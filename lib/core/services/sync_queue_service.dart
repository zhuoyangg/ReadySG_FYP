import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/hive_config.dart';
import '../config/supabase_config.dart';
import '../utils/app_logger.dart';

/// Persists user-specific remote mutations until Supabase is reachable again.
class SyncQueueService {
  static final SyncQueueService _instance = SyncQueueService._internal();
  factory SyncQueueService() => _instance;
  SyncQueueService._internal();

  final HiveConfig _hive = HiveConfig();

  /// Guards concurrent access to the points-delta accumulator in Hive.
  Future<void>? _pointsGuard;

  bool get _isSupabaseReady => SupabaseConfig().isInitialized;
  SupabaseClient get _supabase => SupabaseConfig().client;

  /// Maximum number of consecutive flush failures before an entry is dropped.
  static const int _maxRetryAttempts = 5;
  static const String _retryPrefix = 'retry_count:';

  Future<void> queueProgressUpsert({
    required String userId,
    required String lessonId,
    required bool completed,
    required int quizScore,
    required int bestScore,
    DateTime? completedAt,
  }) async {
    await _hive.syncQueueBox.put(_progressKey(userId, lessonId), {
      'user_id': userId,
      'lesson_id': lessonId,
      'completed': completed,
      'quiz_score': quizScore,
      'best_score': bestScore,
      'completed_at': completedAt?.toIso8601String(),
    });
  }

  Future<void> queuePointsDelta(String userId, int pointsToAdd) async {
    if (pointsToAdd == 0) return;

    // Serialize access so concurrent callers don't lose increments.
    while (_pointsGuard != null) {
      await _pointsGuard;
    }
    final completer = Completer<void>();
    _pointsGuard = completer.future;
    try {
      final key = _pointsKey(userId);
      final existing = (_hive.syncQueueBox.get(key) as num?)?.toInt() ?? 0;
      await _hive.syncQueueBox.put(key, existing + pointsToAdd);
    } finally {
      _pointsGuard = null;
      completer.complete();
    }
  }

  Future<void> queueStreakUpdate(String userId, int streak) async {
    await _hive.syncQueueBox.put(_streakKey(userId), streak);
  }

  Future<void> queueBadgeAward(String userId, String badgeId) async {
    await _hive.syncQueueBox.put(_badgeKey(userId, badgeId), true);
  }

  Future<int> applyRemotePointsDelta(String userId, int delta) async {
    if (delta == 0) {
      return _hive.usersBox.get(userId)?.totalPoints ?? 0;
    }

    final newPoints = await _invokePointsIncrement(userId, delta);
    await _updateCachedUserPoints(userId, newPoints);
    return newPoints;
  }

  /// Replays all queued mutations for the signed-in user and deletes each
  /// entry on success. Entries that exceed [_maxRetryAttempts] consecutive
  /// failures are dropped to prevent infinite retry loops.
  Future<void> flushPendingForCurrentUser() async {
    if (!_isSupabaseReady) return;

    final currentUserId = SupabaseConfig().currentUser?.id;
    if (currentUserId == null) return;

    final pendingEntries = Map<dynamic, dynamic>.from(_hive.syncQueueBox.toMap());

    for (final entry in pendingEntries.entries) {
      final key = entry.key.toString();
      if (!_belongsToUser(key, currentUserId)) continue;

      try {
        if (key.startsWith('progress:')) {
          if (entry.value is! Map) {
            AppLogger.warning('Dropping malformed progress entry: $key', scope: 'sync_queue');
            await _hive.syncQueueBox.delete(entry.key);
            continue;
          }
          final payload = Map<String, dynamic>.from(entry.value as Map);
          // Validate required fields before sending to Supabase.
          if (payload['user_id'] is! String ||
              payload['lesson_id'] is! String ||
              payload['completed'] is! bool) {
            AppLogger.warning('Dropping invalid progress payload: $key', scope: 'sync_queue');
            await _hive.syncQueueBox.delete(entry.key);
            continue;
          }
          await _supabase.from('user_progress').upsert(
                payload,
                onConflict: 'user_id,lesson_id',
              );
        } else if (key.startsWith('points_delta:')) {
          final delta = (entry.value as num?)?.toInt() ?? 0;
          await applyRemotePointsDelta(currentUserId, delta);
        } else if (key.startsWith('streak:')) {
          final streak = (entry.value as num?)?.toInt() ?? 0;
          await _supabase
              .from('profiles')
              .update({'current_streak': streak}).eq('id', currentUserId);
        } else if (key.startsWith('badge:')) {
          final badgeId = key.split(':').last;
          await _supabase.from('user_badges').upsert(
                {'user_id': currentUserId, 'badge_id': badgeId},
                onConflict: 'user_id,badge_id',
              );
        } else {
          continue;
        }

        await _hive.syncQueueBox.delete(entry.key);
        // Clear retry counter on success.
        await _hive.syncQueueBox.delete('$_retryPrefix$key');
      } catch (e) {
        final retryKey = '$_retryPrefix$key';
        final attempts = ((_hive.syncQueueBox.get(retryKey) as num?)?.toInt() ?? 0) + 1;
        if (attempts >= _maxRetryAttempts) {
          AppLogger.warning(
            'Dropping sync item after $_maxRetryAttempts failures: $key',
            scope: 'sync_queue',
            error: e,
          );
          await _hive.syncQueueBox.delete(entry.key);
          await _hive.syncQueueBox.delete(retryKey);
        } else {
          await _hive.syncQueueBox.put(retryKey, attempts);
          AppLogger.warning(
            'Deferred sync item failed (attempt $attempts/$_maxRetryAttempts)',
            scope: 'sync_queue',
            error: e,
          );
        }
      }
    }
  }

  Future<int> _invokePointsIncrement(String userId, int delta) async {
    final result = await _supabase.rpc(
      'increment_profile_points',
      params: {
        'target_user_id': userId,
        'points_delta': delta,
      },
    );
    return (result as num).toInt();
  }

  Future<void> _updateCachedUserPoints(String userId, int newPoints) async {
    final cachedUser = _hive.usersBox.get(userId);
    if (cachedUser == null) return;

    await _hive.usersBox.put(
      userId,
      cachedUser.copyWith(totalPoints: newPoints),
    );
  }

  bool _belongsToUser(String key, String userId) {
    return key.startsWith('progress:$userId:') ||
        key == _pointsKey(userId) ||
        key == _streakKey(userId) ||
        key.startsWith('badge:$userId:');
  }

  String _progressKey(String userId, String lessonId) =>
      'progress:$userId:$lessonId';
  String _pointsKey(String userId) => 'points_delta:$userId';
  String _streakKey(String userId) => 'streak:$userId';
  String _badgeKey(String userId, String badgeId) => 'badge:$userId:$badgeId';
}
