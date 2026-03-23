import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity utilities
/// Helper methods to check network connectivity status
class ConnectivityUtils {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device is currently online
  /// Returns true if connected to WiFi or mobile data
  static Future<bool> isOnline() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Get connectivity stream
  /// Monitors connectivity changes and emits boolean values
  /// true = online, false = offline
  static Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map(
      (ConnectivityResult result) => result != ConnectivityResult.none,
    );
  }

  /// Get current connectivity type
  /// Returns the type of connection (wifi, mobile, none, etc.)
  static Future<ConnectivityResult> getConnectivityType() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result;
  }

  /// Check if connected via WiFi
  static Future<bool> isWiFi() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Check if connected via mobile data
  static Future<bool> isMobile() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }
}
