import 'dart:convert';

import 'package:flutter_base/models/example_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ExampleModel fromJson', () {
    const String json = '''
      {
         "name" : "abc"
      }
    ''';

    final ExampleModel exampleModel = ExampleModel.fromJson(jsonDecode(json) as Map<String, dynamic>);

    expect(exampleModel.name, 'abc');
  });
}
