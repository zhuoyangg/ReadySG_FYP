import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/hive_config.dart';
import '../../../../core/services/recent_activity_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../gamification/providers/gamification_provider.dart';
import '../../../learning/providers/courses_provider.dart';
import '../widgets/profile_hero_card.dart';
import '../widgets/profile_section_card.dart';
import 'profile_notifications_screen.dart';
import 'profile_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static final RecentActivityService _activityService = RecentActivityService();
  static final HiveConfig _hive = HiveConfig();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final gamification = context.watch<GamificationProvider>();
    final courses = context.watch<CoursesProvider>();
    final tokens = AppSemanticColors.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final displayName = _profileDisplayName(user?.fullName, user?.username);
    final profileStats = _buildProfileStats(courses, user?.id);
    final badgeCount = gamification.earnedBadgeIds.length;

    return Container(
      color: const Color(0xFFF6F7FB),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, topPadding + 22, 20, 136),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B2940),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your account and preferences',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: -118,
                  child: ProfileHeroCard(
                    displayName: displayName,
                    subtitle: 'ReadySG Member',
                    streak: user?.currentStreak ?? 0,
                    points: user?.totalPoints ?? 0,
                    badgeCount: badgeCount,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 134),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                children: [
                  ProfileSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Learning Statistics',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        ProfileStatRow(
                          label: 'Courses Started',
                          value: '${profileStats.coursesStarted}',
                        ),
                        const SizedBox(height: 14),
                        ProfileStatRow(
                          label: 'Courses Completed',
                          value: '${profileStats.coursesCompleted}',
                        ),
                        const SizedBox(height: 14),
                        ProfileStatRow(
                          label: 'Total Study Time',
                          value: _formatDuration(profileStats.studyMinutes),
                        ),
                        const SizedBox(height: 14),
                        ProfileStatRow(
                          label: 'Practice Sessions',
                          value: '${profileStats.practiceSessions}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ProfileActionTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileSettingsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfileActionTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileNotificationsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfileActionTile(
                    icon: Icons.delete_sweep_outlined,
                    iconTint: const Color(0xFFFF6A00),
                    title: 'Clear Downloaded Content',
                    subtitle: 'Refresh downloaded course and emergency data',
                    onTap: () => _confirmClearCache(context),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tokens.danger,
                      side: BorderSide(
                        color: tokens.danger.withValues(alpha: 0.35),
                      ),
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.read<AuthProvider>().signOut(),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ProfileStats _buildProfileStats(CoursesProvider courses, String? userId) {
    if (userId == null) {
      return const _ProfileStats();
    }

    var started = 0;
    var completed = 0;
    var lessonStudyMinutes = 0;

    if (courses.courses.isNotEmpty) {
      for (final course in courses.courses) {
        final lessons = courses.lessonsForCourse(course.id);
        if (lessons.isEmpty) continue;

        final completedLessons = lessons
            .where((lesson) => courses.isLessonCompleted(lesson.id))
            .toList();

        if (completedLessons.isNotEmpty) {
          started++;
        }
        if (completedLessons.length == lessons.length) {
          completed++;
        }

        for (final lesson in completedLessons) {
          lessonStudyMinutes += _estimatedLessonMinutes(lesson.points);
        }
      }
    }

    var reviewStudyMinutes = 0;
    for (final schedule in _hive.spacedPracticeBox.values) {
      if (schedule.userId != userId || schedule.reviewCount <= 0) continue;
      final lesson = _hive.lessonsBox.get(schedule.lessonId);
      if (lesson == null) continue;
      reviewStudyMinutes +=
          _estimatedLessonMinutes(lesson.points) * schedule.reviewCount;
    }

    final recentActivities = _activityService.getRecentActivities(
      userId,
      limit: 30,
    );
    final practiceSessions = recentActivities.where((entry) {
      return entry.type == RecentActivityType.quickQuiz ||
          entry.type == RecentActivityType.timeTrial ||
          entry.type == RecentActivityType.moduleReview;
    }).length;

    return _ProfileStats(
      coursesStarted: started,
      coursesCompleted: completed,
      studyMinutes: lessonStudyMinutes + reviewStudyMinutes,
      practiceSessions: practiceSessions,
    );
  }

  int _estimatedLessonMinutes(int points) => (points / 2).round();

  String _profileDisplayName(String? fullName, String? username) {
    if (fullName != null && fullName.trim().isNotEmpty) {
      return fullName.trim();
    }
    if (username != null && username.trim().isNotEmpty) {
      return username.trim();
    }
    return 'ReadySG User';
  }

  Future<void> _confirmClearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Downloaded Content'),
        content: const Text(
          'This clears downloaded course, guide, badge, and AED data. '
          'Your account, preferences, and personal progress stay on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await HiveConfig().clearContentCaches();
      if (context.mounted) {
        AppFeedback.show(
          context,
          'Downloaded content cleared. Pull to refresh or reopen the app to sync again.',
          type: AppFeedbackType.success,
        );
      }
    }
  }

  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

class _ProfileStats {
  final int coursesStarted;
  final int coursesCompleted;
  final int studyMinutes;
  final int practiceSessions;

  const _ProfileStats({
    this.coursesStarted = 0,
    this.coursesCompleted = 0,
    this.studyMinutes = 0,
    this.practiceSessions = 0,
  });
}
