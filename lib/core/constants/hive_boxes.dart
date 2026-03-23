/// Hive box names and TypeAdapter IDs
/// All box names and adapter IDs are centralized here for consistency
class HiveBoxes {
  // Box names - used when opening Hive boxes
  static const String auth = 'auth_box';
  static const String users = 'users_box';
  static const String courses = 'courses_box';
  static const String lessons = 'lessons_box';
  static const String quizzes = 'quizzes_box';
  static const String userProgress = 'user_progress_box';
  static const String emergencyGuides = 'emergency_guides_box';
  static const String aedLocations = 'aed_locations_box';
  static const String syncQueue = 'sync_queue_box';
  static const String appSettings = 'app_settings_box';
  static const String badges = 'badges_box';
  static const String userBadges = 'user_badges_box';
  static const String quizAttempts = 'quiz_attempts_box';
  static const String spacedPractice = 'spaced_practice_box';

  // TypeAdapter IDs - must be unique integers for each model
  // These are used by Hive to identify different data types
  static const int userModelId = 0;
  static const int lessonModelId = 1;
  static const int quizModelId = 2;
  static const int userProgressModelId = 3;
  static const int emergencyGuideModelId = 4;
  static const int courseModelId = 11;
  static const int aedLocationModelId = 5;
  static const int appModeId = 6;
  static const int badgeModelId = 7;
  static const int userBadgeModelId = 8;
  static const int quizAttemptModelId = 9;
  static const int spacedPracticeModelId = 10;
}
