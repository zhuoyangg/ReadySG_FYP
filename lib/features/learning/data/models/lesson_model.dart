import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson_model.g.dart';

/// A lesson is one module within a course, containing a slide array.
/// Maps to the Supabase `lessons` table.
@HiveType(typeId: 1)
@JsonSerializable()
class LessonModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String courseId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  /// JSON-encoded slide array from the JSONB `content` column.
  /// Use the [slides] getter to get a decoded list.
  @HiveField(4)
  final String contentJson;

  @HiveField(5)
  final int points;

  @HiveField(6)
  final int sortOrder;

  @HiveField(7)
  final bool isPublished;

  @HiveField(8)
  final DateTime createdAt;

  LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.contentJson,
    required this.points,
    required this.sortOrder,
    required this.isPublished,
    required this.createdAt,
  });

  /// Decodes [contentJson] into a list of typed slide maps.
  /// Each map has at minimum a 'type' key ('text', 'image', 'video', 'tip').
  /// Handles double-encoded strings gracefully: if the first decode returns a
  /// String rather than a List (caused by Supabase returning JSONB as a raw
  /// string that was then jsonEncoded again), it decodes a second time.
  List<Map<String, dynamic>> get slides {
    dynamic decoded = jsonDecode(contentJson);
    if (decoded is String) decoded = jsonDecode(decoded);
    final list = decoded as List<dynamic>;
    return list.map((s) => Map<String, dynamic>.from(s as Map)).toList();
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonModelToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LessonModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'LessonModel(id: $id, title: $title, courseId: $courseId)';
}
