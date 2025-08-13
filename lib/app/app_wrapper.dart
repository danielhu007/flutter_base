import 'package:flutter/material.dart';
import 'package:flutter_base/repositories/test.dart';
import 'package:flutter_base/state/provider_initializer.dart';
import 'package:flutter_base/utils/logger.dart';

class AppWrapper extends StatelessWidget {
  final log = getLogger(AppWrapper);
  final Widget app;

  AppWrapper({required this.app});

  @override
  Widget build(BuildContext context) {
    log.i('Building AppStarter widget');
    return GestureDetector(
      onTap: () {
        // Hide keyboard if tapped outside of form
        final FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild!.unfocus();
        }
      },
      child: Test(
        isTested: false,
        child: ProviderInitializer(
          child: app,
        ),
      ),
    );
  }
}
