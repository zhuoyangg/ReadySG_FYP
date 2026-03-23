import '../../../../core/config/hive_config.dart';
import '../../../../core/services/app_clock.dart';
import '../models/spaced_practice_model.dart';

/// Manages per-lesson spaced repetition schedules stored in Hive.
/// No Supabase sync - review schedules are device-local.
class SpacedPracticeRepository {
  final HiveConfig _hive = HiveConfig();
  // Read

  List<SpacedPracticeModel> getAllSchedules(String userId) {
    return _hive.spacedPracticeBox.values
        .where((s) => s.userId == userId)
        .toList();
  }

  SpacedPracticeModel? getSchedule(String userId, String lessonId) {
    final key = SpacedPracticeModel.hiveKey(userId, lessonId);
    return _hive.spacedPracticeBox.get(key);
  }

  bool hasSchedule(String userId, String lessonId) {
    final key = SpacedPracticeModel.hiveKey(userId, lessonId);
    return _hive.spacedPracticeBox.containsKey(key);
  }
  // Write

  /// Called when a lesson is first completed. Schedules first review in 1 day.
  Future<void> scheduleLesson(
    String userId,
    String lessonId, {
    DateTime? from,
  }) async {
    final now = from ?? AppClock.now();
    final schedule = SpacedPracticeModel(
      userId: userId,
      lessonId: lessonId,
      lastReviewedAt: now,
      nextReviewAt: now.add(const Duration(days: 1)),
      intervalDays: 1,
      reviewCount: 0,
    );
    final key = SpacedPracticeModel.hiveKey(userId, lessonId);
    await _hive.spacedPracticeBox.put(key, schedule);
  }

  /// Advances the interval to the next fixed step and reschedules.
  Future<void> markReviewed(String userId, String lessonId) async {
    final key = SpacedPracticeModel.hiveKey(userId, lessonId);
    final existing = _hive.spacedPracticeBox.get(key);
    if (existing == null) return;

    final nextInterval = SpacedPracticeModel.nextInterval(existing.intervalDays);
    final now = AppClock.now();

    final updated = SpacedPracticeModel(
      userId: userId,
      lessonId: lessonId,
      lastReviewedAt: now,
      nextReviewAt: now.add(Duration(days: nextInterval)),
      intervalDays: nextInterval,
      reviewCount: existing.reviewCount + 1,
    );
    await _hive.spacedPracticeBox.put(key, updated);
  }
}
