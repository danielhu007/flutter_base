import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier(int initialState) : super(initialState);

  void increment() {
    state++;
  }

  void decrement() {
    state--;
  }
}
