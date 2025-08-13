import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'plus_bridge_base.dart';

class PlusDeviceModule extends PlusBridgeModule {
  String? _model;
  String? _vendor;
  String? _uuid;

  PlusDeviceModule() {
    _init();
  }

  Future<void> _init() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      _model = info.model;
      _vendor = info.manufacturer;
      _uuid = info.id;
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      _model = info.utsname.machine;
      _vendor = 'Apple';
      _uuid = info.identifierForVendor;
    }
  }

  @override
  String get jsNamespace => 'device';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'getProperty':
        final property = params is Map ? params['property'] : null;
        if (property == 'model') return _model ?? '';
        if (property == 'vendor') return _vendor ?? '';
        if (property == 'uuid') return _uuid ?? '';
        if (property == 'imei') return ''; // Android 10+ 无法获取 IMEI
        if (property == 'imsi') return ''; // Android 10+ 无法获取 IMSI
        if (property == 'all') {
          return {
            'model': _model ?? '',
            'vendor': _vendor ?? '',
            'uuid': _uuid ?? '',
            'imei': '', // Android 10+ 无法获取 IMEI
            'imsi': '', // Android 10+ 无法获取 IMSI
          };
        }
        return null;
      case 'beep':
        // 这里只做占位，实际可用 soundpool 或 assets 播放 beep 声音
        return null;
      case 'dial':
        final number = params is Map ? params['number'] : null;
        if (number != null) {
          final uri = Uri.parse('tel:$number');
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return null;
      case 'vibrate':
        final ms = params is Map ? params['milliseconds'] : null;
        if (ms is int) {
          Vibration.vibrate(duration: ms);
        } else {
          Vibration.vibrate();
        }
        return null;
      default:
        return {'error': 'Unknown device method'};
    }
  }

  @override
  String get jsCode => '''
    // 预先获取设备信息
    let deviceInfo = null;
    window.flutter_invoke('device.getProperty', {property: 'all'}).then(function(info) {
      deviceInfo = info;
      console.log('Device info loaded:', deviceInfo);
    });
    
    window.plus.device = {
      get model() { 
        return deviceInfo ? deviceInfo.model : '';
      },
      get vendor() { 
        return deviceInfo ? deviceInfo.vendor : '';
      },
      get uuid() { 
        return deviceInfo ? deviceInfo.uuid : '';
      },
      get imei() { 
        return deviceInfo ? deviceInfo.imei : '';
      },
      get imsi() { 
        return deviceInfo ? deviceInfo.imsi : '';
      },
      beep: function(times) { 
        return window.flutter_invoke('device.beep', {times: times || 1}); 
      },
      dial: function(number, confirm) { 
        return window.flutter_invoke('device.dial', {number: number, confirm: confirm !== false}); 
      },
      getInfo: function(callback) {
        if (deviceInfo && typeof callback === 'function') {
          callback(deviceInfo);
        } else {
          window.flutter_invoke('device.getProperty', {property: 'all'}).then(function(res) {
            if (typeof callback === 'function') callback(res);
          });
        }
      },
      vibrate: function(milliseconds) { 
        return window.flutter_invoke('device.vibrate', {milliseconds: milliseconds || 500}); 
      }
    };
  ''';
}
