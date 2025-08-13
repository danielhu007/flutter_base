import 'package:flutter/material.dart';
import 'package:flutter_base/app/router/app_routes.dart';
import 'package:flutter_base/features/home/home_screen.dart';
import 'package:flutter_base/utils/logger.dart';
import 'package:flutter_base/widgets/webview_bridge.dart';

class RouteGenerator {
  static final log = getLogger(RouteGenerator);

  static Route<dynamic> generate(RouteSettings settings) {
    final name = settings.name;
    final args = settings.arguments;

    log.i('Opening new route "$name"');
    switch (name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case AppRoutes.placeholder:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Placeholder'),
              foregroundColor: Colors.black,
            ),
            body: const Placeholder(),
          ),
        );
      case AppRoutes.webView:
        final url = args is Map ? args['url'] as String? : null;
        final title = args is Map ? args['title'] as String? : 'WebView';
        if (url != null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text(title ?? 'WebView')),
              body: WebViewBridge(url: url),
            ),
          );
        }
        return _errorRoute('WebView URL is required');
      case AppRoutes.webViewEventsDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('WebView 事件演示')),
            body: const WebViewBridge(
                url: 'assets/web/example/webview_events_demo.html'),
          ),
        );
      case AppRoutes.webViewDeviceDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('设备信息测试')),
            body: const WebViewBridge(url: 'assets/web/example/device.html'),
          ),
        );
      case AppRoutes.webViewHomeDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('简单测试页面')),
            body: const WebViewBridge(url: 'assets/web/example/home.html'),
          ),
        );
      case AppRoutes.webViewNavigatorDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.navigator 测试')),
            body: const WebViewBridge(url: 'assets/web/example/navigator.html'),
          ),
        );
      case AppRoutes.webViewSqliteDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('SQLite测试')),
            body: const WebViewBridge(url: 'assets/web/example/sqlite.html'),
          ),
        );
      case AppRoutes.webViewAudioDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.audio 测试')),
            body: const WebViewBridge(url: 'assets/web/example/audio.html'),
          ),
        );
      case AppRoutes.webViewNativeObjDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.nativeObj 测试')),
            body: const WebViewBridge(url: 'assets/web/example/nativeObj.html'),
          ),
        );
      case AppRoutes.webViewNativeUIDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.nativeUI 测试')),
            body: const WebViewBridge(url: 'assets/web/example/nativeui.html'),
          ),
        );
      case AppRoutes.webViewZipDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.zip 压缩测试')),
            body: const WebViewBridge(url: 'assets/web/example/zip.html'),
          ),
        );
      case AppRoutes.webViewGalleryDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.gallery 测试')),
            body: const WebViewBridge(url: 'assets/web/example/gallery.html'),
          ),
        );
      case AppRoutes.webViewIODemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.io 测试')),
            body: const WebViewBridge(url: 'assets/web/example/io.html'),
          ),
        );
      case AppRoutes.webViewCameraDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.camera 测试')),
            body: const WebViewBridge(url: 'assets/web/example/camera.html'),
          ),
        );
      case AppRoutes.webViewGeolocationDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.geolocation 测试')),
            body:
                const WebViewBridge(url: 'assets/web/example/geolocation.html'),
          ),
        );
      case AppRoutes.webViewShareDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.share 测试')),
            body: const WebViewBridge(url: 'assets/web/example/share.html'),
          ),
        );
      case AppRoutes.webViewAndroidDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.android 测试')),
            body: const WebViewBridge(url: 'assets/web/example/android.html'),
          ),
        );
      case AppRoutes.webViewUploaderDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.uploader 测试')),
            body: const WebViewBridge(url: 'assets/web/example/uploader.html'),
          ),
        );
      case AppRoutes.webViewNetworkInfoPingDemo:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('plus.networkinfo.ping 测试')),
            body: const WebViewBridge(url: 'assets/web/example/networkinfo_ping.html'),
          ),
        );
      default:
        final String message = 'Undefined route $name';
        log.f(message);
        return _errorRoute(message);
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}
