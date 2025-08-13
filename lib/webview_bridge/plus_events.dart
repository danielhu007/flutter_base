import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'plus_bridge_base.dart';

class PlusEventsModule extends PlusBridgeModule {
  final Map<String, List<String>> _eventCallbacks = {};
  InAppWebViewController? _webViewController;

  @override
  String get jsNamespace => 'events';

  // 设置WebView控制器，用于向JS发送事件
  void setWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
  }

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'addEventListener':
        final event = params is Map ? params['event'] : null;
        final callbackId = params is Map ? params['callbackId'] : null;
        if (event != null && callbackId != null) {
          _eventCallbacks.putIfAbsent(event, () => []).add(callbackId);
          return true;
        }
        return false;

      case 'removeEventListener':
        final event = params is Map ? params['event'] : null;
        final callbackId = params is Map ? params['callbackId'] : null;
        if (event != null && callbackId != null) {
          _eventCallbacks[event]?.remove(callbackId);
          return true;
        }
        return false;

      case 'fireEvent':
        final event = params is Map ? params['event'] : null;
        final data = params is Map ? params['data'] : null;
        if (event != null) {
          await _fireEventToJS(event, data);
          return {
            'event': event,
            'data': data,
            'callbacks': _eventCallbacks[event] ?? []
          };
        }
        return false;

      default:
        return {'error': 'Unknown events method'};
    }
  }

  // 从Flutter侧触发事件到JS侧
  Future<void> fireEventFromFlutter(
      String event, Map<String, dynamic>? data) async {
    await _fireEventToJS(event, data);
  }

  // 向JS发送事件
  Future<void> _fireEventToJS(String event, dynamic data) async {
    if (_webViewController == null) return;

    final callbacks = _eventCallbacks[event] ?? [];
    if (callbacks.isEmpty) return;

    for (String callbackId in callbacks) {
      try {
        await _webViewController!.evaluateJavascript(source: '''
          (function() {
            if (window.plusEventCallbacks && window.plusEventCallbacks['$callbackId']) {
              try {
                window.plusEventCallbacks['$callbackId']($data);
              } catch (e) {
                console.error('Event callback error:', e);
              }
            }
          })();
        ''');
      } catch (e) {
        print('Failed to fire event $event to JS: $e');
      }
    }
  }

  // 提供事件触发接口，供 WebViewBridge 调用
  List<String> getCallbacks(String event) => _eventCallbacks[event] ?? [];

  // 清除所有事件监听器
  void clearAllEvents() {
    _eventCallbacks.clear();
  }

  @override
  String get jsCode => '''
    // 初始化事件回调系统
    window.plusEventCallbacks = window.plusEventCallbacks || {};
    
    // 生成唯一的回调ID
    function generateCallbackId() {
      return 'callback_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    // plus.events 模块
    window.plus.events = {
      addEventListener: function(event, callback) {
        const callbackId = generateCallbackId();
        window.plusEventCallbacks[callbackId] = callback;
        
        window.flutter_invoke('events.addEventListener', {
          event: event,
          callbackId: callbackId
        });
        
        return callbackId;
      },
      removeEventListener: function(event, callbackId) {
        if (window.plusEventCallbacks[callbackId]) {
          delete window.plusEventCallbacks[callbackId];
        }
        
        window.flutter_invoke('events.removeEventListener', {
          event: event,
          callbackId: callbackId
        });
      },
      fireEvent: function(event, data) {
        window.flutter_invoke('events.fireEvent', {
          event: event,
          data: data
        });
      }
    };
  ''';
}
