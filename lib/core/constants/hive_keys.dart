/// Centralized Hive key generators for daily counters and challenge state.
///
/// All keys that combine userId + date or userId + entityId live here so that
/// readers and writers always agree on the format.
class HiveKeys {
  const HiveKeys._();

  // Daily quiz counters (written by ProgressRepository, read by GamificationProvider)
  static String dailyQuizzes(String userId, String date) =>
      'daily_quizzes_${userId}_$date';
  static String dailyPerfect(String userId, String date) =>
      'daily_perfect_${userId}_$date';
  static String dailyHigh(String userId, String date) =>
      'daily_high_${userId}_$date';

  // Daily challenge state (written/read by GamificationProvider)
  static String dailyChallengeBonus(String userId, String date) =>
      'daily_challenge_bonus_${userId}_$date';
  static String dailyChallengeLastCompleted(String userId) =>
      'daily_challenge_last_completed_$userId';

  // Earned badges (JSON string list, managed by BadgeRepository)
  static String earnedBadges(String userId) => 'earned_badges_$userId';
}
