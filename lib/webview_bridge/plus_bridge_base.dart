import 'package:flutter/material.dart';

abstract class PlusBridgeModule {
  String get jsNamespace;
  Future<dynamic>? handle(String method, dynamic params, BuildContext context);
  String get jsCode;
}
