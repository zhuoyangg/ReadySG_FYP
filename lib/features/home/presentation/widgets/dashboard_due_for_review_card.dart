import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../gamification/providers/spaced_practice_provider.dart';
import '../../../learning/data/models/course_model.dart';
import '../../../learning/providers/courses_provider.dart';
import 'dashboard_section_card.dart';

/// Returns an accent color for a given course [category] slug.
Color courseAccentColor(BuildContext context, String category) {
  switch (category) {
    case 'cpr':
      return const Color(0xFFE91E8C);
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

class DashboardDueForReviewCard extends StatelessWidget {
  final SpacedPracticeProvider spaced;
  final CoursesProvider courses;
  final VoidCallback? onSeeAll;

  const DashboardDueForReviewCard({
    super.key,
    required this.spaced,
    required this.courses,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final due = spaced.dueSchedules.take(3).toList();
    final tokens = AppSemanticColors.of(context);

    return DashboardSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionTitle(
            icon: Icons.event_repeat_outlined,
            title: 'Due for Review',
            color: const Color(0xFF8A3FFC),
            trailing: spaced.dueCount > 3
                ? TextButton(
                    onPressed: onSeeAll,
                    child: Text('See All (${spaced.dueCount})'),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          if (due.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: tokens.success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All caught up. No lesson reviews due right now.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.subtleText,
                          ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: due.map((schedule) {
                final lesson = spaced.findLesson(schedule.lessonId);
                final course = lesson == null
                    ? null
                    : _courseFor(courses, lesson.courseId);
                final accent = courseAccentColor(
                  context,
                  course?.category ?? 'emergency_prep',
                );
                final reviewLabel = schedule.daysOverdue > 0
                    ? '${schedule.daysOverdue}d overdue'
                    : 'Due today';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson?.title ?? schedule.lessonId,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: accent.withValues(alpha: 0.18),
                                    ),
                                  ),
                                  child: Text(
                                    course?.difficultyLabel ?? 'Review',
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  reviewLabel,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: schedule.daysOverdue > 0
                                            ? tokens.danger
                                            : accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: lesson != null
                            ? () =>
                                  context.push(AppRouter.lessonPath(lesson.id))
                            : null,
                        child: Text(
                          'Review',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  CourseModel? _courseFor(CoursesProvider courses, String courseId) {
    for (final course in courses.courses) {
      if (course.id == courseId) return course;
    }
    return null;
  }
}
