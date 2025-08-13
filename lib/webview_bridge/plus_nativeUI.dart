// plus_nativeUI.dart
// H5+ nativeUI API 桥接接口定义
// 实现了原生UI相关功能

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base/webview_bridge/plus_bridge_base.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PlusNativeUI {
  static BuildContext? _currentContext;
  static OverlayEntry? _waitingOverlay;
  static OverlayEntry? _imagePreviewOverlay;
  static String _currentUIStyle = 'light';
  static final Map<String, Timer> _toastTimers = {};

  /// 设置当前上下文，用于显示对话框
  static void setContext(BuildContext context) {
    _currentContext = context;
  }

  /// 弹出系统选择按钮框（底部弹出）
  static Future<Map<String, dynamic>> actionSheet(
      Map<String, dynamic> options) async {
    if (_currentContext == null) return {'error': 'Context not available'};

    final title = options['title']?.toString() ?? '';
    final cancel = options['cancel']?.toString() ?? '取消';
    final buttons = options['buttons'] as List<dynamic>? ?? [];

    if (Platform.isIOS) {
      return await _showCupertinoActionSheet(title, cancel, buttons);
    } else {
      return await _showMaterialBottomSheet(title, cancel, buttons);
    }
  }

  /// iOS 风格的 ActionSheet
  static Future<Map<String, dynamic>> _showCupertinoActionSheet(
      String title, String cancel, List<dynamic> buttons) async {
    final completer = Completer<Map<String, dynamic>>();

    showCupertinoModalPopup(
      context: _currentContext!,
      builder: (context) => CupertinoActionSheet(
        title: title.isNotEmpty ? Text(title) : null,
        actions: buttons.asMap().entries.map((entry) {
          final index = entry.key;
          final button = entry.value as Map<String, dynamic>;
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              completer.complete({'index': index});
            },
            child: Text(button['title']?.toString() ?? ''),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            completer.complete({'index': -1});
          },
          isDestructiveAction: true,
          child: Text(cancel),
        ),
      ),
    );

    return completer.future;
  }

  /// Material 风格的 BottomSheet
  static Future<Map<String, dynamic>> _showMaterialBottomSheet(
      String title, String cancel, List<dynamic> buttons) async {
    final completer = Completer<Map<String, dynamic>>();

    showModalBottomSheet(
      context: _currentContext!,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ...buttons.asMap().entries.map((entry) {
              final index = entry.key;
              final button = entry.value as Map<String, dynamic>;
              return ListTile(
                title: Text(button['title']?.toString() ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  completer.complete({'index': index});
                },
              );
            }),
            const Divider(),
            ListTile(
              title: Text(cancel, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                completer.complete({'index': -1});
              },
            ),
          ],
        ),
      ),
    );

    return completer.future;
  }

  /// 弹出系统提示对话框
  static Future<void> alert(String message,
      [VoidCallback? callback, String? title, String? buttonCapture]) async {
    if (_currentContext == null) return;

    await showDialog(
      context: _currentContext!,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              callback?.call();
            },
            child: Text(buttonCapture ?? '确定'),
          ),
        ],
      ),
    );
  }

  /// 弹出系统确认对话框
  static Future<Map<String, dynamic>> confirm(String message,
      [Map<String, dynamic>? options]) async {
    if (_currentContext == null) return {'error': 'Context not available'};

    final title = options?['title']?.toString() ?? '确认';
    final buttons = options?['buttons'] as List<dynamic>? ?? ['确定', '取消'];

    final completer = Completer<Map<String, dynamic>>();

    showDialog(
      context: _currentContext!,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: buttons.asMap().entries.map((entry) {
          final index = entry.key;
          final buttonText = entry.value.toString();
          return TextButton(
            onPressed: () {
              Navigator.pop(context);
              completer.complete({'index': index, 'value': buttonText});
            },
            child: Text(buttonText),
          );
        }).toList(),
      ),
    );

    return completer.future;
  }

  /// 弹出系统输入对话框
  static Future<Map<String, dynamic>> prompt(String message,
      [Map<String, dynamic>? options]) async {
    if (_currentContext == null) return {'error': 'Context not available'};

    final title = options?['title']?.toString() ?? '输入';
    final placeholder = options?['placeholder']?.toString() ?? '';
    final buttons = options?['buttons'] as List<dynamic>? ?? ['确定', '取消'];
    final controller = TextEditingController();

    final completer = Completer<Map<String, dynamic>>();

    showDialog(
      context: _currentContext!,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: placeholder,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: buttons.asMap().entries.map((entry) {
          final index = entry.key;
          final buttonText = entry.value.toString();
          return TextButton(
            onPressed: () {
              Navigator.pop(context);
              completer.complete({
                'index': index,
                'value': controller.text,
              });
            },
            child: Text(buttonText),
          );
        }).toList(),
      ),
    );

    return completer.future;
  }

  /// 显示自动消失的提示消息
  static Future<void> toast(String message,
      [Map<String, dynamic>? options]) async {
    final duration = options?['duration']?.toString() ?? 'short';
    final position = options?['position']?.toString() ?? 'bottom';

    // 如果使用自定义实现
    if (options?['style'] != null) {
      await _showCustomToast(message, options!);
      return;
    }

    // 使用系统 Toast
    ToastGravity gravity;
    switch (position) {
      case 'top':
        gravity = ToastGravity.TOP;
        break;
      case 'center':
        gravity = ToastGravity.CENTER;
        break;
      default:
        gravity = ToastGravity.BOTTOM;
    }

    await Fluttertoast.showToast(
      msg: message,
      toastLength: duration == 'long' ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  /// 自定义样式的 Toast
  static Future<void> _showCustomToast(
      String message, Map<String, dynamic> options) async {
    if (_currentContext == null) return;

    final overlay = Overlay.of(_currentContext!);
    final style = options['style'] as Map<String, dynamic>? ?? {};
    final duration = options['duration']?.toString() ?? 'short';
    final toastId = DateTime.now().millisecondsSinceEpoch.toString();

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 50,
        right: 50,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _parseColor(style['backgroundColor']) ?? Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: _parseColor(style['color']) ?? Colors.white,
                fontSize: (style['fontSize'] as num?)?.toDouble() ?? 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // 设置自动消失
    final timer = Timer(Duration(seconds: duration == 'long' ? 3 : 2), () {
      overlayEntry.remove();
      _toastTimers.remove(toastId);
    });

    _toastTimers[toastId] = timer;
  }

  /// 关闭 Toast
  static void closeToast() {
    Fluttertoast.cancel();
    // 关闭自定义 Toast
    for (final timer in _toastTimers.values) {
      timer.cancel();
    }
    _toastTimers.clear();
  }

  /// 显示系统等待对话框
  static WaitingDialog showWaiting(
      [String? message, Map<String, dynamic>? options]) {
    if (_currentContext == null) return WaitingDialog._();

    final overlay = Overlay.of(_currentContext!);
    final waitingDialog = WaitingDialog._(message ?? '加载中...', options ?? {});

    _waitingOverlay = OverlayEntry(
      builder: (context) => waitingDialog._buildWidget(),
    );

    overlay.insert(_waitingOverlay!);
    return waitingDialog;
  }

  /// 关闭系统等待对话框
  static void closeWaiting() {
    _waitingOverlay?.remove();
    _waitingOverlay = null;
  }

  /// 弹出系统日期选择对话框
  static Future<Map<String, dynamic>> pickDate(
      [Map<String, dynamic>? options]) async {
    if (_currentContext == null) return {'error': 'Context not available'};

    final minDate = _parseDate(options?['minDate']) ?? DateTime(1900);
    final maxDate = _parseDate(options?['maxDate']) ?? DateTime(2100);
    final initialDate = _parseDate(options?['date']) ?? DateTime.now();

    final selectedDate = await showDatePicker(
      context: _currentContext!,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
    );

    if (selectedDate != null) {
      return {
        'date': selectedDate.toIso8601String(),
        'year': selectedDate.year,
        'month': selectedDate.month,
        'day': selectedDate.day,
      };
    } else {
      return {'error': 'User cancelled'};
    }
  }

  /// 弹出系统时间选择对话框
  static Future<Map<String, dynamic>> pickTime(
      [Map<String, dynamic>? options]) async {
    if (_currentContext == null) return {'error': 'Context not available'};

    final is24Hour = options?['is24Hour'] as bool? ?? true;
    final initialTime = _parseTime(options?['time']) ?? TimeOfDay.now();

    final selectedTime = await showTimePicker(
      context: _currentContext!,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(alwaysUse24HourFormat: is24Hour),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      return {
        'time': selectedTime.format(_currentContext!),
        'hour': selectedTime.hour,
        'minute': selectedTime.minute,
      };
    } else {
      return {'error': 'User cancelled'};
    }
  }

  /// 全屏预览图片
  static void previewImage(List<String> images,
      [Map<String, dynamic>? options]) {
    if (_currentContext == null) return;

    final current = options?['current'] as int? ?? 0;
    final loop = options?['loop'] as bool? ?? false;
    final indicator = options?['indicator'] as bool? ?? true;

    final overlay = Overlay.of(_currentContext!);
    final controller = PageController(initialPage: current);

    _imagePreviewOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              pageController: controller,
              itemCount: images.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: _getImageProvider(images[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              scrollPhysics: loop
                  ? const BouncingScrollPhysics()
                  : const ClampingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: closePreviewImage,
              ),
            ),
            if (indicator && images.length > 1)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: current == index ? Colors.white : Colors.white54,
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );

    overlay.insert(_imagePreviewOverlay!);
  }

  /// 关闭预览图片界面
  static void closePreviewImage() {
    _imagePreviewOverlay?.remove();
    _imagePreviewOverlay = null;
  }

  /// 设置原生界面样式（仅 iOS13+ 支持暗黑模式）
  static Future<void> setUIStyle(String style) async {
    _currentUIStyle = style;

    if (Platform.isIOS) {
      final brightness = style == 'dark' ? Brightness.dark : Brightness.light;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: brightness,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      );
    }
  }

  /// 获取当前UI样式
  static String getUIStyle() => _currentUIStyle;

  // 辅助方法
  static Color? _parseColor(dynamic colorValue) {
    if (colorValue == null) return null;
    try {
      final colorString = colorValue.toString();
      if (colorString.startsWith('#')) {
        return Color(
            int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static TimeOfDay? _parseTime(dynamic timeValue) {
    if (timeValue == null) return null;
    try {
      if (timeValue is Map<String, dynamic>) {
        final hour = timeValue['hour'] as int?;
        final minute = timeValue['minute'] as int?;
        if (hour != null && minute != null) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    } else if (imagePath.startsWith('assets/') ||
        imagePath.startsWith('asset/')) {
      return AssetImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }
}

/// 等待对话框类
class WaitingDialog {
  String _title;
  final Map<String, dynamic> _options;

  WaitingDialog._([this._title = '加载中...', this._options = const {}]);

  void setTitle(String title) {
    _title = title;
    // 这里可以添加更新UI的逻辑
  }

  void close() {
    PlusNativeUI.closeWaiting();
  }

  Widget _buildWidget() {
    final style = _options['style'] as Map<String, dynamic>? ?? {};
    final loadingStyle = _options['loading'] as Map<String, dynamic>? ?? {};

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PlusNativeUI._parseColor(style['backgroundColor']) ??
                Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoadingIndicator(loadingStyle),
              const SizedBox(height: 16),
              Text(
                _title,
                style: TextStyle(
                  color:
                      PlusNativeUI._parseColor(style['color']) ?? Colors.black,
                  fontSize: (style['fontSize'] as num?)?.toDouble() ?? 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(Map<String, dynamic> loadingStyle) {
    final type = loadingStyle['type']?.toString() ?? 'circular';
    final color =
        PlusNativeUI._parseColor(loadingStyle['color']) ?? Colors.blue;
    final size = (loadingStyle['size'] as num?)?.toDouble() ?? 40;

    switch (type) {
      case 'wave':
        return SpinKitWave(color: color, size: size);
      case 'pulse':
        return SpinKitPulse(color: color, size: size);
      case 'dots':
        return SpinKitThreeBounce(color: color, size: size);
      default:
        return SpinKitCircle(color: color, size: size);
    }
  }
}

/// NativeUI 桥接模块
class PlusNativeUIModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'nativeUI';

  @override
  Future<dynamic>? handle(String method, dynamic params, BuildContext context) {
    // 设置上下文
    PlusNativeUI.setContext(context);

    switch (method) {
      case 'actionSheet':
        return PlusNativeUI.actionSheet(params as Map<String, dynamic>);
      case 'alert':
        final message = params['message']?.toString() ?? '';
        final title = params['title']?.toString();
        final buttonCapture = params['buttonCapture']?.toString();
        PlusNativeUI.alert(message, null, title, buttonCapture);
        return Future.value(true);
      case 'confirm':
        final message = params['message']?.toString() ?? '';
        final options = params['options'] as Map<String, dynamic>?;
        return PlusNativeUI.confirm(message, options);
      case 'prompt':
        final message = params['message']?.toString() ?? '';
        final options = params['options'] as Map<String, dynamic>?;
        return PlusNativeUI.prompt(message, options);
      case 'toast':
        final message = params['message']?.toString() ?? '';
        final options = params['options'] as Map<String, dynamic>?;
        PlusNativeUI.toast(message, options);
        return Future.value(true);
      case 'closeToast':
        PlusNativeUI.closeToast();
        return Future.value(true);
      case 'showWaiting':
        final message = params['message']?.toString();
        final options = params['options'] as Map<String, dynamic>?;
        final waiting = PlusNativeUI.showWaiting(message, options);
        return Future.value({'id': waiting.hashCode});
      case 'closeWaiting':
        PlusNativeUI.closeWaiting();
        return Future.value(true);
      case 'pickDate':
        final options = params as Map<String, dynamic>?;
        return PlusNativeUI.pickDate(options);
      case 'pickTime':
        final options = params as Map<String, dynamic>?;
        return PlusNativeUI.pickTime(options);
      case 'previewImage':
        final images = (params['images'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        final options = params['options'] as Map<String, dynamic>?;
        PlusNativeUI.previewImage(images, options);
        return Future.value(true);
      case 'closePreviewImage':
        PlusNativeUI.closePreviewImage();
        return Future.value(true);
      case 'setUIStyle':
        final style = params['style']?.toString() ?? 'light';
        PlusNativeUI.setUIStyle(style);
        return Future.value(true);
      case 'getUIStyle':
        return Future.value(PlusNativeUI.getUIStyle());
      default:
        return Future.value({'error': 'Unknown nativeUI method: $method'});
    }
  }

  @override
  String get jsCode => '''
    // plus.nativeUI 模块注入，兼容 H5+
    window.plus.nativeUI = {
      actionSheet: function(options, callback) {
        return window.flutter_invoke('nativeUI.actionSheet', options).then(function(result) {
          if (typeof callback === 'function') {
            callback(result);
          }
          return result;
        });
      },
      alert: function(message, callback, title, buttonCapture) {
        return window.flutter_invoke('nativeUI.alert', {
          message: message,
          title: title,
          buttonCapture: buttonCapture
        }).then(function(result) {
          if (typeof callback === 'function') {
            callback();
          }
          return result;
        });
      },
      confirm: function(message, callback, options) {
        return window.flutter_invoke('nativeUI.confirm', {
          message: message,
          options: options
        }).then(function(result) {
          if (typeof callback === 'function') {
            callback(result);
          }
          return result;
        });
      },
      prompt: function(message, callback, title, placeholder, buttons) {
        return window.flutter_invoke('nativeUI.prompt', {
          message: message,
          options: {
            title: title,
            placeholder: placeholder,
            buttons: buttons
          }
        }).then(function(result) {
          if (typeof callback === 'function') {
            callback(result);
          }
          return result;
        });
      },
      toast: function(message, options) {
        return window.flutter_invoke('nativeUI.toast', {
          message: message,
          options: options
        });
      },
      closeToast: function() {
        return window.flutter_invoke('nativeUI.closeToast');
      },
      showWaiting: function(message, options) {
        return window.flutter_invoke('nativeUI.showWaiting', {
          message: message,
          options: options
        }).then(function(result) {
          return {
            setTitle: function(title) {
              // 这里可以通过调用 Dart 端方法来更新标题
              return window.flutter_invoke('nativeUI.setWaitingTitle', { title: title });
            },
            close: function() {
              return window.flutter_invoke('nativeUI.closeWaiting');
            }
          };
        });
      },
      closeWaiting: function() {
        return window.flutter_invoke('nativeUI.closeWaiting');
      },
      pickDate: function(successCallback, errorCallback, options) {
        return window.flutter_invoke('nativeUI.pickDate', options).then(function(result) {
          if (result.error) {
            if (typeof errorCallback === 'function') {
              errorCallback(result);
            }
          } else {
            if (typeof successCallback === 'function') {
              successCallback(result);
            }
          }
          return result;
        });
      },
      pickTime: function(successCallback, errorCallback, options) {
        return window.flutter_invoke('nativeUI.pickTime', options).then(function(result) {
          if (result.error) {
            if (typeof errorCallback === 'function') {
              errorCallback(result);
            }
          } else {
            if (typeof successCallback === 'function') {
              successCallback(result);
            }
          }
          return result;
        });
      },
      previewImage: function(images, options) {
        return window.flutter_invoke('nativeUI.previewImage', {
          images: images,
          options: options
        });
      },
      closePreviewImage: function() {
        return window.flutter_invoke('nativeUI.closePreviewImage');
      },
      setUIStyle: function(style) {
        return window.flutter_invoke('nativeUI.setUIStyle', { style: style });
      },
      getUIStyle: function() {
        return window.flutter_invoke('nativeUI.getUIStyle');
      }
    };
  ''';
}
