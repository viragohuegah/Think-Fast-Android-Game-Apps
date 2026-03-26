import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Singleton audio service. Call [AudioService.instance].
/// All methods are fire-and-forget — they never throw to the caller.
final class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  // Dedicated players per sound so overlapping is possible
  final AudioPlayer _correct = AudioPlayer();
  final AudioPlayer _wrong = AudioPlayer();
  final AudioPlayer _tick = AudioPlayer();
  final AudioPlayer _roundStart = AudioPlayer();
  final AudioPlayer _roundEnd = AudioPlayer();

  bool _initialized = false;
  bool _muted = false;

  bool get muted => _muted;
  set muted(bool value) => _muted = value;

  Future<void> init() async {
    if (_initialized) return;
    try {
      // Lower latency mode on Android
      await _correct.setPlayerMode(PlayerMode.lowLatency);
      await _wrong.setPlayerMode(PlayerMode.lowLatency);
      await _tick.setPlayerMode(PlayerMode.lowLatency);
      await _roundStart.setPlayerMode(PlayerMode.lowLatency);
      await _roundEnd.setPlayerMode(PlayerMode.lowLatency);

      // Pre-cache for near-zero latency
      await AudioCache.instance.loadAll([
        'audio/correct.mp3',
        'audio/wrong.mp3',
        'audio/countdown_tick.mp3',
        'audio/round_end.mp3',
        'audio/round_start.mp3',
      ]);

      _initialized = true;
    } catch (e) {
      debugPrint('[AudioService] init error: $e');
    }
  }

  Future<void> playCorrect() => _play(_correct, 'audio/correct.mp3');
  Future<void> playWrong() => _play(_wrong, 'audio/wrong.mp3');
  Future<void> playTick() => _play(_tick, 'audio/countdown_tick.mp3');
  Future<void> playRoundStart() => _play(_roundStart, 'audio/round_start.mp3');
  Future<void> playRoundEnd() => _play(_roundEnd, 'audio/round_end.mp3');

  Future<void> _play(AudioPlayer player, String asset) async {
    if (_muted) return;
    try {
      await player.stop();
      await player.play(AssetSource(asset));
    } catch (e) {
      debugPrint('[AudioService] play error ($asset): $e');
    }
  }

  Future<void> dispose() async {
    await _correct.dispose();
    await _wrong.dispose();
    await _tick.dispose();
    await _roundStart.dispose();
    await _roundEnd.dispose();
  }
}
