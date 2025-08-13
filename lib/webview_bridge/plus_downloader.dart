// Downloader 模块基础结构，API 参考 HTML5+ Downloader
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'plus_bridge_base.dart';

/// 下载任务状态
class DownloadState {
  static const int undefined = -2; // 未开始
  static const int scheduled = 0; // 开始调度
  static const int connecting = 1; // 开始请求
  static const int connected = 2; // 请求已接收
  static const int receiving = 3; // 接收数据
  static const int completed = 4; // 已完成
  static const int paused = 5; // 已暂停
}

/// 下载任务参数
class DownloadOptions {
  final String? method; // GET/POST
  final dynamic data; // POST数据
  final String? filename; // 保存路径
  final int? priority;
  final int? timeout;
  final int? retry;
  final int? retryInterval;

  DownloadOptions({
    this.method,
    this.data,
    this.filename,
    this.priority,
    this.timeout,
    this.retry,
    this.retryInterval,
  });
}

/// 下载任务对象
class Download {
  final String id;
  final String url;
  final DownloadOptions options;
  int state;
  String? filename;
  int downloadedSize = 0;
  int totalSize = 0;

  final StreamController<DownloadStateChangedEvent> _stateChangedController =
      StreamController.broadcast();
  Stream<DownloadStateChangedEvent> get onStateChanged =>
      _stateChangedController.stream;

  HttpClient? _httpClient;
  HttpClientRequest? _request;
  HttpClientResponse? _response;
  IOSink? _fileSink;
  bool _isPaused = false;
  bool _isAborted = false;

  Download({
    required this.id,
    required this.url,
    required this.options,
    this.state = DownloadState.undefined,
    this.filename,
  });

  Future<void> start() async {
    if (state == DownloadState.completed) return;
    state = DownloadState.scheduled;
    _emitStateChanged(0);
    _isPaused = false;
    _isAborted = false;
    try {
      print('[Downloader] 开始下载: $url');
      state = DownloadState.connecting;
      _emitStateChanged(1);
      _httpClient = HttpClient();
      final uri = Uri.parse(url);
      _request = await _httpClient!
          .openUrl(options.method?.toUpperCase() ?? 'GET', uri);
      if (options.method?.toUpperCase() == 'POST' && options.data != null) {
        _request!.headers.contentType = ContentType.json;
        _request!.write(options.data);
      }
      _response = await _request!.close();
      state = DownloadState.connected;
      _emitStateChanged(2);
      totalSize = _response!.contentLength;
      print('[Downloader] 响应 contentLength: $totalSize');
      // 生成保存路径
      final savePath = options.filename ?? await getDefaultSavePath(uri);
      print('[Downloader] 保存路径: $savePath');
      filename = savePath;
      final file = File(savePath);
      _fileSink = file.openWrite();
      state = DownloadState.receiving;
      _emitStateChanged(3);
      downloadedSize = 0;
      await for (final data in _response!) {
        if (_isAborted) {
          print('[Downloader] 用户取消下载');
          await _fileSink?.close();
          await file.delete();
          state = DownloadState.undefined;
          _emitStateChanged(0);
          return;
        }
        if (_isPaused) {
          print('[Downloader] 用户暂停下载');
          await _fileSink?.flush();
          await _fileSink?.close();
          state = DownloadState.paused;
          _emitStateChanged(5);
          return;
        }
        _fileSink?.add(data);
        downloadedSize += data.length;
        print('[Downloader] 已下载: $downloadedSize / $totalSize');
        _emitStateChanged(3);
      }
      await _fileSink?.flush();
      await _fileSink?.close();
      state = DownloadState.completed;
      print('[Downloader] 下载完成: $filename');
      _emitStateChanged(4);
    } catch (e, stack) {
      print('[Downloader] 下载异常: $e\n$stack');
      state = DownloadState.completed;
      _emitStateChanged(-1); // -1 代表失败
    } finally {
      _httpClient?.close(force: true);
    }
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    if (state == DownloadState.paused) {
      _isPaused = false;
      _resumeDownload();
    }
  }

  Future<void> _resumeDownload() async {
    try {
      print('[Downloader] 恢复下载: $url');
      state = DownloadState.connecting;
      _emitStateChanged(1);
      _httpClient = HttpClient();
      final uri = Uri.parse(url);
      _request = await _httpClient!
          .openUrl(options.method?.toUpperCase() ?? 'GET', uri);
      if (downloadedSize > 0) {
        _request!.headers.add('Range', 'bytes=$downloadedSize-');
      }
      _response = await _request!.close();
      state = DownloadState.connected;
      _emitStateChanged(2);
      final file = File(filename!);
      _fileSink = file.openWrite(mode: FileMode.append);
      state = DownloadState.receiving;
      _emitStateChanged(3);
      await for (final data in _response!) {
        if (_isAborted) {
          print('[Downloader] 用户取消下载');
          await _fileSink?.close();
          await file.delete();
          state = DownloadState.undefined;
          _emitStateChanged(0);
          return;
        }
        if (_isPaused) {
          print('[Downloader] 用户暂停下载');
          await _fileSink?.flush();
          await _fileSink?.close();
          state = DownloadState.paused;
          _emitStateChanged(5);
          return;
        }
        _fileSink?.add(data);
        downloadedSize += data.length;
        print('[Downloader] 已下载: $downloadedSize');
        _emitStateChanged(3);
      }
      await _fileSink?.flush();
      await _fileSink?.close();
      state = DownloadState.completed;
      print('[Downloader] 下载完成: $filename');
      _emitStateChanged(4);
    } catch (e, stack) {
      print('[Downloader] 恢复下载异常: $e\n$stack');
      state = DownloadState.completed;
      _emitStateChanged(-1);
    } finally {
      _httpClient?.close(force: true);
    }
  }

  void abort() {
    _isAborted = true;
  }

  void _emitStateChanged(int status) {
    _stateChangedController.add(DownloadStateChangedEvent(this, status));
  }
}

Future<String> getDefaultSavePath(Uri uri) async {
  final dir = await getApplicationDocumentsDirectory();
  final name =
      uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'downloaded_file';
  return '${dir.path}/$name';
}

/// 下载任务状态变化事件
class DownloadStateChangedEvent {
  final Download download;
  final int status;
  DownloadStateChangedEvent(this.download, this.status);
}

/// 下载任务完成回调
typedef DownloadCompletedCallback = void Function(
    Download download, int status);

/// Downloader 管理器
class Downloader {
  static final Downloader _instance = Downloader._internal();
  factory Downloader() => _instance;
  Downloader._internal();

  final Map<String, Download> _tasks = {};

  /// 创建下载任务
  Download createDownload(
    String url, {
    DownloadOptions? options,
    DownloadCompletedCallback? completedCB,
  }) {
    // TODO: 生成唯一ID
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final task = Download(
      id: id,
      url: url,
      options: options ?? DownloadOptions(),
    );
    _tasks[id] = task;
    // TODO: 绑定完成回调
    return task;
  }

  /// 枚举下载任务
  List<Download> enumerate({int? state}) {
    if (state == null) return _tasks.values.toList();
    return _tasks.values.where((d) => d.state == state).toList();
  }

  /// 清除下载任务
  void clear({int? state}) {
    if (state == null) {
      _tasks
          .removeWhere((key, value) => value.state != DownloadState.completed);
    } else {
      _tasks.removeWhere((key, value) => value.state == state);
    }
  }

  /// 启动所有未开始/暂停的任务
  void startAll() {
    for (final d in _tasks.values) {
      if (d.state == DownloadState.undefined ||
          d.state == DownloadState.paused) {
        d.start();
      }
    }
  }
}

class PlusDownloaderModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'downloader';

  final Downloader _downloader = Downloader();

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'createDownload':
        final url = params['url'] as String;
        final options = params['options'] != null
            ? DownloadOptions(
                method: params['options']['method'] as String?,
                data: params['options']['data'],
                filename: params['options']['filename'] as String?,
                priority: params['options']['priority'] as int?,
                timeout: params['options']['timeout'] as int?,
                retry: params['options']['retry'] as int?,
                retryInterval: params['options']['retryInterval'] as int?,
              )
            : null;
        final task = _downloader.createDownload(url, options: options);
        task.start();
        return {'id': task.id, 'filename': task.filename};
      case 'enumerate':
        final state = params?['state'] as int?;
        final tasks = _downloader.enumerate(state: state);
        return tasks
            .map((d) => {
                  'id': d.id,
                  'url': d.url,
                  'state': d.state,
                  'filename': d.filename,
                  'downloadedSize': d.downloadedSize,
                  'totalSize': d.totalSize,
                })
            .toList();
      case 'clear':
        final state = params?['state'] as int?;
        _downloader.clear(state: state);
        return true;
      case 'startAll':
        _downloader.startAll();
        return true;
      case 'pause':
        final id = params['id'] as String;
        final task = _downloader
            .enumerate()
            .firstWhere((d) => d.id == id, orElse: () => null as Download);
        task?.pause();
        return true;
      case 'resume':
        final id = params['id'] as String;
        final task = _downloader
            .enumerate()
            .firstWhere((d) => d.id == id, orElse: () => null as Download);
        task?.resume();
        return true;
      case 'abort':
        final id = params['id'] as String;
        final task = _downloader
            .enumerate()
            .firstWhere((d) => d.id == id, orElse: () => null as Download);
        task?.abort();
        return true;

      default:
        return null;
    }
  }

  @override
  String get jsCode => '''
    // plus.downloader 模块注入
    window.plus.downloader = {
      _tasks: {},
      createDownload: function(url, options, completedCB) {
        return window.flutter_invoke('downloader.createDownload', { url: url, options: options || {} }).then(function(res) {
          var task = {
            id: res.id,
            filename: res.filename,
            url: url,
            _listeners: {},
            start: function() {
              window.flutter_invoke('downloader.start', { id: this.id });
            },
            pause: function() {
              window.flutter_invoke('downloader.pause', { id: this.id });
            },
            resume: function() {
              window.flutter_invoke('downloader.resume', { id: this.id });
            },
            abort: function() {
              window.flutter_invoke('downloader.abort', { id: this.id });
            },
            addEventListener: function(event, cb) {
              if (event === 'statechanged') {
                this._listeners[event] = cb;
              }
            }
          };
          // 轮询监听状态变化
          var poll = setInterval(function() {
            window.flutter_invoke('downloader.enumerate', {}).then(function(tasks) {
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
      }
    };
  ''';
}
