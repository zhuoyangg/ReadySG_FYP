import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../aed/presentation/screens/aed_locator_screen.dart';
import '../../data/models/emergency_guide_model.dart';
import '../../data/repositories/emergency_guide_repository.dart';
import '../../providers/emergency_guides_provider.dart';
import '../widgets/aed_support_card.dart';
import '../widgets/call_now_button.dart';
import '../widgets/guide_detail_hero.dart';
import '../widgets/styled_step_card.dart';
import '../widgets/warnings_card.dart';

/// Shows a single emergency guide with fixed step cards and support panels.
class EmergencyGuideDetailScreen extends StatefulWidget {
  final String guideId;

  const EmergencyGuideDetailScreen({super.key, required this.guideId});

  @override
  State<EmergencyGuideDetailScreen> createState() =>
      _EmergencyGuideDetailScreenState();
}

class _EmergencyGuideDetailScreenState extends State<EmergencyGuideDetailScreen> {
  final EmergencyGuideRepository _repository = EmergencyGuideRepository();
  EmergencyGuideModel? _guide;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGuide();
  }

  Future<void> _loadGuide() async {
    try {
      EmergencyGuideModel? guide = _findGuideInProvider();
      guide ??= _repository.getCachedGuide(widget.guideId);

      if (guide == null) {
        final result = await _repository.syncAllGuidesSafe();
        guide = _repository.getCachedGuide(widget.guideId);
        if (guide == null && !result.isSuccess) {
          _errorMessage = result.error?.message;
        }
      }

      if (!mounted) return;
      setState(() {
        _guide = guide;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.warning(
        'Failed to load emergency guide ${widget.guideId}',
        scope: 'emergency_guides',
        error: e,
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Guide could not be loaded right now.';
        _isLoading = false;
      });
    }
  }

  EmergencyGuideModel? _findGuideInProvider() {
    final guides = context.read<EmergencyGuidesProvider>().guides;
    for (final guide in guides) {
      if (guide.id == widget.guideId) {
        return guide;
      }
    }
    return null;
  }

  static Future<void> _callEmergency() async {
    HapticFeedback.heavyImpact();
    final uri = Uri.parse('tel:995');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_guide == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMessage ?? 'Guide not found. Please go back and try again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final guide = _guide!;
    final slides = guide.slides;
    final warnings = _warningItemsForGuide(guide);
    final showAedPanel = _shouldShowAedPanel(guide);
    final scale = AppScale.of(context);
    final horizontalInset = scale.space(12);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(bottom: scale.space(28)),
          children: [
            GuideDetailHero(
              title: guide.title,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            SizedBox(height: scale.space(16)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalInset),
              child: CallNowButton(onTap: _callEmergency),
            ),
            SizedBox(height: scale.space(14)),
            ...List.generate(slides.length, (index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalInset,
                  0,
                  horizontalInset,
                  scale.space(12),
                ),
                child: StyledStepCard(
                  slide: slides[index],
                  stepNumber: index + 1,
                  showCriticalTag: _isCriticalStep(slides[index], index),
                ),
              );
            }),
            if (warnings.isNotEmpty) ...[
              SizedBox(height: scale.space(4)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalInset),
                child: WarningsCard(items: warnings),
              ),
            ],
            if (showAedPanel) ...[
              SizedBox(height: scale.space(12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalInset),
                child: AedSupportCard(
                  onFindAed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AEDLocatorScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _warningItemsForGuide(EmergencyGuideModel guide) {
    final items = <String>[];

    for (final slide in guide.slides) {
      final title = (slide['title'] as String? ?? '').trim();
      final body = (slide['body'] as String? ?? '').trim();
      final combined = '$title $body'.toLowerCase();
      final isWarning = combined.contains('do not') ||
          combined.contains("don't") ||
          combined.contains('not ') ||
          combined.contains('if alone') ||
          combined.contains('remove') ||
          combined.contains('danger');

      if (!isWarning) continue;

      final candidate = body.isNotEmpty ? body : title;
      final normalized = candidate.replaceAll('\n', ' ').trim();
      if (normalized.isNotEmpty && !items.contains(normalized)) {
        items.add(normalized);
      }
      if (items.length == 3) break;
    }

    if (items.isEmpty && guide.description.trim().isNotEmpty) {
      items.add(guide.description.trim());
    }

    return items;
  }

  bool _shouldShowAedPanel(EmergencyGuideModel guide) {
    final text = '${guide.title} ${guide.description} '
            '${guide.slides.map((slide) => slide['title']).join(' ')} '
            '${guide.slides.map((slide) => slide['body']).join(' ')}'
        .toLowerCase();

    return text.contains('aed') ||
        text.contains('cardiac') ||
        text.contains('heart') ||
        text.contains('cpr') ||
        text.contains('shock');
  }

  bool _isCriticalStep(Map<String, dynamic> slide, int index) {
    final title = (slide['title'] as String? ?? '').toLowerCase();
    final body = (slide['body'] as String? ?? '').toLowerCase();
    final text = '$title $body';

    const criticalTerms = [
      '995',
      'unresponsive',
      'not breathing',
      'shock',
      'compress',
      'cpr',
      'severe bleeding',
      'direct pressure',
      'heart attack',
      'stroke',
      'cool for 20',
      'unconscious',
      'call for',
      'call 995',
    ];

    if (criticalTerms.any(text.contains)) {
      return true;
    }

    return index < 2;
  }
}
