import 'package:flutter/material.dart';
import 'package:flutter_base/utils/logger.dart';

class ProviderInitializer extends StatelessWidget {
  final log = getLogger(ProviderInitializer);
  final Widget child;

  ProviderInitializer({required this.child});

  @override
  Widget build(BuildContext context) {
    log.i('Riverpod providers are now initialized globally');
    // Riverpod providers are now defined in riverpod_providers.dart
    // and don't need to be initialized in the widget tree
    return child;
  }
}
