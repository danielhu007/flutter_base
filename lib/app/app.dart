import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base/app/router/route_generator.dart';
import 'package:flutter_base/app/theme/app_theme.dart';
import 'package:flutter_base/utils/extensions/build_context.dart';
import 'package:flutter_base/utils/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class App extends StatelessWidget {
  final log = getLogger(App);

  final String appName = dotenv.get('APP_NAME', fallback: '');
  final bool devicePreview = dotenv.env['DEVICE_PREVIEW'] == 'true';
  final bool productionErrorWidget =
      dotenv.get('PRODUCTION_ERROR_WIDGET', fallback: 'true') == 'true';

  @override
  Widget build(BuildContext context) {
    final Widget Function(BuildContext, Widget?) builder;
    Locale? locale;

    if (devicePreview) {
      log.i('Building the core App widget with DevicePreview');
      builder = DevicePreview.appBuilder;
      locale = DevicePreview.locale(context);
    } else {
      log.i('Building the core App widget');
      builder = (context, widget) {
        if (productionErrorWidget) {
          ErrorWidget.builder = (errorDetails) {
            return const Text('Něco se pokazilo');
          };
        }
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            // iOS only
            statusBarBrightness: Brightness.light,
            // Android only
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarColor: context.customColorScheme.transparent,
            systemNavigationBarColor: context.colorScheme.surface,
          ),
          child: widget ?? const Text('Něco se pokazilo'),
        );
      };
    }

    final app = MaterialApp(
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true, // Necessary for DevicePreview to work
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: AppTheme().appThemeLight,
      locale: locale,
      builder: builder,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generate,
    );

    return devicePreview ? DevicePreview(builder: (_) => app) : app;
  }
}
