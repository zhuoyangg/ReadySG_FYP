import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Persistent banner shown at the top of scrollable content when cached data
/// is being displayed but background sync has failed.
class ReadyOfflineBanner extends StatelessWidget {
  final bool visible;

  const ReadyOfflineBanner({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: AppSizing.iconSm,
            color: AppSemanticColors.of(context).subtleText,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Showing cached data',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppSemanticColors.of(context).subtleText,
                ),
          ),
        ],
      ),
    );
  }
}
