import 'package:flutter/foundation.dart';

import '../config/hive_config.dart';

class CacheInfoSnapshot {
  final int authEntries;
  final int settingsEntries;
  final int syncQueueEntries;
  final int courses;
  final int lessons;
  final int quizzes;
  final int progressEntries;
  final int guides;
  final int aeds;
  final int badges;
  final int reviewSchedules;

  const CacheInfoSnapshot({
    required this.authEntries,
    required this.settingsEntries,
    required this.syncQueueEntries,
    required this.courses,
    required this.lessons,
    required this.quizzes,
    required this.progressEntries,
    required this.guides,
    required this.aeds,
    required this.badges,
    required this.reviewSchedules,
  });

  int get totalEntries =>
      authEntries +
      settingsEntries +
      syncQueueEntries +
      courses +
      lessons +
      quizzes +
      progressEntries +
      guides +
      aeds +
      badges +
      reviewSchedules;
}

class AppPreferencesProvider extends ChangeNotifier {
  static const String _darkModeKey = 'pref_dark_mode';
  static const String _preferOfflineCacheKey = 'pref_prefer_offline_cache';
  static const String _autoSyncOnLaunchKey = 'pref_auto_sync_on_launch';
  static const String _reviewRemindersEnabledKey =
      'pref_review_reminders_enabled';
  static const String _streakNudgesEnabledKey = 'pref_streak_nudges_enabled';
  static const String _showDebugToolsKey = 'pref_show_debug_tools';

  static final HiveConfig _sharedHive = HiveConfig();

  final HiveConfig _hive = HiveConfig();

  bool _darkMode = false;
  bool _preferOfflineCache = false;
  bool _autoSyncOnLaunch = true;
  bool _reviewRemindersEnabled = true;
  bool _streakNudgesEnabled = true;
  bool _showDebugTools = kDebugMode;

  AppPreferencesProvider() {
    _loadSavedPreferences();
  }

  bool get darkMode => _darkMode;
  bool get preferOfflineCache => _preferOfflineCache;
  bool get autoSyncOnLaunch => _autoSyncOnLaunch;
  bool get reviewRemindersEnabled => _reviewRemindersEnabled;
  bool get streakNudgesEnabled => _streakNudgesEnabled;
  bool get debugToolsAvailable => kDebugMode;
  bool get showDebugTools => debugToolsAvailable && _showDebugTools;

  CacheInfoSnapshot get cacheInfo => CacheInfoSnapshot(
        authEntries: _hive.authBox.length,
        settingsEntries: _hive.settingsBox.length,
        syncQueueEntries: _hive.syncQueueBox.length,
        courses: _hive.coursesBox.length,
        lessons: _hive.lessonsBox.length,
        quizzes: _hive.quizzesBox.length,
        progressEntries: _hive.userProgressBox.length,
        guides: _hive.emergencyGuidesBox.length,
        aeds: _hive.aedLocationsBox.length,
        badges: _hive.badgesBox.length,
        reviewSchedules: _hive.spacedPracticeBox.length,
      );

  static bool readDarkMode() => _readBool(_darkModeKey, false);
  static bool readPreferOfflineCache() =>
      _readBool(_preferOfflineCacheKey, false);
  static bool readAutoSyncOnLaunch() =>
      _readBool(_autoSyncOnLaunchKey, true);
  static bool readReviewRemindersEnabled() =>
      _readBool(_reviewRemindersEnabledKey, true);
  static bool readStreakNudgesEnabled() =>
      _readBool(_streakNudgesEnabledKey, true);
  static bool readShowDebugTools() =>
      kDebugMode && _readBool(_showDebugToolsKey, true);

  Future<void> setDarkMode(bool value) =>
      _setBool(_darkModeKey, value, () => _darkMode = value);

  Future<void> setPreferOfflineCache(bool value) => _setBool(
        _preferOfflineCacheKey,
        value,
        () => _preferOfflineCache = value,
      );

  Future<void> setAutoSyncOnLaunch(bool value) => _setBool(
        _autoSyncOnLaunchKey,
        value,
        () => _autoSyncOnLaunch = value,
      );

  Future<void> setReviewRemindersEnabled(bool value) => _setBool(
        _reviewRemindersEnabledKey,
        value,
        () => _reviewRemindersEnabled = value,
      );

  Future<void> setStreakNudgesEnabled(bool value) => _setBool(
        _streakNudgesEnabledKey,
        value,
        () => _streakNudgesEnabled = value,
      );

  Future<void> setShowDebugTools(bool value) => _setBool(
        _showDebugToolsKey,
        debugToolsAvailable && value,
        () => _showDebugTools = debugToolsAvailable && value,
      );

  void _loadSavedPreferences() {
    if (!_hive.isInitialized) return;

    _darkMode = readDarkMode();
    _preferOfflineCache = readPreferOfflineCache();
    _autoSyncOnLaunch = readAutoSyncOnLaunch();
    _reviewRemindersEnabled = readReviewRemindersEnabled();
    _streakNudgesEnabled = readStreakNudgesEnabled();
    _showDebugTools = readShowDebugTools();
  }

  Future<void> _setBool(
    String key,
    bool value,
    VoidCallback apply,
  ) async {
    apply();
    if (_hive.isInitialized) {
      await _hive.settingsBox.put(key, value);
    }
    notifyListeners();
  }

  static bool _readBool(String key, bool defaultValue) {
    if (!_sharedHive.isInitialized) return defaultValue;
    return (_sharedHive.settingsBox.get(key) as bool?) ?? defaultValue;
  }
}
