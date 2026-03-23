import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ready_sg/core/services/location_service.dart';
import 'package:ready_sg/core/types/repository_result.dart';
import 'package:ready_sg/features/aed/data/models/aed_location_model.dart';
import 'package:ready_sg/features/aed/data/repositories/aed_repository.dart';
import 'package:ready_sg/features/aed/providers/aed_provider.dart';

class _FakeAedRepository implements IAEDRepository {
  _FakeAedRepository({
    required this.cached,
    required this.syncHandler,
  });

  final List<AEDLocationModel> cached;
  final Future<List<AEDLocationModel>> Function() syncHandler;

  @override
  List<AEDLocationModel> getCachedAeds() => cached;

  @override
  Future<List<AEDLocationModel>> syncAllAeds() => syncHandler();

  @override
  Future<RepositoryResult<List<AEDLocationModel>>> syncAllAedsSafe() async {
    try {
      final data = await syncHandler();
      return RepositoryResult.success(data);
    } catch (e) {
      return RepositoryResult.failure(
        RepositoryError(
          type: RepositoryErrorType.unknown,
          message: 'Sync failed',
          cause: e,
        ),
      );
    }
  }
}

class _FakeLocationService implements ILocationService {
  _FakeLocationService({
    this.currentPosition,
    Stream<Position>? stream,
  }) : _stream = stream ?? const Stream.empty();

  final Position? currentPosition;
  final Stream<Position> _stream;

  @override
  Future<Position?> getCurrentPosition() async => currentPosition;

  @override
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) =>
      _stream;
}

AEDLocationModel _aed(String id) => AEDLocationModel(
      aedId: id,
      latitude: 1.3000,
      longitude: 103.8000,
      buildingName: 'Building $id',
      roadName: 'Road',
      houseNumber: '1',
      unitNumber: null,
      postalCode: '123456',
      locationDescription: 'Lobby',
      floorLevel: 'L1',
      operatingHours: '24h',
    );

void main() {
  test('AEDProvider serves cached AEDs before background sync completes', () async {
    final syncGate = Completer<void>();
    final repo = _FakeAedRepository(
      cached: [_aed('cached-1')],
      syncHandler: () async {
        await syncGate.future;
        return [_aed('fresh-1')];
      },
    );
    final provider = AEDProvider(
      repository: repo,
      locationService: _FakeLocationService(),
    );

    await provider.loadAeds();

    expect(provider.aeds.length, 1);
    expect(provider.aeds.first.aedId, 'cached-1');
    expect(provider.isLoading, isFalse);

    syncGate.complete();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(provider.aeds.first.aedId, 'fresh-1');
  });

  test('AEDProvider keeps existing data when refresh sync fails', () async {
    final repo = _FakeAedRepository(
      cached: [_aed('cached-1')],
      syncHandler: () async => throw Exception('sync failure'),
    );
    final provider = AEDProvider(
      repository: repo,
      locationService: _FakeLocationService(),
    );

    await provider.loadAeds();
    await provider.refreshAeds();

    expect(provider.aeds.length, 1);
    expect(provider.aeds.first.aedId, 'cached-1');
    expect(provider.isLoading, isFalse);
  });

  test('AEDProvider background sync populates list when cache is empty', () async {
    final repo = _FakeAedRepository(
      cached: const [],
      syncHandler: () async => [_aed('fresh-1'), _aed('fresh-2')],
    );
    final provider = AEDProvider(
      repository: repo,
      locationService: _FakeLocationService(),
    );

    await provider.loadAeds();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(provider.aeds.length, 2);
    expect(provider.isLoading, isFalse);
  });

  test('AEDProvider refreshAeds also refreshes the current location', () async {
    final repo = _FakeAedRepository(
      cached: [_aed('cached-1')],
      syncHandler: () async => [_aed('fresh-1')],
    );
    final position = Position(
      longitude: 103.851959,
      latitude: 1.290270,
      timestamp: DateTime(2026, 3, 23),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 1,
      heading: 0,
      headingAccuracy: 1,
      speed: 0,
      speedAccuracy: 1,
    );
    final provider = AEDProvider(
      repository: repo,
      locationService: _FakeLocationService(currentPosition: position),
    );

    await provider.loadAeds(fetchLocation: false);
    await provider.refreshAeds();

    expect(provider.userPosition, isNotNull);
    expect(provider.userPosition!.latitude, position.latitude);
    expect(provider.userPosition!.longitude, position.longitude);
  });

  test('AEDProvider live location stream updates user position', () async {
    final controller = StreamController<Position>();
    final repo = _FakeAedRepository(
      cached: [_aed('cached-1')],
      syncHandler: () async => [_aed('cached-1')],
    );
    final provider = AEDProvider(
      repository: repo,
      locationService: _FakeLocationService(stream: controller.stream),
    );

    provider.startLiveLocationUpdates();
    controller.add(
      Position(
        longitude: 103.8198,
        latitude: 1.3521,
        timestamp: DateTime(2026, 3, 23, 10),
        accuracy: 5,
        altitude: 0,
        altitudeAccuracy: 1,
        heading: 0,
        headingAccuracy: 1,
        speed: 0,
        speedAccuracy: 1,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(provider.userPosition, isNotNull);
    expect(provider.userPosition!.latitude, 1.3521);
    expect(provider.userPosition!.longitude, 103.8198);

    await provider.stopLiveLocationUpdates();
    await controller.close();
  });
}
