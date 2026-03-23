import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ready_sg/core/types/repository_result.dart';
import 'package:ready_sg/features/emergency/data/models/emergency_guide_model.dart';
import 'package:ready_sg/features/emergency/data/repositories/emergency_guide_repository.dart';
import 'package:ready_sg/features/emergency/providers/emergency_guides_provider.dart';

class _FakeEmergencyGuideRepository implements IEmergencyGuideRepository {
  _FakeEmergencyGuideRepository({
    required this.cached,
    required this.syncHandler,
  });

  final List<EmergencyGuideModel> cached;
  final Future<List<EmergencyGuideModel>> Function() syncHandler;

  @override
  List<EmergencyGuideModel> getCachedGuides() => cached;

  @override
  EmergencyGuideModel? getCachedGuide(String id) {
    for (final guide in cached) {
      if (guide.id == id) return guide;
    }
    return null;
  }

  @override
  Future<List<EmergencyGuideModel>> syncAllGuides() => syncHandler();

  @override
  Future<RepositoryResult<List<EmergencyGuideModel>>> syncAllGuidesSafe() async {
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

EmergencyGuideModel _guide(String id) => EmergencyGuideModel(
      id: id,
      title: 'Guide $id',
      description: 'Description',
      contentJson: '[{"type":"text","title":"Step","body":"Do this"}]',
      sortOrder: 1,
      isPublished: true,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  test(
    'EmergencyGuidesProvider serves cached guides before background sync completes',
    () async {
      final syncGate = Completer<void>();
      final repo = _FakeEmergencyGuideRepository(
        cached: [_guide('cached-1')],
        syncHandler: () async {
          await syncGate.future;
          return [_guide('fresh-1')];
        },
      );
      final provider = EmergencyGuidesProvider(repository: repo);

      await provider.loadGuides();

      expect(provider.guides.length, 1);
      expect(provider.guides.first.id, 'cached-1');
      expect(provider.error, isNull);

      syncGate.complete();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(provider.guides.first.id, 'fresh-1');
    },
  );

  test('EmergencyGuidesProvider keeps existing data when refresh sync fails', () async {
    final repo = _FakeEmergencyGuideRepository(
      cached: [_guide('cached-1')],
      syncHandler: () async => throw Exception('sync failure'),
    );
    final provider = EmergencyGuidesProvider(repository: repo);

    await provider.loadGuides();
    await provider.refreshGuides();

    expect(provider.guides.length, 1);
    expect(provider.guides.first.id, 'cached-1');
    expect(provider.isLoading, isFalse);
    expect(provider.error, isNotNull);
  });

  test(
    'EmergencyGuidesProvider surfaces error when cache is empty and background sync fails',
    () async {
      final repo = _FakeEmergencyGuideRepository(
        cached: const [],
        syncHandler: () async => throw Exception('sync failure'),
      );
      final provider = EmergencyGuidesProvider(repository: repo);

      await provider.loadGuides();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.guides, isEmpty);
      expect(provider.error, isNotNull);
    },
  );
}
