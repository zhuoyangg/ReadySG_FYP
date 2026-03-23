import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Compact stat display chip used in the Dashboard stats row.
/// Shows icon + value + label, with optional tap navigation.
class ReadyStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const ReadyStatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);
    return Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizing.minTouchTarget),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: onTap != null ? Clip.antiAlias : Clip.none,
          child: Semantics(
            label: '$value $label',
            button: onTap != null,
            child: InkWell(
              onTap: onTap,
              child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: tokens.subtleText),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(height: 2),
                    Icon(Icons.chevron_right,
                        size: 12, color: tokens.subtleText),
                  ],
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
