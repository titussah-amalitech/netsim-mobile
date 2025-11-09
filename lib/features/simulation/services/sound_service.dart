import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer();
  bool _isMuted = false;
  bool _isBackgroundMusicPlaying = false;

  bool get isMuted => _isMuted;
  bool get isBackgroundMusicPlaying => _isBackgroundMusicPlaying;

  Future<void> playErrorSound() async {
    if (_isMuted) return;
    await _player.play(AssetSource('sounds/alarm.mp3'));
  }

  Future<void> playSuccessSound() async {
    if (_isMuted) return;
    await _player.play(AssetSource('sounds/alarm.mp3'));
  }

  Future<void> playGameOverSound() async {
    if (_isMuted) return;
    await _player.play(AssetSource('sounds/alarm.mp3'));
  }

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  Future<void> startBackgroundMusic() async {
    if (_isMuted || _isBackgroundMusicPlaying) return;
    _isBackgroundMusicPlaying = true;
    await _bgPlayer.setReleaseMode(ReleaseMode.loop); // Makes the audio loop
    await _bgPlayer.play(AssetSource('sounds/alarm.mp3'));
    await _bgPlayer.setVolume(0.3); // Set volume to 30%
  }

  Future<void> stopBackgroundMusic() async {
    if (!_isBackgroundMusicPlaying) return;
    _isBackgroundMusicPlaying = false;
    await _bgPlayer.stop();
  }

  void toggleMusicAndSound() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      stopBackgroundMusic();
    } else {
      startBackgroundMusic();
    }
  }

  void dispose() {
    stopBackgroundMusic();
    _player.dispose();
    _bgPlayer.dispose();
  }
}

final soundServiceProvider = Provider((ref) => SoundService());