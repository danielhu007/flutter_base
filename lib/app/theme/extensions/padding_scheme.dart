import 'package:flutter/material.dart';

/// Paddings used in custom widgets
/// called as `context.paddingScheme`
class PaddingScheme extends ThemeExtension<PaddingScheme> {
  double get p1 => 4.0;
  double get p2 => 8.0;
  double get p3 => 16.0;
  double get p4 => 24.0;
  double get p5 => 32.0;

  @override
  ThemeExtension<PaddingScheme> copyWith() {
    return PaddingScheme();
  }

  @override
  ThemeExtension<PaddingScheme> lerp(covariant ThemeExtension<PaddingScheme>? other, double t) {
    if (other is! PaddingScheme) {
      return this;
    }
    return PaddingScheme();
  }
}
