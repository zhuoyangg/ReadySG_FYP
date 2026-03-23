import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/recent_activity_service.dart';
import '../../../../core/services/signed_in_state_refresh_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../gamification/providers/spaced_practice_provider.dart';
import '../../../learning/data/models/quiz_model.dart';
import '../widgets/practice_activity_card.dart';
import '../widgets/practice_hero_banner.dart';
import '../widgets/practice_recent_scores_section.dart';
import '../widgets/practice_section_heading.dart';
import '../widgets/practice_tip_card.dart';
import '../widgets/practice_weak_topics_section.dart';
import 'quick_quiz_screen.dart';
import 'time_trial_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  static final RecentActivityService _activityService = RecentActivityService();
  final SignedInStateRefreshService _refreshService =
      SignedInStateRefreshService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() => _refreshSignedInState();

  Future<void> _refreshSignedInState() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;
    await _refreshService.refresh(
      userId: userId,
      authProvider: authProvider,
      spacedPracticeProvider: context.read<SpacedPracticeProvider>(),
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final userId = user?.id;
    final spaced = context.watch<SpacedPracticeProvider>();
    final tokens = AppSemanticColors.of(context);

    return RefreshIndicator(
      color: tokens.achievement,
      onRefresh: _refreshSignedInState,
      child: Container(
        color: const Color(0xFFF5F2FA),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ValueListenableBuilder<int>(
            valueListenable: _activityService.changes,
            builder: (context, _, _) {
              final practicePoints = userId == null
                  ? 0
                  : _activityService.getPracticePointsTotal(userId);
              final recentScores = userId == null
                  ? const <RecentActivityEntry>[]
                  : _recentScoreEntries(userId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PracticeHeroBanner(totalPoints: practicePoints),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PracticeSectionHeading(title: 'Choose an Activity'),
                        const SizedBox(height: 14),
                        PracticeActivityCard(
                          accent: const Color(0xFFA62BFF),
                          iconBackground: const Color(0xFFA62BFF),
                          icon: Icons.psychology_alt_outlined,
                          title: 'Quick Quiz',
                          description:
                              'Test your knowledge with random questions',
                          durationLabel: '5-10 min',
                          levelLabel: 'Mixed',
                          pointsLabel: '+50 pts',
                          onPressed: () => _openQuickQuiz(context, spaced),
                        ),
                        const SizedBox(height: 14),
                        PracticeActivityCard(
                          accent: const Color(0xFFFF5A00),
                          iconBackground: const Color(0xFFFF6A00),
                          icon: Icons.timer_outlined,
                          title: 'Time Trial Challenge',
                          description:
                              'Answer as many questions as you can in 30 seconds',
                          durationLabel: '30 sec',
                          levelLabel: 'Advanced',
                          pointsLabel: '+100 pts',
                          onPressed: () => _openTimeTrial(context, spaced),
                        ),
                        const SizedBox(height: 24),
                        PracticeWeakTopicsSection(spaced: spaced, userId: userId),
                        const SizedBox(height: 24),
                        PracticeRecentScoresSection(entries: recentScores),
                        const SizedBox(height: 24),
                        const PracticeTipCard(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<RecentActivityEntry> _recentScoreEntries(String userId) {
    return _activityService
        .getRecentActivities(userId, limit: 12)
        .where((entry) {
          return entry.type == RecentActivityType.quickQuiz ||
              entry.type == RecentActivityType.timeTrial;
        })
        .take(3)
        .toList();
  }

  Future<void> _openQuickQuiz(
    BuildContext context,
    SpacedPracticeProvider spaced,
  ) {
    return _openPracticeActivity(
      context: context,
      questions: spaced.getQuickQuizQuestions(),
      screenBuilder: (questions) => QuickQuizScreen(questions: questions),
    );
  }

  Future<void> _openTimeTrial(
    BuildContext context,
    SpacedPracticeProvider spaced,
  ) {
    return _openPracticeActivity(
      context: context,
      questions: spaced.getQuickQuizQuestions(count: 60),
      screenBuilder: (questions) => TimeTrialScreen(questions: questions),
    );
  }

  Future<void> _openPracticeActivity({
    required BuildContext context,
    required List<QuizModel> questions,
    required Widget Function(List<QuizModel> questions) screenBuilder,
  }) async {
    if (questions.isEmpty) {
      AppFeedback.show(
        context,
        'No questions available yet.',
        type: AppFeedbackType.warning,
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => screenBuilder(questions),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }
}
