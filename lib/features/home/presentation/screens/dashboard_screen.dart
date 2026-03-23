import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/services/signed_in_state_refresh_service.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../shared/widgets/ready_offline_banner.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../gamification/providers/gamification_provider.dart';
import '../../../gamification/providers/spaced_practice_provider.dart';
import '../../../learning/providers/courses_provider.dart';
import '../widgets/dashboard_badges_earned_card.dart';
import '../widgets/dashboard_daily_challenge.dart';
import '../widgets/dashboard_due_for_review_card.dart';
import '../widgets/dashboard_learning_progress_card.dart';
import '../widgets/dashboard_overview_hero.dart';
import '../widgets/dashboard_recent_activity.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToPractice;

  const DashboardScreen({super.key, this.onNavigateToPractice});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SignedInStateRefreshService _refreshService =
      SignedInStateRefreshService();
  String? _loadedForUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() => _syncDashboard(reloadCourses: false);

  Future<void> _refresh() => _syncDashboard(reloadCourses: true);

  Future<void> _syncDashboard({required bool reloadCourses}) async {
    final authProvider = context.read<AuthProvider>();
    final gamification = context.read<GamificationProvider>();
    final spaced = context.read<SpacedPracticeProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    _loadedForUserId = userId;
    final courses = context.read<CoursesProvider>();
    if (reloadCourses) {
      await courses.refresh();
    } else {
      await courses.loadCourses(userId);
    }
    if (!mounted) return;

    await _refreshSupportingState(
      userId: userId,
      authProvider: authProvider,
      gamification: gamification,
      spaced: spaced,
    );
    if (!mounted) return;

    setState(() {});
    _checkNewBadges();
  }

  Future<void> _refreshSupportingState({
    required String userId,
    required AuthProvider authProvider,
    required GamificationProvider gamification,
    required SpacedPracticeProvider spaced,
  }) {
    return _refreshService.refresh(
      userId: userId,
      authProvider: authProvider,
      gamificationProvider: gamification,
      spacedPracticeProvider: spaced,
    );
  }

  void _checkNewBadges() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final gamification = context.read<GamificationProvider>();
      final newly = gamification.newlyUnlocked;
      if (newly.isEmpty) return;

      final names = newly.map((badge) => badge.name).join(', ');
      AppFeedback.show(
        context,
        'Badge${newly.length > 1 ? 's' : ''} unlocked: $names!',
        type: AppFeedbackType.success,
      );
      gamification.clearNewlyUnlocked();
    });
  }

  void _scheduleReloadForUser(String userId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loadedForUserId == userId) return;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final gamification = context.watch<GamificationProvider>();
    final spaced = context.watch<SpacedPracticeProvider>();
    final courses = context.watch<CoursesProvider>();

    if (user != null && _loadedForUserId != user.id) {
      _scheduleReloadForUser(user.id);
    }

    final completedLessons = courses.totalCompletedLessons;
    final totalLessons = courses.courses.fold<int>(
      0,
      (sum, course) => sum + courses.lessonsForCourse(course.id).length,
    );
    final showOfflineBanner =
        (courses.syncFailed && courses.hasData) ||
        (gamification.syncFailed && gamification.hasData);

    return Column(
      children: [
        ReadyOfflineBanner(visible: showOfflineBanner),
        Expanded(
          child: Container(
            color: const Color(0xFFF5F2FA),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardOverviewHero(
                      username: _displayName(user?.fullName, user?.username),
                      streak: user?.currentStreak ?? 0,
                      totalPoints: user?.totalPoints ?? 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 120, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DashboardDailyChallenge(
                            gamification: gamification,
                            onNavigateToPractice: widget.onNavigateToPractice,
                          ),
                          const SizedBox(height: 16),
                          DashboardLearningProgressCard(
                            completedLessons: completedLessons,
                            totalLessons: totalLessons,
                            streak: user?.currentStreak ?? 0,
                            dueSchedules: spaced.dueSchedules,
                          ),
                          const SizedBox(height: 16),
                          DashboardBadgesEarnedCard(
                            allBadges: gamification.allBadges,
                            earnedBadgeIds: gamification.earnedBadgeIds,
                            onTap: () => context.push(AppRouter.badges),
                          ),
                          const SizedBox(height: 16),
                          DashboardDueForReviewCard(
                            spaced: spaced,
                            courses: courses,
                            onSeeAll: widget.onNavigateToPractice,
                          ),
                          const SizedBox(height: 16),
                          DashboardRecentActivityCard(
                            spaced: spaced,
                            userId: user?.id,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _displayName(String? fullName, String? username) {
  if (fullName != null && fullName.trim().isNotEmpty) {
    return fullName.trim();
  }
  if (username != null && username.trim().isNotEmpty) {
    return username.trim();
  }
  return 'Learner';
}
