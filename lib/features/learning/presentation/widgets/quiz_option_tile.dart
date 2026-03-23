import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class QuizOptionTile extends StatelessWidget {
  final String label;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool hasSubmitted;
  final VoidCallback? onTap;

  const QuizOptionTile({
    super.key,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.hasSubmitted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    final isCorrect = index == correctIndex;
    final tokens = AppSemanticColors.of(context);
    final cs = Theme.of(context).colorScheme;

    Color borderColor;
    Color bgColor;
    Color textColor;
    Widget radioWidget;

    if (!hasSubmitted) {
      if (isSelected) {
        borderColor = cs.primary;
        bgColor = cs.primary.withValues(alpha: 0.06);
        textColor = cs.onSurface;
        radioWidget = _Radio(filled: true, color: cs.primary);
      } else {
        borderColor = cs.outline;
        bgColor = Colors.white;
        textColor = cs.onSurface;
        radioWidget = _Radio(filled: false, color: cs.outline);
      }
    } else {
      if (isCorrect) {
        borderColor = tokens.success;
        bgColor = tokens.success.withValues(alpha: 0.08);
        textColor = cs.onSurface;
        radioWidget = _RadioIcon(icon: Icons.check, color: tokens.success);
      } else if (isSelected) {
        borderColor = tokens.danger;
        bgColor = tokens.danger.withValues(alpha: 0.08);
        textColor = cs.onSurface;
        radioWidget = _RadioIcon(icon: Icons.close, color: tokens.danger);
      } else {
        borderColor = cs.outline.withValues(alpha: 0.35);
        bgColor = Colors.white;
        textColor = tokens.subtleText;
        radioWidget = _Radio(filled: false, color: cs.outline.withValues(alpha: 0.35));
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            radioWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      fontWeight: isSelected || (hasSubmitted && isCorrect)
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool filled;
  final Color color;
  const _Radio({required this.filled, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: filled
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}

class _RadioIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _RadioIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 14),
    );
  }
}
