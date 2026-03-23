import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_model.g.dart';

/// Quiz question model for a lesson
/// Each lesson has multiple quiz questions in Supabase quizzes table
@HiveType(typeId: 2)
@JsonSerializable()
class QuizModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String lessonId;

  @HiveField(2)
  final String question;

  @HiveField(3)
  final List<String> options;

  @HiveField(4)
  final int correctAnswerIndex;

  @HiveField(5)
  final String explanation;

  @HiveField(6)
  final int sortOrder;

  QuizModel({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.sortOrder,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizModelToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'QuizModel(id: $id, lessonId: $lessonId, question: $question)';
}
