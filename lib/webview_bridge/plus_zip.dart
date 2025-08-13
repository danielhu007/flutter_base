import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_base/webview_bridge/plus_bridge_base.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class PlusZipModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'zip';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    try {
      switch (method) {
        case 'compress':
          return await _compress(params);
        case 'decompress':
          return await _decompress(params);
        case 'compressImage':
          return await _compressImage(params);
        case 'compressVideo':
          return await _compressVideo(params);
        default:
          return {'error': 'Unknown zip method: $method'};
      }
    } catch (e) {
      return {'error': 'Error in zip.$method: $e'};
    }
  }

  @override
  String get jsCode => '''
    // plus.zip 模块注入，兼容 H5+
    window.plus.zip = {
      compress: function(src, zipfile, successCB, errorCB) {
        window.flutter_invoke('zip.compress', {
          src: src,
          zipfile: zipfile
        }).then(function(result) {
          if (result.error) {
            if (typeof errorCB === 'function') {
              errorCB({code: -1, message: result.error});
            }
          } else {
            if (typeof successCB === 'function') {
              successCB();
            }
          }
        }).catch(function(error) {
          if (typeof errorCB === 'function') {
            errorCB({code: -1, message: error.message || 'Compression failed'});
          }
        });
      },
      
      decompress: function(zipfile, target, successCB, errorCB) {
        window.flutter_invoke('zip.decompress', {
          zipfile: zipfile,
          target: target
        }).then(function(result) {
          if (result.error) {
            if (typeof errorCB === 'function') {
              errorCB({code: -1, message: result.error});
            }
          } else {
            if (typeof successCB === 'function') {
              successCB();
            }
          }
        }).catch(function(error) {
          if (typeof errorCB === 'function') {
            errorCB({code: -1, message: error.message || 'Decompression failed'});
          }
        });
      },
      
      compressImage: function(options, successCB, errorCB) {
        window.flutter_invoke('zip.compressImage', {
          options: options
        }).then(function(result) {
          if (result.error) {
            if (typeof errorCB === 'function') {
              errorCB({code: -1, message: result.error});
            }
          } else {
            if (typeof successCB === 'function') {
              successCB({
                target: result.target,
                size: result.size,
                width: result.width,
                height: result.height
              });
            }
          }
        }).catch(function(error) {
          if (typeof errorCB === 'function') {
            errorCB({code: -1, message: error.message || 'Image compression failed'});
          }
        });
      },
      
      compressVideo: function(options, successCB, errorCB) {
        window.flutter_invoke('zip.compressVideo', {
          options: options
        }).then(function(result) {
          if (result.error) {
            if (typeof errorCB === 'function') {
              errorCB({code: -1, message: result.error});
            }
          } else {
            if (typeof successCB === 'function') {
              successCB({
                tempFilePath: result.tempFilePath,
                size: result.size
              });
            }
          }
        }).catch(function(error) {
          if (typeof errorCB === 'function') {
            errorCB({code: -1, message: error.message || 'Video compression failed'});
          }
        });
      }
    };
  ''';

  /// 压缩文件或目录到zip文件
  Future<Map<String, dynamic>> _compress(dynamic params) async {
    if (params == null || params is! Map) {
      return {'error': 'Invalid parameters for compress'};
    }

    final src = params['src'] as String?;
    final zipfile = params['zipfile'] as String?;

    if (src == null || zipfile == null) {
      return {'error': 'src and zipfile parameters are required'};
    }

    try {
      // 处理路径前缀
      final sourcePath = await _resolvePath(src);
      final zipPath = await _resolvePath(zipfile);

      final sourceFile = File(sourcePath);
      final sourceDir = Directory(sourcePath);

      if (!sourceFile.existsSync() && !sourceDir.existsSync()) {
        return {
          'error': 'Source file or directory does not exist: $sourcePath'
        };
      }

      // 创建zip归档
      final archive = Archive();

      if (sourceFile.existsSync()) {
        // 压缩单个文件
        final bytes = await sourceFile.readAsBytes();
        final fileName = path.basename(sourcePath);
        final file = ArchiveFile(fileName, bytes.length, bytes);
        archive.addFile(file);
      } else if (sourceDir.existsSync()) {
        // 压缩目录
        await _addDirectoryToArchive(archive, sourceDir, sourcePath);
      }

      // 编码为zip
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);

      if (zipBytes == null) {
        return {'error': 'Failed to encode zip file'};
      }

      // 确保目标目录存在
      final zipFile = File(zipPath);
      await zipFile.parent.create(recursive: true);

      // 写入zip文件
      await zipFile.writeAsBytes(zipBytes);

      return {'success': true, 'zipfile': zipPath};
    } catch (e) {
      return {'error': 'Compress failed: $e'};
    }
  }

  /// 解压zip文件到指定目录
  Future<Map<String, dynamic>> _decompress(dynamic params) async {
    if (params == null || params is! Map) {
      return {'error': 'Invalid parameters for decompress'};
    }

    final zipfile = params['zipfile'] as String?;
    final target = params['target'] as String?;

    if (zipfile == null || target == null) {
      return {'error': 'zipfile and target parameters are required'};
    }

    try {
      final zipPath = await _resolvePath(zipfile);
      final targetPath = await _resolvePath(target);

      final zipFile = File(zipPath);
      if (!zipFile.existsSync()) {
        return {'error': 'Zip file does not exist: $zipPath'};
      }

      final targetDir = Directory(targetPath);
      if (!targetDir.existsSync()) {
        return {'error': 'Target directory does not exist: $targetPath'};
      }

      // 读取zip文件
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 解压文件
      for (final file in archive) {
        final filePath = path.join(targetPath, file.name);
        final outputFile = File(filePath);

        if (file.isFile) {
          await outputFile.parent.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }

      return {'success': true, 'target': targetPath};
    } catch (e) {
      return {'error': 'Decompress failed: $e'};
    }
  }

  /// 压缩图片
  Future<Map<String, dynamic>> _compressImage(dynamic params) async {
    if (params == null || params is! Map) {
      return {'error': 'Invalid parameters for compressImage'};
    }

    final options = params['options'] as Map<String, dynamic>?;
    if (options == null) {
      return {'error': 'options parameter is required'};
    }

    final src = options['src'] as String?;
    final dst = options['dst'] as String?;

    if (src == null || dst == null) {
      return {'error': 'src and dst are required in options'};
    }

    try {
      final srcPath = await _resolvePath(src);
      final dstPath = await _resolvePath(dst);

      final srcFile = File(srcPath);
      if (!srcFile.existsSync()) {
        return {'error': 'Source image does not exist: $srcPath'};
      }

      // 解析压缩选项
      final overwrite = options['overwrite'] == true;
      final format = options['format'] as String? ?? 'jpg';
      final quality = options['quality'] as int? ?? 50;
      final width = _parseSize(options['width']);
      final height = _parseSize(options['height']);
      final rotate = options['rotate'] as int? ?? 0;

      // 检查输出文件是否存在
      final dstFile = File(dstPath);
      if (dstFile.existsSync() && !overwrite) {
        return {'error': 'Destination file exists and overwrite is false'};
      }

      // 确保目标目录存在
      await dstFile.parent.create(recursive: true);

      // 压缩图片
      final result = await FlutterImageCompress.compressAndGetFile(
        srcPath,
        dstPath,
        quality: quality.clamp(1, 100),
        minWidth: width ?? 0,
        minHeight: height ?? 0,
        rotate: rotate,
        format: format.toLowerCase() == 'png'
            ? CompressFormat.png
            : CompressFormat.jpeg,
      );

      if (result == null) {
        return {'error': 'Image compression failed'};
      }

      // 获取压缩后的文件信息
      final compressedFile = File(result.path);
      final size = await compressedFile.length();

      // 获取图片尺寸（简化处理）
      return {
        'success': true,
        'target': result.path,
        'size': size,
        'width': width ?? 0,
        'height': height ?? 0,
      };
    } catch (e) {
      return {'error': 'Image compression failed: $e'};
    }
  }

  /// 压缩视频
  Future<Map<String, dynamic>> _compressVideo(dynamic params) async {
    if (params == null || params is! Map) {
      return {'error': 'Invalid parameters for compressVideo'};
    }

    final options = params['options'] as Map<String, dynamic>?;
    if (options == null) {
      return {'error': 'options parameter is required'};
    }

    final src = options['src'] as String?;
    if (src == null) {
      return {'error': 'src is required in options'};
    }

    try {
      final srcPath = await _resolvePath(src);
      final srcFile = File(srcPath);
      if (!srcFile.existsSync()) {
        return {'error': 'Source video does not exist: $srcPath'};
      }

      // 解析压缩选项
      final quality = options['quality'] as String? ?? 'high';
      final filename = options['filename'] as String?;

      // 映射质量等级
      VideoQuality videoQuality;
      switch (quality.toLowerCase()) {
        case 'low':
          videoQuality = VideoQuality.LowQuality;
        case 'medium':
          videoQuality = VideoQuality.MediumQuality;
        default:
          videoQuality = VideoQuality.HighestQuality;
      }

      // 压缩视频
      final info = await VideoCompress.compressVideo(
        srcPath,
        quality: videoQuality,
        deleteOrigin: false,
      );

      if (info == null) {
        return {'error': 'Video compression failed'};
      }

      String finalPath = info.path!;

      // 如果指定了自定义文件名，移动文件
      if (filename != null) {
        final customPath = await _resolvePath(filename);
        final customFile = File(customPath);
        await customFile.parent.create(recursive: true);
        await File(info.path!).copy(customPath);
        await File(info.path!).delete();
        finalPath = customPath;
      }

      return {
        'success': true,
        'tempFilePath': finalPath,
        'size': info.filesize ?? 0,
      };
    } catch (e) {
      return {'error': 'Video compression failed: $e'};
    }
  }

  /// 递归添加目录到归档
  Future<void> _addDirectoryToArchive(
      Archive archive, Directory dir, String basePath) async {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final bytes = await entity.readAsBytes();
        final relativePath = path.relative(entity.path, from: basePath);
        final file = ArchiveFile(relativePath, bytes.length, bytes);
        archive.addFile(file);
      }
    }
  }

  /// 解析路径前缀（_www, _doc等）
  Future<String> _resolvePath(String pathStr) async {
    if (pathStr.startsWith('_www/')) {
      // _www 路径指向应用的文档目录下的www文件夹
      final docDir = await getApplicationDocumentsDirectory();
      final wwwPath = pathStr.replaceFirst('_www/', '${docDir.path}/www/');

      // 如果www目录不存在，创建它
      final wwwDir = Directory(path.dirname(wwwPath));
      if (!wwwDir.existsSync()) {
        await wwwDir.create(recursive: true);
      }

      return wwwPath;
    } else if (pathStr.startsWith('_doc/')) {
      final docDir = await getApplicationDocumentsDirectory();
      return pathStr.replaceFirst('_doc/', '${docDir.path}/');
    } else if (pathStr.startsWith('_downloads/')) {
      final docDir = await getApplicationDocumentsDirectory();
      final downloadsPath =
          pathStr.replaceFirst('_downloads/', '${docDir.path}/downloads/');

      // 如果downloads目录不存在，创建它
      final downloadsDir = Directory(path.dirname(downloadsPath));
      if (!downloadsDir.existsSync()) {
        await downloadsDir.create(recursive: true);
      }

      return downloadsPath;
    } else if (pathStr.startsWith('/')) {
      // 绝对路径
      return pathStr;
    } else {
      // 相对路径，相对于文档目录
      final docDir = await getApplicationDocumentsDirectory();
      return path.join(docDir.path, pathStr);
    }
  }

  /// 解析尺寸参数（支持px、%、auto）
  int? _parseSize(dynamic size) {
    if (size == null || size == 'auto') return null;
    if (size is int) return size;
    if (size is String) {
      if (size.endsWith('px')) {
        return int.tryParse(size.replaceAll('px', ''));
      }
      if (size.endsWith('%')) {
        // 对于百分比，这里简化处理，实际应该基于原图尺寸计算
        final percent = int.tryParse(size.replaceAll('%', ''));
        if (percent != null) {
          // 假设一个基准尺寸，实际应该获取原图尺寸
          return (1000 * percent / 100).round();
        }
      }

      return int.tryParse(size);
    }
    return null;
  }
}
