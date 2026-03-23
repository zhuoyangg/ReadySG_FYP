import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/config/hive_config.dart';
import 'core/config/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_tokens.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/learning/providers/courses_provider.dart';
import 'features/learning/providers/lessons_provider.dart';
import 'features/emergency/providers/emergency_guides_provider.dart';
import 'features/aed/providers/aed_provider.dart';
import 'features/learning/providers/quiz_provider.dart';
import 'features/mode_switcher/providers/app_mode_provider.dart';
import 'features/gamification/providers/gamification_provider.dart';
import 'features/gamification/providers/spaced_practice_provider.dart';
import 'core/providers/app_clock_provider.dart';
import 'core/providers/app_preferences_provider.dart';
import 'core/services/notification_service.dart';

/// Root application widget
/// Sets up all providers and hands off routing to GoRouter
class ReadySGApp extends StatelessWidget {
  const ReadySGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppModeProvider()),
        ChangeNotifierProvider(create: (_) => CoursesProvider()),
        ChangeNotifierProvider(create: (_) => LessonsProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyGuidesProvider()),
        ChangeNotifierProvider(create: (_) => AEDProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => SpacedPracticeProvider()),
        ChangeNotifierProvider(create: (_) => AppClockProvider()),
        ChangeNotifierProvider(create: (_) => AppPreferencesProvider()),
      ],
      child: const _AppView(),
    );
  }
}

/// Inner view — separated so providers are available in initState via context
class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;
  StreamSubscription<String>? _notificationTapSubscription;

  @override
  void initState() {
    super.initState();

    final authProvider = context.read<AuthProvider>();

    // Build the router once — it holds a reference to authProvider so that
    // every notifyListeners() call re-triggers the redirect logic automatically
    _router = AppRouter.createRouter(authProvider);
    _notificationTapSubscription =
        NotificationService().notificationTapStream.listen((payload) {
      if (!mounted) return;
      if (payload == 'open_home') {
        _router.go(AppRouter.home);
      }
    });

    // Kick off the session check after the first frame so the widget tree is
    // fully built before any notifyListeners() calls reach the router
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider.checkAuthStatus();
      if (HiveConfig().isInitialized) {
        context.read<EmergencyGuidesProvider>().warmCriticalCache();
        context.read<AEDProvider>().warmCriticalCache();
      }
    });
  }

  @override
  void dispose() {
    _notificationTapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer<AppModeProvider> rebuilds only MaterialApp.router when the mode
    // changes — Flutter animates the colour transition between the two themes
    return Consumer2<AppModeProvider, AppPreferencesProvider>(
      builder: (context, modeProvider, preferences, _) {
        return MaterialApp.router(
          key: ValueKey(modeProvider.currentMode),
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          themeAnimationDuration: Duration.zero,
          themeAnimationCurve: Curves.linear,
          theme: AppTheme.getTheme(
            modeProvider.currentMode,
            brightness: Brightness.light,
          ),
          darkTheme: AppTheme.getTheme(
            modeProvider.currentMode,
            brightness: Brightness.dark,
          ),
          themeMode: preferences.darkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            final scale = AppScale.of(context);
            final media = MediaQuery.of(context);
            final accessibilityTextScale = media.textScaler.scale(16) / 16;
            final scaledMedia = media.copyWith(
              textScaler: TextScaler.linear(
                accessibilityTextScale * scale.factor,
              ),
            );

            return MediaQuery(
              data: scaledMedia,
              child: Theme(
                data: AppTheme.scaleTheme(Theme.of(context), context),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          routerConfig: _router,
        );
      },
    );
  }
}
