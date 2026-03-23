import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Colored score badge that changes color based on score threshold.
/// >= 80: success, >= 60: warning, else: danger.
class ReadyScoreBadge extends StatelessWidget {
  final int score;
  final String? suffix;

  const ReadyScoreBadge({
    super.key,
    required this.score,
    this.suffix = '%',
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);
    final color = _scoreColor(tokens);

    return Semantics(
      label: 'Score: $score percent',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizing.cardRadius),
        ),
        child: Text(
          '$score${suffix ?? ''}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Color _scoreColor(AppSemanticColors tokens) {
    if (score >= 80) return tokens.success;
    if (score >= 60) return tokens.warning;
    return tokens.danger;
  }
}
