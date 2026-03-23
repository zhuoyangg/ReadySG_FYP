import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'emergency_guide_model.g.dart';

/// A single emergency guide (e.g. CPR, Choking, Burns).
/// Maps to the Supabase `emergency_guides` table.
/// Content is stored as a JSONB slide array - same shape as LessonModel.
@HiveType(typeId: 4)
@JsonSerializable()
class EmergencyGuideModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  /// JSON-encoded slide array from the JSONB `content` column.
  /// Slide types: 'text', 'image', 'video'.
  /// Use the [slides] getter to get a decoded list.
  @HiveField(3)
  final String contentJson;

  @HiveField(4)
  final int sortOrder;

  @HiveField(5)
  final bool isPublished;

  @HiveField(6)
  final DateTime createdAt;

  EmergencyGuideModel({
    required this.id,
    required this.title,
    required this.description,
    required this.contentJson,
    required this.sortOrder,
    required this.isPublished,
    required this.createdAt,
  });

  /// Decodes [contentJson] into a list of typed slide maps.
  /// Each map has at minimum a 'type' key ('text', 'image', 'video').
  /// Handles double-encoded strings defensively (same pattern as LessonModel).
  List<Map<String, dynamic>> get slides {
    dynamic decoded = jsonDecode(contentJson);
    if (decoded is String) decoded = jsonDecode(decoded);
    final list = decoded as List<dynamic>;
    return list.map((s) => Map<String, dynamic>.from(s as Map)).toList();
  }

  factory EmergencyGuideModel.fromJson(Map<String, dynamic> json) =>
      _$EmergencyGuideModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyGuideModelToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyGuideModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'EmergencyGuideModel(id: $id, title: $title)';
}
