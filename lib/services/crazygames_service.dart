/// K-Poker — CrazyGames SDK v3 서비스
///
/// dart:js_interop 기반 웹 전용 래퍼.
/// 모든 메서드는 kIsWeb 가드로 보호되어 Windows/Android 빌드에서 에러 없음.
library;

import 'dart:js_interop';
import 'package:flutter/foundation.dart' show kIsWeb;

// ─── JS Interop Extension Types ────────────────────────────────────────────

extension type CrazySDKAdCallbacks._(JSObject _) implements JSObject {
  external factory CrazySDKAdCallbacks({
    JSFunction? adStarted,
    JSFunction? adFinished,
    JSFunction? adError,
  });
}

extension type CrazySDKAdModule._(JSObject _) implements JSObject {
  external void requestAd(JSString type, CrazySDKAdCallbacks callbacks);
}

extension type CrazySDKGameModule._(JSObject _) implements JSObject {
  external void gameplayStart();
  external void gameplayStop();
  external void loadingStart();
  external void loadingStop();
  external void happytime();
}

extension type CrazySDKRoot._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> init();
  external CrazySDKAdModule get ad;
  external CrazySDKGameModule get game;
  external JSString get environment;
}

extension type CrazyGamesNamespace._(JSObject _) implements JSObject {
  external CrazySDKRoot get SDK;
}

@JS('CrazyGames')
external CrazyGamesNamespace get _crazyGamesNamespace;

// ─── CrazyGamesService ─────────────────────────────────────────────────────

/// CrazyGames SDK v3 정적 서비스 클래스.
///
/// 사용 예:
/// ```dart
/// await CrazyGamesService.init();
/// CrazyGamesService.gameplayStart();
/// CrazyGamesService.requestMidgameAd(onFinished: () { ... });
/// ```
class CrazyGamesService {
  CrazyGamesService._();

  static bool _initialized = false;

  // ─── 초기화 ──────────────────────────────────────────────────────────────

  /// SDK 초기화 (앱 시작 시 1회만 호출).
  static Future<void> init() async {
    if (!kIsWeb) return;
    if (_initialized) return;
    try {
      await _crazyGamesNamespace.SDK.init().toDart;
      _initialized = true;
    } catch (e) {
      // CrazyGames 외부 환경(로컬 개발 등)에서는 init이 실패할 수 있음 — 무시
      _log('init failed (non-CrazyGames env?): $e');
    }
  }

  // ─── 로딩 추적 ───────────────────────────────────────────────────────────

  /// 게임 에셋 로딩 시작 알림.
  static void loadingStart() {
    if (!kIsWeb) return;
    try {
      _crazyGamesNamespace.SDK.game.loadingStart();
    } catch (e) {
      _log('loadingStart error: $e');
    }
  }

  /// 게임 에셋 로딩 완료 알림.
  static void loadingStop() {
    if (!kIsWeb) return;
    try {
      _crazyGamesNamespace.SDK.game.loadingStop();
    } catch (e) {
      _log('loadingStop error: $e');
    }
  }

  // ─── 게임플레이 추적 ─────────────────────────────────────────────────────

  /// 실제 게임플레이 시작 알림 (광고 안 보여주는 구간 진입).
  static void gameplayStart() {
    if (!kIsWeb) return;
    try {
      _crazyGamesNamespace.SDK.game.gameplayStart();
    } catch (e) {
      _log('gameplayStart error: $e');
    }
  }

  /// 게임플레이 일시중단/종료 알림 (광고 허용 구간 진입).
  static void gameplayStop() {
    if (!kIsWeb) return;
    try {
      _crazyGamesNamespace.SDK.game.gameplayStop();
    } catch (e) {
      _log('gameplayStop error: $e');
    }
  }

  // ─── 행복 이벤트 ─────────────────────────────────────────────────────────

  /// 플레이어 행복 순간 알림 (승리, 특별 달성 등).
  static void happytime() {
    if (!kIsWeb) return;
    try {
      _crazyGamesNamespace.SDK.game.happytime();
    } catch (e) {
      _log('happytime error: $e');
    }
  }

  // ─── 광고 요청 ───────────────────────────────────────────────────────────

  /// 미드게임 광고 요청.
  ///
  /// [onStarted] 광고 시작 시 호출 (BGM 뮤트 권장).
  /// [onFinished] 광고 종료 시 호출 (BGM 언뮤트 + gameplayStart 권장).
  /// [onError] 광고 실패 시 호출 (gameplayStart 재개 권장).
  static void requestMidgameAd({
    void Function()? onStarted,
    void Function()? onFinished,
    void Function(String error)? onError,
  }) {
    if (!kIsWeb) return;
    try {
      final callbacks = CrazySDKAdCallbacks(
        adStarted: onStarted != null
            ? (() => onStarted()).toJS
            : null,
        adFinished: onFinished != null
            ? (() => onFinished()).toJS
            : null,
        adError: onError != null
            ? ((JSAny? err) => onError(err?.toString() ?? 'unknown')).toJS
            : null,
      );
      _crazyGamesNamespace.SDK.ad.requestAd('midgame'.toJS, callbacks);
    } catch (e) {
      _log('requestMidgameAd error: $e');
      onError?.call(e.toString());
    }
  }

  /// 보상형 광고 요청.
  ///
  /// [onStarted] 광고 시작 시 호출.
  /// [onFinished] 광고 완료 시 호출 (보상 지급 로직 여기서 실행).
  /// [onError] 광고 실패 시 호출.
  static void requestRewardedAd({
    void Function()? onStarted,
    void Function()? onFinished,
    void Function(String error)? onError,
  }) {
    if (!kIsWeb) return;
    try {
      final callbacks = CrazySDKAdCallbacks(
        adStarted: onStarted != null
            ? (() => onStarted()).toJS
            : null,
        adFinished: onFinished != null
            ? (() => onFinished()).toJS
            : null,
        adError: onError != null
            ? ((JSAny? err) => onError(err?.toString() ?? 'unknown')).toJS
            : null,
      );
      _crazyGamesNamespace.SDK.ad.requestAd('rewarded'.toJS, callbacks);
    } catch (e) {
      _log('requestRewardedAd error: $e');
      onError?.call(e.toString());
    }
  }

  // ─── 내부 유틸 ───────────────────────────────────────────────────────────

  static void _log(String message) {
    // ignore: avoid_print
    print('[CrazyGames] $message');
  }
}
