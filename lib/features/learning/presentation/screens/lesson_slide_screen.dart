import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/lesson_model.dart';
import '../../data/repositories/lesson_repository.dart';
import '../widgets/lesson_header.dart';
import '../widgets/lesson_image_slide.dart';
import '../widgets/lesson_nav_bar.dart';
import '../widgets/lesson_quiz_prompt_slide.dart';
import '../widgets/lesson_text_slide.dart';
import '../widgets/lesson_tip_slide.dart';
import '../widgets/video_slide.dart';

/// Paginated slide viewer for a single lesson.
/// Slide types: 'text', 'image', 'video', 'tip'.
/// A quiz-prompt slide is automatically appended if quiz questions exist.
class LessonSlideScreen extends StatefulWidget {
  final String lessonId;
  const LessonSlideScreen({super.key, required this.lessonId});

  @override
  State<LessonSlideScreen> createState() => _LessonSlideScreenState();
}

class _LessonSlideScreenState extends State<LessonSlideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<Map<String, dynamic>> _slides;
  LessonModel? _lesson;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  void _loadLesson() {
    final repo = LessonRepository();
    _lesson = repo.getCachedLesson(widget.lessonId);
    if (_lesson == null) return;

    _slides = _lesson!.slides;

    final cached = repo.getCachedQuizzesForLesson(widget.lessonId);
    if (cached.isNotEmpty) {
      _slides = [..._slides, {'type': 'quiz_prompt'}];
    } else {
      _fetchQuizzesInBackground(repo);
    }
  }

  Future<void> _fetchQuizzesInBackground(LessonRepository repo) async {
    try {
      final quizzes = await repo.syncQuizzesForLesson(widget.lessonId);
      if (quizzes.isNotEmpty && mounted) {
        setState(() {
          _slides = [..._lesson!.slides, {'type': 'quiz_prompt'}];
        });
      }
    } catch (e) {
      AppLogger.warning(
        'Background quiz fetch failed for lesson ${widget.lessonId}',
        scope: 'learning',
        error: e,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Lesson not found. Please go back and try again.'),
        ),
      );
    }

    final total = _slides.length;
    final colorScheme = Theme.of(context).colorScheme;
    // Exclude quiz_prompt from slide count shown to user
    final displayTotal =
        _slides.where((s) => s['type'] != 'quiz_prompt').length;
    final isQuizSlide = _slides[_currentPage]['type'] == 'quiz_prompt';

    return Scaffold(
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────────
          LessonHeader(
            lesson: _lesson!,
            currentSlide: isQuizSlide ? displayTotal : _currentPage + 1,
            totalSlides: displayTotal,
            colorScheme: colorScheme,
            onBack: () => context.pop(),
          ),

          // ── Slide content card ───────────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: total,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                final slideNumber = _slides
                        .take(index + 1)
                        .where((s) => s['type'] != 'quiz_prompt')
                        .length;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SlideCard(
                    slide: _slides[index],
                    slideNumber: slideNumber,
                    displayTotal: displayTotal,
                    lessonId: widget.lessonId,
                    lessonTitle: _lesson!.title,
                    lessonPoints: _lesson!.points,
                  ),
                );
              },
            ),
          ),

          // ── Navigation buttons ───────────────────────────────────────────
          if (!isQuizSlide)
            LessonNavBar(
              current: _currentPage,
              total: total,
              onPrev: _currentPage > 0 ? () => _goTo(_currentPage - 1) : null,
              onNext: _currentPage < total - 1
                  ? () => _goTo(_currentPage + 1)
                  : null,
              isLastContentSlide: total >= 2 &&
                  _currentPage == total - 2 &&
                  _slides.last['type'] == 'quiz_prompt',
            ),
        ],
      ),
    );
  }
}

// ─── Slide card wrapper ────────────────────────────────────────────────────────

class _SlideCard extends StatelessWidget {
  final Map<String, dynamic> slide;
  final int slideNumber;
  final int displayTotal;
  final String lessonId;
  final String lessonTitle;
  final int lessonPoints;

  const _SlideCard({
    required this.slide,
    required this.slideNumber,
    required this.displayTotal,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonPoints,
  });

  @override
  Widget build(BuildContext context) {
    final isQuizPrompt = slide['type'] == 'quiz_prompt';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: _SlideContent(
              slide: slide,
              lessonId: lessonId,
              lessonTitle: lessonTitle,
              lessonPoints: lessonPoints,
            ),
          ),
          // Slide number indicator at bottom of card (only for content slides)
          if (!isQuizPrompt)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Slide $slideNumber of $displayTotal',
                style: TextStyle(
                  fontSize: 13,
                  color: AppSemanticColors.of(context).subtleText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Slide content dispatcher ─────────────────────────────────────────────────

class _SlideContent extends StatelessWidget {
  final Map<String, dynamic> slide;
  final String lessonId;
  final String lessonTitle;
  final int lessonPoints;

  const _SlideContent({
    required this.slide,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonPoints,
  });

  @override
  Widget build(BuildContext context) {
    final slideType = slide['type'] as String?;
    switch (slideType) {
      case 'image':
        return LessonImageSlide(slide: slide);
      case 'video':
        return VideoSlide(slide: slide);
      case 'tip':
        return LessonTipSlide(slide: slide);
      case 'quiz_prompt':
        return LessonQuizPromptSlide(
          lessonId: lessonId,
          lessonTitle: lessonTitle,
          lessonPoints: lessonPoints,
        );
      case null:
        AppLogger.warning('Slide missing type field', scope: 'learning');
        return LessonTextSlide(slide: slide);
      default:
        return LessonTextSlide(slide: slide);
    }
  }
}
