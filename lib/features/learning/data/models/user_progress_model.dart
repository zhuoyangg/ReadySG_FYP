import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_progress_model.g.dart';

/// User progress model tracking lesson completion and quiz scores
/// Synchronized with Supabase user_progress table
@HiveType(typeId: 3)
@JsonSerializable()
class UserProgressModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String lessonId;

  @HiveField(2)
  final bool completed;

  @HiveField(3)
  final int quizScore; // Percentage 0-100

  @HiveField(4)
  final int bestScore; // Best quiz percentage achieved

  @HiveField(5)
  final DateTime? completedAt;

  UserProgressModel({
    required this.userId,
    required this.lessonId,
    required this.completed,
    required this.quizScore,
    required this.bestScore,
    this.completedAt,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      _$UserProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgressModelToJson(this);

  /// Hive storage key — unique per user+lesson pair
  static String hiveKey(String userId, String lessonId) =>
      '${userId}_$lessonId';

  UserProgressModel copyWith({
    bool? completed,
    int? quizScore,
    int? bestScore,
    DateTime? completedAt,
  }) {
    return UserProgressModel(
      userId: userId,
      lessonId: lessonId,
      completed: completed ?? this.completed,
      quizScore: quizScore ?? this.quizScore,
      bestScore: bestScore ?? this.bestScore,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgressModel &&
        other.userId == userId &&
        other.lessonId == lessonId;
  }

  @override
  int get hashCode => Object.hash(userId, lessonId);

  @override
  String toString() =>
      'UserProgressModel(userId: $userId, lessonId: $lessonId, completed: $completed, score: $quizScore)';
}
