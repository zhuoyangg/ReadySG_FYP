import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/hive_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/types/repository_result.dart';
import '../../../../core/utils/connectivity_utils.dart';
import '../models/emergency_guide_model.dart';

abstract class IEmergencyGuideRepository {
  List<EmergencyGuideModel> getCachedGuides();
  EmergencyGuideModel? getCachedGuide(String id);
  Future<List<EmergencyGuideModel>> syncAllGuides();
  Future<RepositoryResult<List<EmergencyGuideModel>>> syncAllGuidesSafe();
}

/// Repository for emergency guide data.
/// Offline-first: serves Hive cache instantly, syncs from Supabase in background.
class EmergencyGuideRepository implements IEmergencyGuideRepository {
  final HiveConfig _hive = HiveConfig();
  bool get _isSupabaseReady => SupabaseConfig().isInitialized;
  SupabaseClient get _supabase => SupabaseConfig().client;
  // Cache reads

  /// Returns all cached guides sorted by sort_order.
  @override
  List<EmergencyGuideModel> getCachedGuides() {
    return _hive.emergencyGuidesBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Returns a single cached guide by ID, or null if not found.
  @override
  EmergencyGuideModel? getCachedGuide(String id) =>
      _hive.emergencyGuidesBox.get(id);
  // Supabase sync

  /// Fetches all published guides from Supabase and caches them.
  /// Called on first launch (or manual refresh) when online.
  @override
  Future<List<EmergencyGuideModel>> syncAllGuides() async {
    final result = await syncAllGuidesSafe();
    if (result.isSuccess && result.data != null) return result.data!;
    throw Exception(result.error?.message ?? 'Failed to sync emergency guides');
  }

  @override
  Future<RepositoryResult<List<EmergencyGuideModel>>> syncAllGuidesSafe() async {
    if (!_isSupabaseReady) {
      return const RepositoryResult.failure(
        RepositoryError(
          type: RepositoryErrorType.unknown,
          message: 'Guide sync is unavailable while backend services are offline.',
        ),
      );
    }
    if (!await ConnectivityUtils.isOnline()) {
      return const RepositoryResult.failure(
        RepositoryError(
          type: RepositoryErrorType.network,
          message: 'Unable to sync guides. Check your internet connection.',
        ),
      );
    }

    try {
      final data = await _supabase
          .from('emergency_guides')
          .select()
          .eq('is_published', true)
          .order('sort_order');

      final guides = (data as List)
          .map((row) => _guideFromRow(row as Map<String, dynamic>))
          .toList();

      for (final guide in guides) {
        await _hive.emergencyGuidesBox.put(guide.id, guide);
      }

      return RepositoryResult.success(guides);
    } catch (e) {
      final type = mapRepositoryErrorType(e);
      final message = switch (type) {
        RepositoryErrorType.network =>
          'Unable to sync guides. Check your internet connection.',
        RepositoryErrorType.auth =>
          'Guide sync failed due to an authorization error.',
        RepositoryErrorType.schema =>
          'Guide sync failed due to a backend schema mismatch.',
        RepositoryErrorType.unknown => 'Guide sync failed unexpectedly.',
      };
      return RepositoryResult.failure(
        RepositoryError(type: type, message: message, cause: e),
      );
    }
  }
  // Private mapping helper

  EmergencyGuideModel _guideFromRow(Map<String, dynamic> row) {
    return EmergencyGuideModel(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      // content is JSONB - handle List/Map (already parsed) or raw String
      contentJson: row['content'] is String
          ? row['content'] as String
          : jsonEncode(row['content']),
      sortOrder: row['sort_order'] as int? ?? 0,
      isPublished: row['is_published'] as bool,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
