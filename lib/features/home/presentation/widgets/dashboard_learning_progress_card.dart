import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../gamification/data/models/spaced_practice_model.dart';
import 'dashboard_section_card.dart';

class DashboardLearningProgressCard extends StatelessWidget {
  final int completedLessons;
  final int totalLessons;
  final int streak;
  final List<SpacedPracticeModel> dueSchedules;

  const DashboardLearningProgressCard({
    super.key,
    required this.completedLessons,
    required this.totalLessons,
    required this.streak,
    required this.dueSchedules,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);
    final remaining = (totalLessons - completedLessons).clamp(0, totalLessons);
    final fraction = totalLessons == 0 ? 0.0 : completedLessons / totalLessons;
    final overdueCount = dueSchedules.where((item) => item.daysOverdue > 0).length;
    final onTrack = remaining == 0 || (streak >= 3 && overdueCount == 0);
    final statusLabel = remaining == 0
        ? 'Completed'
        : overdueCount > 0
        ? 'Review backlog'
        : streak == 0
        ? 'Start streak'
        : onTrack
        ? 'On track'
        : 'Keep going';
    final statusColor = remaining == 0
        ? tokens.success
        : overdueCount > 0
        ? tokens.danger
        : onTrack
        ? tokens.success
        : tokens.warning;
    final weeklyPace = overdueCount > 0 ? streak.clamp(1, 4) : streak.clamp(1, 7);
    final weeksToComplete =
        remaining == 0 ? 0 : (remaining / weeklyPace).ceil().clamp(1, 99);
    final estimateLabel = remaining == 0
        ? 'All lessons completed'
        : overdueCount > 0
        ? '$overdueCount overdue review${overdueCount == 1 ? '' : 's'}'
        : dueSchedules.isNotEmpty
        ? '${dueSchedules.length} review${dueSchedules.length == 1 ? '' : 's'} due'
        : '~$weeksToComplete week${weeksToComplete == 1 ? '' : 's'} to complete';

    return DashboardSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionTitle(
            icon: Icons.menu_book_outlined,
            title: 'Learning Progress',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text('Lessons Completed', style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Text(
                '$completedLessons/$totalLessons',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 10,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                onTrack || remaining == 0
                    ? Icons.trending_up
                    : Icons.warning_amber_rounded,
                size: 18,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                statusLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time_rounded, size: 18, color: tokens.subtleText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  estimateLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: tokens.subtleText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
