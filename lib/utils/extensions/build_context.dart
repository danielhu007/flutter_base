import 'package:flutter/material.dart';
import 'package:flutter_base/app/theme/extensions/custom_color_scheme.dart';
import 'package:flutter_base/app/theme/extensions/padding_scheme.dart';

extension BuildContextExt on BuildContext {
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;

  // Material theme
  ColorScheme get colorScheme => _theme.colorScheme;
  TextTheme get textTheme => _theme.textTheme;
  ThemeData get _theme => Theme.of(this);

  // Theme extensions
  CustomColorScheme get customColorScheme => _theme.extension<CustomColorScheme>()!;
  PaddingScheme get paddingScheme => _theme.extension<PaddingScheme>()!;
}
