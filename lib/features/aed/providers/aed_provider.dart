import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/services/location_service.dart';
import '../../../core/types/repository_result.dart';
import '../../../core/utils/app_logger.dart';
import '../data/models/aed_location_model.dart';
import '../data/repositories/aed_repository.dart';

/// State management for AED locations and user position.
///
/// Load flow:
/// 1. Serve Hive cache instantly (non-blocking)
/// 2. Get user GPS position in parallel
/// 3. Background-sync Supabase to Hive
class AEDProvider extends ChangeNotifier {
  AEDProvider({
    IAEDRepository? repository,
    ILocationService? locationService,
  })  : _repo = repository ?? AEDRepository(),
        _locationService = locationService ?? LocationService();

  final IAEDRepository _repo;
  final ILocationService _locationService;

  List<AEDLocationModel> _aeds = [];
  Position? _userPosition;
  bool _isLoading = false;
  bool _isLocating = false;
  String? _error;
  bool _syncFailed = false;
  String? _locationError;
  bool _hasLoadedOnce = false;
  StreamSubscription<Position>? _positionSubscription;

  List<AEDLocationModel> get aeds => _aeds;
  Position? get userPosition => _userPosition;
  bool get isLoading => _isLoading;
  bool get isLocating => _isLocating;
  String? get error => _error;
  bool get syncFailed => _syncFailed;
  bool get hasData => _aeds.isNotEmpty;
  bool get hasLocationError => _locationError != null;
  String? get locationError => _locationError;

  /// AEDs sorted nearest-first. Falls back to insertion order when
  /// user position is unknown.
  List<AEDLocationModel> get sortedByDistance {
    if (_userPosition == null) return _aeds;
    final sorted = List<AEDLocationModel>.from(_aeds);
    sorted.sort((a, b) => _dist(a).compareTo(_dist(b)));
    return sorted;
  }

  /// Distance in metres from the user to [aed].
  /// Returns [double.infinity] when user position is unavailable.
  double distanceTo(AEDLocationModel aed) {
    if (_userPosition == null) return double.infinity;
    return _dist(aed);
  }

  double _dist(AEDLocationModel aed) => Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        aed.latitude,
        aed.longitude,
      );

  bool _isSyncing = false;

  /// Serve cache immediately, optionally get location, and sync in background.
  Future<void> loadAeds({bool fetchLocation = true}) async {
    if (_hasLoadedOnce) {
      if (_loadCachedAedsIfNeeded()) {
        notifyListeners();
      }
      _refreshLocationIfNeeded(fetchLocation);
      if (!_isSyncing) unawaited(_syncInBackground());
      return;
    }

    _hasLoadedOnce = true;
    _resetTransientState();
    if (_loadCachedAedsIfNeeded()) {
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    if (fetchLocation) {
      unawaited(_getUserLocation());
    }
    unawaited(_syncInBackground());
  }

  /// Warms the AED cache for offline emergency use without triggering a GPS
  /// permission prompt during non-emergency app startup.
  Future<void> warmCriticalCache() => loadAeds(fetchLocation: false);

  /// Force a full re-sync from Supabase (pull-to-refresh).
  Future<void> refreshAeds({bool refreshLocation = true}) async {
    _hasLoadedOnce = true;
    _isLoading = true;
    _error = null;
    _syncFailed = false;
    notifyListeners();

    final locationFuture = refreshLocation ? refreshLocationNow() : null;
    final result = await _repo.syncAllAedsSafe();
    _applySyncResult(
      result,
      failureMessage: 'AED refresh failed',
      replaceError: true,
    );
    if (locationFuture != null) {
      await locationFuture;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Re-request the user's current position.
  Future<void> refreshLocationNow() =>
      _resolveUserLocation(clearExistingError: true);

  /// Backwards-compatible alias for callers that already use this name.
  Future<void> refreshLocation() => refreshLocationNow();

  void startLiveLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5,
  }) {
    if (_positionSubscription != null) return;

    _positionSubscription = _locationService
        .getPositionStream(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
        )
        .listen(
          _handleStreamPosition,
          onError: (_) {
            _locationError ??= 'Location permission denied or unavailable';
            _isLocating = false;
            notifyListeners();
          },
        );
  }

  Future<void> stopLiveLocationUpdates() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> _getUserLocation() =>
      _resolveUserLocation(clearExistingError: false);

  Future<void> _resolveUserLocation({
    required bool clearExistingError,
  }) async {
    _isLocating = true;
    if (clearExistingError) {
      _locationError = null;
    }
    notifyListeners();

    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      _userPosition = position;
    }
    _isLocating = false;
    _locationError =
        position == null ? 'Location permission denied or unavailable' : null;
    notifyListeners();
  }

  void _handleStreamPosition(Position position) {
    final previous = _userPosition;
    _isLocating = false;
    _locationError = null;

    if (previous != null) {
      final movedDistance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        position.latitude,
        position.longitude,
      );
      if (movedDistance < 1) {
        return;
      }
    }

    _userPosition = position;
    notifyListeners();
  }

  Future<void> _syncInBackground() async {
    _isSyncing = true;
    try {
      final result = await _repo.syncAllAedsSafe();
      _applySyncResult(result, failureMessage: 'Background AED sync failed');
    } finally {
      _isSyncing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void _resetTransientState() {
    _error = null;
    _syncFailed = false;
    _locationError = null;
  }

  bool _loadCachedAedsIfNeeded() {
    if (_aeds.isNotEmpty) return false;

    final cached = _repo.getCachedAeds();
    if (cached.isEmpty) return false;

    _aeds = cached;
    return true;
  }

  void _refreshLocationIfNeeded(bool fetchLocation) {
    if (!fetchLocation || _userPosition != null || _isLocating) {
      return;
    }
    unawaited(_getUserLocation());
  }

  void _applySyncResult(
    RepositoryResult<List<AEDLocationModel>> result, {
    required String failureMessage,
    bool replaceError = false,
  }) {
    if (result.isSuccess && result.data != null) {
      _aeds = result.data!;
      _syncFailed = false;
      return;
    }

    _syncFailed = true;
    if (replaceError) {
      _error = result.error?.message;
    } else {
      _error ??= result.error?.message;
    }
    AppLogger.warning(
      failureMessage,
      scope: 'aed',
      error: result.error?.cause,
    );
  }

  @override
  void dispose() {
    unawaited(stopLiveLocationUpdates());
    super.dispose();
  }
}
