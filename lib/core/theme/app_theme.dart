import 'package:flutter/material.dart';
import 'peaceful_theme.dart';
import 'emergency_theme.dart';
import 'app_tokens.dart';

/// App Mode Enum
/// Defines the two operational modes of the app
enum AppMode {
  peaceful, // Learning and exploration mode
  emergency, // Crisis response mode
}

/// App Theme Manager
/// Manages theme switching between Peaceful and Emergency modes
class AppTheme {
  /// Get theme based on app mode
  static ThemeData getTheme(
    AppMode mode, {
    Brightness? brightness,
  }) {
    final base = switch (mode) {
      AppMode.peaceful => PeacefulTheme.getTheme(),
      AppMode.emergency => EmergencyTheme.getTheme(),
    };
    final targetBrightness = brightness ?? base.brightness;
    if (base.brightness == targetBrightness) {
      return base;
    }
    return _withBrightness(base, mode, targetBrightness);
  }

  /// Get theme from string representation
  /// Useful for loading persisted mode from local storage
  static ThemeData getThemeFromString(String modeString) {
    final mode = AppMode.values.firstWhere(
      (e) => e.toString() == modeString,
      orElse: () => AppMode.peaceful, // Default to peaceful mode
    );
    return getTheme(mode);
  }

  /// Convert AppMode to string for persistence
  static String modeToString(AppMode mode) {
    return mode.toString();
  }

  /// Convert string to AppMode
  static AppMode stringToMode(String modeString) {
    return AppMode.values.firstWhere(
      (e) => e.toString() == modeString,
      orElse: () => AppMode.peaceful,
    );
  }

  /// Animation duration for theme transitions
  static const Duration transitionDuration = Duration(milliseconds: 300);

  /// Theme transition curve
  static const Curve transitionCurve = Curves.easeInOut;

  /// Apply screen-based scaling to the active theme so shared UI elements
  /// stay proportionate across compact and larger phones.
  static ThemeData scaleTheme(ThemeData base, BuildContext context) {
    final scale = AppScale.of(context);

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        toolbarHeight: _scaleDouble(base.appBarTheme.toolbarHeight, scale),
        iconTheme: _scaleIconTheme(base.appBarTheme.iconTheme, scale),
        actionsIconTheme: _scaleIconTheme(
          base.appBarTheme.actionsIconTheme,
          scale,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        margin: _scaleEdgeInsets(base.cardTheme.margin, scale),
        elevation: _scaleDouble(base.cardTheme.elevation, scale),
        shape: _scaleShapeBorder(base.cardTheme.shape, scale),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _scaleButtonStyle(base.elevatedButtonTheme.style, scale),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _scaleButtonStyle(base.outlinedButtonTheme.style, scale),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _scaleButtonStyle(base.textButtonTheme.style, scale),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _scaleButtonStyle(base.filledButtonTheme.style, scale),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        contentPadding: _scaleEdgeInsets(
          base.inputDecorationTheme.contentPadding,
          scale,
        ),
        border: _scaleInputBorder(base.inputDecorationTheme.border, scale),
        enabledBorder: _scaleInputBorder(
          base.inputDecorationTheme.enabledBorder,
          scale,
        ),
        focusedBorder: _scaleInputBorder(
          base.inputDecorationTheme.focusedBorder,
          scale,
        ),
        errorBorder: _scaleInputBorder(
          base.inputDecorationTheme.errorBorder,
          scale,
        ),
        focusedErrorBorder: _scaleInputBorder(
          base.inputDecorationTheme.focusedErrorBorder,
          scale,
        ),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        elevation: _scaleDouble(base.bottomNavigationBarTheme.elevation, scale),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        iconSize: _scaleDouble(base.floatingActionButtonTheme.iconSize, scale),
        extendedSizeConstraints: _scaleBoxConstraints(
          base.floatingActionButtonTheme.extendedSizeConstraints,
          scale,
        ),
      ),
      iconTheme: _scaleIconTheme(base.iconTheme, scale),
      primaryIconTheme: _scaleIconTheme(base.primaryIconTheme, scale),
      dividerTheme: base.dividerTheme.copyWith(
        thickness: _scaleDouble(base.dividerTheme.thickness, scale),
        space: _scaleDouble(base.dividerTheme.space, scale),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: _scaleEdgeInsets(base.chipTheme.padding, scale),
        shape: _scaleChipShape(base.chipTheme.shape, scale),
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        insetPadding: _scaleEdgeInsets(base.snackBarTheme.insetPadding, scale),
        shape: _scaleShapeBorder(base.snackBarTheme.shape, scale),
      ),
    );
  }

  static ThemeData _withBrightness(
    ThemeData base,
    AppMode mode,
    Brightness brightness,
  ) {
    final seedScheme = ColorScheme.fromSeed(
      seedColor: base.colorScheme.primary,
      brightness: brightness,
    ).copyWith(
      secondary: base.colorScheme.secondary,
      error: base.colorScheme.error,
    );
    final semanticColors = switch (mode) {
      AppMode.peaceful => brightness == Brightness.dark
          ? AppSemanticColors.peaceful().copyWith(
              subtleText: Colors.grey.shade400,
            )
          : AppSemanticColors.peaceful(),
      AppMode.emergency => brightness == Brightness.light
          ? AppSemanticColors.emergency().copyWith(
              subtleText: Colors.grey.shade600,
            )
          : AppSemanticColors.emergency(),
    };
    final textTheme = (brightness == Brightness.dark
            ? Typography.material2021().white
            : Typography.material2021().black)
        .apply(
          bodyColor: seedScheme.onSurface,
          displayColor: seedScheme.onSurface,
        );

    return base.copyWith(
      colorScheme: seedScheme,
      scaffoldBackgroundColor: seedScheme.surface,
      canvasColor: seedScheme.surface,
      cardTheme: base.cardTheme.copyWith(
        color: seedScheme.surface,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: seedScheme.primary,
        foregroundColor: seedScheme.onPrimary,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: seedScheme.surface,
        selectedItemColor: seedScheme.primary,
        unselectedItemColor: seedScheme.onSurface.withValues(alpha: 0.6),
      ),
      iconTheme: base.iconTheme.copyWith(color: seedScheme.onSurface),
      textTheme: textTheme,
      snackBarTheme: base.snackBarTheme.copyWith(
        backgroundColor: seedScheme.inverseSurface,
        contentTextStyle: TextStyle(color: seedScheme.onInverseSurface),
      ),
      extensions: [semanticColors],
    );
  }

  static double? _scaleDouble(double? value, AppScale scale) {
    if (value == null) return null;
    return scale.size(value);
  }

  static IconThemeData? _scaleIconTheme(
    IconThemeData? theme,
    AppScale scale,
  ) {
    if (theme == null) return null;
    return theme.copyWith(size: _scaleDouble(theme.size, scale));
  }

  static EdgeInsets? _scaleEdgeInsets(
    EdgeInsetsGeometry? insets,
    AppScale scale,
  ) {
    if (insets == null) return null;
    final resolved = insets.resolve(TextDirection.ltr);
    return EdgeInsets.fromLTRB(
      scale.space(resolved.left),
      scale.space(resolved.top),
      scale.space(resolved.right),
      scale.space(resolved.bottom),
    );
  }

  static BoxConstraints? _scaleBoxConstraints(
    BoxConstraints? constraints,
    AppScale scale,
  ) {
    if (constraints == null) return null;
    return BoxConstraints(
      minWidth: scale.size(constraints.minWidth),
      maxWidth: constraints.hasBoundedWidth
          ? scale.size(constraints.maxWidth)
          : constraints.maxWidth,
      minHeight: scale.size(constraints.minHeight),
      maxHeight: constraints.hasBoundedHeight
          ? scale.size(constraints.maxHeight)
          : constraints.maxHeight,
    );
  }

  static WidgetStateProperty<T?>? _scaleStateProperty<T>(
    WidgetStateProperty<T?>? property,
    T? Function(T value) scaleValue,
  ) {
    if (property == null) return null;
    return WidgetStateProperty.resolveWith((states) {
      final value = property.resolve(states);
      if (value == null) return null;
      return scaleValue(value);
    });
  }

  static ButtonStyle? _scaleButtonStyle(ButtonStyle? style, AppScale scale) {
    if (style == null) return null;
    return style.copyWith(
      padding: _scaleStateProperty<EdgeInsetsGeometry>(
        style.padding,
        (value) => _scaleEdgeInsets(value, scale)!,
      ),
      minimumSize: _scaleStateProperty<Size>(
        style.minimumSize,
        (value) => Size(scale.size(value.width), scale.size(value.height)),
      ),
      fixedSize: _scaleStateProperty<Size>(
        style.fixedSize,
        (value) => Size(scale.size(value.width), scale.size(value.height)),
      ),
      maximumSize: _scaleStateProperty<Size>(
        style.maximumSize,
        (value) => Size(
          value.width.isFinite ? scale.size(value.width) : value.width,
          value.height.isFinite ? scale.size(value.height) : value.height,
        ),
      ),
      iconSize: _scaleStateProperty<double>(
        style.iconSize,
        (value) => scale.icon(value),
      ),
      elevation: _scaleStateProperty<double>(
        style.elevation,
        (value) => scale.size(value),
      ),
      shape: _scaleStateProperty<OutlinedBorder>(
        style.shape,
        (value) => _scaleOutlinedBorder(value, scale) ?? value,
      ),
    );
  }

  static InputBorder? _scaleInputBorder(InputBorder? border, AppScale scale) {
    if (border == null) return null;
    if (border is OutlineInputBorder) {
      return border.copyWith(
        borderRadius: _scaleBorderRadius(border.borderRadius, scale),
        borderSide: border.borderSide.copyWith(
          width: scale.size(border.borderSide.width),
        ),
      );
    }
    if (border is UnderlineInputBorder) {
      return border.copyWith(
        borderRadius: _scaleBorderRadius(border.borderRadius, scale),
        borderSide: border.borderSide.copyWith(
          width: scale.size(border.borderSide.width),
        ),
      );
    }
    return border;
  }

  static ShapeBorder? _scaleShapeBorder(
    ShapeBorder? shape,
    AppScale scale,
  ) {
    if (shape == null) return null;
    if (shape is RoundedRectangleBorder) {
      return shape.copyWith(
        borderRadius: _scaleBorderRadius(shape.borderRadius, scale),
        side: shape.side.copyWith(width: scale.size(shape.side.width)),
      );
    }
    if (shape is StadiumBorder) {
      return StadiumBorder(
        side: shape.side.copyWith(width: scale.size(shape.side.width)),
      );
    }
    if (shape is ContinuousRectangleBorder) {
      return ContinuousRectangleBorder(
        borderRadius: _scaleBorderRadius(shape.borderRadius, scale),
        side: shape.side.copyWith(width: scale.size(shape.side.width)),
      );
    }
    if (shape is BeveledRectangleBorder) {
      return BeveledRectangleBorder(
        borderRadius: _scaleBorderRadius(shape.borderRadius, scale),
        side: shape.side.copyWith(width: scale.size(shape.side.width)),
      );
    }
    if (shape is CircleBorder) {
      return CircleBorder(
        side: shape.side.copyWith(width: scale.size(shape.side.width)),
      );
    }
    return shape;
  }

  static OutlinedBorder? _scaleOutlinedBorder(
    OutlinedBorder? shape,
    AppScale scale,
  ) {
    final scaled = _scaleShapeBorder(shape, scale);
    return scaled is OutlinedBorder ? scaled : shape;
  }

  static OutlinedBorder? _scaleChipShape(
    OutlinedBorder? shape,
    AppScale scale,
  ) {
    final scaled = _scaleShapeBorder(shape, scale);
    return scaled is OutlinedBorder ? scaled : shape;
  }

  static BorderRadius _scaleBorderRadius(
    BorderRadiusGeometry borderRadius,
    AppScale scale,
  ) {
    final resolved = borderRadius.resolve(TextDirection.ltr);
    Radius scaleRadius(Radius radius) => Radius.elliptical(
          scale.radius(radius.x),
          scale.radius(radius.y),
        );

    return BorderRadius.only(
      topLeft: scaleRadius(resolved.topLeft),
      topRight: scaleRadius(resolved.topRight),
      bottomLeft: scaleRadius(resolved.bottomLeft),
      bottomRight: scaleRadius(resolved.bottomRight),
    );
  }
}

/// Extension to make AppMode easier to work with
extension AppModeExtension on AppMode {
  /// Get human-readable name
  String get displayName {
    switch (this) {
      case AppMode.peaceful:
        return 'Peaceful Mode';
      case AppMode.emergency:
        return 'Emergency Mode';
    }
  }

  /// Get description
  String get description {
    switch (this) {
      case AppMode.peaceful:
        return 'Learning and skill development';
      case AppMode.emergency:
        return 'Crisis response and emergency guides';
    }
  }

  /// Get icon
  IconData get icon {
    switch (this) {
      case AppMode.peaceful:
        return Icons.school;
      case AppMode.emergency:
        return Icons.emergency;
    }
  }

  /// Check if current mode is peaceful
  bool get isPeaceful => this == AppMode.peaceful;

  /// Check if current mode is emergency
  bool get isEmergency => this == AppMode.emergency;
}
