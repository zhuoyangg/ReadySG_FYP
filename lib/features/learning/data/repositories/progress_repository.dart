import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/hive_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/services/app_clock.dart';
import '../../../../core/services/sync_queue_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/time_ago_formatter.dart';
import '../models/user_progress_model.dart';

abstract class IProgressRepository {
  Map<String, UserProgressModel> getAllLocalProgress(String userId);
  Future<void> syncAllProgressFromRemote(String userId);
}

/// Repository for tracking user lesson progress and quiz scores.
/// Saves locally to Hive immediately and syncs remotely when possible.
class ProgressRepository implements IProgressRepository {
  final HiveConfig _hive = HiveConfig();
  final SyncQueueService _syncQueue = SyncQueueService();

  bool get _isSupabaseReady => SupabaseConfig().isInitialized;
  SupabaseClient get _supabase => SupabaseConfig().client;

  /// Returns locally cached progress for a specific lesson, or null if none.
  UserProgressModel? getLocalProgress(String userId, String lessonId) {
    final key = UserProgressModel.hiveKey(userId, lessonId);
    return _hive.userProgressBox.get(key);
  }

  /// Returns a map of lessonId -> UserProgressModel for all cached progress.
  @override
  Map<String, UserProgressModel> getAllLocalProgress(String userId) {
    final result = <String, UserProgressModel>{};
    for (final entry in _hive.userProgressBox.toMap().entries) {
      final progress = entry.value;
      if (progress.userId == userId) {
        result[progress.lessonId] = progress;
      }
    }
    return result;
  }

  /// Records a completed lesson with quiz score.
  ///
  /// - Saves progress to Hive immediately.
  /// - Upserts to Supabase user_progress if online.
  /// - Updates profiles.total_points in Supabase if online.
  /// - Updates the cached UserModel in Hive.
  ///
  /// Returns the points actually awarded (0 if lesson was already completed
  /// with a higher or equal score).
  Future<int> completeLesson({
    required String userId,
    required String lessonId,
    required int score,
    required int availablePoints,
  }) async {
    final key = UserProgressModel.hiveKey(userId, lessonId);
    final existing = _hive.userProgressBox.get(key);

    final isFirstCompletion = existing == null || !existing.completed;
    final isNewBest = existing == null || score > existing.bestScore;
    final pointsEarned = isFirstCompletion ? availablePoints : 0;

    final progress = UserProgressModel(
      userId: userId,
      lessonId: lessonId,
      completed: true,
      quizScore: score,
      bestScore: isNewBest ? score : existing.bestScore,
      completedAt: existing?.completedAt ?? AppClock.now(),
    );

    await _hive.userProgressBox.put(key, progress);

    await recordDailyQuizAttempt(userId, scorePercent: score);

    if (pointsEarned > 0) {
      final cachedUser = _hive.usersBox.get(userId);
      if (cachedUser != null) {
        await _hive.usersBox.put(
          userId,
          cachedUser.copyWith(
            totalPoints: cachedUser.totalPoints + pointsEarned,
          ),
        );
      }
    }

    // Fire-and-forget: sync runs in background so the UI isn't blocked.
    // Failures are caught internally and queued for later retry.
    unawaited(_syncProgressToRemote(progress, pointsEarned, userId));

    return pointsEarned;
  }

  /// Awards bonus points (e.g. daily challenge completion).
  /// Updates Hive optimistically and syncs the delta remotely when possible.
  Future<void> awardBonusPoints(String userId, int points) async {
    final cachedUser = _hive.usersBox.get(userId);
    if (cachedUser != null) {
      await _hive.usersBox.put(
        userId,
        cachedUser.copyWith(totalPoints: cachedUser.totalPoints + points),
      );
    }
    await _incrementUserPoints(userId, points);
  }

  /// Increments daily quiz counters and sets perfect/high-score flags.
  /// These keys are consumed by [GamificationProvider] for daily challenges.
  Future<void> recordDailyQuizAttempt(
    String userId, {
    required int scorePercent,
  }) async {
    final today = TimeAgoFormatter.dateKey(AppClock.now());
    final countKey = HiveKeys.dailyQuizzes(userId, today);
    final prevCount = (_hive.settingsBox.get(countKey) as int?) ?? 0;
    await _hive.settingsBox.put(countKey, prevCount + 1);
    if (scorePercent == 100) {
      await _hive.settingsBox.put(HiveKeys.dailyPerfect(userId, today), true);
    }
    if (scorePercent >= 80) {
      await _hive.settingsBox.put(HiveKeys.dailyHigh(userId, today), true);
    }
  }

  Future<void> setCurrentStreak(String userId, int streak) async {
    final cachedUser = _hive.usersBox.get(userId);
    if (cachedUser != null) {
      await _hive.usersBox.put(
        userId,
        cachedUser.copyWith(currentStreak: streak),
      );
    }
    await _syncStreakToRemote(userId, streak);
  }

  /// Fetches all progress for this user from Supabase and refreshes Hive cache.
  @override
  Future<void> syncAllProgressFromRemote(String userId) async {
    if (!_isSupabaseReady) return;

    try {
      await _syncQueue.flushPendingForCurrentUser();

      final data = await _supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId);

      for (final row in data as List) {
        final progress = _progressFromRow(row as Map<String, dynamic>);
        final key = UserProgressModel.hiveKey(userId, progress.lessonId);
        await _hive.userProgressBox.put(key, progress);
      }
    } catch (e) {
      AppLogger.warning('Progress sync failed', scope: 'progress', error: e);
    }
  }

  Future<void> _syncProgressToRemote(
    UserProgressModel progress,
    int pointsEarned,
    String userId,
  ) async {
    if (!_isSupabaseReady) {
      await _queueProgressMutation(progress, pointsEarned, userId);
      return;
    }

    try {
      await _supabase.from('user_progress').upsert({
        'user_id': progress.userId,
        'lesson_id': progress.lessonId,
        'completed': progress.completed,
        'quiz_score': progress.quizScore,
        'best_score': progress.bestScore,
        'completed_at': progress.completedAt?.toIso8601String(),
      }, onConflict: 'user_id,lesson_id');

      if (pointsEarned > 0) {
        await _incrementUserPoints(userId, pointsEarned);
      }
    } catch (e) {
      await _queueProgressMutation(progress, pointsEarned, userId);
      AppLogger.warning(
        'Remote progress sync failed',
        scope: 'progress',
        error: e,
      );
    }
  }

  Future<void> _incrementUserPoints(String userId, int pointsToAdd) async {
    if (pointsToAdd == 0) return;
    if (!_isSupabaseReady) {
      await _syncQueue.queuePointsDelta(userId, pointsToAdd);
      return;
    }

    try {
      await _syncQueue.applyRemotePointsDelta(userId, pointsToAdd);
    } catch (e) {
      await _syncQueue.queuePointsDelta(userId, pointsToAdd);
      AppLogger.warning('Points update failed', scope: 'progress', error: e);
    }
  }

  Future<void> _queueProgressMutation(
    UserProgressModel progress,
    int pointsEarned,
    String userId,
  ) async {
    await _syncQueue.queueProgressUpsert(
      userId: progress.userId,
      lessonId: progress.lessonId,
      completed: progress.completed,
      quizScore: progress.quizScore,
      bestScore: progress.bestScore,
      completedAt: progress.completedAt,
    );
    if (pointsEarned > 0) {
      await _syncQueue.queuePointsDelta(userId, pointsEarned);
    }
  }

  UserProgressModel _progressFromRow(Map<String, dynamic> row) {
    return UserProgressModel(
      userId: row['user_id'] as String,
      lessonId: row['lesson_id'] as String,
      completed: row['completed'] as bool? ?? false,
      quizScore: row['quiz_score'] as int? ?? 0,
      bestScore: row['best_score'] as int? ?? 0,
      completedAt: row['completed_at'] != null
          ? DateTime.parse(row['completed_at'] as String)
          : null,
    );
  }

  Future<void> _syncStreakToRemote(String userId, int streak) async {
    if (!_isSupabaseReady) {
      await _syncQueue.queueStreakUpdate(userId, streak);
      return;
    }

    try {
      await _supabase
          .from('profiles')
          .update({'current_streak': streak}).eq('id', userId);
    } catch (e) {
      await _syncQueue.queueStreakUpdate(userId, streak);
      AppLogger.warning('Streak sync failed', scope: 'progress', error: e);
    }
  }

}
