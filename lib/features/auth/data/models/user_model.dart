import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User model for authentication and profile data
/// Synchronized with Supabase profiles table
@HiveType(typeId: 0)
@JsonSerializable()
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? username;

  @HiveField(3)
  final String? fullName;

  @HiveField(4)
  final String? avatarUrl;

  @HiveField(5)
  final int totalPoints;

  @HiveField(6)
  final int currentStreak;

  @HiveField(7)
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.totalPoints = 0,
    this.currentStreak = 0,
    required this.createdAt,
  });

  /// Create UserModel from JSON (Supabase response)
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert UserModel to JSON (for Supabase)
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatarUrl,
    int? totalPoints,
    int? currentStreak,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, fullName: $fullName, points: $totalPoints, streak: $currentStreak)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
