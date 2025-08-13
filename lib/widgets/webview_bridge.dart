import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_base/webview_bridge/plus_module_registry.dart';
import 'package:flutter_base/webview_bridge/plus_bridge_base.dart';
import 'package:flutter_base/widgets/webview_loading_overlay.dart';

// 全局 WebView 管理
class WebViewManager {
  static final WebViewManager _instance = WebViewManager._internal();
  factory WebViewManager() => _instance;
  WebViewManager._internal();

  final Map<String, WebViewData> _webviews = {};

  void addWebView(String id, String url, BuildContext context) {
    _webviews[id] = WebViewData(id: id, url: url, context: context);
  }

  WebViewData? getWebView(String id) => _webviews[id];

  void removeWebView(String id) => _webviews.remove(id);

  List<WebViewData> getAllWebViews() => _webviews.values.toList();
}

class WebViewData {
  final String id;
  final String url;
  final BuildContext context;
  bool isShown = false;

  WebViewData({required this.id, required this.url, required this.context});
}

class WebViewBridge extends StatefulWidget {
  final String url;
  final List<String>? plusModules;

  const WebViewBridge({
    Key? key,
    required this.url,
    this.plusModules,
  }) : super(key: key);

  @override
  State<WebViewBridge> createState() => _WebViewBridgeState();
}

class _WebViewBridgeState extends State<WebViewBridge> {
  InAppWebViewController? _webViewController;

  // 在 _WebViewBridgeState 里定义变量
  String? _appid;
  String? _version;
  String? _model;
  String? _vendor;
  String? _uuid;
  
  // 加载状态管理
  WebViewLoadingState _loadingState = WebViewLoadingState.loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      setState(() {
        _appid = info.packageName;
        _version = info.version;
      });
    });
    _initDeviceInfo();
  }

  Future<void> _initDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      setState(() {
        _model = info.model;
        _vendor = info.manufacturer;
        _uuid = info.id;
        // Android 10+ 无法获取 IMEI/IMSI，返回空字符串
        _imei = '';
        _imsi = '';
      });
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      setState(() {
        _model = info.utsname.machine;
        _vendor = 'Apple';
        _uuid = info.identifierForVendor;
        _imei = '';
        _imsi = '';
      });
    }
  }

  String? _imei;
  String? _imsi;

  // 重试加载方法
  void _retryLoad() {
    setState(() {
      _loadingState = WebViewLoadingState.loading;
      _errorMessage = null;
    });
    _webViewController?.reload();
  }

  /// 生成动态JS代码
  String _generateJS() {
    final selectedModules = widget.plusModules;

    // 基础JS框架
    final buffer = StringBuffer();
    buffer.writeln('''
      window.flutter_invoke = function(method, params) {
        return window.flutter_inappwebview.callHandler('flutter_invoke', method, params);
      };
      window.plus = window.plus || {};
      
      // 初始化事件回调系统
      window.plusEventCallbacks = window.plusEventCallbacks || {};
      
      // 生成唯一的回调ID
      function generateCallbackId() {
        return 'callback_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
      }
    ''');

    // 获取要加载的模块列表
    final List<PlusBridgeModule> modulesToLoad;
    if (selectedModules == null || selectedModules.isEmpty) {
      // 加载所有模块
      modulesToLoad = plusModules;
    } else {
      // 只加载指定的模块
      modulesToLoad = plusModules.where((module) => 
        selectedModules.contains(module.jsNamespace)
      ).toList();
    }

    // 动态添加选中的模块JS代码
    for (final module in modulesToLoad) {
      buffer.writeln('\n// ${module.jsNamespace} module');
      buffer.writeln(module.jsCode);
    }

    // WebView基本功能 - 独立于模块系统
    buffer.writeln('''
      // WebView对象构造函数
      function WebviewObject(id, url) {
        this.id = id;
        this.url = url;
      }
      
      // WebView对象方法
      WebviewObject.prototype.show = function() {
        return window.flutter_invoke('webview.show', { id: this.id });
      };
      
      WebviewObject.prototype.close = function() {
        return window.flutter_invoke('webview.close', { id: this.id });
      };
      
      WebviewObject.prototype.hide = function() {
        return window.flutter_invoke('webview.hide', { id: this.id });
      };
      
      WebviewObject.prototype.addEventListener = function(event, callback) {
        const callbackId = generateCallbackId();
        window.plusEventCallbacks[callbackId] = callback;
        
        window.flutter_invoke('webview.addEventListener', {
          id: this.id,
          event: event,
          callbackId: callbackId
        });
        
        return callbackId;
      };
      
      WebviewObject.prototype.removeEventListener = function(event, callbackId) {
        if (window.plusEventCallbacks[callbackId]) {
          delete window.plusEventCallbacks[callbackId];
        }
        
        window.flutter_invoke('webview.removeEventListener', {
          id: this.id,
          event: event,
          callbackId: callbackId
        });
      };
      
      WebviewObject.prototype.loadURL = function(url) {
        return window.flutter_invoke('webview.loadURL', { id: this.id, url: url });
      };
      
      WebviewObject.prototype.evalJS = function(js) {
        return window.flutter_invoke('webview.evalJS', { id: this.id, js: js });
      };
      
      WebviewObject.prototype.getURL = function() {
        return window.flutter_invoke('webview.getURL', { id: this.id });
      };
      
      WebviewObject.prototype.getTitle = function() {
        return window.flutter_invoke('webview.getTitle', { id: this.id });
      };
      
      WebviewObject.prototype.reload = function() {
        return window.flutter_invoke('webview.reload', { id: this.id });
      };
      
      WebviewObject.prototype.stop = function() {
        return window.flutter_invoke('webview.stop', { id: this.id });
      };
      
      WebviewObject.prototype.canGoBack = function() {
        return window.flutter_invoke('webview.canGoBack', { id: this.id });
      };
      
      WebviewObject.prototype.goBack = function() {
        return window.flutter_invoke('webview.goBack', { id: this.id });
      };
      
      WebviewObject.prototype.canGoForward = function() {
        return window.flutter_invoke('webview.canGoForward', { id: this.id });
      };
      
      WebviewObject.prototype.goForward = function() {
        return window.flutter_invoke('webview.goForward', { id: this.id });
      };
      
      window.plus.webview = {
        create: function(url, id) {
          return window.flutter_invoke('webview.create', { url: url, id: id }).then(function(res) {
            return new WebviewObject(res.id, res.url);
          });
        },
        all: function() {
          return window.flutter_invoke('webview.all');
        },
        getWebviewById: function(id) {
          return window.flutter_invoke('webview.getWebviewById', { id: id });
        },
        currentWebview: function() {
          // 返回当前WebView对象
          return new WebviewObject('current', window.location.href);
        }
      };
    ''');

    // 滚动事件监听
    buffer.writeln('''
      // 滚动到底部时通知 Dart
      window.addEventListener('scroll', function() {
        if ((window.innerHeight + window.scrollY) >= document.body.scrollHeight) {
          window.flutter_invoke('events.fireEvent', {event: 'plusscrollbottom'});
        }
      });
    ''');

    return buffer.toString();
  }

  // WebView 方法处理
  Future<dynamic> _handleWebViewMethod(
      String method, dynamic params, BuildContext context) async {
    final manager = WebViewManager();

    switch (method) {
      case 'create':
        final url = params is Map ? params['url']?.toString() : null;
        final id = params is Map && params['id'] != null
            ? params['id'].toString()
            : 'webview_${DateTime.now().millisecondsSinceEpoch}';

        if (url != null) {
          manager.addWebView(id, url, context);
          return {'id': id, 'url': url};
        }
        return {'error': 'URL is required'};

      case 'show':
        final id = params is Map ? params['id']?.toString() : null;
        if (id != null) {
          final webviewData = manager.getWebView(id);
          if (webviewData != null && !webviewData.isShown) {
            webviewData.isShown = true;
            // 使用 Navigator 打开新页面
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: Text('WebView: $id'),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        webviewData.isShown = false;
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  body: WebViewBridge(url: webviewData.url),
                ),
              ),
            );
            return true;
          }
        }
        return false;

      case 'close':
        final id = params is Map ? params['id']?.toString() : null;
        if (id != null) {
          final webviewData = manager.getWebView(id);
          if (webviewData != null) {
            if (webviewData.isShown) {
              Navigator.of(context).pop();
            }
            manager.removeWebView(id);
            return true;
          }
        }
        return false;

      case 'hide':
        final id = params is Map ? params['id']?.toString() : null;
        if (id != null) {
          final webviewData = manager.getWebView(id);
          if (webviewData != null && webviewData.isShown) {
            webviewData.isShown = false;
            Navigator.of(context).pop();
            return true;
          }
        }
        return false;

      case 'all':
        return manager
            .getAllWebViews()
            .map((data) => {
                  'id': data.id,
                  'url': data.url,
                  'shown': data.isShown,
                })
            .toList();

      case 'getWebviewById':
        final id = params is Map ? params['id']?.toString() : null;
        if (id != null) {
          final webviewData = manager.getWebView(id);
          if (webviewData != null) {
            return {
              'id': webviewData.id,
              'url': webviewData.url,
              'shown': webviewData.isShown,
            };
          }
        }
        return null;

      case 'loadURL':
      case 'evalJS':
      case 'getURL':
      case 'getTitle':
      case 'reload':
      case 'stop':
      case 'canGoBack':
      case 'goBack':
      case 'canGoForward':
      case 'goForward':
      case 'addEventListener':
      case 'removeEventListener':
        // 这些方法目前返回成功，实际功能可以后续添加
        return true;

      default:
        return {'error': 'Unknown webview method: $method'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        widget.url.startsWith('http://') || widget.url.startsWith('https://');
    return Stack(
      children: [
        InAppWebView(
          initialFile: isNetwork ? null : widget.url,
          initialUrlRequest: isNetwork ? URLRequest(url: WebUri(widget.url)) : null,
          initialSettings: InAppWebViewSettings(
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            supportZoom: false,
            builtInZoomControls: false,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),
          onConsoleMessage: (controller, consoleMessage) {
            print('[WebView JS] ${consoleMessage.message}');
          },
          onWebViewCreated: (controller) {
            _webViewController = controller;
            controller.addJavaScriptHandler(
              handlerName: 'flutter_invoke',
              callback: (args) async {
                if (args.isEmpty) return null;
                final methodFull = args[0] as String? ?? '';
                final params = args.length > 1 ? args[1] : null;
                final dotIdx = methodFull.indexOf('.');
                if (dotIdx == -1) return {'error': 'Invalid method'};
                final namespace = methodFull.substring(0, dotIdx);
                final method = methodFull.substring(dotIdx + 1);

                // 设置WebView控制器到events模块
                if (namespace == 'events') {
                  plusEventsModule.setWebViewController(controller);
                }

                // 事件分发
                if (namespace == 'events' && method == 'fireEvent') {
                  final event = params is Map ? params['event'] : null;
                  if (event == 'plusscrollbottom') {
                    _webViewController?.evaluateJavascript(
                        source:
                            "document.dispatchEvent(new Event('plusscrollbottom'));");
                  }
                  return true;
                }

                // WebView 模块处理
                if (namespace == 'webview') {
                  return await _handleWebViewMethod(method, params, context);
                }

                // 其他 plus.* 分发
                return await handlePlusMethod(namespace, method, params, context);
              },
            );
          },
          onLoadStart: (controller, url) {
            setState(() {
              _loadingState = WebViewLoadingState.loading;
              _errorMessage = null;
            });
            print('WebView loading started: $url');
          },
          onLoadStop: (controller, url) async {
            setState(() {
              _loadingState = WebViewLoadingState.loaded;
              _errorMessage = null;
            });
            print('WebView loading finished: $url');
            // 注入动态生成的 JS Bridge
            await controller.evaluateJavascript(source: _generateJS());
            // 页面加载完成后由 Dart 主动触发 plusready
            await controller.evaluateJavascript(
                source: "document.dispatchEvent(new Event('plusready'));");
          },
          onReceivedError: (controller, request, errorResponse) {
            setState(() {
              _loadingState = WebViewLoadingState.error;
              _errorMessage = errorResponse.description;
            });
            print(
                'WebView loading error:  [31m${errorResponse.type.toNativeValue()} - ${errorResponse.description} [0m');
          },
        ),
        WebViewLoadingOverlay(
          state: _loadingState,
          errorText: _errorMessage ?? '加载失败',
          onRetry: _retryLoad,
          backgroundColor: Theme.of(context).colorScheme.surface,
          opacity: 0.95,
          showAnimation: true,
        ),
      ],
    );
  }
}
