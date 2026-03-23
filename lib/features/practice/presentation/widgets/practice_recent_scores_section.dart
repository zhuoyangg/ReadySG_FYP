import 'package:flutter/material.dart';

import '../../../../core/services/recent_activity_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/time_ago_formatter.dart';
import 'practice_section_heading.dart';

class PracticeRecentScoresSection extends StatelessWidget {
  final List<RecentActivityEntry> entries;

  const PracticeRecentScoresSection({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PracticeSectionHeading(
          title: 'Recent Scores',
          icon: Icons.star_outline_rounded,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD9DDE7)),
          ),
          child: entries.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No scores yet. Start a practice activity to fill this in.',
                  ),
                )
              : Column(
                  children: List.generate(entries.length, (index) {
                    final entry = entries[index];
                    return Column(
                      children: [
                        _RecentScoreTile(entry: entry),
                        if (index != entries.length - 1)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }
}

class _RecentScoreTile extends StatelessWidget {
  final RecentActivityEntry entry;

  const _RecentScoreTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TimeAgoFormatter.format(entry.timestamp),
                  style: TextStyle(color: tokens.subtleText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _scoreText(entry),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              if ((entry.pointsEarned ?? 0) > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: Color(0xFFFFB000),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+${entry.pointsEarned}',
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static String _scoreText(RecentActivityEntry entry) {
    switch (entry.type) {
      case RecentActivityType.quickQuiz:
        final correct = entry.correctAnswers ?? 0;
        final total = entry.totalQuestions ?? 0;
        return total > 0 ? '$correct/$total' : '${entry.score ?? 0}%';
      case RecentActivityType.timeTrial:
        final correct = entry.correctAnswers ?? 0;
        final total = entry.totalQuestions ?? 0;
        return '$correct/$total';
      case RecentActivityType.moduleCompletion:
      case RecentActivityType.moduleReview:
        return '${entry.score ?? 0}%';
      case RecentActivityType.dailyChallenge:
      case RecentActivityType.badgeEarned:
        return '${entry.pointsEarned ?? 0} pts';
    }
  }
}
