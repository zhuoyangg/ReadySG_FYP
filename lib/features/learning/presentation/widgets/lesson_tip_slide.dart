import 'package:flutter/material.dart';

class LessonTipSlide extends StatelessWidget {
  final Map<String, dynamic> slide;
  const LessonTipSlide({super.key, required this.slide});

  // These colors are intentionally not tokenized — they are data-driven
  // per-slide accent colors, not semantic design-system tokens.
  static Color _bgColor(String? color) {
    switch (color) {
      case 'green':
        return Colors.green.shade50;
      case 'red':
        return Colors.red.shade50;
      case 'yellow':
        return Colors.yellow.shade50;
      case 'orange':
        return Colors.orange.shade50;
      default:
        return Colors.blue.shade50;
    }
  }

  static Color _accentColor(String? color) {
    switch (color) {
      case 'green':
        return Colors.green.shade700;
      case 'red':
        return Colors.red.shade700;
      case 'yellow':
        return Colors.orange.shade700;
      case 'orange':
        return Colors.orange.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = slide['title'] as String? ?? 'Remember!';
    final body = slide['body'] as String? ?? '';
    final color = slide['color'] as String?;
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 380 || size.height < 760;
    final iconSize = compact ? 48.0 : 56.0;
    final topPadding = compact ? 20.0 : 24.0;
    final contentPadding = compact ? 18.0 : 24.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              Icons.lightbulb,
              size: iconSize,
              color: _accentColor(color),
            ),
          ),
          SizedBox(height: compact ? 16 : 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(contentPadding),
            decoration: BoxDecoration(
              color: _bgColor(color),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _accentColor(color).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _accentColor(color),
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: compact ? 1.55 : 1.7,
                        color: _accentColor(color).withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
