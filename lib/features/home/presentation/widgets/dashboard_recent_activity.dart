import 'package:flutter/material.dart';

import '../../../../core/config/hive_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/app_clock.dart';
import '../../../../core/services/recent_activity_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/time_ago_formatter.dart';
import '../../../gamification/providers/spaced_practice_provider.dart';
import 'dashboard_section_card.dart';

class DashboardRecentActivityCard extends StatelessWidget {
  final SpacedPracticeProvider spaced;
  final String? userId;

  static final RecentActivityService _activityService = RecentActivityService();
  static final HiveConfig _hive = HiveConfig();

  const DashboardRecentActivityCard({
    super.key,
    required this.spaced,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (userId == null) return const SizedBox.shrink();
    return ValueListenableBuilder<int>(
      valueListenable: _activityService.changes,
      builder: (context, _, _) {
        var recent = _activityService.getRecentActivities(userId!, limit: 5);
        if (recent.isEmpty) {
          recent = spaced
              .getRecentActivity(userId!, limit: 5)
              .map<RecentActivityEntry>((progress) {
            final timestamp = progress.completedAt ?? AppClock.now();
            final title =
                spaced.findLesson(progress.lessonId)?.title ?? progress.lessonId;
            final quizTotal = _quizCountForLesson(progress.lessonId);
            return RecentActivityEntry(
              id: RecentActivityEntry.generateId(
                type: RecentActivityType.moduleCompletion,
                timestamp: timestamp,
                title: title,
              ),
              type: RecentActivityType.moduleCompletion,
              timestamp: timestamp,
              title: title,
              score: progress.bestScore,
              correctAnswers: quizTotal == 0
                  ? null
                  : _estimatedCorrectAnswers(progress.bestScore, quizTotal),
              totalQuestions: quizTotal == 0 ? null : quizTotal,
              passed: progress.bestScore >= AppConstants.defaultPassingScore,
            );
          }).toList();
        }

        return DashboardSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardSectionTitle(
                icon: Icons.history_rounded,
                title: 'Recent Activity',
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              if (recent.isEmpty)
                Text(
                  'No activity yet. Complete your first lesson to start your timeline.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppSemanticColors.of(context).subtleText,
                  ),
                )
              else
                Column(
                  children: recent.map((activity) {
                    return _RecentActivityTile(
                      activity: activity,
                      timeAgo: TimeAgoFormatter.format(activity.timestamp),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  int _quizCountForLesson(String lessonId) {
    return _hive.quizzesBox.values
        .where((quiz) => quiz.lessonId == lessonId)
        .length;
  }

  int? _estimatedCorrectAnswers(int percent, int totalQuestions) {
    for (var correct = 0; correct <= totalQuestions; correct++) {
      final candidate = ((correct / totalQuestions) * 100).round();
      if (candidate == percent) return correct;
    }
    return null;
  }
}

class _RecentActivityTile extends StatelessWidget {
  final RecentActivityEntry activity;
  final String timeAgo;

  const _RecentActivityTile({required this.activity, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final visuals = _visualsFor(context, activity);
    final tokens = AppSemanticColors.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: visuals.background,
            ),
            child: Icon(visuals.icon, color: visuals.foreground, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitleFor(activity),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.subtleText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeAgo,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tokens.subtleText),
          ),
        ],
      ),
    );
  }

  String _subtitleFor(RecentActivityEntry activity) {
    switch (activity.type) {
      case RecentActivityType.dailyChallenge:
        final streak = activity.streakCount ?? 0;
        final points = activity.pointsEarned ?? 0;
        return '+$points pts - +1 streak ($streak total)';
      case RecentActivityType.moduleCompletion:
        final result = activity.passed == true
            ? 'Passed lesson quiz'
            : 'Failed lesson quiz';
        return '$result - ${_scoreLabel(activity)}';
      case RecentActivityType.moduleReview:
        final result = activity.passed == true
            ? 'Passed review quiz'
            : 'Failed review quiz';
        return '$result - ${_scoreLabel(activity)}';
      case RecentActivityType.quickQuiz:
        final result = activity.passed == true
            ? 'Passed quick quiz'
            : 'Failed quick quiz';
        return '$result - ${_scoreLabel(activity)}';
      case RecentActivityType.timeTrial:
        final points = activity.pointsEarned ?? 0;
        final score = _scoreLabel(activity);
        return points > 0
            ? '$score - +$points pts'
            : '$score in 30 sec';
      case RecentActivityType.badgeEarned:
        final points = activity.pointsEarned ?? 0;
        return points > 0 ? 'Badge earned - +$points pts' : 'Badge earned';
    }
  }

  String _scoreLabel(RecentActivityEntry activity) {
    final correctAnswers = activity.correctAnswers;
    final totalQuestions = activity.totalQuestions;
    if (correctAnswers != null &&
        totalQuestions != null &&
        totalQuestions > 0) {
      return '$correctAnswers/$totalQuestions';
    }
    return '${activity.score ?? 0}%';
  }

  _ActivityVisuals _visualsFor(
    BuildContext context,
    RecentActivityEntry activity,
  ) {
    final tokens = AppSemanticColors.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (activity.type == RecentActivityType.dailyChallenge) {
      return _ActivityVisuals(
        icon: Icons.bolt,
        background: tokens.points.withValues(alpha: 0.18),
        foreground: tokens.points,
      );
    }
    if (activity.type == RecentActivityType.badgeEarned) {
      return _ActivityVisuals(
        icon: Icons.military_tech,
        background: tokens.achievement.withValues(alpha: 0.18),
        foreground: tokens.achievement,
      );
    }
    if (activity.passed != null) {
      final passed = activity.passed!;
      return _ActivityVisuals(
        icon: passed ? Icons.check_circle : Icons.cancel,
        background: (passed ? tokens.success : tokens.danger).withValues(
          alpha: 0.16,
        ),
        foreground: passed ? tokens.success : tokens.danger,
      );
    }
    return _ActivityVisuals(
      icon: Icons.history_rounded,
      background: colorScheme.primaryContainer,
      foreground: colorScheme.onPrimaryContainer,
    );
  }
}

class _ActivityVisuals {
  final IconData icon;
  final Color background;
  final Color foreground;

  const _ActivityVisuals({
    required this.icon,
    required this.background,
    required this.foreground,
  });
}
