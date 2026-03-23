import 'package:flutter_test/flutter_test.dart';
import 'package:ready_sg/core/config/app_router.dart';

void main() {
  group('AppRouter.resolveRedirect', () {
    test('always routes to loading when auth state is loading', () {
      final redirect = AppRouter.resolveRedirect(
        isLoading: true,
        isAuthenticated: false,
        path: AppRouter.home,
      );
      expect(redirect, AppRouter.loading);
    });

    test('unauthenticated user is redirected to login for protected route', () {
      final redirect = AppRouter.resolveRedirect(
        isLoading: false,
        isAuthenticated: false,
        path: AppRouter.home,
      );
      expect(redirect, AppRouter.login);
    });

    test('unauthenticated user can access guest emergency route', () {
      final redirect = AppRouter.resolveRedirect(
        isLoading: false,
        isAuthenticated: false,
        path: AppRouter.emergencyGuest,
      );
      expect(redirect, isNull);
    });

    test('unauthenticated user can access guide detail route', () {
      final redirect = AppRouter.resolveRedirect(
        isLoading: false,
        isAuthenticated: false,
        path: '/guide/abc',
      );
      expect(redirect, isNull);
    });

    test('authenticated user is redirected away from login/signup', () {
      final fromLogin = AppRouter.resolveRedirect(
        isLoading: false,
        isAuthenticated: true,
        path: AppRouter.login,
      );
      final fromSignup = AppRouter.resolveRedirect(
        isLoading: false,
        isAuthenticated: true,
        path: AppRouter.signup,
      );
      expect(fromLogin, AppRouter.home);
      expect(fromSignup, AppRouter.home);
    });

    test('loading route resolves to home or login after loading completes', () {
      final authed = AppRouter.resolveRedirect(
        isLoading: false,
        isAuthenticated: true,
        path: AppRouter.loading,
      );
      final guest = AppRouter.resolveRedirect(
        isLoading: false,
        isAuthenticated: false,
        path: AppRouter.loading,
      );
      expect(authed, AppRouter.home);
      expect(guest, AppRouter.login);
    });
  });
}
