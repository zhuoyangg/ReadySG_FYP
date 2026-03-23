import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/types/repository_result.dart';
import '../../../core/utils/app_logger.dart';
import '../data/models/emergency_guide_model.dart';
import '../data/repositories/emergency_guide_repository.dart';

/// Provides emergency guide data to the UI.
/// Serves cached guides instantly and syncs in background.
class EmergencyGuidesProvider extends ChangeNotifier {
  EmergencyGuidesProvider({IEmergencyGuideRepository? repository})
      : _repo = repository ?? EmergencyGuideRepository();

  final IEmergencyGuideRepository _repo;
  bool _hasLoadedOnce = false;

  List<EmergencyGuideModel> _guides = [];
  bool _isLoading = false;
  String? _error;
  bool _syncFailed = false;

  List<EmergencyGuideModel> get guides => _guides;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get syncFailed => _syncFailed;
  bool get hasData => _guides.isNotEmpty;

  /// Loads guides from cache immediately, then syncs in background.
  Future<void> loadGuides() async {
    if (_hasLoadedOnce) {
      _loadCachedGuides();
      notifyListeners();
      unawaited(_syncInBackground());
      return;
    }

    _hasLoadedOnce = true;
    _resetTransientState();
    _loadCachedGuides();
    notifyListeners();
    unawaited(_syncInBackground());
  }

  /// Warms the emergency guide cache for offline use without requiring the UI
  /// to be visible first.
  Future<void> warmCriticalCache() async {
    _hasLoadedOnce = true;
    _resetTransientState();
    _loadCachedGuides();
    notifyListeners();
    unawaited(_syncInBackground());
  }

  /// Forces a full re-sync from Supabase regardless of cache state.
  Future<void> refreshGuides() async {
    _isLoading = true;
    _error = null;
    _syncFailed = false;
    notifyListeners();

    final result = await _repo.syncAllGuidesSafe();
    _applySyncResult(
      result,
      failureMessage: 'Emergency guides refresh failed',
      replaceError: true,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncInBackground() async {
    final result = await _repo.syncAllGuidesSafe();
    _applySyncResult(
      result,
      failureMessage: 'Emergency guides background sync failed',
      surfaceErrorOnlyWithoutData: true,
    );
    notifyListeners();
  }

  void _resetTransientState() {
    _error = null;
    _syncFailed = false;
  }

  void _loadCachedGuides() {
    _guides = _repo.getCachedGuides();
  }

  void _applySyncResult(
    RepositoryResult<List<EmergencyGuideModel>> result, {
    required String failureMessage,
    bool replaceError = false,
    bool surfaceErrorOnlyWithoutData = false,
  }) {
    if (result.isSuccess && result.data != null) {
      _guides = result.data!;
      _syncFailed = false;
      return;
    }

    _syncFailed = true;
    final shouldSurfaceError =
        replaceError || !surfaceErrorOnlyWithoutData || _guides.isEmpty;
    if (shouldSurfaceError) {
      if (replaceError) {
        _error = result.error?.message;
      } else {
        _error ??= result.error?.message;
      }
    }
    AppLogger.warning(
      failureMessage,
      scope: 'emergency_guides',
      error: result.error?.cause,
    );
  }
}
