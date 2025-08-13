import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'plus_bridge_base.dart';

class PlusNetworkInfoModule extends PlusBridgeModule {
  // 网络类型常量 - 保持大写命名以兼容 H5+ 规范
  // ignore_for_file: constant_identifier_names
  static const int CONNECTION_UNKNOW = 0; // 未知
  static const int CONNECTION_NONE = 1; // 无网络
  static const int CONNECTION_ETHERNET = 2; // 有线网络
  static const int CONNECTION_WIFI = 3; // Wi-Fi
  static const int CONNECTION_CELL2G = 4; // 2G
  static const int CONNECTION_CELL3G = 5; // 3G
  static const int CONNECTION_CELL4G = 6; // 4G
  static const int CONNECTION_CELL5G = 7; // 5G

  @override
  String get jsNamespace => 'networkinfo';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'getCurrentType':
        return await _getCurrentConnectionType();
      case 'isSetProxy':
        return await _isProxySet();
      case 'ping':
        final url = params is String ? params : (params is Map ? params['url'] : null);
        if (url is String && url.isNotEmpty) {
          return await _pingUrl(url);
        }
        return -1;
      default:
        return {'error': 'Unknown networkinfo method'};
    }
  }

  @override
  String get jsCode => '''
    // plus.networkinfo 模块注入，兼容 H5+
    window.plus.networkinfo = {
      getCurrentType: function() {
        return window.flutter_invoke('networkinfo.getCurrentType');
      },
      isSetProxy: function() {
        return window.flutter_invoke('networkinfo.isSetProxy');
      },
      ping: function(url) {
        return window.flutter_invoke('networkinfo.ping', url);
      }
    };
  ''';
  /// Ping 一个 URL，返回延迟（毫秒），失败返回 -1
  Future<int> _pingUrl(String url) async {
    try {
      final stopwatch = Stopwatch()..start();
      final uri = Uri.parse(url);
      final client = HttpClient();
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      request.persistentConnection = false;
      final response = await request.close();
      await response.drain();
      stopwatch.stop();
      client.close();
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      return -1;
    }
  }

  /// 获取当前网络连接类型
  Future<int> _getCurrentConnectionType() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        return CONNECTION_NONE;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        return CONNECTION_WIFI;
      } else if (connectivityResult == ConnectivityResult.ethernet) {
        return CONNECTION_ETHERNET;
      } else if (connectivityResult == ConnectivityResult.mobile) {
        // 移动网络需要进一步判断是2G/3G/4G/5G
        return await _getMobileNetworkType();
      } else {
        return CONNECTION_UNKNOW;
      }
    } catch (e) {
      return CONNECTION_UNKNOW;
    }
  }

  /// 获取移动网络类型（2G/3G/4G/5G）
  Future<int> _getMobileNetworkType() async {
    // 这里需要根据平台特性来判断具体的移动网络类型
    // 由于 Flutter 的 connectivity_plus 包不提供详细的移动网络类型信息
    // 这里返回一个默认值，实际项目中可能需要使用平台特定的插件

    // Android 可以通过 TelephonyManager 获取网络类型
    // iOS 可以通过 CTTelephonyNetworkInfo 获取网络类型

    // 这里暂时返回 4G 作为默认值
    return CONNECTION_CELL4G;
  }

  /// 检查是否设置了代理
  Future<bool> _isProxySet() async {
    try {
      if (Platform.isAndroid) {
        // Android 4.4+ 仅支持 Wi-Fi 代理检测
        // 这里需要通过系统设置或网络配置来检测代理
        // 由于 Flutter 没有直接提供检测代理的 API，这里返回 false
        // 实际项目中可能需要使用平台通道或特定插件
        return false;
      } else if (Platform.isIOS) {
        // iOS 9.0+ 支持代理检测
        // 同样需要通过系统设置来检测代理
        // 这里返回 false
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
