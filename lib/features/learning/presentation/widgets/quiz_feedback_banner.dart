import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class QuizFeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final String? explanation;

  const QuizFeedbackBanner({
    super.key,
    required this.isCorrect,
    this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);
    final color = isCorrect ? tokens.success : tokens.danger;
    final icon = isCorrect ? '🎉' : '✗';
    final title = isCorrect ? 'Correct!' : 'Not quite right';
    final subtitle = isCorrect
        ? (explanation ?? "Great job! You've mastered this lesson.")
        : (explanation ??
            'The correct answer is highlighted above. Review the lesson to learn more.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: color.withValues(alpha: 0.85), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
