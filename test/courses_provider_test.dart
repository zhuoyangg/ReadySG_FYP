import 'package:flutter_test/flutter_test.dart';
import 'package:ready_sg/features/learning/data/models/course_model.dart';
import 'package:ready_sg/features/learning/data/models/lesson_model.dart';
import 'package:ready_sg/features/learning/data/models/user_progress_model.dart';
import 'package:ready_sg/features/learning/data/repositories/course_repository.dart';
import 'package:ready_sg/features/learning/data/repositories/lesson_repository.dart';
import 'package:ready_sg/features/learning/data/repositories/progress_repository.dart';
import 'package:ready_sg/features/learning/providers/courses_provider.dart';

class _FakeCourseRepository implements ICourseRepository {
  _FakeCourseRepository({
    required this.cachedCourses,
    required this.syncResponses,
  });

  List<CourseModel> cachedCourses;
  final List<List<CourseModel>> syncResponses;
  int syncCount = 0;

  @override
  List<CourseModel> getCachedCourses() => List<CourseModel>.from(cachedCourses);

  @override
  Future<List<CourseModel>> syncCoursesFromRemote() async {
    final index = syncCount < syncResponses.length
        ? syncCount
        : syncResponses.length - 1;
    syncCount++;
    return List<CourseModel>.from(syncResponses[index]);
  }
}

class _FakeLessonRepository implements ILessonRepository {
  _FakeLessonRepository({
    required this.cachedLessons,
    required this.remoteLessons,
  });

  final Map<String, List<LessonModel>> cachedLessons;
  final Map<String, List<LessonModel>> remoteLessons;
  int syncAllQuizzesCount = 0;

  @override
  List<LessonModel> getCachedLessonsForCourse(String courseId) =>
      List<LessonModel>.from(cachedLessons[courseId] ?? const []);

  @override
  Future<List<LessonModel>> syncLessonsForCourse(String courseId) async =>
      List<LessonModel>.from(remoteLessons[courseId] ?? const []);

  @override
  Future<void> syncAllQuizzes() async {
    syncAllQuizzesCount++;
  }
}

class _FakeProgressRepository implements IProgressRepository {
  _FakeProgressRepository({
    required this.localProgress,
  });

  final Map<String, Map<String, UserProgressModel>> localProgress;
  final List<String> syncedUsers = [];

  @override
  Map<String, UserProgressModel> getAllLocalProgress(String userId) =>
      Map<String, UserProgressModel>.from(localProgress[userId] ?? const {});

  @override
  Future<void> syncAllProgressFromRemote(String userId) async {
    syncedUsers.add(userId);
  }
}

CourseModel _course(String id, String title) => CourseModel(
      id: id,
      title: title,
      description: 'Description for $title',
      thumbnailUrl: null,
      category: 'cpr',
      difficulty: 'beginner',
      sortOrder: 0,
      isPublished: true,
      createdAt: DateTime(2026, 1, 1),
    );

LessonModel _lesson(String id, String courseId) => LessonModel(
      id: id,
      courseId: courseId,
      title: 'Lesson $id',
      description: 'Lesson description',
      contentJson: '[]',
      points: 10,
      sortOrder: 0,
      isPublished: true,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  test(
    'CoursesProvider re-syncs catalog when cache is empty after a previous sync',
    () async {
      final firstRemote = [_course('course-1', 'CPR Essentials')];
      final secondRemote = [_course('course-2', 'AED Training')];
      final courseRepo = _FakeCourseRepository(
        cachedCourses: const [],
        syncResponses: [firstRemote, secondRemote],
      );
      final lessonRepo = _FakeLessonRepository(
        cachedLessons: const {},
        remoteLessons: {
          'course-1': [_lesson('lesson-1', 'course-1')],
          'course-2': [_lesson('lesson-2', 'course-2')],
        },
      );
      final progressRepo = _FakeProgressRepository(localProgress: const {});
      final provider = CoursesProvider(
        courseRepository: courseRepo,
        lessonRepository: lessonRepo,
        progressRepository: progressRepo,
      );

      await provider.loadCourses('user-1');
      expect(provider.courses.map((course) => course.id), ['course-1']);
      expect(courseRepo.syncCount, 1);

      courseRepo.cachedCourses = const [];

      await provider.loadCourses('user-1');

      expect(provider.courses.map((course) => course.id), ['course-2']);
      expect(courseRepo.syncCount, 2);
      expect(lessonRepo.syncAllQuizzesCount, 2);
    },
  );

  test('CoursesProvider resets sync state when the signed-in user changes', () async {
    final courseRepo = _FakeCourseRepository(
      cachedCourses: const [],
      syncResponses: [
        [_course('course-a', 'User A Course')],
        [_course('course-b', 'User B Course')],
      ],
    );
    final lessonRepo = _FakeLessonRepository(
      cachedLessons: const {},
      remoteLessons: {
        'course-a': [_lesson('lesson-a', 'course-a')],
        'course-b': [_lesson('lesson-b', 'course-b')],
      },
    );
    final progressRepo = _FakeProgressRepository(localProgress: const {});
    final provider = CoursesProvider(
      courseRepository: courseRepo,
      lessonRepository: lessonRepo,
      progressRepository: progressRepo,
    );

    await provider.loadCourses('user-a');
    await provider.loadCourses('user-b');

    expect(provider.courses.map((course) => course.id), ['course-b']);
    expect(courseRepo.syncCount, 2);
    expect(progressRepo.syncedUsers, ['user-a', 'user-b']);
  });
}
