import 'package:hive/hive.dart';

part 'badge_model.g.dart';

/// Represents an achievement badge that users can earn.
/// Badges are seeded in Supabase and cached locally in Hive.
@HiveType(typeId: 7)
class BadgeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  /// Icon identifier - maps to a Material icon in the UI.
  @HiveField(3)
  final String iconName;

  /// Badge category: 'milestone' | 'streak' | 'quiz'
  @HiveField(4)
  final String category;

  /// Threshold that triggers this badge (lessons count, streak days, or score %).
  @HiveField(5)
  final int threshold;

  @HiveField(6)
  final int pointsReward;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.category,
    required this.threshold,
    required this.pointsReward,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BadgeModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BadgeModel($name, category: $category)';
}
