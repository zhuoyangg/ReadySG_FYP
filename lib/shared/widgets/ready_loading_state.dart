import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Consistent centered loading indicator with optional label.
class ReadyLoadingState extends StatelessWidget {
  final String? label;

  const ReadyLoadingState({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (label != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                label!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppSemanticColors.of(context).subtleText,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
