import 'package:flutter/material.dart';

class QuizResultActionsBar extends StatelessWidget {
  final bool hasPassed;
  final VoidCallback onDone;
  final VoidCallback onBackToLesson;
  final VoidCallback onRetryQuiz;

  const QuizResultActionsBar({
    super.key,
    required this.hasPassed,
    required this.onDone,
    required this.onBackToLesson,
    required this.onRetryQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (hasPassed) {
              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onDone,
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                ),
              );
            }

            final backButton = OutlinedButton.icon(
              onPressed: onBackToLesson,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Lesson'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: constraints.maxWidth < 360 ? 12 : 14,
                ),
              ),
            );
            final retryButton = FilledButton.icon(
              onPressed: onRetryQuiz,
              icon: const Icon(Icons.replay),
              label: const Text('Retry Quiz'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: constraints.maxWidth < 360 ? 12 : 14,
                ),
              ),
            );

            return Row(
              children: [
                Expanded(child: backButton),
                const SizedBox(width: 10),
                Expanded(child: retryButton),
              ],
            );
          },
        ),
      ),
    );
  }
}
