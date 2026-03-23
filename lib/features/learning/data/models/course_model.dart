import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course_model.g.dart';

/// A course is a container for one or more related lessons.
/// Maps to the Supabase `courses` table.
@HiveType(typeId: 11)
@JsonSerializable()
class CourseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String? thumbnailUrl;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String difficulty;

  @HiveField(6)
  final int sortOrder;

  @HiveField(7)
  final bool isPublished;

  @HiveField(8)
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.category,
    required this.difficulty,
    required this.sortOrder,
    required this.isPublished,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseModelToJson(this);

  String get categoryLabel {
    switch (category) {
      case 'cpr':
        return 'CPR';
      case 'first_aid':
        return 'First Aid';
      case 'fire_safety':
        return 'Fire Safety';
      case 'aed':
        return 'AED';
      case 'emergency_prep':
        return 'Emergency Prep';
      default:
        return category;
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return difficulty;
    }
  }

  /// Icon to display when no thumbnail image is available.
  String get categoryEmoji {
    switch (category) {
      case 'cpr':
        return '❤️';
      case 'first_aid':
        return '🩹';
      case 'fire_safety':
        return '🔥';
      case 'aed':
        return '⚡';
      case 'emergency_prep':
        return '📞';
      default:
        return '📚';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CourseModel(id: $id, title: $title)';
}
