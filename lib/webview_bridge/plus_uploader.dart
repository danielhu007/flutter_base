// Uploader 模块基础结构，API 参考 HTML5+ Uploader
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'plus_bridge_base.dart';

/// 上传任务状态
class UploadState {
  static const int undefined = -2; // 未开始
  static const int scheduled = 0; // 开始调度
  static const int connecting = 1; // 开始请求
  static const int connected = 2; // 请求已接收
  static const int transferring = 3; // 正在传输
  static const int completed = 4; // 已完成
  static const int paused = 5; // 已暂停
}

/// 上传任务参数
class UploadOptions {
  final String? method; // POST（固定）
  final int? timeout; // 服务器响应超时，默认120s
  final int? retry; // 重试次数，默认3次
  final int? retryInterval; // 重试间隔，默认30s
  final int? priority; // 优先级，默认0
  final int? chunkSize; // 分块大小，>0开启分块上传

  UploadOptions({
    this.method = 'POST',
    this.timeout = 120,
    this.retry = 3,
    this.retryInterval = 30,
    this.priority = 0,
    this.chunkSize,
  });
}

/// 上传文件选项
class UploadFileOption {
  final String? key; // 表单键名
  final String? name; // 文件名
  final String? mime; // MIME类型

  UploadFileOption({
    this.key,
    this.name,
    this.mime,
  });
}

/// 上传任务对象
class Upload {
  final String id;
  final String url;
  final UploadOptions options;
  int state;
  int uploadedSize = 0;
  int totalSize = 0;
  String? responseText;

  final StreamController<UploadStateChangedEvent> _stateChangedController =
      StreamController.broadcast();
  Stream<UploadStateChangedEvent> get onStateChanged =>
      _stateChangedController.stream;

  final List<Map<String, dynamic>> _files = [];
  final Map<String, dynamic> _data = {};
  final Map<String, String> _headers = {};

  CancelToken? _cancelToken;
  Dio? _dio;
  bool _isPaused = false;
  bool _isAborted = false;

  Upload({
    required this.id,
    required this.url,
    required this.options,
    this.state = UploadState.undefined,
  });

  /// 追加单个文件
  void addFile(String path, UploadFileOption opts) {
    _files.add({
      'path': path,
      'key': opts.key ?? 'file',
      'name': opts.name ?? path.split('/').last,
      'mime': opts.mime ?? lookupMimeType(path) ?? 'application/octet-stream',
    });
    // 更新总大小
    _updateTotalSize();
  }

  /// 追加表单字段
  void addData(String key, dynamic value) {
    _data[key] = value;
  }

  /// 自定义头（start 前调用）
  void setRequestHeader(String header, String value) {
    _headers[header] = value;
  }

  /// 开始上传
  Future<void> start() async {
    if (state == UploadState.completed) return;
    if (_files.isEmpty) {
      throw Exception('No files to upload');
    }

    state = UploadState.scheduled;
    _emitStateChanged(0);
    _isPaused = false;
    _isAborted = false;

    try {
      print('[Uploader] 开始上传: $url');
      state = UploadState.connecting;
      _emitStateChanged(1);

      _dio = Dio();
      _cancelToken = CancelToken();

      // 设置超时
      _dio!.options.connectTimeout = Duration(seconds: options.timeout ?? 120);
      _dio!.options.receiveTimeout = Duration(seconds: options.timeout ?? 120);
      _dio!.options.sendTimeout = Duration(seconds: options.timeout ?? 120);

      // 设置请求头
      _headers.forEach((key, value) {
        _dio!.options.headers[key] = value;
      });

      state = UploadState.connected;
      _emitStateChanged(2);

      // 创建表单数据
      final formData = FormData();
      
      // 添加表单字段
      _data.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // 添加文件
      for (final file in _files) {
        final fileData = await MultipartFile.fromFile(
          file['path'],
          filename: file['name'],
          contentType: MediaType.parse(file['mime']),
        );
        formData.files.add(MapEntry(file['key'], fileData));
      }

      state = UploadState.transferring;
      _emitStateChanged(3);
      uploadedSize = 0;

      // 发送请求
      final response = await _dio!.post(
        url,
        data: formData,
        cancelToken: _cancelToken,
        onSendProgress: (sent, total) {
          if (_isAborted) {
            _cancelToken?.cancel();
            return;
          }
          if (_isPaused) {
            return;
          }
          uploadedSize = sent;
          totalSize = total;
          _emitStateChanged(3);
        },
      );

      responseText = response.data.toString();
      state = UploadState.completed;
      print('[Uploader] 上传完成: $url');
      _emitStateChanged(4);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        if (_isAborted) {
          print('[Uploader] 用户取消上传');
          state = UploadState.undefined;
          _emitStateChanged(0);
        } else if (_isPaused) {
          print('[Uploader] 用户暂停上传');
          state = UploadState.paused;
          _emitStateChanged(5);
        }
      } else {
        print('[Uploader] 上传异常: ${e.message}');
        state = UploadState.completed;
        _emitStateChanged(-1); // -1 代表失败
      }
    } catch (e, stack) {
      print('[Uploader] 上传异常: $e\n$stack');
      state = UploadState.completed;
      _emitStateChanged(-1);
    } finally {
      _dio?.close();
    }
  }

  /// 暂停上传
  void pause() {
    if (state == UploadState.transferring) {
      _isPaused = true;
      _cancelToken?.cancel();
    }
  }

  /// 恢复上传
  void resume() {
    if (state == UploadState.paused) {
      _isPaused = false;
      _resumeUpload();
    }
  }

  /// 取消上传
  void abort() {
    _isAborted = true;
    _cancelToken?.cancel();
  }

  Future<void> _resumeUpload() async {
    try {
      print('[Uploader] 恢复上传: $url');
      await start();
    } catch (e, stack) {
      print('[Uploader] 恢复上传异常: $e\n$stack');
      state = UploadState.completed;
      _emitStateChanged(-1);
    }
  }

  void _updateTotalSize() {
    totalSize = 0;
    for (final file in _files) {
      final fileObj = File(file['path']);
      if (fileObj.existsSync()) {
        totalSize += fileObj.lengthSync();
      }
    }
  }

  void _emitStateChanged(int status) {
    _stateChangedController.add(UploadStateChangedEvent(this, status));
  }
}

/// 上传任务状态变化事件
class UploadStateChangedEvent {
  final Upload upload;
  final int status;
  UploadStateChangedEvent(this.upload, this.status);
}

/// 上传任务完成回调
typedef UploadCompletedCallback = void Function(
    Upload upload, int status);

/// Uploader 管理器
class Uploader {
  static final Uploader _instance = Uploader._internal();
  factory Uploader() => _instance;
  Uploader._internal();

  final Map<String, Upload> _tasks = {};

  /// 创建上传任务
  Upload createUpload(
    String url, {
    UploadOptions? options,
    UploadCompletedCallback? completedCB,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final task = Upload(
      id: id,
      url: url,
      options: options ?? UploadOptions(),
    );
    _tasks[id] = task;
    return task;
  }

  /// 枚举上传任务
  List<Upload> enumerate({int? state}) {
    if (state == null) return _tasks.values.toList();
    return _tasks.values.where((u) => u.state == state).toList();
  }

  /// 清除上传任务
  void clear({int? state}) {
    if (state == null) {
      _tasks.removeWhere((key, value) => value.state == UploadState.completed);
    } else {
      _tasks.removeWhere((key, value) => value.state == state);
    }
  }

  /// 启动所有未开始/暂停的任务
  void startAll() {
    for (final u in _tasks.values) {
      if (u.state == UploadState.undefined ||
          u.state == UploadState.paused) {
        u.start();
      }
    }
  }
}

class PlusUploaderModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'uploader';

  final Uploader _uploader = Uploader();

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'createUpload':
        final url = params['url'] as String;
        final options = params['options'] != null
            ? UploadOptions(
                method: params['options']['method'] as String?,
                timeout: params['options']['timeout'] as int?,
                retry: params['options']['retry'] as int?,
                retryInterval: params['options']['retryInterval'] as int?,
                priority: params['options']['priority'] as int?,
                chunkSize: params['options']['chunkSize'] as int?,
              )
            : null;
        final task = _uploader.createUpload(url, options: options);
        return {'id': task.id, 'url': task.url};
      case 'addFile':
        final id = params['id'] as String;
        final path = params['path'] as String;
        final opts = params['options'] != null
            ? UploadFileOption(
                key: params['options']['key'] as String?,
                name: params['options']['name'] as String?,
                mime: params['options']['mime'] as String?,
              )
            : UploadFileOption();
        final task = _uploader
            .enumerate()
            .firstWhere((u) => u.id == id, orElse: () => null as Upload);
        task?.addFile(path, opts);
        return true;
      case 'addData':
        final id = params['id'] as String;
        final key = params['key'] as String;
        final value = params['value'];
        final task = _uploader
            .enumerate()
            .firstWhere((u) => u.id == id, orElse: () => null as Upload);
        task?.addData(key, value);
        return true;
      case 'setRequestHeader':
        final id = params['id'] as String;
        final header = params['header'] as String;
        final value = params['value'] as String;
        final task = _uploader
            .enumerate()
            .firstWhere((u) => u.id == id, orElse: () => null as Upload);
        task?.setRequestHeader(header, value);
        return true;
      case 'start':
        final id = params['id'] as String;
        final task = _uploader
            .enumerate()
            .firstWhere((u) => u.id == id, orElse: () => null as Upload);
        task?.start();
        return true;
      case 'pause':
        final id = params['id'] as String;
        final task = _uploader
            .enumerate()
            .firstWhere((u) => u.id == id, orElse: () => null as Upload);
        task?.pause();
        return true;
      case 'resume':
        final id = params['id'] as String;
        final task = _uploader
            .enumerate()
            .firstWhere((u) => u.id == id, orElse: () => null as Upload);
        task?.resume();
        return true;
      case 'abort':
        final id = params['id'] as String;
        final task = _uploader
            .enumerate()
            .firstWhere((u) => u.id == id, orElse: () => null as Upload);
        task?.abort();
        return true;
      case 'enumerate':
        final state = params?['state'] as int?;
        final tasks = _uploader.enumerate(state: state);
        return tasks
            .map((u) => {
                  'id': u.id,
                  'url': u.url,
                  'state': u.state,
                  'uploadedSize': u.uploadedSize,
                  'totalSize': u.totalSize,
                  'responseText': u.responseText,
                })
            .toList();
      case 'clear':
        final state = params?['state'] as int?;
        _uploader.clear(state: state);
        return true;
      case 'startAll':
        _uploader.startAll();
        return true;
      default:
        return null;
    }
  }

  @override
  String get jsCode => '''
    // plus.uploader 模块注入
    window.plus.uploader = {
      _tasks: {},
      createUpload: function(url, options, completedCB) {
        return window.flutter_invoke('uploader.createUpload', { url: url, options: options || {} }).then(function(res) {
          var task = {
            id: res.id,
            url: res.url,
            _listeners: {},
            addFile: function(path, opts) {
              return window.flutter_invoke('uploader.addFile', { id: this.id, path: path, options: opts || {} });
            },
            addData: function(key, value) {
              return window.flutter_invoke('uploader.addData', { id: this.id, key: key, value: value });
            },
            setRequestHeader: function(header, value) {
              return window.flutter_invoke('uploader.setRequestHeader', { id: this.id, header: header, value: value });
            },
            start: function() {
              window.flutter_invoke('uploader.start', { id: this.id });
            },
            pause: function() {
              window.flutter_invoke('uploader.pause', { id: this.id });
            },
            resume: function() {
              window.flutter_invoke('uploader.resume', { id: this.id });
            },
            abort: function() {
              window.flutter_invoke('uploader.abort', { id: this.id });
            },
            addEventListener: function(event, cb) {
              if (event === 'statechanged') {
                this._listeners[event] = cb;
              }
            }
          };
          // 轮询监听状态变化
          var poll = setInterval(function() {
            window.flutter_invoke('uploader.enumerate', {}).then(function(tasks) {
              var t = tasks.find(function(t) { return t.id === task.id; });
              if (t) {
                if (task._listeners['statechanged']) {
                  task._listeners['statechanged'](t, t.state);
                }
                if (t.state === 4 || t.state === -1) {
                  clearInterval(poll);
                  if (typeof completedCB === 'function') completedCB(t, t.state === 4 ? 200 : -1);
                }
              }
            });
          }, 500);
          return task;
        });
      },
      enumerate: function(state, cb) {
        return window.flutter_invoke('uploader.enumerate', { state: state }).then(function(tasks) {
          if (typeof cb === 'function') cb(tasks);
          return tasks;
        });
      },
      clear: function(state) {
        return window.flutter_invoke('uploader.clear', { state: state });
      },
      startAll: function() {
        return window.flutter_invoke('uploader.startAll', {});
      }
    };
  ''';
}