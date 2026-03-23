import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/config/hive_config.dart';
import 'core/config/supabase_config.dart';
import 'core/services/notification_service.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initializeApp();

  runApp(const ReadySGApp());
}

/// Initialize local storage first, then try optional backend services.
Future<void> _initializeApp() async {
  AppLogger.info('Initializing ReadySG...', scope: 'bootstrap');

  AppLogger.info('Initializing Hive database...', scope: 'bootstrap');
  await HiveConfig().initialize();
  AppLogger.info('Hive database initialized', scope: 'bootstrap');

  try {
    AppLogger.info('Loading environment configuration...', scope: 'bootstrap');
    await EnvConfig.initialize();
    AppLogger.info('Environment configuration loaded', scope: 'bootstrap');

    AppLogger.info('Initializing Supabase...', scope: 'bootstrap');
    await SupabaseConfig().initialize();
    AppLogger.info('Supabase initialized', scope: 'bootstrap');
  } catch (e, stackTrace) {
    AppLogger.error(
      'Backend services unavailable; continuing in local-only mode',
      scope: 'bootstrap',
      error: e,
      stackTrace: stackTrace,
    );
  }

  try {
    AppLogger.info('Initializing notifications...', scope: 'bootstrap');
    await NotificationService().initialize();
    AppLogger.info('Notifications initialized', scope: 'bootstrap');
  } catch (e, stackTrace) {
    AppLogger.error(
      'Notifications unavailable; continuing without local reminders',
      scope: 'bootstrap',
      error: e,
      stackTrace: stackTrace,
    );
  }

  AppLogger.info('ReadySG initialized successfully', scope: 'bootstrap');
}
