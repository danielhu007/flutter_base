import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'plus_bridge_base.dart';

class PlusOSModule extends PlusBridgeModule {
  String? _language;
  String? _name;
  String? _vendor;
  String? _version;

  PlusOSModule() {
    _init();
  }

  Future<void> _init() async {
    // 获取系统语言
    _language = Platform.localeName;

    // 获取操作系统信息
    if (Platform.isAndroid) {
      _name = 'Android';
      _vendor = 'Google';
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      _version = androidInfo.version.release;
    } else if (Platform.isIOS) {
      _name = 'iOS';
      _vendor = 'Apple';
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      _version = iosInfo.systemVersion;
    } else if (kIsWeb) {
      _name = 'Web';
      _vendor = 'Unknown';
      _version = 'Unknown';
    } else {
      _name = 'Unknown';
      _vendor = 'Unknown';
      _version = 'Unknown';
    }
  }

  @override
  String get jsNamespace => 'os';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'getProperty':
        final property = params is Map ? params['property'] : null;
        if (property == 'language') return _language ?? '';
        if (property == 'name') return _name ?? '';
        if (property == 'vendor') return _vendor ?? '';
        if (property == 'version') return _version ?? '';
        if (property == 'all') {
          return {
            'language': _language ?? '',
            'name': _name ?? '',
            'vendor': _vendor ?? '',
            'version': _version ?? '',
          };
        }
        return null;
      default:
        return {'error': 'Unknown os method'};
    }
  }

  @override
  String get jsCode => '''
      // 预先获取操作系统信息
      let osInfo = null;
      window.flutter_invoke('os.getProperty', {property: 'all'}).then(function(info) {
        osInfo = info;
        console.log('OS info loaded:', osInfo);
      });
      
      window.plus.os = {
        get language() {
          return osInfo ? osInfo.language : '';
        },
        get name() {
          return osInfo ? osInfo.name : '';
        },
        get vendor() {
          return osInfo ? osInfo.vendor : '';
        },
        get version() {
          return osInfo ? osInfo.version : '';
        }
      };
  ''';
}
