import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight structured logger with debug gating.
class AppLogger {
  static void info(String message, {String scope = 'app'}) {
    if (!kDebugMode) return;
    developer.log(message, name: scope, level: 800);
  }

  static void warning(String message, {String scope = 'app', Object? error}) {
    if (!kDebugMode) return;
    developer.log(message, name: scope, level: 900, error: error);
  }

  static void error(
    String message, {
    String scope = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    developer.log(
      message,
      name: scope,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
