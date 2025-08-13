import 'package:flutter/material.dart';
import 'package:flutter_base/features/counter/state/counter_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testable.dart';

void testNormal(
  String description, {
  required Widget widget,
  required Future<void> Function(WidgetTester) body,
  Function(RepoMocks)? setupServiceMocks,
  Function(CounterProvider)? setupExampleManager,
}) {
  testWidgets(description, (tester) async {
    await dotenv.load(fileName: 'assets/cfg/.env.example');
    await tester.pumpWidget(
      Testable(
        setupServiceMocks: setupServiceMocks,
        setupExampleManager: setupExampleManager,
        child: widget,
      ),
    );
    await body(tester);
  });
}

void expectTextOnce(List<String> texts) {
  for (final String text in texts) {
    expect(find.text(text), findsOneWidget);
  }
}
