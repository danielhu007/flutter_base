import 'package:flutter/material.dart';

final textTheme = TextTheme(
  displayLarge: _font(size: 40, weight: FontWeight.w400),
  // Pin keyboard
  displayMedium: _font(size: 24, weight: FontWeight.w500),
  // Account name
  displaySmall: _font(size: 24, weight: FontWeight.w300),
  // Pin action
  //
  titleLarge: _font(size: 20, weight: FontWeight.w500),
  // Default AppBar style
  titleMedium: _font(size: 20, weight: FontWeight.w400),
  // Dialog title, Drawer title
  titleSmall: _font(size: 14, weight: FontWeight.w700),
  // AboutUs screen titles
  //
  headlineLarge: _undefinedFont,
  headlineMedium: _font(size: 16, weight: FontWeight.w500),
  // Dashboard section, Tile descriptions
  headlineSmall: _font(size: 15, weight: FontWeight.w500),
  // Gallery section
  //
  labelLarge: _font(size: 14, weight: FontWeight.w500),
  // Active tabs, Dashboard table labels
  labelMedium: _font(size: 14, weight: FontWeight.w400),
  // Form field name
  labelSmall: _font(size: 12, weight: FontWeight.w700),
  // Dashboard field status
  //
  bodyLarge: _font(size: 12, weight: FontWeight.w500),
  // Inactive tabs, Dashboard tabs
  bodyMedium: _font(size: 12, weight: FontWeight.w400),
  // Default Text style
  bodySmall: _font(size: 10, weight: FontWeight.w400), // Badge, AppointmentCard metadata
);

const TextStyle _undefinedFont = TextStyle(
  fontSize: 12,
  color: Colors.purple,
  fontWeight: FontWeight.w900,
  fontStyle: FontStyle.italic,
);

TextStyle _font({required double size, required FontWeight weight}) => TextStyle(fontSize: size, fontWeight: weight);
