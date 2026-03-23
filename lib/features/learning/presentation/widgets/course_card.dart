import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../data/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final int completedCount;
  final int totalCount;
  final double progressFraction;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.completedCount,
    required this.totalCount,
    required this.progressFraction,
    required this.onTap,
  });

  Color _accentColor(BuildContext context) {
    switch (course.category) {
      case 'cpr':
        return const Color(0xFF1565C0);
      case 'first_aid':
        return const Color(0xFFFF9800);
      case 'fire_safety':
        return const Color(0xFFFF5722);
      case 'aed':
        return const Color(0xFF4CAF50);
      case 'emergency_prep':
        return Theme.of(context).colorScheme.primary;
      default:
        return const Color(0xFF607D8B);
    }
  }

  int get _estimatedMinutes => totalCount * 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppSemanticColors.of(context);
    final accent = _accentColor(context);
    final hasProgress = completedCount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'course_icon_${course.id}',
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              course.categoryEmoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: tokens.subtleText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _DifficultyChip(course.difficultyLabel),
                                const SizedBox(width: 8),
                                Text(
                                  '$totalCount lesson${totalCount == 1 ? '' : 's'} - $_estimatedMinutes min',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: tokens.subtleText,
                                  ),
                                ),
                              ],
                            ),
                            if (hasProgress) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Progress',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: tokens.subtleText,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$completedCount/$totalCount completed',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: tokens.progress,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progressFraction,
                                  minHeight: 5,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation(accent),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: tokens.subtleText),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;

  const _DifficultyChip(this.label);

  Color _color() {
    switch (label.toLowerCase()) {
      case 'beginner':
        return Colors.green.shade600;
      case 'intermediate':
        return Colors.orange.shade700;
      case 'advanced':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
