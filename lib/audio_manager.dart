import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgPlayer = AudioPlayer();
  bool _musicEnabled = true;
  bool _isPlaying = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _musicEnabled = prefs.getBool('music_enabled') ?? true;

    if (_musicEnabled && !_isPlaying) {
      await _playBackgroundMusic();
    }
  }

  Future<void> toggleMusic(bool enabled) async {
    _musicEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', enabled);

    if (_musicEnabled) {
      await _playBackgroundMusic();
    } else {
      await _bgPlayer.stop();
      _isPlaying = false;
    }
  }

  bool get isMusicEnabled => _musicEnabled;

  Future<void> _playBackgroundMusic() async {
    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(0.5); 
      await _bgPlayer.setSource(AssetSource('game_music.mp3'));
      await _bgPlayer.resume();
      _isPlaying = true;
    } catch (e) {
      print('Failed to play background music: $e');
      _isPlaying = false;
    }
  }

  Future<void> dispose() async {
    await _bgPlayer.dispose();
  }
}
