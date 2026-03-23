import 'package:flutter/foundation.dart';

import '../../../core/services/sync_queue_service.dart';
import '../../../core/utils/app_logger.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

enum SignUpFlowResult {
  signedIn,
  emailConfirmationRequired,
  failed,
}

/// Authentication provider
/// Manages authentication state using Provider package
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final SyncQueueService _syncQueue = SyncQueueService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Check authentication status on app start
  /// Attempts to retrieve user from local storage
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _clearStatusMessages();

    try {
      final user = await _authRepository.getCurrentUser();
      _currentUser = user;
      await _flushPendingSyncsIfNeeded();
      notifyListeners();
    } catch (e) {
      _setError(_toUserFriendlyError(e));
      AppLogger.warning('Auth check failed', scope: 'auth_provider', error: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up a new user
  Future<SignUpFlowResult> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    _setLoading(true);
    _clearStatusMessages();

    try {
      final result = await _authRepository.signUp(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
      );

      switch (result.status) {
        case AuthSignUpStatus.signedIn:
          _currentUser = result.user;
          await _flushPendingSyncsIfNeeded();
          notifyListeners();
          return SignUpFlowResult.signedIn;
        case AuthSignUpStatus.emailConfirmationRequired:
          _currentUser = null;
          _setInfo(result.message);
          notifyListeners();
          return SignUpFlowResult.emailConfirmationRequired;
      }
    } catch (e) {
      _setError(_toUserFriendlyError(e));
      AppLogger.warning('Sign up failed', scope: 'auth_provider', error: e);
      return SignUpFlowResult.failed;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in an existing user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearStatusMessages();

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      _currentUser = user;
      await _flushPendingSyncsIfNeeded();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_toUserFriendlyError(e));
      AppLogger.warning('Sign in failed', scope: 'auth_provider', error: e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _setLoading(true);
    _clearStatusMessages();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(_toUserFriendlyError(e));
      AppLogger.warning('Sign out failed', scope: 'auth_provider', error: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    _clearStatusMessages();

    try {
      final updatedUser = await _authRepository.updateProfile(
        username: username,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_toUserFriendlyError(e));
      AppLogger.warning(
        'Profile update failed',
        scope: 'auth_provider',
        error: e,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reload the current user from local cache (e.g. after points update).
  Future<void> reloadUser() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  /// Pull the latest profile fields from Supabase into local cache.
  Future<void> refreshCurrentUserFromRemote() async {
    final user = await _authRepository.refreshCurrentUserFromRemote();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  void clearMessages() {
    _clearStatusMessages();
  }

  // Private helper methods

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setInfo(String message) {
    _infoMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearStatusMessages() {
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  Future<void> _flushPendingSyncsIfNeeded() async {
    if (_currentUser == null) return;

    try {
      await _syncQueue.flushPendingForCurrentUser();
      final refreshedUser = await _authRepository.getCurrentUser();
      if (refreshedUser != null) {
        _currentUser = refreshedUser;
      }
    } catch (e) {
      AppLogger.warning(
        'Deferred sync flush failed',
        scope: 'auth_provider',
        error: e,
      );
    }
  }

  String _toUserFriendlyError(Object error) {
    final message =
        error.toString().replaceAll('Exception: ', '').toLowerCase();

    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('errno = 7') ||
        message.contains('network is unreachable')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (message.contains('timed out') || message.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }

    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }

    if (message.contains('user already registered')) {
      return 'An account with this email already exists.';
    }

    if (message.contains('email not confirmed')) {
      return 'Please confirm your email address before signing in.';
    }

    if (message.contains('jwt') || message.contains('token')) {
      return 'Your session is invalid or expired. Please sign in again.';
    }

    return 'Something went wrong. Please try again.';
  }
}
