import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'plus_bridge_base.dart';

class PlusNativeObjModule extends PlusBridgeModule {
  final Map<String, NativeBitmap> _bitmaps = {};
  final Map<String, NativeView> _views = {};

  @override
  String get jsNamespace => 'nativeObj';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    try {
      switch (method) {
        // Bitmap相关方法
        case 'createBitmap':
          return _createBitmap(params);
        case 'loadBitmap':
          return await _loadBitmap(params);
        case 'loadBase64Data':
          return await _loadBase64Data(params);
        case 'saveBitmap':
          return await _saveBitmap(params);
        case 'toBase64Data':
          return _toBase64Data(params);
        case 'clearBitmap':
          return _clearBitmap(params);
        case 'recycleBitmap':
          return _recycleBitmap(params);
        case 'getBitmaps':
          return _getBitmaps();
        case 'getBitmapById':
          return _getBitmapById(params);

        // View相关方法
        case 'createView':
          return _createView(params);
        case 'drawView':
          return await _drawView(params);
        case 'drawBitmapOnView':
          return await _drawBitmapOnView(params);
        case 'drawRectOnView':
          return _drawRectOnView(params);
        case 'drawTextOnView':
          return _drawTextOnView(params);
        case 'showView':
          return _showView(params);
        case 'hideView':
          return _hideView(params);
        case 'closeView':
          return _closeView(params);
        case 'getViewById':
          return _getViewById(params);

        // ImageSlider相关方法
        case 'createImageSlider':
          return _createImageSlider(params);
        case 'addImagesToSlider':
          return _addImagesToSlider(params);
        case 'setImagesToSlider':
          return _setImagesToSlider(params);
        case 'getCurrentImageIndex':
          return _getCurrentImageIndex(params);

        // 动画相关方法
        case 'startAnimation':
          return await _startAnimation(params);
        case 'clearAnimation':
          return _clearAnimation();

        default:
          return {'error': 'Unknown nativeObj method: $method'};
      }
    } catch (e) {
      return {'error': 'Error in nativeObj.$method: $e'};
    }
  }

  @override
  String get jsCode => '''
    // plus.nativeObj 模块注入，兼容 H5+
    window.plus.nativeObj = window.plus.nativeObj || {};
    
    // Bitmap 对象构造函数
    function Bitmap(id, path) {
      this.id = id || 'bitmap_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
      if (path) {
        window.flutter_invoke('nativeObj.createBitmap', {id: this.id, path: path});
      } else {
        window.flutter_invoke('nativeObj.createBitmap', {id: this.id});
      }
    }
    
    // Bitmap 静态方法
    Bitmap.prototype.load = function(path, successCallback, errorCallback) {
      window.flutter_invoke('nativeObj.loadBitmap', {id: this.id, path: path})
        .then(function(res) {
          if (res.success && typeof successCallback === 'function') {
            successCallback();
          } else if (res.error && typeof errorCallback === 'function') {
            errorCallback({message: res.error});
          }
        });
    };
    
    Bitmap.prototype.loadBase64Data = function(data, successCallback, errorCallback) {
      window.flutter_invoke('nativeObj.loadBase64Data', {id: this.id, data: data})
        .then(function(res) {
          if (res.success && typeof successCallback === 'function') {
            successCallback();
          } else if (res.error && typeof errorCallback === 'function') {
            errorCallback({message: res.error});
          }
        });
    };
    
    Bitmap.prototype.save = function(path, options, successCallback, errorCallback) {
      // 处理可选参数
      if (typeof options === 'function') {
        errorCallback = successCallback;
        successCallback = options;
        options = {};
      }
      
      window.flutter_invoke('nativeObj.saveBitmap', {id: this.id, path: path})
        .then(function(res) {
          if (res.success && typeof successCallback === 'function') {
            successCallback();
          } else if (res.error && typeof errorCallback === 'function') {
            errorCallback({message: res.error});
          }
        });
    };
    
    Bitmap.prototype.toBase64Data = function() {
      return window.flutter_invoke('nativeObj.toBase64Data', {id: this.id})
        .then(function(res) {
          return res.data;
        });
    };
    
    Bitmap.prototype.clear = function() {
      window.flutter_invoke('nativeObj.clearBitmap', {id: this.id});
    };
    
    Bitmap.prototype.recycle = function() {
      window.flutter_invoke('nativeObj.recycleBitmap', {id: this.id});
    };
    
    // Bitmap 静态方法
    Bitmap.getItems = function() {
      return window.flutter_invoke('nativeObj.getBitmaps');
    };
    
    Bitmap.getBitmapById = function(id) {
      return window.flutter_invoke('nativeObj.getBitmapById', {id: id})
        .then(function(res) {
          if (res) {
            return new Bitmap(res.id, res.path);
          }
          return null;
        });
    };
    
    // View 对象构造函数
    function View(id, styles, tags) {
      this.id = id || 'view_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
      window.flutter_invoke('nativeObj.createView', {id: this.id, styles: styles, tags: tags});
    }
    
    // View 方法
    View.prototype.draw = function(tags) {
      return window.flutter_invoke('nativeObj.drawView', {id: this.id, tags: tags});
    };
    
    View.prototype.drawBitmap = function(src, sprite, position, id) {
      var bitmapId = src.id || src; // src 可能是 Bitmap 对象或字符串 ID
      return window.flutter_invoke('nativeObj.drawBitmapOnView', {
        viewId: this.id,
        bitmapId: bitmapId,
        sprite: sprite,
        position: position,
        id: id
      });
    };
    
    View.prototype.drawRect = function(color, position, id) {
      return window.flutter_invoke('nativeObj.drawRectOnView', {
        viewId: this.id,
        color: color,
        position: position,
        id: id
      });
    };
    
    View.prototype.drawText = function(text, position, styles, id) {
      return window.flutter_invoke('nativeObj.drawTextOnView', {
        viewId: this.id,
        text: text,
        position: position,
        styles: styles,
        id: id
      });
    };
    
    View.prototype.show = function() {
      return window.flutter_invoke('nativeObj.showView', {id: this.id});
    };
    
    View.prototype.hide = function() {
      return window.flutter_invoke('nativeObj.hideView', {id: this.id});
    };
    
    View.prototype.close = function() {
      return window.flutter_invoke('nativeObj.closeView', {id: this.id});
    };
    
    // View 静态方法
    View.getViewById = function(id) {
      return window.flutter_invoke('nativeObj.getViewById', {id: id})
        .then(function(res) {
          if (res) {
            return new View(res.id, res.styles);
          }
          return null;
        });
    };
    
    // ImageSlider 对象构造函数（继承自 View）
    function ImageSlider(id, styles, tags) {
      View.call(this, id, styles, tags);
      this.id = id || 'slider_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
      window.flutter_invoke('nativeObj.createImageSlider', {id: this.id, styles: styles, tags: tags});
    }
    
    ImageSlider.prototype = Object.create(View.prototype);
    ImageSlider.prototype.constructor = ImageSlider;
    
    ImageSlider.prototype.addImages = function(images) {
      return window.flutter_invoke('nativeObj.addImagesToSlider', {id: this.id, images: images});
    };
    
    ImageSlider.prototype.setImages = function(images) {
      return window.flutter_invoke('nativeObj.setImagesToSlider', {id: this.id, images: images});
    };
    
    ImageSlider.prototype.currentImageIndex = function() {
      return window.flutter_invoke('nativeObj.getCurrentImageIndex', {id: this.id})
        .then(function(res) {
          return res.index;
        });
    };
    
    // 动画方法
    View.startAnimation = function(options, view1, view2, callback) {
      return window.flutter_invoke('nativeObj.startAnimation', {
        options: options,
        view1: view1,
        view2: view2
      }).then(function(res) {
        if (typeof callback === 'function') {
          callback();
        }
      });
    };
    
    View.clearAnimation = function() {
      return window.flutter_invoke('nativeObj.clearAnimation');
    };
    
    // 暴露构造函数到 plus.nativeObj
    window.plus.nativeObj.Bitmap = Bitmap;
    window.plus.nativeObj.View = View;
    window.plus.nativeObj.ImageSlider = ImageSlider;

    // plus.navigator 模块注入，兼容 H5+
    window.plus.navigator = {
      getStatusbarHeight: function() {
        return window.flutter_invoke('navigator.getStatusbarHeight');
      },
      setStatusBarBackground: function(color) {
        return window.flutter_invoke('navigator.setStatusBarBackground', { color: color });
      },
      getStatusBarBackground: function() {
        return window.flutter_invoke('navigator.getStatusBarBackground');
      },
      setStatusBarStyle: function(style) {
        return window.flutter_invoke('navigator.setStatusBarStyle', { style: style });
      },
      getStatusBarStyle: function() {
        return window.flutter_invoke('navigator.getStatusBarStyle');
      },
      getOrientation: function() {
        return window.flutter_invoke('navigator.getOrientation');
      },
      isBackground: function() {
        return window.flutter_invoke('navigator.isBackground');
      }
    };
  ''';

  // Bitmap相关方法实现
  Map<String, dynamic> _createBitmap(dynamic params) {
    final id = params is Map
        ? params['id'] as String? ??
            'bitmap_${DateTime.now().millisecondsSinceEpoch}'
        : 'bitmap_${DateTime.now().millisecondsSinceEpoch}';
    final bitmapPath = params is Map ? params['path'] as String? : null;

    final bitmap = NativeBitmap(id, bitmapPath);
    _bitmaps[id] = bitmap;

    return {
      'id': id,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> _loadBitmap(dynamic params) async {
    final id = params is Map ? params['id'] as String? : null;
    final bitmapPath = params is Map ? params['path'] as String? : null;

    if (id == null || bitmapPath == null) {
      return {'error': 'ID and path are required'};
    }

    final bitmap = _bitmaps[id];
    if (bitmap == null) {
      return {'error': 'Bitmap not found'};
    }

    try {
      await bitmap.load(bitmapPath);
      return {'success': true};
    } catch (e) {
      return {'error': 'Failed to load bitmap: $e'};
    }
  }

  Future<Map<String, dynamic>> _loadBase64Data(dynamic params) async {
    final id = params is Map ? params['id'] as String? : null;
    final base64Data = params is Map ? params['data'] as String? : null;

    if (id == null || base64Data == null) {
      return {'error': 'ID and data are required'};
    }

    final bitmap = _bitmaps[id];
    if (bitmap == null) {
      return {'error': 'Bitmap not found'};
    }

    try {
      await bitmap.loadFromBase64(base64Data);
      return {'success': true};
    } catch (e) {
      return {'error': 'Failed to load bitmap from base64: $e'};
    }
  }

  Future<Map<String, dynamic>> _saveBitmap(dynamic params) async {
    // In the JavaScript API, params would be [bitmapId, savePath, options, successCallback, errorCallback]
    // But in our bridge, it's passed as a Map with 'id' and 'path' keys
    final id = params is Map ? params['id'] as String? : null;
    final savePath = params is Map ? params['path'] as String? : null;
    final options =
        params is Map ? params['options'] as Map<String, dynamic>? : null;

    if (id == null || savePath == null) {
      return {'error': 'ID and path are required'};
    }

    final bitmap = _bitmaps[id];
    if (bitmap == null) {
      return {'error': 'Bitmap not found'};
    }

    try {
      await bitmap.save(savePath, options);
      return {'success': true};
    } catch (e) {
      return {'error': 'Failed to save bitmap: $e'};
    }
  }

  Map<String, dynamic> _toBase64Data(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;

    if (id == null) {
      return {'error': 'ID is required'};
    }

    final bitmap = _bitmaps[id];
    if (bitmap == null) {
      return {'error': 'Bitmap not found'};
    }

    try {
      final base64Data = bitmap.toBase64();
      return {'data': base64Data};
    } catch (e) {
      return {'error': 'Failed to convert to base64: $e'};
    }
  }

  Map<String, dynamic> _clearBitmap(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;

    if (id == null) {
      return {'error': 'ID is required'};
    }

    final bitmap = _bitmaps.remove(id);
    if (bitmap == null) {
      return {'error': 'Bitmap not found'};
    }

    bitmap.clear();
    return {'success': true};
  }

  Map<String, dynamic> _recycleBitmap(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;

    if (id == null) {
      return {'error': 'ID is required'};
    }

    final bitmap = _bitmaps[id];
    if (bitmap == null) {
      return {'error': 'Bitmap not found'};
    }

    bitmap.recycle();
    return {'success': true};
  }

  List<Map<String, dynamic>> _getBitmaps() {
    return _bitmaps.entries
        .map((entry) => {
              'id': entry.key,
              'path': entry.value.path,
            })
        .toList();
  }

  Map<String, dynamic>? _getBitmapById(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;

    if (id == null) {
      return null;
    }

    final bitmap = _bitmaps[id];
    if (bitmap == null) {
      return null;
    }

    return {
      'id': bitmap.id,
      'path': bitmap.path,
    };
  }

  // View相关方法实现
  Map<String, dynamic> _createView(dynamic params) {
    final id = params is Map
        ? params['id'] as String? ??
            'view_${DateTime.now().millisecondsSinceEpoch}'
        : 'view_${DateTime.now().millisecondsSinceEpoch}';
    final styles =
        params is Map ? params['styles'] as Map<String, dynamic>? : null;
    final tags = params is Map ? params['tags'] as List<dynamic>? : null;

    final view = NativeView(id, styles, tags);
    _views[id] = view;

    return {
      'id': id,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> _drawView(dynamic params) async {
    final id = params is Map ? params['id'] as String? : null;
    final tags = params is Map ? params['tags'] as List<dynamic>? : null;

    if (id == null) {
      return {'error': 'ID is required'};
    }

    final view = _views[id];
    if (view == null) {
      return {'error': 'View not found'};
    }

    try {
      await view.draw(tags);
      return {'success': true};
    } catch (e) {
      return {'error': 'Failed to draw view: $e'};
    }
  }

  Future<Map<String, dynamic>> _drawBitmapOnView(dynamic params) async {
    final viewId = params is Map ? params['viewId'] as String? : null;
    final bitmapId = params is Map ? params['bitmapId'] as String? : null;
    final sprite =
        params is Map ? params['sprite'] as Map<String, dynamic>? : null;
    final position =
        params is Map ? params['position'] as Map<String, dynamic>? : null;
    final id = params is Map ? params['id'] as String? : null;

    if (viewId == null || bitmapId == null) {
      return {'error': 'View ID and Bitmap ID are required'};
    }

    final view = _views[viewId];
    final bitmap = _bitmaps[bitmapId];

    if (view == null) {
      return {'error': 'View not found'};
    }

    if (bitmap == null) {
      return {'error': 'Bitmap not found'};
    }

    try {
      await view.drawBitmap(bitmap, sprite, position, id);
      return {'success': true};
    } catch (e) {
      return {'error': 'Failed to draw bitmap on view: $e'};
    }
  }

  Map<String, dynamic> _drawRectOnView(dynamic params) {
    final viewId = params is Map ? params['viewId'] as String? : null;
    final color = params is Map ? params['color'] as String? : null;
    final position =
        params is Map ? params['position'] as Map<String, dynamic>? : null;
    final id = params is Map ? params['id'] as String? : null;

    if (viewId == null) {
      return {'error': 'View ID is required'};
    }

    final view = _views[viewId];
    if (view == null) {
      return {'error': 'View not found'};
    }

    try {
      view.drawRect(color, position, id);
      return {'success': true};
    } catch (e) {
      return {'error': 'Failed to draw rectangle on view: $e'};
    }
  }

  Map<String, dynamic> _drawTextOnView(dynamic params) {
    final viewId = params is Map ? params['viewId'] as String? : null;
    final text = params is Map ? params['text'] as String? : null;
    final position =
        params is Map ? params['position'] as Map<String, dynamic>? : null;
    final styles =
        params is Map ? params['styles'] as Map<String, dynamic>? : null;
    final id = params is Map ? params['id'] as String? : null;

    if (viewId == null || text == null) {
      return {'error': 'View ID and text are required'};
    }

    final view = _views[viewId];
    if (view == null) {
      return {'error': 'View not found'};
    }

    try {
      view.drawText(text, position, styles, id);
      return {'success': true};
    } catch (e) {
      return {'error': 'Failed to draw text on view: $e'};
    }
  }

  Map<String, dynamic> _showView(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;

    if (id == null) {
      return {'error': 'ID is required'};
    }

    final view = _views[id];
    if (view == null) {
      return {'error': 'View not found'};
    }

    try {
      view.show();
      return {'success': true};
    } catch (e) {
      return {'error': 'Failed to show view: $e'};
    }
  }

  Map<String, dynamic> _hideView(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;

    if (id == null) {
      return {'error': 'ID is required'};
    }

    final view = _views[id];
    if (view == null) {
      return {'error': 'View not found'};
    }

    try {
      view.hide();
      return {'success': true};
    } catch (e) {
      return {'error': 'Failed to hide view: $e'};
    }
  }

  Map<String, dynamic> _closeView(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;

    if (id == null) {
      return {'error': 'ID is required'};
    }

    final view = _views.remove(id);
    if (view == null) {
      return {'error': 'View not found'};
    }

    view.close();
    return {'success': true};
  }

  Map<String, dynamic>? _getViewById(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;

    if (id == null) {
      return null;
    }

    final view = _views[id];
    if (view == null) {
      return null;
    }

    return {
      'id': view.id,
      'styles': view.styles,
    };
  }

  // ImageSlider相关方法实现
  Map<String, dynamic> _createImageSlider(dynamic params) {
    final id = params is Map
        ? params['id'] as String? ??
            'slider_${DateTime.now().millisecondsSinceEpoch}'
        : 'slider_${DateTime.now().millisecondsSinceEpoch}';
    final styles =
        params is Map ? params['styles'] as Map<String, dynamic>? : null;
    final tags = params is Map ? params['tags'] as List<dynamic>? : null;

    // ImageSlider继承自View，这里简化处理
    final slider = NativeView(id, styles, tags);
    _views[id] = slider;

    return {
      'id': id,
      'success': true,
    };
  }

  Map<String, dynamic> _addImagesToSlider(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;
    final images = params is Map ? params['images'] as List<dynamic>? : null;

    if (id == null) {
      return {'error': 'ID is required'};
    }

    final slider = _views[id];
    if (slider == null) {
      return {'error': 'ImageSlider not found'};
    }

    // 简化处理，实际应该有专门的ImageSlider类
    return {
      'success': true,
      'message': 'Images added to slider (simplified implementation)'
    };
  }

  Map<String, dynamic> _setImagesToSlider(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;
    final images = params is Map ? params['images'] as List<dynamic>? : null;

    if (id == null) {
      return {'error': 'ID is required'};
    }

    final slider = _views[id];
    if (slider == null) {
      return {'error': 'ImageSlider not found'};
    }

    // 简化处理，实际应该有专门的ImageSlider类
    return {
      'success': true,
      'message': 'Images set to slider (simplified implementation)'
    };
  }

  Map<String, dynamic> _getCurrentImageIndex(dynamic params) {
    final id = params is Map ? params['id'] as String? : null;

    if (id == null) {
      return {'error': 'ID is required'};
    }

    final slider = _views[id];
    if (slider == null) {
      return {'error': 'ImageSlider not found'};
    }

    // 简化处理，返回默认索引
    return {'index': 0};
  }

  // 动画相关方法实现
  Future<Map<String, dynamic>> _startAnimation(dynamic params) async {
    // 简化处理，实际应该实现原生动画
    await Future.delayed(Duration(milliseconds: 100)); // 模拟动画执行
    return {
      'success': true,
      'message': 'Animation started (simplified implementation)'
    };
  }

  Map<String, dynamic> _clearAnimation() {
    // 简化处理，实际应该清除原生动画
    return {
      'success': true,
      'message': 'Animation cleared (simplified implementation)'
    };
  }
}

// NativeBitmap类
class NativeBitmap {
  final String id;
  String? path;
  img.Image? _image;

  NativeBitmap(this.id, this.path);

  Future<void> load(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      _image = img.decodeImage(bytes);
      path = imagePath;
    } else {
      throw Exception('File not found: $imagePath');
    }
  }

  Future<void> loadFromBase64(String base64Data) async {
    // 移除可能的数据URI前缀
    final cleanBase64 =
        base64Data.replaceAll(RegExp(r'data:image\/[a-zA-Z]+;base64,'), '');
    final bytes = base64Decode(cleanBase64);
    _image = img.decodeImage(bytes);
  }

  Future<void> save(String savePathParam,
      [Map<String, dynamic>? options]) async {
    if (_image == null) {
      throw Exception('No image loaded');
    }

    if (savePathParam.isEmpty) {
      throw Exception('Save path cannot be empty');
    }

    // Handle overwrite option
    final overwrite = options != null && options['overwrite'] == true;
    final file = File(savePathParam);

    // Check if file exists and handle overwrite
    if (await file.exists() && !overwrite) {
      throw Exception('File already exists and overwrite is false');
    }

    await file.create(recursive: true);

    // Determine format from options or file extension
    String ext = '';
    if (options != null && options['format'] is String) {
      ext = '.${options['format']}'.toLowerCase();
    } else {
      // Extract extension manually without using path.extension
      final lastDotIndex = savePathParam.lastIndexOf('.');
      ext = lastDotIndex != -1
          ? savePathParam.substring(lastDotIndex).toLowerCase()
          : '';
    }

    List<int> bytes;

    if (ext == '.png') {
      bytes = img.encodePng(_image!);
    } else if (ext == '.jpg' || ext == '.jpeg') {
      final quality = options != null && options['quality'] is int
          ? options['quality'] as int
          : 85;
      bytes = img.encodeJpg(_image!, quality: quality);
    } else {
      // Default to PNG if format is not specified or unrecognized
      bytes = img.encodePng(_image!);
    }

    await file.writeAsBytes(bytes);
  }

  String toBase64() {
    if (_image == null) {
      throw Exception('No image loaded');
    }

    final bytes = img.encodePng(_image!);
    return base64Encode(bytes);
  }

  void clear() {
    _image = null;
    path = null;
  }

  void recycle() {
    // 在Flutter中，图像内存管理由框架处理，这里简化处理
    _image = null;
  }
}

// NativeView类
class NativeView {
  final String id;
  final Map<String, dynamic>? styles;
  final List<dynamic>? tags;
  bool _isVisible = false;

  NativeView(this.id, this.styles, this.tags);

  Future<void> draw(List<dynamic>? drawTags) async {
    // 在Flutter中，绘制由框架处理，这里简化处理
    print('Drawing view $id with tags: $drawTags');
  }

  Future<void> drawBitmap(NativeBitmap bitmap, Map<String, dynamic>? sprite,
      Map<String, dynamic>? position, String? id) async {
    // 在Flutter中，绘制由框架处理，这里简化处理
    print('Drawing bitmap ${bitmap.id} on view $id');
  }

  void drawRect(String? color, Map<String, dynamic>? position, String? id) {
    // 在Flutter中，绘制由框架处理，这里简化处理
    print('Drawing rectangle with color $color on view $id');
  }

  void drawText(String text, Map<String, dynamic>? position,
      Map<String, dynamic>? styles, String? id) {
    // 在Flutter中，绘制由框架处理，这里简化处理
    print('Drawing text "$text" on view $id');
  }

  void show() {
    _isVisible = true;
    print('Showing view $id');
  }

  void hide() {
    _isVisible = false;
    print('Hiding view $id');
  }

  void close() {
    _isVisible = false;
    print('Closing view $id');
  }
}
