import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'plus_bridge_base.dart';

/// 定义 WebView 事件类型
enum WebViewEventType {
  // 窗口事件
  windowLoaded,
  windowUnloaded,
  windowFocus,
  windowBlur,
  windowResize,
  windowClose,

  // 资源加载事件
  resourceStart,
  resourceStop,
  resourceError,
  resourceProgress,

  // 导航事件
  navigationStart,
  navigationStop,
  navigationError,
  urlChange,

  // 标题更新
  titleChange,

  // 动画事件
  animationStart,
  animationEnd,
  animationIteration,

  // 手势事件
  touchStart,
  touchMove,
  touchEnd,
  scroll,
  scrollToTop,
  scrollToBottom,

  // 按钮点击事件
  buttonClick,
  linkClick,

  // 成功/失败回调
  success,
  failure,
  complete,

  // 自定义事件
  custom,
}

/// WebView 事件数据
class WebViewEventData {
  final WebViewEventType type;
  final String? eventName;
  final Map<String, dynamic>? data;
  final String? url;
  final String? title;
  final String? error;
  final int? statusCode;
  final double? progress;
  final bool? success;
  final String? message;
  final Map<String, dynamic>? customData;

  WebViewEventData({
    required this.type,
    this.eventName,
    this.data,
    this.url,
    this.title,
    this.error,
    this.statusCode,
    this.progress,
    this.success,
    this.message,
    this.customData,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'eventName': eventName,
      'data': data,
      'url': url,
      'title': title,
      'error': error,
      'statusCode': statusCode,
      'progress': progress,
      'success': success,
      'message': message,
      'customData': customData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

/// WebView 事件回调
typedef WebViewEventCallback = Function(WebViewEventData event);

/// WebView 事件管理器
class WebViewEventManager extends PlusBridgeModule {
  final Map<String, List<WebViewEventCallback>> _eventCallbacks = {};
  final Map<String, List<String>> _jsCallbacks = {};

  @override
  String get jsNamespace => 'events';

  /// 注册事件监听器
  void addEventListener(WebViewEventType type, WebViewEventCallback callback) {
    final eventName = type.toString().split('.').last;
    _eventCallbacks.putIfAbsent(eventName, () => []).add(callback);
  }

  /// 移除事件监听器
  void removeEventListener(
      WebViewEventType type, WebViewEventCallback callback) {
    final eventName = type.toString().split('.').last;
    _eventCallbacks[eventName]?.remove(callback);
  }

  /// 触发事件
  void fireEvent(WebViewEventData event) {
    final eventName = event.eventName ?? event.type.toString().split('.').last;

    // 触发 Dart 回调
    final callbacks = _eventCallbacks[eventName] ?? [];
    for (final callback in callbacks) {
      try {
        callback(event);
      } catch (e) {
        print('WebView event callback error: $e');
      }
    }
  }

  /// 向 WebView 发送事件
  Future<void> sendEventToWebView(
      InAppWebViewController controller, WebViewEventData event) async {
    final eventData = event.toJson();
    final jsCallbacks = _jsCallbacks[
            event.eventName ?? event.type.toString().split('.').last] ??
        [];

    for (final callbackId in jsCallbacks) {
      await controller.evaluateJavascript(source: '''
        if (window.webviewCallbacks && window.webviewCallbacks['$callbackId']) {
          window.webviewCallbacks['$callbackId'](${eventData.toString()});
        }
      ''');
    }
  }

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'addEventListener':
        final eventName = params is Map ? params['eventName'] : null;
        final callbackId = params is Map ? params['callbackId'] : null;
        if (eventName != null && callbackId != null) {
          _jsCallbacks.putIfAbsent(eventName, () => []).add(callbackId);
          return {'success': true, 'message': 'Event listener added'};
        }
        return {'success': false, 'error': 'Invalid parameters'};

      case 'removeEventListener':
        final eventName = params is Map ? params['eventName'] : null;
        final callbackId = params is Map ? params['callbackId'] : null;
        if (eventName != null && callbackId != null) {
          _jsCallbacks[eventName]?.remove(callbackId);
          return {'success': true, 'message': 'Event listener removed'};
        }
        return {'success': false, 'error': 'Invalid parameters'};

      case 'fireEvent':
        final eventName = params is Map ? params['eventName'] : null;
        final data = params is Map ? params['data'] : null;
        if (eventName != null) {
          final eventType = WebViewEventType.values.firstWhere(
            (e) => e.toString().split('.').last == eventName,
            orElse: () => WebViewEventType.custom,
          );

          final event = WebViewEventData(
            type: eventType,
            eventName: eventName,
            data: data,
            customData: params is Map ? params : null,
          );

          fireEvent(event);
          return {'success': true, 'message': 'Event fired'};
        }
        return {'success': false, 'error': 'Event name is required'};

      case 'getEventListeners':
        return {
          'dartCallbacks': _eventCallbacks.map((k, v) => MapEntry(k, v.length)),
          'jsCallbacks': _jsCallbacks.map((k, v) => MapEntry(k, v.length)),
        };

      default:
        return {'success': false, 'error': 'Unknown method: $method'};
    }
  }

  /// 创建快捷方法
  void onWindowLoaded(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.windowLoaded, callback);
  void onWindowUnloaded(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.windowUnloaded, callback);
  void onResourceStart(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.resourceStart, callback);
  void onResourceStop(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.resourceStop, callback);
  void onResourceError(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.resourceError, callback);
  void onUrlChange(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.urlChange, callback);
  void onTitleChange(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.titleChange, callback);
  void onScrollToBottom(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.scrollToBottom, callback);
  void onButtonClick(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.buttonClick, callback);
  void onSuccess(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.success, callback);
  void onFailure(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.failure, callback);
  void onComplete(WebViewEventCallback callback) =>
      addEventListener(WebViewEventType.complete, callback);

  /// 清除所有事件监听器
  void clearAllEventListeners() {
    _eventCallbacks.clear();
    _jsCallbacks.clear();
  }
}
