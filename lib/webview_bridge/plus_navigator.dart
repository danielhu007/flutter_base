// plus_navigator.dart
// H5+ navigator API 桥接接口定义
// 实现了 navigator 相关功能

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'plus_bridge_base.dart';

class PlusNavigator {
  static const MethodChannel _channel = MethodChannel('plus_navigator');

  /// 获取系统状态栏高度
  static Future<double> getStatusbarHeight() async {
    try {
      final result = await _channel.invokeMethod('getStatusbarHeight');
      return result.toDouble();
    } catch (e) {
      // 如果调用失败，返回默认值
      return 20.0;
    }
  }

  /// 设置系统状态栏背景颜色
  /// [color] 颜色字符串，如 #RRGGBB 或 #AARRGGBB
  static Future<void> setStatusBarBackground(String color) async {
    print('PlusNavigator.setStatusBarBackground called with color: $color');
    try {
      // 保存颜色值
      _currentStatusBarColor = color;
      
      if (Platform.isAndroid) {
        // Android 使用 MethodChannel
        await _channel.invokeMethod('setStatusBarBackground', {'color': color});
        print('PlusNavigator.setStatusBarBackground (Android) completed successfully');
      } else if (Platform.isIOS) {
        // iOS 使用 SystemChrome
        final intColor = _parseColor(color);
        if (intColor != null) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Color(intColor),
              statusBarBrightness: _getBrightness(intColor),
              statusBarIconBrightness: _getBrightness(intColor) == Brightness.dark 
                  ? Brightness.light 
                  : Brightness.dark,
            ),
          );
          print('PlusNavigator.setStatusBarBackground (iOS) completed successfully');
        }
      }
    } catch (e) {
      print('PlusNavigator.setStatusBarBackground error: $e');
    }
  }

  /// 解析颜色字符串为整数
  static int? _parseColor(String colorString) {
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF' + hex; // 添加 alpha 通道
      }
      return int.parse(hex, radix: 16);
    } catch (e) {
      print('Error parsing color: $colorString');
      return null;
    }
  }

  /// 根据颜色获取亮度
  static Brightness _getBrightness(int color) {
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;
    final brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return brightness > 0.5 ? Brightness.light : Brightness.dark;
  }

  // 保存当前设置的状态栏颜色
  static String _currentStatusBarColor = '#000000';

  /// 获取系统状态栏背景颜色
  /// 返回颜色字符串
  static Future<String> getStatusBarBackground() async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod('getStatusBarBackground');
        return result.toString();
      } else {
        // iOS 返回保存的颜色值
        return _currentStatusBarColor;
      }
    } catch (e) {
      // 返回默认值
      return '#000000';
    }
  }

  /// 设置系统状态栏样式
  /// [style] 可选值：'light' 或 'dark'
  static Future<void> setStatusBarStyle(String style) async {
    try {
      await _channel.invokeMethod('setStatusBarStyle', {'style': style});
    } catch (e) {
      // 忽略错误
    }
  }

  /// 获取系统状态栏样式
  /// 返回 'light' 或 'dark'
  static Future<String> getStatusBarStyle() async {
    try {
      final result = await _channel.invokeMethod('getStatusBarStyle');
      return result.toString();
    } catch (e) {
      // 返回默认值
      return 'light';
    }
  }

  /// 获取应用的横竖屏状态
  /// 返回 'portrait' 或 'landscape'
  static Future<String> getOrientation() async {
    try {
      final orientation = await NativeDeviceOrientationCommunicator().orientation(useSensor: true);
      if (orientation == NativeDeviceOrientation.portraitUp || orientation == NativeDeviceOrientation.portraitDown) {
        return 'portrait';
      } else if (orientation == NativeDeviceOrientation.landscapeLeft || orientation == NativeDeviceOrientation.landscapeRight) {
        return 'landscape';
      } else {
        return 'portrait';
      }
    } catch (e) {
      return 'portrait';
    }
  }

  /// 判断当前应用是否切换到后台
  /// 返回 true 表示在后台，false 表示在前台
  static Future<bool> isBackground() async {
    try {
      final result = await _channel.invokeMethod('isBackground');
      return result as bool;
    } catch (e) {
      // 默认返回 false (前台)
      return false;
    }
  }
}

class PlusNavigatorModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'navigator';

  @override
  Future<dynamic>? handle(String method, dynamic params, BuildContext context) {
    print('PlusNavigatorModule.handle called with method: $method, params: $params');
    switch (method) {
      case 'getStatusbarHeight':
        return PlusNavigator.getStatusbarHeight();
      case 'setStatusBarBackground': {
        String color = '';
        if (params is String) {
          color = params;
        } else if (params is Map && params['color'] != null) {
          color = params['color'].toString();
        }
        print('PlusNavigatorModule.handle setStatusBarBackground with color: $color');
        return PlusNavigator.setStatusBarBackground(color);
      }
      case 'getStatusBarBackground':
        return PlusNavigator.getStatusBarBackground();
      case 'setStatusBarStyle': {
        String style = '';
        if (params is String) {
          style = params;
        } else if (params is Map && params['style'] != null) {
          style = params['style'].toString();
        }
        return PlusNavigator.setStatusBarStyle(style);
      }
      case 'getStatusBarStyle':
        return PlusNavigator.getStatusBarStyle();
      case 'getOrientation':
        return PlusNavigator.getOrientation();
      case 'isBackground':
        return PlusNavigator.isBackground();
      default:
        return Future.value({'error': 'Unknown navigator method: $method'});
    }
  }

  @override
  String get jsCode => '''
    // plus.navigator 模块注入，兼容 H5+
    window.plus.navigator = {
      getStatusbarHeight: function() {
        return window.flutter_invoke('navigator.getStatusbarHeight');
      },
      setStatusBarBackground: function(color) {
        return window.flutter_invoke('navigator.setStatusBarBackground', { color: color });
      },
      getStatusBarBackground: function() {
        return window.flutter_invoke('navigator.getStatusBarBackground');
      },
      setStatusBarStyle: function(style) {
        return window.flutter_invoke('navigator.setStatusBarStyle', { style: style });
      },
      getStatusBarStyle: function() {
        return window.flutter_invoke('navigator.getStatusBarStyle');
      },
      getOrientation: function() {
        return window.flutter_invoke('navigator.getOrientation');
      },
      isBackground: function() {
        return window.flutter_invoke('navigator.isBackground');
      }
    };
  ''';
} 