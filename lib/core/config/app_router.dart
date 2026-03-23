import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/emergency/presentation/screens/emergency_guide_detail_screen.dart';
import '../../features/emergency/presentation/screens/guest_emergency_screen.dart';
import '../../features/gamification/presentation/screens/badges_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/learning/presentation/screens/completed_lessons_screen.dart';
import '../../features/learning/presentation/screens/course_detail_screen.dart';
import '../../features/learning/presentation/screens/lesson_slide_screen.dart';
import '../../features/learning/presentation/screens/quiz_result_screen.dart';
import '../../features/learning/presentation/screens/quiz_screen.dart';
import '../../shared/widgets/ready_loading_state.dart';

/// Application router.
/// Manages navigation and authentication-based redirects.
class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static const String loading = '/loading';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String course = '/course/:courseId';
  static const String lesson = '/lesson/:id';
  static const String quiz = '/quiz/:lessonId';
  static const String quizResult = '/quiz-result';
  static const String completedLessons = '/completed-lessons';
  static const String badges = '/badges';
  static const String guide = '/guide/:id';
  static const String emergencyGuest = '/emergency-guest';

  static String coursePath(String courseId) => '/course/$courseId';
  static String lessonPath(String id) => '/lesson/$id';
  static String quizPath(String lessonId) => '/quiz/$lessonId';
  static String guidePath(String id) => '/guide/$id';

  /// Pure redirect resolver so routing behavior is unit-testable.
  static String? resolveRedirect({
    required bool isLoading,
    required bool isAuthenticated,
    required String path,
  }) {
    if (isLoading) return loading;
    if (path == loading) return isAuthenticated ? home : login;
    if (!isAuthenticated &&
        !_isAuthOnlyRoute(path) &&
        !_isGuestAccessibleRoute(path)) {
      return login;
    }
    if (isAuthenticated && _isAuthOnlyRoute(path)) return home;
    return null;
  }

  /// Creates a [GoRouter] bound to the given [AuthProvider].
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: home,
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        return resolveRedirect(
          isLoading: authProvider.isLoading,
          isAuthenticated: authProvider.isAuthenticated,
          path: state.uri.path,
        );
      },
      routes: [
        GoRoute(
          path: loading,
          builder: (context, state) => const _LoadingScreen(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: signup,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: course,
          pageBuilder: (context, state) {
            final courseId = state.pathParameters['courseId']!;
            return _slideTransitionPage(
              state: state,
              child: CourseDetailScreen(courseId: courseId),
            );
          },
        ),
        GoRoute(
          path: lesson,
          pageBuilder: (context, state) {
            final lessonId = state.pathParameters['id']!;
            return _slideTransitionPage(
              state: state,
              child: LessonSlideScreen(lessonId: lessonId),
            );
          },
        ),
        GoRoute(
          path: quiz,
          pageBuilder: (context, state) {
            final lessonId = state.pathParameters['lessonId']!;
            return _slideTransitionPage(
              state: state,
              child: QuizScreen(lessonId: lessonId),
            );
          },
        ),
        GoRoute(
          path: quizResult,
          pageBuilder: (context, state) => _slideTransitionPage(
            state: state,
            child: const QuizResultScreen(),
          ),
        ),
        GoRoute(
          path: completedLessons,
          pageBuilder: (context, state) => _slideTransitionPage(
            state: state,
            child: const CompletedLessonsScreen(),
          ),
        ),
        GoRoute(
          path: badges,
          pageBuilder: (context, state) => _slideTransitionPage(
            state: state,
            child: const BadgesScreen(),
          ),
        ),
        GoRoute(
          path: guide,
          pageBuilder: (context, state) {
            final guideId = state.pathParameters['id']!;
            return _slideTransitionPage(
              state: state,
              child: EmergencyGuideDetailScreen(guideId: guideId),
            );
          },
        ),
        GoRoute(
          path: emergencyGuest,
          builder: (context, state) => const GuestEmergencyScreen(),
        ),
      ],
    );
  }

  static bool _isAuthOnlyRoute(String path) => path == login || path == signup;

  static bool _isGuestAccessibleRoute(String path) {
    return path == emergencyGuest || path.startsWith('/guide/');
  }

  /// Builds a [CustomTransitionPage] that slides the new route in from the right.
  static CustomTransitionPage<void> _slideTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

/// Minimal loading screen shown during the initial auth status check.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ReadyLoadingState(label: 'Loading...'),
    );
  }
}
