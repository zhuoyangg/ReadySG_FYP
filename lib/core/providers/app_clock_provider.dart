import 'package:flutter/material.dart';

import '../services/app_clock.dart';

/// Exposes app clock state to the widget tree.
class AppClockProvider extends ChangeNotifier {
  AppClockProvider() {
    AppClock.listenable.addListener(_onClockChanged);
  }

  DateTime get now => AppClock.now();

  DateTime? get overrideTime => AppClock.overrideTime;

  bool get hasOverride => AppClock.hasOverride;

  void setOverride(DateTime value) {
    AppClock.setOverride(value);
  }

  void clearOverride() {
    AppClock.setOverride(null);
  }

  void shiftBy(Duration delta) {
    final base = AppClock.overrideTime ?? DateTime.now();
    AppClock.setOverride(base.add(delta));
  }

  void _onClockChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    AppClock.listenable.removeListener(_onClockChanged);
    super.dispose();
  }
}
