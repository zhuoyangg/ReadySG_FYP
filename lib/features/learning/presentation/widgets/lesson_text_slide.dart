import 'package:flutter/material.dart';

class LessonTextSlide extends StatelessWidget {
  final Map<String, dynamic> slide;
  const LessonTextSlide({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    final title = slide['title'] as String?;
    final body = slide['body'] as String? ?? '';
    final lines = body.split('\n').where((l) => l.isNotEmpty).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
          ],
          ...lines.map((line) {
            final isBullet =
                line.startsWith('• ') || line.startsWith('- ') || line.startsWith('* ');
            if (isBullet) {
              final text = line.substring(2).trim();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                line,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      color: line.startsWith('"') || line.startsWith('Note:')
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
