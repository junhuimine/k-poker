/// 🎵 K-Poker — 오디오 매니저
///
/// BGM + SFX 재생, 볼륨 관리, SharedPreferences 저장

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._();
  factory AudioManager() => _instance;
  AudioManager._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  double _bgmVolume = 0.5;
  double _sfxVolume = 0.7;
  bool _bgmMuted = true;
  bool _sfxMuted = true;

  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  bool get bgmMuted => _bgmMuted;
  bool get sfxMuted => _sfxMuted;

  /// 초기화 (앱 시작 시)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _bgmVolume = prefs.getDouble('bgm_volume') ?? 0.5;
    _sfxVolume = prefs.getDouble('sfx_volume') ?? 0.7;
    _bgmMuted = prefs.getBool('bgm_muted') ?? false;
    _sfxMuted = prefs.getBool('sfx_muted') ?? false;
    
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_bgmMuted ? 0 : _bgmVolume);

    // 곡 끝나면 자동 다음 곡 (리스너 1회만 등록)
    _bgmPlayer.onPlayerComplete.listen((_) {
      playNextBgm();
    });
  }

  /// BGM 볼륨 설정
  Future<void> setBgmVolume(double vol) async {
    _bgmVolume = vol;
    await _bgmPlayer.setVolume(_bgmMuted ? 0 : vol);
    _save();
  }

  /// SFX 볼륨 설정
  Future<void> setSfxVolume(double vol) async {
    _sfxVolume = vol;
    _save();
  }

  /// BGM 뮤트 토글
  Future<void> toggleBgmMute() async {
    _bgmMuted = !_bgmMuted;
    await _bgmPlayer.setVolume(_bgmMuted ? 0 : _bgmVolume);
    _save();
  }

  /// SFX 뮤트 토글
  Future<void> toggleSfxMute() async {
    _sfxMuted = !_sfxMuted;
    _save();
  }

  /// 효과음 재생
  Future<void> playSfx(String filename) async {
    if (_sfxMuted) return;
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play(AssetSource('audio/sfx/$filename'));
    } catch (_) {}
  }

  /// BGM 재생
  Future<void> playBgm(String filename) async {
    try {
      await _bgmPlayer.setVolume(_bgmMuted ? 0 : _bgmVolume);
      await _bgmPlayer.play(AssetSource('audio/bgm/$filename'));
    } catch (_) {}
  }

  /// BGM 정지
  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  /// 편의 메서드들
  void cardPlay() => playSfx('card_play.wav');
  void cardMatch() => playSfx('card_match.wav');
  void cardSweep() => playSfx('card_sweep.wav');
  void brightCapture() => playSfx('bright_capture.wav');
  void goDeclare() => playSfx('go_declare.wav');
  void stopDeclare() => playSfx('stop_declare.wav');
  void winSound() => playSfx('win.wav');
  void loseSound() => playSfx('lose.wav');
  void shopBuy() => playSfx('shop_buy.wav');
  void stageClear() => playSfx('stage_clear.wav');

  /// BGM 10곡 순환 재생
  static const _allBgm = [
    'bgm_1.mp3', 'bgm_2.mp3', 'bgm_3.mp3', 'bgm_4.mp3', 'bgm_5.mp3',
    'bgm_6.mp3', 'bgm_7.mp3', 'bgm_8.mp3', 'bgm_9.mp3', 'bgm_10.mp3',
  ];
  int _currentBgmIndex = 0;

  /// 다음 BGM 재생 (순환)
  Future<void> playNextBgm() async {
    final file = _allBgm[_currentBgmIndex];
    _currentBgmIndex = (_currentBgmIndex + 1) % _allBgm.length;
    await playBgm(file);
  }

  /// BGM 시작 (게임 시작 시 호출)
  Future<void> startBgmLoop() async {
    _currentBgmIndex = 0;
    await playNextBgm();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bgm_volume', _bgmVolume);
    await prefs.setDouble('sfx_volume', _sfxVolume);
    await prefs.setBool('bgm_muted', _bgmMuted);
    await prefs.setBool('sfx_muted', _sfxMuted);
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
