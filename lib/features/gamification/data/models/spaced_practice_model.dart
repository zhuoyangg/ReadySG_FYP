import 'package:hive/hive.dart';

import '../../../../core/services/app_clock.dart';

part 'spaced_practice_model.g.dart';

/// Tracks the spaced repetition review schedule for a completed lesson.
/// Uses fixed intervals: 1 -> 3 -> 7 -> 14 -> 30 days.
@HiveType(typeId: 10)
class SpacedPracticeModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String lessonId;

  @HiveField(2)
  final DateTime lastReviewedAt;

  @HiveField(3)
  final DateTime nextReviewAt;

  /// Current interval in days. Advances through 1 -> 3 -> 7 -> 14 -> 30.
  @HiveField(4)
  final int intervalDays;

  @HiveField(5)
  final int reviewCount;

  SpacedPracticeModel({
    required this.userId,
    required this.lessonId,
    required this.lastReviewedAt,
    required this.nextReviewAt,
    required this.intervalDays,
    required this.reviewCount,
  });

  static String hiveKey(String userId, String lessonId) =>
      '${userId}_${lessonId}_sp';

  /// Returns the next interval in the fixed sequence: 1 -> 3 -> 7 -> 14 -> 30.
  static int nextInterval(int current) {
    const intervals = [1, 3, 7, 14, 30];
    final idx = intervals.indexOf(current);
    if (idx == -1 || idx >= intervals.length - 1) return 30;
    return intervals[idx + 1];
  }

  bool get isDue => AppClock.now().isAfter(nextReviewAt);

  int get daysOverdue {
    if (!isDue) return 0;
    return AppClock.now().difference(nextReviewAt).inDays;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpacedPracticeModel &&
          other.userId == userId &&
          other.lessonId == lessonId);

  @override
  int get hashCode => Object.hash(userId, lessonId);
}
