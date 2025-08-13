import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'plus_bridge_base.dart';
// import 'dart:developer'; // 不再需要

/// 音频播放器参数，完全对标 H5+ AudioPlayerStyles
class AudioPlayerStyles {
  final bool autoplay;
  final bool backgroundControl;
  final String? coverImgUrl;
  final String? epname;
  final bool loop;
  final double playbackRate;
  final String? singer;
  final String src;
  final double startTime;
  final String? title;
  final double volume;

  AudioPlayerStyles({
    required this.src,
    this.autoplay = false,
    this.backgroundControl = false,
    this.coverImgUrl,
    this.epname,
    this.loop = false,
    this.playbackRate = 1.0,
    this.singer,
    this.startTime = 0.0,
    this.title,
    this.volume = 1.0,
  });

  factory AudioPlayerStyles.fromMap(Map<String, dynamic> map) {
    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      if (v is num) return v != 0;
      return false;
    }

    return AudioPlayerStyles(
      src: map['src']?.toString() ?? '',
      autoplay: parseBool(map['autoplay']),
      backgroundControl: parseBool(map['backgroundControl']),
      coverImgUrl: map['coverImgUrl']?.toString(),
      epname: map['epname']?.toString(),
      loop: parseBool(map['loop']),
      playbackRate: map['playbackRate'] != null
          ? double.tryParse(map['playbackRate'].toString()) ?? 1.0
          : 1.0,
      singer: map['singer']?.toString(),
      startTime: map['startTime'] != null
          ? double.tryParse(map['startTime'].toString()) ?? 0.0
          : 0.0,
      title: map['title']?.toString(),
      volume: map['volume'] != null
          ? double.tryParse(map['volume'].toString()) ?? 1.0
          : 1.0,
    );
  }
}

/// 音频播放器实例管理
class _AudioPlayerInstance {
  final AudioPlayer player;
  final AudioPlayerStyles styles;
  InAppWebViewController? controller;
  StreamSubscription? _playingSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _posSub;
  StreamSubscription? _errorSub;
  _AudioPlayerInstance(this.player, this.styles, this.controller);
  void dispose() {
    _playingSub?.cancel();
    _stateSub?.cancel();
    _posSub?.cancel();
    _errorSub?.cancel();
    player.dispose();
  }
}

class PlusAudioModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'audio';

  // 多实例管理，key 可用 uuid 或自增 id
  final Map<String, _AudioPlayerInstance> _players = {};
  InAppWebViewController? _webViewController;

  // 新增：全局后台播放器
  _AudioPlayerInstance? _backgroundPlayerInstance;
  String? _backgroundPlayerId;

  void setWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
  }

  void _bindEvents(String id, _AudioPlayerInstance instance) {
    final player = instance.player;
    final controller = instance.controller ?? _webViewController;
    print(
        '[plus_audio] _bindEvents for id=$id, controller=${controller != null}');
    if (controller == null) return;
    // 播放/暂停事件
    instance._playingSub = player.playingStream.listen((playing) {
      print('[plus_audio] playingStream id=$id, playing=$playing');
      controller.evaluateJavascript(
          source:
              "window.plus && window.plus._audioEvent && window.plus._audioEvent('$id','${playing ? 'onPlay' : 'onPause'}')");
    });
    // 状态事件
    instance._stateSub = player.playerStateStream.listen((state) {
      print(
          '[plus_audio] playerStateStream id=$id, state=${state.processingState}, playing=${state.playing}');
      if (state.processingState == ProcessingState.completed) {
        controller.evaluateJavascript(
            source:
                "window.plus && window.plus._audioEvent && window.plus._audioEvent('$id','onEnded')");
      } else if (state.processingState == ProcessingState.idle &&
          !state.playing) {
        controller.evaluateJavascript(
            source:
                "window.plus && window.plus._audioEvent && window.plus._audioEvent('$id','onStop')");
      } else if (state.processingState == ProcessingState.idle &&
          state.playing == false) {
        controller.evaluateJavascript(
            source:
                "window.plus && window.plus._audioEvent && window.plus._audioEvent('$id','onError')");
      }
    });
    // 进度事件
    instance._posSub = player.positionStream.listen((pos) {
      print('[plus_audio] positionStream id=$id, position=$pos');
      controller.evaluateJavascript(
          source:
              "window.plus && window.plus._audioEvent && window.plus._audioEvent('$id','onTimeUpdate')");
    });
  }

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'setWebViewController':
        if (params is InAppWebViewController) setWebViewController(params);
        return true;
      case 'createPlayer':
        final id = UniqueKey().toString();
        final styles = params is Map<String, dynamic>
            ? AudioPlayerStyles.fromMap(params)
            : AudioPlayerStyles(src: '');
        final player = AudioPlayer();
        final controller = _webViewController;
        final instance = _AudioPlayerInstance(player, styles, controller);
        _players[id] = instance;
        if (styles.backgroundControl) {
          _backgroundPlayerInstance = instance;
          _backgroundPlayerId = id;
        }
        await player.setUrl(styles.src);
        await player.setVolume(styles.volume);
        await player.setSpeed(styles.playbackRate);
        if (styles.loop) {
          player.setLoopMode(LoopMode.one);
        }
        if (styles.startTime > 0) {
          await player.seek(Duration(seconds: styles.startTime.toInt()));
        }
        if (styles.autoplay) {
          player.play();
        }
        _bindEvents(id, instance);
        return {'id': id};
      case 'play':
        {
          final id = params['id']?.toString();
          _AudioPlayerInstance? instance = _players[id];
          if (instance == null && _backgroundPlayerId == id) {
            instance = _backgroundPlayerInstance;
          }
          print('[plus_audio] play id=$id, instance=${instance != null}');
          if (instance == null) return {'error': 'player not found'};
          await instance.player.play();
          return {'success': true};
        }
      case 'pause':
        {
          final id = params['id']?.toString();
          _AudioPlayerInstance? instance = _players[id];
          if (instance == null && _backgroundPlayerId == id) {
            instance = _backgroundPlayerInstance;
          }
          print('[plus_audio] pause id=$id, instance=${instance != null}');
          if (instance == null) return {'error': 'player not found'};
          await instance.player.pause();
          return {'success': true};
        }
      case 'stop':
        {
          final id = params['id']?.toString();
          _AudioPlayerInstance? instance = _players[id];
          if (instance == null && _backgroundPlayerId == id) {
            instance = _backgroundPlayerInstance;
          }
          print('[plus_audio] stop id=$id, instance=${instance != null}');
          if (instance == null) return {'error': 'player not found'};
          await instance.player.stop();
          return {'success': true};
        }
      case 'seekTo':
        {
          final id = params['id']?.toString();
          final position = params['position'];
          _AudioPlayerInstance? instance = _players[id];
          if (instance == null && _backgroundPlayerId == id) {
            instance = _backgroundPlayerInstance;
          }
          print(
              '[plus_audio] seekTo id=$id, position=$position, instance=${instance != null}');
          if (instance == null) return {'error': 'player not found'};
          if (position == null) return {'error': 'position required'};
          await instance.player.seek(Duration(
              seconds: double.tryParse(position.toString())?.toInt() ?? 0));
          return {'success': true};
        }
      case 'setLoop':
        {
          final id = params['id']?.toString();
          final loop = params['loop'];
          _AudioPlayerInstance? instance = _players[id];
          if (instance == null && _backgroundPlayerId == id) {
            instance = _backgroundPlayerInstance;
          }
          print(
              '[plus_audio] setLoop id=$id, loop=$loop, instance=${instance != null}');
          if (instance == null) return {'error': 'player not found'};
          await instance.player
              .setLoopMode(loop == true ? LoopMode.one : LoopMode.off);
          return {'success': true};
        }
      case 'setVolume':
        {
          final id = params['id']?.toString();
          final volume = params['volume'];
          _AudioPlayerInstance? instance = _players[id];
          if (instance == null && _backgroundPlayerId == id) {
            instance = _backgroundPlayerInstance;
          }
          print(
              '[plus_audio] setVolume id=$id, volume=$volume, instance=${instance != null}');
          if (instance == null) return {'error': 'player not found'};
          await instance.player
              .setVolume(volume is num ? volume.toDouble() : 1.0);
          return {'success': true};
        }
      case 'setPlaybackRate':
        {
          final id = params['id']?.toString();
          final rate = params['playbackRate'];
          _AudioPlayerInstance? instance = _players[id];
          if (instance == null && _backgroundPlayerId == id) {
            instance = _backgroundPlayerInstance;
          }
          print(
              '[plus_audio] setPlaybackRate id=$id, rate=$rate, instance=${instance != null}');
          if (instance == null) return {'error': 'player not found'};
          await instance.player.setSpeed(rate is num ? rate.toDouble() : 1.0);
          return {'success': true};
        }
      case 'close':
        {
          final id = params['id']?.toString();
          _AudioPlayerInstance? instance = _players.remove(id);
          if (instance == null && _backgroundPlayerId == id) {
            instance = _backgroundPlayerInstance;
            _backgroundPlayerInstance = null;
            _backgroundPlayerId = null;
          }
          print('[plus_audio] close id=$id, instance=${instance != null}');
          if (instance == null) return {'error': 'player not found'};
          instance.dispose();
          return {'success': true};
        }
      case 'getCurrentPlayer':
        if (_backgroundPlayerInstance != null && _backgroundPlayerId != null) {
          // 重新绑定 controller 并 _bindEvents
          _backgroundPlayerInstance!.controller = _webViewController;
          _bindEvents(_backgroundPlayerId!, _backgroundPlayerInstance!);
          print(
              '[plus_audio] getCurrentPlayer: rebind controller for id=$_backgroundPlayerId');
          final player = _backgroundPlayerInstance!.player;
          final styles = _backgroundPlayerInstance!.styles;
          print(
              '[plus_audio] getCurrentPlayer: id=$_backgroundPlayerId, position=${player.position}, playing=${player.playing}, duration=${player.duration}');
          return {
            'id': _backgroundPlayerId,
            'src': styles.src,
            'position': player.position.inSeconds,
            'duration': player.duration?.inSeconds ?? 0,
            'paused': !player.playing,
            'loop': player.loopMode == LoopMode.one,
            'title': styles.title,
            'singer': styles.singer,
            'epname': styles.epname,
            'coverImgUrl': styles.coverImgUrl,
          };
        }
        print('[plus_audio] getCurrentPlayer: no background player');
        return null;
      case 'getProperty':
        final id = params['id']?.toString();
        final property = params['property']?.toString();
        _AudioPlayerInstance? instance = _players[id];
        if (instance == null && _backgroundPlayerId == id) {
          instance = _backgroundPlayerInstance;
        }
        print(
            '[plus_audio] getProperty id=$id, property=$property, instance=${instance != null}');
        if (instance == null) return {'error': 'player not found'};
        final player = instance.player;
        switch (property) {
          case 'src':
            return instance.styles.src;
          case 'duration':
            return player.duration?.inSeconds ?? 0;
          case 'position':
            return player.position.inSeconds;
          case 'paused':
            return !player.playing;
          case 'loop':
            return player.loopMode == LoopMode.one;
          default:
            return null;
        }
      default:
        return {'error': 'Unknown audio method'};
    }
  }

  @override
  String get jsCode => '''
    // plus.audio 模块注入，兼容 H5+
    window.plus._audioEvent = function(id, event) {
      if (window.plus._audioPlayers && window.plus._audioPlayers[id]) {
        var player = window.plus._audioPlayers[id];
        var handler = player[event];
        if (typeof handler === 'function') handler();
      }
    };
    window.plus._audioPlayers = window.plus._audioPlayers || {};
    window.plus.audio = {
      createPlayer: function(options) {
        return window.flutter_invoke('audio.createPlayer', options).then(function(res) {
          if (!res || !res.id) return null;
          var id = res.id;
          var player = {
            id: id,
            play: function() { return window.flutter_invoke('audio.play', {id: id}); },
            pause: function() { return window.flutter_invoke('audio.pause', {id: id}); },
            stop: function() { return window.flutter_invoke('audio.stop', {id: id}); },
            seekTo: function(position) { return window.flutter_invoke('audio.seekTo', {id: id, position: position}); },
            setLoop: function(loop) { return window.flutter_invoke('audio.setLoop', {id: id, loop: loop}); },
            setVolume: function(volume) { return window.flutter_invoke('audio.setVolume', {id: id, volume: volume}); },
            setPlaybackRate: function(rate) { return window.flutter_invoke('audio.setPlaybackRate', {id: id, playbackRate: rate}); },
            close: function() { return window.flutter_invoke('audio.close', {id: id}); },
            getProperty: function(property) { return window.flutter_invoke('audio.getProperty', {id: id, property: property}); },
            // H5+ 风格事件注册
            onPlay: null,
            onPause: null,
            onStop: null,
            onEnded: null,
            onError: null,
            onTimeUpdate: null
          };
          window.plus._audioPlayers[id] = player;
          return player;
        });
      },
      getCurrentPlayer: function() {
          return window.flutter_invoke('audio.getCurrentPlayer').then(function(res) {
          if (!res || !res.id) return null;
          var id = res.id;
          var player = {
            id: id,
            play: function() { return window.flutter_invoke('audio.play', {id: id}); },
            pause: function() { return window.flutter_invoke('audio.pause', {id: id}); },
            stop: function() { return window.flutter_invoke('audio.stop', {id: id}); },
            seekTo: function(position) { return window.flutter_invoke('audio.seekTo', {id: id, position: position}); },
            setLoop: function(loop) { return window.flutter_invoke('audio.setLoop', {id: id, loop: loop}); },
            setVolume: function(volume) { return window.flutter_invoke('audio.setVolume', {id: id, volume: volume}); },
            setPlaybackRate: function(rate) { return window.flutter_invoke('audio.setPlaybackRate', {id: id, playbackRate: rate}); },
            close: function() { return window.flutter_invoke('audio.close', {id: id}); },
            getProperty: function(property) { return window.flutter_invoke('audio.getProperty', {id: id, property: property}); },
            // H5+ 风格事件注册
            onPlay: null,
            onPause: null,
            onStop: null,
            onEnded: null,
            onError: null,
            onTimeUpdate: null
          };
          window.plus._audioPlayers[id] = player;
          return player;
          });
      }
    };
  ''';
}
