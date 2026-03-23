import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/lessons_provider.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/quiz_feedback_banner.dart';
import '../widgets/quiz_header.dart';
import '../widgets/quiz_option_tile.dart';

/// Interactive multiple-choice quiz screen with inline per-question feedback.
/// Shows correct/incorrect feedback immediately after each submission,
/// then advances on "Next Question" or submits on "Complete Lesson".
class QuizScreen extends StatefulWidget {
  final String lessonId;
  const QuizScreen({super.key, required this.lessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  /// Whether the current question has been submitted (feedback visible).
  bool _hasSubmittedCurrent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startQuiz());
  }

  void _startQuiz() {
    final auth = context.read<AuthProvider>();
    final lessons = context.read<LessonsProvider>();
    final quiz = context.read<QuizProvider>();
    final userId = auth.currentUser?.id;
    if (userId == null) return;
    final lesson = lessons.lessons.where((l) => l.id == widget.lessonId).firstOrNull;
    quiz.startQuiz(
      lessonId: widget.lessonId,
      lessonTitle: lesson?.title ?? 'Quiz',
      lessonPoints: lesson?.points ?? 10,
      userId: userId,
    );
  }

  void _submitAnswer() => setState(() => _hasSubmittedCurrent = true);

  void _nextQuestion() {
    context.read<QuizProvider>().nextQuestion();
    setState(() => _hasSubmittedCurrent = false);
  }

  Future<void> _completeLesson() async {
    await context.read<QuizProvider>().submitQuiz();
    if (mounted) context.replace(AppRouter.quizResult);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quiz, _) {
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: Column(
            children: [
              // ── Gradient header ────────────────────────────────────────
              QuizHeader(
                lessonTitle: quiz.currentLessonTitle ?? 'Quiz',
                currentIndex: quiz.currentIndex,
                total: quiz.totalQuestions,
                colorScheme: colorScheme,
                onBack: () => context.pop(),
              ),

              // ── Body ──────────────────────────────────────────────────
              Expanded(child: _buildBody(context, quiz)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, QuizProvider quiz) {
    if (quiz.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quiz.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: AppSemanticColors.of(context).danger),
              const SizedBox(height: 16),
              Text(quiz.error!,
                  style: TextStyle(color: AppSemanticColors.of(context).danger),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _startQuiz, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (quiz.questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No quiz questions available for this lesson yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppSemanticColors.of(context).subtleText),
          ),
        ),
      );
    }

    final question = quiz.currentQuestion!;
    final selectedIndex = quiz.selectedAnswerForCurrent();
    final isLast = quiz.isLastQuestion;
    final hasSelected = quiz.hasAnsweredCurrent;
    final isCorrect =
        _hasSubmittedCurrent && selectedIndex == question.correctAnswerIndex;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Question card ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              question.question,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Answer options ─────────────────────────────────────────────
          ...List.generate(question.options.length, (index) {
            return QuizOptionTile(
              label: question.options[index],
              index: index,
              selectedIndex: selectedIndex,
              correctIndex: question.correctAnswerIndex,
              hasSubmitted: _hasSubmittedCurrent,
              onTap: _hasSubmittedCurrent
                  ? null
                  : () => context.read<QuizProvider>().selectAnswer(index),
            );
          }),

          const SizedBox(height: 16),

          // ── Inline feedback banner ─────────────────────────────────────
          if (_hasSubmittedCurrent)
            QuizFeedbackBanner(
              isCorrect: isCorrect,
              explanation: question.explanation,
            ),

          const SizedBox(height: 16),

          // ── Action button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: _hasSubmittedCurrent
                ? FilledButton(
                    onPressed: isLast ? _completeLesson : _nextQuestion,
                    style: FilledButton.styleFrom(
                      backgroundColor: isLast
                          ? AppSemanticColors.of(context).success
                          : Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      isLast ? 'Complete Lesson' : 'Next Question',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  )
                : FilledButton(
                    onPressed: hasSelected ? _submitAnswer : null,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Submit Answer',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
