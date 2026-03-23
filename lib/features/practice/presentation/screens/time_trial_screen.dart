import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/recent_activity_service.dart';
import '../../../../core/services/signed_in_state_refresh_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/ready_option_tile.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../gamification/providers/gamification_provider.dart';
import '../../../learning/data/models/quiz_model.dart';
import '../../../learning/data/repositories/progress_repository.dart';
import '../widgets/time_trial_actions_bar.dart';
import '../widgets/trial_stat_chip.dart';

class TimeTrialScreen extends StatefulWidget {
  final List<QuizModel> questions;

  const TimeTrialScreen({super.key, required this.questions});

  @override
  State<TimeTrialScreen> createState() => _TimeTrialScreenState();
}

class _TimeTrialScreenState extends State<TimeTrialScreen> {
  static const int _durationSeconds = 30;
  static const int _maxPoints = 100;

  final RecentActivityService _activityService = RecentActivityService();
  final ProgressRepository _progressRepository = ProgressRepository();
  final SignedInStateRefreshService _refreshService =
      SignedInStateRefreshService();

  late List<QuizModel> _questionPool;
  Timer? _timer;
  int _secondsLeft = _durationSeconds;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _answeredCount = 0;
  int _pointsEarned = 0;
  bool _isFinished = false;
  bool _isSavingResult = false;

  @override
  void initState() {
    super.initState();
    _questionPool = List<QuizModel>.empty();
    _resetSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  QuizModel get _currentQuestion =>
      _questionPool[_currentIndex % _questionPool.length];

  void _resetSession() {
    _timer?.cancel();
    _questionPool = List<QuizModel>.from(widget.questions)..shuffle();
    _secondsLeft = _durationSeconds;
    _currentIndex = 0;
    _correctCount = 0;
    _answeredCount = 0;
    _pointsEarned = 0;
    _isFinished = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isFinished) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _finish();
        return;
      }
      setState(() => _secondsLeft--);
    });

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _finish() async {
    if (_isFinished) return;
    _timer?.cancel();
    final pointsEarned = (_correctCount * 10).clamp(0, _maxPoints);
    setState(() {
      _isFinished = true;
      _isSavingResult = true;
      _pointsEarned = pointsEarned;
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

    final percent = _answeredCount == 0
        ? 0
        : ((_correctCount / _answeredCount) * 100).round();
    await _progressRepository.recordDailyQuizAttempt(
      userId,
      scorePercent: percent,
    );
    if (pointsEarned > 0) {
      await _progressRepository.awardBonusPoints(userId, pointsEarned);
    }
    await _activityService.logTimeTrialCompletion(
      userId: userId,
      correctAnswers: _correctCount,
      totalQuestions: _answeredCount,
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

  void _selectAnswer(int selectedIndex) {
    if (_isFinished) return;

    final question = _currentQuestion;
    final isCorrect = selectedIndex == question.correctAnswerIndex;

    setState(() {
      if (isCorrect) {
        _correctCount++;
      }
      _answeredCount++;
      _currentIndex++;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppSemanticColors.of(context);

    return PopScope(
      canPop: !_isSavingResult,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !_isSavingResult,
          title: const Text('Time Trial Challenge'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tokens.warning.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: tokens.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(_secondsLeft),
                        style: TextStyle(
                          color: tokens.warning,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _isFinished
            ? TimeTrialActionsBar(
                isEnabled: !_isSavingResult,
                onRetry: _resetSession,
                onDone: () => Navigator.of(context).pop(),
              )
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: FilledButton(
                    onPressed: _finish,
                    child: const Text('Finish Run'),
                  ),
                ),
              ),
        body: _isFinished ? _buildResults(context) : _buildQuestion(context),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final question = _currentQuestion;
    final tokens = AppSemanticColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TrialStatChip(
                  icon: Icons.check_circle_outline,
                  label: 'Correct',
                  value: '$_correctCount',
                  color: tokens.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TrialStatChip(
                  icon: Icons.playlist_add_check_circle_outlined,
                  label: 'Answered',
                  value: '$_answeredCount',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Tap an answer to move straight to the next question.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.subtleText,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 24),
          ...List.generate(question.options.length, (index) {
            return ReadyOptionTile(
              optionLetter: String.fromCharCode(65 + index),
              label: question.options[index],
              isSelected: false,
              onTap: () => _selectAnswer(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final tokens = AppSemanticColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFF0E6),
              border: Border.all(color: const Color(0xFFFF6A00), width: 4),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_correctCount/$_answeredCount',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF6A00),
                    ),
                  ),
                  Text(
                    'score',
                    style: TextStyle(
                      color: tokens.subtleText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Time is up',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You scored $_correctCount/$_answeredCount and earned $_pointsEarned practice points.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.subtleText,
                ),
          ),
          if (_isSavingResult) ...[
            const SizedBox(height: 16),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            const SizedBox(height: 8),
            Text(
              'Saving practice result...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.subtleText,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
