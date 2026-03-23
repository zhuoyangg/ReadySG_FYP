import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/recent_activity_service.dart';
import '../../../../core/services/signed_in_state_refresh_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../gamification/providers/gamification_provider.dart';
import '../../../gamification/providers/spaced_practice_provider.dart';
import '../../providers/courses_provider.dart';
import '../../providers/lessons_provider.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/question_result_card.dart';
import '../widgets/quiz_result_actions_bar.dart';

/// Shows the quiz score, points earned, and per-question feedback.
class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  final RecentActivityService _activityService = RecentActivityService();
  final SignedInStateRefreshService _refreshService =
      SignedInStateRefreshService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = context.read<AuthProvider>().currentUser?.id;
      final lessonId = context.read<QuizProvider>().currentLessonId;
      final quiz = context.read<QuizProvider>();
      if (userId != null) {
        context.read<LessonsProvider>().refreshProgress(userId);
        context.read<CoursesProvider>().refreshProgress(userId);
        if (lessonId != null) {
          final reviewRecorded = await context
              .read<SpacedPracticeProvider>()
              .markReviewedIfDue(userId, lessonId);
          if (reviewRecorded) {
            await _activityService.logModuleReviewCompletion(
              userId: userId,
              lessonId: lessonId,
              score: quiz.scorePercent,
              correctAnswers: quiz.correctCount,
              totalQuestions: quiz.totalQuestions,
              passed: quiz.hasPassed,
            );
          } else {
            await _activityService.logModuleCompletion(
              userId: userId,
              lessonId: lessonId,
              score: quiz.scorePercent,
              correctAnswers: quiz.correctCount,
              totalQuestions: quiz.totalQuestions,
              passed: quiz.hasPassed,
            );
          }
        }
        if (!mounted) return;
        await _refreshService.refresh(
          userId: userId,
          authProvider: context.read<AuthProvider>(),
          gamificationProvider: context.read<GamificationProvider>(),
          spacedPracticeProvider: context.read<SpacedPracticeProvider>(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final hasResultData = quiz.totalQuestions > 0;
    final hasPassed = quiz.hasPassed;
    final tokens = AppSemanticColors.of(context);
    final hasLessonPoints = quiz.pointsEarned > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: QuizResultActionsBar(
        hasPassed: hasPassed,
        onDone: () {
          final lessonId = quiz.currentLessonId;
          context.read<QuizProvider>().resetQuiz();

          if (lessonId == null) {
            context.go(AppRouter.home);
            return;
          }

          final lesson = context.read<CoursesProvider>().findLesson(lessonId);
          final courseId = lesson?.courseId;
          if (courseId != null) {
            context.pushReplacement(AppRouter.coursePath(courseId));
            return;
          }

          context.go(AppRouter.home);
        },
        onBackToLesson: () {
          final lessonId = quiz.currentLessonId;
          if (lessonId == null) {
            context.go(AppRouter.home);
            return;
          }
          context.pushReplacement(AppRouter.lessonPath(lessonId));
        },
        onRetryQuiz: () {
          final lessonId = quiz.currentLessonId;
          if (lessonId == null) return;
          context.read<QuizProvider>().resetQuiz();
          context.replace(AppRouter.quizPath(lessonId));
        },
      ),
      body: hasResultData
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasPassed
                                ? tokens.success.withValues(alpha: 0.08)
                                : tokens.warning.withValues(alpha: 0.08),
                            border: Border.all(
                              color: hasPassed ? tokens.success : tokens.warning,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${quiz.scorePercent}%',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: hasPassed
                                        ? tokens.success
                                        : tokens.warning,
                                  ),
                                ),
                                Text(
                                  '${quiz.correctCount}/${quiz.totalQuestions}',
                                  style: TextStyle(
                                    color: tokens.subtleText,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          hasPassed ? 'Great work!' : 'Keep practising!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasPassed
                              ? 'You answered ${quiz.correctCount} out of ${quiz.totalQuestions} correctly.'
                              : 'Review the explanations and try again.',
                          style: TextStyle(
                            color: tokens.subtleText,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: hasLessonPoints
                                ? tokens.points.withValues(alpha: 0.12)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            hasLessonPoints
                                ? '+${quiz.pointsEarned} lesson points'
                                : 'No additional lesson points on retry',
                            style: TextStyle(
                              color: hasLessonPoints
                                  ? tokens.points
                                  : const Color(0xFF6B7280),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!hasPassed) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Score ${AppConstants.defaultPassingScore}% or more to pass',
                            style: TextStyle(
                              fontSize: 12,
                              color: tokens.danger,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question Breakdown',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(quiz.questions.length, (index) {
                          final question = quiz.questions[index];
                          final selectedForIndex = _selectedAnswer(quiz, index);
                          final isCorrect =
                              selectedForIndex == question.correctAnswerIndex;
                          return QuestionResultCard(
                            index: index,
                            question: question.question,
                            selectedAnswer: selectedForIndex != null
                                ? question.options[selectedForIndex]
                                : 'Not answered',
                            correctAnswer:
                                question.options[question.correctAnswerIndex],
                            explanation: question.explanation,
                            isCorrect: isCorrect,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : _EmptyQuizResultState(
              onRetryQuiz: () {
                final lessonId = quiz.currentLessonId;
                if (lessonId == null) return;
                context.read<QuizProvider>().resetQuiz();
                context.replace(AppRouter.quizPath(lessonId));
              },
            ),
    );
  }

  int? _selectedAnswer(QuizProvider quiz, int questionIndex) {
    if (questionIndex < quiz.questions.length) {
      return quiz.answerAt(questionIndex);
    }
    return null;
  }
}

class _EmptyQuizResultState extends StatelessWidget {
  final VoidCallback onRetryQuiz;

  const _EmptyQuizResultState({required this.onRetryQuiz});

  @override
  Widget build(BuildContext context) {
    final subtleText = AppSemanticColors.of(context).subtleText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 52,
              color: subtleText,
            ),
            const SizedBox(height: 16),
            Text(
              'Quiz results are unavailable right now.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The quiz state was cleared before the results page finished loading. Retry the quiz from the lesson to regenerate the results.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: subtleText,
                    height: 1.45,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetryQuiz,
              icon: const Icon(Icons.replay),
              label: const Text('Retry Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
