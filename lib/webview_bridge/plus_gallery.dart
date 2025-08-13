import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'plus_bridge_base.dart';

/// Gallery 配置选项
class GalleryOptions {
  final bool animation;
  final String? confirmText;
  final GalleryCropStyles? crop;
  final bool editable;
  final String? filename;
  final String filter;
  final int maximum;
  final bool multiple;
  final Function? onmaxed;
  final bool permissionAlert;
  final PopPosition? popover;
  final List<String>? selected;

  GalleryOptions({
    this.animation = true,
    this.confirmText,
    this.crop,
    this.editable = true,
    this.filename,
    this.filter = 'image',
    this.maximum = 0x7FFFFFFF, // Infinity
    this.multiple = false,
    this.onmaxed,
    this.permissionAlert = false,
    this.popover,
    this.selected,
  });

  factory GalleryOptions.fromMap(Map<String, dynamic> map) {
    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      if (v is num) return v != 0;
      return false;
    }

    return GalleryOptions(
      animation: parseBool(map['animation']),
      confirmText: map['confirmText']?.toString(),
      crop: map['crop'] != null
          ? GalleryCropStyles.fromMap(
              Map<String, dynamic>.from(map['crop'] as Map))
          : null,
      editable: parseBool(map['editable']),
      filename: map['filename']?.toString(),
      filter: map['filter']?.toString() ?? 'image',
      maximum: map['maximum'] is int
          ? map['maximum'] as int
          : int.tryParse(map['maximum'].toString()) ?? 0x7FFFFFFF,
      multiple: parseBool(map['multiple']),
      permissionAlert: parseBool(map['permissionAlert']),
      popover: map['popover'] != null
          ? PopPosition.fromMap(
              Map<String, dynamic>.from(map['popover'] as Map))
          : null,
      selected: map['selected'] is List
          ? List<String>.from(map['selected'] as List)
          : null,
    );
  }
}

/// 裁剪配置
class GalleryCropStyles {
  final int quality;
  final int width;
  final int height;
  final bool resize;
  final bool saveToAlbum;

  GalleryCropStyles({
    this.quality = 80,
    required this.width,
    required this.height,
    this.resize = true,
    this.saveToAlbum = false,
  });

  factory GalleryCropStyles.fromMap(Map<String, dynamic> map) {
    return GalleryCropStyles(
      quality: map['quality'] is int
          ? map['quality'] as int
          : int.tryParse(map['quality'].toString()) ?? 80,
      width: map['width'] is int
          ? map['width'] as int
          : int.tryParse(map['width'].toString()) ?? 300,
      height: map['height'] is int
          ? map['height'] as int
          : int.tryParse(map['height'].toString()) ?? 300,
      resize: map['resize'] is bool
          ? map['resize'] as bool
          : map['resize']?.toString().toLowerCase() == 'true',
      saveToAlbum: map['saveToAlbum'] is bool
          ? map['saveToAlbum'] as bool
          : map['saveToAlbum']?.toString().toLowerCase() == 'true',
    );
  }
}

/// iPad 弹窗位置
class PopPosition {
  final String? top;
  final String? left;
  final String? width;
  final String? height;

  PopPosition({
    this.top,
    this.left,
    this.width,
    this.height,
  });

  factory PopPosition.fromMap(Map<String, dynamic> map) {
    return PopPosition(
      top: map['top']?.toString(),
      left: map['left']?.toString(),
      width: map['width']?.toString(),
      height: map['height']?.toString(),
    );
  }
}

class PlusGalleryModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'gallery';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'pick':
        return await _handlePick(params, context);
      case 'save':
        return await _handleSave(params, context);
      default:
        return {'error': 'Unknown gallery method: $method'};
    }
  }

  Future<dynamic> _handlePick(dynamic params, BuildContext context) async {
    try {
      final options = params is Map<String, dynamic>
          ? GalleryOptions.fromMap(params)
          : GalleryOptions();

      // 确定请求类型
      final RequestType requestType = options.filter == 'video'
          ? RequestType.video
          : options.filter == 'none'
              ? RequestType.common
              : RequestType.image;

      // 选择资源
      final SpecialPickerType? specialPickerType = options.multiple
          ? SpecialPickerType.noPreview
          : (requestType == RequestType.common
              ? SpecialPickerType.wechatMoment
              : null);
      final List<AssetEntity>? entities = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: options.maximum,
          requestType: requestType,
          specialPickerType: specialPickerType,
          textDelegate: options.confirmText != null
              ? CustomAssetPickerTextDelegate(confirmText: options.confirmText!)
              : const AssetPickerTextDelegate(),
          selectedAssets: options.selected != null
              ? await _getAssetEntitiesFromPaths(options.selected!)
              : null,
        ),
      );

      if (entities == null || entities.isEmpty) {
        return {'error': 'User cancelled selection'};
      }

      // 获取文件路径
      if (options.multiple) {
        final List<String> paths = [];
        for (final entity in entities) {
          final file = await entity.file;
          if (file != null) {
            // 如果需要裁剪
            if (options.crop != null && requestType == RequestType.image) {
              final croppedPath = await _cropImage(file.path, options.crop!);
              if (croppedPath != null) {
                paths.add(croppedPath);
              }
            } else {
              paths.add(file.path);
            }
          }
        }
        return {'files': paths};
      } else {
        final file = await entities.first.file;
        if (file == null) {
          return {'error': 'Failed to get file'};
        }

        // 如果需要裁剪
        if (options.crop != null && requestType == RequestType.image) {
          final croppedPath = await _cropImage(file.path, options.crop!);
          if (croppedPath != null) {
            return {'file': croppedPath};
          }
        }

        return {'file': file.path};
      }
    } catch (e) {
      return {'error': 'Failed to pick assets: ${e.toString()}'};
    }
  }

  Future<dynamic> _handleSave(dynamic params, BuildContext context) async {
    try {
      if (params is! Map<String, dynamic>) {
        return {'error': 'Invalid parameters'};
      }

      final path = params['path']?.toString();
      if (path == null || path.isEmpty) {
        return {'error': 'Path is required'};
      }

      final file = File(path);
      if (!await file.exists()) {
        return {'error': 'File does not exist'};
      }

      // 保存到相册
      final result = await ImageGallerySaver.saveFile(path);

      if (result != null && result is Map && result['isSuccess'] == true) {
        return {
          'success': true,
          'path': result['filePath']?.toString() ?? path,
        };
      } else {
        return {'error': 'Failed to save to gallery'};
      }
    } catch (e) {
      return {'error': 'Failed to save file: ${e.toString()}'};
    }
  }

  Future<List<AssetEntity>> _getAssetEntitiesFromPaths(
      List<String> paths) async {
    final List<AssetEntity> entities = [];
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        // 这里简化处理，实际应用中可能需要更复杂的逻辑来从路径获取 AssetEntity
        // 暂时返回空列表，因为从路径获取 AssetEntity 比较复杂
      }
    }
    return entities;
  }

  Future<String?> _cropImage(String path, GalleryCropStyles cropStyles) async {
    try {
      // 这里应该实现图片裁剪功能
      // 由于 wechat_assets_picker 本身不提供裁剪功能，需要集成其他裁剪库
      // 这里暂时返回原路径，实际应用中应该实现裁剪逻辑
      return path;
    } catch (e) {
      print('Failed to crop image: $e');
      return null;
    }
  }

  @override
  String get jsCode => '''
    // plus.gallery 模块注入，兼容 H5+
    window.plus.gallery = {
      pick: function(successCB, errorCB, options) {
        options = options || {};
        return window.flutter_invoke('gallery.pick', options).then(function(result) {
          if (result.error) {
            if (typeof errorCB === 'function') {
              errorCB({code: -1, message: result.error});
            }
          } else {
            if (typeof successCB === 'function') {
              if (result.files) {
                // 多选情况
                successCB({files: result.files});
              } else {
                // 单选情况
                successCB(result.file);
              }
            }
          }
        }).catch(function(error) {
          if (typeof errorCB === 'function') {
            errorCB({code: -1, message: error.message || 'Failed to pick from gallery'});
          }
        });
      },
      save: function(path, successCB, errorCB) {
        if (!path) {
          if (typeof errorCB === 'function') {
            errorCB({code: -1, message: 'Path is required'});
          }
          return;
        }
        
        return window.flutter_invoke('gallery.save', {path: path}).then(function(result) {
          if (result.error) {
            if (typeof errorCB === 'function') {
              errorCB({code: -1, message: result.error});
            }
          } else {
            if (typeof successCB === 'function') {
              successCB({path: result.path});
            }
          }
        }).catch(function(error) {
          if (typeof errorCB === 'function') {
            errorCB({code: -1, message: error.message || 'Failed to save to gallery'});
          }
        });
      }
    };
    ''';
}

/// 自定义资源选择器文本委托
class CustomAssetPickerTextDelegate extends AssetPickerTextDelegate {
  final String confirmText;

  CustomAssetPickerTextDelegate({required this.confirmText});

  @override
  String get confirm => confirmText;

  @override
  String get cancel => '取消';

  @override
  String get edit => '编辑';

  @override
  String get gifIndicator => 'GIF';

  @override
  String get loadFailed => '加载失败';

  @override
  String get original => '原图';

  @override
  String get preview => '预览';

  @override
  String get select => '选择';

  String get unSelect => '取消选择';

  String get videoIndicator => '视频';

  @override
  String get emptyList => '空列表';

  @override
  String get unSupportedAssetType => '不支持的资源类型';

  @override
  String get unableToAccessAll => '无法访问所有资源';

  @override
  String get viewingLimitedAssetsTip => '正在查看受限资源';

  @override
  String get changeAccessibleLimitedAssets => '更改可访问的受限资源';

  @override
  String get accessAllTip => '应用只能访问部分资源，请前往系统设置更改';

  @override
  String get goToSystemSettings => '前往系统设置';
}
