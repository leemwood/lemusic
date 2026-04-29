import 'dart:async';

import 'models.dart';

enum PlayerStatus { idle, buffering, playing, paused, ended, error }

class PlayerState {
  final PlayerStatus status;
  final Track? current;
  final Object? error;

  const PlayerState({required this.status, this.current, this.error});
}

abstract class PlayerEngine {
  Future<void> play(Track track);
  Future<void> pause();
  Future<void> stop();
}

/// 直链播放：预留给 just_audio + audio_service
class DirectAudioEngine implements PlayerEngine {
  @override
  Future<void> pause() async {}

  @override
  Future<void> play(Track track) async {
    // TODO: 接入 just_audio
  }

  @override
  Future<void> stop() async {}
}

/// WebView 播放：预留给酷狗 mini-player H5 + JS bridge
class WebPlayerEngine implements PlayerEngine {
  @override
  Future<void> pause() async {}

  @override
  Future<void> play(Track track) async {
    // TODO: 通过 WebView 注入 JS 控制播放
  }

  @override
  Future<void> stop() async {}
}

/// 外部打开：使用 url_launcher 打开 deeplink / https
class ExternalOpenEngine implements PlayerEngine {
  @override
  Future<void> pause() async {}

  @override
  Future<void> play(Track track) async {
    // TODO: 由 UI 层调用 url_launcher，Engine 仅作占位
  }

  @override
  Future<void> stop() async {}
}

class PlayerFacade {
  final _state = StreamController<PlayerState>.broadcast();
  PlayerState _currentState = const PlayerState(status: PlayerStatus.idle);

  Stream<PlayerState> get states => _state.stream;
  PlayerState get snapshot => _currentState;

  final List<Track> _queue = [];
  int _index = -1;

  final PlayerEngine directEngine;
  final PlayerEngine webEngine;
  final PlayerEngine externalEngine;

  PlayerFacade({
    PlayerEngine? directEngine,
    PlayerEngine? webEngine,
    PlayerEngine? externalEngine,
  })  : directEngine = directEngine ?? DirectAudioEngine(),
        webEngine = webEngine ?? WebPlayerEngine(),
        externalEngine = externalEngine ?? ExternalOpenEngine();

  void setQueue(List<Track> tracks, {int startIndex = 0}) {
    _queue
      ..clear()
      ..addAll(tracks);
    _index = _queue.isEmpty ? -1 : startIndex.clamp(0, _queue.length - 1);
    _emit(PlayerState(status: PlayerStatus.idle, current: current));
  }

  Track? get current => (_index >= 0 && _index < _queue.length) ? _queue[_index] : null;

  Future<void> playCurrent() async {
    final track = current;
    if (track == null) return;
    _emit(PlayerState(status: PlayerStatus.buffering, current: track));
    try {
      final engine = _pickEngine(track.playability);
      await engine.play(track);
      _emit(PlayerState(status: PlayerStatus.playing, current: track));
    } catch (e) {
      _emit(PlayerState(status: PlayerStatus.error, current: track, error: e));
    }
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    _index = (_index + 1) % _queue.length;
    await playCurrent();
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    _index = (_index - 1) < 0 ? _queue.length - 1 : _index - 1;
    await playCurrent();
  }

  PlayerEngine _pickEngine(Playability p) {
    return switch (p) {
      DirectStreamPlayability() => directEngine,
      EmbeddedWebPlayability() => webEngine,
      ExternalOpenPlayability() => externalEngine,
    };
  }

  void _emit(PlayerState s) {
    _currentState = s;
    _state.add(s);
  }

  void dispose() {
    _state.close();
  }
}

