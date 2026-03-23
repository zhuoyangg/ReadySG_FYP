import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Standard error-state widget shown when data loading fails and no cache
/// is available.
class ReadyErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ReadyErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: tokens.danger),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: TextStyle(color: tokens.danger),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
