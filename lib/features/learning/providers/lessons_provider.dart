import 'package:flutter/material.dart';
import '../data/models/lesson_model.dart';
import '../data/models/user_progress_model.dart';
import '../data/repositories/lesson_repository.dart';
import '../data/repositories/progress_repository.dart';

/// Lightweight provider used by the quiz flow.
///
/// CoursesProvider handles course/lesson loading and caches lessons to Hive.
/// This provider reads from that Hive cache so QuizScreen and QuizResultScreen
/// can look up lesson metadata and progress without depending on CoursesProvider.
class LessonsProvider extends ChangeNotifier {
  final LessonRepository _lessonRepo = LessonRepository();
  final ProgressRepository _progressRepo = ProgressRepository();

  Map<String, UserProgressModel> _progress = {};

  // ─── Getters ───────────────────────────────────────────────────────────────

  /// All lessons cached in Hive (populated by CoursesProvider on sync).
  List<LessonModel> get lessons => _lessonRepo.getAllCachedLessons();

  UserProgressModel? progressFor(String lessonId) => _progress[lessonId];

  bool isCompleted(String lessonId) =>
      _progress[lessonId]?.completed == true;

  // ─── Actions ───────────────────────────────────────────────────────────────

  /// Called by QuizResultScreen after a lesson is completed.
  void refreshProgress(String userId) {
    _progress = _progressRepo.getAllLocalProgress(userId);
    notifyListeners();
  }
}
