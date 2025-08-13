import 'dart:convert';

import 'package:flutter_base/models/example_model.dart';

class ExternalRepository {
  Future<ExampleModel> fetchDummy() async {
    // For example an http call
    await Future.delayed(const Duration(milliseconds: 2000));
    final exampleJson = jsonDecode('{"name": "DummyModel"}') as Map<String, dynamic>;
    return ExampleModel.fromJson(exampleJson);
  }
}
