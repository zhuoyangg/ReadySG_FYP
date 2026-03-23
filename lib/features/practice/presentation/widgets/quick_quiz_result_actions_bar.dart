import 'package:flutter/material.dart';

class QuickQuizResultActionsBar extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const QuickQuizResultActionsBar({
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isEnabled ? onRetry : null,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: constraints.maxWidth < 340 ? 12 : 14,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isEnabled ? onDone : null,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: constraints.maxWidth < 340 ? 12 : 14,
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
