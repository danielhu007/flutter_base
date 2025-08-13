import 'package:flutter/cupertino.dart';

class Test extends InheritedWidget {
  final bool isTested;

  const Test({
    required super.child,
    required this.isTested,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static Test? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: Test);
  }
}
