import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/courses_provider.dart';

class LessonQuizPromptSlide extends StatelessWidget {
  final String lessonId;
  final String lessonTitle;
  final int lessonPoints;

  const LessonQuizPromptSlide({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonPoints,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.quiz_outlined, size: 48, color: colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Quiz Time!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            "Let's test what you've learnt.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppSemanticColors.of(context).subtleText,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Earn $lessonPoints points on completion!',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                context.read<CoursesProvider>().refreshProgress(userId);
                context.pushReplacement(AppRouter.quizPath(lessonId));
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Quiz'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
