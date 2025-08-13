import 'package:flutter/material.dart';
import 'package:flutter_base/utils/logger.dart';

class ConnectivityChecker {
  static final log = getLogger(ConnectivityChecker);
  static final ConnectivityChecker _instance = ConnectivityChecker._internal();

  factory ConnectivityChecker() => _instance;

  ConnectivityChecker._internal();

  bool _isOnline = true;
  final ValueNotifier<bool> _connectivityNotifier = ValueNotifier<bool>(true);

  ValueNotifier<bool> get connectivityNotifier => _connectivityNotifier;

  bool get isOnline => _isOnline;

  void init() {
    // 这里可以添加实际的网络连接检查逻辑
    // 例如使用 connectivity_plus 包来检查网络状态
    log.i('ConnectivityChecker initialized');

    // 模拟网络状态变化，实际项目中应该使用 connectivity_plus
    // _connectivityStream = Connectivity().onConnectivityChanged.listen((result) {
    //   _updateConnectionStatus(result);
    // });
  }

  void _updateConnectionStatus(dynamic result) {
    // 根据实际的网络状态更新
    // bool wasOnline = _isOnline;
    // _isOnline = result != ConnectivityResult.none;

    // if (wasOnline != _isOnline) {
    //   _connectivityNotifier.value = _isOnline;
    //   log.i('Network status changed: ${_isOnline ? 'Online' : 'Offline'}');
    // }
  }

  void dispose() {
    _connectivityNotifier.dispose();
    // _connectivityStream?.cancel();
    log.i('ConnectivityChecker disposed');
  }
}
