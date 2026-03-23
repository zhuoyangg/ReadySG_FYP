import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/hive_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/types/repository_result.dart';
import '../../../../core/utils/connectivity_utils.dart';
import '../models/aed_location_model.dart';

/// Contract for AED data sources used by [AEDProvider].
abstract class IAEDRepository {
  List<AEDLocationModel> getCachedAeds();
  Future<List<AEDLocationModel>> syncAllAeds();
  Future<RepositoryResult<List<AEDLocationModel>>> syncAllAedsSafe();
}

/// Offline-first repository for AED locations.
///
/// Flow:
///   1. getCachedAeds() - instant read from Hive (may be empty on first launch)
///   2. syncAllAeds()   - fetch ALL rows from Supabase aed_locations (paginated),
///                        write to Hive, return fresh list
class AEDRepository implements IAEDRepository {
  bool get _isSupabaseReady => SupabaseConfig().isInitialized;
  SupabaseClient get _supabase => SupabaseConfig().client;
  // Cache

  @override
  /// Returns all AEDs currently stored in Hive (empty on first launch).
  List<AEDLocationModel> getCachedAeds() {
    return HiveConfig().aedLocationsBox.values.toList();
  }
  // Supabase sync

  @override
  /// Fetches all AED records from Supabase (paginated, 1000/page),
  /// overwrites Hive cache, and returns the fresh list.
  Future<List<AEDLocationModel>> syncAllAeds() async {
    final result = await syncAllAedsSafe();
    if (result.isSuccess && result.data != null) return result.data!;
    throw Exception(result.error?.message ?? 'Failed to sync AED locations');
  }

  @override
  Future<RepositoryResult<List<AEDLocationModel>>> syncAllAedsSafe() async {
    if (!_isSupabaseReady) {
      return const RepositoryResult.failure(
        RepositoryError(
          type: RepositoryErrorType.unknown,
          message: 'AED sync is unavailable while backend services are offline.',
        ),
      );
    }
    if (!await ConnectivityUtils.isOnline()) {
      return const RepositoryResult.failure(
        RepositoryError(
          type: RepositoryErrorType.network,
          message: 'Unable to sync AED locations. Check your internet connection.',
        ),
      );
    }

    try {
      const pageSize = AppConstants.supabasePageSize;
      const maxPages = 20; // Safety valve: at most 20k rows
      int from = 0;
      final allRows = <Map<String, dynamic>>[];

      for (var page = 0; page < maxPages; page++) {
        final rows = await _supabase
            .from('aed_locations')
            .select()
            .range(from, from + pageSize - 1);

        allRows.addAll(rows);
        if (rows.length < pageSize) break;
        from += pageSize;
      }

      final models = allRows.map(_rowToModel).toList();

      // Batch-write to Hive (putAll is more efficient than individual puts)
      final box = HiveConfig().aedLocationsBox;
      await box.clear();
      await box.putAll({for (final m in models) m.aedId: m});

      return RepositoryResult.success(models);
    } catch (e) {
      final type = mapRepositoryErrorType(e);
      final message = switch (type) {
        RepositoryErrorType.network =>
          'Unable to sync AED locations. Check your internet connection.',
        RepositoryErrorType.auth =>
          'AED sync failed due to an authorization error.',
        RepositoryErrorType.schema =>
          'AED sync failed due to a backend schema mismatch.',
        RepositoryErrorType.unknown => 'AED sync failed unexpectedly.',
      };
      return RepositoryResult.failure(
        RepositoryError(type: type, message: message, cause: e),
      );
    }
  }
  // Mapping

  AEDLocationModel _rowToModel(Map<String, dynamic> row) {
    return AEDLocationModel(
      aedId: row['aed_id'] as String,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      buildingName: row['building_name'] as String? ?? '',
      roadName: row['road_name'] as String? ?? '',
      houseNumber: row['house_number'] as String? ?? '',
      unitNumber: row['unit_number'] as String?,
      postalCode: row['postal_code'] as String? ?? '',
      locationDescription: row['location_description'] as String? ?? '',
      floorLevel: row['floor_level'] as String? ?? '',
      operatingHours: row['operating_hours'] as String? ?? '',
    );
  }
}
