import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/hive_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/app_clock.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_model.dart';

enum AuthSignUpStatus {
  signedIn,
  emailConfirmationRequired,
}

class AuthSignUpResult {
  final AuthSignUpStatus status;
  final UserModel? user;
  final String message;

  const AuthSignUpResult({
    required this.status,
    required this.message,
    this.user,
  });
}

/// Authentication repository
/// Handles all authentication operations with Supabase and local storage
class AuthRepository {
  final HiveConfig _hive = HiveConfig();
  SupabaseClient get _supabase => SupabaseConfig().client;
  bool get _isSupabaseReady => SupabaseConfig().isInitialized;
  bool get _hasActiveSession =>
      _supabase.auth.currentSession != null && _supabase.auth.currentUser != null;

  // Storage keys
  static const String _currentUserIdKey = 'current_user_id';

  /// Sign up a new user
  /// Creates a Supabase auth user and only establishes an app session when a
  /// real Supabase session exists.
  Future<AuthSignUpResult> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    if (!_isSupabaseReady) {
      throw Exception('Supabase is not initialized');
    }
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          if (fullName != null && fullName.trim().isNotEmpty)
            'full_name': fullName.trim(),
        },
      );

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      if (response.session == null) {
        return const AuthSignUpResult(
          status: AuthSignUpStatus.emailConfirmationRequired,
          message:
              'Account created. Check your email to verify your account before signing in.',
        );
      }

      final user = await _loadOrCreateProfileForUser(response.user!);
      await _saveUserLocally(user);

      return AuthSignUpResult(
        status: AuthSignUpStatus.signedIn,
        user: user,
        message: 'Account created successfully.',
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in an existing user
  /// Retrieves user from Supabase and saves session locally
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (!_isSupabaseReady) {
      throw Exception('Supabase is not initialized');
    }
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Invalid credentials');
      }

      final user = await _loadOrCreateProfileForUser(response.user!);
      await _saveUserLocally(user);
      return user;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign out current user
  /// Clears session from Supabase and local storage
  Future<void> signOut() async {
    if (!_isSupabaseReady) {
      await _clearUserLocally();
      return;
    }
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      AppLogger.warning(
        'Remote sign-out failed; clearing local session anyway',
        scope: 'auth',
        error: e,
      );
    }

    await _clearUserLocally();
  }

  /// Get current user from local storage
  /// Returns null if no user is logged in
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _getCachedUser();
      if (user == null) return null;
      if (!_isSupabaseReady) {
        return user;
      }

      if (!_hasActiveSession) {
        await _clearUserLocally();
        return null;
      }

      return user;
    } catch (e) {
      AppLogger.warning('Failed to get current user', scope: 'auth', error: e);
      return null;
    }
  }

  /// Fetch the current user's latest profile from Supabase and refresh Hive.
  /// Falls back to the cached user when offline or backend services are down.
  Future<UserModel?> refreshCurrentUserFromRemote() async {
    try {
      final cachedUser = _getCachedUser();
      if (cachedUser == null) return null;
      if (!_isSupabaseReady) return cachedUser;

      if (!_hasActiveSession) {
        await _clearUserLocally();
        return null;
      }

      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', cachedUser.id)
          .maybeSingle();

      if (profileData == null) return cachedUser;

      final refreshedUser = _userFromProfileData(
        profileData,
        email: cachedUser.email,
      );

      await _saveUserLocally(refreshedUser);
      return refreshedUser;
    } catch (e) {
      AppLogger.warning(
        'Failed to refresh current user from remote',
        scope: 'auth',
        error: e,
      );
      return getCurrentUser();
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    if (!_isSupabaseReady) {
      throw Exception('Supabase is not initialized');
    }
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase.from('profiles').update(updates).eq('id', currentUser.id);

      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();

      final updatedUser = _userFromProfileData(
        profileData,
        email: currentUser.email,
      );

      await _saveUserLocally(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  /// Save user to local storage (Hive)
  Future<void> _saveUserLocally(UserModel user) async {
    await _hive.usersBox.put(user.id, user);
    await _hive.authBox.put(_currentUserIdKey, user.id);
  }

  Future<UserModel> _loadOrCreateProfileForUser(User authUser) async {
    final profileData = await _supabase
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (profileData != null) {
      return _userFromProfileData(
        profileData,
        email: authUser.email ?? '',
      );
    }

    AppLogger.warning(
      'Profile missing for authenticated user, creating fallback profile',
      scope: 'auth',
    );

    await _supabase.from('profiles').insert({
      'id': authUser.id,
      'username': _resolveUsername(authUser),
      'full_name': _resolveFullName(authUser),
      'total_points': 0,
      'current_streak': 0,
      'created_at': AppClock.now().toIso8601String(),
    });

    final createdProfile = await _supabase
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .single();

    return _userFromProfileData(
      createdProfile,
      email: authUser.email ?? '',
    );
  }

  UserModel _userFromProfileData(
    Map<String, dynamic> profileData, {
    required String email,
  }) {
    return UserModel(
      id: profileData['id'],
      email: email,
      username: profileData['username'],
      fullName: profileData['full_name'],
      avatarUrl: profileData['avatar_url'],
      totalPoints: profileData['total_points'] ?? 0,
      currentStreak: profileData['current_streak'] ?? 0,
      createdAt: DateTime.parse(profileData['created_at']),
    );
  }

  String _resolveUsername(User authUser) {
    final metadataUsername = authUser.userMetadata?['username'] as String?;
    if (metadataUsername != null && metadataUsername.trim().isNotEmpty) {
      return metadataUsername.trim();
    }

    final email = authUser.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'user_${authUser.id.substring(0, 8)}';
  }

  String? _resolveFullName(User authUser) {
    final fullName = authUser.userMetadata?['full_name'] as String?;
    if (fullName == null || fullName.trim().isEmpty) {
      return null;
    }
    return fullName.trim();
  }

  UserModel? _getCachedUser() {
    final userId = _hive.authBox.get(_currentUserIdKey);
    if (userId == null) return null;
    return _hive.usersBox.get(userId);
  }

  /// Clear user from local storage
  Future<void> _clearUserLocally() async {
    final userId = _hive.authBox.get(_currentUserIdKey);
    if (userId != null) {
      await _hive.usersBox.delete(userId);
    }
    await _hive.authBox.delete(_currentUserIdKey);
  }

  /// Handle Supabase auth exceptions
  String _handleAuthException(AuthException exception) {
    switch (exception.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password';
      case 'User already registered':
        return 'An account with this email already exists';
      case 'Email not confirmed':
        return 'Please confirm your email address';
      default:
        return exception.message;
    }
  }
}
