import 'package:flutter/material.dart';

import '../../../core/providers/app_preferences_provider.dart';
import '../../../core/services/sync_queue_service.dart';
import '../../../core/utils/app_logger.dart';
import '../data/models/course_model.dart';
import '../data/models/lesson_model.dart';
import '../data/models/user_progress_model.dart';
import '../data/repositories/course_repository.dart';
import '../data/repositories/lesson_repository.dart';
import '../data/repositories/progress_repository.dart';

/// Manages the full course catalogue, per-course lesson lists, and progress.
///
/// Load sequence:
///   1. Serve Hive cache instantly (empty if first run)
///   2. Sync courses and lessons from Supabase in background
///   3. Notify listeners when sync completes
class CoursesProvider extends ChangeNotifier {
  CoursesProvider({
    ICourseRepository? courseRepository,
    ILessonRepository? lessonRepository,
    IProgressRepository? progressRepository,
  })  : _courseRepo = courseRepository ?? CourseRepository(),
        _lessonRepo = lessonRepository ?? LessonRepository(),
        _progressRepo = progressRepository ?? ProgressRepository();

  final ICourseRepository _courseRepo;
  final ILessonRepository _lessonRepo;
  final IProgressRepository _progressRepo;

  List<CourseModel> _courses = [];
  final Map<String, List<LessonModel>> _lessonsByCourse = {};
  Map<String, UserProgressModel> _progress = {};
  bool _isLoading = false;
  bool _hasSynced = false;
  String? _error;
  bool _syncFailed = false;
  String? _currentUserId;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get syncFailed => _syncFailed;
  bool get hasData => _courses.isNotEmpty;

  List<LessonModel> lessonsForCourse(String courseId) =>
      _lessonsByCourse[courseId] ?? [];

  UserProgressModel? progressFor(String lessonId) => _progress[lessonId];

  bool isLessonCompleted(String lessonId) =>
      _progress[lessonId]?.completed == true;

  int completedCountForCourse(String courseId) =>
      lessonsForCourse(courseId).where((lesson) {
        return isLessonCompleted(lesson.id);
      }).length;

  double progressFractionForCourse(String courseId) {
    final total = lessonsForCourse(courseId).length;
    if (total == 0) return 0;
    return completedCountForCourse(courseId) / total;
  }

  /// Total completed lessons across all courses for the loaded user.
  int get totalCompletedLessons =>
      _progress.values.where((progress) => progress.completed).length;

  /// Finds a lesson by ID across all loaded courses, or null if not found.
  LessonModel? findLesson(String lessonId) {
    for (final lessons in _lessonsByCourse.values) {
      for (final lesson in lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  bool _isSyncing = false;

  /// Load courses, lessons, and progress for [userId].
  Future<void> loadCourses(String userId) async {
    // Prevent overlapping sync operations from concurrent calls.
    if (_isSyncing && _currentUserId == userId) return;
    _resetForUserChange(userId);
    _currentUserId = userId;
    _prepareForLoad();
    _loadCachedState(userId);
    notifyListeners();

    if (_shouldSkipAutoSync()) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = _courses.isEmpty;
    if (_isLoading) notifyListeners();

    _isSyncing = true;
    try {
      await _syncCatalogIfNeeded();
      await _syncProgress(userId);
    } catch (e) {
      _syncFailed = true;
      _error = _courses.isEmpty ? 'Failed to load courses: $e' : null;
      AppLogger.warning('Course sync failed', scope: 'courses', error: e);
    } finally {
      _isSyncing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force re-sync from Supabase (pull-to-refresh).
  Future<void> refresh() async {
    if (_currentUserId == null) return;
    _hasSynced = false;
    await loadCourses(_currentUserId!);
  }

  /// Called after a quiz is submitted to update completion badges immediately.
  void refreshProgress(String userId) {
    _progress = _progressRepo.getAllLocalProgress(userId);
    notifyListeners();
  }

  void _resetForUserChange(String userId) {
    if (_currentUserId == userId) return;

    _hasSynced = false;
    _isSyncing = false;
    _courses = [];
    _lessonsByCourse.clear();
    _progress = {};
  }

  void _prepareForLoad() {
    _error = null;
    _syncFailed = false;
  }

  void _loadCachedState(String userId) {
    _courses = _courseRepo.getCachedCourses();
    _replaceLessonsByCourse(_cachedLessonsFor(_courses));
    _progress = _progressRepo.getAllLocalProgress(userId);
  }

  bool _shouldSkipAutoSync() {
    return _courses.isNotEmpty &&
        (AppPreferencesProvider.readPreferOfflineCache() ||
            !AppPreferencesProvider.readAutoSyncOnLaunch());
  }

  Future<void> _syncCatalogIfNeeded() async {
    final shouldSyncCatalog = !_hasSynced || _courses.isEmpty;
    if (!shouldSyncCatalog) return;

    final syncedCourses = await _courseRepo.syncCoursesFromRemote();
    final syncedLessons = await _syncLessonsForCourses(syncedCourses);

    _courses = syncedCourses;
    _replaceLessonsByCourse(syncedLessons);

    // Sync quiz questions in one bulk fetch so the quiz cache is ready before
    // the user opens a lesson or launches Quick Quiz.
    await _lessonRepo.syncAllQuizzes();
    _hasSynced = true;
  }

  Future<void> _syncProgress(String userId) async {
    await SyncQueueService().flushPendingForCurrentUser();
    await _progressRepo.syncAllProgressFromRemote(userId);
    _progress = _progressRepo.getAllLocalProgress(userId);
    _syncFailed = false;
  }

  Map<String, List<LessonModel>> _cachedLessonsFor(List<CourseModel> courses) {
    return {
      for (final course in courses)
        course.id: _lessonRepo.getCachedLessonsForCourse(course.id),
    };
  }

  Future<Map<String, List<LessonModel>>> _syncLessonsForCourses(
    List<CourseModel> courses,
  ) async {
    final lessonEntries = await Future.wait(
      courses.map(
        (course) async => MapEntry(
          course.id,
          await _lessonRepo.syncLessonsForCourse(course.id),
        ),
      ),
    );

    return {
      for (final entry in lessonEntries) entry.key: entry.value,
    };
  }

  void _replaceLessonsByCourse(Map<String, List<LessonModel>> lessonsByCourse) {
    _lessonsByCourse
      ..clear()
      ..addAll(lessonsByCourse);
  }
}
