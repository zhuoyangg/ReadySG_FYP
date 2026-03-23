import 'package:flutter/material.dart';

import '../../../core/config/hive_config.dart';
import '../../../core/providers/app_preferences_provider.dart';
import '../../../core/services/app_clock.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/recent_activity_service.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/time_ago_formatter.dart';
import '../../../features/learning/data/models/user_progress_model.dart';
import '../../../features/learning/data/repositories/progress_repository.dart';
import '../data/models/badge_model.dart';
import '../data/repositories/badge_repository.dart';
import '../data/repositories/spaced_practice_repository.dart';

/// Specification for one daily challenge type.
class _ChallengeSpec {
  final String type;
  final String title;
  final String description;
  final int target;
  final int bonusPoints;
  const _ChallengeSpec(
      this.type, this.title, this.description, this.target, this.bonusPoints);
}

const _challenges = [
  _ChallengeSpec('complete_1', 'Daily Learner',
      'Complete any quiz today', 1, 50),
  _ChallengeSpec('perfect_quiz', 'Perfectionist',
      'Score 100% on any quiz today', 1, 75),
  _ChallengeSpec('complete_3', 'Hat Trick',
      'Complete 3 quizzes today', 3, 80),
  _ChallengeSpec('complete_2', 'Double Up',
      'Complete 2 quizzes today', 2, 60),
  _ChallengeSpec('high_score', 'High Achiever',
      'Score 80% or higher on any quiz today', 1, 50),
];

/// Manages badges, streak awareness, and daily challenge state.
///
/// Call [load] once the user is authenticated (e.g. from DashboardScreen).
/// After each lesson/quiz completion, call [load] again to award any new badges
/// and update the daily-challenge flag.
class GamificationProvider extends ChangeNotifier {
  final BadgeRepository _badgeRepo = BadgeRepository();
  final SpacedPracticeRepository _spRepo = SpacedPracticeRepository();
  final ProgressRepository _progressRepo = ProgressRepository();
  final HiveConfig _hive = HiveConfig();
  final RecentActivityService _activityService = RecentActivityService();

  List<BadgeModel> _allBadges = [];
  Set<String> _earnedBadgeIds = {};
  List<BadgeModel> _newlyUnlocked = [];
  _ChallengeSpec? _todayChallenge;
  int _challengeProgress = 0;
  String? _dailyChallengeLessonId;
  String? _dailyChallengeHint;
  bool _isLoading = false;
  bool _syncFailed = false;

  // Getters

  List<BadgeModel> get allBadges => _allBadges;
  Set<String> get earnedBadgeIds => _earnedBadgeIds;
  List<BadgeModel> get earnedBadges =>
      _allBadges.where((b) => _earnedBadgeIds.contains(b.id)).toList();
  List<BadgeModel> get newlyUnlocked => List.unmodifiable(_newlyUnlocked);

  /// Whether today's challenge has been completed.
  bool get dailyChallengeCompleted =>
      _challengeProgress >= (_todayChallenge?.target ?? 1);

  String? get dailyChallengeLessonId => _dailyChallengeLessonId;
  String? get dailyChallengeHint => _dailyChallengeHint;
  bool get isLoading => _isLoading;
  bool get syncFailed => _syncFailed;
  bool get hasData => _allBadges.isNotEmpty;

  // Daily challenge detail getters for the UI.
  String get dailyChallengeTitle => _todayChallenge?.title ?? 'Daily Challenge';
  String get dailyChallengeDescription =>
      _todayChallenge?.description ?? 'Complete a lesson today';
  int get dailyChallengeTarget => _todayChallenge?.target ?? 1;
  int get dailyChallengeBonus => _todayChallenge?.bonusPoints ?? 50;
  int get challengeProgress => _challengeProgress;

  // Actions

  /// Full load: serve cache, check daily challenge, then sync badges remotely
  /// and award any newly earned ones.
  Future<void> load(String userId) async {
    _syncFailed = false;
    _isLoading = false;
    await _reconcileChallengeStreak(userId);

    // 1. Serve cache instantly
    _allBadges = _badgeRepo.getCachedBadges();
    _earnedBadgeIds = _badgeRepo.getCachedEarnedBadgeIds(userId);
    _refreshDailyChallenge(userId);
    await _ensureSpacedPracticeScheduled(userId);
    notifyListeners();

    final skipAutoSync = _allBadges.isNotEmpty &&
        (AppPreferencesProvider.readPreferOfflineCache() ||
            !AppPreferencesProvider.readAutoSyncOnLaunch());

    // 2. Sync badges + earned IDs from Supabase in background
    if (!skipAutoSync) {
      _isLoading = true;
      try {
        _allBadges = await _badgeRepo.syncBadgesFromRemote();
        _earnedBadgeIds = await _badgeRepo.syncEarnedBadgeIds(userId);
        _syncFailed = false;
      } catch (e) {
        _syncFailed = true;
        // Stay on cached data
        AppLogger.warning(
          'Gamification sync failed, using cached data',
          scope: 'gamification',
          error: e,
        );
      } finally {
        _isLoading = false;
      }
    }

    // 3. Check and award newly earned badges
    await _checkAndAwardBadges(userId);

    // 4. Award challenge bonus if newly completed
    if (dailyChallengeCompleted) {
      await _awardChallengeBonus(userId);
    }

    // 5. Schedule notifications
    final dueCount = _spRepo
        .getAllSchedules(userId)
        .where((s) => s.isDue)
        .length;
    await NotificationService().scheduleReviewReminder(dueCount);
    if (dailyChallengeCompleted) {
      await NotificationService().cancelStreakNudge();
    } else {
      await NotificationService().scheduleStreakNudge();
    }

    notifyListeners();
  }

  /// Clear the newly-unlocked badge list after the UI has shown them.
  void clearNewlyUnlocked() {
    _newlyUnlocked = [];
    notifyListeners();
  }

  // Daily challenge

  void _refreshDailyChallenge(String userId) {
    final now = AppClock.now();
    final today = TimeAgoFormatter.dateKey(now);

    // Pick today's challenge by day-of-year so it rotates daily but is stable
    // within a day. Uses modulo of days elapsed since Jan 1.
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    _todayChallenge = _challenges[dayOfYear % _challenges.length];

    // Compute progress from daily counters written by ProgressRepository
    _challengeProgress = _getProgress(userId, today, _todayChallenge!);

    _dailyChallengeLessonId = _computeChallengeLessonId(userId);
    _dailyChallengeHint = _challengeHintFor(_todayChallenge!);
  }

  int _getProgress(String userId, String today, _ChallengeSpec challenge) {
    switch (challenge.type) {
      case 'complete_1':
      case 'complete_2':
      case 'complete_3':
        return (_hive.settingsBox.get(HiveKeys.dailyQuizzes(userId, today)) as int?) ?? 0;
      case 'perfect_quiz':
        return (_hive.settingsBox.get(HiveKeys.dailyPerfect(userId, today)) as bool? ?? false) ? 1 : 0;
      case 'high_score':
        return (_hive.settingsBox.get(HiveKeys.dailyHigh(userId, today)) as bool? ?? false) ? 1 : 0;
      default:
        return 0;
    }
  }

  /// Awards the daily challenge bonus once per day (idempotent).
  Future<void> _awardChallengeBonus(String userId) async {
    final today = TimeAgoFormatter.dateKey(AppClock.now());
    final bonusKey = HiveKeys.dailyChallengeBonus(userId, today);
    final alreadyAwarded = (_hive.settingsBox.get(bonusKey) as bool?) ?? false;
    if (alreadyAwarded) return;

    final bonus = _todayChallenge?.bonusPoints ?? 0;
    if (bonus <= 0) return;

    final streak = await _incrementChallengeStreak(userId, today);
    await _hive.settingsBox.put(bonusKey, true);
    await _progressRepo.awardBonusPoints(userId, bonus);
    await _activityService.logDailyChallengeCompletion(
      userId: userId,
      challengeTitle: dailyChallengeTitle,
      pointsEarned: bonus,
      streakCount: streak,
    );
  }

  /// The daily challenge lesson is the first incomplete lesson across all courses.
  String? _computeChallengeLessonId(String userId) {
    if (_todayChallenge == null) return null;
    switch (_todayChallenge!.type) {
      case 'complete_1':
      case 'complete_2':
      case 'complete_3':
      case 'perfect_quiz':
      case 'high_score':
        return null;
    }
    for (final lesson in _hive.lessonsBox.values) {
      final key = UserProgressModel.hiveKey(userId, lesson.id);
      final progress = _hive.userProgressBox.get(key);
      if (progress == null || !progress.completed) return lesson.id;
    }
    return null;
  }

  String _challengeHintFor(_ChallengeSpec challenge) {
    switch (challenge.type) {
      case 'complete_1':
      case 'complete_2':
      case 'complete_3':
        return 'Practice and lesson quizzes both count. Streaks are earned only from daily challenge completion.';
      case 'perfect_quiz':
      case 'high_score':
        return 'Use Practice or lesson quizzes. Completing today\'s challenge is the only way to earn streak progress.';
      default:
        return 'Complete today\'s challenge to earn streak progress.';
    }
  }

  Future<void> _reconcileChallengeStreak(String userId) async {
    final now = AppClock.now();
    final today = TimeAgoFormatter.startOfDay(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastCompletedRaw =
        _hive.settingsBox.get(HiveKeys.dailyChallengeLastCompleted(userId)) as String?;
    final lastCompleted = lastCompletedRaw == null
        ? null
        : DateTime.tryParse(lastCompletedRaw);

    if (lastCompleted == null) {
      await _progressRepo.setCurrentStreak(userId, 0);
      return;
    }

    final lastDay = TimeAgoFormatter.startOfDay(lastCompleted);
    if (lastDay == today || lastDay == yesterday) {
      return;
    }

    await _progressRepo.setCurrentStreak(userId, 0);
  }

  Future<int> _incrementChallengeStreak(String userId, String today) async {
    final cachedUser = _hive.usersBox.get(userId);
    final current = cachedUser?.currentStreak ?? 0;
    final lastCompletedRaw =
        _hive.settingsBox.get(HiveKeys.dailyChallengeLastCompleted(userId)) as String?;
    final lastCompleted = lastCompletedRaw == null
        ? null
        : DateTime.tryParse(lastCompletedRaw);

    int nextStreak;
    if (lastCompleted == null) {
      nextStreak = 1;
    } else {
      final lastDay = TimeAgoFormatter.startOfDay(lastCompleted);
      final todayDate = TimeAgoFormatter.startOfDay(AppClock.now());
      final yesterday = todayDate.subtract(const Duration(days: 1));
      if (lastDay == todayDate) {
        nextStreak = current;
      } else if (lastDay == yesterday) {
        nextStreak = current + 1;
      } else {
        nextStreak = 1;
      }
    }

    await _progressRepo.setCurrentStreak(userId, nextStreak);
    await _hive.settingsBox.put(HiveKeys.dailyChallengeLastCompleted(userId), today);
    return nextStreak;
  }

  // Spaced practice scheduling

  /// For every completed lesson that has no spaced practice entry yet,
  /// create one. Called lazily on Dashboard load.
  Future<void> _ensureSpacedPracticeScheduled(String userId) async {
    for (final entry in _hive.userProgressBox.toMap().entries) {
      final progress = entry.value;
      if (progress.userId != userId || !progress.completed) continue;
      if (!_spRepo.hasSchedule(userId, progress.lessonId)) {
        await _spRepo.scheduleLesson(
          userId,
          progress.lessonId,
          from: progress.completedAt ?? AppClock.now(),
        );
      }
    }
  }

  // Badge checking

  Future<void> _checkAndAwardBadges(String userId) async {
    if (_allBadges.isEmpty) return;

    // Aggregate stats from local Hive data
    int completedCount = 0;
    int maxScore = 0;
    for (final progress in _hive.userProgressBox.values) {
      if (progress.userId != userId || !progress.completed) continue;
      completedCount++;
      if (progress.bestScore > maxScore) maxScore = progress.bestScore;
    }
    final user = _hive.usersBox.get(userId);
    final streak = user?.currentStreak ?? 0;

    final newlyEarned = <BadgeModel>[];

    for (final badge in _allBadges) {
      if (_earnedBadgeIds.contains(badge.id)) continue;

      final earned = switch (badge.category) {
        'milestone' => completedCount >= badge.threshold,
        'streak' => streak >= badge.threshold,
        'quiz' => maxScore >= badge.threshold,
        _ => false,
      };

      if (earned) {
        await _badgeRepo.awardBadge(userId, badge.id);
        _earnedBadgeIds.add(badge.id);
        newlyEarned.add(badge);
        await _activityService.logBadgeEarned(
          userId: userId,
          badgeName: badge.name,
          pointsEarned: badge.pointsReward,
        );
      }
    }

    if (newlyEarned.isNotEmpty) {
      _newlyUnlocked = [..._newlyUnlocked, ...newlyEarned];
    }
  }

}
