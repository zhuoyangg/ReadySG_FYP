import 'package:supabase_flutter/supabase_flutter.dart';
import 'env_config.dart';
import '../utils/app_logger.dart';

/// Supabase backend configuration singleton
/// Manages Supabase initialization and provides client access
class SupabaseConfig {
  static final SupabaseConfig _instance = SupabaseConfig._internal();
  factory SupabaseConfig() => _instance;
  SupabaseConfig._internal();

  late SupabaseClient _client;
  SupabaseClient get client => _client;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialize Supabase client
  /// Must be called after EnvConfig.initialize()
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final envConfig = EnvConfig();

      // Validate environment configuration
      if (!envConfig.validate()) {
        throw Exception(
          'Invalid Supabase configuration. Provide SUPABASE_URL and SUPABASE_ANON_KEY with --dart-define or a bundled .env file.',
        );
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: envConfig.supabaseUrl,
        anonKey: envConfig.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType:
              AuthFlowType.pkce, // Proof Key for Code Exchange (more secure)
          autoRefreshToken: true, // Automatically refresh expired tokens
        ),
        debug: false, // Set to true during development for verbose logging
      );

      _client = Supabase.instance.client;
      _initialized = true;

      AppLogger.info('Supabase initialized successfully', scope: 'supabase');
    } catch (e) {
      AppLogger.error(
        'Supabase initialization failed',
        scope: 'supabase',
        error: e,
      );
      rethrow;
    }
  }

  // Helper getters for common Supabase operations

  /// Get auth client for authentication operations
  GoTrueClient get auth => _client.auth;

  /// Get query builder for a specific table
  SupabaseQueryBuilder from(String table) => _client.from(table);

  /// Get storage client for file operations
  SupabaseStorageClient get storage => _client.storage;

  /// Get realtime client for subscriptions
  RealtimeClient get realtime => _client.realtime;

  /// Test Supabase connection
  /// Returns true if connection is successful
  Future<bool> testConnection() async {
    try {
      // Try to fetch a single row from lessons table (or any public table)
      // This will fail gracefully if table doesn't exist yet
      await _client.from('lessons').select('id').limit(1);
      AppLogger.info('Supabase connection test passed', scope: 'supabase');
      return true;
    } catch (e) {
      AppLogger.warning(
        'Supabase connection test failed (expected if tables are not created yet)',
        scope: 'supabase',
        error: e,
      );
      return false;
    }
  }

  /// Sign out current user and clear session
  Future<void> signOut() async {
    await auth.signOut();
    AppLogger.info('User signed out', scope: 'supabase');
  }

  /// Get current user session
  Session? get currentSession => auth.currentSession;

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
