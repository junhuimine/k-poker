/// 🎵 K-Poker — 오디오 매니저
///
/// BGM + SFX 재생, 볼륨 관리, SharedPreferences 저장
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._();
  factory AudioManager() => _instance;
  AudioManager._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  double _bgmVolume = 0.2;
  double _sfxVolume = 0.2;
  bool _bgmMuted = false;
  bool _sfxMuted = false;
  bool _bgmLoopStarted = false; // 순환 루프가 한 번이라도 시작됐는지
  Timer? _bgmWatchdog; // 릴리스 빌드에서 onPlayerComplete 누락 방지용 폴링

  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  bool get bgmMuted => _bgmMuted;
  bool get sfxMuted => _sfxMuted;

  /// 초기화 (앱 시작 시)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _bgmVolume = prefs.getDouble('bgm_volume') ?? 0.2;
    _sfxVolume = prefs.getDouble('sfx_volume') ?? 0.3;
    // 신규 설치 시 소리 ON (이전에는 기본값 true로 되어 있어 첫 실행 시 무음)
    _bgmMuted = prefs.getBool('bgm_muted') ?? false;
    _sfxMuted = prefs.getBool('sfx_muted') ?? false;

    // 🎚️ 오디오 컨텍스트 분리 — SFX가 BGM의 오디오 포커스를 뺏지 않도록.
    // 2026-04-19 실기기 테스트: 패를 낼 때마다 SFX가 기본 gain 포커스를 요청해서
    // BGM 플레이어가 매번 음소거/정지됨. SFX는 포커스 요청 없이 재생하도록 분리.
    // ignore: prefer_const_constructors — AudioContext 생성자가 const가 아니라 런타임 구성 필요
    await _bgmPlayer.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    ));
    await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    // ignore: prefer_const_constructors
    await _sfxPlayer.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
    ));

    // 🎯 loop 모드로 설정 — 한 곡이 끝나면 즉시 처음부터 다시 재생 (침묵 0)
    //
    // 배경: 2026-04-17 실기기 에뮬 검증 결과, audioplayers 6.0 Android 릴리스 빌드에서
    // onPlayerComplete / onPlayerStateChanged 이벤트 둘 다 안정적으로 발생하지 않음.
    // → 'stop' 모드 + 이벤트 기반 다음 곡 재생 방식은 Android 릴리스에서 1곡 후 침묵.
    // → 'loop' 모드로 바꾸면 audioplayers 네이티브가 끝나면 자동 재시작해서 침묵 없음.
    // → 10곡 순환은 별도 Timer로 주기적으로 playNextBgm()을 호출해서 구현.
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_bgmMuted ? 0 : _bgmVolume);

    // 이벤트 기반 다음 곡 (정상 환경에서는 동작, 릴리스 Android에서는 안 불려도 loop이 커버)
    _bgmPlayer.onPlayerComplete.listen((_) => _advanceIfNeeded('onPlayerComplete'));
    _bgmPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _advanceIfNeeded('onPlayerStateChanged');
      }
    });

    // 주기적 곡 전환 — 같은 곡을 너무 오래 반복하지 않게 110초마다 다음 곡으로 전환.
    // BGM 파일 길이는 100~180초 범위 → 110초 주기면 대부분의 곡이 한 번 또는 약간 반복 후 전환.
    _bgmWatchdog?.cancel();
    _bgmWatchdog = Timer.periodic(const Duration(seconds: 110), (_) async {
      if (!_bgmLoopStarted || _bgmMuted) return;
      await _advanceIfNeeded('watchdog-periodic');
    });
  }

  bool _advancing = false;
  Future<void> _advanceIfNeeded(String trigger) async {
    if (_advancing) return;
    _advancing = true;
    try {
      await playNextBgm();
    } finally {
      _advancing = false;
    }
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
    'bgm_1.ogg', 'bgm_2.ogg', 'bgm_3.ogg', 'bgm_4.ogg', 'bgm_5.ogg',
    'bgm_6.ogg', 'bgm_7.ogg', 'bgm_8.ogg', 'bgm_9.ogg', 'bgm_10.ogg',
  ];
  int _currentBgmIndex = 0;

  /// 다음 BGM 재생 (순환)
  Future<void> playNextBgm() async {
    final file = _allBgm[_currentBgmIndex];
    _currentBgmIndex = (_currentBgmIndex + 1) % _allBgm.length;
    await playBgm(file);
  }

  /// BGM 시작 (게임 시작 시 호출)
  ///
  /// 이미 재생 중이면 재시작하지 않음 — 스테이지 전환 시 곡이 끊기는 문제 방지.
  /// `force: true` 를 넘기면 현재 곡을 중단하고 1번 곡부터 재시작.
  Future<void> startBgmLoop({bool force = false}) async {
    if (!force && _bgmLoopStarted) {
      // 이미 루프가 시작됐으면, 정지된 상태일 때만 현재 곡 이어서 재생
      final state = _bgmPlayer.state;
      if (state == PlayerState.playing || state == PlayerState.paused) {
        if (state == PlayerState.paused) await _bgmPlayer.resume();
        return;
      }
      // stopped/completed → 현재 인덱스에서 이어 재생
      await playNextBgm();
      return;
    }
    _bgmLoopStarted = true;
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
    _bgmWatchdog?.cancel();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
