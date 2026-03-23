import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_clock.dart';
import '../config/hive_config.dart';
import '../config/supabase_config.dart';
import '../utils/app_logger.dart';

enum RecentActivityType {
  dailyChallenge,
  moduleCompletion,
  moduleReview,
  quickQuiz,
  timeTrial,
  badgeEarned,
}

class RecentActivityEntry {
  final String id;
  final RecentActivityType type;
  final DateTime timestamp;
  final DateTime? serverCreatedAt;
  final String title;
  final int? score;
  final int? correctAnswers;
  final int? totalQuestions;
  final bool? passed;
  final int? pointsEarned;
  final int? streakCount;

  const RecentActivityEntry({
    required this.id,
    required this.type,
    required this.timestamp,
    this.serverCreatedAt,
    required this.title,
    this.score,
    this.correctAnswers,
    this.totalQuestions,
    this.passed,
    this.pointsEarned,
    this.streakCount,
  });

  factory RecentActivityEntry.fromMap(Map<String, dynamic> map) {
    return RecentActivityEntry(
      id: map['id'] as String? ??
          _legacyIdFor(
            type: map['type'] as String,
            timestamp: map['timestamp'] as String,
            title: map['title'] as String,
          ),
      type: RecentActivityType.values.byName(map['type'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
      serverCreatedAt: map['serverCreatedAt'] != null
          ? DateTime.parse(map['serverCreatedAt'] as String)
          : null,
      title: map['title'] as String,
      score: map['score'] as int?,
      correctAnswers: map['correctAnswers'] as int?,
      totalQuestions: map['totalQuestions'] as int?,
      passed: map['passed'] as bool?,
      pointsEarned: map['pointsEarned'] as int?,
      streakCount: map['streakCount'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'serverCreatedAt': serverCreatedAt?.toIso8601String(),
      'title': title,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'passed': passed,
      'pointsEarned': pointsEarned,
      'streakCount': streakCount,
    };
  }

  Map<String, dynamic> toRemoteMap(String userId) {
    return {
      'id': id,
      'user_id': userId,
      'activity_type': type.name,
      'activity_at': timestamp.toIso8601String(),
      'title': title,
      'score': score,
      'correct_answers': correctAnswers,
      'total_questions': totalQuestions,
      'passed': passed,
      'points_earned': pointsEarned,
      'streak_count': streakCount,
    };
  }

  factory RecentActivityEntry.fromRemoteMap(Map<String, dynamic> map) {
    final activityTimestamp =
        map['activity_at'] as String? ?? map['created_at'] as String;
    final createdAt = map['created_at'] as String?;
    return RecentActivityEntry(
      id: map['id'] as String,
      type: RecentActivityType.values.byName(map['activity_type'] as String),
      timestamp: DateTime.parse(activityTimestamp),
      serverCreatedAt: createdAt != null ? DateTime.parse(createdAt) : null,
      title: map['title'] as String,
      score: map['score'] as int?,
      correctAnswers: map['correct_answers'] as int?,
      totalQuestions: map['total_questions'] as int?,
      passed: map['passed'] as bool?,
      pointsEarned: map['points_earned'] as int?,
      streakCount: map['streak_count'] as int?,
    );
  }

  static String generateId({
    required RecentActivityType type,
    required DateTime timestamp,
    required String title,
  }) {
    return '${timestamp.microsecondsSinceEpoch}_${type.name}_${title.hashCode}';
  }

  DateTime get sortTimestamp => serverCreatedAt ?? timestamp;

  static String _legacyIdFor({
    required String type,
    required String timestamp,
    required String title,
  }) {
    final parsed = DateTime.tryParse(timestamp) ?? AppClock.now();
    return generateId(
      type: RecentActivityType.values.byName(type),
      timestamp: parsed,
      title: title,
    );
  }
}

class RecentActivityService {
  static const int _maxEntries = 30;
  static const _practicePointsTypes = {
    RecentActivityType.quickQuiz,
    RecentActivityType.timeTrial,
  };
  static final ValueNotifier<int> _changes = ValueNotifier<int>(0);
  static final Map<String, List<RecentActivityEntry>> _entriesCache = {};

  final HiveConfig _hive = HiveConfig();
  bool get _isSupabaseReady => SupabaseConfig().isInitialized;
  SupabaseClient get _supabase => SupabaseConfig().client;

  ValueListenable<int> get changes => _changes;

  List<RecentActivityEntry> getRecentActivities(
    String userId, {
    int limit = 5,
  }) {
    final cachedEntries = _entriesCache[userId];
    if (cachedEntries != null) {
      return cachedEntries.take(limit).toList();
    }

    final raw = _hive.settingsBox.get(_key(userId)) as String?;
    if (raw == null || raw.isEmpty) {
      _entriesCache.remove(userId);
      return const [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final entries = decoded
          .map((item) => RecentActivityEntry.fromMap(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList()
        ..sort((a, b) => b.sortTimestamp.compareTo(a.sortTimestamp));
      _entriesCache[userId] = List.unmodifiable(entries);
      return entries.take(limit).toList();
    } catch (_) {
      _entriesCache.remove(userId);
      return const [];
    }
  }

  int getPracticePointsTotal(String userId) {
    final cached = _hive.settingsBox.get(_practicePointsKey(userId));
    if (cached is num) return cached.toInt();
    return _sumPracticePoints(getRecentActivities(userId, limit: _maxEntries));
  }

  Future<void> logModuleCompletion({
    required String userId,
    required String lessonId,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required bool passed,
  }) {
    final timestamp = AppClock.now();
    return _append(
      userId,
      RecentActivityEntry(
        id: RecentActivityEntry.generateId(
          type: RecentActivityType.moduleCompletion,
          timestamp: timestamp,
          title: _resolveLessonTitle(lessonId),
        ),
        type: RecentActivityType.moduleCompletion,
        timestamp: timestamp,
        title: _resolveLessonTitle(lessonId),
        score: score,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        passed: passed,
      ),
    );
  }

  Future<void> logModuleReviewCompletion({
    required String userId,
    required String lessonId,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required bool passed,
  }) {
    final timestamp = AppClock.now();
    return _append(
      userId,
      RecentActivityEntry(
        id: RecentActivityEntry.generateId(
          type: RecentActivityType.moduleReview,
          timestamp: timestamp,
          title: _resolveLessonTitle(lessonId),
        ),
        type: RecentActivityType.moduleReview,
        timestamp: timestamp,
        title: _resolveLessonTitle(lessonId),
        score: score,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        passed: passed,
      ),
    );
  }

  Future<void> logQuickQuizCompletion({
    required String userId,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required bool passed,
    int? pointsEarned,
  }) {
    final timestamp = AppClock.now();
    return _append(
      userId,
      RecentActivityEntry(
        id: RecentActivityEntry.generateId(
          type: RecentActivityType.quickQuiz,
          timestamp: timestamp,
          title: 'Quick Quiz',
        ),
        type: RecentActivityType.quickQuiz,
        timestamp: timestamp,
        title: 'Quick Quiz',
        score: score,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        passed: passed,
        pointsEarned: pointsEarned,
      ),
    );
  }

  Future<void> logTimeTrialCompletion({
    required String userId,
    required int correctAnswers,
    required int totalQuestions,
    required int pointsEarned,
  }) {
    final score = totalQuestions == 0
        ? 0
        : ((correctAnswers / totalQuestions) * 100).round();
    final timestamp = AppClock.now();
    return _append(
      userId,
      RecentActivityEntry(
        id: RecentActivityEntry.generateId(
          type: RecentActivityType.timeTrial,
          timestamp: timestamp,
          title: 'Time Trial',
        ),
        type: RecentActivityType.timeTrial,
        timestamp: timestamp,
        title: 'Time Trial',
        score: score,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        passed: correctAnswers >= 10,
        pointsEarned: pointsEarned,
      ),
    );
  }

  Future<void> logDailyChallengeCompletion({
    required String userId,
    required String challengeTitle,
    required int pointsEarned,
    required int streakCount,
  }) {
    final timestamp = AppClock.now();
    return _append(
      userId,
      RecentActivityEntry(
        id: RecentActivityEntry.generateId(
          type: RecentActivityType.dailyChallenge,
          timestamp: timestamp,
          title: challengeTitle,
        ),
        type: RecentActivityType.dailyChallenge,
        timestamp: timestamp,
        title: challengeTitle,
        pointsEarned: pointsEarned,
        streakCount: streakCount,
      ),
    );
  }

  Future<void> logBadgeEarned({
    required String userId,
    required String badgeName,
    required int pointsEarned,
  }) {
    final timestamp = AppClock.now();
    return _append(
      userId,
      RecentActivityEntry(
        id: RecentActivityEntry.generateId(
          type: RecentActivityType.badgeEarned,
          timestamp: timestamp,
          title: badgeName,
        ),
        type: RecentActivityType.badgeEarned,
        timestamp: timestamp,
        title: badgeName,
        pointsEarned: pointsEarned,
      ),
    );
  }

  Future<void> syncWithRemote(String userId) async {
    if (!_isSupabaseReady) return;

    try {
      final localEntries = getRecentActivities(userId, limit: _maxEntries);
      await _pushEntriesToRemote(userId, localEntries);

      final rows = await _supabase
          .from('recent_activity')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(_maxEntries);

      final remoteEntries = (rows as List)
          .map((row) => RecentActivityEntry.fromRemoteMap(row as Map<String, dynamic>))
          .toList();

      final merged = _mergeEntries(localEntries, remoteEntries);
      await _storeEntries(userId, merged, notify: false);
      await _storePracticePointsTotal(
        userId,
        await _fetchRemotePracticePointsTotal(userId),
      );
      _changes.value++;
    } catch (e) {
      AppLogger.warning(
        'Recent activity sync failed',
        scope: 'recent_activity',
        error: e,
      );
    }
  }

  Future<void> _append(String userId, RecentActivityEntry entry) async {
    final existing = getRecentActivities(userId, limit: _maxEntries);
    final updated = _mergeEntries([entry], existing);
    await _storeEntries(userId, updated, notify: false);

    final currentTotal = getPracticePointsTotal(userId);
    final delta = _practicePointsTypes.contains(entry.type)
        ? (entry.pointsEarned ?? 0)
        : 0;
    await _storePracticePointsTotal(userId, currentTotal + delta);
    _changes.value++;

    if (_isSupabaseReady) {
      try {
        await _pushEntriesToRemote(userId, [entry]);
      } catch (e) {
        AppLogger.warning(
          'Recent activity remote append failed',
          scope: 'recent_activity',
          error: e,
        );
      }
    }
  }

  String _resolveLessonTitle(String lessonId) {
    return _hive.lessonsBox.get(lessonId)?.title ?? lessonId;
  }

  List<RecentActivityEntry> _mergeEntries(
    List<RecentActivityEntry> primary,
    List<RecentActivityEntry> secondary,
  ) {
    final merged = <String, RecentActivityEntry>{};
    for (final entry in [...primary, ...secondary]) {
      merged[entry.id] = entry;
    }
    final values = merged.values.toList()
      ..sort((a, b) => b.sortTimestamp.compareTo(a.sortTimestamp));
    return values.take(_maxEntries).toList();
  }

  Future<void> _storeEntries(
    String userId,
    List<RecentActivityEntry> entries, {
    bool notify = true,
  }) async {
    final encoded = jsonEncode(entries.map((item) => item.toMap()).toList());
    await _hive.settingsBox.put(_key(userId), encoded);
    _entriesCache[userId] = List.unmodifiable(
      List<RecentActivityEntry>.from(entries),
    );
    if (notify) {
      _changes.value++;
    }
  }

  Future<void> _storePracticePointsTotal(String userId, int total) async {
    await _hive.settingsBox.put(_practicePointsKey(userId), total);
  }

  Future<void> _pushEntriesToRemote(
    String userId,
    List<RecentActivityEntry> entries,
  ) async {
    if (entries.isEmpty) return;
    await _supabase.from('recent_activity').upsert(
          entries.map((entry) => entry.toRemoteMap(userId)).toList(),
          onConflict: 'id',
        );
  }

  String _key(String userId) => 'recent_activity_$userId';
  String _practicePointsKey(String userId) => 'practice_points_total_$userId';

  Future<int> _fetchRemotePracticePointsTotal(String userId) async {
    final rows = await _supabase
        .from('recent_activity')
        .select('activity_type, points_earned')
        .eq('user_id', userId)
        .or('activity_type.eq.quickQuiz,activity_type.eq.timeTrial');

    return _sumPracticePoints(
      (rows as List)
          .map((row) => RecentActivityEntry(
                id: '',
                type: RecentActivityType.values
                    .byName((row as Map<String, dynamic>)['activity_type'] as String),
                timestamp: DateTime.fromMillisecondsSinceEpoch(0),
                serverCreatedAt: null,
                title: '',
                pointsEarned: row['points_earned'] as int?,
              ))
          .toList(),
    );
  }

  int _sumPracticePoints(List<RecentActivityEntry> entries) {
    return entries
        .where((entry) => _practicePointsTypes.contains(entry.type))
        .fold<int>(0, (sum, entry) => sum + (entry.pointsEarned ?? 0));
  }
}
