import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'plus_bridge_base.dart';

class PlusGeolocationModule extends PlusBridgeModule {
  // 位置监听器缓存
  final Map<int, StreamSubscription<Position>> _positionSubscriptions = {};
  int _nextWatchId = 1;

  // 错误码常量
  static const int permissionDenied = 1;
  static const int positionUnavailable = 2;
  static const int timeout = 3;

  @override
  String get jsNamespace => 'geolocation';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'getCurrentPosition':
        return await _getCurrentPosition(
            params['options'] as Map<String, dynamic>?);
      case 'watchPosition':
        return await _watchPosition(
          params['options'] as Map<String, dynamic>?,
          context,
        );
      case 'clearWatch':
        return await _clearWatch(params['watchId'] as int);
      default:
        return {'error': 'Unknown geolocation method'};
    }
  }

  /// 一次性获取当前坐标、地址等信息
  Future<Map<String, dynamic>> _getCurrentPosition(
      Map<String, dynamic>? options) async {
    try {
      // 解析选项
      final enableHighAccuracy =
          options?['enableHighAccuracy'] as bool? ?? false;
      final timeout = options?['timeout'] as int? ?? 10000; // 默认10秒
      // final maximumAge = options?['maximumAge'] as int? ?? 0; // 暂时未使用
      // final provider = options?['provider'] as String? ?? 'system'; // 暂时未使用
      final coordsType = options?['coordsType'] as String? ?? 'wgs84';
      final geocode = options?['geocode'] as bool? ?? false;

      // 检查位置权限
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'error': 'Location services are disabled',
          'code': positionUnavailable
        };
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'error': 'Location permissions are denied',
            'code': permissionDenied
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'error': 'Location permissions are permanently denied',
          'code': permissionDenied
        };
      }

      // 获取当前位置
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: enableHighAccuracy
            ? LocationAccuracy.high
            : LocationAccuracy.medium,
        timeLimit: Duration(milliseconds: timeout),
      );

      // 转换坐标系（这里简化处理，实际项目中需要使用坐标转换库）
      final Map<String, dynamic> coords =
          _convertCoordinates(position, coordsType);

      // 构建返回结果
      final result = {
        'coords': coords,
        'coordsType': coordsType,
        'timestamp': position.timestamp?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch,
      };

      // 如果需要解析地址
      if (geocode) {
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            result['address'] = {
              'country': placemark.country ?? '',
              'province': placemark.administrativeArea ?? '',
              'city': placemark.locality ?? '',
              'district': placemark.subAdministrativeArea ?? '',
              'street': placemark.street ?? '',
              'streetNumber': placemark.subThoroughfare ?? '',
              'postalCode': placemark.postalCode ?? '',
            };
          }
        } catch (e) {
          // 地址解析失败，不影响返回位置信息
          print('Geocoding failed: $e');
        }
      }

      return {'success': true, 'position': result};
    } catch (e) {
      return {'error': e.toString(), 'code': timeout};
    }
  }

  /// 持续监听位置变化
  Future<Map<String, dynamic>> _watchPosition(
    Map<String, dynamic>? options,
    BuildContext context,
  ) async {
    try {
      // 解析选项
      final enableHighAccuracy =
          options?['enableHighAccuracy'] as bool? ?? false;
      final timeout = options?['timeout'] as int? ?? 10000;
      final maximumAge = options?['maximumAge'] as int? ?? 0;
      // final provider = options?['provider'] as String? ?? 'system'; // 暂时未使用
      final coordsType = options?['coordsType'] as String? ?? 'wgs84';
      final geocode = options?['geocode'] as bool? ?? false;

      // 检查位置权限
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'error': 'Location services are disabled',
          'code': positionUnavailable
        };
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'error': 'Location permissions are denied',
            'code': permissionDenied
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'error': 'Location permissions are permanently denied',
          'code': permissionDenied
        };
      }

      // 创建位置监听器
      final locationSettings = LocationSettings(
        accuracy: enableHighAccuracy
            ? LocationAccuracy.high
            : LocationAccuracy.medium,
        distanceFilter: maximumAge > 0 ? (maximumAge / 1000).toInt() : 0,
        timeLimit: Duration(milliseconds: timeout),
      );

      final positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings);

      // 生成监听器ID
      final watchId = _nextWatchId++;

      // 订阅位置变化
      final subscription = positionStream.listen((position) async {
        // 转换坐标系
        final Map<String, dynamic> coords =
            _convertCoordinates(position, coordsType);

        // 构建返回结果
        final result = {
          'coords': coords,
          'coordsType': coordsType,
          'timestamp': position.timestamp?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
        };

        // 如果需要解析地址
        if (geocode) {
          try {
            final placemarks = await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );

            if (placemarks.isNotEmpty) {
              final placemark = placemarks.first;
              result['address'] = {
                'country': placemark.country ?? '',
                'province': placemark.administrativeArea ?? '',
                'city': placemark.locality ?? '',
                'district': placemark.subAdministrativeArea ?? '',
                'street': placemark.street ?? '',
                'streetNumber': placemark.subThoroughfare ?? '',
                'postalCode': placemark.postalCode ?? '',
              };
            }
          } catch (e) {
            // 地址解析失败，不影响返回位置信息
            print('Geocoding failed: $e');
          }
        }

        // 通过 JavaScript 回调返回结果
        // 这里需要将结果传递给 WebView
        // 由于我们无法直接调用 JavaScript 函数，这里简化处理
        // 实际项目中可能需要使用其他机制来通知 WebView
      });

      // 缓存监听器
      _positionSubscriptions[watchId] = subscription;

      return {'success': true, 'watchId': watchId};
    } catch (e) {
      return {'error': e.toString(), 'code': timeout};
    }
  }

  /// 停止对应监听器
  Future<Map<String, dynamic>> _clearWatch(int watchId) async {
    try {
      if (_positionSubscriptions.containsKey(watchId)) {
        final subscription = _positionSubscriptions[watchId]!;
        await subscription.cancel();
        _positionSubscriptions.remove(watchId);
        return {'success': true};
      } else {
        return {'error': 'Watch ID not found', 'code': positionUnavailable};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 转换坐标系（这里简化处理，实际项目中需要使用坐标转换库）
  Map<String, dynamic> _convertCoordinates(
      Position position, String coordsType) {
    // 这里应该根据不同的坐标系进行转换
    // 由于 geolocator 插件默认返回 WGS84 坐标，所以这里简化处理
    // 实际项目中可能需要使用第三方库进行坐标转换

    final double latitude = position.latitude;
    final double longitude = position.longitude;

    // 这里只是示例，实际转换需要更复杂的算法
    if (coordsType == 'gcj02') {
      // WGS84 转 GCJ02（中国国测局坐标）
      // 这里应该实现转换算法
    } else if (coordsType == 'bd09') {
      // WGS84 转 BD09（百度坐标）
      // 这里应该实现转换算法
    }

    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': position.altitude,
      'accuracy': position.accuracy,
      'altitudeAccuracy': position.altitudeAccuracy,
      'heading': position.heading,
      'speed': position.speed,
    };
  }

  @override
  String get jsCode => '''
    window.plus.geolocation = {
      // 位置监听器缓存
      _watchers: {},
      _nextWatchId: 1,
      
      // 一次性获取当前坐标、地址等信息
      getCurrentPosition: function(successCB, errorCB, options) {
        options = options || {};
        return window.flutter_invoke('geolocation.getCurrentPosition', {
          options: options
        }).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB({code: res.code || -1, message: res.error});
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res.position);
            }
          }
        }).catch(function(error) {
          if (typeof errorCB === 'function') {
            errorCB({code: -1, message: error.message || 'Get current position failed'});
          }
        });
      },
      
      // 持续监听位置变化
      watchPosition: function(successCB, errorCB, options) {
        options = options || {};
        return window.flutter_invoke('geolocation.watchPosition', {
          options: options
        }).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB({code: res.code || -1, message: res.error});
            }
          } else {
            // 缓存监听器
            var watchId = res.watchId;
            window.plus.geolocation._watchers[watchId] = {
              successCB: successCB,
              errorCB: errorCB
            };
            
            if (typeof successCB === 'function') {
              successCB(watchId);
            }
          }
        }).catch(function(error) {
          if (typeof errorCB === 'function') {
            errorCB({code: -1, message: error.message || 'Watch position failed'});
          }
        });
      },
      
      // 停止对应监听器
      clearWatch: function(watchId) {
        return window.flutter_invoke('geolocation.clearWatch', {
          watchId: watchId
        }).then(function(res) {
          // 移除缓存
          if (window.plus.geolocation._watchers[watchId]) {
            delete window.plus.geolocation._watchers[watchId];
          }
          return res.success;
        });
      }
    };
  ''';
}
