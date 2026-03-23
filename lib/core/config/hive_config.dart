import 'package:hive_flutter/hive_flutter.dart';
import '../constants/hive_boxes.dart';
import '../utils/app_logger.dart';

// Import model adapters
import '../../features/auth/data/models/user_model.dart';
import '../../features/learning/data/models/course_model.dart';
import '../../features/learning/data/models/lesson_model.dart';
import '../../features/learning/data/models/quiz_model.dart';
import '../../features/learning/data/models/user_progress_model.dart';
import '../../features/emergency/data/models/emergency_guide_model.dart';
import '../../features/aed/data/models/aed_location_model.dart';
import '../../features/aed/data/models/aed_location_model.g.dart';
import '../../features/gamification/data/models/badge_model.dart';
import '../../features/gamification/data/models/spaced_practice_model.dart';

/// Hive database configuration singleton
/// Manages local database initialization and box access
class HiveConfig {
  static final HiveConfig _instance = HiveConfig._internal();
  factory HiveConfig() => _instance;
  HiveConfig._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Increment this whenever any TypeAdapter field layout changes.
  /// On mismatch the typed box files are deleted BEFORE being opened
  /// (while they are still unlocked), so no file-access error can occur.
  static const int _schemaVersion = 5;

  /// Initialize Hive database
  /// This must be called before accessing any boxes
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Hive with Flutter
      await Hive.initFlutter();

      // Register TypeAdapters
      Hive.registerAdapter(UserModelAdapter());
      Hive.registerAdapter(CourseModelAdapter());
      Hive.registerAdapter(LessonModelAdapter());
      Hive.registerAdapter(QuizModelAdapter());
      Hive.registerAdapter(UserProgressModelAdapter());
      Hive.registerAdapter(EmergencyGuideModelAdapter());
      Hive.registerAdapter(AEDLocationModelAdapter());
      Hive.registerAdapter(BadgeModelAdapter());
      Hive.registerAdapter(SpacedPracticeModelAdapter());

      // Open untyped boxes first (these never have TypeAdapter changes)
      await Future.wait([
        Hive.openBox(HiveBoxes.auth),
        Hive.openBox(HiveBoxes.appSettings),
        Hive.openBox(HiveBoxes.syncQueue),
      ]);

      // Schema-version gate: delete typed box files if the TypeAdapter
      // layout has changed since the last run. Files are deleted HERE,
      // before they are opened, so they are not yet locked by Hive.
      final savedVersion =
          settingsBox.get('schema_version', defaultValue: 0) as int;
      if (savedVersion < _schemaVersion) {
        AppLogger.warning(
          'Hive schema changed ($savedVersion -> $_schemaVersion); clearing typed boxes',
          scope: 'hive',
        );
        for (final name in [
          HiveBoxes.users,
          HiveBoxes.courses,
          HiveBoxes.lessons,
          HiveBoxes.quizzes,
          HiveBoxes.userProgress,
          HiveBoxes.emergencyGuides,
          HiveBoxes.aedLocations,
          HiveBoxes.badges,
          HiveBoxes.spacedPractice,
        ]) {
          await Hive.deleteBoxFromDisk(name);
        }
        await settingsBox.put('schema_version', _schemaVersion);
      }

      // Open typed boxes (now guaranteed to match current adapters)
      await Future.wait([
        Hive.openBox<UserModel>(HiveBoxes.users),
        Hive.openBox<CourseModel>(HiveBoxes.courses),
        Hive.openBox<LessonModel>(HiveBoxes.lessons),
        Hive.openBox<QuizModel>(HiveBoxes.quizzes),
        Hive.openBox<UserProgressModel>(HiveBoxes.userProgress),
        Hive.openBox<EmergencyGuideModel>(HiveBoxes.emergencyGuides),
        Hive.openBox<AEDLocationModel>(HiveBoxes.aedLocations),
        Hive.openBox<BadgeModel>(HiveBoxes.badges),
        Hive.openBox<SpacedPracticeModel>(HiveBoxes.spacedPractice),
      ]);

      _initialized = true;
      AppLogger.info(
        'Hive initialized successfully (schema v$_schemaVersion)',
        scope: 'hive',
      );
    } catch (e) {
      AppLogger.error('Hive initialization failed', scope: 'hive', error: e);
      rethrow;
    }
  }

  // Box getters — untyped boxes
  Box get authBox => Hive.box(HiveBoxes.auth);
  Box get settingsBox => Hive.box(HiveBoxes.appSettings);
  Box get syncQueueBox => Hive.box(HiveBoxes.syncQueue);

  // Typed box getters
  Box<UserModel> get usersBox => Hive.box<UserModel>(HiveBoxes.users);
  Box<CourseModel> get coursesBox => Hive.box<CourseModel>(HiveBoxes.courses);
  Box<LessonModel> get lessonsBox => Hive.box<LessonModel>(HiveBoxes.lessons);
  Box<QuizModel> get quizzesBox => Hive.box<QuizModel>(HiveBoxes.quizzes);
  Box<UserProgressModel> get userProgressBox =>
      Hive.box<UserProgressModel>(HiveBoxes.userProgress);
  Box<EmergencyGuideModel> get emergencyGuidesBox =>
      Hive.box<EmergencyGuideModel>(HiveBoxes.emergencyGuides);
  Box<AEDLocationModel> get aedLocationsBox =>
      Hive.box<AEDLocationModel>(HiveBoxes.aedLocations);
  Box<BadgeModel> get badgesBox =>
      Hive.box<BadgeModel>(HiveBoxes.badges);
  Box<SpacedPracticeModel> get spacedPracticeBox =>
      Hive.box<SpacedPracticeModel>(HiveBoxes.spacedPractice);

  /// Clear all data from all boxes (used on logout / reset)
  Future<void> clearAllBoxes() async {
    await Future.wait([
      authBox.clear(),
      settingsBox.clear(),
      syncQueueBox.clear(),
      usersBox.clear(),
      coursesBox.clear(),
      lessonsBox.clear(),
      quizzesBox.clear(),
      userProgressBox.clear(),
      emergencyGuidesBox.clear(),
      aedLocationsBox.clear(),
      badgesBox.clear(),
      spacedPracticeBox.clear(),
    ]);
    AppLogger.info('All Hive boxes cleared', scope: 'hive');
  }

  /// Clear downloaded content while preserving auth, settings, and user data.
  Future<void> clearContentCaches() async {
    await Future.wait([
      coursesBox.clear(),
      lessonsBox.clear(),
      quizzesBox.clear(),
      emergencyGuidesBox.clear(),
      aedLocationsBox.clear(),
      badgesBox.clear(),
    ]);
    AppLogger.info('Content cache boxes cleared', scope: 'hive');
  }

  /// Close all boxes (called on app termination)
  Future<void> closeAllBoxes() async {
    await Hive.close();
    _initialized = false;
    AppLogger.info('All Hive boxes closed', scope: 'hive');
  }
}
