import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Reusable quiz option tile with letter badge (A/B/C/D), selection state,
/// Material ink ripple, and proper accessibility.
class ReadyOptionTile extends StatelessWidget {
  final String label;
  final String optionLetter;
  final bool isSelected;
  final VoidCallback onTap;

  const ReadyOptionTile({
    super.key,
    required this.label,
    required this.optionLetter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        label: 'Option $optionLetter: $label',
        selected: isSelected,
        button: true,
        child: Material(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizing.cardRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizing.cardRadius),
            onTap: onTap,
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizing.cardRadius),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      optionLetter,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color:
                            isSelected ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color:
                          isSelected ? Colors.white : colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
