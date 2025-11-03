import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  Future<void> playErrorSound() async {
    if (_isMuted) return;
    await _player.play(AssetSource('sounds/error.mp3'));
  }

  Future<void> playSuccessSound() async {
    if (_isMuted) return;
    await _player.play(AssetSource('sounds/success.mp3'));
  }

  Future<void> playGameOverSound() async {
    if (_isMuted) return;
    await _player.play(AssetSource('sounds/game_over.mp3'));
  }

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  void dispose() {
    _player.dispose();
  }
}

final soundServiceProvider = Provider((ref) => SoundService());