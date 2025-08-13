import 'package:flutter/material.dart';

/// Colors used in custom widgets that extend the material color scheme
/// called as `context.appColorScheme`
class CustomColorScheme extends ThemeExtension<CustomColorScheme> {
  Color get transparent => Colors.transparent;

  /// Shades of GREY
  /// prefer picking the closest possible, instead of defining a new color
  // static const white = Colors.white;                  <-- USE `context.colorScheme.onPrimary` INSTEAD
  // static Color grey50 = Colors.grey.shade50;          <-- USE `context.colorScheme.surfaceVariant` INSTEAD
  // static Color grey200 = Colors.grey.shade200;        <-- USE `context.colorScheme.outlineVariant` INSTEAD
  // static Color grey900 = Colors.grey.shade900;        <-- USE `context.colorScheme.outline` INSTEAD

  /// Black and White
  Color get black => Colors.black;
  Color get white => Colors.white;

  /// Shades of RED -> Error
  /// prefer picking the closest possible, instead of defining a new color
  // static const error = Colors.red;                    <-- USE `context.colorScheme.error` INSTEAD
  // static final errorContainer = Colors.red.shade50;   <-- USE `context.colorScheme.errorContainer` INSTEAD

  /// Shades of GREEN -> Success
  /// prefer picking the closest possible, instead of defining a new color
  Color get success => Colors.green;
  Color get successContainer => success.withAlpha(34);

  /// Shades of ORANGE -> Warning
  /// prefer picking the closest possible, instead of defining a new color
  Color get warning => Colors.orange;
  Color get warningContainer => warning.withAlpha(34);

  /// Shades of BLUE -> Info
  /// prefer picking the closest possible, instead of defining a new color
  Color get info => Colors.lightBlue;
  Color get infoContainer => info.withAlpha(34);

  /// Other colors
  // static const purple = Colors.purple;
  // ... add more colors

  @override
  ThemeExtension<CustomColorScheme> copyWith() {
    return CustomColorScheme();
  }

  @override
  ThemeExtension<CustomColorScheme> lerp(covariant ThemeExtension<CustomColorScheme>? other, double t) {
    if (other is! CustomColorScheme) {
      return this;
    }
    return CustomColorScheme();
  }
}
