import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/hive_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';

abstract class ILessonRepository {
  List<LessonModel> getCachedLessonsForCourse(String courseId);
  Future<List<LessonModel>> syncLessonsForCourse(String courseId);
  Future<void> syncAllQuizzes();
}

/// Repository for lesson and quiz data.
/// Offline-first: serves Hive cache instantly, syncs from Supabase in background.
class LessonRepository implements ILessonRepository {
  final HiveConfig _hive = HiveConfig();
  bool get _isSupabaseReady => SupabaseConfig().isInitialized;
  SupabaseClient get _supabase => SupabaseConfig().client;

  // ─── Lessons ──────────────────────────────────────────────────────────────

  /// Returns cached lessons for a course sorted by sort_order descending
  /// (higher sort_order = earlier in the course, matching DB authoring order).
  @override
  List<LessonModel> getCachedLessonsForCourse(String courseId) {
    return _hive.lessonsBox.values
        .where((l) => l.courseId == courseId)
        .toList()
      ..sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
  }

  /// Returns a single cached lesson by ID, or null if not found.
  LessonModel? getCachedLesson(String lessonId) =>
      _hive.lessonsBox.get(lessonId);

  /// Returns ALL cached lessons (used by QuizScreen to look up lesson by ID).
  List<LessonModel> getAllCachedLessons() =>
      _hive.lessonsBox.values.toList();

  /// Fetches published lessons for a course from Supabase and caches them.
  @override
  Future<List<LessonModel>> syncLessonsForCourse(String courseId) async {
    if (!_isSupabaseReady) {
      throw Exception('Backend services are unavailable');
    }

    final data = await _supabase
        .from('lessons')
        .select()
        .eq('course_id', courseId)
        .eq('is_published', true)
        .order('sort_order', ascending: false);

    final lessons = data.map(_lessonFromRow).toList();

    for (final lesson in lessons) {
      await _hive.lessonsBox.put(lesson.id, lesson);
    }

    return lessons;
  }

  // ─── Quizzes ──────────────────────────────────────────────────────────────

  /// Returns cached quiz questions for a lesson sorted by sort_order.
  /// Deduplicates by sort_order (keeps the first seen) to guard against
  /// stale duplicate rows that may exist in the local Hive cache.
  List<QuizModel> getCachedQuizzesForLesson(String lessonId) {
    final all = _hive.quizzesBox.values
        .where((q) => q.lessonId == lessonId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final seen = <int>{};
    return all.where((q) => seen.add(q.sortOrder)).toList();
  }

  /// Fetches quiz questions for a lesson from Supabase and caches them.
  Future<List<QuizModel>> syncQuizzesForLesson(String lessonId) async {
    if (!_isSupabaseReady) {
      throw Exception('Backend services are unavailable');
    }

    final data = await _supabase
        .from('quizzes')
        .select()
        .eq('lesson_id', lessonId)
        .order('sort_order');

    final quizzes = data.map(_quizFromRow).toList();

    for (final quiz in quizzes) {
      await _hive.quizzesBox.put(quiz.id, quiz);
    }

    return quizzes;
  }

  /// Fetches ALL quiz questions in one query and caches them.
  /// Called by CoursesProvider on startup so quizzesBox is populated
  /// before the user opens any lesson or uses Quick Quiz.
  @override
  Future<void> syncAllQuizzes() async {
    if (!_isSupabaseReady) return;

    try {
      final data = await _supabase
          .from('quizzes')
          .select()
          .order('sort_order');

      final quizzes = data.map(_quizFromRow).toList();

      // Clear before repopulating so stale duplicate entries are removed.
      await _hive.quizzesBox.clear();
      await _hive.quizzesBox.putAll({for (final q in quizzes) q.id: q});
    } catch (e) {
      // Non-fatal - individual lesson sync will fill gaps on demand.
      AppLogger.warning('Bulk quiz sync failed', scope: 'learning', error: e);
    }
  }

  // ─── Private mapping helpers ───────────────────────────────────────────────

  LessonModel _lessonFromRow(Map<String, dynamic> row) {
    return LessonModel(
      id: row['id'] as String,
      courseId: row['course_id'] as String,
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      // content is JSONB — Supabase may return it as List<dynamic> (parsed)
      // or as a raw JSON String depending on client version. Handle both:
      // - List/Map → jsonEncode it into a JSON string for Hive storage
      // - String   → already a JSON string, use directly (avoid double-encoding)
      contentJson: row['content'] is String
          ? row['content'] as String
          : jsonEncode(row['content']),
      points: row['points'] as int? ?? 10,
      sortOrder: row['sort_order'] as int? ?? 0,
      isPublished: row['is_published'] as bool,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  QuizModel _quizFromRow(Map<String, dynamic> row) {
    final rawOptions = row['options'] as List<dynamic>;
    return QuizModel(
      id: row['id'] as String,
      lessonId: row['lesson_id'] as String,
      question: row['question'] as String,
      options: rawOptions.map((e) => e.toString()).toList(),
      correctAnswerIndex: row['correct_answer_index'] as int,
      explanation: row['explanation'] as String,
      sortOrder: row['sort_order'] as int,
    );
  }
}
