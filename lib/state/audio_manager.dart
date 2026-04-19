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
  Timer? _bgmNextTimer;   // 현재 곡 길이에 맞춰 예약된 다음 곡 전환 타이머
  Timer? _bgmFailsafe;    // onPlayerComplete + duration 둘 다 실패할 때의 최후 방어 (5분)

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

    // 🎯 release 모드 + duration 기반 정확한 전환 스케줄링
    //
    // 배경: 이전엔 ReleaseMode.loop + Timer.periodic(110초)로 강제 전환했는데,
    // 곡 길이(100~180초)와 주기가 맞지 않아 중간에 끊기거나 부자연스러운 페이드가 발생.
    //
    // 개선 (2026-04-19): 곡을 한 번만 재생(release)하고, onDurationChanged로 얻은
    // 실제 곡 길이에 맞춰 정확히 "곡 끝나기 300ms 전"에 다음 곡으로 전환 예약.
    // → 자연스러운 곡 종료 직전에 매끄러운 전환. 침묵/끊김 최소화.
    // onPlayerComplete는 백업 경로로 유지 (duration이 null이거나 이벤트가 늦을 때).
    _bgmPlayer.setReleaseMode(ReleaseMode.release);
    await _bgmPlayer.setVolume(_bgmMuted ? 0 : _bgmVolume);

    // 주 경로: 곡이 로드되면 duration이 방출됨 → 그 길이에 맞춰 전환 예약
    _bgmPlayer.onDurationChanged.listen(_scheduleNextFromDuration);

    // 백업 경로: 이벤트가 정상이면 완료 시점에 즉시 다음 곡
    _bgmPlayer.onPlayerComplete.listen((_) => _advanceIfNeeded('onPlayerComplete'));
    _bgmPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _advanceIfNeeded('onPlayerStateChanged');
      }
    });
  }

  /// 현재 재생 중인 곡의 실제 길이에 맞춰 다음 곡 전환 시점 예약.
  /// duration 이 null/0이거나 비정상이면 무시 (onPlayerComplete 경로에 맡김).
  void _scheduleNextFromDuration(Duration duration) {
    _bgmNextTimer?.cancel();
    _bgmFailsafe?.cancel();
    final ms = duration.inMilliseconds;
    if (ms <= 2000) return; // 너무 짧으면 무시 (잘못된 메타)

    // 곡 끝 300ms 전에 전환 → 자연스러운 페이드아웃 직전
    final leadMs = ms > 1000 ? ms - 300 : ms;
    _bgmNextTimer = Timer(Duration(milliseconds: leadMs), () {
      if (!_bgmLoopStarted || _bgmMuted) return;
      _advanceIfNeeded('duration-scheduled');
    });

    // 최후 방어: 곡 길이 + 30초가 지나도 다음 곡 전환이 없으면 강제 전환
    _bgmFailsafe = Timer(Duration(milliseconds: ms + 30000), () {
      if (!_bgmLoopStarted || _bgmMuted) return;
      _advanceIfNeeded('failsafe');
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
    _bgmNextTimer?.cancel();
    _bgmFailsafe?.cancel();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
