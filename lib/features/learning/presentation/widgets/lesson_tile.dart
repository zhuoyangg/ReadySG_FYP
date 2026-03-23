import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../data/models/lesson_model.dart';

class LessonTile extends StatelessWidget {
  final int number;
  final LessonModel lesson;
  final bool isCompleted;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const LessonTile({
    super.key,
    required this.number,
    required this.lesson,
    required this.isCompleted,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppSemanticColors.of(context);
    final colorScheme = theme.colorScheme;

    // Status icon
    Widget statusIcon;
    if (isCompleted) {
      statusIcon = Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: tokens.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 22),
      );
    } else if (isUnlocked) {
      statusIcon = Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
      );
    } else {
      statusIcon = Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.lock_outline, color: tokens.subtleText, size: 20),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              statusIcon,
              const SizedBox(width: 14),

              // Lesson number label + title + badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'LESSON $number',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tokens.subtleText,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 8),
                          _CompletedBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? colorScheme.onSurface
                            : tokens.subtleText,
                      ),
                    ),
                    if (lesson.description.isNotEmpty && isUnlocked) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.schedule_outlined,
                              size: 13, color: tokens.subtleText),
                          const SizedBox(width: 4),
                          Text(
                            '${(lesson.points / 2).round()} min',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: tokens.subtleText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: tokens.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Completed',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: tokens.success,
        ),
      ),
    );
  }
}
