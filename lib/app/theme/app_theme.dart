import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base/app/theme/dark_colorscheme.dart';
import 'package:flutter_base/app/theme/extensions/custom_color_scheme.dart';
import 'package:flutter_base/app/theme/extensions/padding_scheme.dart';
import 'package:flutter_base/app/theme/light_colorscheme.dart';
import 'package:flutter_base/app/theme/text_theme.dart';

class AppTheme {
  ThemeData get appThemeLight => _applyCommonSettings(_lightBase).copyWith(
      // Define light theme specific settings here
      );

  ThemeData get appThemeDark => _applyCommonSettings(_darkBase).copyWith(
      // Define dark theme specific settings here
      );

  ThemeData _applyCommonSettings(ThemeData theme) => theme.copyWith(
        // Makes swipe back gesture work on all platforms
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          /*foregroundColor: theme.colorScheme.onPrimary,*/
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        dividerTheme: const DividerThemeData(
          space: 0,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(theme.colorScheme.onPrimary),
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return theme.colorScheme.primary;
            }
            return theme.colorScheme.outlineVariant;
          }),
        ),
        radioTheme: const RadioThemeData(
          visualDensity: VisualDensity.compact,
        ),
        checkboxTheme: CheckboxThemeData(
          shape: const CircleBorder(),
          side: BorderSide(color: theme.colorScheme.outline),
        ),
        cardTheme: const CardThemeData(elevation: 1),
        bottomNavigationBarTheme: theme.bottomNavigationBarTheme.copyWith(
          //elevation: 24, custom shadow needed to be added
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: theme.colorScheme.primary,
          selectedIconTheme: theme.iconTheme.copyWith(
            color: theme.colorScheme.primary,
            fill: 1.0,
          ),
          selectedLabelStyle: theme.textTheme.bodyMedium,
          unselectedLabelStyle: theme.textTheme.bodyMedium,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          // shape: const CircleBorder(),
        ),
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: textTheme.labelLarge,
          backgroundColor: theme.colorScheme.outline,
        ),
      );

  ThemeData get _lightBase => _base(Brightness.light);
  ThemeData get _darkBase => _base(Brightness.dark);

  ThemeData _base(Brightness brightness) {
    final ColorScheme colorScheme =
        brightness == Brightness.light ? flexSchemeLight : flexSchemeDark;

    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      colorScheme: colorScheme,
      extensions: [
        CustomColorScheme(),
        PaddingScheme(),
      ],
    );
  }
}
