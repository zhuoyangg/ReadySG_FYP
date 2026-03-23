import 'package:flutter/foundation.dart';
import '../../../core/config/hive_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// App Mode Provider
/// Manages the current app mode (peaceful/emergency) with Hive persistence
/// Extends ChangeNotifier so MaterialApp.router can re-theme on mode change
class AppModeProvider extends ChangeNotifier {
  final HiveConfig _hive = HiveConfig();

  AppMode _currentMode = AppMode.peaceful;

  // Getters
  AppMode get currentMode => _currentMode;
  bool get isPeaceful => _currentMode == AppMode.peaceful;
  bool get isEmergency => _currentMode == AppMode.emergency;

  AppModeProvider() {
    _loadSavedMode();
  }

  /// Load persisted mode from Hive on startup
  void _loadSavedMode() {
    if (!_hive.isInitialized) return;
    final saved = _hive.settingsBox.get(AppConstants.currentModeKey);
    if (saved != null) {
      _currentMode = AppTheme.stringToMode(saved as String);
      // No notifyListeners() — we're in the constructor, UI hasn't built yet
    }
  }

  /// Toggle between peaceful and emergency mode
  Future<void> toggleMode() async {
    _currentMode = _currentMode.isPeaceful ? AppMode.emergency : AppMode.peaceful;
    await _persistMode();
    notifyListeners();
  }

  /// Set a specific mode directly
  Future<void> setMode(AppMode mode) async {
    if (_currentMode == mode) return;
    _currentMode = mode;
    await _persistMode();
    notifyListeners();
  }

  /// Persist current mode to Hive
  Future<void> _persistMode() async {
    if (!_hive.isInitialized) return;
    await _hive.settingsBox.put(
      AppConstants.currentModeKey,
      AppTheme.modeToString(_currentMode),
    );
  }
}
