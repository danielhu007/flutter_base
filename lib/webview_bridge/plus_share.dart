import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'plus_bridge_base.dart';

class PlusShareModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'share';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'sendWithSystem':
        return await _sendWithSystem(
          params['msg'] as Map<String, dynamic>?,
          params['successCB'] as String?,
          params['errorCB'] as String?,
          context,
        );
      default:
        return {'error': 'Unknown share method'};
    }
  }

  /// 使用系统分享
  Future<Map<String, dynamic>> _sendWithSystem(
    Map<String, dynamic>? msg,
    String? successCB,
    String? errorCB,
    BuildContext context,
  ) async {
    try {
      if (msg == null) {
        return {'error': 'Share message is required'};
      }

      final type = msg['type'] as String? ?? 'text';
      final content = msg['content'] as String? ?? '';
      final href = msg['href'] as String?;
      final pictures = msg['pictures'] as List<dynamic>?;

      // 根据类型构建分享内容
      if (type == 'text') {
        // 文本分享
        String shareText = content;
        if (href != null && href.isNotEmpty) {
          shareText += '\n$href';
        }

        final box = context.findRenderObject() as RenderBox?;
        await Share.share(
          shareText,
          subject: content,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      } else if (type == 'image') {
        // 图片分享
        if (pictures == null || pictures.isEmpty) {
          return {'error': 'No images provided for image sharing'};
        }

        final List<XFile> imageFiles = [];

        for (final picturePath in pictures) {
          if (picturePath is String && picturePath.isNotEmpty) {
            // 处理文件路径
            String filePath;
            if (picturePath.startsWith('_doc/')) {
              final docDir = await getApplicationDocumentsDirectory();
              filePath = path.join(docDir.path, picturePath.substring(5));
            } else if (picturePath.startsWith('_www/')) {
              final wwwDir = await getApplicationSupportDirectory();
              filePath = path.join(wwwDir.path, picturePath.substring(5));
            } else {
              filePath = picturePath;
            }

            final file = File(filePath);
            if (await file.exists()) {
              imageFiles.add(XFile(filePath));
            }
          }
        }

        if (imageFiles.isEmpty) {
          return {'error': 'No valid image files found'};
        }

        final box = context.findRenderObject() as RenderBox?;
        await Share.shareXFiles(
          imageFiles,
          subject: content,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        return {'error': 'Unsupported share type: $type'};
      }

      // 分享成功
      if (successCB != null) {
        // 这里应该调用 JavaScript 回调，但由于 webview_bridge 的限制，
        // 我们只返回成功状态
        return {'success': true, 'callback': successCB};
      }

      return {'success': true};
    } catch (e) {
      // 分享失败
      if (errorCB != null) {
        // 这里应该调用 JavaScript 错误回调，但由于 webview_bridge 的限制，
        // 我们只返回错误信息
        return {'error': e.toString(), 'callback': errorCB};
      }

      return {'error': e.toString()};
    }
  }

  @override
  String get jsCode => '''
  // plus.share 模块注入，兼容 H5+
  window.plus.share = {
    // 使用系统分享
    sendWithSystem: function(msg, successCB, errorCB) {
      return window.flutter_invoke('share.sendWithSystem', {
        msg: msg,
        successCB: successCB ? successCB.toString() : null,
        errorCB: errorCB ? errorCB.toString() : null
      }).then(function(res) {
        if (res.error) {
          if (typeof errorCB === 'function') {
            errorCB({code: -1, message: res.error});
          }
          throw new Error(res.error);
        } else {
          if (typeof successCB === 'function') {
            successCB();
          }
          return res;
        }
      }).catch(function(error) {
        if (typeof errorCB === 'function') {
          errorCB({code: -1, message: error.message || 'Share failed'});
        }
        throw error;
      });
    }
  };
  ''';
}
