import 'package:flutter/foundation.dart';

/// Centralized clock used for time-sensitive features.
///
/// In normal usage it returns system time. For testing, a local override can be
/// set from the debug time controls UI.
class AppClock {
  AppClock._();

  static final ValueNotifier<DateTime?> _overrideNotifier =
      ValueNotifier<DateTime?>(null);

  static DateTime now() => _overrideNotifier.value ?? DateTime.now();

  static DateTime? get overrideTime => _overrideNotifier.value;

  static bool get hasOverride => _overrideNotifier.value != null;

  static void setOverride(DateTime? value) {
    _overrideNotifier.value = value;
  }

  static ValueListenable<DateTime?> get listenable => _overrideNotifier;
}
