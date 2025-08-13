import 'package:flutter/material.dart';
import 'package:flutter_base/utils/logger.dart';

class MyFutureBuilder<T> extends StatelessWidget {
  final log = getLogger(MyFutureBuilder);

  final Future<T> future;
  final Widget Function(T) builder;
  final Widget? onError;
  final Widget? onLoading;

  MyFutureBuilder({
    required this.future,
    required this.builder,
    this.onError,
    this.onLoading,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log.e(snapshot.error);
          return onError ?? const Text('加载失败，请检查网络连接');
        }
        if (snapshot.hasData) {
          return builder(snapshot.data as T);
        }
        return onLoading ?? const Center(child: CircularProgressIndicator());
      },
    );
  }
}
