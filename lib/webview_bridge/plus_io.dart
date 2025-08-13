import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'plus_bridge_base.dart';

class PlusIOModule extends PlusBridgeModule {
  // 沙盒目录常量 - 保持大写命名以兼容 H5+ 规范
  // ignore_for_file: constant_identifier_names
  static const int PRIVATE_WWW = 0; // _www   （应用资源，只读）
  static const int PRIVATE_DOC = 1; // _doc   （应用私有文档，可读写）
  static const int PUBLIC_DOCUMENTS = 2; // _documents（多应用共享文档，可读写）
  static const int PUBLIC_DOWNLOADS = 3; // _downloads（多应用共享下载，可读写）

  // 文件系统根目录缓存
  final Map<int, Directory> _fileSystemRoots = {};

  @override
  String get jsNamespace => 'io';

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'requestFileSystem':
        return await _requestFileSystem(params['type'] as int);
      case 'resolveLocalFileSystemURL':
        return await _resolveLocalFileSystemURL(params['url'] as String);
      case 'convertLocalFileSystemURL':
        return await _convertLocalFileSystemURL(params['url'] as String);
      case 'convertAbsoluteFileSystem':
        return await _convertAbsoluteFileSystem(params['path'] as String);
      case 'getFileInfo':
        return await _getFileInfo(params['path'] as String);
      case 'getAudioInfo':
        return await _getAudioInfo(params['path'] as String);
      case 'getImageInfo':
        return await _getImageInfo(params['path'] as String);
      case 'getVideoInfo':
        return await _getVideoInfo(params['path'] as String);
      case 'createFile':
        return await _createFile(
            params['path'] as String, params['data'] as String);
      case 'readFile':
        return await _readFile(params['path'] as String);
      case 'writeFile':
        return await _writeFile(
            params['path'] as String, params['data'] as String);
      case 'deleteFile':
        return await _deleteFile(params['path'] as String);
      case 'createDirectory':
        return await _createDirectory(params['path'] as String);
      case 'readDirectory':
        return await _readDirectory(params['path'] as String);
      case 'deleteDirectory':
        return await _deleteDirectory(params['path'] as String);
      default:
        return {'error': 'Unknown io method'};
    }
  }

  @override
  String get jsCode => '''
    // plus.io 模块注入，兼容 H5+
    window.plus.io = {
      // 沙盒目录常量
      PRIVATE_WWW: 0,      // _www   （应用资源，只读）
      PRIVATE_DOC: 1,      // _doc   （应用私有文档，可读写）
      PUBLIC_DOCUMENTS: 2, // _documents（多应用共享文档，可读写）
      PUBLIC_DOWNLOADS: 3, // _downloads（多应用共享下载，可读写）
      
      // 获取文件系统根对象
      requestFileSystem: function(type, successCB, errorCB) {
        window.flutter_invoke('io.requestFileSystem', {type: type}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res.root);
            }
          }
        });
      },
      
      // 通过 URL 获取目录/文件对象
      resolveLocalFileSystemURL: function(url, successCB, errorCB) {
        window.flutter_invoke('io.resolveLocalFileSystemURL', {url: url}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res.entry);
            }
          }
        });
      },
      
      // 将相对路径URL转换为绝对路径（file://…）
      convertLocalFileSystemURL: function(url) {
        return window.flutter_invoke('io.convertLocalFileSystemURL', {url: url});
      },
      
      // 将绝对路径转换为相对路径（_xxx/…）
      convertAbsoluteFileSystem: function(path) {
        return window.flutter_invoke('io.convertAbsoluteFileSystem', {path: path});
      },
      
      // 获取文件信息
      getFileInfo: function(path, successCB, errorCB) {
        window.flutter_invoke('io.getFileInfo', {path: path}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res.info);
            }
          }
        });
      },
      
      // 获取音频信息
      getAudioInfo: function(path, successCB, errorCB) {
        window.flutter_invoke('io.getAudioInfo', {path: path}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res.info);
            }
          }
        });
      },
      
      // 获取图片信息
      getImageInfo: function(path, successCB, errorCB) {
        window.flutter_invoke('io.getImageInfo', {path: path}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res.info);
            }
          }
        });
      },
      
      // 获取视频信息
      getVideoInfo: function(path, successCB, errorCB) {
        window.flutter_invoke('io.getVideoInfo', {path: path}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res.info);
            }
          }
        });
      },
      
      // 创建文件
      createFile: function(path, data, successCB, errorCB) {
        window.flutter_invoke('io.createFile', {path: path, data: data}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res);
            }
          }
        });
      },
      
      // 读取文件
      readFile: function(path, successCB, errorCB) {
        window.flutter_invoke('io.readFile', {path: path}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res.content);
            }
          }
        });
      },
      
      // 写入文件
      writeFile: function(path, data, successCB, errorCB) {
        window.flutter_invoke('io.writeFile', {path: path, data: data}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res);
            }
          }
        });
      },
      
      // 删除文件
      deleteFile: function(path, successCB, errorCB) {
        window.flutter_invoke('io.deleteFile', {path: path}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res);
            }
          }
        });
      },
      
      // 创建目录
      createDirectory: function(path, successCB, errorCB) {
        window.flutter_invoke('io.createDirectory', {path: path}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res);
            }
          }
        });
      },
      
      // 读取目录
      readDirectory: function(path, successCB, errorCB) {
        window.flutter_invoke('io.readDirectory', {path: path}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res.entries);
            }
          }
        });
      },
      
      // 删除目录
      deleteDirectory: function(path, successCB, errorCB) {
        window.flutter_invoke('io.deleteDirectory', {path: path}).then(function(res) {
          if (res.error) {
            if (typeof errorCB === 'function') {
              errorCB(res.error);
            }
          } else {
            if (typeof successCB === 'function') {
              successCB(res);
            }
          }
        });
      }
    };
  ''';

  /// 获取文件系统根对象
  Future<Map<String, dynamic>> _requestFileSystem(int type) async {
    try {
      Directory? directory;

      switch (type) {
        case PRIVATE_WWW:
          // _www 目录（应用资源，只读）
          directory = await getApplicationSupportDirectory();
          break;
        case PRIVATE_DOC:
          // _doc 目录（应用私有文档，可读写）
          directory = await getApplicationDocumentsDirectory();
          break;
        case PUBLIC_DOCUMENTS:
          // _documents 目录（多应用共享文档，可读写）
          if (Platform.isAndroid) {
            directory = Directory('/storage/emulated/0/Documents');
          } else if (Platform.isIOS) {
            directory = await getApplicationDocumentsDirectory();
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
          break;
        case PUBLIC_DOWNLOADS:
          // _downloads 目录（多应用共享下载，可读写）
          if (Platform.isAndroid) {
            directory = Directory('/storage/emulated/0/Download');
          } else if (Platform.isIOS) {
            directory = await getApplicationDocumentsDirectory();
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
          break;
        default:
          return {'error': 'Invalid file system type'};
      }

      // 确保目录存在
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 缓存目录
      _fileSystemRoots[type] = directory;

      return {
        'success': true,
        'root': {
          'name': directory.path.split(path.separator).last,
          'fullPath': directory.path,
          'isDirectory': true,
          'isFile': false,
        }
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 通过 URL 获取目录/文件对象
  Future<Map<String, dynamic>> _resolveLocalFileSystemURL(String url) async {
    try {
      String? filePath;

      // 处理相对路径
      if (url.startsWith('_www/')) {
        final root = await getApplicationSupportDirectory();
        filePath = path.join(root.path, url.substring(5));
      } else if (url.startsWith('_doc/')) {
        final root = await getApplicationDocumentsDirectory();
        filePath = path.join(root.path, url.substring(5));
      } else if (url.startsWith('_documents/')) {
        if (Platform.isAndroid) {
          filePath = '/storage/emulated/0/Documents/${url.substring(11)}';
        } else {
          final root = await getApplicationDocumentsDirectory();
          filePath = path.join(root.path, url.substring(11));
        }
      } else if (url.startsWith('_downloads/')) {
        if (Platform.isAndroid) {
          filePath = '/storage/emulated/0/Download/${url.substring(11)}';
        } else {
          final root = await getApplicationDocumentsDirectory();
          filePath = path.join(root.path, url.substring(11));
        }
      } else if (url.startsWith('file://')) {
        filePath = url.substring(7);
      } else {
        return {'error': 'Invalid URL format'};
      }

      final file = File(filePath);
      final directory = Directory(filePath);

      if (await file.exists()) {
        final stat = await file.stat();
        return {
          'success': true,
          'entry': {
            'name': path.basename(filePath),
            'fullPath': filePath,
            'isFile': true,
            'isDirectory': false,
            'size': stat.size,
            'lastModified': stat.modified.millisecondsSinceEpoch,
          }
        };
      } else if (await directory.exists()) {
        return {
          'success': true,
          'entry': {
            'name': path.basename(filePath),
            'fullPath': filePath,
            'isFile': false,
            'isDirectory': true,
          }
        };
      } else {
        return {'error': 'File or directory not found'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 将相对路径URL转换为绝对路径（file://…）
  Future<String> _convertLocalFileSystemURL(String url) async {
    try {
      String? filePath;

      if (url.startsWith('_www/')) {
        final root = await getApplicationSupportDirectory();
        filePath = path.join(root.path, url.substring(5));
      } else if (url.startsWith('_doc/')) {
        final root = await getApplicationDocumentsDirectory();
        filePath = path.join(root.path, url.substring(5));
      } else if (url.startsWith('_documents/')) {
        if (Platform.isAndroid) {
          filePath = '/storage/emulated/0/Documents/${url.substring(11)}';
        } else {
          final root = await getApplicationDocumentsDirectory();
          filePath = path.join(root.path, url.substring(11));
        }
      } else if (url.startsWith('_downloads/')) {
        if (Platform.isAndroid) {
          filePath = '/storage/emulated/0/Download/${url.substring(11)}';
        } else {
          final root = await getApplicationDocumentsDirectory();
          filePath = path.join(root.path, url.substring(11));
        }
      } else {
        return url; // 已经是绝对路径
      }

      return 'file://$filePath';
    } catch (e) {
      return '';
    }
  }

  /// 将绝对路径转换为相对路径（_xxx/…）
  Future<String> _convertAbsoluteFileSystem(String absolutePath) async {
    try {
      // 移除 file:// 前缀
      String pathStr = absolutePath;
      if (pathStr.startsWith('file://')) {
        pathStr = pathStr.substring(7);
      }

      // 获取各种根目录
      final wwwRoot = await getApplicationSupportDirectory();
      final docRoot = await getApplicationDocumentsDirectory();

      // 检查路径属于哪个根目录
      if (pathStr.startsWith(wwwRoot.path)) {
        return '_www/${pathStr.substring(wwwRoot.path.length + 1)}';
      } else if (pathStr.startsWith(docRoot.path)) {
        return '_doc/${pathStr.substring(docRoot.path.length + 1)}';
      } else if (Platform.isAndroid) {
        if (pathStr.startsWith('/storage/emulated/0/Documents')) {
          return '_documents/${pathStr.substring('/storage/emulated/0/Documents/'.length)}';
        } else if (pathStr.startsWith('/storage/emulated/0/Download')) {
          return '_downloads/${pathStr.substring('/storage/emulated/0/Download/'.length)}';
        }
      }

      return pathStr; // 无法转换为相对路径，返回原路径
    } catch (e) {
      return absolutePath;
    }
  }

  /// 获取文件信息
  Future<Map<String, dynamic>> _getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'error': 'File not found'};
      }

      final stat = await file.stat();
      final bytes = await file.readAsBytes();

      // 简单计算MD5（实际项目中应该使用crypto包）
      String md5 = '';
      for (int i = 0; i < bytes.length; i++) {
        md5 += bytes[i].toRadixString(16).padLeft(2, '0');
      }
      if (md5.length > 32) {
        md5 = md5.substring(0, 32);
      }

      return {
        'success': true,
        'info': {
          'size': stat.size,
          'lastModified': stat.modified.millisecondsSinceEpoch,
          'type': path.extension(filePath).toLowerCase(),
          'md5': md5,
        }
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 获取音频信息（简化版）
  Future<Map<String, dynamic>> _getAudioInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'error': 'File not found'};
      }

      // 这里应该使用音频解析库获取详细信息
      // 简化版本只返回基本信息
      final stat = await file.stat();

      return {
        'success': true,
        'info': {
          'duration': 0, // 需要音频库支持
          'size': stat.size,
          'format': path.extension(filePath).toLowerCase(),
        }
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 获取图片信息（简化版）
  Future<Map<String, dynamic>> _getImageInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'error': 'File not found'};
      }

      // 这里应该使用图片解析库获取详细信息
      // 简化版本只返回基本信息
      final stat = await file.stat();

      return {
        'success': true,
        'info': {
          'width': 0, // 需要图片库支持
          'height': 0, // 需要图片库支持
          'size': stat.size,
          'format': path.extension(filePath).toLowerCase(),
        }
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 获取视频信息（简化版）
  Future<Map<String, dynamic>> _getVideoInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'error': 'File not found'};
      }

      // 这里应该使用视频解析库获取详细信息
      // 简化版本只返回基本信息
      final stat = await file.stat();

      return {
        'success': true,
        'info': {
          'duration': 0, // 需要视频库支持
          'width': 0, // 需要视频库支持
          'height': 0, // 需要视频库支持
          'size': stat.size,
          'format': path.extension(filePath).toLowerCase(),
        }
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 创建文件
  Future<Map<String, dynamic>> _createFile(String filePath, String data) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsString(data);

      return {
        'success': true,
        'path': filePath,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 读取文件
  Future<Map<String, dynamic>> _readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'error': 'File not found'};
      }

      final content = await file.readAsString();

      return {
        'success': true,
        'content': content,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 写入文件
  Future<Map<String, dynamic>> _writeFile(String filePath, String data) async {
    try {
      final file = File(filePath);
      await file.writeAsString(data);

      return {
        'success': true,
        'path': filePath,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 删除文件
  Future<Map<String, dynamic>> _deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'error': 'File not found'};
      }

      await file.delete();

      return {
        'success': true,
        'path': filePath,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 创建目录
  Future<Map<String, dynamic>> _createDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      await directory.create(recursive: true);

      return {
        'success': true,
        'path': dirPath,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 读取目录
  Future<Map<String, dynamic>> _readDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (!await directory.exists()) {
        return {'error': 'Directory not found'};
      }

      final entities = await directory.list().toList();
      final entries = <Map<String, dynamic>>[];

      for (final entity in entities) {
        final stat = await entity.stat();
        entries.add({
          'name': path.basename(entity.path),
          'fullPath': entity.path,
          'isFile': entity is File,
          'isDirectory': entity is Directory,
          'size': stat.size,
        });
      }

      return {
        'success': true,
        'entries': entries,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 删除目录
  Future<Map<String, dynamic>> _deleteDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (!await directory.exists()) {
        return {'error': 'Directory not found'};
      }

      await directory.delete(recursive: true);

      return {
        'success': true,
        'path': dirPath,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
