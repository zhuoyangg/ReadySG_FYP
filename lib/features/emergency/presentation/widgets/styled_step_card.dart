import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_tokens.dart';

class StyledStepCard extends StatelessWidget {
  final Map<String, dynamic> slide;
  final int stepNumber;
  final bool showCriticalTag;

  const StyledStepCard({
    super.key,
    required this.slide,
    required this.stepNumber,
    required this.showCriticalTag,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final title = (slide['title'] as String? ?? '').trim().isNotEmpty
        ? (slide['title'] as String).trim()
        : 'Step $stepNumber';
    final type = slide['type'] as String? ?? 'text';
    final textParts = _stepTextParts(slide, type);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final contentInset = compact ? 0.0 : scale.space(54);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            scale.space(16),
            scale.space(16),
            scale.space(16),
            scale.space(compact ? 16 : 18),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(scale.radius(16)),
            border: Border.all(color: const Color(0xFFFF7B7B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepNumberBadge(number: stepNumber),
                  SizedBox(width: scale.space(14)),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: scale.space(2)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                          ),
                          if (showCriticalTag) ...[
                            SizedBox(height: scale.space(6)),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: scale.icon(14),
                                  color: Color(0xFFE10600),
                                ),
                                Text(
                                  'CRITICAL STEP',
                                  style: TextStyle(
                                    color: Color(0xFFE10600),
                                    fontSize: scale.font(11),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: scale.space(18)),
              if (textParts.primary.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: contentInset),
                  child: Text(
                    textParts.primary,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          height: 1.45,
                        ),
                  ),
                ),
              if (textParts.secondary.isNotEmpty) ...[
                SizedBox(height: scale.space(8)),
                Padding(
                  padding: EdgeInsets.only(left: contentInset),
                  child: Text(
                    textParts.secondary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF475569),
                          height: 1.5,
                        ),
                  ),
                ),
              ],
              if (type == 'image') ...[
                SizedBox(height: scale.space(12)),
                _GuideImage(slide: slide, leftInset: contentInset),
              ],
              if (type == 'video') ...[
                SizedBox(height: scale.space(14)),
                Padding(
                  padding: EdgeInsets.only(left: contentInset),
                  child: _VideoAction(slide: slide),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  _StepTextParts _stepTextParts(Map<String, dynamic> slide, String type) {
    if (type == 'video') {
      final body = (slide['body'] as String? ?? '').trim();
      if (body.isEmpty) {
        return const _StepTextParts(
          primary: 'Watch the guide demonstration.',
          secondary: '',
        );
      }
      return _splitBody(body);
    }

    final body = (slide['body'] as String? ?? '').trim();
    return _splitBody(body);
  }

  _StepTextParts _splitBody(String body) {
    if (body.isEmpty) {
      return const _StepTextParts(primary: '', secondary: '');
    }

    final newlineParts = body
        .split('\n')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (newlineParts.length > 1) {
      return _StepTextParts(
        primary: newlineParts.first,
        secondary: newlineParts.skip(1).join(' '),
      );
    }

    final sentenceParts = body
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (sentenceParts.length > 1) {
      return _StepTextParts(
        primary: sentenceParts.first,
        secondary: sentenceParts.skip(1).join(' '),
      );
    }

    return _StepTextParts(primary: body, secondary: '');
  }
}

class _StepNumberBadge extends StatelessWidget {
  final int number;

  const _StepNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return Container(
      width: scale.size(38),
      height: scale.size(38),
      decoration: const BoxDecoration(
        color: Color(0xFFFF0000),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          color: Colors.white,
          fontSize: scale.font(20),
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _GuideImage extends StatelessWidget {
  final Map<String, dynamic> slide;
  final double leftInset;

  const _GuideImage({
    required this.slide,
    this.leftInset = 54,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = slide['image_url'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(left: leftInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppScale.of(context).radius(12)),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            height: 140,
            color: const Color(0xFFF3F4F6),
            alignment: Alignment.center,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF94A3B8),
              size: AppScale.of(context).icon(30),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoAction extends StatelessWidget {
  final Map<String, dynamic> slide;

  const _VideoAction({required this.slide});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final youtubeId = slide['youtube_id'] as String?;

    if (youtubeId == null || youtubeId.isEmpty) {
      return Text(
        'Video coming soon',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
            ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () async {
        HapticFeedback.selectionClick();
        final uri = Uri.parse('https://www.youtube.com/watch?v=$youtubeId');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2563EB),
        side: const BorderSide(color: Color(0xFF93C5FD)),
        padding: EdgeInsets.symmetric(
          horizontal: scale.space(14),
          vertical: scale.space(12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(scale.radius(12)),
        ),
      ),
      icon: Icon(Icons.play_circle_outline, size: scale.icon(18)),
      label: Text(
        'Watch Demonstration',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: scale.font(14),
        ),
      ),
    );
  }
}

class _StepTextParts {
  final String primary;
  final String secondary;

  const _StepTextParts({
    required this.primary,
    required this.secondary,
  });
}
