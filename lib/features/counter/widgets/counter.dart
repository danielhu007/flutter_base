import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_base/state/riverpod_providers.dart';

class Counter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final counterNotifier = ref.read(counterProvider.notifier);

    return Column(
      children: [
        Text('Global counter: $counter'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: counterNotifier.decrement,
              child: const Text('-'),
            ),
            TextButton(
              onPressed: counterNotifier.increment,
              child: const Text('+'),
            ),
          ],
        ),
      ],
    );
  }
}
