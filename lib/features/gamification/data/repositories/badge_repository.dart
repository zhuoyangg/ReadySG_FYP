import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/hive_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/services/sync_queue_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/badge_model.dart';

/// Manages badge definitions (from Supabase) and earned badge tracking.
///
/// Badge definitions are cached in Hive badgesBox.
/// Earned badge IDs are stored as a JSON list in Hive settingsBox
/// (keyed by userId) for fast local lookup; Supabase user_badges is the
/// canonical source and is synced in the background.
class BadgeRepository {
  final HiveConfig _hive = HiveConfig();
  final SyncQueueService _syncQueue = SyncQueueService();
  bool get _isSupabaseReady => SupabaseConfig().isInitialized;
  SupabaseClient get _supabase => SupabaseConfig().client;
  // Badge definitions

  List<BadgeModel> getCachedBadges() =>
      _hive.badgesBox.values.toList()..sort((a, b) => a.threshold.compareTo(b.threshold));

  Future<List<BadgeModel>> syncBadgesFromRemote() async {
    if (!_isSupabaseReady) return getCachedBadges();

    try {
      final rows = await _supabase.from('badges').select().order('threshold');

      final badges = rows.map(_badgeFromRow).toList();

      await _hive.badgesBox.clear();
      final map = {for (final b in badges) b.id: b};
      await _hive.badgesBox.putAll(map);

      return badges;
    } catch (e) {
      AppLogger.warning('Badge sync failed', scope: 'badges', error: e);
      return getCachedBadges();
    }
  }
  // Earned badge IDs

  Set<String> getCachedEarnedBadgeIds(String userId) {
    final raw = _hive.settingsBox.get(HiveKeys.earnedBadges(userId)) as String?;
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return {};
      return Set<String>.from(decoded.whereType<String>());
    } catch (e) {
      AppLogger.warning(
        'Failed to parse cached earned badges for $userId',
        scope: 'badges',
        error: e,
      );
      return {};
    }
  }

  Future<Set<String>> syncEarnedBadgeIds(String userId) async {
    if (!_isSupabaseReady) {
      return getCachedEarnedBadgeIds(userId);
    }

    try {
      final rows = await _supabase
          .from('user_badges')
          .select('badge_id')
          .eq('user_id', userId);

      final ids = rows
          .map((r) => r['badge_id'] as String)
          .toSet();

      await _hive.settingsBox.put(
        HiveKeys.earnedBadges(userId),
        jsonEncode(ids.toList()),
      );

      return ids;
    } catch (e) {
      AppLogger.warning('Earned badge sync failed', scope: 'badges', error: e);
      return getCachedEarnedBadgeIds(userId);
    }
  }

  Future<void> awardBadge(String userId, String badgeId) async {
    // Update local cache immediately
    final current = getCachedEarnedBadgeIds(userId);
    current.add(badgeId);
    await _hive.settingsBox.put(
      HiveKeys.earnedBadges(userId),
      jsonEncode(current.toList()),
    );

    // Sync to Supabase in background
    _upsertUserBadge(userId, badgeId);
  }
  // Private helpers

  Future<void> _upsertUserBadge(String userId, String badgeId) async {
    if (!_isSupabaseReady) {
      await _syncQueue.queueBadgeAward(userId, badgeId);
      return;
    }
    try {
      await _supabase.from('user_badges').upsert(
        {'user_id': userId, 'badge_id': badgeId},
        onConflict: 'user_id,badge_id',
      );
    } catch (e) {
      await _syncQueue.queueBadgeAward(userId, badgeId);
      AppLogger.warning('Badge award sync failed', scope: 'badges', error: e);
    }
  }

  BadgeModel _badgeFromRow(Map<String, dynamic> r) => BadgeModel(
        id: r['id'] as String,
        name: r['name'] as String,
        description: r['description'] as String,
        iconName: r['icon_name'] as String,
        category: r['category'] as String,
        threshold: (r['threshold'] as num).toInt(),
        pointsReward: (r['points_reward'] as num).toInt(),
      );
}
