import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class LessonNavBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool isLastContentSlide;

  const LessonNavBar({
    super.key,
    required this.current,
    required this.total,
    required this.onPrev,
    required this.onNext,
    required this.isLastContentSlide,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPrev = onPrev != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final previousButton = OutlinedButton.icon(
              onPressed: onPrev,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: constraints.maxWidth < 360 ? 12 : 14,
                ),
                foregroundColor: hasPrev
                    ? colorScheme.onSurface
                    : AppSemanticColors.of(context).subtleText,
                side: BorderSide(
                  color: hasPrev
                      ? colorScheme.outline
                      : colorScheme.outline.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            final nextButton = FilledButton.icon(
              onPressed: onNext,
              icon: Icon(
                isLastContentSlide ? Icons.quiz : Icons.arrow_forward,
                size: 18,
              ),
              label: Text(isLastContentSlide ? 'Take Quiz' : 'Next'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: constraints.maxWidth < 360 ? 12 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            return Row(
              children: [
                Expanded(child: previousButton),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: nextButton),
              ],
            );
          },
        ),
      ),
    );
  }
}
