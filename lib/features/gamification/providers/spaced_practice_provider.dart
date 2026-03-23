import 'package:flutter/material.dart';

import '../../../core/config/hive_config.dart';
import '../../../features/learning/data/models/lesson_model.dart';
import '../../../features/learning/data/models/quiz_model.dart';
import '../../../features/learning/data/models/user_progress_model.dart';
import '../data/models/spaced_practice_model.dart';
import '../data/repositories/spaced_practice_repository.dart';

enum PracticeActivityType { completion, review }

class PracticeActivity {
  final String lessonId;
  final DateTime timestamp;
  final PracticeActivityType type;
  final int? score;
  final int? reviewCount;

  const PracticeActivity({
    required this.lessonId,
    required this.timestamp,
    required this.type,
    this.score,
    this.reviewCount,
  });
}

/// Manages the spaced repetition queue, quick quiz questions, and weak topics.
class SpacedPracticeProvider extends ChangeNotifier {
  final SpacedPracticeRepository _repo = SpacedPracticeRepository();
  final HiveConfig _hive = HiveConfig();

  List<SpacedPracticeModel> _schedules = [];

  // ─── Getters ───────────────────────────────────────────────────────────────

  /// Schedules that are due, sorted by most overdue first.
  List<SpacedPracticeModel> get dueSchedules =>
      _schedules.where((s) => s.isDue).toList()
        ..sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));

  int get dueCount => dueSchedules.length;

  // ─── Actions ───────────────────────────────────────────────────────────────

  void load(String userId) {
    _schedules = _repo.getAllSchedules(userId);
    notifyListeners();
  }

  /// Advances a spaced-practice schedule only when it's currently due.
  /// Returns true when a review was recorded.
  Future<bool> markReviewedIfDue(String userId, String lessonId) async {
    final schedule = _repo.getSchedule(userId, lessonId);
    if (schedule == null || !schedule.isDue) return false;
    await _repo.markReviewed(userId, lessonId);
    _schedules = _repo.getAllSchedules(userId);
    notifyListeners();
    return true;
  }

  // ─── Quick quiz ────────────────────────────────────────────────────────────

  /// Returns [count] randomly shuffled questions from the full quiz pool.
  List<QuizModel> getQuickQuizQuestions({int count = 5}) {
    final all = _hive.quizzesBox.values.toList();
    all.shuffle();
    return all.take(count).toList();
  }

  // ─── Weak topics ───────────────────────────────────────────────────────────

  /// Returns completed lessons where bestScore < 70, sorted by score ascending.
  /// Each entry is {'lesson': LessonModel, 'score': int}.
  List<Map<String, dynamic>> getWeakLessons(String userId) {
    final result = <Map<String, dynamic>>[];

    for (final progress in _hive.userProgressBox.values) {
      if (progress.userId != userId) continue;
      if (!progress.completed) continue;
      if (progress.bestScore >= 70) continue;

      final lesson = _findLesson(progress.lessonId);
      if (lesson != null) {
        result.add({'lesson': lesson, 'score': progress.bestScore});
      }
    }

    result.sort((a, b) => (a['score'] as int).compareTo(b['score'] as int));
    return result;
  }

  /// All completed lessons (for recent activity strip on Dashboard).
  /// Returns progress entries sorted by completedAt descending.
  List<UserProgressModel> getRecentActivity(String userId, {int limit = 3}) {
    final completed =
        _hive.userProgressBox.values
            .where(
              (p) => p.userId == userId && p.completed && p.completedAt != null,
            )
            .toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    return completed.take(limit).toList();
  }

  /// Latest activity across both completions and spaced-practice reviews.
  List<PracticeActivity> getRecentTimeline(String userId, {int limit = 8}) {
    final timeline = <PracticeActivity>[];

    for (final progress in _hive.userProgressBox.values) {
      if (progress.userId != userId ||
          !progress.completed ||
          progress.completedAt == null) {
        continue;
      }
      timeline.add(
        PracticeActivity(
          lessonId: progress.lessonId,
          timestamp: progress.completedAt!,
          type: PracticeActivityType.completion,
          score: progress.bestScore,
        ),
      );
    }

    for (final schedule in _hive.spacedPracticeBox.values) {
      if (schedule.userId != userId || schedule.reviewCount <= 0) continue;
      timeline.add(
        PracticeActivity(
          lessonId: schedule.lessonId,
          timestamp: schedule.lastReviewedAt,
          type: PracticeActivityType.review,
          reviewCount: schedule.reviewCount,
        ),
      );
    }

    timeline.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return timeline.take(limit).toList();
  }

  LessonModel? findLesson(String lessonId) => _findLesson(lessonId);

  // ─── Private helpers ───────────────────────────────────────────────────────

  LessonModel? _findLesson(String lessonId) => _hive.lessonsBox.get(lessonId);
}
