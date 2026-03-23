import 'package:flutter/material.dart';

/// Semantic color tokens that adapt to Peaceful/Emergency mode.
///
/// Access via `AppSemanticColors.of(context)` which includes a debug
/// assert when the extension is missing and a colorScheme-derived fallback.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.points,
    required this.streak,
    required this.progress,
    required this.achievement,
    required this.callBanner,
    required this.subtleText,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color points;
  final Color streak;
  final Color progress;
  final Color achievement;
  final Color callBanner;
  final Color subtleText;

  /// Peaceful mode palette — calming, learning-oriented.
  factory AppSemanticColors.peaceful() => AppSemanticColors(
        success: Colors.green.shade600,
        warning: Colors.orange,
        danger: Colors.red.shade700,
        points: Colors.amber.shade600,
        streak: Colors.deepOrange,
        progress: Colors.blue.shade600,
        achievement: Colors.purple.shade600,
        callBanner: const Color(0xFF4CAF50),
        subtleText: Colors.grey.shade600,
      );

  /// Emergency mode palette — high-contrast for crisis.
  factory AppSemanticColors.emergency() => AppSemanticColors(
        success: Colors.green.shade400,
        warning: Colors.amber.shade600,
        danger: Colors.red.shade300,
        points: Colors.amber.shade400,
        streak: Colors.deepOrange.shade300,
        progress: Colors.blue.shade300,
        achievement: Colors.purple.shade300,
        callBanner: const Color(0xFF4CAF50),
        subtleText: Colors.grey.shade400,
      );

  /// Retrieve tokens from the nearest Theme, with debug assert and
  /// colorScheme-derived fallback so the app never crashes.
  static AppSemanticColors of(BuildContext context) {
    final ext = Theme.of(context).extension<AppSemanticColors>();
    assert(() {
      if (ext == null) {
        debugPrint(
          'AppSemanticColors: ThemeExtension not registered — using '
          'colorScheme-derived fallback. Register the extension in your '
          'ThemeData to silence this warning.',
        );
      }
      return true;
    }());
    if (ext != null) return ext;

    // Derive reasonable defaults from the current colorScheme so the
    // fallback still looks correct in both light and dark themes.
    final cs = Theme.of(context).colorScheme;
    return AppSemanticColors(
      success: cs.primary,
      warning: cs.secondary,
      danger: cs.error,
      points: cs.secondary,
      streak: cs.secondary,
      progress: cs.primary,
      achievement: cs.tertiary,
      callBanner: const Color(0xFF4CAF50),
      subtleText: cs.onSurface.withValues(alpha: 0.6),
    );
  }

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? points,
    Color? streak,
    Color? progress,
    Color? achievement,
    Color? callBanner,
    Color? subtleText,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      progress: progress ?? this.progress,
      achievement: achievement ?? this.achievement,
      callBanner: callBanner ?? this.callBanner,
      subtleText: subtleText ?? this.subtleText,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      points: Color.lerp(points, other.points, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
      progress: Color.lerp(progress, other.progress, t)!,
      achievement: Color.lerp(achievement, other.achievement, t)!,
      callBanner: Color.lerp(callBanner, other.callBanner, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
    );
  }
}

/// Standard spacing scale used throughout the app.
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Standard sizing constants for layout and accessibility.
abstract class AppSizing {
  /// WCAG 2.2 AA minimum touch target size.
  static const double minTouchTarget = 48.0;

  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;

  static const double avatarSm = 36;
  static const double avatarMd = 48;
  static const double avatarLg = 72;

  static const double cardRadius = 12;
  static const double chipRadius = 20;
}

/// Lightweight responsive scaler for screen-dependent spacing and sizing.
///
/// This is intentionally conservative: it scales relative to a 390dp-wide
/// phone baseline, but clamps the factor so layouts do not become tiny on
/// compact phones or oversized on larger phones.
class AppScale {
  AppScale._(this._factor, this.width, this.height, this.shortestSide);

  final double _factor;
  final double width;
  final double height;
  final double shortestSide;

  static AppScale of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final shortestSide = size.shortestSide;
    final factor = (shortestSide / 390).clamp(0.9, 1.18);
    return AppScale._(factor, size.width, size.height, shortestSide);
  }

  bool get compactWidth => width < 360;
  bool get compactHeight => height < 760;
  bool get compactPhone => compactWidth || compactHeight;
  double get factor => _factor;

  double space(double value) => value * _factor;
  double size(double value) => value * _factor;
  double radius(double value) => value * _factor;
  double icon(double value) => value * _factor;
  double font(double value) => value * _factor;
}
