import 'package:flutter/material.dart';
import 'package:flutter_base/app/theme/app_theme.dart';
import 'package:flutter_base/features/counter/state/counter_provider.dart';
import 'package:flutter_base/features/posts/repositories/posts_repository.dart';
import 'package:flutter_base/repositories/database/external_repository.dart';
import 'package:flutter_base/repositories/repos.dart';
import 'package:flutter_base/repositories/test.dart';
import 'package:provider/provider.dart';

import '../mocks/mockito.mocks.dart';

class Testable extends StatelessWidget {
  final Widget child;
  final void Function(RepoMocks)? setupServiceMocks;
  final void Function(MockCounterProvider)? setupExampleManager;

  const Testable({
    required this.child,
    required this.setupServiceMocks,
    required this.setupExampleManager,
  });

  @override
  Widget build(BuildContext context) {
    final serviceMocks = RepoMocks();
    final counterProvider = MockCounterProvider();
    setupServiceMocks?.call(serviceMocks);
    setupExampleManager?.call(counterProvider);

    return MaterialApp(
      theme: AppTheme().appThemeLight,
      home: Material(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Test(
            isTested: true,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<Repos>(
                  create: (context) => serviceMocks,
                ),
                ChangeNotifierProvider<CounterProvider>(
                  create: (context) => counterProvider,
                ),
              ],
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class RepoMocks extends ChangeNotifier implements Repos {
  @override
  final PostsRepository posts = MockPostsRepository();

  @override
  final ExternalRepository external = MockExternalRepository();
}
