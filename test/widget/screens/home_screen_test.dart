import 'package:flutter_base/features/home/home_screen.dart';
import 'package:flutter_base/features/posts/models/post_model.dart';
import 'package:flutter_base/models/example_model.dart';
import 'package:mockito/mockito.dart';

import '../helpers.dart';

void main() {
  final externalModel = ExampleModel(name: 'external');
  final postsMocks = [PostModel(title: 'example'), PostModel(title: 'example2')];

  testNormal(
    'HomeScreen',
    widget: HomeScreen(),
    setupServiceMocks: (mocks) {
      when(mocks.external.fetchDummy()).thenAnswer((_) async => externalModel);
      when(mocks.posts.fetchPosts()).thenAnswer((_) async => postsMocks);
    },
    setupExampleManager: (manager) {
      when(manager.count).thenReturn(123);
    },
    body: (tester) async {
      expectTextOnce([
        'Home',
        'Content',
        'isTested = true',
        'Global counter: 123',
      ]);

      await tester.pumpAndSettle();
      expectTextOnce([
        'externalService.fetchDummy() = external',
        'number of fetched posts = 2',
      ]);
    },
  );
}
