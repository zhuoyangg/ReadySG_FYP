import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class LessonImageSlide extends StatelessWidget {
  final Map<String, dynamic> slide;
  const LessonImageSlide({super.key, required this.slide});

  Widget _buildImage(BuildContext context, String imageUrl, double frameHeight) {
    final isAsset = imageUrl.startsWith('assets/');
    final image = isAsset
        ? Image.asset(
            imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          )
        : Image.network(
            imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Container(
              height: frameHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.image_not_supported,
                    size: 48,
                    color: AppSemanticColors.of(context).subtleText),
              ),
            ),
          );

    return SizedBox(
      height: frameHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: image,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = slide['title'] as String?;
    final body = slide['body'] as String?;
    final imageUrl = slide['image_url'] as String?;
    final screenHeight = MediaQuery.of(context).size.height;
    final frameHeight = (screenHeight * 0.36).clamp(240.0, 360.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
          ],
          if (imageUrl != null) _buildImage(context, imageUrl, frameHeight),
          if (body != null) ...[
            const SizedBox(height: 12),
            Text(body,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.7)),
          ],
        ],
      ),
    );
  }
}
