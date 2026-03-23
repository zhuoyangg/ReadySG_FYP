/// Application-wide constants
/// Centralized location for all app constants
class AppConstants {
  // App Information
  static const String appName = 'ReadySG';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Be Prepared. Save Lives.';

  // Cache and Sync Configuration
  static const Duration cacheRefreshInterval = Duration(hours: 24);
  static const Duration syncRetryInterval = Duration(minutes: 5);
  static const Duration offlineDataValidity = Duration(days: 7);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Retry Policies
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration apiTimeout = Duration(seconds: 30);

  // Local Storage Keys
  static const String lastSyncKey = 'last_sync_timestamp';
  static const String currentModeKey = 'current_app_mode';
  static const String userSessionKey = 'user_session';
  static const String userIdKey = 'user_id';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Emergency Contact Numbers (Singapore)
  static const String emergencyNumber = '995'; // SCDF - Fire & Ambulance
  static const String policeNumber = '999'; // Singapore Police Force
  static const String ambulanceNumber = '995'; // Same as emergency
  static const String nonEmergencyAmbulanceNumber = '1777';
  static const String nationalMindlineNumber = '1771';
  static const String samaritansHotlineNumber = '1767';
  static const String policeEmergencySmsNumber = '70999';
  static const String scdfEmergencySmsNumber = '70995';
  static const String scdfHotline = '1800-280-0000'; // SCDF hotline

  // External URLs
  static const String scdfWebsite = 'https://www.scdf.gov.sg';
  static const String myResponderApp = 'https://www.scdf.gov.sg/home/community-volunteers/mobile-applications/myresponder-app';
  static const String privacyPolicyUrl = 'https://example.com/privacy'; // Update with actual URL
  static const String termsOfServiceUrl = 'https://example.com/terms'; // Update with actual URL
  static const String supportEmail = 'support@readysg.com'; // Update with actual email

  // Gamification
  static const int pointsPerLessonComplete = 10;
  static const int pointsPerQuizPass = 15;
  static const int pointsPerQuizPerfectScore = 25;
  static const int pointsPerBadgeEarned = 50;
  static const int pointsPerDailyStreak = 5;

  // Quiz Configuration
  static const int defaultPassingScore = 70; // Percentage
  static const int quizTimeoutMinutes = 15;
  static const int maxQuizAttempts = 3;

  // Spaced Repetition Intervals (in days)
  static const List<int> spacedRepetitionIntervals = [1, 3, 7, 14, 30];

  // Media Configuration
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSizeBytes = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoFormats = ['mp4', 'webm'];

  // Supabase Pagination
  static const int supabasePageSize = 1000; // Supabase default row limit

  // Video Player
  static const Duration youtubeLoadTimeout = Duration(seconds: 12);

  // Map Configuration
  static const double defaultMapZoom = 15.0;
  static const double aedSearchRadiusMeters = 2000; // 2km radius
  static const double singaporeLatitude = 1.3521;
  static const double singaporeLongitude = 103.8198;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Notification Configuration
  static const String notificationChannelId = 'readysg_notifications';
  static const String notificationChannelName = 'ReadySG Notifications';
  static const String notificationChannelDescription = 'Notifications for spaced practice reminders';

  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String authErrorMessage = 'Authentication failed. Please log in again.';
}
