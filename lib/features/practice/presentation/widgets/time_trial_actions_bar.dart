import 'package:flutter/material.dart';

class TimeTrialActionsBar extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const TimeTrialActionsBar({
    super.key,
    required this.isEnabled,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isEnabled ? onRetry : null,
                child: const Text('Retry'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: isEnabled ? onDone : null,
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
