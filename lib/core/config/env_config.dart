import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_logger.dart';

/// Environment configuration singleton
/// Prefers compile-time defines and falls back to the bundled .env file.
class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  static const String _supabaseUrlDefine =
      String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKeyDefine =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _appNameDefine = String.fromEnvironment('APP_NAME');
  static const String _appVersionDefine = String.fromEnvironment('APP_VERSION');
  static const String _enableAnalyticsDefine =
      String.fromEnvironment('ENABLE_ANALYTICS');
  static const String _enableCrashReportingDefine =
      String.fromEnvironment('ENABLE_CRASH_REPORTING');

  static bool _initialized = false;
  static bool _dotenvLoaded = false;

  /// Initialize environment configuration
  /// Must be called before accessing any environment variables
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await dotenv.load(fileName: '.env');
      _dotenvLoaded = true;
      AppLogger.info('Loaded bundled .env configuration', scope: 'env');
    } catch (e) {
      try {
        await dotenv.load(fileName: '.env.example');
        _dotenvLoaded = true;
        AppLogger.warning(
          'Bundled .env not found; falling back to .env.example defaults',
          scope: 'env',
          error: e,
        );
      } catch (fallbackError) {
        _dotenvLoaded = false;
        AppLogger.warning(
          'No bundled env asset loaded; using dart-defines if provided',
          scope: 'env',
          error: fallbackError,
        );
      }
    } finally {
      _initialized = true;
    }
  }

  // Supabase Configuration
  String get supabaseUrl => _readString('SUPABASE_URL', _supabaseUrlDefine);
  String get supabaseAnonKey =>
      _readString('SUPABASE_ANON_KEY', _supabaseAnonKeyDefine);

  // App Configuration
  String get appName => _readString('APP_NAME', _appNameDefine, 'ReadySG');
  String get appVersion =>
      _readString('APP_VERSION', _appVersionDefine, '1.0.0');

  // Feature Flags
  bool get enableAnalytics =>
      _readBool('ENABLE_ANALYTICS', _enableAnalyticsDefine);
  bool get enableCrashReporting =>
      _readBool('ENABLE_CRASH_REPORTING', _enableCrashReportingDefine);

  /// Validate that all required environment variables are set
  bool validate() {
    if (supabaseUrl.isEmpty) {
      AppLogger.error(
        'SUPABASE_URL is not set. Provide --dart-define or a bundled .env value.',
        scope: 'env',
      );
      return false;
    }
    if (supabaseAnonKey.isEmpty) {
      AppLogger.error(
        'SUPABASE_ANON_KEY is not set. Provide --dart-define or a bundled .env value.',
        scope: 'env',
      );
      return false;
    }
    return true;
  }

  bool get usesBundledEnvFallback => _dotenvLoaded;

  String _readString(String key, String defineValue, [String fallback = '']) {
    if (defineValue.isNotEmpty) return defineValue;
    return dotenv.env[key] ?? fallback;
  }

  bool _readBool(String key, String defineValue) {
    final raw = _readString(key, defineValue);
    return raw.toLowerCase() == 'true';
  }
}
