import 'package:flutter/material.dart';

enum AppFeedbackType { info, success, warning, error }

class AppFeedback {
  static void show(
    BuildContext context,
    String message, {
    AppFeedbackType type = AppFeedbackType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final colors = Theme.of(context).colorScheme;
    final backgroundColor = switch (type) {
      AppFeedbackType.info => colors.inverseSurface,
      AppFeedbackType.success => Colors.green.shade700,
      AppFeedbackType.warning => Colors.orange.shade800,
      AppFeedbackType.error => colors.error,
    };
    final foregroundColor = switch (type) {
      AppFeedbackType.info => colors.onInverseSurface,
      AppFeedbackType.success => Colors.white,
      AppFeedbackType.warning => Colors.white,
      AppFeedbackType.error => colors.onError,
    };

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          duration: duration,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}
