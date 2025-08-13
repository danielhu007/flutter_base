import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'plus_bridge_base.dart';

class PlusRuntimeModule extends PlusBridgeModule {
  String? _appid;
  String? _version;

  PlusRuntimeModule() {
    _init();
  }

  Future<void> _init() async {
    final info = await PackageInfo.fromPlatform();
    _appid = info.packageName;
    _version = info.version;
  }

  @override
  String get jsNamespace => 'runtime';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'echo':
        return params;
      case 'getProperty':
        final property = params is Map ? params['property'] : null;
        if (property == 'appid') return _appid ?? '';
        if (property == 'version') return _version ?? '';
        if (property == 'channel') return 'default';
        if (property == 'launcher') return 'default';
        if (property == 'origin') return 'local';
        if (property == 'all') {
          return {
            'appid': _appid ?? '',
            'version': _version ?? '',
            'channel': 'default',
            'launcher': 'default',
            'origin': 'local',
          };
        }
        return null;
      case 'quit':
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
        return null;
      case 'openFile':
        final filename = params['filename'] as String;
        print('[Runtime] 打开文件: $filename');
        final result = await OpenFile.open(filename);
        return result.type == ResultType.done;
      default:
        return {'error': 'Unknown runtime method'};
    }
  }

  @override
  String get jsCode => '''
    window.plus.runtime = {
      get appid() { return window.flutter_invoke('runtime.getProperty', {property: 'appid'}); },
      get version() { return window.flutter_invoke('runtime.getProperty', {property: 'version'}); },
      get channel() { return window.flutter_invoke('runtime.getProperty', {property: 'channel'}); },
      get launcher() { return window.flutter_invoke('runtime.getProperty', {property: 'launcher'}); },
      get origin() { return window.flutter_invoke('runtime.getProperty', {property: 'origin'}); },
      getProperty: function(appid, callback) {
        window.flutter_invoke('runtime.getProperty', {property: 'all', appid: appid}).then(function(res) {
          if (typeof callback === 'function') callback(res);
        });
      },
      quit: function() { window.flutter_invoke('runtime.quit'); },
      openFile: function(filename) {
        return window.flutter_invoke('runtime.openFile', { filename: filename });
      }
    };
  ''';
}
