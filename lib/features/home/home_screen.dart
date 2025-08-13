import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_base/app/router/app_routes.dart';
import 'package:flutter_base/features/counter/widgets/counter.dart';
import 'package:flutter_base/features/posts/models/post_model.dart';
import 'package:flutter_base/models/example_model.dart';
import 'package:flutter_base/repositories/repos.dart';
import 'package:flutter_base/repositories/test.dart';
import 'package:flutter_base/state/riverpod_providers.dart';
import 'package:flutter_base/utils/extensions/build_context.dart';
import 'package:flutter_base/webview_bridge/plus_module_registry.dart';
import 'package:flutter_base/widgets/my_futurebuilder.dart';
import 'package:flutter_base/widgets/webview_bridge.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isTested = Test.of(context)!.isTested;
    final services = ref.watch(reposProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('WebView 演示',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.webView,
                      arguments: {
                        'url': 'https://z.fs.zunlijc.com/mh5v3/',
                        'title': 'WebViewBridge 网络页面',
                      },
                    );
                  },
                  child: const Text('打开网络页面'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewEventsDemo);
                  },
                  child: const Text('测试事件演示'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewDeviceDemo);
                  },
                  child: const Text('测试设备信息'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.webViewHomeDemo);
                  },
                  child: const Text('测试简单页面'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewNavigatorDemo);
                  },
                  child: const Text('plus.navigator 测试'),
                ),
                const Divider(height: 32),
                const Text('功能测试',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewSqliteDemo);
                  },
                  child: const Text('SQLite测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.webViewAudioDemo);
                  },
                  child: const Text('plus.audio 测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewNativeObjDemo);
                  },
                  child: const Text('plus.nativeObj 测试'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewNativeUIDemo);
                  },
                  child: const Text('plus.nativeUI 测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.webViewZipDemo);
                  },
                  child: const Text('plus.zip 压缩测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewGalleryDemo);
                  },
                  child: const Text('plus.gallery 测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.webViewIODemo);
                  },
                  child: const Text('plus.io 测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewCameraDemo);
                  },
                  child: const Text('plus.camera 测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewGeolocationDemo);
                  },
                  child: const Text('plus.geolocation 测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.webViewShareDemo);
                  },
                  child: const Text('plus.share 测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewAndroidDemo);
                  },
                  child: const Text('plus.android 测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewUploaderDemo);
                  },
                  child: const Text('plus.uploader 测试'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.webViewNetworkInfoPingDemo);
                  },
                  child: const Text('plus.networkinfo.ping 测试'),
                ),
                const Divider(height: 32),
                const Text('数据演示',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(context.paddingScheme.p3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Counter(),
                        const SizedBox(height: 8),
                        MyFutureBuilder<ExampleModel>(
                          future: services.external.fetchDummy(),
                          builder: (exampleModel) => Text(
                            'externalService.fetchDummy() =  ${exampleModel.name}',
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyFutureBuilder<List<PostModel>>(
                          future: services.posts.fetchPosts(),
                          builder: (exampleModel) => Text(
                            'number of fetched posts =  ${exampleModel.length}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('isTested = $isTested',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/placeholder');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
