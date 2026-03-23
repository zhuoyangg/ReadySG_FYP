import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/app_logger.dart';

/// Embeds a YouTube player with timeout/error fallback to an external link.
///
/// Expects a slide map containing:
///   - `title`  (String?) — heading above the player
///   - `youtube_id` (String?) — YouTube video ID
///   - `start_seconds` (num?) — optional start offset
class VideoSlide extends StatefulWidget {
  final Map<String, dynamic> slide;
  const VideoSlide({super.key, required this.slide});

  @override
  State<VideoSlide> createState() => _VideoSlideState();
}

class _VideoSlideState extends State<VideoSlide> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _playerSubscription;
  Timer? _loadTimeout;
  bool _hasWebResourceError = false;
  bool _didTimeOut = false;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    final youtubeId = widget.slide['youtube_id'] as String?;
    final startSeconds = (widget.slide['start_seconds'] as num?)?.toDouble();
    if (youtubeId != null) {
      _controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          strictRelatedVideos: true,
        ),
        onWebResourceError: (error) {
          AppLogger.warning(
            'YouTube WebView failed for video $youtubeId',
            scope: 'learning',
            error: error,
          );
          if (mounted) {
            setState(() => _hasWebResourceError = true);
          }
        },
      )..cueVideoById(videoId: youtubeId, startSeconds: startSeconds);

      _playerSubscription = _controller!.stream.listen((value) {
        final isReady = value.playerState != PlayerState.unknown;
        if (isReady && !_isPlayerReady && mounted) {
          _loadTimeout?.cancel();
          setState(() {
            _isPlayerReady = true;
            _didTimeOut = false;
          });
        }

        if (value.hasError && mounted) {
          _loadTimeout?.cancel();
          setState(() {
            _hasWebResourceError = true;
          });
        }
      });

      _loadTimeout = Timer(AppConstants.youtubeLoadTimeout, () {
        if (!mounted || _isPlayerReady || _hasWebResourceError) return;
        AppLogger.warning(
          'YouTube player timed out for video $youtubeId',
          scope: 'learning',
        );
        setState(() => _didTimeOut = true);
      });
    }
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    _playerSubscription?.cancel();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.slide['title'] as String? ?? 'Watch Video';
    final youtubeId = widget.slide['youtube_id'] as String?;
    final startSeconds = (widget.slide['start_seconds'] as num?)?.toInt();
    final theme = Theme.of(context);
    final subtleText = AppSemanticColors.of(context).subtleText;
    final showFallback = _hasWebResourceError || _didTimeOut;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_controller != null && youtubeId != null)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: YoutubePlayerScaffold(
                      controller: _controller!,
                      aspectRatio: 16 / 9,
                      enableFullScreenOnVerticalDrag: false,
                      builder: (context, player) => ColoredBox(
                        color: Colors.black,
                        child: player,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: _buildStatusFooter(
                      context,
                      youtubeId: youtubeId,
                      startSeconds: startSeconds,
                      showFallback: showFallback,
                      theme: theme,
                      subtleText: subtleText,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'Video coming soon',
              style: TextStyle(color: subtleText),
            ),
        ],
      ),
    );
  }

  /// Renders the status area below the player: error fallback, loading, or
  /// the default "open on YouTube" link.
  Widget _buildStatusFooter(
    BuildContext context, {
    required String youtubeId,
    required int? startSeconds,
    required bool showFallback,
    required ThemeData theme,
    required Color subtleText,
  }) {
    return YoutubeValueBuilder(
      controller: _controller!,
      builder: (context, value) {
        final String message;
        if (showFallback || value.hasError) {
          message =
              'The embedded video could not be played due to permission issues.';
        } else if (!_isPlayerReady) {
          message = 'Loading video...';
        } else {
          message = 'Tap play to watch without leaving the lesson.';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isPlayerReady && !(showFallback || value.hasError))
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style:
                          theme.textTheme.bodyMedium?.copyWith(color: subtleText),
                    ),
                  ),
                ],
              )
            else
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: subtleText),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _openInYoutube(youtubeId, startSeconds),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open on YouTube'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openInYoutube(String youtubeId, int? startSeconds) async {
    final appUri = Uri.parse('vnd.youtube:$youtubeId');
    final watchUri = Uri.parse(
      'https://www.youtube.com/watch?v=$youtubeId'
      '${startSeconds != null ? '&t=${startSeconds}s' : ''}',
    );

    try {
      if (await launchUrl(appUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // Fall through to the web URL if the YouTube app is unavailable.
    }

    try {
      if (await launchUrl(watchUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // Fall through to the default browser mode.
    }

    await launchUrl(watchUri, mode: LaunchMode.platformDefault);
  }
}
