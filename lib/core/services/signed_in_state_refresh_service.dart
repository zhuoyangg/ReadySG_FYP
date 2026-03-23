import '../../features/auth/providers/auth_provider.dart';
import '../../features/gamification/providers/gamification_provider.dart';
import '../../features/gamification/providers/spaced_practice_provider.dart';
import 'recent_activity_service.dart';

/// Coordinates the shared refresh sequence used after profile-affecting actions.
class SignedInStateRefreshService {
  SignedInStateRefreshService({
    RecentActivityService? recentActivityService,
  }) : _recentActivityService = recentActivityService ?? RecentActivityService();

  final RecentActivityService _recentActivityService;

  Future<void> refresh({
    required String userId,
    required AuthProvider authProvider,
    GamificationProvider? gamificationProvider,
    SpacedPracticeProvider? spacedPracticeProvider,
  }) async {
    await _recentActivityService.syncWithRemote(userId);
    if (gamificationProvider != null) {
      await gamificationProvider.load(userId);
    }
    await authProvider.refreshCurrentUserFromRemote();
    spacedPracticeProvider?.load(userId);
  }
}
