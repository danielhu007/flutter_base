import 'dart:io';
import 'package:flutter/material.dart';
import 'plus_bridge_base.dart';

class PlusAndroidModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'android';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    if (!Platform.isAndroid) {
      return {'error': 'Android API is only available on Android platform'};
    }

    switch (method) {
      case 'importClass':
        final className = params is Map ? params['className'] : null;
        if (className != null && className is String) {
          return {'success': true, 'className': className};
        }
        return {'error': 'Invalid class name'};

      case 'newObject':
        final className = params is Map ? params['className'] : null;
        final args = params is Map ? params['args'] : [];
        if (className != null && className is String) {
          return {'success': true, 'className': className, 'args': args};
        }
        return {'error': 'Invalid class name or arguments'};

      case 'invoke':
        final obj = params is Map ? params['object'] : null;
        final methodName = params is Map ? params['methodName'] : null;
        final args = params is Map ? params['args'] : [];
        if (obj != null && methodName != null && methodName is String) {
          return {
            'success': true,
            'object': obj,
            'methodName': methodName,
            'args': args
          };
        }
        return {'error': 'Invalid object or method name'};

      case 'getAttribute':
        final obj = params is Map ? params['object'] : null;
        final fieldName = params is Map ? params['fieldName'] : null;
        if (obj != null && fieldName != null && fieldName is String) {
          return {'success': true, 'object': obj, 'fieldName': fieldName};
        }
        return {'error': 'Invalid object or field name'};

      case 'setAttribute':
        final obj = params is Map ? params['object'] : null;
        final fieldName = params is Map ? params['fieldName'] : null;
        final value = params is Map ? params['value'] : null;
        if (obj != null && fieldName != null && fieldName is String) {
          return {
            'success': true,
            'object': obj,
            'fieldName': fieldName,
            'value': value
          };
        }
        return {'error': 'Invalid object, field name or value'};

      case 'runtimeMainActivity':
        return {'success': true, 'activity': 'MainActivity'};

      case 'currentWebview':
        return {'success': true, 'webview': 'WebView'};

      case 'requestPermissions':
        final permissions = params is Map ? params['permissions'] : [];
        if (permissions is List) {
          return {'success': true, 'permissions': permissions, 'granted': true};
        }
        return {'error': 'Invalid permissions list'};

      case 'autoCollection':
        final instance = params is Map ? params['instance'] : null;
        if (instance != null) {
          return {'success': true, 'instance': instance};
        }
        return {'error': 'Invalid instance'};

      case 'getAvailMem':
        // 模拟获取可用内存
        return {'success': true, 'availMem': 1024 * 1024 * 512}; // 512MB

      default:
        return {'error': 'Unknown android method'};
    }
  }

  @override
  String get jsCode => '''
    // Android 模块 - 通过 JavaScript 直接调用 Android 原生 API
    window.plus.android = {
      // 导入 Java 类
      importClass: function(className) {
        return window.flutter_invoke('android.importClass', {className: className})
          .then(function(result) {
            if (result.error) {
              throw new Error(result.error);
            }
            return {
              className: className,
              toString: function() { return "[JavaClass " + className + "]"; }
            };
          });
      },
      
      // 创建 Java 对象实例
      newObject: function(className, ...args) {
        return window.flutter_invoke('android.newObject', {className: className, args: args})
          .then(function(result) {
            if (result.error) {
              throw new Error(result.error);
            }
            return {
              className: className,
              args: args,
              toString: function() { return "[JavaInstance " + className + "]"; }
            };
          });
      },
      
      // 调用方法
      invoke: function(obj, methodName, ...args) {
        return window.flutter_invoke('android.invoke', {object: obj, methodName: methodName, args: args})
          .then(function(result) {
            if (result.error) {
              throw new Error(result.error);
            }
            return result;
          });
      },
      
      // 获取属性
      getAttribute: function(obj, fieldName) {
        return window.flutter_invoke('android.getAttribute', {object: obj, fieldName: fieldName})
          .then(function(result) {
            if (result.error) {
              throw new Error(result.error);
            }
            return result;
          });
      },
      
      // 设置属性
      setAttribute: function(obj, fieldName, value) {
        return window.flutter_invoke('android.setAttribute', {object: obj, fieldName: fieldName, value: value})
          .then(function(result) {
            if (result.error) {
              throw new Error(result.error);
            }
            return result;
          });
      },
      
      // 获取当前主 Activity
      runtimeMainActivity: function() {
        return window.flutter_invoke('android.runtimeMainActivity', {})
          .then(function(result) {
            if (result.error) {
              throw new Error(result.error);
            }
            return result.activity;
          });
      },
      
      // 获取当前 WebView
      currentWebview: function() {
        return window.flutter_invoke('android.currentWebview', {})
          .then(function(result) {
            if (result.error) {
              throw new Error(result.error);
            }
            return result.webview;
          });
      },
      
      // 请求权限
      requestPermissions: function(permissions, callback) {
        return window.flutter_invoke('android.requestPermissions', {permissions: permissions})
          .then(function(result) {
            if (result.error) {
              throw new Error(result.error);
            }
            if (typeof callback === 'function') {
              callback(result.granted);
            }
            return result.granted;
          });
      },
      
      // 自动回收
      autoCollection: function(instance) {
        return window.flutter_invoke('android.autoCollection', {instance: instance})
          .then(function(result) {
            if (result.error) {
              throw new Error(result.error);
            }
            return result;
          });
      },
      
      // 获取可用内存示例
      getAvailMem: function() {
        return window.flutter_invoke('android.getAvailMem', {})
          .then(function(result) {
            if (result.error) {
              throw new Error(result.error);
            }
            return result.availMem;
          });
      }
    };
    
    // 示例：获取系统可用内存
    function getAvailMem() {
      const Context = plus.android.importClass("android.content.Context");
      const ActivityManager = plus.android.importClass("android.app.ActivityManager");
      const main = plus.android.runtimeMainActivity();
      const am = main.getSystemService(Context.ACTIVITY_SERVICE);
      const mi = plus.android.newObject("android.app.ActivityManager\$MemoryInfo");
      am.getMemoryInfo(mi);
      return plus.android.getAttribute(mi, "availMem");
    }
    
    // 将示例函数挂载到全局
    window.getAvailMem = getAvailMem;
  ''';
}
