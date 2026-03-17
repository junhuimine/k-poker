/// 🎴 K-Poker — 다국어(i18n) 시스템
///
/// 기기 기본 언어 자동 감지 + 10개 언어 지원
/// 하드코딩 없이 모든 UI 텍스트를 중앙 관리

import 'package:flutter/material.dart';

/// 지원 언어 목록 (10개)
enum AppLanguage {
  ko, // 한국어
  en, // English
  ja, // 日本語
  zhCn, // 简体中文
  zhTw, // 繁體中文
  es, // Español
  fr, // Français
  de, // Deutsch
  pt, // Português
  th, // ภาษาไทย
}

/// 언어 표시 이름
const Map<AppLanguage, String> languageNames = {
  AppLanguage.ko: '한국어',
  AppLanguage.en: 'English',
  AppLanguage.ja: '日本語',
  AppLanguage.zhCn: '简体中文',
  AppLanguage.zhTw: '繁體中文',
  AppLanguage.es: 'Español',
  AppLanguage.fr: 'Français',
  AppLanguage.de: 'Deutsch',
  AppLanguage.pt: 'Português',
  AppLanguage.th: 'ภาษาไทย',
};

/// 시스템 로케일 -> AppLanguage 변환
AppLanguage detectLanguage(Locale locale) {
  switch (locale.languageCode) {
    case 'ko': return AppLanguage.ko;
    case 'ja': return AppLanguage.ja;
    case 'zh':
      if (locale.scriptCode == 'Hant' || locale.countryCode == 'TW' || locale.countryCode == 'HK') {
        return AppLanguage.zhTw;
      }
      return AppLanguage.zhCn;
    case 'es': return AppLanguage.es;
    case 'fr': return AppLanguage.fr;
    case 'de': return AppLanguage.de;
    case 'pt': return AppLanguage.pt;
    case 'th': return AppLanguage.th;
    default: return AppLanguage.en;
  }
}

/// 모든 UI 텍스트의 번역 키
class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  String get appTitle => _t({
    AppLanguage.ko: 'K-Poker: 화투 타짜',
    AppLanguage.en: 'K-Poker: Hwatu Gambler',
    AppLanguage.ja: 'K-Poker: 花札の勝負師',
    AppLanguage.zhCn: 'K-Poker: 花牌赌神',
    AppLanguage.zhTw: 'K-Poker: 花牌賭神',
    AppLanguage.es: 'K-Poker: Apostador Hwatu',
    AppLanguage.fr: 'K-Poker: Joueur de Hwatu',
    AppLanguage.de: 'K-Poker: Hwatu-Spieler',
    AppLanguage.pt: 'K-Poker: Jogador de Hwatu',
    AppLanguage.th: 'K-Poker: นักพนันฮวาตู',
  });

  String get startGame => _t({
    AppLanguage.ko: '게임 시작',
    AppLanguage.en: 'Start Game',
    AppLanguage.ja: 'ゲーム開始',
    AppLanguage.zhCn: '开始游戏',
    AppLanguage.zhTw: '開始遊戲',
    AppLanguage.es: 'Iniciar Juego',
    AppLanguage.fr: 'Commencer',
    AppLanguage.de: 'Spiel starten',
    AppLanguage.pt: 'Iniciar Jogo',
    AppLanguage.th: 'เริ่มเกม',
  });

  String get totalScore => _t({
    AppLanguage.ko: '총 점수',
    AppLanguage.en: 'TOTAL SCORE',
    AppLanguage.ja: '合計スコア',
    AppLanguage.zhCn: '总分',
    AppLanguage.zhTw: '總分',
    AppLanguage.es: 'PUNTUACIÓN TOTAL',
    AppLanguage.fr: 'SCORE TOTAL',
    AppLanguage.de: 'GESAMTPUNKTZAHL',
    AppLanguage.pt: 'PONTUAÇÃO TOTAL',
    AppLanguage.th: 'คะแนนรวม',
  });

  String get score => _t({
    AppLanguage.ko: '점수',
    AppLanguage.en: 'Score',
    AppLanguage.ja: 'スコア',
    AppLanguage.zhCn: '分数',
    AppLanguage.zhTw: '分數',
    AppLanguage.es: 'Puntuación',
    AppLanguage.fr: 'Score',
    AppLanguage.de: 'Punktzahl',
    AppLanguage.pt: 'Pontuação',
    AppLanguage.th: 'คะแนน',
  });

  String get goDecision => _t({
    AppLanguage.ko: '고!',
    AppLanguage.en: 'Go!',
    AppLanguage.ja: 'ゴー！',
    AppLanguage.zhCn: '继续！',
    AppLanguage.zhTw: '繼續！',
    AppLanguage.es: '¡Seguir!',
    AppLanguage.fr: 'Continuer !',
    AppLanguage.de: 'Weiter!',
    AppLanguage.pt: 'Continuar!',
    AppLanguage.th: 'ไปต่อ!',
  });

  String get stopDecision => _t({
    AppLanguage.ko: '스톱!',
    AppLanguage.en: 'Stop!',
    AppLanguage.ja: 'ストップ！',
    AppLanguage.zhCn: '停止！',
    AppLanguage.zhTw: '停止！',
    AppLanguage.es: '¡Parar!',
    AppLanguage.fr: 'Arrêter !',
    AppLanguage.de: 'Stopp!',
    AppLanguage.pt: 'Parar!',
    AppLanguage.th: 'หยุด!',
  });

  String get shop => _t({
    AppLanguage.ko: '상점',
    AppLanguage.en: 'Shop',
    AppLanguage.ja: 'ショップ',
    AppLanguage.zhCn: '商店',
    AppLanguage.zhTw: '商店',
    AppLanguage.es: 'Tienda',
    AppLanguage.fr: 'Boutique',
    AppLanguage.de: 'Laden',
    AppLanguage.pt: 'Loja',
    AppLanguage.th: 'ร้านค้า',
  });

  String get nextStage => _t({
    AppLanguage.ko: '다음 스테이지',
    AppLanguage.en: 'Next Stage',
    AppLanguage.ja: '次のステージ',
    AppLanguage.zhCn: '下一关',
    AppLanguage.zhTw: '下一關',
    AppLanguage.es: 'Siguiente Etapa',
    AppLanguage.fr: 'Étape suivante',
    AppLanguage.de: 'Nächste Stufe',
    AppLanguage.pt: 'Próxima Fase',
    AppLanguage.th: 'ด่านถัดไป',
  });

  String get gameOver => _t({
    AppLanguage.ko: '게임 오버',
    AppLanguage.en: 'Game Over',
    AppLanguage.ja: 'ゲームオーバー',
    AppLanguage.zhCn: '游戏结束',
    AppLanguage.zhTw: '遊戲結束',
    AppLanguage.es: 'Fin del Juego',
    AppLanguage.fr: 'Fin de Partie',
    AppLanguage.de: 'Spiel vorbei',
    AppLanguage.pt: 'Fim de Jogo',
    AppLanguage.th: 'จบเกม',
  });

  String get settings => _t({
    AppLanguage.ko: '설정',
    AppLanguage.en: 'Settings',
    AppLanguage.ja: '設定',
    AppLanguage.zhCn: '设置',
    AppLanguage.zhTw: '設定',
    AppLanguage.es: 'Configuración',
    AppLanguage.fr: 'Paramètres',
    AppLanguage.de: 'Einstellungen',
    AppLanguage.pt: 'Configurações',
    AppLanguage.th: 'การตั้งค่า',
  });

  String get language_ => _t({
    AppLanguage.ko: '언어',
    AppLanguage.en: 'Language',
    AppLanguage.ja: '言語',
    AppLanguage.zhCn: '语言',
    AppLanguage.zhTw: '語言',
    AppLanguage.es: 'Idioma',
    AppLanguage.fr: 'Langue',
    AppLanguage.de: 'Sprache',
    AppLanguage.pt: 'Idioma',
    AppLanguage.th: 'ภาษา',
  });

  /// 번역 헬퍼
  String _t(Map<AppLanguage, String> translations) {
    return translations[language] ?? translations[AppLanguage.en] ?? '';
  }
}
