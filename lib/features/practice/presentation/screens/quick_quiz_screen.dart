import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/recent_activity_service.dart';
import '../../../../core/services/signed_in_state_refresh_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/ready_option_tile.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../gamification/providers/gamification_provider.dart';
import '../../../learning/data/models/quiz_model.dart';
import '../../../learning/data/repositories/progress_repository.dart';
import '../widgets/quick_quiz_question_result.dart';
import '../widgets/quick_quiz_result_actions_bar.dart';

/// Standalone 5-question mixed drill. Not connected to progress tracking —
/// purely for practice. Manages its own state locally.
class QuickQuizScreen extends StatefulWidget {
  final List<QuizModel> questions;

  const QuickQuizScreen({super.key, required this.questions});

  @override
  State<QuickQuizScreen> createState() => _QuickQuizScreenState();
}

class _QuickQuizScreenState extends State<QuickQuizScreen> {
  final RecentActivityService _activityService = RecentActivityService();
  final ProgressRepository _progressRepository = ProgressRepository();
  final SignedInStateRefreshService _refreshService =
      SignedInStateRefreshService();
  int _currentIndex = 0;
  late List<int?> _selectedAnswers;
  bool _isSubmitted = false;
  bool _isSavingResult = false;
  int _pointsEarned = 0;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List<int?>.filled(widget.questions.length, null);
  }

  void _selectAnswer(int index) {
    if (_isSubmitted) return;
    setState(() => _selectedAnswers[_currentIndex] = index);
  }

  void _next() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitted = true;
      _isSavingResult = true;
    });
    final authProvider = context.read<AuthProvider>();
    final gamificationProvider = context.read<GamificationProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        setState(() => _isSavingResult = false);
      }
      return;
    }
    final percent = ((_correctCount / widget.questions.length) * 100).round();
    final pointsEarned = (_correctCount * 5).clamp(0, 50);
    _pointsEarned = pointsEarned;
    await _progressRepository.recordDailyQuizAttempt(
      userId,
      scorePercent: percent,
    );
    if (pointsEarned > 0) {
      await _progressRepository.awardBonusPoints(userId, pointsEarned);
    }
    await _activityService.logQuickQuizCompletion(
      userId: userId,
      score: percent,
      correctAnswers: _correctCount,
      totalQuestions: widget.questions.length,
      passed: percent >= AppConstants.defaultPassingScore,
      pointsEarned: pointsEarned,
    );
    await _refreshService.refresh(
      userId: userId,
      authProvider: authProvider,
      gamificationProvider: gamificationProvider,
    );
    if (!mounted) return;
    setState(() => _isSavingResult = false);
  }

  void _retry() {
    setState(() {
      _currentIndex = 0;
      _selectedAnswers = List<int?>.filled(widget.questions.length, null);
      _isSubmitted = false;
      _pointsEarned = 0;
    });
  }

  int get _correctCount {
    int count = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (_selectedAnswers[i] == widget.questions[i].correctAnswerIndex) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSavingResult,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !_isSavingResult,
          title: const Text('Quick Quiz'),
          centerTitle: true,
        ),
        bottomNavigationBar: _isSubmitted
            ? QuickQuizResultActionsBar(
                isEnabled: !_isSavingResult,
                onRetry: _retry,
                onDone: () => Navigator.of(context).pop(),
              )
            : null,
        body: _isSubmitted ? _buildResults() : _buildQuestion(),
      ),
    );
  }

  // ─── Question view ──────────────────────────────────────────────────────────

  Widget _buildQuestion() {
    final question = widget.questions[_currentIndex];
    final selected = _selectedAnswers[_currentIndex];
    final isLastQuestion = _currentIndex == widget.questions.length - 1;
    final hasAnswered = selected != null;

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: (_currentIndex + 1) / widget.questions.length,
          minHeight: 4,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${widget.questions.length}',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppSemanticColors.of(context).subtleText),
                ),
                const SizedBox(height: 12),
                Text(
                  question.question,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                ...List.generate(question.options.length, (i) {
                  return ReadyOptionTile(
                    optionLetter: String.fromCharCode(65 + i), // A, B, C, D
                    label: question.options[i],
                    isSelected: selected == i,
                    onTap: () => _selectAnswer(i),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: hasAnswered
                        ? (isLastQuestion ? _submit : _next)
                        : null,
                    child: Text(isLastQuestion ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Results view ───────────────────────────────────────────────────────────

  Widget _buildResults() {
    final correct = _correctCount;
    final total = widget.questions.length;
    final percent = ((correct / total) * 100).round();
    final passed = percent >= AppConstants.defaultPassingScore;
    final tokens = AppSemanticColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Score circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: passed
                  ? tokens.success.withValues(alpha: 0.1)
                  : tokens.warning.withValues(alpha: 0.1),
              border: Border.all(
                color: passed ? tokens.success : tokens.warning,
                width: 3,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$percent%',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: passed ? tokens.success : tokens.warning)),
                  Text('$correct/$total',
                      style: TextStyle(color: tokens.subtleText, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            passed ? 'Great work!' : 'Keep practising!',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            passed
                ? 'You answered $correct out of $total correctly.'
                : 'Review the explanations and try again.',
            style: TextStyle(color: tokens.subtleText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: tokens.points.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '+$_pointsEarned practice points',
              style: TextStyle(
                color: tokens.points,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_isSavingResult) ...[
            const SizedBox(height: 12),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            const SizedBox(height: 8),
            Text(
              'Saving practice result...',
              style: TextStyle(color: tokens.subtleText, fontSize: 12),
            ),
          ],
          if (!passed) ...[
            const SizedBox(height: 8),
            Text(
              'Score ${AppConstants.defaultPassingScore}% or more to pass',
              style: TextStyle(fontSize: 12, color: tokens.danger),
            ),
          ],
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Question Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(widget.questions.length, (i) {
            final q = widget.questions[i];
            final userAnswer = _selectedAnswers[i];
            final isCorrect = userAnswer == q.correctAnswerIndex;
            return QuickQuizQuestionResult(
              index: i,
              question: q.question,
              selectedAnswer: userAnswer != null
                  ? q.options[userAnswer]
                  : 'Not answered',
              correctAnswer: q.options[q.correctAnswerIndex],
              explanation: q.explanation,
              isCorrect: isCorrect,
            );
          }),
        ],
      ),
    );
  }
}
