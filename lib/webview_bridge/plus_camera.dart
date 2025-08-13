import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'plus_bridge_base.dart';

class PlusCameraModule extends PlusBridgeModule {
  // 相机实例缓存
  final Map<int, CameraInstance> _cameraInstances = {};

  @override
  String get jsNamespace => 'camera';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'getCamera':
        return await _getCamera(params['index'] as int?);
      case 'captureImage':
        return await _captureImage(
          params['cameraId'] as int,
          params['options'] as Map<String, dynamic>?,
          context,
        );
      case 'startVideoCapture':
        return await _startVideoCapture(
          params['cameraId'] as int,
          params['options'] as Map<String, dynamic>?,
          context,
        );
      case 'stopVideoCapture':
        return await _stopVideoCapture(params['cameraId'] as int);
      default:
        return {'error': 'Unknown camera method'};
    }
  }

  /// 获取摄像头实例
  Future<Map<String, dynamic>> _getCamera(int? index) async {
    try {
      // 默认使用主摄 (index=1)
      final cameraIndex = index ?? 1;

      // 检查是否已存在该摄像头实例
      if (_cameraInstances.containsKey(cameraIndex)) {
        final instance = _cameraInstances[cameraIndex]!;
        return {
          'success': true,
          'camera': {
            'id': instance.id,
            'supportedImageResolutions': instance.supportedImageResolutions,
            'supportedVideoResolutions': instance.supportedVideoResolutions,
            'supportedImageFormats': instance.supportedImageFormats,
            'supportedVideoFormats': instance.supportedVideoFormats,
          }
        };
      }

      // 创建新的摄像头实例
      final instance = CameraInstance(
        id: cameraIndex,
        supportedImageResolutions: [
          '1920*1080',
          '1280*720',
          '640*480',
          '320*240'
        ],
        supportedVideoResolutions: [
          '1920*1080',
          '1280*720',
          '640*480',
          '320*240'
        ],
        supportedImageFormats: ['jpg', 'png'],
        supportedVideoFormats: ['mp4', '3gp'],
      );

      _cameraInstances[cameraIndex] = instance;

      return {
        'success': true,
        'camera': {
          'id': instance.id,
          'supportedImageResolutions': instance.supportedImageResolutions,
          'supportedVideoResolutions': instance.supportedVideoResolutions,
          'supportedImageFormats': instance.supportedImageFormats,
          'supportedVideoFormats': instance.supportedVideoFormats,
        }
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 拍照
  Future<Map<String, dynamic>> _captureImage(
    int cameraId,
    Map<String, dynamic>? options,
    BuildContext context,
  ) async {
    try {
      // 检查摄像头实例是否存在
      if (!_cameraInstances.containsKey(cameraId)) {
        return {'error': 'Camera instance not found'};
      }

      // 解析选项
      final filename = options?['filename'] as String? ??
          '_doc/camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      // final format = options?['format'] as String? ?? 'jpg'; // 暂时未使用
      // final resolution = options?['resolution'] as String? ?? '1920*1080'; // 暂时未使用
      // final crop = options?['crop'] as bool? ?? false; // 暂时未使用
      // final optimize = options?['optimize'] as bool? ?? true; // 暂时未使用

      // 处理文件路径
      String filePath;
      if (filename.startsWith('_doc/')) {
        final docDir = await getApplicationDocumentsDirectory();
        filePath = path.join(docDir.path, filename.substring(5));
      } else if (filename.startsWith('_www/')) {
        final wwwDir = await getApplicationSupportDirectory();
        filePath = path.join(wwwDir.path, filename.substring(5));
      } else {
        filePath = filename;
      }

      // 确保目录存在
      final directory = Directory(path.dirname(filePath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 使用 wechat_camera_picker 拍照
      final asset = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          textDelegate: EnglishCameraPickerTextDelegate(),
        ),
      );

      if (asset == null) {
        return {'error': 'User cancelled'};
      }

      // 获取文件
      final file = await asset.file;
      if (file == null) {
        return {'error': 'Failed to get image file'};
      }

      // 复制到目标路径
      await file.copy(filePath);

      return {
        'success': true,
        'filePath': filePath,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 开始摄像
  Future<Map<String, dynamic>> _startVideoCapture(
    int cameraId,
    Map<String, dynamic>? options,
    BuildContext context,
  ) async {
    try {
      // 检查摄像头实例是否存在
      if (!_cameraInstances.containsKey(cameraId)) {
        return {'error': 'Camera instance not found'};
      }

      // 解析选项
      final filename = options?['filename'] as String? ??
          '_doc/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      // final format = options?['format'] as String? ?? 'mp4'; // 暂时未使用
      // final resolution = options?['resolution'] as String? ?? '1920*1080'; // 暂时未使用
      final videoMaximumDuration =
          options?['videoMaximumDuration'] as int? ?? 60;

      // 处理文件路径
      String filePath;
      if (filename.startsWith('_doc/')) {
        final docDir = await getApplicationDocumentsDirectory();
        filePath = path.join(docDir.path, filename.substring(5));
      } else if (filename.startsWith('_www/')) {
        final wwwDir = await getApplicationSupportDirectory();
        filePath = path.join(wwwDir.path, filename.substring(5));
      } else {
        filePath = filename;
      }

      // 确保目录存在
      final directory = Directory(path.dirname(filePath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 使用 wechat_camera_picker 录制视频
      final asset = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: CameraPickerConfig(
          enableRecording: true,
          maximumRecordingDuration: Duration(seconds: videoMaximumDuration),
          textDelegate: const EnglishCameraPickerTextDelegate(),
        ),
      );

      if (asset == null) {
        return {'error': 'User cancelled'};
      }

      // 获取文件
      final file = await asset.file;
      if (file == null) {
        return {'error': 'Failed to get video file'};
      }

      // 复制到目标路径
      await file.copy(filePath);

      return {
        'success': true,
        'filePath': filePath,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 结束摄像（Android/iOS 均无效，需用户手动停止）
  Future<Map<String, dynamic>> _stopVideoCapture(int cameraId) async {
    // 在实际实现中，这个方法可能无法直接停止录制
    // 因为 wechat_camera_picker 需要用户手动停止录制
    return {
      'success': false,
      'error':
          'stopVideoCapture is not supported, user must stop recording manually',
    };
  }

  @override
  String get jsCode => '''
  // plus.camera 模块注入，兼容 H5+
  window.plus.camera = {
    // 缓存相机实例
    _cameras: {},
    
    // 获取摄像头实例
    getCamera: function(index) {
      return window.flutter_invoke('camera.getCamera', {index: index}).then(function(res) {
        if (res.error) {
          throw new Error(res.error);
        }
        
        var cameraId = res.camera.id;
        
        // 如果已存在该摄像头实例，直接返回
        if (window.plus.camera._cameras[cameraId]) {
          return window.plus.camera._cameras[cameraId];
        }
        
        // 创建新的摄像头实例
        var camera = {
          id: cameraId,
          supportedImageResolutions: res.camera.supportedImageResolutions,
          supportedVideoResolutions: res.camera.supportedVideoResolutions,
          supportedImageFormats: res.camera.supportedImageFormats,
          supportedVideoFormats: res.camera.supportedVideoFormats,
          
          // 拍照方法
          captureImage: function(successCB, errorCB, options) {
            options = options || {};
            return window.flutter_invoke('camera.captureImage', {
              cameraId: this.id,
              options: options
            }).then(function(res) {
              if (res.error) {
                if (typeof errorCB === 'function') {
                  errorCB({code: -1, message: res.error});
                }
              } else {
                if (typeof successCB === 'function') {
                  successCB(res.filePath);
                }
              }
            }).catch(function(error) {
              if (typeof errorCB === 'function') {
                errorCB({code: -1, message: error.message || 'Capture image failed'});
              }
            });
          },
          
          // 开始摄像方法
          startVideoCapture: function(successCB, errorCB, options) {
            options = options || {};
            return window.flutter_invoke('camera.startVideoCapture', {
              cameraId: this.id,
              options: options
            }).then(function(res) {
              if (res.error) {
                if (typeof errorCB === 'function') {
                  errorCB({code: -1, message: res.error});
                }
              } else {
                if (typeof successCB === 'function') {
                  successCB(res.filePath);
                }
              }
            }).catch(function(error) {
              if (typeof errorCB === 'function') {
                errorCB({code: -1, message: error.message || 'Start video capture failed'});
              }
            });
          },
          
          // 结束摄像方法（Android/iOS 均无效，需用户手动停止）
          stopVideoCapture: function() {
            return window.flutter_invoke('camera.stopVideoCapture', {
              cameraId: this.id
            }).then(function(res) {
              return res.success;
            });
          }
        };
        
        // 缓存摄像头实例
        window.plus.camera._cameras[cameraId] = camera;
        
        return camera;
      });
    }
  };
  ''';
}

/// 摄像头实例类
class CameraInstance {
  final int id;
  final List<String> supportedImageResolutions;
  final List<String> supportedVideoResolutions;
  final List<String> supportedImageFormats;
  final List<String> supportedVideoFormats;

  CameraInstance({
    required this.id,
    required this.supportedImageResolutions,
    required this.supportedVideoResolutions,
    required this.supportedImageFormats,
    required this.supportedVideoFormats,
  });
}
