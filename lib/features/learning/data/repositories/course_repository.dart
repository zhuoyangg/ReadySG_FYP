import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/hive_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/course_model.dart';

abstract class ICourseRepository {
  List<CourseModel> getCachedCourses();
  Future<List<CourseModel>> syncCoursesFromRemote();
}

/// Repository for course data.
/// Offline-first: serves Hive cache instantly, syncs from Supabase in background.
class CourseRepository implements ICourseRepository {
  final HiveConfig _hive = HiveConfig();
  bool get _isSupabaseReady => SupabaseConfig().isInitialized;
  SupabaseClient get _supabase => SupabaseConfig().client;

  /// Returns cached courses sorted by sort_order.
  @override
  List<CourseModel> getCachedCourses() {
    return _hive.coursesBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Fetches published courses from Supabase, caches in Hive, and returns the list.
  @override
  Future<List<CourseModel>> syncCoursesFromRemote() async {
    if (!_isSupabaseReady) {
      throw Exception('Backend services are unavailable');
    }

    final data = await _supabase
        .from('courses')
        .select()
        .eq('is_published', true)
        .order('sort_order');

    final courses = (data as List)
        .map((row) => _courseFromRow(row as Map<String, dynamic>))
        .toList();

    for (final course in courses) {
      await _hive.coursesBox.put(course.id, course);
    }

    return courses;
  }

  CourseModel _courseFromRow(Map<String, dynamic> row) {
    return CourseModel(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      thumbnailUrl: row['thumbnail_url'] as String?,
      category: row['category'] as String,
      difficulty: row['difficulty'] as String,
      sortOrder: row['sort_order'] as int? ?? 0,
      isPublished: row['is_published'] as bool,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
