import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../data/models/quiz_model.dart';
import '../data/repositories/lesson_repository.dart';
import '../data/repositories/progress_repository.dart';

/// Manages quiz state: loading questions, tracking answers, submitting results.
class QuizProvider extends ChangeNotifier {
  final LessonRepository _lessonRepo = LessonRepository();
  final ProgressRepository _progressRepo = ProgressRepository();

  // Current quiz session state
  List<QuizModel> _questions = [];
  List<int?> _selectedAnswers = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isSubmitted = false;
  String? _error;

  // Set when a quiz session starts
  String? _currentLessonId;
  String? _currentLessonTitle;
  int _lessonPoints = 0;
  String? _currentUserId;

  // Results (populated after submission)
  int _pointsEarned = 0;
  int _correctCount = 0;

  // ─── Getters ───────────────────────────────────────────────────────────────

  List<QuizModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  bool get isLoading => _isLoading;
  bool get isSubmitted => _isSubmitted;
  String? get error => _error;
  String? get currentLessonId => _currentLessonId;
  String? get currentLessonTitle => _currentLessonTitle;
  int get pointsEarned => _pointsEarned;
  int get correctCount => _correctCount;
  int get lessonPoints => _lessonPoints;

  QuizModel? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : null;

  int? selectedAnswerForCurrent() =>
      _currentIndex < _selectedAnswers.length
          ? _selectedAnswers[_currentIndex]
          : null;

  /// Returns the answer selected for a given question [index], or null if
  /// the question was not answered. Used by QuizResultScreen for breakdown.
  int? answerAt(int index) =>
      index < _selectedAnswers.length ? _selectedAnswers[index] : null;

  bool get hasAnsweredCurrent =>
      _currentIndex < _selectedAnswers.length &&
      _selectedAnswers[_currentIndex] != null;

  bool get isLastQuestion => _currentIndex == _questions.length - 1;

  bool get hasPassed =>
      _questions.isNotEmpty && scorePercent >= AppConstants.defaultPassingScore;

  int get scorePercent => _questions.isEmpty
      ? 0
      : ((_correctCount / _questions.length) * 100).round();

  // ─── Actions ───────────────────────────────────────────────────────────────

  /// Initialise a new quiz session for [lessonId].
  /// Loads cached questions first; fetches from Supabase if cache is empty.
  Future<void> startQuiz({
    required String lessonId,
    required String lessonTitle,
    required int lessonPoints,
    required String userId,
  }) async {
    _currentLessonId = lessonId;
    _currentLessonTitle = lessonTitle;
    _lessonPoints = lessonPoints;
    _currentUserId = userId;
    _currentIndex = 0;
    _selectedAnswers = [];
    _isSubmitted = false;
    _pointsEarned = 0;
    _correctCount = 0;
    _error = null;

    _isLoading = true;
    notifyListeners();

    try {
      // Try cache first
      var quizzes = _lessonRepo.getCachedQuizzesForLesson(lessonId);

      // Fetch from Supabase if cache miss
      if (quizzes.isEmpty) {
        quizzes = await _lessonRepo.syncQuizzesForLesson(lessonId);
      }

      _questions = quizzes;
      _selectedAnswers = List<int?>.filled(quizzes.length, null);
    } catch (e) {
      _error = 'Failed to load quiz questions: $e';
      _questions = [];
      AppLogger.warning('Quiz load failed', scope: 'quiz', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Records the user's answer for the current question.
  void selectAnswer(int optionIndex) {
    if (_isSubmitted) return;
    _selectedAnswers[_currentIndex] = optionIndex;
    notifyListeners();
  }

  /// Moves to the next question. Call only when [hasAnsweredCurrent] is true.
  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// Scores the quiz, saves progress, and marks as submitted.
  Future<void> submitQuiz() async {
    if (_isSubmitted || _currentUserId == null || _currentLessonId == null) {
      return;
    }

    // Calculate score
    _correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctAnswerIndex) {
        _correctCount++;
      }
    }

    _isSubmitted = true;
    notifyListeners();

    // Save progress and earn points
    try {
      _pointsEarned = await _progressRepo.completeLesson(
        userId: _currentUserId!,
        lessonId: _currentLessonId!,
        score: scorePercent,
        availablePoints: _lessonPoints,
      );
      notifyListeners();
    } catch (e) {
      AppLogger.warning('Progress save failed', scope: 'quiz', error: e);
    }
  }

  /// Resets provider so the quiz can be retaken.
  void resetQuiz() {
    _currentIndex = 0;
    _selectedAnswers = List<int?>.filled(_questions.length, null);
    _isSubmitted = false;
    _pointsEarned = 0;
    _correctCount = 0;
    notifyListeners();
  }
}
