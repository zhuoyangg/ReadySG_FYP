import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../gamification/providers/spaced_practice_provider.dart';
import 'practice_section_heading.dart';

class PracticeWeakTopicsSection extends StatelessWidget {
  final SpacedPracticeProvider spaced;
  final String? userId;

  const PracticeWeakTopicsSection({
    super.key,
    required this.spaced,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (userId == null) return const SizedBox.shrink();
    final weakLessons = spaced.getWeakLessons(userId!).take(3).toList();
    final tokens = AppSemanticColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PracticeSectionHeading(title: 'Weak Topics'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD9DDE7)),
          ),
          child: weakLessons.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events_outlined, color: tokens.points),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No weak topics right now. Keep the streak going.',
                          style: TextStyle(color: tokens.subtleText),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: List.generate(weakLessons.length, (index) {
                    final entry = weakLessons[index];
                    final lesson = entry['lesson'] as dynamic;
                    final score = entry['score'] as int;

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: tokens.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                '$score%',
                                style: TextStyle(
                                  color: tokens.danger,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            lesson.title as String? ?? 'Unknown lesson',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: const Text('Review this lesson to improve'),
                          trailing:
                              const Icon(Icons.chevron_right_rounded, size: 18),
                          onTap: () => context.push(
                            AppRouter.lessonPath(lesson.id as String),
                          ),
                        ),
                        if (index != weakLessons.length - 1)
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
