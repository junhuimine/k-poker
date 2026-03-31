/// 🎴 K-Poker — 다국어(i18n) 시스템
///
/// 기기 기본 언어 자동 감지 + 10개 언어 지원
/// 하드코딩 없이 모든 UI 텍스트를 중앙 관리
library;

import 'dart:math';
import 'package:flutter/material.dart';

import 'ai_dialogues_de.dart';
import 'ai_dialogues_en.dart';
import 'ai_dialogues_es.dart';
import 'ai_dialogues_fr.dart';
import 'ai_dialogues_ja.dart';
import 'ai_dialogues_pt.dart';
import 'ai_dialogues_th.dart';
import 'ai_dialogues_zh.dart';

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
    AppLanguage.fr: 'La partie est terminée.',
    AppLanguage.de: 'Spiel beendet',
    AppLanguage.pt: 'Fim de Jogo',
    AppLanguage.th: 'เกมจบแล้ว',
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

  // ─── [일반 UI 텍스트] ───
  String ui(String key) {
    const Map<String, Map<AppLanguage, String>> uiTexts = {
      'subtitle': {
        AppLanguage.ko: '화투 타짜의 도박',
        AppLanguage.en: 'Hwatu Roguelike',
        AppLanguage.ja: '花札ローグライク',
        AppLanguage.zhCn: '花牌肉鸽',
        AppLanguage.zhTw: '花牌肉鴿',
        AppLanguage.es: 'Roguelike Hwatu',
        AppLanguage.fr: 'Roguelike Hwatu',
        AppLanguage.de: 'Hwatu-Roguelike',
        AppLanguage.pt: 'Roguelike Hwatu',
        AppLanguage.th: 'ฮวาตูโร้กไลค์',
      },
      'settings': {
        AppLanguage.ko: '설정', AppLanguage.en: 'Settings', AppLanguage.ja: '設定', AppLanguage.zhCn: '设置', AppLanguage.zhTw: '設定',
        AppLanguage.es: 'Configuración', AppLanguage.fr: 'Paramètres', AppLanguage.de: 'Einstellungen', AppLanguage.pt: 'Configurações', AppLanguage.th: 'การตั้งค่า',
      },
      'bgm': {
        AppLanguage.ko: '배경음악', AppLanguage.en: 'BGM', AppLanguage.ja: 'BGM', AppLanguage.zhCn: '背景音乐', AppLanguage.zhTw: '背景音樂',
        AppLanguage.es: 'Música', AppLanguage.fr: 'Musique', AppLanguage.de: 'Musik', AppLanguage.pt: 'Música', AppLanguage.th: 'เพลงพื้นหลัง',
      },
      'sfx': {
        AppLanguage.ko: '효과음', AppLanguage.en: 'SFX', AppLanguage.ja: 'SE', AppLanguage.zhCn: '音效', AppLanguage.zhTw: '音效',
        AppLanguage.es: 'Efectos', AppLanguage.fr: 'Effets', AppLanguage.de: 'Effekte', AppLanguage.pt: 'Efeitos', AppLanguage.th: 'เอฟเฟกต์เสียง',
      },
      'language': {
        AppLanguage.ko: '언어', AppLanguage.en: 'Language', AppLanguage.ja: '言語', AppLanguage.zhCn: '语言', AppLanguage.zhTw: '語言',
        AppLanguage.es: 'Idioma', AppLanguage.fr: 'Langue', AppLanguage.de: 'Sprache', AppLanguage.pt: 'Idioma', AppLanguage.th: 'ภาษา',
      },
      'cardSkin': {
        AppLanguage.ko: '카드 뒷면 디자인', AppLanguage.en: 'Card Back Design', AppLanguage.ja: 'カード背面デザイン', AppLanguage.zhCn: '卡背设计', AppLanguage.zhTw: '卡背設計',
        AppLanguage.es: 'Diseño del reverso', AppLanguage.fr: 'Design du dos', AppLanguage.de: 'Kartenrücken-Design', AppLanguage.pt: 'Design do verso', AppLanguage.th: 'ดีไซน์หลังไพ่',
      },
      'cardSkinFront': {
        AppLanguage.ko: '카드 앞면 디자인', AppLanguage.en: 'Card Front Design', AppLanguage.ja: 'カード表面デザイン', AppLanguage.zhCn: '卡面设计', AppLanguage.zhTw: '卡面設計',
        AppLanguage.es: 'Diseño del anverso', AppLanguage.fr: 'Design de la face', AppLanguage.de: 'Kartenvorderseite-Design', AppLanguage.pt: 'Design da frente', AppLanguage.th: 'ดีไซน์หน้าไพ่',
      },
      'cardSkinBack': {
        AppLanguage.ko: '카드 뒷면 디자인', AppLanguage.en: 'Card Back Design', AppLanguage.ja: 'カード背面デザイン', AppLanguage.zhCn: '卡背设计', AppLanguage.zhTw: '卡背設計',
        AppLanguage.es: 'Diseño del reverso', AppLanguage.fr: 'Design du dos', AppLanguage.de: 'Kartenrücken-Design', AppLanguage.pt: 'Design do verso', AppLanguage.th: 'ดีไซน์หลังไพ่',
      },
      'volumeOff': {
        AppLanguage.ko: '끔', AppLanguage.en: 'OFF', AppLanguage.ja: 'オフ', AppLanguage.zhCn: '关', AppLanguage.zhTw: '關',
        AppLanguage.es: 'Apagado', AppLanguage.fr: 'Désactivé', AppLanguage.de: 'Aus', AppLanguage.pt: 'Desligado', AppLanguage.th: 'ปิด',
      },
      'handStatus': {
        AppLanguage.ko: '패 현황', AppLanguage.en: 'Hand Status', AppLanguage.ja: '手札状況', AppLanguage.zhCn: '卡牌状态', AppLanguage.zhTw: '卡牌狀態',
        AppLanguage.es: 'Estado de mano', AppLanguage.fr: 'État de la main', AppLanguage.de: 'Handstatus', AppLanguage.pt: 'Estado da mão', AppLanguage.th: 'สถานะไพ่ในมือ',
      },
      'myInfo': {
        AppLanguage.ko: '내 정보', AppLanguage.en: 'My Profile', AppLanguage.ja: 'マイプロフィール', AppLanguage.zhCn: '我的信息', AppLanguage.zhTw: '我的資訊',
        AppLanguage.es: 'Mi perfil', AppLanguage.fr: 'Mon profil', AppLanguage.de: 'Mein Profil', AppLanguage.pt: 'Meu perfil', AppLanguage.th: 'ข้อมูลของฉัน',
      },
      'winStreak': {
        AppLanguage.ko: '연승', AppLanguage.en: ' Win Streak', AppLanguage.ja: '連勝', AppLanguage.zhCn: '连胜', AppLanguage.zhTw: '連勝',
        AppLanguage.es: 'Racha', AppLanguage.fr: 'Série', AppLanguage.de: 'Siegesserie', AppLanguage.pt: 'Sequência', AppLanguage.th: 'ชนะติดต่อ',
      },
      'currentScore': {
        AppLanguage.ko: '현재 점수', AppLanguage.en: 'Current Score', AppLanguage.ja: '現在のスコア', AppLanguage.zhCn: '当前分数', AppLanguage.zhTw: '目前分數',
        AppLanguage.es: 'Puntuación actual', AppLanguage.fr: 'Score actuel', AppLanguage.de: 'Aktuelle Punktzahl', AppLanguage.pt: 'Pontuação atual', AppLanguage.th: 'คะแนนปัจจุบัน',
      },
      'yakuProgress': {
        AppLanguage.ko: '족보 진행', AppLanguage.en: 'Yaku Progress', AppLanguage.ja: '役の進行', AppLanguage.zhCn: '牌型进度', AppLanguage.zhTw: '牌型進度',
        AppLanguage.es: 'Progreso Yaku', AppLanguage.fr: 'Progression Yaku', AppLanguage.de: 'Yaku-Fortschritt', AppLanguage.pt: 'Progresso Yaku', AppLanguage.th: 'ความคืบหน้ายาคุ',
      },
      'opponent': {
        AppLanguage.ko: '상대', AppLanguage.en: 'Opponent', AppLanguage.ja: '相手', AppLanguage.zhCn: '对手', AppLanguage.zhTw: '對手',
        AppLanguage.es: 'Oponente', AppLanguage.fr: 'Adversaire', AppLanguage.de: 'Gegner', AppLanguage.pt: 'Oponente', AppLanguage.th: 'คู่ต่อสู้',
      },
      'none': {
        AppLanguage.ko: '없음', AppLanguage.en: 'None', AppLanguage.ja: 'なし', AppLanguage.zhCn: '无', AppLanguage.zhTw: '無',
        AppLanguage.es: 'Ninguno', AppLanguage.fr: 'Aucun', AppLanguage.de: 'Keine', AppLanguage.pt: 'Nenhum', AppLanguage.th: 'ไม่มี',
      },
      // 족보 이름들
      'kwang': { AppLanguage.ko: '광', AppLanguage.en: 'Bright', AppLanguage.ja: '光', AppLanguage.zhCn: '光', AppLanguage.zhTw: '光', AppLanguage.es: 'Brillante', AppLanguage.fr: 'Lumière', AppLanguage.de: 'Licht', AppLanguage.pt: 'Brilhante', AppLanguage.th: 'กวัง' },
      'animal': { AppLanguage.ko: '열끗', AppLanguage.en: 'Animal', AppLanguage.ja: 'タネ', AppLanguage.zhCn: '种', AppLanguage.zhTw: '種', AppLanguage.es: 'Animal', AppLanguage.fr: 'Animal', AppLanguage.de: 'Tier', AppLanguage.pt: 'Animal', AppLanguage.th: 'สัตว์' },
      'blue': { AppLanguage.ko: '청단', AppLanguage.en: 'Blue Ribbon', AppLanguage.ja: '青短', AppLanguage.zhCn: '青丹', AppLanguage.zhTw: '青丹', AppLanguage.es: 'Cinta azul', AppLanguage.fr: 'Ruban bleu', AppLanguage.de: 'Blaues Band', AppLanguage.pt: 'Fita azul', AppLanguage.th: 'แถบน้ำเงิน' },
      'red': { AppLanguage.ko: '홍단', AppLanguage.en: 'Red Ribbon', AppLanguage.ja: '赤短', AppLanguage.zhCn: '赤丹', AppLanguage.zhTw: '赤丹', AppLanguage.es: 'Cinta roja', AppLanguage.fr: 'Ruban rouge', AppLanguage.de: 'Rotes Band', AppLanguage.pt: 'Fita vermelha', AppLanguage.th: 'แถบแดง' },
      'grass': { AppLanguage.ko: '초단', AppLanguage.en: 'Grass Ribbon', AppLanguage.ja: '草短', AppLanguage.zhCn: '草丹', AppLanguage.zhTw: '草丹', AppLanguage.es: 'Cinta hierba', AppLanguage.fr: 'Ruban herbe', AppLanguage.de: 'Grasband', AppLanguage.pt: 'Fita grama', AppLanguage.th: 'แถบหญ้า' },
      'plain': { AppLanguage.ko: '띠', AppLanguage.en: 'Ribbon', AppLanguage.ja: '短冊', AppLanguage.zhCn: '条', AppLanguage.zhTw: '條', AppLanguage.es: 'Cinta', AppLanguage.fr: 'Ruban', AppLanguage.de: 'Band', AppLanguage.pt: 'Fita', AppLanguage.th: 'แถบ' },
      'pi': { AppLanguage.ko: '피', AppLanguage.en: 'Junk', AppLanguage.ja: 'カス', AppLanguage.zhCn: '皮', AppLanguage.zhTw: '皮', AppLanguage.es: 'Basura', AppLanguage.fr: 'Rebut', AppLanguage.de: 'Schrott', AppLanguage.pt: 'Lixo', AppLanguage.th: 'พี' },
      // ─── [카드 선택 오버레이] ───
      'selectCardTitle': {
        AppLanguage.ko: '먹을 카드를 선택하세요', AppLanguage.en: 'Select a card to capture', AppLanguage.ja: '取るカードを選んでください', AppLanguage.zhCn: '请选择要吃的牌', AppLanguage.zhTw: '請選擇要吃的牌',
        AppLanguage.es: 'Selecciona una carta para capturar', AppLanguage.fr: 'Sélectionnez une carte à capturer', AppLanguage.de: 'Wähle eine Karte zum Fangen', AppLanguage.pt: 'Selecione uma carta para capturar', AppLanguage.th: 'เลือกไพ่ที่จะยึด',
      },
      'cancel': {
        AppLanguage.ko: '취소', AppLanguage.en: 'Cancel', AppLanguage.ja: 'キャンセル', AppLanguage.zhCn: '取消', AppLanguage.zhTw: '取消',
        AppLanguage.es: 'Cancelar', AppLanguage.fr: 'Annuler', AppLanguage.de: 'Abbrechen', AppLanguage.pt: 'Cancelar', AppLanguage.th: 'ยกเลิก',
      },
      // ─── [고/스톱 & 라운드 종료 오버레이] ───
      'me': {
        AppLanguage.ko: '나', AppLanguage.en: 'Me', AppLanguage.ja: '自分', AppLanguage.zhCn: '我', AppLanguage.zhTw: '我',
        AppLanguage.es: 'Yo', AppLanguage.fr: 'Moi', AppLanguage.de: 'Ich', AppLanguage.pt: 'Eu', AppLanguage.th: 'ฉัน',
      },
      'meWithIcon': {
        AppLanguage.ko: '나', AppLanguage.en: 'Me', AppLanguage.ja: '自分', AppLanguage.zhCn: '我', AppLanguage.zhTw: '我',
        AppLanguage.es: 'Yo', AppLanguage.fr: 'Moi', AppLanguage.de: 'Ich', AppLanguage.pt: 'Eu', AppLanguage.th: 'ฉัน',
      },
      'opponentWithIcon': {
        AppLanguage.ko: '상대', AppLanguage.en: 'Opponent', AppLanguage.ja: '相手', AppLanguage.zhCn: '对手', AppLanguage.zhTw: '對手',
        AppLanguage.es: 'Oponente', AppLanguage.fr: 'Adversaire', AppLanguage.de: 'Gegner', AppLanguage.pt: 'Oponente', AppLanguage.th: 'คู่ต่อสู้',
      },
      'pointSuffix': {
        AppLanguage.ko: '점', AppLanguage.en: 'pts', AppLanguage.ja: '点', AppLanguage.zhCn: '分', AppLanguage.zhTw: '分',
        AppLanguage.es: 'pts', AppLanguage.fr: 'pts', AppLanguage.de: 'Pkt', AppLanguage.pt: 'pts', AppLanguage.th: 'คะแนน',
      },
      'uiScore': {
        AppLanguage.ko: '점수', AppLanguage.en: 'Score', AppLanguage.ja: 'スコア', AppLanguage.zhCn: '分数', AppLanguage.zhTw: '分數',
        AppLanguage.es: 'Puntuación', AppLanguage.fr: 'Score', AppLanguage.de: 'Punktzahl', AppLanguage.pt: 'Pontuação', AppLanguage.th: 'คะแนน',
      },
      'calculation': {
        AppLanguage.ko: '계산', AppLanguage.en: 'Calc', AppLanguage.ja: '計算', AppLanguage.zhCn: '计算', AppLanguage.zhTw: '計算',
        AppLanguage.es: 'Cálc', AppLanguage.fr: 'Calc', AppLanguage.de: 'Ber.', AppLanguage.pt: 'Cálc', AppLanguage.th: 'คำนวณ',
      },
      'victory': {
        AppLanguage.ko: '승리!', AppLanguage.en: 'Victory!', AppLanguage.ja: '勝利！', AppLanguage.zhCn: '胜利！', AppLanguage.zhTw: '勝利！',
        AppLanguage.es: '¡Victoria!', AppLanguage.fr: 'Victoire !', AppLanguage.de: 'Sieg!', AppLanguage.pt: 'Vitória!', AppLanguage.th: 'ชนะ!',
      },
      'defeat': {
        AppLanguage.ko: '패배...', AppLanguage.en: 'Defeat...', AppLanguage.ja: '敗北...', AppLanguage.zhCn: '失败...', AppLanguage.zhTw: '失敗...',
        AppLanguage.es: 'Derrota...', AppLanguage.fr: 'Défaite...', AppLanguage.de: 'Niederlage...', AppLanguage.pt: 'Derrota...', AppLanguage.th: 'แพ้...',
      },
      'sweepLabel': {
        AppLanguage.ko: '쓸', AppLanguage.en: 'Sweep', AppLanguage.ja: '掃', AppLanguage.zhCn: '清', AppLanguage.zhTw: '清',
        AppLanguage.es: 'Barrida', AppLanguage.fr: 'Balayage', AppLanguage.de: 'Fegen', AppLanguage.pt: 'Varredura', AppLanguage.th: 'กวาด',
      },
      'income': {
        AppLanguage.ko: '수입', AppLanguage.en: 'Income', AppLanguage.ja: '収入', AppLanguage.zhCn: '收入', AppLanguage.zhTw: '收入',
        AppLanguage.es: 'Ingreso', AppLanguage.fr: 'Revenu', AppLanguage.de: 'Einkommen', AppLanguage.pt: 'Renda', AppLanguage.th: 'รายได้',
      },
      'loss': {
        AppLanguage.ko: '손실', AppLanguage.en: 'Loss', AppLanguage.ja: '損失', AppLanguage.zhCn: '损失', AppLanguage.zhTw: '損失',
        AppLanguage.es: 'Pérdida', AppLanguage.fr: 'Perte', AppLanguage.de: 'Verlust', AppLanguage.pt: 'Perda', AppLanguage.th: 'ขาดทุน',
      },
      'nextRound': {
        AppLanguage.ko: '다음 라운드 →', AppLanguage.en: 'Next Round →', AppLanguage.ja: '次のラウンド →', AppLanguage.zhCn: '下一回合 →', AppLanguage.zhTw: '下一回合 →',
        AppLanguage.es: 'Siguiente Ronda →', AppLanguage.fr: 'Manche suivante →', AppLanguage.de: 'Nächste Runde →', AppLanguage.pt: 'Próxima Rodada →', AppLanguage.th: 'รอบถัดไป →',
      },
      'retry': {
        AppLanguage.ko: '재도전!', AppLanguage.en: 'Retry!', AppLanguage.ja: 'リトライ！', AppLanguage.zhCn: '再试！', AppLanguage.zhTw: '再試！',
        AppLanguage.es: '¡Reintentar!', AppLanguage.fr: 'Réessayer !', AppLanguage.de: 'Nochmal!', AppLanguage.pt: 'Tentar novamente!', AppLanguage.th: 'ลองอีกครั้ง!',
      },
      // ─── [점수 상세 breakdown] ───
      'scoreDetail': {
        AppLanguage.ko: '점수 상세', AppLanguage.en: 'Score Detail', AppLanguage.ja: 'スコア詳細', AppLanguage.zhCn: '得分详情', AppLanguage.zhTw: '得分詳情',
        AppLanguage.es: 'Detalle de puntos', AppLanguage.fr: 'Detail du score', AppLanguage.de: 'Punktedetails', AppLanguage.pt: 'Detalhe dos pontos', AppLanguage.th: 'รายละเอียดคะแนน',
      },
      'totalLabel': {
        AppLanguage.ko: '합계', AppLanguage.en: 'Total', AppLanguage.ja: '合計', AppLanguage.zhCn: '合计', AppLanguage.zhTw: '合計',
        AppLanguage.es: 'Total', AppLanguage.fr: 'Total', AppLanguage.de: 'Gesamt', AppLanguage.pt: 'Total', AppLanguage.th: 'รวม',
      },
      // ─── [족보 이름 (점수 breakdown용)] ───
      'yaku_ogwang': {
        AppLanguage.ko: '오광', AppLanguage.en: 'Five Brights', AppLanguage.ja: '五光', AppLanguage.zhCn: '五光', AppLanguage.zhTw: '五光',
        AppLanguage.es: 'Cinco Brillantes', AppLanguage.fr: 'Cinq Lumieres', AppLanguage.de: 'Funf Lichter', AppLanguage.pt: 'Cinco Brilhantes', AppLanguage.th: 'ห้ากวัง',
      },
      'yaku_sagwang': {
        AppLanguage.ko: '사광', AppLanguage.en: 'Four Brights', AppLanguage.ja: '四光', AppLanguage.zhCn: '四光', AppLanguage.zhTw: '四光',
        AppLanguage.es: 'Cuatro Brillantes', AppLanguage.fr: 'Quatre Lumieres', AppLanguage.de: 'Vier Lichter', AppLanguage.pt: 'Quatro Brilhantes', AppLanguage.th: 'สี่กวัง',
      },
      'yaku_bisagwang': {
        AppLanguage.ko: '비사광', AppLanguage.en: 'Rainy Four Brights', AppLanguage.ja: '雨四光', AppLanguage.zhCn: '雨四光', AppLanguage.zhTw: '雨四光',
        AppLanguage.es: 'Cuatro Brillantes con Lluvia', AppLanguage.fr: 'Quatre Lumieres Pluvieuses', AppLanguage.de: 'Regen-Vier-Lichter', AppLanguage.pt: 'Quatro Brilhantes Chuvosos', AppLanguage.th: 'สี่กวังฝน',
      },
      'yaku_bisamgwang': {
        AppLanguage.ko: '비삼광', AppLanguage.en: 'Rainy Three Brights', AppLanguage.ja: '雨三光', AppLanguage.zhCn: '雨三光', AppLanguage.zhTw: '雨三光',
        AppLanguage.es: 'Tres Brillantes con Lluvia', AppLanguage.fr: 'Trois Lumieres Pluvieuses', AppLanguage.de: 'Regen-Drei-Lichter', AppLanguage.pt: 'Tres Brilhantes Chuvosos', AppLanguage.th: 'สามกวังฝน',
      },
      'yaku_samgwang': {
        AppLanguage.ko: '삼광', AppLanguage.en: 'Three Brights', AppLanguage.ja: '三光', AppLanguage.zhCn: '三光', AppLanguage.zhTw: '三光',
        AppLanguage.es: 'Tres Brillantes', AppLanguage.fr: 'Trois Lumieres', AppLanguage.de: 'Drei Lichter', AppLanguage.pt: 'Tres Brilhantes', AppLanguage.th: 'สามกวัง',
      },
      'yaku_godori': {
        AppLanguage.ko: '고도리', AppLanguage.en: 'Godori', AppLanguage.ja: 'ゴドリ', AppLanguage.zhCn: '五鸟', AppLanguage.zhTw: '五鳥',
        AppLanguage.es: 'Godori', AppLanguage.fr: 'Godori', AppLanguage.de: 'Godori', AppLanguage.pt: 'Godori', AppLanguage.th: 'โกโดริ',
      },
      'yaku_hongdan': {
        AppLanguage.ko: '홍단', AppLanguage.en: 'Red Ribbons', AppLanguage.ja: '赤短', AppLanguage.zhCn: '红短', AppLanguage.zhTw: '紅短',
        AppLanguage.es: 'Cintas Rojas', AppLanguage.fr: 'Rubans Rouges', AppLanguage.de: 'Rote Bander', AppLanguage.pt: 'Fitas Vermelhas', AppLanguage.th: 'แถบแดง',
      },
      'yaku_cheongdan': {
        AppLanguage.ko: '청단', AppLanguage.en: 'Blue Ribbons', AppLanguage.ja: '青短', AppLanguage.zhCn: '青短', AppLanguage.zhTw: '青短',
        AppLanguage.es: 'Cintas Azules', AppLanguage.fr: 'Rubans Bleus', AppLanguage.de: 'Blaue Bander', AppLanguage.pt: 'Fitas Azuis', AppLanguage.th: 'แถบน้ำเงิน',
      },
      'yaku_chodan': {
        AppLanguage.ko: '초단', AppLanguage.en: 'Grass Ribbons', AppLanguage.ja: '草短', AppLanguage.zhCn: '草短', AppLanguage.zhTw: '草短',
        AppLanguage.es: 'Cintas Verdes', AppLanguage.fr: 'Rubans Verts', AppLanguage.de: 'Grasbander', AppLanguage.pt: 'Fitas Verdes', AppLanguage.th: 'แถบหญ้า',
      },
      'yaku_ribbon_count': {
        AppLanguage.ko: '띠 {count}장', AppLanguage.en: '{count} Ribbons', AppLanguage.ja: '短冊{count}枚', AppLanguage.zhCn: '{count}条', AppLanguage.zhTw: '{count}條',
        AppLanguage.es: '{count} Cintas', AppLanguage.fr: '{count} Rubans', AppLanguage.de: '{count} Bander', AppLanguage.pt: '{count} Fitas', AppLanguage.th: 'แถบ {count} ใบ',
      },
      'yaku_animal_count': {
        AppLanguage.ko: '열끗 {count}장', AppLanguage.en: '{count} Animals', AppLanguage.ja: 'タネ{count}枚', AppLanguage.zhCn: '种{count}张', AppLanguage.zhTw: '種{count}張',
        AppLanguage.es: '{count} Animales', AppLanguage.fr: '{count} Animaux', AppLanguage.de: '{count} Tiere', AppLanguage.pt: '{count} Animais', AppLanguage.th: 'สัตว์ {count} ใบ',
      },
      'yaku_junk_count': {
        AppLanguage.ko: '피 {count}장', AppLanguage.en: '{count} Junks', AppLanguage.ja: 'カス{count}枚', AppLanguage.zhCn: '皮{count}张', AppLanguage.zhTw: '皮{count}張',
        AppLanguage.es: '{count} Basuras', AppLanguage.fr: '{count} Rebuts', AppLanguage.de: '{count} Schrott', AppLanguage.pt: '{count} Lixos', AppLanguage.th: 'พี {count} ใบ',
      },
      'yaku_sweep': {
        AppLanguage.ko: '쓸 {count}회', AppLanguage.en: '{count} Sweeps', AppLanguage.ja: '掃{count}回', AppLanguage.zhCn: '清{count}次', AppLanguage.zhTw: '清{count}次',
        AppLanguage.es: '{count} Barridas', AppLanguage.fr: '{count} Balayages', AppLanguage.de: '{count} Feger', AppLanguage.pt: '{count} Varreduras', AppLanguage.th: 'กวาด {count} ครั้ง',
      },
      'yaku_go_points': {
        AppLanguage.ko: '{count}고', AppLanguage.en: '{count} Go', AppLanguage.ja: '{count}ゴー', AppLanguage.zhCn: '{count} Go', AppLanguage.zhTw: '{count} Go',
        AppLanguage.es: '{count} Go', AppLanguage.fr: '{count} Go', AppLanguage.de: '{count} Go', AppLanguage.pt: '{count} Go', AppLanguage.th: '{count} โก',
      },
      'yaku_go_mult': {
        AppLanguage.ko: '{count}고 배율', AppLanguage.en: '{count} Go Multiplier', AppLanguage.ja: '{count}ゴー倍率', AppLanguage.zhCn: '{count} Go倍率', AppLanguage.zhTw: '{count} Go倍率',
        AppLanguage.es: 'Multiplicador {count} Go', AppLanguage.fr: 'Multiplicateur {count} Go', AppLanguage.de: '{count} Go-Multiplikator', AppLanguage.pt: 'Multiplicador {count} Go', AppLanguage.th: 'ตัวคูณ {count} โก',
      },
      'yaku_talisman_regular': {
        AppLanguage.ko: '단골손님', AppLanguage.en: 'Regular Customer', AppLanguage.ja: '常連客', AppLanguage.zhCn: '常客', AppLanguage.zhTw: '常客',
        AppLanguage.es: 'Cliente habitual', AppLanguage.fr: 'Client regulier', AppLanguage.de: 'Stammkunde', AppLanguage.pt: 'Cliente regular', AppLanguage.th: 'ลูกค้าประจำ',
      },
      'yaku_cup_as_junk': {
        AppLanguage.ko: '국화술잔 -> 쌍피', AppLanguage.en: 'Chrysanthemum Cup -> Double Junk', AppLanguage.ja: '菊杯 -> 双皮', AppLanguage.zhCn: '菊花杯 -> 双皮', AppLanguage.zhTw: '菊花杯 -> 雙皮',
        AppLanguage.es: 'Copa Crisantemo -> Doble Basura', AppLanguage.fr: 'Coupe Chrysantheme -> Double Rebut', AppLanguage.de: 'Chrysanthemen-Becher -> Doppelschrott', AppLanguage.pt: 'Taca Crisantemo -> Duplo Lixo', AppLanguage.th: 'ถ้วยเบญจมาศ -> พีคู่',
      },
      'yaku_jackpot': {
        AppLanguage.ko: '잭팟 티켓', AppLanguage.en: 'Jackpot Ticket', AppLanguage.ja: 'ジャックポットチケット', AppLanguage.zhCn: '大奖票', AppLanguage.zhTw: '大獎票',
        AppLanguage.es: 'Ticket Jackpot', AppLanguage.fr: 'Ticket Jackpot', AppLanguage.de: 'Jackpot-Ticket', AppLanguage.pt: 'Bilhete Jackpot', AppLanguage.th: 'ตั๋วแจ็คพอต',
      },
      // ─── [박 배율] ───
      'penalty_gwangbak': {
        AppLanguage.ko: '광박', AppLanguage.en: 'Bright Penalty', AppLanguage.ja: '光朴', AppLanguage.zhCn: '光罚', AppLanguage.zhTw: '光罰',
        AppLanguage.es: 'Penalizacion Brillante', AppLanguage.fr: 'Penalite Lumiere', AppLanguage.de: 'Licht-Strafe', AppLanguage.pt: 'Penalidade Brilhante', AppLanguage.th: 'โทษกวัง',
      },
      'penalty_pibak': {
        AppLanguage.ko: '피박', AppLanguage.en: 'Junk Penalty', AppLanguage.ja: '皮朴', AppLanguage.zhCn: '皮罚', AppLanguage.zhTw: '皮罰',
        AppLanguage.es: 'Penalizacion Basura', AppLanguage.fr: 'Penalite Rebut', AppLanguage.de: 'Schrott-Strafe', AppLanguage.pt: 'Penalidade Lixo', AppLanguage.th: 'โทษพี',
      },
      'penalty_ttibak': {
        AppLanguage.ko: '띠박', AppLanguage.en: 'Ribbon Penalty', AppLanguage.ja: '短冊朴', AppLanguage.zhCn: '条罚', AppLanguage.zhTw: '條罰',
        AppLanguage.es: 'Penalizacion Cinta', AppLanguage.fr: 'Penalite Ruban', AppLanguage.de: 'Band-Strafe', AppLanguage.pt: 'Penalidade Fita', AppLanguage.th: 'โทษแถบ',
      },
      'penalty_meongbak': {
        AppLanguage.ko: '멍박', AppLanguage.en: 'Animal Penalty', AppLanguage.ja: 'タネ朴', AppLanguage.zhCn: '种罚', AppLanguage.zhTw: '種罰',
        AppLanguage.es: 'Penalizacion Animal', AppLanguage.fr: 'Penalite Animal', AppLanguage.de: 'Tier-Strafe', AppLanguage.pt: 'Penalidade Animal', AppLanguage.th: 'โทษสัตว์',
      },
      // ─── [아이템/시너지 효과 (점수 breakdown)] ───
      'item_bonus_chips': {
        AppLanguage.ko: '아이템 보너스', AppLanguage.en: 'Item Bonus', AppLanguage.ja: 'アイテムボーナス', AppLanguage.zhCn: '道具加成', AppLanguage.zhTw: '道具加成',
        AppLanguage.es: 'Bonificacion de objeto', AppLanguage.fr: 'Bonus objet', AppLanguage.de: 'Gegenstandsbonus', AppLanguage.pt: 'Bonus de item', AppLanguage.th: 'โบนัสไอเทม',
      },
      'item_bonus_mult': {
        AppLanguage.ko: '아이템 배율', AppLanguage.en: 'Item Multiplier', AppLanguage.ja: 'アイテム倍率', AppLanguage.zhCn: '道具倍率', AppLanguage.zhTw: '道具倍率',
        AppLanguage.es: 'Multiplicador de objeto', AppLanguage.fr: 'Multiplicateur objet', AppLanguage.de: 'Gegenstandsmultiplikator', AppLanguage.pt: 'Multiplicador de item', AppLanguage.th: 'ตัวคูณไอเทม',
      },
      'item_bonus_xmult': {
        AppLanguage.ko: '아이템 곱배율', AppLanguage.en: 'Item xMult', AppLanguage.ja: 'アイテムx倍率', AppLanguage.zhCn: '道具乘倍率', AppLanguage.zhTw: '道具乘倍率',
        AppLanguage.es: 'xMult de objeto', AppLanguage.fr: 'xMult objet', AppLanguage.de: 'Gegenstands-xMult', AppLanguage.pt: 'xMult de item', AppLanguage.th: 'xMult ไอเทม',
      },
      'talisman_gwangbak_shield': {
        AppLanguage.ko: '광박 방패', AppLanguage.en: 'Bright Penalty Shield', AppLanguage.ja: '光朴シールド', AppLanguage.zhCn: '光罚护盾', AppLanguage.zhTw: '光罰護盾',
        AppLanguage.es: 'Escudo de penalizacion', AppLanguage.fr: 'Bouclier penalite', AppLanguage.de: 'Lichtstrafen-Schild', AppLanguage.pt: 'Escudo de penalidade', AppLanguage.th: 'โล่โทษกวัง',
      },
      'talisman_mountain_charm': {
        AppLanguage.ko: '산신부적 (열끗 x1.5)', AppLanguage.en: 'Mountain Charm (Animal x1.5)', AppLanguage.ja: '山神のお守り (タネx1.5)', AppLanguage.zhCn: '山神符 (种x1.5)', AppLanguage.zhTw: '山神符 (種x1.5)',
        AppLanguage.es: 'Amuleto de montana (Animal x1.5)', AppLanguage.fr: 'Charme montagne (Animal x1.5)', AppLanguage.de: 'Bergamulett (Tier x1.5)', AppLanguage.pt: 'Amuleto da montanha (Animal x1.5)', AppLanguage.th: 'เครื่องรางภูเขา (สัตว์ x1.5)',
      },
      'consumable_ribbon_polish': {
        AppLanguage.ko: '띠 광택제 (띠 x2)', AppLanguage.en: 'Ribbon Polish (Ribbon x2)', AppLanguage.ja: '短冊磨き (短冊x2)', AppLanguage.zhCn: '条打磨 (条x2)', AppLanguage.zhTw: '條打磨 (條x2)',
        AppLanguage.es: 'Pulidor de cintas (Cinta x2)', AppLanguage.fr: 'Polissage ruban (Ruban x2)', AppLanguage.de: 'Bandpolitur (Band x2)', AppLanguage.pt: 'Polidor de fita (Fita x2)', AppLanguage.th: 'ขัดเงาแถบ (แถบ x2)',
      },
      'consumable_bomb_fuse': {
        AppLanguage.ko: '도화선 (폭탄 x4)', AppLanguage.en: 'Bomb Fuse (Bomb x4)', AppLanguage.ja: '導火線 (爆弾x4)', AppLanguage.zhCn: '导火线 (炸弹x4)', AppLanguage.zhTw: '導火線 (炸彈x4)',
        AppLanguage.es: 'Mecha de bomba (Bomba x4)', AppLanguage.fr: 'Meche bombe (Bombe x4)', AppLanguage.de: 'Bombenzunder (Bombe x4)', AppLanguage.pt: 'Pavio de bomba (Bomba x4)', AppLanguage.th: 'ชนวนระเบิด (ระเบิด x4)',
      },
      'synergy_fortress': {
        AppLanguage.ko: '요새 (박 감소)', AppLanguage.en: 'Fortress (Penalty -25%)', AppLanguage.ja: '要塞 (朴-25%)', AppLanguage.zhCn: '堡垒 (罚-25%)', AppLanguage.zhTw: '堡壘 (罰-25%)',
        AppLanguage.es: 'Fortaleza (Penalizacion -25%)', AppLanguage.fr: 'Forteresse (Penalite -25%)', AppLanguage.de: 'Festung (Strafe -25%)', AppLanguage.pt: 'Fortaleza (Penalidade -25%)', AppLanguage.th: 'ป้อมปราการ (โทษ -25%)',
      },
      'passive_flower_bomb': {
        AppLanguage.ko: '꽃폭탄 (x3)', AppLanguage.en: 'Flower Bomb (x3)', AppLanguage.ja: '花爆弾 (x3)', AppLanguage.zhCn: '花炸弹 (x3)', AppLanguage.zhTw: '花炸彈 (x3)',
        AppLanguage.es: 'Bomba de flores (x3)', AppLanguage.fr: 'Bombe florale (x3)', AppLanguage.de: 'Blumenbombe (x3)', AppLanguage.pt: 'Bomba de flores (x3)', AppLanguage.th: 'ระเบิดดอกไม้ (x3)',
      },
      'passive_provoke': {
        AppLanguage.ko: '도발 (x2)', AppLanguage.en: 'Provoke (x2)', AppLanguage.ja: '挑発 (x2)', AppLanguage.zhCn: '挑衅 (x2)', AppLanguage.zhTw: '挑釁 (x2)',
        AppLanguage.es: 'Provocacion (x2)', AppLanguage.fr: 'Provocation (x2)', AppLanguage.de: 'Provokation (x2)', AppLanguage.pt: 'Provocacao (x2)', AppLanguage.th: 'ยั่วยุ (x2)',
      },
      // ─── [흔들기 보너스 (점수 계산)] ───
      'shake_bonus': {
        AppLanguage.ko: '흔들기 x2', AppLanguage.en: 'Shake x2', AppLanguage.ja: '振り x2', AppLanguage.zhCn: '摇动 x2', AppLanguage.zhTw: '搖動 x2',
        AppLanguage.es: 'Agitar x2', AppLanguage.fr: 'Secouer x2', AppLanguage.de: 'Schütteln x2', AppLanguage.pt: 'Sacudir x2', AppLanguage.th: 'เขย่า x2',
      },
      'event_shake': {
        AppLanguage.ko: '흔들기!', AppLanguage.en: 'Shake!', AppLanguage.ja: '振り！', AppLanguage.zhCn: '摇动！', AppLanguage.zhTw: '搖動！',
        AppLanguage.es: '¡Agitar!', AppLanguage.fr: 'Secouer !', AppLanguage.de: 'Schütteln!', AppLanguage.pt: 'Sacudir!', AppLanguage.th: 'เขย่า!',
      },
      'event_shake_sub': {
        AppLanguage.ko: '점수 2배!', AppLanguage.en: 'Score x2!', AppLanguage.ja: 'スコア2倍！', AppLanguage.zhCn: '得分翻倍！', AppLanguage.zhTw: '得分翻倍！',
        AppLanguage.es: '¡Puntuación x2!', AppLanguage.fr: 'Score x2 !', AppLanguage.de: 'Punkte x2!', AppLanguage.pt: 'Pontuação x2!', AppLanguage.th: 'คะแนน x2!',
      },
      // ─── [특수 이벤트 이펙트 (i18n)] ───
      'event_ppeok': {
        AppLanguage.ko: '뻑', AppLanguage.en: 'Ppuck', AppLanguage.ja: 'ションション', AppLanguage.zhCn: '爆', AppLanguage.zhTw: '爆',
        AppLanguage.es: 'Ppuck', AppLanguage.fr: 'Ppuck', AppLanguage.de: 'Ppuck', AppLanguage.pt: 'Ppuck', AppLanguage.th: 'ปอก',
      },
      'event_double_ppeok': {
        AppLanguage.ko: '연뻑', AppLanguage.en: 'Double Ppuck', AppLanguage.ja: '連ション', AppLanguage.zhCn: '连爆', AppLanguage.zhTw: '連爆',
        AppLanguage.es: 'Doble Ppuck', AppLanguage.fr: 'Double Ppuck', AppLanguage.de: 'Doppel-Ppuck', AppLanguage.pt: 'Ppuck Duplo', AppLanguage.th: 'ปอกคู่',
      },
      'event_double_ppeok_sub': {
        AppLanguage.ko: '+3점', AppLanguage.en: '+3 pts', AppLanguage.ja: '+3点', AppLanguage.zhCn: '+3分', AppLanguage.zhTw: '+3分',
        AppLanguage.es: '+3 pts', AppLanguage.fr: '+3 pts', AppLanguage.de: '+3 Pkt', AppLanguage.pt: '+3 pts', AppLanguage.th: '+3 คะแนน',
      },
      'event_triple_ppeok': {
        AppLanguage.ko: '삼뻑', AppLanguage.en: 'Triple Ppuck', AppLanguage.ja: '三連ション', AppLanguage.zhCn: '三连爆', AppLanguage.zhTw: '三連爆',
        AppLanguage.es: 'Triple Ppuck', AppLanguage.fr: 'Triple Ppuck', AppLanguage.de: 'Dreifach-Ppuck', AppLanguage.pt: 'Ppuck Triplo', AppLanguage.th: 'ปอกสาม',
      },
      'event_triple_ppeok_sub': {
        AppLanguage.ko: '즉시 승리', AppLanguage.en: 'Instant Win', AppLanguage.ja: '即勝利', AppLanguage.zhCn: '立即获胜', AppLanguage.zhTw: '立即獲勝',
        AppLanguage.es: 'Victoria instantanea', AppLanguage.fr: 'Victoire instantanee', AppLanguage.de: 'Sofort-Sieg', AppLanguage.pt: 'Vitoria instantanea', AppLanguage.th: 'ชนะทันที',
      },
      'event_chok': {
        AppLanguage.ko: '쪽', AppLanguage.en: 'Jjok', AppLanguage.ja: 'チョク', AppLanguage.zhCn: '接', AppLanguage.zhTw: '接',
        AppLanguage.es: 'Jjok', AppLanguage.fr: 'Jjok', AppLanguage.de: 'Jjok', AppLanguage.pt: 'Jjok', AppLanguage.th: 'จ็อก',
      },
      'event_chok_sweep': {
        AppLanguage.ko: '쪽쓸', AppLanguage.en: 'Jjok Sweep', AppLanguage.ja: 'チョク掃', AppLanguage.zhCn: '接清', AppLanguage.zhTw: '接清',
        AppLanguage.es: 'Jjok Barrida', AppLanguage.fr: 'Jjok Balayage', AppLanguage.de: 'Jjok-Fegen', AppLanguage.pt: 'Jjok Varredura', AppLanguage.th: 'จ็อกกวาด',
      },
      'event_chok_sweep_sub': {
        AppLanguage.ko: '피 2장 빼앗기', AppLanguage.en: 'Steal 2 Junks', AppLanguage.ja: 'カス2枚奪取', AppLanguage.zhCn: '抢走2张皮', AppLanguage.zhTw: '搶走2張皮',
        AppLanguage.es: 'Robar 2 Basuras', AppLanguage.fr: 'Voler 2 Rebuts', AppLanguage.de: '2 Schrott stehlen', AppLanguage.pt: 'Roubar 2 Lixos', AppLanguage.th: 'ขโมย 2 พี',
      },
      'event_tadak': {
        AppLanguage.ko: '따닥', AppLanguage.en: 'Ttadak', AppLanguage.ja: 'タダク', AppLanguage.zhCn: '连击', AppLanguage.zhTw: '連擊',
        AppLanguage.es: 'Ttadak', AppLanguage.fr: 'Ttadak', AppLanguage.de: 'Ttadak', AppLanguage.pt: 'Ttadak', AppLanguage.th: 'ตะดัก',
      },
      'event_sweep': {
        AppLanguage.ko: '쓸', AppLanguage.en: 'Sweep', AppLanguage.ja: '掃', AppLanguage.zhCn: '清', AppLanguage.zhTw: '清',
        AppLanguage.es: 'Barrida', AppLanguage.fr: 'Balayage', AppLanguage.de: 'Fegen', AppLanguage.pt: 'Varredura', AppLanguage.th: 'กวาด',
      },
      'event_ppeok_eat': {
        AppLanguage.ko: '뻑 먹기', AppLanguage.en: 'Ppuck Eat', AppLanguage.ja: 'ション食い', AppLanguage.zhCn: '吃爆', AppLanguage.zhTw: '吃爆',
        AppLanguage.es: 'Comer Ppuck', AppLanguage.fr: 'Manger Ppuck', AppLanguage.de: 'Ppuck Essen', AppLanguage.pt: 'Comer Ppuck', AppLanguage.th: 'กินปอก',
      },
      'event_ppeok_eat_sub': {
        AppLanguage.ko: '4장 흡수', AppLanguage.en: 'Absorb 4 cards', AppLanguage.ja: '4枚吸収', AppLanguage.zhCn: '吸收4张', AppLanguage.zhTw: '吸收4張',
        AppLanguage.es: 'Absorber 4 cartas', AppLanguage.fr: 'Absorber 4 cartes', AppLanguage.de: '4 Karten absorbieren', AppLanguage.pt: 'Absorver 4 cartas', AppLanguage.th: 'ดูดซับ 4 ใบ',
      },
      'event_self_ppeok': {
        AppLanguage.ko: '자뻑', AppLanguage.en: 'Self Ppuck', AppLanguage.ja: '自ション', AppLanguage.zhCn: '自爆', AppLanguage.zhTw: '自爆',
        AppLanguage.es: 'Auto Ppuck', AppLanguage.fr: 'Auto Ppuck', AppLanguage.de: 'Selbst-Ppuck', AppLanguage.pt: 'Auto Ppuck', AppLanguage.th: 'ปอกตัวเอง',
      },
      'event_self_ppeok_sub': {
        AppLanguage.ko: '4장 + 피 2장 빼앗기!', AppLanguage.en: '4 cards + Steal 2 Junks!', AppLanguage.ja: '4枚+カス2枚奪取！', AppLanguage.zhCn: '4张+抢走2张皮！', AppLanguage.zhTw: '4張+搶走2張皮！',
        AppLanguage.es: '4 cartas + Robar 2 Basuras!', AppLanguage.fr: '4 cartes + Voler 2 Rebuts !', AppLanguage.de: '4 Karten + 2 Schrott stehlen!', AppLanguage.pt: '4 cartas + Roubar 2 Lixos!', AppLanguage.th: '4 ใบ + ขโมย 2 พี!',
      },
      'event_bomb': {
        AppLanguage.ko: '폭탄', AppLanguage.en: 'Bomb', AppLanguage.ja: '爆弾', AppLanguage.zhCn: '炸弹', AppLanguage.zhTw: '炸彈',
        AppLanguage.es: 'Bomba', AppLanguage.fr: 'Bombe', AppLanguage.de: 'Bombe', AppLanguage.pt: 'Bomba', AppLanguage.th: 'ระเบิด',
      },
      'event_chongtong': {
        AppLanguage.ko: '총통', AppLanguage.en: 'Chongtong', AppLanguage.ja: '総統', AppLanguage.zhCn: '总统', AppLanguage.zhTw: '總統',
        AppLanguage.es: 'Chongtong', AppLanguage.fr: 'Chongtong', AppLanguage.de: 'Chongtong', AppLanguage.pt: 'Chongtong', AppLanguage.th: 'ชงทง',
      },
      'event_chongtong_sub': {
        AppLanguage.ko: '4장 즉시 획득', AppLanguage.en: 'Capture 4 cards instantly', AppLanguage.ja: '4枚即取得', AppLanguage.zhCn: '立即获得4张', AppLanguage.zhTw: '立即獲得4張',
        AppLanguage.es: 'Capturar 4 cartas al instante', AppLanguage.fr: 'Capturer 4 cartes instantanement', AppLanguage.de: '4 Karten sofort einfangen', AppLanguage.pt: 'Capturar 4 cartas instantaneamente', AppLanguage.th: 'ยึด 4 ใบทันที',
      },
      // ─── [파산 오버레이] ───
      'bankrupt': {
        AppLanguage.ko: '파산!', AppLanguage.en: 'Bankrupt!', AppLanguage.ja: '破産！', AppLanguage.zhCn: '破产！', AppLanguage.zhTw: '破產！',
        AppLanguage.es: '¡Bancarrota!', AppLanguage.fr: 'Faillite !', AppLanguage.de: 'Bankrott!', AppLanguage.pt: 'Falência!', AppLanguage.th: 'ล้มละลาย!',
      },
      'bankruptDesc': {
        AppLanguage.ko: '소지금이 바닥났습니다...', AppLanguage.en: 'You ran out of money...', AppLanguage.ja: '所持金が底を尽きました...', AppLanguage.zhCn: '身无分文了...', AppLanguage.zhTw: '身無分文了...',
        AppLanguage.es: 'Te quedaste sin dinero...', AppLanguage.fr: 'Vous n\'avez plus d\'argent...', AppLanguage.de: 'Kein Geld mehr...', AppLanguage.pt: 'Ficou sem dinheiro...', AppLanguage.th: 'หมดเงินแล้ว...',
      },
      'restartFromBeginning': {
        AppLanguage.ko: '처음부터 다시', AppLanguage.en: 'Start Over', AppLanguage.ja: '最初からやり直す', AppLanguage.zhCn: '从头开始', AppLanguage.zhTw: '從頭開始',
        AppLanguage.es: 'Empezar de nuevo', AppLanguage.fr: 'Recommencer', AppLanguage.de: 'Von vorne', AppLanguage.pt: 'Recomeçar', AppLanguage.th: 'เริ่มใหม่',
      },
      'totalWins': {
        AppLanguage.ko: '총 승리', AppLanguage.en: 'Total Wins', AppLanguage.ja: '合計勝利', AppLanguage.zhCn: '总胜利', AppLanguage.zhTw: '總勝利',
        AppLanguage.es: 'Victorias totales', AppLanguage.fr: 'Victoires totales', AppLanguage.de: 'Siege gesamt', AppLanguage.pt: 'Vitórias totais', AppLanguage.th: 'ชนะทั้งหมด',
      },
      'totalLosses': {
        AppLanguage.ko: '총 패배', AppLanguage.en: 'Total Losses', AppLanguage.ja: '合計敗北', AppLanguage.zhCn: '总失败', AppLanguage.zhTw: '總失敗',
        AppLanguage.es: 'Derrotas totales', AppLanguage.fr: 'Défaites totales', AppLanguage.de: 'Niederlagen gesamt', AppLanguage.pt: 'Derrotas totais', AppLanguage.th: 'แพ้ทั้งหมด',
      },
      'bestWinStreak': {
        AppLanguage.ko: '최고 연승', AppLanguage.en: 'Best Streak', AppLanguage.ja: '最高連勝', AppLanguage.zhCn: '最高连胜', AppLanguage.zhTw: '最高連勝',
        AppLanguage.es: 'Mejor racha', AppLanguage.fr: 'Meilleure série', AppLanguage.de: 'Beste Serie', AppLanguage.pt: 'Melhor sequência', AppLanguage.th: 'สถิติชนะติดต่อ',
      },
      'bestScore': {
        AppLanguage.ko: '최고 점수', AppLanguage.en: 'Best Score', AppLanguage.ja: '最高スコア', AppLanguage.zhCn: '最高分', AppLanguage.zhTw: '最高分',
        AppLanguage.es: 'Mejor puntuación', AppLanguage.fr: 'Meilleur score', AppLanguage.de: 'Highscore', AppLanguage.pt: 'Melhor pontuação', AppLanguage.th: 'คะแนนสูงสุด',
      },
      'bestMoney': {
        AppLanguage.ko: '최고 소지금', AppLanguage.en: 'Best Money', AppLanguage.ja: '最高所持金', AppLanguage.zhCn: '最高持金', AppLanguage.zhTw: '最高持金',
        AppLanguage.es: 'Más dinero', AppLanguage.fr: 'Plus d\'argent', AppLanguage.de: 'Meistes Geld', AppLanguage.pt: 'Mais dinheiro', AppLanguage.th: 'เงินสูงสุด',
      },
      'reachedStage': {
        AppLanguage.ko: '도달 스테이지', AppLanguage.en: 'Stage Reached', AppLanguage.ja: '到達ステージ', AppLanguage.zhCn: '到达关卡', AppLanguage.zhTw: '到達關卡',
        AppLanguage.es: 'Etapa alcanzada', AppLanguage.fr: 'Étape atteinte', AppLanguage.de: 'Erreichte Stufe', AppLanguage.pt: 'Fase alcançada', AppLanguage.th: 'ด่านที่ไปถึง',
      },
      'winsUnit': {
        AppLanguage.ko: '승', AppLanguage.en: 'W', AppLanguage.ja: '勝', AppLanguage.zhCn: '胜', AppLanguage.zhTw: '勝',
        AppLanguage.es: 'V', AppLanguage.fr: 'V', AppLanguage.de: 'S', AppLanguage.pt: 'V', AppLanguage.th: 'ชนะ',
      },
      'lossesUnit': {
        AppLanguage.ko: '패', AppLanguage.en: 'L', AppLanguage.ja: '敗', AppLanguage.zhCn: '负', AppLanguage.zhTw: '負',
        AppLanguage.es: 'D', AppLanguage.fr: 'D', AppLanguage.de: 'N', AppLanguage.pt: 'D', AppLanguage.th: 'แพ้',
      },
      'streakUnit': {
        AppLanguage.ko: '연승', AppLanguage.en: ' streak', AppLanguage.ja: '連勝', AppLanguage.zhCn: '连胜', AppLanguage.zhTw: '連勝',
        AppLanguage.es: ' racha', AppLanguage.fr: ' série', AppLanguage.de: ' Serie', AppLanguage.pt: ' sequência', AppLanguage.th: ' ต่อเนื่อง',
      },
      'stagePrefix': {
        AppLanguage.ko: '스테이지', AppLanguage.en: 'Stage', AppLanguage.ja: 'ステージ', AppLanguage.zhCn: '关卡', AppLanguage.zhTw: '關卡',
        AppLanguage.es: 'Etapa', AppLanguage.fr: 'Étape', AppLanguage.de: 'Stufe', AppLanguage.pt: 'Fase', AppLanguage.th: 'ด่าน',
      },
      // ─── [AI 고/스톱 표시] ───
      'aiStop': {
        AppLanguage.ko: '스톱!', AppLanguage.en: 'Stop!', AppLanguage.ja: 'ストップ！', AppLanguage.zhCn: '停！', AppLanguage.zhTw: '停！',
        AppLanguage.es: '¡Stop!', AppLanguage.fr: 'Stop !', AppLanguage.de: 'Stopp!', AppLanguage.pt: 'Stop!', AppLanguage.th: 'สต็อป!',
      },
      'aiGo': {
        AppLanguage.ko: '고!', AppLanguage.en: 'Go!', AppLanguage.ja: 'ゴー！', AppLanguage.zhCn: '继续！', AppLanguage.zhTw: '繼續！',
        AppLanguage.es: '¡Go!', AppLanguage.fr: 'Go !', AppLanguage.de: 'Go!', AppLanguage.pt: 'Go!', AppLanguage.th: 'โก!',
      },
      // ─── [고/스톱 결정 상세 텍스트] ───
      'goStopReached': {
        AppLanguage.ko: '3점 달성!', AppLanguage.en: '3 pts reached!', AppLanguage.ja: '3点達成！', AppLanguage.zhCn: '达到3分！', AppLanguage.zhTw: '達到3分！',
        AppLanguage.es: '¡3 pts alcanzados!', AppLanguage.fr: '3 pts atteints !', AppLanguage.de: '3 Pkt erreicht!', AppLanguage.pt: '3 pts alcançados!', AppLanguage.th: 'ถึง 3 คะแนน!',
      },
      'goStopExtraPoints': {
        AppLanguage.ko: '추가 점수!', AppLanguage.en: 'Extra points!', AppLanguage.ja: '追加点数！', AppLanguage.zhCn: '额外得分！', AppLanguage.zhTw: '額外得分！',
        AppLanguage.es: '¡Puntos extra!', AppLanguage.fr: 'Points bonus !', AppLanguage.de: 'Extrapunkte!', AppLanguage.pt: 'Pontos extras!', AppLanguage.th: 'คะแนนพิเศษ!',
      },
      'goStopDesc1go': {
        AppLanguage.ko: '고(1고) → +1점 추가 | 스톱 시 즉시 승리', AppLanguage.en: 'Go(1 Go) → +1 pt | Stop to win now', AppLanguage.ja: 'ゴー(1ゴー) → +1点追加 | ストップで即勝利', AppLanguage.zhCn: 'Go(1 Go) → +1分 | 停则立即获胜', AppLanguage.zhTw: 'Go(1 Go) → +1分 | 停則立即獲勝',
        AppLanguage.es: 'Go(1 Go) → +1 pt | Stop para ganar', AppLanguage.fr: 'Go(1 Go) → +1 pt | Stop pour gagner', AppLanguage.de: 'Go(1 Go) → +1 Pkt | Stop zum Gewinnen', AppLanguage.pt: 'Go(1 Go) → +1 pt | Stop para vencer', AppLanguage.th: 'Go(1 Go) → +1 คะแนน | สต็อปเพื่อชนะ',
      },
      'goStopDesc2go': {
        AppLanguage.ko: '고(2고) → +2점 추가 | 스톱 시 즉시 승리', AppLanguage.en: 'Go(2 Go) → +2 pts | Stop to win now', AppLanguage.ja: 'ゴー(2ゴー) → +2点追加 | ストップで即勝利', AppLanguage.zhCn: 'Go(2 Go) → +2分 | 停则立即获胜', AppLanguage.zhTw: 'Go(2 Go) → +2分 | 停則立即獲勝',
        AppLanguage.es: 'Go(2 Go) → +2 pts | Stop para ganar', AppLanguage.fr: 'Go(2 Go) → +2 pts | Stop pour gagner', AppLanguage.de: 'Go(2 Go) → +2 Pkt | Stop zum Gewinnen', AppLanguage.pt: 'Go(2 Go) → +2 pts | Stop para vencer', AppLanguage.th: 'Go(2 Go) → +2 คะแนน | สต็อปเพื่อชนะ',
      },
      'goStopDesc3go': {
        AppLanguage.ko: '고(3고) → 점수 2배 폭증! | 스톱 시 즉시 승리', AppLanguage.en: 'Go(3 Go) → Score x2! | Stop to win now', AppLanguage.ja: 'ゴー(3ゴー) → スコア2倍！ | ストップで即勝利', AppLanguage.zhCn: 'Go(3 Go) → 分数翻倍！ | 停则立即获胜', AppLanguage.zhTw: 'Go(3 Go) → 分數翻倍！ | 停則立即獲勝',
        AppLanguage.es: 'Go(3 Go) → ¡Puntuación x2! | Stop para ganar', AppLanguage.fr: 'Go(3 Go) → Score x2 ! | Stop pour gagner', AppLanguage.de: 'Go(3 Go) → Punkte x2! | Stop zum Gewinnen', AppLanguage.pt: 'Go(3 Go) → Pontuação x2! | Stop para vencer', AppLanguage.th: 'Go(3 Go) → คะแนน x2! | สต็อปเพื่อชนะ',
      },
      // ─── [사이드 패널] ───
      'skillBag': {
        AppLanguage.ko: '기술 가방', AppLanguage.en: 'Skill Bag', AppLanguage.ja: 'スキルバッグ', AppLanguage.zhCn: '技能包', AppLanguage.zhTw: '技能包',
        AppLanguage.es: 'Bolsa de habilidades', AppLanguage.fr: 'Sac de compétences', AppLanguage.de: 'Fähigkeitentasche', AppLanguage.pt: 'Bolsa de habilidades', AppLanguage.th: 'กระเป๋าสกิล',
      },
      'noSkills': {
        AppLanguage.ko: '보유한 기술/부적이 없습니다', AppLanguage.en: 'No skills or talismans', AppLanguage.ja: 'スキル/お守りなし', AppLanguage.zhCn: '没有技能/护符', AppLanguage.zhTw: '沒有技能/護符',
        AppLanguage.es: 'Sin habilidades ni talismanes', AppLanguage.fr: 'Aucune compétence ni talisman', AppLanguage.de: 'Keine Fähigkeiten oder Talismane', AppLanguage.pt: 'Sem habilidades ou talismãs', AppLanguage.th: 'ไม่มีสกิลหรือเครื่องราง',
      },
      // ─── [화투 카드] ───
      'flip': {
        AppLanguage.ko: '뒤집기', AppLanguage.en: 'Flip', AppLanguage.ja: 'めくる', AppLanguage.zhCn: '翻牌', AppLanguage.zhTw: '翻牌',
        AppLanguage.es: 'Voltear', AppLanguage.fr: 'Retourner', AppLanguage.de: 'Umdrehen', AppLanguage.pt: 'Virar', AppLanguage.th: 'พลิก',
      },
      'monthLabel': {
        AppLanguage.ko: '월', AppLanguage.en: '', AppLanguage.ja: '月', AppLanguage.zhCn: '月', AppLanguage.zhTw: '月',
        AppLanguage.es: '', AppLanguage.fr: '', AppLanguage.de: '', AppLanguage.pt: '', AppLanguage.th: '',
      },
      'doublePi': {
        AppLanguage.ko: '쌍피', AppLanguage.en: 'Double', AppLanguage.ja: '双皮', AppLanguage.zhCn: '双皮', AppLanguage.zhTw: '雙皮',
        AppLanguage.es: 'Doble', AppLanguage.fr: 'Double', AppLanguage.de: 'Doppelt', AppLanguage.pt: 'Duplo', AppLanguage.th: 'คู่',
      },
      // ─── [카드 특징 라벨] ───
      'cardGradeBright': {
        AppLanguage.ko: '광', AppLanguage.en: 'Bright', AppLanguage.ja: '光', AppLanguage.zhCn: '光', AppLanguage.zhTw: '光',
        AppLanguage.es: 'Brillante', AppLanguage.fr: 'Lumière', AppLanguage.de: 'Licht', AppLanguage.pt: 'Brilhante', AppLanguage.th: 'กวัง',
      },
      'cardGradeAnimal': {
        AppLanguage.ko: '열끗', AppLanguage.en: 'Animal', AppLanguage.ja: 'タネ', AppLanguage.zhCn: '种', AppLanguage.zhTw: '種',
        AppLanguage.es: 'Animal', AppLanguage.fr: 'Animal', AppLanguage.de: 'Tier', AppLanguage.pt: 'Animal', AppLanguage.th: 'สัตว์',
      },
      'cardGradeRedRibbon': {
        AppLanguage.ko: '홍단', AppLanguage.en: 'Red', AppLanguage.ja: '赤短', AppLanguage.zhCn: '红短', AppLanguage.zhTw: '紅短',
        AppLanguage.es: 'Roja', AppLanguage.fr: 'Rouge', AppLanguage.de: 'Rot', AppLanguage.pt: 'Vermelha', AppLanguage.th: 'แดง',
      },
      'cardGradeBlueRibbon': {
        AppLanguage.ko: '청단', AppLanguage.en: 'Blue', AppLanguage.ja: '青短', AppLanguage.zhCn: '青短', AppLanguage.zhTw: '青短',
        AppLanguage.es: 'Azul', AppLanguage.fr: 'Bleu', AppLanguage.de: 'Blau', AppLanguage.pt: 'Azul', AppLanguage.th: 'น้ำเงิน',
      },
      'cardGradeGrassRibbon': {
        AppLanguage.ko: '초단', AppLanguage.en: 'Grass', AppLanguage.ja: '草短', AppLanguage.zhCn: '草短', AppLanguage.zhTw: '草短',
        AppLanguage.es: 'Hierba', AppLanguage.fr: 'Herbe', AppLanguage.de: 'Gras', AppLanguage.pt: 'Grama', AppLanguage.th: 'หญ้า',
      },
      'cardGradeRibbon': {
        AppLanguage.ko: '띠', AppLanguage.en: 'Ribbon', AppLanguage.ja: '短冊', AppLanguage.zhCn: '条', AppLanguage.zhTw: '條',
        AppLanguage.es: 'Cinta', AppLanguage.fr: 'Ruban', AppLanguage.de: 'Band', AppLanguage.pt: 'Fita', AppLanguage.th: 'แถบ',
      },
      'cardGradeJunk': {
        AppLanguage.ko: '피', AppLanguage.en: 'Junk', AppLanguage.ja: 'カス', AppLanguage.zhCn: '皮', AppLanguage.zhTw: '皮',
        AppLanguage.es: 'Basura', AppLanguage.fr: 'Rebut', AppLanguage.de: 'Schrott', AppLanguage.pt: 'Lixo', AppLanguage.th: 'พี',
      },
      // ─── [도감 카드등급 이름] ───
      'cardGradeAnimalFull': {
        AppLanguage.ko: '열끗 (멍텅구리)', AppLanguage.en: 'Animal (10-pt)', AppLanguage.ja: 'タネ (動物)', AppLanguage.zhCn: '种 (动物)', AppLanguage.zhTw: '種 (動物)',
        AppLanguage.es: 'Animal (10 pts)', AppLanguage.fr: 'Animal (10 pts)', AppLanguage.de: 'Tier (10 Pkt)', AppLanguage.pt: 'Animal (10 pts)', AppLanguage.th: 'สัตว์ (10 คะแนน)',
      },
      'cardGradeRibbonFull': {
        AppLanguage.ko: '띠 (단)', AppLanguage.en: 'Ribbon (Dan)', AppLanguage.ja: '短冊 (短)', AppLanguage.zhCn: '条 (短)', AppLanguage.zhTw: '條 (短)',
        AppLanguage.es: 'Cinta (Dan)', AppLanguage.fr: 'Ruban (Dan)', AppLanguage.de: 'Band (Dan)', AppLanguage.pt: 'Fita (Dan)', AppLanguage.th: 'แถบ (ดัน)',
      },
      // ─── [도움말 툴팁] ───
      'help': {
        AppLanguage.ko: '도움말', AppLanguage.en: 'Help', AppLanguage.ja: 'ヘルプ', AppLanguage.zhCn: '帮助', AppLanguage.zhTw: '幫助',
        AppLanguage.es: 'Ayuda', AppLanguage.fr: 'Aide', AppLanguage.de: 'Hilfe', AppLanguage.pt: 'Ajuda', AppLanguage.th: 'ช่วยเหลือ',
      },
      // ─── [상점 UI 텍스트] ───
      'shopSecretShop': {
        AppLanguage.ko: '비밀 상점', AppLanguage.en: 'Secret Shop', AppLanguage.ja: '秘密ショップ', AppLanguage.zhCn: '秘密商店', AppLanguage.zhTw: '秘密商店',
        AppLanguage.es: 'Tienda secreta', AppLanguage.fr: 'Boutique secrète', AppLanguage.de: 'Geheimshop', AppLanguage.pt: 'Loja secreta', AppLanguage.th: 'ร้านลับ',
      },
      'shopActiveSkillTitle': {
        AppLanguage.ko: '⚡ 인게임 액티브 스킬 (소모품)', AppLanguage.en: '⚡ In-game Active Skills (Consumable)', AppLanguage.ja: '⚡ インゲーム・アクティブスキル (消耗品)', AppLanguage.zhCn: '⚡ 游戏内主动技能 (消耗品)', AppLanguage.zhTw: '⚡ 遊戲內主動技能 (消耗品)',
        AppLanguage.es: '⚡ Habilidades activas (Consumible)', AppLanguage.fr: '⚡ Compétences actives (Consommable)', AppLanguage.de: '⚡ Aktive Fähigkeiten (Verbrauchbar)', AppLanguage.pt: '⚡ Habilidades ativas (Consumível)', AppLanguage.th: '⚡ สกิลแอคทีฟ (ใช้แล้วหมด)',
      },
      'shopActiveSkillSubtitle': {
        AppLanguage.ko: '게임 중 턴을 소모하지 않고 원할 때 발동!', AppLanguage.en: 'Activate anytime during the game without using a turn!', AppLanguage.ja: 'ゲーム中、ターンを消費せずに好きなタイミングで発動！', AppLanguage.zhCn: '游戏中随时发动，不消耗回合！', AppLanguage.zhTw: '遊戲中隨時發動，不消耗回合！',
        AppLanguage.es: '¡Activa en cualquier momento sin gastar turno!', AppLanguage.fr: 'Activez à tout moment sans utiliser de tour !', AppLanguage.de: 'Jederzeit aktivieren, ohne einen Zug zu verbrauchen!', AppLanguage.pt: 'Ative a qualquer momento sem gastar turno!', AppLanguage.th: 'เปิดใช้ได้ตลอดเกมโดยไม่เสียเทิร์น!',
      },
      'shopPreRoundTitle': {
        AppLanguage.ko: '🛡️ 라운드 장착 (일회성)', AppLanguage.en: '🛡️ Round Equipment (One-time)', AppLanguage.ja: '🛡️ ラウンド装備 (使い捨て)', AppLanguage.zhCn: '🛡️ 回合装备 (一次性)', AppLanguage.zhTw: '🛡️ 回合裝備 (一次性)',
        AppLanguage.es: '🛡️ Equipo de ronda (Un solo uso)', AppLanguage.fr: '🛡️ Equipement de manche (Usage unique)', AppLanguage.de: '🛡️ Rundenausrüstung (Einmalig)', AppLanguage.pt: '🛡️ Equipamento de rodada (Uso único)', AppLanguage.th: '🛡️ อุปกรณ์ประจำรอบ (ใช้ครั้งเดียว)',
      },
      'shopPreRoundSubtitle': {
        AppLanguage.ko: '이번 판 시작 전에 미리 장비! (판 종료 시 소멸)', AppLanguage.en: 'Equip before the round starts! (Expires when round ends)', AppLanguage.ja: 'ラウンド開始前に装備！(ラウンド終了時に消滅)', AppLanguage.zhCn: '回合开始前装备！(回合结束后消失)', AppLanguage.zhTw: '回合開始前裝備！(回合結束後消失)',
        AppLanguage.es: '¡Equipa antes de que empiece la ronda! (Desaparece al terminar)', AppLanguage.fr: 'Equipez avant le début de la manche ! (Disparait a la fin)', AppLanguage.de: 'Vor Rundenbeginn ausrüsten! (Verschwindet bei Rundenende)', AppLanguage.pt: 'Equipe antes da rodada comecar! (Expira ao final)', AppLanguage.th: 'สวมใส่ก่อนเริ่มรอบ! (หายไปเมื่อจบรอบ)',
      },
      'shopPassiveTitle': {
        AppLanguage.ko: '🔮 패시브 스킬', AppLanguage.en: '🔮 Passive Skills', AppLanguage.ja: '🔮 パッシブスキル', AppLanguage.zhCn: '🔮 被动技能', AppLanguage.zhTw: '🔮 被動技能',
        AppLanguage.es: '🔮 Habilidades pasivas', AppLanguage.fr: '🔮 Compétences passives', AppLanguage.de: '🔮 Passive Fähigkeiten', AppLanguage.pt: '🔮 Habilidades passivas', AppLanguage.th: '🔮 สกิลพาสซีฟ',
      },
      'shopPassiveSubtitle': {
        AppLanguage.ko: '보유만 해도 자동 발동! 시너지를 노려보세요', AppLanguage.en: 'Auto-activates while owned! Aim for synergies', AppLanguage.ja: '所持するだけで自動発動！シナジーを狙おう', AppLanguage.zhCn: '持有即自动生效！追求协同效果吧', AppLanguage.zhTw: '持有即自動生效！追求協同效果吧',
        AppLanguage.es: '¡Se activa automaticamente al tenerla! Busca sinergias', AppLanguage.fr: "S'active automatiquement ! Visez les synergies", AppLanguage.de: 'Aktiviert sich automatisch! Sucht Synergien', AppLanguage.pt: 'Ativa automaticamente ao possuir! Busque sinergias', AppLanguage.th: 'เปิดใช้งานอัตโนมัติเมื่อถือ! มุ่งหาซินเนอร์จี',
      },
      'shopTalismanTitle': {
        AppLanguage.ko: '📜 영구 부적', AppLanguage.en: '📜 Talismans', AppLanguage.ja: '📜 お守り', AppLanguage.zhCn: '📜 护符', AppLanguage.zhTw: '📜 護符',
        AppLanguage.es: '📜 Talismanes', AppLanguage.fr: '📜 Talismans', AppLanguage.de: '📜 Talismane', AppLanguage.pt: '📜 Talismãs', AppLanguage.th: '📜 เครื่องราง',
      },
      'shopTalismanSubtitle': {
        AppLanguage.ko: '한 번 사두면 런 전체 적용!', AppLanguage.en: 'Buy once, applies for the entire run!', AppLanguage.ja: '一度買えばラン全体に適用！', AppLanguage.zhCn: '买一次，整个运行生效！', AppLanguage.zhTw: '買一次，整個運行生效！',
        AppLanguage.es: '¡Compra una vez, aplica durante toda la partida!', AppLanguage.fr: 'Achetez une fois, actif pour toute la partie !', AppLanguage.de: 'Einmal kaufen, gilt für den gesamten Run!', AppLanguage.pt: 'Compre uma vez, vale para toda a partida!', AppLanguage.th: 'ซื้อครั้งเดียว มีผลตลอดรอบ!',
      },
      'shopExit': {
        AppLanguage.ko: '쇼핑 종료 / 대기실로 →', AppLanguage.en: 'Finish Shopping / To Lobby →', AppLanguage.ja: 'ショッピング終了 / ロビーへ →', AppLanguage.zhCn: '结束购物 / 前往大厅 →', AppLanguage.zhTw: '結束購物 / 前往大廳 →',
        AppLanguage.es: 'Terminar compras / Al vestibulo →', AppLanguage.fr: 'Fin des achats / Vers le lobby →', AppLanguage.de: 'Einkauf beenden / Zur Lobby →', AppLanguage.pt: 'Finalizar compras / Para o lobby →', AppLanguage.th: 'จบการช็อปปิ้ง / ไปล็อบบี้ →',
      },
      'shopEquipped': {
        AppLanguage.ko: '✅ 장착 완료', AppLanguage.en: '✅ Equipped', AppLanguage.ja: '✅ 装備済み', AppLanguage.zhCn: '✅ 已装备', AppLanguage.zhTw: '✅ 已裝備',
        AppLanguage.es: '✅ Equipado', AppLanguage.fr: '✅ Equipé', AppLanguage.de: '✅ Ausgerüstet', AppLanguage.pt: '✅ Equipado', AppLanguage.th: '✅ สวมใส่แล้ว',
      },
      'shopEquip': {
        AppLanguage.ko: '장착하기', AppLanguage.en: 'Equip', AppLanguage.ja: '装備する', AppLanguage.zhCn: '装备', AppLanguage.zhTw: '裝備',
        AppLanguage.es: 'Equipar', AppLanguage.fr: 'Equiper', AppLanguage.de: 'Ausrüsten', AppLanguage.pt: 'Equipar', AppLanguage.th: 'สวมใส่',
      },
      'shopOwnedPermanent': {
        AppLanguage.ko: '✅ 영구 보유 중', AppLanguage.en: '✅ Permanently Owned', AppLanguage.ja: '✅ 永久保有中', AppLanguage.zhCn: '✅ 永久持有中', AppLanguage.zhTw: '✅ 永久持有中',
        AppLanguage.es: '✅ Propiedad permanente', AppLanguage.fr: '✅ Possession permanente', AppLanguage.de: '✅ Dauerhaft im Besitz', AppLanguage.pt: '✅ Posse permanente', AppLanguage.th: '✅ ถือครองถาวร',
      },
      'shopPurchased': {
        AppLanguage.ko: '구매 완료', AppLanguage.en: 'Purchased', AppLanguage.ja: '購入済み', AppLanguage.zhCn: '已购买', AppLanguage.zhTw: '已購買',
        AppLanguage.es: 'Comprado', AppLanguage.fr: 'Acheté', AppLanguage.de: 'Gekauft', AppLanguage.pt: 'Comprado', AppLanguage.th: 'ซื้อแล้ว',
      },
      'shopUse': {
        AppLanguage.ko: '사용', AppLanguage.en: 'Use', AppLanguage.ja: '使用', AppLanguage.zhCn: '使用', AppLanguage.zhTw: '使用',
        AppLanguage.es: 'Usar', AppLanguage.fr: 'Utiliser', AppLanguage.de: 'Verwenden', AppLanguage.pt: 'Usar', AppLanguage.th: 'ใช้',
      },
      'skillUsed': {
        AppLanguage.ko: '스킬 사용!', AppLanguage.en: 'Skill Used!', AppLanguage.ja: 'スキル発動！', AppLanguage.zhCn: '技能已使用！', AppLanguage.zhTw: '技能已使用！',
        AppLanguage.es: '¡Habilidad usada!', AppLanguage.fr: 'Compétence utilisée !', AppLanguage.de: 'Skill eingesetzt!', AppLanguage.pt: 'Habilidade usada!', AppLanguage.th: 'ใช้สกิลแล้ว!',
      },
      'brightLabel': {
        AppLanguage.ko: '광', AppLanguage.en: 'Bright', AppLanguage.ja: '光', AppLanguage.zhCn: '光', AppLanguage.zhTw: '光',
        AppLanguage.es: 'Brillante', AppLanguage.fr: 'Lumière', AppLanguage.de: 'Licht', AppLanguage.pt: 'Brilhante', AppLanguage.th: 'กวัง',
      },
      // ─── [상점 추가 UI] ───
      'shopSoldOut': {
        AppLanguage.ko: '매진', AppLanguage.en: 'SOLD OUT', AppLanguage.ja: '売り切れ', AppLanguage.zhCn: '已售罄', AppLanguage.zhTw: '已售罄',
        AppLanguage.es: 'AGOTADO', AppLanguage.fr: 'ÉPUISÉ', AppLanguage.de: 'AUSVERKAUFT', AppLanguage.pt: 'ESGOTADO', AppLanguage.th: 'ขายหมดแล้ว',
      },
      'shopLocked': {
        AppLanguage.ko: '🔒 잠김', AppLanguage.en: '🔒 LOCKED', AppLanguage.ja: '🔒 未解放', AppLanguage.zhCn: '🔒 未解锁', AppLanguage.zhTw: '🔒 未解鎖',
        AppLanguage.es: '🔒 BLOQUEADO', AppLanguage.fr: '🔒 VERROUILLÉ', AppLanguage.de: '🔒 GESPERRT', AppLanguage.pt: '🔒 BLOQUEADO', AppLanguage.th: '🔒 ล็อค',
      },
      'shopSynergyTitle': {
        AppLanguage.ko: '-- 시너지 --', AppLanguage.en: '-- Synergy --', AppLanguage.ja: '-- シナジー --', AppLanguage.zhCn: '-- 协同效果 --', AppLanguage.zhTw: '-- 協同效果 --',
        AppLanguage.es: '-- Sinergia --', AppLanguage.fr: '-- Synergie --', AppLanguage.de: '-- Synergie --', AppLanguage.pt: '-- Sinergia --', AppLanguage.th: '-- ซินเนอร์จี --',
      },
      'shopInventoryTitle': {
        AppLanguage.ko: '-- 보유 아이템 --', AppLanguage.en: '-- Inventory --', AppLanguage.ja: '-- 所持アイテム --', AppLanguage.zhCn: '-- 持有道具 --', AppLanguage.zhTw: '-- 持有道具 --',
        AppLanguage.es: '-- Inventario --', AppLanguage.fr: '-- Inventaire --', AppLanguage.de: '-- Inventar --', AppLanguage.pt: '-- Inventário --', AppLanguage.th: '-- กระเป๋า --',
      },
      'shopSlotActive': {
        AppLanguage.ko: '액티브', AppLanguage.en: 'Active', AppLanguage.ja: 'アクティブ', AppLanguage.zhCn: '主动', AppLanguage.zhTw: '主動',
        AppLanguage.es: 'Activo', AppLanguage.fr: 'Actif', AppLanguage.de: 'Aktiv', AppLanguage.pt: 'Ativo', AppLanguage.th: 'แอคทีฟ',
      },
      'shopSlotPassive': {
        AppLanguage.ko: '패시브', AppLanguage.en: 'Passive', AppLanguage.ja: 'パッシブ', AppLanguage.zhCn: '被动', AppLanguage.zhTw: '被動',
        AppLanguage.es: 'Pasivo', AppLanguage.fr: 'Passif', AppLanguage.de: 'Passiv', AppLanguage.pt: 'Passivo', AppLanguage.th: 'พาสซีฟ',
      },
      'shopSlotTalisman': {
        AppLanguage.ko: '부적', AppLanguage.en: 'Talisman', AppLanguage.ja: 'お守り', AppLanguage.zhCn: '护符', AppLanguage.zhTw: '護符',
        AppLanguage.es: 'Talismán', AppLanguage.fr: 'Talisman', AppLanguage.de: 'Talisman', AppLanguage.pt: 'Talismã', AppLanguage.th: 'เครื่องราง',
      },
      'shopSlotConsumable': {
        AppLanguage.ko: '소모품', AppLanguage.en: 'Consumable', AppLanguage.ja: '消耗品', AppLanguage.zhCn: '消耗品', AppLanguage.zhTw: '消耗品',
        AppLanguage.es: 'Consumible', AppLanguage.fr: 'Consommable', AppLanguage.de: 'Verbrauchbar', AppLanguage.pt: 'Consumível', AppLanguage.th: 'ใช้แล้วหมด',
      },
      'unlockFiveBrights': {
        AppLanguage.ko: '해금: 오광 1회 달성', AppLanguage.en: 'Unlock: Achieve Five Brights once', AppLanguage.ja: '解放: 五光を1回達成', AppLanguage.zhCn: '解锁: 达成一次五光', AppLanguage.zhTw: '解鎖: 達成一次五光',
        AppLanguage.es: 'Desbloquear: Logra Cinco Brillantes', AppLanguage.fr: 'Débloquer: Obtenez Cinq Lumières', AppLanguage.de: 'Freischalten: Fünf Lichter erreichen', AppLanguage.pt: 'Desbloquear: Conquiste Cinco Brilhantes', AppLanguage.th: 'ปลดล็อค: ทำห้ากวังครั้งหนึ่ง',
      },
    };
    return _t(uiTexts[key] ?? {AppLanguage.ko: key});
  }

  /// 같은 월 카드 수 표시 (파라미터화)
  String sameMonthCards(int count) => _t({
    AppLanguage.ko: '같은 월 카드가 $count장 있습니다',
    AppLanguage.en: 'There are $count cards of the same month',
    AppLanguage.ja: '同じ月のカードが$count枚あります',
    AppLanguage.zhCn: '有$count张同月的牌',
    AppLanguage.zhTw: '有$count張同月的牌',
    AppLanguage.es: 'Hay $count cartas del mismo mes',
    AppLanguage.fr: 'Il y a $count cartes du même mois',
    AppLanguage.de: 'Es gibt $count Karten desselben Monats',
    AppLanguage.pt: 'Há $count cartas do mesmo mês',
    AppLanguage.th: 'มี $count ใบเดือนเดียวกัน',
  });

  /// 월 표시 형식화 (예: "1월", "Jan 1")
  String monthFormatted(int month) => _t({
    AppLanguage.ko: '$month월',
    AppLanguage.en: 'M$month',
    AppLanguage.ja: '$month月',
    AppLanguage.zhCn: '$month月',
    AppLanguage.zhTw: '$month月',
    AppLanguage.es: 'Mes $month',
    AppLanguage.fr: 'Mois $month',
    AppLanguage.de: 'Monat $month',
    AppLanguage.pt: 'Mês $month',
    AppLanguage.th: 'เดือน $month',
  });

  /// 고/스톱 배율 설명 (현재 배율 → 고 시 배율)
  String goStopMultiplierDesc(int currentMult, int nextMult) => _t({
    AppLanguage.ko: '현재 배율 $currentMult배 → 고 시 $nextMult배!',
    AppLanguage.en: 'Current x$currentMult → Go for x$nextMult!',
    AppLanguage.ja: '現在$currentMult倍 → ゴーで$nextMult倍！',
    AppLanguage.zhCn: '当前$currentMult倍 → Go后$nextMult倍！',
    AppLanguage.zhTw: '目前$currentMult倍 → Go後$nextMult倍！',
    AppLanguage.es: 'Actual x$currentMult → ¡Go para x$nextMult!',
    AppLanguage.fr: 'Actuel x$currentMult → Go pour x$nextMult !',
    AppLanguage.de: 'Aktuell x$currentMult → Go für x$nextMult!',
    AppLanguage.pt: 'Atual x$currentMult → Go para x$nextMult!',
    AppLanguage.th: 'ตอนนี้ x$currentMult → Go เป็น x$nextMult!',
  });

  // ─── [도움말/도감 시스템 텍스트] ───
  String get tabRules => _t({
    AppLanguage.ko: '규칙', AppLanguage.en: 'Rules', AppLanguage.ja: 'ルール', AppLanguage.zhCn: '规则', AppLanguage.zhTw: '規則',
    AppLanguage.es: 'Reglas', AppLanguage.fr: 'Règles', AppLanguage.de: 'Regeln', AppLanguage.pt: 'Regras', AppLanguage.th: 'กติกา',
  });
  String get tabDictionary => _t({
    AppLanguage.ko: '도감', AppLanguage.en: 'Cards', AppLanguage.ja: '図鑑', AppLanguage.zhCn: '图鉴', AppLanguage.zhTw: '圖鑑',
    AppLanguage.es: 'Cartas', AppLanguage.fr: 'Cartes', AppLanguage.de: 'Karten', AppLanguage.pt: 'Cartas', AppLanguage.th: 'สมุดไพ่',
  });
  String get tabYaku => _t({
    AppLanguage.ko: '족보', AppLanguage.en: 'Yaku', AppLanguage.ja: '役', AppLanguage.zhCn: '牌型', AppLanguage.zhTw: '牌型',
    AppLanguage.es: 'Yaku', AppLanguage.fr: 'Yaku', AppLanguage.de: 'Yaku', AppLanguage.pt: 'Yaku', AppLanguage.th: 'ยาคุ',
  });

  String get ruleIntroTitle => _t({
    AppLanguage.ko: '🎴 게임 기본 규칙', AppLanguage.en: '🎴 Basic Rules', AppLanguage.ja: '🎴 基本ルール', AppLanguage.zhCn: '🎴 基本规则', AppLanguage.zhTw: '🎴 基本規則',
    AppLanguage.es: '🎴 Reglas básicas', AppLanguage.fr: '🎴 Règles de base', AppLanguage.de: '🎴 Grundregeln', AppLanguage.pt: '🎴 Regras básicas', AppLanguage.th: '🎴 กติกาพื้นฐาน',
  });
  String get ruleIntroBody => _t({
    AppLanguage.ko: 'K-Poker(화투)는 같은 계절(1~12월)의 무늬를 맞춰 카드를 획득하는 한국 전통 고스톱 기반 카드 배틀입니다.',
    AppLanguage.en: 'K-Poker (Hwatu) is a card battle based on traditional Korean Go-Stop, where you match cards of the same month/season to capture them.',
    AppLanguage.ja: 'K-Poker(花札)は、同じ月(季節)の手札を合わせてカードを獲得する、韓国の伝統的な「ゴーストップ」ベースのカードバトルです。',
    AppLanguage.zhCn: 'K-Poker (花牌) 是一款基于韩国传统 Go-Stop 的卡牌对战游戏，通过匹配同月/季节的卡牌来进行。',
    AppLanguage.zhTw: 'K-Poker (花牌) 是一款基於韓國傳統 Go-Stop 的卡牌對戰遊戲，透過配對同月/季節的卡牌來進行。',
    AppLanguage.es: 'K-Poker (Hwatu) es un juego de cartas basado en el tradicional Go-Stop coreano, donde emparejas cartas del mismo mes/estación para capturarlas.',
    AppLanguage.fr: 'K-Poker (Hwatu) est un jeu de cartes basé sur le Go-Stop coréen traditionnel, où vous associez des cartes du même mois/saison pour les capturer.',
    AppLanguage.de: 'K-Poker (Hwatu) ist ein Kartenspiel basierend auf dem traditionellen koreanischen Go-Stop, bei dem du Karten des gleichen Monats/der gleichen Jahreszeit kombinierst.',
    AppLanguage.pt: 'K-Poker (Hwatu) é um jogo de cartas baseado no tradicional Go-Stop coreano, onde você combina cartas do mesmo mês/estação para capturá-las.',
    AppLanguage.th: 'K-Poker (ฮวาตู) คือเกมไพ่แบทเทิลที่อิงจากโกสต็อปแบบดั้งเดิมของเกาหลี จับคู่ไพ่ของเดือน/ฤดูกาลเดียวกันเพื่อยึดไพ่',
  });

  String get ruleTurnTitle => _t({
    AppLanguage.ko: '🔄 턴 진행', AppLanguage.en: '🔄 Turn Flow', AppLanguage.ja: '🔄 ターンの進行', AppLanguage.zhCn: '🔄 回合流程', AppLanguage.zhTw: '🔄 回合流程',
    AppLanguage.es: '🔄 Flujo del turno', AppLanguage.fr: '🔄 Déroulement du tour', AppLanguage.de: '🔄 Zugablauf', AppLanguage.pt: '🔄 Fluxo do turno', AppLanguage.th: '🔄 ลำดับเทิร์น',
  });
  String get ruleTurnBody => _t({
    AppLanguage.ko: '1. 내 손의 카드를 필드에 내어 같은 무늬를 맞춥니다.\n2. 덱에서 카드 1장을 뒤집어 필드에 냅니다.\n3. 매칭된 카드들을 내 공간으로 가져와 점수를 계산합니다!',
    AppLanguage.en: '1. Play a card from your hand to match the field.\n2. Flip 1 card from the deck to the field.\n3. Take all matched cards into your captured area to score!',
    AppLanguage.ja: '1. 手札からカードを出し、場の同じ柄に合わせます。\n2. 山札から1枚めくり、場に出します。\n3. マッチしたカードを獲得エリアに入れ、役と点数を作ります！',
    AppLanguage.zhCn: '1. 出一张手牌以匹配场上的花色。\n2. 从牌库翻开一张牌到场上。\n3. 将匹配成功的卡牌收入得分区！',
    AppLanguage.zhTw: '1. 出一張手牌以配對場上的花色。\n2. 從牌庫翻開一張牌到場上。\n3. 將配對成功的卡牌收入得分區！',
    AppLanguage.es: '1. Juega una carta de tu mano para emparejar con el campo.\n2. Voltea 1 carta del mazo al campo.\n3. ¡Toma las cartas emparejadas a tu área de captura para sumar puntos!',
    AppLanguage.fr: '1. Jouez une carte de votre main pour l\'associer au terrain.\n2. Retournez 1 carte du paquet sur le terrain.\n3. Prenez les cartes associées dans votre zone de capture pour marquer !',
    AppLanguage.de: '1. Spiele eine Karte aus deiner Hand, um sie dem Feld zuzuordnen.\n2. Decke 1 Karte vom Stapel auf das Feld auf.\n3. Nimm alle passenden Karten in deinen Gewinnbereich, um Punkte zu sammeln!',
    AppLanguage.pt: '1. Jogue uma carta da sua mão para combinar com o campo.\n2. Vire 1 carta do baralho para o campo.\n3. Leve as cartas combinadas para sua área de captura para pontuar!',
    AppLanguage.th: '1. เล่นไพ่จากมือเพื่อจับคู่กับสนาม\n2. พลิกไพ่ 1 ใบจากกองไพ่ไปที่สนาม\n3. นำไพ่ที่จับคู่ได้ไปยังพื้นที่ยึดเพื่อทำคะแนน!',
  });

  String get ruleGoStopTitle => _t({
    AppLanguage.ko: '🔥 고 & 스톱', AppLanguage.en: '🔥 Go & Stop', AppLanguage.ja: '🔥 ゴー & ストップ', AppLanguage.zhCn: '🔥 Go & Stop', AppLanguage.zhTw: '🔥 Go & Stop',
    AppLanguage.es: '🔥 Go y Stop', AppLanguage.fr: '🔥 Go et Stop', AppLanguage.de: '🔥 Go & Stop', AppLanguage.pt: '🔥 Go e Stop', AppLanguage.th: '🔥 โกและสต็อป',
  });
  String get ruleGoStopBody => _t({
    AppLanguage.ko: '획득한 점수가 3점 이상이 되면 선택할 수 있습니다.\n• GO: 게임을 계속합니다. 추가 점수와 2배율(3고 이상) 혜택을 얻지만, 상대가 먼저 점수를 내면 패배합니다(독박)!\n• STOP: 즉시 승리하며 베팅금을 얻어 스테이지를 넘깁니다.',
    AppLanguage.en: 'Available when you reach 3 or more points.\n• GO: Continue playing. You get multiplier bonuses (at 3 GO), but if the opponent scores first, you lose instantly (Dokbak)!\n• STOP: Win immediately and claim the bet money to clear the stage.',
    AppLanguage.ja: '3点以上になった時に選択できます。\n• GO：継続します。追加点や倍率ボーナス(3GO以上)を得ますが、相手に先に点数を取られると即敗北(独り被り)となります！\n• STOP：すぐに勝利し、賭け金を獲得してステージをクリアします。',
    AppLanguage.zhCn: '到达3分时可进行选择。\n• GO：继续游戏。可获得额外倍率(3 Go 以上)，但若对手先得分则立即失败(反加)。\n• STOP：立即胜利并带走奖金，进入下一关。',
    AppLanguage.zhTw: '到達3分時可進行選擇。\n• GO：繼續遊戲。可獲得額外倍率(3 Go 以上)，但若對手先得分則立即失敗(反加)。\n• STOP：立即勝利並帶走獎金，進入下一關。',
    AppLanguage.es: 'Disponible al alcanzar 3 o más puntos.\n• GO: Continuar jugando. Obtienes bonificación de multiplicador (a partir de 3 GO), pero si el oponente puntúa primero, ¡pierdes instantáneamente (Dokbak)!\n• STOP: Gana inmediatamente y reclama la apuesta para pasar de etapa.',
    AppLanguage.fr: 'Disponible lorsque vous atteignez 3 points ou plus.\n• GO : Continuer à jouer. Vous obtenez des bonus de multiplicateur (à 3 GO), mais si l\'adversaire marque en premier, vous perdez instantanément (Dokbak) !\n• STOP : Gagnez immédiatement et réclamez la mise pour passer l\'étape.',
    AppLanguage.de: 'Verfügbar ab 3 oder mehr Punkten.\n• GO: Weiterspielen. Du bekommst Multiplikator-Boni (ab 3 GO), aber wenn der Gegner zuerst punktet, verlierst du sofort (Dokbak)!\n• STOP: Sofort gewinnen und den Einsatz kassieren, um die Stufe zu bestehen.',
    AppLanguage.pt: 'Disponível ao atingir 3 ou mais pontos.\n• GO: Continue jogando. Você ganha bônus de multiplicador (a partir de 3 GO), mas se o oponente pontuar primeiro, você perde instantaneamente (Dokbak)!\n• STOP: Vença imediatamente e reivindique a aposta para passar de fase.',
    AppLanguage.th: 'ใช้ได้เมื่อได้ 3 คะแนนขึ้นไป\n• GO: เล่นต่อ ได้โบนัสตัวคูณ (ตั้งแต่ 3 GO) แต่ถ้าคู่ต่อสู้ทำคะแนนก่อน จะแพ้ทันที (ด็อกบัก)!\n• STOP: ชนะทันทีและรับเงินเดิมพันเพื่อผ่านด่าน',
  });

  // ─── [족보 안내 텍스트] ───
  String get yakuGwangTitle => _t({
    AppLanguage.ko: '🌟 광 (Kwang)', AppLanguage.en: '🌟 Kwang (Bright)', AppLanguage.ja: '🌟 光 (光札)', AppLanguage.zhCn: '🌟 光', AppLanguage.zhTw: '🌟 光',
    AppLanguage.es: '🌟 Kwang (Brillante)', AppLanguage.fr: '🌟 Kwang (Lumière)', AppLanguage.de: '🌟 Kwang (Licht)', AppLanguage.pt: '🌟 Kwang (Brilhante)', AppLanguage.th: '🌟 กวัง (สว่าง)',
  });
  String get yakuGwangBody => _t({
    AppLanguage.ko: '• 삼광: 광 3장 = 3점 (비광 포함시 2점)\n• 사광: 광 4장 = 4점\n• 오광: 광 5장 = 15점 (최강의 족보!)',
    AppLanguage.en: '• 3 Kwang: 3 Bright cards = 3 pts (2 pts if Rain card is included)\n• 4 Kwang: 4 Bright cards = 4 pts\n• 5 Kwang: All 5 Bright cards = 15 pts (Max!)',
    AppLanguage.ja: '• 三光：光札3枚 = 3点 (雨入りは2点)\n• 四光：光札4枚 = 4点\n• 五光：光札5枚 = 15点 (最強役!)',
    AppLanguage.zhCn: '• 三光：3张光牌 = 3分 (若含雨光则为2分)\n• 四光：4张光牌 = 4分\n• 五光：集齐5张光牌 = 15分 (最强!)',
    AppLanguage.zhTw: '• 三光：3張光牌 = 3分 (若含雨光則為2分)\n• 四光：4張光牌 = 4分\n• 五光：集齊5張光牌 = 15分 (最強!)',
    AppLanguage.es: '• 3 Kwang: 3 cartas Brillantes = 3 pts (2 pts si incluye carta de Lluvia)\n• 4 Kwang: 4 cartas Brillantes = 4 pts\n• 5 Kwang: Las 5 cartas Brillantes = 15 pts (¡Máximo!)',
    AppLanguage.fr: '• 3 Kwang : 3 cartes Lumière = 3 pts (2 pts si la carte Pluie est incluse)\n• 4 Kwang : 4 cartes Lumière = 4 pts\n• 5 Kwang : Les 5 cartes Lumière = 15 pts (Max !)',
    AppLanguage.de: '• 3 Kwang: 3 Lichtkarten = 3 Pkt (2 Pkt mit Regenkarte)\n• 4 Kwang: 4 Lichtkarten = 4 Pkt\n• 5 Kwang: Alle 5 Lichtkarten = 15 Pkt (Maximum!)',
    AppLanguage.pt: '• 3 Kwang: 3 cartas Brilhantes = 3 pts (2 pts se incluir carta de Chuva)\n• 4 Kwang: 4 cartas Brilhantes = 4 pts\n• 5 Kwang: Todas as 5 cartas Brilhantes = 15 pts (Máximo!)',
    AppLanguage.th: '• 3 กวัง: ไพ่สว่าง 3 ใบ = 3 คะแนน (2 คะแนนถ้ารวมไพ่ฝน)\n• 4 กวัง: ไพ่สว่าง 4 ใบ = 4 คะแนน\n• 5 กวัง: ไพ่สว่างครบ 5 ใบ = 15 คะแนน (สูงสุด!)',
  });

  String get yakuRibbonTitle => _t({
    AppLanguage.ko: '🎀 홍단 / 청단 / 초단', AppLanguage.en: '🎀 Dan (Ribbon)', AppLanguage.ja: '🎀 短 (赤短/青短/草短)', AppLanguage.zhCn: '🎀 短 (红/青/草短)', AppLanguage.zhTw: '🎀 短 (紅/青/草短)',
    AppLanguage.es: '🎀 Dan (Cinta)', AppLanguage.fr: '🎀 Dan (Ruban)', AppLanguage.de: '🎀 Dan (Band)', AppLanguage.pt: '🎀 Dan (Fita)', AppLanguage.th: '🎀 ดัน (แถบ)',
  });
  String get yakuRibbonBody => _t({
    AppLanguage.ko: '• 홍단: 글씨 있는 빨간 띠 3장 = 3점\n• 청단: 파란 띠 3장 = 3점\n• 초단: 글씨 없는 빨간 띠 3장 = 3점',
    AppLanguage.en: '• Red Ribbon: 3 Red Titled = 3 pts\n• Blue Ribbon: 3 Blue = 3 pts\n• Grass Ribbon: 3 Plain Red = 3 pts',
    AppLanguage.ja: '• 赤短：文字入り赤短冊3枚 = 3点\n• 青短：青短冊3枚 = 3点\n• 草短：文字なし赤短冊3枚 = 3点',
    AppLanguage.zhCn: '• 红短：3张带字红短 = 3分\n• 青短：3张青短 = 3分\n• 草短：3张无字红短 = 3分',
    AppLanguage.zhTw: '• 紅短：3張帶字紅短 = 3分\n• 青短：3張青短 = 3分\n• 草短：3張無字紅短 = 3分',
    AppLanguage.es: '• Cinta Roja: 3 cintas rojas con texto = 3 pts\n• Cinta Azul: 3 cintas azules = 3 pts\n• Cinta Hierba: 3 cintas rojas sin texto = 3 pts',
    AppLanguage.fr: '• Ruban Rouge : 3 rubans rouges avec texte = 3 pts\n• Ruban Bleu : 3 rubans bleus = 3 pts\n• Ruban Herbe : 3 rubans rouges sans texte = 3 pts',
    AppLanguage.de: '• Rotes Band: 3 rote Bänder mit Schrift = 3 Pkt\n• Blaues Band: 3 blaue Bänder = 3 Pkt\n• Grasband: 3 rote Bänder ohne Schrift = 3 Pkt',
    AppLanguage.pt: '• Fita Vermelha: 3 fitas vermelhas com texto = 3 pts\n• Fita Azul: 3 fitas azuis = 3 pts\n• Fita Grama: 3 fitas vermelhas sem texto = 3 pts',
    AppLanguage.th: '• แถบแดง: แถบแดงมีตัวอักษร 3 ใบ = 3 คะแนน\n• แถบน้ำเงิน: แถบน้ำเงิน 3 ใบ = 3 คะแนน\n• แถบหญ้า: แถบแดงไม่มีตัวอักษร 3 ใบ = 3 คะแนน',
  });

  String get yakuAnimalTitle => _t({
    AppLanguage.ko: '🦌 멍텅구리 (고도리/열끗)', AppLanguage.en: '🦌 Godori & Animal', AppLanguage.ja: '🦌 動物 (猪鹿蝶/タネ)', AppLanguage.zhCn: '🦌 动物 (役鸟/十分)', AppLanguage.zhTw: '🦌 動物 (役鳥/十分)',
    AppLanguage.es: '🦌 Godori y Animal', AppLanguage.fr: '🦌 Godori et Animal', AppLanguage.de: '🦌 Godori & Tier', AppLanguage.pt: '🦌 Godori e Animal', AppLanguage.th: '🦌 โกโดริและสัตว์',
  });
  String get yakuAnimalBody => _t({
    AppLanguage.ko: '• 고도리: 새 그림 3장(2, 4, 8월) = 5점\n• 열끗: 동물 5장 = 1점 (이후 1장당 1점 추가)\n• 멍따: 열끗 7장 이상 = 점수 2배 폭증!',
    AppLanguage.en: '• Godori: 3 Bird cards (Feb, Apr, Aug) = 5 pts\n• Animal: 5 Animal cards = 1 pt (+1 pt per extra)\n• Mung-tta: 7+ Animal cards = Score x2!',
    AppLanguage.ja: '• 猪鹿蝶(ゴドリ)：鳥の絵3枚(2,4,8月) = 5点\n• タネ：動物5枚 = 1点 (以降1枚ごとに+1)\n• タネの倍付け：動物7枚以上 = スコア2倍！',
    AppLanguage.zhCn: '• 高鸟：集齐3张特定的鸟类牌 = 5分\n• 十分：5张动物牌 = 1分 (之后每多1张+1)\n• 十分翻倍：7张以上动物牌 = 总分 x2!',
    AppLanguage.zhTw: '• 高鳥：集齊3張特定的鳥類牌 = 5分\n• 十分：5張動物牌 = 1分 (之後每多1張+1)\n• 十分翻倍：7張以上動物牌 = 總分 x2!',
    AppLanguage.es: '• Godori: 3 cartas de Pájaro (Feb, Abr, Ago) = 5 pts\n• Animal: 5 cartas de Animal = 1 pt (+1 pt por extra)\n• Mung-tta: 7+ cartas de Animal = ¡Puntuación x2!',
    AppLanguage.fr: '• Godori : 3 cartes Oiseau (Fév, Avr, Août) = 5 pts\n• Animal : 5 cartes Animal = 1 pt (+1 pt par carte supplémentaire)\n• Mung-tta : 7+ cartes Animal = Score x2 !',
    AppLanguage.de: '• Godori: 3 Vogelkarten (Feb, Apr, Aug) = 5 Pkt\n• Tier: 5 Tierkarten = 1 Pkt (+1 Pkt pro zusätzliche)\n• Mung-tta: 7+ Tierkarten = Punktzahl x2!',
    AppLanguage.pt: '• Godori: 3 cartas de Pássaro (Fev, Abr, Ago) = 5 pts\n• Animal: 5 cartas de Animal = 1 pt (+1 pt por extra)\n• Mung-tta: 7+ cartas de Animal = Pontuação x2!',
    AppLanguage.th: '• โกโดริ: ไพ่นก 3 ใบ (ก.พ., เม.ย., ส.ค.) = 5 คะแนน\n• สัตว์: ไพ่สัตว์ 5 ใบ = 1 คะแนน (+1 ต่อใบเพิ่ม)\n• มุงตา: ไพ่สัตว์ 7+ ใบ = คะแนน x2!',
  });

  String get yakuPiTitle => _t({
    AppLanguage.ko: '🍂 피 (Pi)', AppLanguage.en: '🍂 Pi (Junk)', AppLanguage.ja: '🍂 カス (皮)', AppLanguage.zhCn: '🍂 皮 (杂牌)', AppLanguage.zhTw: '🍂 皮 (雜牌)',
    AppLanguage.es: '🍂 Pi (Basura)', AppLanguage.fr: '🍂 Pi (Rebut)', AppLanguage.de: '🍂 Pi (Schrott)', AppLanguage.pt: '🍂 Pi (Lixo)', AppLanguage.th: '🍂 พี (ขยะ)',
  });
  String get yakuPiBody => _t({
    AppLanguage.ko: '• 피: 가장 흔한 카드. 10장 = 1점 (이후 1장당 1점 추가)\n• 쌍피: 피 2장으로 취급되는 특수 카드!',
    AppLanguage.en: '• Pi: Common cards. 10 Pi = 1 pt (+1 pt per extra)\n• Double Pi (Ssang-Pi): Counts as 2 Pi cards!',
    AppLanguage.ja: '• カス：最も一般的なカード。10枚 = 1点(以降+1)\n• 双皮(サンピ)：カス2枚分として計算される特殊カード！',
    AppLanguage.zhCn: '• 皮：最普通的杂牌。10张=1分 (之后每多1张+1)\n• 双皮：视为2张皮的稀有卡！',
    AppLanguage.zhTw: '• 皮：最普通的雜牌。10張=1分 (之後每多1張+1)\n• 雙皮：視為2張皮的稀有卡！',
    AppLanguage.es: '• Pi: Cartas comunes. 10 Pi = 1 pt (+1 pt por extra)\n• Doble Pi (Ssang-Pi): ¡Cuenta como 2 cartas Pi!',
    AppLanguage.fr: '• Pi : Cartes communes. 10 Pi = 1 pt (+1 pt par carte supplémentaire)\n• Double Pi (Ssang-Pi) : Compte comme 2 cartes Pi !',
    AppLanguage.de: '• Pi: Gewöhnliche Karten. 10 Pi = 1 Pkt (+1 Pkt pro zusätzliche)\n• Doppel-Pi (Ssang-Pi): Zählt als 2 Pi-Karten!',
    AppLanguage.pt: '• Pi: Cartas comuns. 10 Pi = 1 pt (+1 pt por extra)\n• Pi Duplo (Ssang-Pi): Conta como 2 cartas Pi!',
    AppLanguage.th: '• พี: ไพ่ทั่วไป 10 พี = 1 คะแนน (+1 ต่อใบเพิ่ม)\n• พีคู่ (ซังพี): นับเป็นไพ่พี 2 ใบ!',
  });

  // ─── [실시간 튜토리얼 팝업 텍스트] ───
  String get tutFirstYakuTitle => _t({
    AppLanguage.ko: '🎉 첫 족보 완성!', AppLanguage.en: '🎉 First Yaku!', AppLanguage.ja: '🎉 初役完成！', AppLanguage.zhCn: '🎉 首次达成牌型！', AppLanguage.zhTw: '🎉 首次達成牌型！',
    AppLanguage.es: '🎉 ¡Primer Yaku!', AppLanguage.fr: '🎉 Premier Yaku !', AppLanguage.de: '🎉 Erstes Yaku!', AppLanguage.pt: '🎉 Primeiro Yaku!', AppLanguage.th: '🎉 ยาคุแรก!',
  });
  String get tutFirstYakuBody => _t({
    AppLanguage.ko: '족보를 완성하여 점수를 획득했습니다!\n총 점수가 3점을 넘기면 [고/스톱]을 통해 게임의 승부를 결정지을 수 있습니다. 족보 점수는 우측 패널을 통해 언제든 확인할 수 있어요.',
    AppLanguage.en: 'You gained points by completing a Yaku!\nReach 3 points to decide whether to GO or STOP. You can always check your Yaku checklist on the right panel.',
    AppLanguage.ja: '役を完成してスコアを獲得しました！\n合計3点を超えると、[GO]または[STOP]で勝負を決められます。完成した役の状況は右側のパネルで確認できます。',
    AppLanguage.zhCn: '你完成了一个牌型并获得了分数！\n总分达到3分时可以宣告 GO 或 STOP。你可以随时在右侧面板查看牌型进度。',
    AppLanguage.zhTw: '你完成了一個牌型並獲得了分數！\n總分達到3分時可以宣告 GO 或 STOP。你可以隨時在右側面板查看牌型進度。',
    AppLanguage.es: '¡Ganaste puntos al completar un Yaku!\nAlcanza 3 puntos para decidir si hacer GO o STOP. Puedes revisar tu lista de Yaku en el panel derecho.',
    AppLanguage.fr: 'Vous avez gagné des points en complétant un Yaku !\nAtteignez 3 points pour décider de faire GO ou STOP. Vous pouvez consulter votre liste de Yaku dans le panneau de droite.',
    AppLanguage.de: 'Du hast Punkte durch ein Yaku erhalten!\nErreiche 3 Punkte, um zwischen GO und STOP zu wählen. Du kannst deine Yaku-Checkliste jederzeit im rechten Panel prüfen.',
    AppLanguage.pt: 'Você ganhou pontos ao completar um Yaku!\nAlcance 3 pontos para decidir entre GO ou STOP. Você pode verificar sua lista de Yaku no painel direito.',
    AppLanguage.th: 'คุณได้คะแนนจากการทำยาคุสำเร็จ!\nถึง 3 คะแนนเพื่อเลือก GO หรือ STOP ตรวจสอบรายการยาคุได้ที่แผงด้านขวา',
  });

  String get tutFirstGoTitle => _t({
    AppLanguage.ko: '🔥 첫 GO!', AppLanguage.en: '🔥 First GO!', AppLanguage.ja: '🔥 初のGO！', AppLanguage.zhCn: '🔥 首次宣告 GO！', AppLanguage.zhTw: '🔥 首次宣告 GO！',
    AppLanguage.es: '🔥 ¡Primer GO!', AppLanguage.fr: '🔥 Premier GO !', AppLanguage.de: '🔥 Erstes GO!', AppLanguage.pt: '🔥 Primeiro GO!', AppLanguage.th: '🔥 โกครั้งแรก!',
  });
  String get tutFirstGoBody => _t({
    AppLanguage.ko: '고를 외치셨군요! 상남자다운 선택입니다.\n고를 할수록 보너스 배율이 커지지만, 만약 다음 턴에 상대방이 먼저 3점을 내고 스톱해버리면 [독박]을 쓰고 패배하게 됩니다! 무운을 빕니다!',
    AppLanguage.en: 'You called GO! A bold choice.\nEach GO increases your score multipliers, but if your opponent reaches 3 points and calls STOP first, you will lose instantly (Dokbak). Good luck!',
    AppLanguage.ja: 'GOを宣言しましたね！強気な選択です！\nGOをするほど倍率が上がりますが、次に相手が先に3点でSTOPを宣言してしまうと、独り被り(ドクバク)で敗北になります！健闘を祈ります！',
    AppLanguage.zhCn: '你宣告了 GO！勇敢的选择。\n每次 GO 都会增加分数倍率，但如果对方先达到3分并喊 STOP，你将直接失败(反加)。祝你好运！',
    AppLanguage.zhTw: '你宣告了 GO！勇敢的選擇。\n每次 GO 都會增加分數倍率，但如果對方先達到3分並喊 STOP，你將直接失敗(反加)。祝你好運！',
    AppLanguage.es: '¡Declaraste GO! Una elección audaz.\nCada GO aumenta tu multiplicador de puntuación, pero si tu oponente alcanza 3 puntos y declara STOP primero, ¡perderás instantáneamente (Dokbak). ¡Buena suerte!',
    AppLanguage.fr: 'Vous avez déclaré GO ! Un choix audacieux.\nChaque GO augmente vos multiplicateurs, mais si votre adversaire atteint 3 points et déclare STOP en premier, vous perdez instantanément (Dokbak). Bonne chance !',
    AppLanguage.de: 'Du hast GO erklärt! Eine mutige Wahl.\nJedes GO erhöht deinen Punktemultiplikator, aber wenn dein Gegner 3 Punkte erreicht und zuerst STOP sagt, verlierst du sofort (Dokbak). Viel Glück!',
    AppLanguage.pt: 'Você declarou GO! Uma escolha ousada.\nCada GO aumenta seu multiplicador de pontuação, mas se seu oponente atingir 3 pontos e declarar STOP primeiro, você perde instantaneamente (Dokbak). Boa sorte!',
    AppLanguage.th: 'คุณประกาศ GO! ทางเลือกที่กล้าหาญ\nทุก GO จะเพิ่มตัวคูณคะแนน แต่ถ้าคู่ต่อสู้ถึง 3 คะแนนและประกาศ STOP ก่อน คุณจะแพ้ทันที (ด็อกบัก) โชคดี!',
  });

  String get continueBtn => _t({
    AppLanguage.ko: '확인', AppLanguage.en: 'Understood', AppLanguage.ja: '確認', AppLanguage.zhCn: '确定', AppLanguage.zhTw: '確定',
    AppLanguage.es: 'Entendido', AppLanguage.fr: 'Compris', AppLanguage.de: 'Verstanden', AppLanguage.pt: 'Entendido', AppLanguage.th: 'เข้าใจแล้ว',
  });
  String get doNotShowAgain => _t({
    AppLanguage.ko: '다시 보지 않기', AppLanguage.en: 'Do not show again', AppLanguage.ja: '次回から表示しない', AppLanguage.zhCn: '不再显示', AppLanguage.zhTw: '不再顯示',
    AppLanguage.es: 'No mostrar de nuevo', AppLanguage.fr: 'Ne plus afficher', AppLanguage.de: 'Nicht mehr anzeigen', AppLanguage.pt: 'Não mostrar novamente', AppLanguage.th: 'ไม่แสดงอีก',
  });

  // ─── [인게임 특수 이벤트 텍스트] ───
  String get eventMatchStart => _t({
    AppLanguage.ko: '🎴 새 라운드 시작!', AppLanguage.en: '🎴 New Round Started!', AppLanguage.ja: '🎴 新しいラウンドが開始！', AppLanguage.zhCn: '🎴 新回合开始！', AppLanguage.zhTw: '🎴 新回合開始！',
    AppLanguage.es: '🎴 ¡Nueva ronda!', AppLanguage.fr: '🎴 Nouvelle manche !', AppLanguage.de: '🎴 Neue Runde!', AppLanguage.pt: '🎴 Nova rodada!', AppLanguage.th: '🎴 รอบใหม่เริ่ม!',
  });
  String eventChongtong(int month) => _t({
    AppLanguage.ko: '🎆 총통! $month월 4장! 즉시 승리! (+3점)', AppLanguage.en: '🎆 Chongtong! All 4 cards of Month $month! Instant Win! (+3)', AppLanguage.ja: '🎆 総統！$month月の4枚！即勝利！(+3点)', AppLanguage.zhCn: '🎆 总统！$month月4张！直接获胜！(+3分)', AppLanguage.zhTw: '🎆 總統！$month月4張！直接獲勝！(+3分)',
    AppLanguage.es: '🎆 ¡Chongtong! ¡Las 4 cartas del mes $month! ¡Victoria instantánea! (+3)', AppLanguage.fr: '🎆 Chongtong ! Les 4 cartes du mois $month ! Victoire instantanée ! (+3)', AppLanguage.de: '🎆 Chongtong! Alle 4 Karten von Monat $month! Sofortiger Sieg! (+3)', AppLanguage.pt: '🎆 Chongtong! Todas as 4 cartas do mês $month! Vitória instantânea! (+3)', AppLanguage.th: '🎆 ชงทง! ไพ่ครบ 4 ใบเดือน $month! ชนะทันที! (+3)',
  });
  String get eventSkillShuffle => _t({
    AppLanguage.ko: '🌪️ [덱 셔플] 발동! 필드와 덱을 재배열했습니다!', AppLanguage.en: '🌪️ [Deck Shuffle] Reordered field and deck!', AppLanguage.ja: '🌪️ [デッキシャッフル] 発動！場と山札を再配置！', AppLanguage.zhCn: '🌪️ [洗牌] 发动！重新排列场上和牌堆！', AppLanguage.zhTw: '🌪️ [洗牌] 發動！重新排列場上和牌堆！',
    AppLanguage.es: '🌪️ [Barajar mazo] ¡Campo y mazo reordenados!', AppLanguage.fr: '🌪️ [Mélange] Terrain et paquet réorganisés !', AppLanguage.de: '🌪️ [Deck mischen] Feld und Deck neu geordnet!', AppLanguage.pt: '🌪️ [Embaralhar] Campo e baralho reorganizados!', AppLanguage.th: '🌪️ [สับไพ่] จัดเรียงสนามและกองไพ่ใหม่!',
  });
  String get eventSkillSniperSuccess => _t({
    AppLanguage.ko: '🎯 [스나이퍼] 발동! 상대 피 1장을 탈취했습니다!', AppLanguage.en: '🎯 [Sniper] Stole 1 Junk from opponent!', AppLanguage.ja: '🎯 [スナイパー] 相手のカスを1枚奪取！', AppLanguage.zhCn: '🎯 [狙击] 夺取对手1张皮！', AppLanguage.zhTw: '🎯 [狙擊] 奪取對手1張皮！',
    AppLanguage.es: '🎯 [Francotirador] ¡Robaste 1 Basura al oponente!', AppLanguage.fr: '🎯 [Sniper] 1 Rebut volé à l\'adversaire !', AppLanguage.de: '🎯 [Scharfschütze] 1 Schrott vom Gegner gestohlen!', AppLanguage.pt: '🎯 [Atirador] Roubou 1 Lixo do oponente!', AppLanguage.th: '🎯 [สไนเปอร์] ขโมยพี 1 ใบจากคู่ต่อสู้!',
  });
  String get eventSkillSniperFail => _t({
    AppLanguage.ko: '🎯 [스나이퍼] 뺏을 수 있는 피가 없습니다!', AppLanguage.en: '🎯 [Sniper] Opponent has no Junk to steal!', AppLanguage.ja: '🎯 [スナイパー] 奪えるカスがありません！', AppLanguage.zhCn: '🎯 [狙击] 对方没有可以夺取的皮！', AppLanguage.zhTw: '🎯 [狙擊] 對方沒有可以奪取的皮！',
    AppLanguage.es: '🎯 [Francotirador] ¡El oponente no tiene Basura!', AppLanguage.fr: '🎯 [Sniper] L\'adversaire n\'a pas de Rebut !', AppLanguage.de: '🎯 [Scharfschütze] Gegner hat keinen Schrott!', AppLanguage.pt: '🎯 [Atirador] Oponente não tem Lixo!', AppLanguage.th: '🎯 [สไนเปอร์] คู่ต่อสู้ไม่มีพีให้ขโมย!',
  });
  String get eventSkillJoker => _t({
    AppLanguage.ko: '🃏 [전용 조커] 강력한 다음 턴을 준비합니다!', AppLanguage.en: '🃏 [Joker] Preparing a powerful next turn!', AppLanguage.ja: '🃏 [ジョーカー] 強力な次のターンを準備します！', AppLanguage.zhCn: '🃏 [小丑] 准备强力的下一回合！', AppLanguage.zhTw: '🃏 [小丑] 準備強力的下一回合！',
    AppLanguage.es: '🃏 [Comodín] ¡Preparando un turno poderoso!', AppLanguage.fr: '🃏 [Joker] Prépare un prochain tour puissant !', AppLanguage.de: '🃏 [Joker] Bereitet eine starke nächste Runde vor!', AppLanguage.pt: '🃏 [Coringa] Preparando um turno poderoso!', AppLanguage.th: '🃏 [โจ๊กเกอร์] เตรียมเทิร์นถัดไปที่ทรงพลัง!',
  });

  String eventPlayerMatch(String name, int count) => _t({
    AppLanguage.ko: '✅ $name → $count장 획득!', AppLanguage.en: '✅ $name → Captured $count!', AppLanguage.ja: '✅ $name → $count枚獲得！', AppLanguage.zhCn: '✅ $name → 获得 $count 张！', AppLanguage.zhTw: '✅ $name → 獲得 $count 張！',
    AppLanguage.es: '✅ $name → ¡$count capturadas!', AppLanguage.fr: '✅ $name → $count capturées !', AppLanguage.de: '✅ $name → $count erbeutet!', AppLanguage.pt: '✅ $name → $count capturadas!', AppLanguage.th: '✅ $name → ยึดได้ $count!',
  });
  String eventPlayerMiss(String name) => _t({
    AppLanguage.ko: '❌ $name → 매칭 실패', AppLanguage.en: '❌ $name → Missed', AppLanguage.ja: '❌ $name → マッチ失敗', AppLanguage.zhCn: '❌ $name → 匹配失败', AppLanguage.zhTw: '❌ $name → 匹配失敗',
    AppLanguage.es: '❌ $name → Falló', AppLanguage.fr: '❌ $name → Raté', AppLanguage.de: '❌ $name → Daneben', AppLanguage.pt: '❌ $name → Errou', AppLanguage.th: '❌ $name → พลาด',
  });
  String eventAiMatch(String name, int count) => _t({
    AppLanguage.ko: '🤖 AI: $name → $count장 획득', AppLanguage.en: '🤖 AI: $name → Captured $count', AppLanguage.ja: '🤖 AI: $name → $count枚獲得', AppLanguage.zhCn: '🤖 AI: $name → 获得 $count 张', AppLanguage.zhTw: '🤖 AI: $name → 獲得 $count 張',
    AppLanguage.es: '🤖 AI: $name → $count capturadas', AppLanguage.fr: '🤖 AI: $name → $count capturées', AppLanguage.de: '🤖 AI: $name → $count erbeutet', AppLanguage.pt: '🤖 AI: $name → $count capturadas', AppLanguage.th: '🤖 AI: $name → ยึดได้ $count',
  });
  String eventAiMiss(String name) => _t({
    AppLanguage.ko: '🤖 AI: $name', AppLanguage.en: '🤖 AI: $name', AppLanguage.ja: '🤖 AI: $name', AppLanguage.zhCn: '🤖 AI: $name', AppLanguage.zhTw: '🤖 AI: $name',
    AppLanguage.es: '🤖 AI: $name', AppLanguage.fr: '🤖 AI: $name', AppLanguage.de: '🤖 AI: $name', AppLanguage.pt: '🤖 AI: $name', AppLanguage.th: '🤖 AI: $name',
  });

  String get eventAiStop => _t({
    AppLanguage.ko: '🤖 AI: 스톱! 라운드 종료!', AppLanguage.en: '🤖 AI: STOP! Round ended!', AppLanguage.ja: '🤖 AI: ストップ！ ラウンド終了！', AppLanguage.zhCn: '🤖 AI: 停！ 回合结束！', AppLanguage.zhTw: '🤖 AI: 停！ 回合結束！',
    AppLanguage.es: '🤖 AI: ¡STOP! ¡Ronda terminada!', AppLanguage.fr: '🤖 AI: STOP ! Manche terminée !', AppLanguage.de: '🤖 AI: STOP! Runde beendet!', AppLanguage.pt: '🤖 AI: STOP! Rodada encerrada!', AppLanguage.th: '🤖 AI: สต็อป! จบรอบ!',
  });
  String eventAiGo(int count) => _t({
    AppLanguage.ko: '🤖🔥 AI: 고! ×$count', AppLanguage.en: '🤖🔥 AI: GO! ×$count', AppLanguage.ja: '🤖🔥 AI: ゴー！ ×$count', AppLanguage.zhCn: '🤖🔥 AI: 继续！ ×$count', AppLanguage.zhTw: '🤖🔥 AI: 繼續！ ×$count',
    AppLanguage.es: '🤖🔥 AI: ¡GO! ×$count', AppLanguage.fr: '🤖🔥 AI: GO ! ×$count', AppLanguage.de: '🤖🔥 AI: GO! ×$count', AppLanguage.pt: '🤖🔥 AI: GO! ×$count', AppLanguage.th: '🤖🔥 AI: โก! ×$count',
  });
  String eventAiBomb(int month) => _t({
    AppLanguage.ko: '🤖💣 AI: $month월 폭탄!', AppLanguage.en: '🤖💣 AI: Bomb of Month $month!', AppLanguage.ja: '🤖💣 AI: $month月の爆弾！', AppLanguage.zhCn: '🤖💣 AI: $month月炸弹！', AppLanguage.zhTw: '🤖💣 AI: $month月炸彈！',
    AppLanguage.es: '🤖💣 AI: ¡Bomba del mes $month!', AppLanguage.fr: '🤖💣 AI: Bombe du mois $month !', AppLanguage.de: '🤖💣 AI: Bombe von Monat $month!', AppLanguage.pt: '🤖💣 AI: Bomba do mês $month!', AppLanguage.th: '🤖💣 AI: ระเบิดเดือน $month!',
  });

  String get eventDraw => _t({
    AppLanguage.ko: '🤝 무승부! (나가리)', AppLanguage.en: '🤝 Draw! (Nagari)', AppLanguage.ja: '🤝 引き分け！ (流れ)', AppLanguage.zhCn: '🤝 平局！ (流局)', AppLanguage.zhTw: '🤝 平局！ (流局)',
    AppLanguage.es: '🤝 ¡Empate! (Nagari)', AppLanguage.fr: '🤝 Égalité ! (Nagari)', AppLanguage.de: '🤝 Unentschieden! (Nagari)', AppLanguage.pt: '🤝 Empate! (Nagari)', AppLanguage.th: '🤝 เสมอ! (นาการิ)',
  });
  String get aiTalkDraw => _t({
    AppLanguage.ko: '무승부다!', AppLanguage.en: 'It\'s a draw!', AppLanguage.ja: '引き分けだな！', AppLanguage.zhCn: '平局！', AppLanguage.zhTw: '平局！',
    AppLanguage.es: '¡Empate!', AppLanguage.fr: 'Égalité !', AppLanguage.de: 'Unentschieden!', AppLanguage.pt: 'Empate!', AppLanguage.th: 'เสมอ!',
  });
  String get eventRewardGoBak => _t({
    AppLanguage.ko: '🎉 상대 고박(Go-Bak)! 점수 2배 획득!', AppLanguage.en: '🎉 Opponent Go-Bak! Double points!', AppLanguage.ja: '🎉 相手の被り(ドクバク)！得点2倍！', AppLanguage.zhCn: '🎉 对手反加(Go-Bak)！分数乘2！', AppLanguage.zhTw: '🎉 對手反加(Go-Bak)！分數乘2！',
    AppLanguage.es: '🎉 ¡Go-Bak del oponente! ¡Puntos dobles!', AppLanguage.fr: '🎉 Go-Bak adverse ! Points doublés !', AppLanguage.de: '🎉 Go-Bak des Gegners! Doppelte Punkte!', AppLanguage.pt: '🎉 Go-Bak do oponente! Pontos dobrados!', AppLanguage.th: '🎉 คู่ต่อสู้โกบัก! คะแนนสองเท่า!',
  });
  String eventWin(String amount) => _t({
    AppLanguage.ko: '🏆 승리! +$amount', AppLanguage.en: '🏆 Win! +$amount', AppLanguage.ja: '🏆 勝利！ +$amount', AppLanguage.zhCn: '🏆 获胜！ +$amount', AppLanguage.zhTw: '🏆 獲勝！ +$amount',
    AppLanguage.es: '🏆 ¡Victoria! +$amount', AppLanguage.fr: '🏆 Victoire ! +$amount', AppLanguage.de: '🏆 Sieg! +$amount', AppLanguage.pt: '🏆 Vitória! +$amount', AppLanguage.th: '🏆 ชนะ! +$amount',
  });
  String get eventPenaltyGoBak => _t({
    AppLanguage.ko: '💀 유저 고박(Go-Bak)! 벌금 2배!', AppLanguage.en: '💀 Player Go-Bak! Double penalty!', AppLanguage.ja: '💀 自分の被り(ドクバク)！罰金2倍！', AppLanguage.zhCn: '💀 玩家反加(Go-Bak)！罚款乘2！', AppLanguage.zhTw: '💀 玩家反加(Go-Bak)！罰款乘2！',
    AppLanguage.es: '💀 ¡Go-Bak del jugador! ¡Penalización doble!', AppLanguage.fr: '💀 Go-Bak du joueur ! Pénalité doublée !', AppLanguage.de: '💀 Spieler Go-Bak! Doppelte Strafe!', AppLanguage.pt: '💀 Go-Bak do jogador! Penalidade dobrada!', AppLanguage.th: '💀 ผู้เล่นโกบัก! โทษสองเท่า!',
  });
  String eventLose(String amount) => _t({
    AppLanguage.ko: '💀 패배... -$amount', AppLanguage.en: '💀 Lose... -$amount', AppLanguage.ja: '💀 敗北... -$amount', AppLanguage.zhCn: '💀 失败... -$amount', AppLanguage.zhTw: '💀 失敗... -$amount',
    AppLanguage.es: '💀 Derrota... -$amount', AppLanguage.fr: '💀 Défaite... -$amount', AppLanguage.de: '💀 Niederlage... -$amount', AppLanguage.pt: '💀 Derrota... -$amount', AppLanguage.th: '💀 แพ้... -$amount',
  });

  String get eventPlayerGo => _t({
    AppLanguage.ko: '🔥 고! 선언! (배율 증가)', AppLanguage.en: '🔥 GO! Declared! (Multiplier increased)', AppLanguage.ja: '🔥 ゴー！ 宣言！ (倍率増加)', AppLanguage.zhCn: '🔥 继续！宣告！ (倍率增加)', AppLanguage.zhTw: '🔥 繼續！宣告！ (倍率增加)',
    AppLanguage.es: '🔥 ¡GO! ¡Declarado! (Multiplicador aumentado)', AppLanguage.fr: '🔥 GO ! Déclaré ! (Multiplicateur augmenté)', AppLanguage.de: '🔥 GO! Erklärt! (Multiplikator erhöht)', AppLanguage.pt: '🔥 GO! Declarado! (Multiplicador aumentado)', AppLanguage.th: '🔥 โก! ประกาศ! (ตัวคูณเพิ่ม)',
  });
  String get eventPlayerStop => _t({
    AppLanguage.ko: '🛑 스톱! 라운드 종료!', AppLanguage.en: '🛑 STOP! Round ended!', AppLanguage.ja: '🛑 ストップ！ ラウンド終了！', AppLanguage.zhCn: '🛑 停！ 回合结束！', AppLanguage.zhTw: '🛑 停！ 回合結束！',
    AppLanguage.es: '🛑 ¡STOP! ¡Ronda terminada!', AppLanguage.fr: '🛑 STOP ! Manche terminée !', AppLanguage.de: '🛑 STOP! Runde beendet!', AppLanguage.pt: '🛑 STOP! Rodada encerrada!', AppLanguage.th: '🛑 สต็อป! จบรอบ!',
  });
  String eventPlayerBomb(int month, bool stolen) => _t({
    AppLanguage.ko: '💣 폭탄! $month월 3장 일괄 획득!${stolen ? ' + 상대 피 빼앗기!' : ''}',
    AppLanguage.en: '💣 Bomb! Captured 3 of Month $month!${stolen ? ' + Stole Junk!' : ''}',
    AppLanguage.ja: '💣 爆弾！$month月3枚獲得！${stolen ? ' + 相手のカス奪う！' : ''}',
    AppLanguage.zhCn: '💣 炸弹！一次获得3张$month月！${stolen ? ' + 夺取对手皮！' : ''}',
    AppLanguage.zhTw: '💣 炸彈！一次獲得3張$month月！${stolen ? ' + 奪取對手皮！' : ''}',
    AppLanguage.es: '💣 ¡Bomba! ¡3 cartas del mes $month capturadas!${stolen ? ' + ¡Robó Basura!' : ''}',
    AppLanguage.fr: '💣 Bombe ! 3 cartes du mois $month capturées !${stolen ? ' + Rebut volé !' : ''}',
    AppLanguage.de: '💣 Bombe! 3 Karten von Monat $month erbeutet!${stolen ? ' + Schrott gestohlen!' : ''}',
    AppLanguage.pt: '💣 Bomba! 3 cartas do mês $month capturadas!${stolen ? ' + Roubou Lixo!' : ''}',
    AppLanguage.th: '💣 ระเบิด! ยึดไพ่เดือน $month ครบ 3 ใบ!${stolen ? ' + ขโมยพี!' : ''}',
  });

  String get eventPpeok => _t({
    AppLanguage.ko: '💥 뻑! 아무것도 먹지 못하고 바닥에 쌓인다!', AppLanguage.en: '💥 Ppeok! Cards stack on the board!', AppLanguage.ja: '💥 ション！何も取れずに場に積まれる！', AppLanguage.zhCn: '💥 爆！什么都没吃到，留在场上！', AppLanguage.zhTw: '💥 爆！什麼都沒吃到，留在場上！',
    AppLanguage.es: '💥 ¡Ppeok! ¡Las cartas se apilan en el campo!', AppLanguage.fr: '💥 Ppeok ! Les cartes s\'empilent sur le terrain !', AppLanguage.de: '💥 Ppeok! Karten stapeln sich auf dem Feld!', AppLanguage.pt: '💥 Ppeok! Cartas se empilham no campo!', AppLanguage.th: '💥 ปอก! ไพ่กองบนสนาม!',
  });
  String get eventDoublePpeok => _t({
    AppLanguage.ko: '🔥🔥 연뻑!! +3점 획득!', AppLanguage.en: '🔥🔥 Double Ppeok!! +3 points!', AppLanguage.ja: '🔥🔥 連続ション！！ +3点獲得！', AppLanguage.zhCn: '🔥🔥 连爆！！ +3分！', AppLanguage.zhTw: '🔥🔥 連爆！！ +3分！',
    AppLanguage.es: '🔥🔥 ¡¡Doble Ppeok!! ¡+3 puntos!', AppLanguage.fr: '🔥🔥 Double Ppeok !! +3 points !', AppLanguage.de: '🔥🔥 Doppel-Ppeok!! +3 Punkte!', AppLanguage.pt: '🔥🔥 Ppeok duplo!! +3 pontos!', AppLanguage.th: '🔥🔥 ปอกคู่!! +3 คะแนน!',
  });
  String get eventTriplePpeok => _t({
    AppLanguage.ko: '🔥🔥🔥 삼뻑!!! 즉시 승리!!!', AppLanguage.en: '🔥🔥🔥 Triple Ppeok!!! Instant Win!!!', AppLanguage.ja: '🔥🔥🔥 3連続ション！！！ 即勝利！！！', AppLanguage.zhCn: '🔥🔥🔥 三连爆！！！ 直接获胜！！！', AppLanguage.zhTw: '🔥🔥🔥 三連爆！！！ 直接獲勝！！！',
    AppLanguage.es: '🔥🔥🔥 ¡¡¡Triple Ppeok!!! ¡¡¡Victoria instantánea!!!', AppLanguage.fr: '🔥🔥🔥 Triple Ppeok !!! Victoire instantanée !!!', AppLanguage.de: '🔥🔥🔥 Dreifach-Ppeok!!! Sofortiger Sieg!!!', AppLanguage.pt: '🔥🔥🔥 Ppeok triplo!!! Vitória instantânea!!!', AppLanguage.th: '🔥🔥🔥 ปอกสาม!!! ชนะทันที!!!',
  });
  String eventChok(bool stolen) => _t({
    AppLanguage.ko: '✌️ 쪽!${stolen ? ' 상대 피 빼앗기!' : ''}',
    AppLanguage.en: '✌️ Chok!${stolen ? ' Stole Junk!' : ''}',
    AppLanguage.ja: '✌️ チュッ！${stolen ? ' 相手のカス奪う！' : ''}',
    AppLanguage.zhCn: '✌️ 吻！${stolen ? ' 夺取对手皮！' : ''}',
    AppLanguage.zhTw: '✌️ 吻！${stolen ? ' 奪取對手皮！' : ''}',
    AppLanguage.es: '✌️ ¡Chok!${stolen ? ' ¡Robó Basura!' : ''}',
    AppLanguage.fr: '✌️ Chok !${stolen ? ' Rebut volé !' : ''}',
    AppLanguage.de: '✌️ Chok!${stolen ? ' Schrott gestohlen!' : ''}',
    AppLanguage.pt: '✌️ Chok!${stolen ? ' Roubou Lixo!' : ''}',
    AppLanguage.th: '✌️ จ๊อก!${stolen ? ' ขโมยพี!' : ''}',
  });
  String eventChokSweep(bool stolen) => _t({
    AppLanguage.ko: '✌️🌊 쪽 + 쓸!${stolen ? ' 상대 피 빼앗기!' : ''}',
    AppLanguage.en: '✌️🌊 Chok + Sweep!${stolen ? ' Stole Junk!' : ''}',
    AppLanguage.ja: '✌️🌊 チュッ + 掃き！${stolen ? ' 相手のカス奪う！' : ''}',
    AppLanguage.zhCn: '✌️🌊 吻 + 清空！${stolen ? ' 夺取对手皮！' : ''}',
    AppLanguage.zhTw: '✌️🌊 吻 + 清空！${stolen ? ' 奪取對手皮！' : ''}',
    AppLanguage.es: '✌️🌊 ¡Chok + Barrida!${stolen ? ' ¡Robó Basura!' : ''}',
    AppLanguage.fr: '✌️🌊 Chok + Balayage !${stolen ? ' Rebut volé !' : ''}',
    AppLanguage.de: '✌️🌊 Chok + Sweep!${stolen ? ' Schrott gestohlen!' : ''}',
    AppLanguage.pt: '✌️🌊 Chok + Varredura!${stolen ? ' Roubou Lixo!' : ''}',
    AppLanguage.th: '✌️🌊 จ๊อก + กวาด!${stolen ? ' ขโมยพี!' : ''}',
  });
  String eventTadak(bool stolen) => _t({
    AppLanguage.ko: '⚡ 따닥!${stolen ? ' 상대 피 빼앗기!' : ''}',
    AppLanguage.en: '⚡ Tadak!${stolen ? ' Stole Junk!' : ''}',
    AppLanguage.ja: '⚡ タダック(連鎖)！${stolen ? ' 相手のカス奪う！' : ''}',
    AppLanguage.zhCn: '⚡ 连打！${stolen ? ' 夺取对手皮！' : ''}',
    AppLanguage.zhTw: '⚡ 連打！${stolen ? ' 奪取對手皮！' : ''}',
    AppLanguage.es: '⚡ ¡Tadak!${stolen ? ' ¡Robó Basura!' : ''}',
    AppLanguage.fr: '⚡ Tadak !${stolen ? ' Rebut volé !' : ''}',
    AppLanguage.de: '⚡ Tadak!${stolen ? ' Schrott gestohlen!' : ''}',
    AppLanguage.pt: '⚡ Tadak!${stolen ? ' Roubou Lixo!' : ''}',
    AppLanguage.th: '⚡ ตาดัก!${stolen ? ' ขโมยพี!' : ''}',
  });
  String eventSweep(bool stolen) => _t({
    AppLanguage.ko: '🌊 쓸!${stolen ? ' 상대 피 빼앗기!' : ''}',
    AppLanguage.en: '🌊 Sweep!${stolen ? ' Stole Junk!' : ''}',
    AppLanguage.ja: '🌊 掃き！${stolen ? ' 相手のカス奪う！' : ''}',
    AppLanguage.zhCn: '🌊 清空！${stolen ? ' 夺取对手皮！' : ''}',
    AppLanguage.zhTw: '🌊 清空！${stolen ? ' 奪取對手皮！' : ''}',
    AppLanguage.es: '🌊 ¡Barrida!${stolen ? ' ¡Robó Basura!' : ''}',
    AppLanguage.fr: '🌊 Balayage !${stolen ? ' Rebut volé !' : ''}',
    AppLanguage.de: '🌊 Sweep!${stolen ? ' Schrott gestohlen!' : ''}',
    AppLanguage.pt: '🌊 Varredura!${stolen ? ' Roubou Lixo!' : ''}',
    AppLanguage.th: '🌊 กวาด!${stolen ? ' ขโมยพี!' : ''}',
  });
  String eventPpeokEat(bool stolen) => _t({
    AppLanguage.ko: '💥 뻑 먹기! 4장 일괄 획득!${stolen ? ' + 피 빼앗기!' : ''}',
    AppLanguage.en: '💥 Ppeok Eat! Captured all 4!${stolen ? ' + Stole Junk!' : ''}',
    AppLanguage.ja: '💥 ション食い！4枚一括獲得！${stolen ? ' + カス奪う！' : ''}',
    AppLanguage.zhCn: '💥 吃爆！全数获得！${stolen ? ' + 夺取皮！' : ''}',
    AppLanguage.zhTw: '💥 吃爆！全數獲得！${stolen ? ' + 奪取皮！' : ''}',
    AppLanguage.es: '💥 ¡Ppeok Eat! ¡4 cartas capturadas!${stolen ? ' + ¡Robó Basura!' : ''}',
    AppLanguage.fr: '💥 Ppeok Eat ! Les 4 capturées !${stolen ? ' + Rebut volé !' : ''}',
    AppLanguage.de: '💥 Ppeok Eat! Alle 4 erbeutet!${stolen ? ' + Schrott gestohlen!' : ''}',
    AppLanguage.pt: '💥 Ppeok Eat! Todas as 4 capturadas!${stolen ? ' + Roubou Lixo!' : ''}',
    AppLanguage.th: '💥 กินปอก! ยึดครบ 4 ใบ!${stolen ? ' + ขโมยพี!' : ''}',
  });
  String eventSelfPpeok(bool stolen) => _t({
    AppLanguage.ko: '💥🔥 자뻑 먹기! 4장 획득!${stolen ? ' + 피 빼앗기!' : ''}',
    AppLanguage.en: '💥🔥 Self Ppeok! Captured all 4!${stolen ? ' + Stole Junk!' : ''}',
    AppLanguage.ja: '💥🔥 自爆食い！4枚獲得！${stolen ? ' + カス奪う！' : ''}',
    AppLanguage.zhCn: '💥🔥 自吃爆！全数获得！${stolen ? ' + 夺取皮！' : ''}',
    AppLanguage.zhTw: '💥🔥 自吃爆！全數獲得！${stolen ? ' + 奪取皮！' : ''}',
    AppLanguage.es: '💥🔥 ¡Auto Ppeok! ¡4 cartas capturadas!${stolen ? ' + ¡Robó Basura!' : ''}',
    AppLanguage.fr: '💥🔥 Auto Ppeok ! Les 4 capturées !${stolen ? ' + Rebut volé !' : ''}',
    AppLanguage.de: '💥🔥 Selbst-Ppeok! Alle 4 erbeutet!${stolen ? ' + Schrott gestohlen!' : ''}',
    AppLanguage.pt: '💥🔥 Auto Ppeok! Todas as 4 capturadas!${stolen ? ' + Roubou Lixo!' : ''}',
    AppLanguage.th: '💥🔥 ปอกตัวเอง! ยึดครบ 4 ใบ!${stolen ? ' + ขโมยพี!' : ''}',
  });
  String eventGeneralBomb(bool stolen) => _t({
    AppLanguage.ko: '💣 폭탄!${stolen ? ' 상대 피 빼앗기!' : ''}',
    AppLanguage.en: '💣 Bomb!${stolen ? ' Stole Junk!' : ''}',
    AppLanguage.ja: '💣 爆弾！${stolen ? ' 相手のカス奪う！' : ''}',
    AppLanguage.zhCn: '💣 炸弹！${stolen ? ' 夺取对手皮！' : ''}',
    AppLanguage.zhTw: '💣 炸彈！${stolen ? ' 奪取對手皮！' : ''}',
    AppLanguage.es: '💣 ¡Bomba!${stolen ? ' ¡Robó Basura!' : ''}',
    AppLanguage.fr: '💣 Bombe !${stolen ? ' Rebut volé !' : ''}',
    AppLanguage.de: '💣 Bombe!${stolen ? ' Schrott gestohlen!' : ''}',
    AppLanguage.pt: '💣 Bomba!${stolen ? ' Roubou Lixo!' : ''}',
    AppLanguage.th: '💣 ระเบิด!${stolen ? ' ขโมยพี!' : ''}',
  });

  // ─── [게임 화면 UI 텍스트] ───
  String get opponentCapturedLabel => _t({
    AppLanguage.ko: '상대 획득', AppLanguage.en: 'Opp. Captured', AppLanguage.ja: '相手の獲得',
    AppLanguage.zhCn: '对手获得', AppLanguage.zhTw: '對手獲得',
    AppLanguage.es: 'Cap. Rival', AppLanguage.fr: 'Prises Adv.', AppLanguage.de: 'Gegner Gew.',
    AppLanguage.pt: 'Cap. Opon.', AppLanguage.th: 'ฝ่ายตรงข้ามได้',
  });
  String get playerCapturedLabel => _t({
    AppLanguage.ko: '내 획득', AppLanguage.en: 'My Captured', AppLanguage.ja: '自分の獲得',
    AppLanguage.zhCn: '我的获得', AppLanguage.zhTw: '我的獲得',
    AppLanguage.es: 'Mis Capturas', AppLanguage.fr: 'Mes Prises', AppLanguage.de: 'Meine Gew.',
    AppLanguage.pt: 'Minhas Cap.', AppLanguage.th: 'ของฉันได้',
  });
  String get skillActivateBtn => _t({
    AppLanguage.ko: '스킬발동', AppLanguage.en: 'Use Skill', AppLanguage.ja: 'スキル発動',
    AppLanguage.zhCn: '发动技能', AppLanguage.zhTw: '發動技能',
    AppLanguage.es: 'Usar Hab.', AppLanguage.fr: 'Activer', AppLanguage.de: 'Skill nutzen',
    AppLanguage.pt: 'Usar Hab.', AppLanguage.th: 'ใช้สกิล',
  });
  String get myTurnLabel => _t({
    AppLanguage.ko: '🎯 내 턴', AppLanguage.en: '🎯 My Turn', AppLanguage.ja: '🎯 自分のターン',
    AppLanguage.zhCn: '🎯 我的回合', AppLanguage.zhTw: '🎯 我的回合',
    AppLanguage.es: '🎯 Mi Turno', AppLanguage.fr: '🎯 Mon Tour', AppLanguage.de: '🎯 Mein Zug',
    AppLanguage.pt: '🎯 Minha Vez', AppLanguage.th: '🎯 ตาของฉัน',
  });
  String get fieldLabel => _t({
    AppLanguage.ko: '필드', AppLanguage.en: 'Field', AppLanguage.ja: 'フィールド',
    AppLanguage.zhCn: '场地', AppLanguage.zhTw: '場地',
    AppLanguage.es: 'Campo', AppLanguage.fr: 'Terrain', AppLanguage.de: 'Feld',
    AppLanguage.pt: 'Campo', AppLanguage.th: 'สนาม',
  });
  String chongtongBtn(int month) => _t({
    AppLanguage.ko: '🎆 총통 $month월', AppLanguage.en: '🎆 Chongtong M.$month', AppLanguage.ja: '🎆 総統 $month月',
    AppLanguage.zhCn: '🎆 总统 $month月', AppLanguage.zhTw: '🎆 總統 $month月',
    AppLanguage.es: '🎆 Chongtong M.$month', AppLanguage.fr: '🎆 Chongtong M.$month', AppLanguage.de: '🎆 Chongtong M.$month',
    AppLanguage.pt: '🎆 Chongtong M.$month', AppLanguage.th: '🎆 ชงทง เดือน $month',
  });
  String bombMonthLabel(int month) => _t({
    AppLanguage.ko: '$month월', AppLanguage.en: 'M.$month', AppLanguage.ja: '$month月',
    AppLanguage.zhCn: '$month月', AppLanguage.zhTw: '$month月',
    AppLanguage.es: 'Mes $month', AppLanguage.fr: 'Mois $month', AppLanguage.de: 'Mon. $month',
    AppLanguage.pt: 'Mês $month', AppLanguage.th: 'เดือน $month',
  });
  String get bombLabel => _t({
    AppLanguage.ko: '폭탄!', AppLanguage.en: 'Bomb!', AppLanguage.ja: '爆弾！',
    AppLanguage.zhCn: '炸弹！', AppLanguage.zhTw: '炸彈！',
    AppLanguage.es: '¡Bomba!', AppLanguage.fr: 'Bombe !', AppLanguage.de: 'Bombe!',
    AppLanguage.pt: 'Bomba!', AppLanguage.th: 'บอมบ์!',
  });
  String get activeSkillTitle => _t({
    AppLanguage.ko: '액티브 스킬 사용', AppLanguage.en: 'Use Active Skill', AppLanguage.ja: 'アクティブスキル使用',
    AppLanguage.zhCn: '使用主动技能', AppLanguage.zhTw: '使用主動技能',
    AppLanguage.es: 'Usar Habilidad', AppLanguage.fr: 'Compétence Active', AppLanguage.de: 'Aktiver Skill',
    AppLanguage.pt: 'Usar Habilidade', AppLanguage.th: 'ใช้สกิลแอคทีฟ',
  });
  String get noSkillAvailable => _t({
    AppLanguage.ko: '사용 가능한 스킬이 없습니다.', AppLanguage.en: 'No skills available.', AppLanguage.ja: '使用可能なスキルがありません。',
    AppLanguage.zhCn: '没有可用的技能。', AppLanguage.zhTw: '沒有可用的技能。',
    AppLanguage.es: 'No hay habilidades disponibles.', AppLanguage.fr: 'Aucune compétence disponible.', AppLanguage.de: 'Keine Skills verfügbar.',
    AppLanguage.pt: 'Nenhuma habilidade disponível.', AppLanguage.th: 'ไม่มีสกิลที่ใช้ได้',
  });
  String remainingCount(int count) => _t({
    AppLanguage.ko: '잔여: $count회', AppLanguage.en: 'Left: $count', AppLanguage.ja: '残り: $count回',
    AppLanguage.zhCn: '剩余: $count次', AppLanguage.zhTw: '剩餘: $count次',
    AppLanguage.es: 'Restante: $count', AppLanguage.fr: 'Restant : $count', AppLanguage.de: 'Übrig: $count',
    AppLanguage.pt: 'Restante: $count', AppLanguage.th: 'เหลือ: $count ครั้ง',
  });
  String get useBtn => _t({
    AppLanguage.ko: '사용', AppLanguage.en: 'Use', AppLanguage.ja: '使用',
    AppLanguage.zhCn: '使用', AppLanguage.zhTw: '使用',
    AppLanguage.es: 'Usar', AppLanguage.fr: 'Utiliser', AppLanguage.de: 'Benutzen',
    AppLanguage.pt: 'Usar', AppLanguage.th: 'ใช้',
  });
  String get closeBtn => _t({
    AppLanguage.ko: '닫기', AppLanguage.en: 'Close', AppLanguage.ja: '閉じる',
    AppLanguage.zhCn: '关闭', AppLanguage.zhTw: '關閉',
    AppLanguage.es: 'Cerrar', AppLanguage.fr: 'Fermer', AppLanguage.de: 'Schließen',
    AppLanguage.pt: 'Fechar', AppLanguage.th: 'ปิด',
  });

  // ─── [액티브 스킬 선택 다이얼로그] ───
  String get selectCardToCapture => _t({
    AppLanguage.ko: '획득할 카드를 선택하세요', AppLanguage.en: 'Select a card to capture', AppLanguage.ja: '獲得するカードを選んでください', AppLanguage.zhCn: '选择要获取的牌', AppLanguage.zhTw: '選擇要獲取的牌',
    AppLanguage.es: 'Selecciona una carta para capturar', AppLanguage.fr: 'Sélectionnez une carte à capturer', AppLanguage.de: 'Wähle eine Karte zum Erfassen', AppLanguage.pt: 'Selecione uma carta para capturar', AppLanguage.th: 'เลือกไพ่ที่ต้องการยึด',
  });
  String get selectFieldCard => _t({
    AppLanguage.ko: '바닥 카드를 선택하세요', AppLanguage.en: 'Select a field card', AppLanguage.ja: '場のカードを選んでください', AppLanguage.zhCn: '选择场上的牌', AppLanguage.zhTw: '選擇場上的牌',
    AppLanguage.es: 'Selecciona una carta del campo', AppLanguage.fr: 'Sélectionnez une carte du terrain', AppLanguage.de: 'Wähle eine Feldkarte', AppLanguage.pt: 'Selecione uma carta do campo', AppLanguage.th: 'เลือกไพ่ในสนาม',
  });
  String get selectHandCard => _t({
    AppLanguage.ko: '핸드 카드를 선택하세요', AppLanguage.en: 'Select a hand card', AppLanguage.ja: '手札を選んでください', AppLanguage.zhCn: '选择手牌', AppLanguage.zhTw: '選擇手牌',
    AppLanguage.es: 'Selecciona una carta de la mano', AppLanguage.fr: 'Sélectionnez une carte de la main', AppLanguage.de: 'Wähle eine Handkarte', AppLanguage.pt: 'Selecione uma carta da mão', AppLanguage.th: 'เลือกไพ่ในมือ',
  });
  String get peekTop3 => _t({
    AppLanguage.ko: '덱 상위 3장 확인', AppLanguage.en: 'Peek Top 3 Cards', AppLanguage.ja: 'デッキ上位3枚確認', AppLanguage.zhCn: '查看牌堆顶部3张', AppLanguage.zhTw: '查看牌堆頂部3張',
    AppLanguage.es: 'Ver 3 cartas superiores', AppLanguage.fr: 'Voir les 3 cartes du dessus', AppLanguage.de: 'Oberste 3 Karten ansehen', AppLanguage.pt: 'Ver 3 cartas do topo', AppLanguage.th: 'ดูไพ่ 3 ใบบนสุด',
  });
  String get moveUp => _t({
    AppLanguage.ko: '위로', AppLanguage.en: 'Up', AppLanguage.ja: '上へ', AppLanguage.zhCn: '上移', AppLanguage.zhTw: '上移',
    AppLanguage.es: 'Arriba', AppLanguage.fr: 'Haut', AppLanguage.de: 'Hoch', AppLanguage.pt: 'Acima', AppLanguage.th: 'ขึ้น',
  });
  String get moveDown => _t({
    AppLanguage.ko: '아래로', AppLanguage.en: 'Down', AppLanguage.ja: '下へ', AppLanguage.zhCn: '下移', AppLanguage.zhTw: '下移',
    AppLanguage.es: 'Abajo', AppLanguage.fr: 'Bas', AppLanguage.de: 'Runter', AppLanguage.pt: 'Abaixo', AppLanguage.th: 'ลง',
  });
  String get confirmBtn => _t({
    AppLanguage.ko: '확인', AppLanguage.en: 'Confirm', AppLanguage.ja: '確認', AppLanguage.zhCn: '确认', AppLanguage.zhTw: '確認',
    AppLanguage.es: 'Confirmar', AppLanguage.fr: 'Confirmer', AppLanguage.de: 'Bestätigen', AppLanguage.pt: 'Confirmar', AppLanguage.th: 'ยืนยัน',
  });
  String get noFieldCards => _t({
    AppLanguage.ko: '바닥에 카드가 없습니다', AppLanguage.en: 'No cards on the field', AppLanguage.ja: '場にカードがありません', AppLanguage.zhCn: '场上没有牌', AppLanguage.zhTw: '場上沒有牌',
    AppLanguage.es: 'No hay cartas en el campo', AppLanguage.fr: 'Pas de cartes sur le terrain', AppLanguage.de: 'Keine Karten auf dem Feld', AppLanguage.pt: 'Sem cartas no campo', AppLanguage.th: 'ไม่มีไพ่ในสนาม',
  });
  String eventSkillTrick(int month) => _t({
    AppLanguage.ko: '🎭 [속임수] 바닥 카드의 월을 $month월로 변경!', AppLanguage.en: '🎭 [Trick] Changed field card month to $month!', AppLanguage.ja: '🎭 [トリック] 場のカードの月を$month月に変更！', AppLanguage.zhCn: '🎭 [诡计] 将场上牌变为$month月！', AppLanguage.zhTw: '🎭 [詭計] 將場上牌變為$month月！',
    AppLanguage.es: '🎭 [Truco] ¡Mes cambiado a $month!', AppLanguage.fr: '🎭 [Ruse] Mois changé en $month !', AppLanguage.de: '🎭 [Trick] Monat auf $month geändert!', AppLanguage.pt: '🎭 [Truque] Mês alterado para $month!', AppLanguage.th: '🎭 [อุบาย] เปลี่ยนไพ่เป็นเดือน $month!',
  });
  String eventSkillLaundry(String cardName) => _t({
    AppLanguage.ko: '🧹 [카드 세탁] $cardName을(를) 덱으로 이동!', AppLanguage.en: '🧹 [Card Laundry] Moved $cardName to deck!', AppLanguage.ja: '🧹 [カード洗浄] $cardNameをデッキへ移動！', AppLanguage.zhCn: '🧹 [洗牌] $cardName 移入牌堆！', AppLanguage.zhTw: '🧹 [洗牌] $cardName 移入牌堆！',
    AppLanguage.es: '🧹 [Lavado] ¡$cardName movida al mazo!', AppLanguage.fr: '🧹 [Blanchiment] $cardName déplacée au paquet !', AppLanguage.de: '🧹 [Karten waschen] $cardName ins Deck verschoben!', AppLanguage.pt: '🧹 [Lavanderia] $cardName movida para o baralho!', AppLanguage.th: '🧹 [ซักไพ่] ย้าย $cardName ไปกองไพ่!',
  });
  String get eventSkillKeenEyeReorder => _t({
    AppLanguage.ko: '👁️ [눈썰미] 덱 상위 3장 순서를 변경했습니다!', AppLanguage.en: '👁️ [Keen Eye] Reordered top 3 deck cards!', AppLanguage.ja: '👁️ [鋭い目] デッキ上位3枚の順番を変更！', AppLanguage.zhCn: '👁️ [锐眼] 重新排列牌堆顶部3张！', AppLanguage.zhTw: '👁️ [銳眼] 重新排列牌堆頂部3張！',
    AppLanguage.es: '👁️ [Ojo agudo] ¡Reordenadas las 3 cartas superiores!', AppLanguage.fr: '👁️ [Oeil vif] Les 3 cartes du dessus réordonnées !', AppLanguage.de: '👁️ [Scharfes Auge] Oberste 3 Karten neu geordnet!', AppLanguage.pt: '👁️ [Olho aguçado] Reordenadas as 3 cartas do topo!', AppLanguage.th: '👁️ [ตาแหลม] จัดเรียงไพ่ 3 ใบบนสุดใหม่!',
  });
  String eventSkillJokerCapture(String cardName) => _t({
    AppLanguage.ko: '🃏 [조커] $cardName 획득!', AppLanguage.en: '🃏 [Joker] Captured $cardName!', AppLanguage.ja: '🃏 [ジョーカー] $cardName を獲得！', AppLanguage.zhCn: '🃏 [小丑] 获得 $cardName！', AppLanguage.zhTw: '🃏 [小丑] 獲得 $cardName！',
    AppLanguage.es: '🃏 [Comodín] ¡$cardName capturada!', AppLanguage.fr: '🃏 [Joker] $cardName capturée !', AppLanguage.de: '🃏 [Joker] $cardName erbeutet!', AppLanguage.pt: '🃏 [Coringa] $cardName capturada!', AppLanguage.th: '🃏 [โจ๊กเกอร์] ยึด $cardName!',
  });

  // ─── [흔들기] ───
  String get shakeTitle => _t({
    AppLanguage.ko: '흔들기!', AppLanguage.en: 'Shake!', AppLanguage.ja: '振り！', AppLanguage.zhCn: '摇动！', AppLanguage.zhTw: '搖動！',
    AppLanguage.es: '¡Agitar!', AppLanguage.fr: 'Secouer !', AppLanguage.de: 'Schütteln!', AppLanguage.pt: 'Sacudir!', AppLanguage.th: 'เขย่า!',
  });
  String shakeDesc(int month) => _t({
    AppLanguage.ko: '핸드에 $month월 카드 3장! 흔들기를 선언하면 이번 판 점수 2배!', AppLanguage.en: 'You have 3 cards of Month $month! Declare Shake for double score this round!', AppLanguage.ja: '手札に$month月のカードが3枚！振りを宣言するとこのラウンドのスコアが2倍！', AppLanguage.zhCn: '手中有$month月3张牌！宣言摇动，本回合得分翻倍！', AppLanguage.zhTw: '手中有$month月3張牌！宣言搖動，本回合得分翻倍！',
    AppLanguage.es: '¡Tienes 3 cartas del mes $month! ¡Declara Agitar para duplicar la puntuación!', AppLanguage.fr: 'Vous avez 3 cartes du mois $month ! Déclarez Secouer pour doubler le score !', AppLanguage.de: 'Du hast 3 Karten von Monat $month! Schütteln deklarieren für doppelte Punkte!', AppLanguage.pt: 'Você tem 3 cartas do mês $month! Declare Sacudir para dobrar a pontuação!', AppLanguage.th: 'มีไพ่เดือน $month 3 ใบ! ประกาศเขย่าเพื่อคะแนนสองเท่า!',
  });
  String get shakeDeclare => _t({
    AppLanguage.ko: '흔들기 선언', AppLanguage.en: 'Declare Shake', AppLanguage.ja: '振りを宣言', AppLanguage.zhCn: '宣言摇动', AppLanguage.zhTw: '宣言搖動',
    AppLanguage.es: 'Declarar Agitar', AppLanguage.fr: 'Déclarer Secouer', AppLanguage.de: 'Schütteln deklarieren', AppLanguage.pt: 'Declarar Sacudir', AppLanguage.th: 'ประกาศเขย่า',
  });
  String get shakePass => _t({
    AppLanguage.ko: '패스', AppLanguage.en: 'Pass', AppLanguage.ja: 'パス', AppLanguage.zhCn: '跳过', AppLanguage.zhTw: '跳過',
    AppLanguage.es: 'Pasar', AppLanguage.fr: 'Passer', AppLanguage.de: 'Passen', AppLanguage.pt: 'Passar', AppLanguage.th: 'ข้าม',
  });
  String shakeAnnounce(int month) => _t({
    AppLanguage.ko: '$month월 흔들기! 점수 2배!', AppLanguage.en: 'Month $month Shake! Score x2!', AppLanguage.ja: '$month月の振り！スコア2倍！', AppLanguage.zhCn: '$month月摇动！得分翻倍！', AppLanguage.zhTw: '$month月搖動！得分翻倍！',
    AppLanguage.es: '¡Mes $month Agitar! ¡Puntuación x2!', AppLanguage.fr: 'Mois $month Secouer ! Score x2 !', AppLanguage.de: 'Monat $month Schütteln! Punkte x2!', AppLanguage.pt: 'Mês $month Sacudir! Pontuação x2!', AppLanguage.th: 'เขย่าเดือน $month! คะแนน x2!',
  });
  String shakeAllDesc(int count) => _t({
    AppLanguage.ko: '${count}벌 모두 흔들면 x${pow(2, count).toInt()}배!', AppLanguage.en: 'Shake all $count sets for x${pow(2, count).toInt()}!', AppLanguage.ja: '${count}組全て振りでx${pow(2, count).toInt()}倍！', AppLanguage.zhCn: '全部${count}组摇动x${pow(2, count).toInt()}倍！', AppLanguage.zhTw: '全部${count}組搖動x${pow(2, count).toInt()}倍！',
    AppLanguage.es: '¡Agita los $count sets para x${pow(2, count).toInt()}!', AppLanguage.fr: 'Secouer les $count sets pour x${pow(2, count).toInt()} !', AppLanguage.de: 'Alle $count Sets schütteln für x${pow(2, count).toInt()}!', AppLanguage.pt: 'Sacudir todos os $count conjuntos para x${pow(2, count).toInt()}!', AppLanguage.th: 'เขย่าทั้ง $count ชุด x${pow(2, count).toInt()} เท่า!',
  });
  String get shakeAllDeclare => _t({
    AppLanguage.ko: '전체 흔들기', AppLanguage.en: 'Shake All', AppLanguage.ja: '全て振り', AppLanguage.zhCn: '全部摇动', AppLanguage.zhTw: '全部搖動',
    AppLanguage.es: 'Agitar Todo', AppLanguage.fr: 'Tout Secouer', AppLanguage.de: 'Alle Schütteln', AppLanguage.pt: 'Sacudir Tudo', AppLanguage.th: 'เขย่าทั้งหมด',
  });

  // ─── [AI 캐릭터 대사 번역] ───
  String getAiDialogue(String aiId, String situation, List<String> defaultKoLines) {
    if (defaultKoLines.isEmpty) return '...';
    final int index = DateTime.now().millisecond % defaultKoLines.length;

    if (language == AppLanguage.ko) return defaultKoLines[index];

    final Map<String, Map<String, List<String>>> targetMap;
    switch (language) {
      case AppLanguage.en: targetMap = aiDialoguesEn; break;
      case AppLanguage.ja: targetMap = aiDialoguesJa; break;
      case AppLanguage.zhCn:
      case AppLanguage.zhTw: targetMap = aiDialoguesZh; break;
      case AppLanguage.es: targetMap = aiDialoguesEs; break;
      case AppLanguage.fr: targetMap = aiDialoguesFr; break;
      case AppLanguage.de: targetMap = aiDialoguesDe; break;
      case AppLanguage.pt: targetMap = aiDialoguesPt; break;
      case AppLanguage.th: targetMap = aiDialoguesTh; break;
      default: return defaultKoLines[index];
    }

    final charMap = targetMap[aiId];
    if (charMap != null) {
      final situationLines = charMap[situation];
      if (situationLines != null && situationLines.isNotEmpty) {
        return situationLines[index % situationLines.length];
      }
    }
    return defaultKoLines[index];
  }

  // ─── [상점 동적 텍스트] ───
  String shopStage(int stage) => _t({
    AppLanguage.ko: '스테이지 $stage',
    AppLanguage.en: 'Stage $stage',
    AppLanguage.ja: 'ステージ $stage',
    AppLanguage.zhCn: '阶段 $stage',
    AppLanguage.zhTw: '階段 $stage',
    AppLanguage.es: 'Etapa $stage',
    AppLanguage.fr: 'Étape $stage',
    AppLanguage.de: 'Stufe $stage',
    AppLanguage.pt: 'Estágio $stage',
    AppLanguage.th: 'ด่าน $stage',
  });

  String shopReroll(int cost) => _t({
    AppLanguage.ko: '리롤 구매 ($cost G)',
    AppLanguage.en: 'Buy Reroll ($cost G)',
    AppLanguage.ja: 'リロール購入 ($cost G)',
    AppLanguage.zhCn: '购买刷新 ($cost G)',
    AppLanguage.zhTw: '購買刷新 ($cost G)',
    AppLanguage.es: 'Comprar Reroll ($cost G)',
    AppLanguage.fr: 'Acheter Reroll ($cost G)',
    AppLanguage.de: 'Reroll kaufen ($cost G)',
    AppLanguage.pt: 'Comprar Reroll ($cost G)',
    AppLanguage.th: 'ซื้อสุ่มใหม่ ($cost G)',
  });

  String shopOwnedCount(int count) => _t({
    AppLanguage.ko: '보유량: $count개',
    AppLanguage.en: 'Owned: $count',
    AppLanguage.ja: '所持数: $count個',
    AppLanguage.zhCn: '持有量: $count个',
    AppLanguage.zhTw: '持有量: $count個',
    AppLanguage.es: 'Cantidad: $count',
    AppLanguage.fr: 'Quantité: $count',
    AppLanguage.de: 'Bestand: $count',
    AppLanguage.pt: 'Quantidade: $count',
    AppLanguage.th: 'จำนวน: $count',
  });

  String shopBuyCost(int cost) => _t({
    AppLanguage.ko: '$cost G 구매',
    AppLanguage.en: 'Buy $cost G',
    AppLanguage.ja: '$cost G 購入',
    AppLanguage.zhCn: '购买 $cost G',
    AppLanguage.zhTw: '購買 $cost G',
    AppLanguage.es: 'Comprar $cost G',
    AppLanguage.fr: 'Acheter $cost G',
    AppLanguage.de: 'Kaufen $cost G',
    AppLanguage.pt: 'Comprar $cost G',
    AppLanguage.th: 'ซื้อ $cost G',
  });

  // ─── [시너지 번역] ───
  String getSynergyName(String id, String defaultNameKo) {
    if (language == AppLanguage.ko) return defaultNameKo;
    final Map<AppLanguage, String> names = _synergyNames[id] ?? {};
    return _t(names).isEmpty ? defaultNameKo : _t(names);
  }

  String getSynergyDesc(String id, String defaultDescKo) {
    if (language == AppLanguage.ko) return defaultDescKo;
    final Map<AppLanguage, String> descs = _synergyDescs[id] ?? {};
    return _t(descs).isEmpty ? defaultDescKo : _t(descs);
  }

  static const Map<String, Map<AppLanguage, String>> _synergyNames = {
    'syn_gwang_master': { AppLanguage.en: 'Bright Master', AppLanguage.ja: '光マスター', AppLanguage.zhCn: '光大师', AppLanguage.zhTw: '光大師', AppLanguage.es: 'Maestro Gwang', AppLanguage.fr: 'Maître Gwang', AppLanguage.de: 'Gwang-Meister', AppLanguage.pt: 'Mestre Gwang', AppLanguage.th: 'จ้าวกวัง' },
    'syn_animal_kingdom': { AppLanguage.en: 'Animal Kingdom', AppLanguage.ja: '動物王国', AppLanguage.zhCn: '动物王国', AppLanguage.zhTw: '動物王國', AppLanguage.es: 'Reino Animal', AppLanguage.fr: 'Royaume Animal', AppLanguage.de: 'Tierreich', AppLanguage.pt: 'Reino Animal', AppLanguage.th: 'อาณาจักรสัตว์' },
    'syn_ribbon_collector': { AppLanguage.en: 'Ribbon Collector', AppLanguage.ja: '短冊コレクター', AppLanguage.zhCn: '条收集者', AppLanguage.zhTw: '條收集者', AppLanguage.es: 'Coleccionista de Cintas', AppLanguage.fr: 'Collectionneur de Rubans', AppLanguage.de: 'Band-Sammler', AppLanguage.pt: 'Coletor de Fitas', AppLanguage.th: 'นักสะสมริบบิ้น' },
    'syn_junk_empire': { AppLanguage.en: 'Junk Empire', AppLanguage.ja: 'カス帝国', AppLanguage.zhCn: '皮帝国', AppLanguage.zhTw: '皮帝國', AppLanguage.es: 'Imperio Pi', AppLanguage.fr: 'Empire Pi', AppLanguage.de: 'Pi-Imperium', AppLanguage.pt: 'Império Pi', AppLanguage.th: 'จักรวรรดิพี' },
    'syn_gamblers_path': { AppLanguage.en: "Gambler's Path", AppLanguage.ja: '勝負師の道', AppLanguage.zhCn: '赌徒之路', AppLanguage.zhTw: '賭徒之路', AppLanguage.es: 'Camino del Jugador', AppLanguage.fr: 'Voie du Joueur', AppLanguage.de: 'Weg des Spielers', AppLanguage.pt: 'Caminho do Jogador', AppLanguage.th: 'เส้นทางนักพนัน' },
    'syn_demolition': { AppLanguage.en: 'Demolition Expert', AppLanguage.ja: '爆破の達人', AppLanguage.zhCn: '爆破专家', AppLanguage.zhTw: '爆破專家', AppLanguage.es: 'Experto en Demolición', AppLanguage.fr: 'Expert en Démolition', AppLanguage.de: 'Sprengmeister', AppLanguage.pt: 'Especialista em Demolição', AppLanguage.th: 'ผู้เชี่ยวชาญระเบิด' },
    'syn_tycoon': { AppLanguage.en: 'Tycoon', AppLanguage.ja: '大富豪', AppLanguage.zhCn: '大亨', AppLanguage.zhTw: '大亨', AppLanguage.es: 'Magnate', AppLanguage.fr: 'Magnat', AppLanguage.de: 'Tycoon', AppLanguage.pt: 'Magnata', AppLanguage.th: 'เศรษฐี' },
    'syn_fortress': { AppLanguage.en: 'Fortress', AppLanguage.ja: '要塞', AppLanguage.zhCn: '要塞', AppLanguage.zhTw: '要塞', AppLanguage.es: 'Fortaleza', AppLanguage.fr: 'Forteresse', AppLanguage.de: 'Festung', AppLanguage.pt: 'Fortaleza', AppLanguage.th: 'ป้อมปราการ' },
    'syn_tazza_school': { AppLanguage.en: 'Tazza School', AppLanguage.ja: 'タジャ流派', AppLanguage.zhCn: '老千学派', AppLanguage.zhTw: '老千學派', AppLanguage.es: 'Escuela Tazza', AppLanguage.fr: 'École Tazza', AppLanguage.de: 'Tazza-Schule', AppLanguage.pt: 'Escola Tazza', AppLanguage.th: 'สำนักตาซซา' },
  };

  static const Map<String, Map<AppLanguage, String>> _synergyDescs = {
    'syn_gwang_master': { AppLanguage.en: 'Gwang tag x3: +3 pts', AppLanguage.ja: '光タグ3個: +3点', AppLanguage.zhCn: '光标签x3: +3分', AppLanguage.zhTw: '光標籤x3: +3分', AppLanguage.es: 'Tag Gwang x3: +3 pts', AppLanguage.fr: 'Tag Gwang x3: +3 pts', AppLanguage.de: 'Gwang-Tag x3: +3 Pkt', AppLanguage.pt: 'Tag Gwang x3: +3 pts', AppLanguage.th: 'แท็กกวัง x3: +3 แต้ม' },
    'syn_animal_kingdom': { AppLanguage.en: 'Animal tag x3: +0.5 mult per capture', AppLanguage.ja: '動物タグ3個: 捕獲+0.5 mult', AppLanguage.zhCn: '动物标签x3: 捕获+0.5 mult', AppLanguage.zhTw: '動物標籤x3: 捕獲+0.5 mult', AppLanguage.es: 'Tag Animal x3: +0.5 mult', AppLanguage.fr: 'Tag Animal x3: +0.5 mult', AppLanguage.de: 'Tier-Tag x3: +0.5 Mult', AppLanguage.pt: 'Tag Animal x3: +0.5 mult', AppLanguage.th: 'แท็กสัตว์ x3: +0.5 mult' },
    'syn_ribbon_collector': { AppLanguage.en: 'Ribbon tag x3: 1 pt even under 5', AppLanguage.ja: '短冊タグ3個: 5枚未満でも1点', AppLanguage.zhCn: '条标签x3: 不足5张也得1分', AppLanguage.zhTw: '條標籤x3: 不足5張也得1分', AppLanguage.es: 'Tag Cinta x3: 1 pt con <5', AppLanguage.fr: 'Tag Ruban x3: 1 pt même <5', AppLanguage.de: 'Band-Tag x3: 1 Pkt auch <5', AppLanguage.pt: 'Tag Fita x3: 1 pt mesmo <5', AppLanguage.th: 'แท็กริบบิ้น x3: 1 แต้มแม้ <5' },
    'syn_junk_empire': { AppLanguage.en: 'Junk tag x3: threshold -1', AppLanguage.ja: 'カスタグ3個: 必要枚数-1', AppLanguage.zhCn: '皮标签x3: 所需张数-1', AppLanguage.zhTw: '皮標籤x3: 所需張數-1', AppLanguage.es: 'Tag Pi x3: umbral -1', AppLanguage.fr: 'Tag Pi x3: seuil -1', AppLanguage.de: 'Pi-Tag x3: Schwelle -1', AppLanguage.pt: 'Tag Pi x3: limiar -1', AppLanguage.th: 'แท็กพี x3: เกณฑ์ -1' },
    'syn_gamblers_path': { AppLanguage.en: 'Go tag x2: +0.3 mult from 1-Go', AppLanguage.ja: 'Goタグ2個: 1ゴーから+0.3 mult', AppLanguage.zhCn: 'Go标签x2: 1-Go起+0.3 mult', AppLanguage.zhTw: 'Go標籤x2: 1-Go起+0.3 mult', AppLanguage.es: 'Tag Go x2: +0.3 mult desde 1-Go', AppLanguage.fr: 'Tag Go x2: +0.3 mult dès 1-Go', AppLanguage.de: 'Go-Tag x2: +0.3 Mult ab 1-Go', AppLanguage.pt: 'Tag Go x2: +0.3 mult a partir de 1-Go', AppLanguage.th: 'แท็ก Go x2: +0.3 mult ตั้งแต่ 1-Go' },
    'syn_demolition': { AppLanguage.en: 'Bomb tag x2: +2 chips per sweep', AppLanguage.ja: '爆弾タグ2個: 掃除+2 chips', AppLanguage.zhCn: '炸弹标签x2: 扫荡+2 chips', AppLanguage.zhTw: '炸彈標籤x2: 掃蕩+2 chips', AppLanguage.es: 'Tag Bomba x2: +2 chips', AppLanguage.fr: 'Tag Bombe x2: +2 chips', AppLanguage.de: 'Bomben-Tag x2: +2 Chips', AppLanguage.pt: 'Tag Bomba x2: +2 chips', AppLanguage.th: 'แท็กระเบิด x2: +2 chips' },
    'syn_tycoon': { AppLanguage.en: 'Economy tag x3: extra 10% discount', AppLanguage.ja: '経済タグ3個: 追加10%割引', AppLanguage.zhCn: '经济标签x3: 额外9折', AppLanguage.zhTw: '經濟標籤x3: 額外9折', AppLanguage.es: 'Tag Economía x3: -10% extra', AppLanguage.fr: 'Tag Économie x3: -10% en plus', AppLanguage.de: 'Wirtschaft-Tag x3: +10% Rabatt', AppLanguage.pt: 'Tag Economia x3: -10% extra', AppLanguage.th: 'แท็กเศรษฐกิจ x3: ลดเพิ่ม 10%' },
    'syn_fortress': { AppLanguage.en: 'Defense tag x3: bak penalty -25%', AppLanguage.ja: '防御タグ3個: 罰-25%', AppLanguage.zhCn: '防御标签x3: 罚分-25%', AppLanguage.zhTw: '防禦標籤x3: 罰分-25%', AppLanguage.es: 'Tag Defensa x3: penalización -25%', AppLanguage.fr: 'Tag Défense x3: pénalité -25%', AppLanguage.de: 'Verteidigungs-Tag x3: Strafe -25%', AppLanguage.pt: 'Tag Defesa x3: penalidade -25%', AppLanguage.th: 'แท็กป้องกัน x3: โทษ -25%' },
    'syn_tazza_school': { AppLanguage.en: 'Tazza tag x3: +5 chips per manipulation', AppLanguage.ja: 'タジャタグ3個: 操作+5 chips', AppLanguage.zhCn: '老千标签x3: 操作+5 chips', AppLanguage.zhTw: '老千標籤x3: 操作+5 chips', AppLanguage.es: 'Tag Tazza x3: +5 chips', AppLanguage.fr: 'Tag Tazza x3: +5 chips', AppLanguage.de: 'Tazza-Tag x3: +5 Chips', AppLanguage.pt: 'Tag Tazza x3: +5 chips', AppLanguage.th: 'แท็กตาซซา x3: +5 chips' },
  };

  // ─── [상점 아이템 번역] ───
  String getItemName(String id, String defaultNameKo) {
    if (language == AppLanguage.ko) return defaultNameKo;
    final Map<AppLanguage, String> names = _itemNames[id] ?? {};
    return _t(names).isEmpty ? defaultNameKo : _t(names);
  }

  String getItemDesc(String id, String defaultDescKo) {
    if (language == AppLanguage.ko) return defaultDescKo;
    final Map<AppLanguage, String> descs = _itemDescs[id] ?? {};
    return _t(descs).isEmpty ? defaultDescKo : _t(descs);
  }

  static const Map<String, Map<AppLanguage, String>> _itemNames = {
    // Legacy
    'S-001': { AppLanguage.en: 'Exclusive Joker', AppLanguage.ja: '専用ジョーカー', AppLanguage.zhCn: '专属鬼牌', AppLanguage.zhTw: '專屬鬼牌', AppLanguage.es: 'Comodin exclusivo', AppLanguage.fr: 'Joker exclusif', AppLanguage.de: 'Exklusiver Joker', AppLanguage.pt: 'Coringa exclusivo', AppLanguage.th: 'โจ๊กเกอร์พิเศษ' },
    'S-002': { AppLanguage.en: 'Sniper', AppLanguage.ja: 'スナイパー', AppLanguage.zhCn: '狙击手', AppLanguage.zhTw: '狙擊手', AppLanguage.es: 'Francotirador', AppLanguage.fr: 'Sniper', AppLanguage.de: 'Scharfschutze', AppLanguage.pt: 'Atirador', AppLanguage.th: 'สไนเปอร์' },
    'S-003': { AppLanguage.en: 'Deck Shuffle', AppLanguage.ja: 'デッキシャッフル', AppLanguage.zhCn: '牌库洗牌', AppLanguage.zhTw: '牌庫洗牌', AppLanguage.es: 'Barajar mazo', AppLanguage.fr: 'Melange du paquet', AppLanguage.de: 'Deck mischen', AppLanguage.pt: 'Embaralhar', AppLanguage.th: 'สับกองไพ่' },
    'P-001': { AppLanguage.en: 'Gwang Scanner', AppLanguage.ja: '光スキャナー', AppLanguage.zhCn: '光牌扫描仪', AppLanguage.zhTw: '光牌掃描儀', AppLanguage.es: 'Escaner Gwang', AppLanguage.fr: 'Scanner Gwang', AppLanguage.de: 'Gwang-Scanner', AppLanguage.pt: 'Scanner Gwang', AppLanguage.th: 'สแกนเนอร์กวัง' },
    'P-002': { AppLanguage.en: 'Safety Helmet', AppLanguage.ja: '安全ヘルメット', AppLanguage.zhCn: '安全头盔', AppLanguage.zhTw: '安全頭盔', AppLanguage.es: 'Casco de seguridad', AppLanguage.fr: 'Casque de securite', AppLanguage.de: 'Schutzhelm', AppLanguage.pt: 'Capacete de seguranca', AppLanguage.th: 'หมวกนิรภัย' },
    'P-003': { AppLanguage.en: 'Jackpot Ticket', AppLanguage.ja: 'ジャックポットチケット', AppLanguage.zhCn: '头奖入场券', AppLanguage.zhTw: '頭獎入場券', AppLanguage.es: 'Boleto Jackpot', AppLanguage.fr: 'Ticket Jackpot', AppLanguage.de: 'Jackpot-Ticket', AppLanguage.pt: 'Bilhete Jackpot', AppLanguage.th: 'ตั๋วแจ็กพอต' },
    'T-001': { AppLanguage.en: 'Regular Customer', AppLanguage.ja: '常連客', AppLanguage.zhCn: '常客', AppLanguage.zhTw: '常客', AppLanguage.es: 'Cliente habitual', AppLanguage.fr: 'Client fidele', AppLanguage.de: 'Stammkunde', AppLanguage.pt: 'Cliente frequente', AppLanguage.th: 'ลูกค้าประจำ' },
    'T-002': { AppLanguage.en: 'Mental Guard', AppLanguage.ja: 'メンタルガード', AppLanguage.zhCn: '精神护盾', AppLanguage.zhTw: '精神護盾', AppLanguage.es: 'Guardia mental', AppLanguage.fr: 'Garde mentale', AppLanguage.de: 'Mentalschutz', AppLanguage.pt: 'Guarda mental', AppLanguage.th: 'การ์ดจิตใจ' },
    // Passive (29)
    'ps_spring_breeze': { AppLanguage.en: 'Spring Breeze', AppLanguage.ja: '春風', AppLanguage.zhCn: '春风', AppLanguage.zhTw: '春風', AppLanguage.es: 'Brisa primaveral', AppLanguage.fr: 'Brise printaniere', AppLanguage.de: 'Fruhlingsbrise', AppLanguage.pt: 'Brisa da primavera', AppLanguage.th: 'สายลมฤดูใบไม้ผลิ' },
    'ps_autumn_harvest': { AppLanguage.en: 'Autumn Harvest', AppLanguage.ja: '秋の収穫', AppLanguage.zhCn: '秋收', AppLanguage.zhTw: '秋收', AppLanguage.es: 'Cosecha de otono', AppLanguage.fr: 'Recolte d\'automne', AppLanguage.de: 'Herbsternte', AppLanguage.pt: 'Colheita de outono', AppLanguage.th: 'เก็บเกี่ยวฤดูใบไม้ร่วง' },
    'ps_summer_heat': { AppLanguage.en: 'Summer Heat', AppLanguage.ja: '夏の熱気', AppLanguage.zhCn: '夏日炎热', AppLanguage.zhTw: '夏日炎熱', AppLanguage.es: 'Calor veraniego', AppLanguage.fr: 'Chaleur estivale', AppLanguage.de: 'Sommerhitze', AppLanguage.pt: 'Calor de verao', AppLanguage.th: 'ความร้อนฤดูร้อน' },
    'ps_winter_chill': { AppLanguage.en: 'Winter Chill', AppLanguage.ja: '冬の寒波', AppLanguage.zhCn: '冬季寒流', AppLanguage.zhTw: '冬季寒流', AppLanguage.es: 'Frio invernal', AppLanguage.fr: 'Froid hivernal', AppLanguage.de: 'Winterkalte', AppLanguage.pt: 'Frio de inverno', AppLanguage.th: 'ลมหนาวฤดูหนาว' },
    'ps_junk_collector': { AppLanguage.en: 'Junk Collector', AppLanguage.ja: 'カス集め', AppLanguage.zhCn: '皮牌收集者', AppLanguage.zhTw: '皮牌收集者', AppLanguage.es: 'Coleccionista de basura', AppLanguage.fr: 'Collectionneur de rebuts', AppLanguage.de: 'Schrottsammler', AppLanguage.pt: 'Coletor de lixo', AppLanguage.th: 'นักสะสมพี' },
    'ps_coin_picker': { AppLanguage.en: 'Coin Picker', AppLanguage.ja: 'コイン拾い', AppLanguage.zhCn: '拾币者', AppLanguage.zhTw: '拾幣者', AppLanguage.es: 'Recoge monedas', AppLanguage.fr: 'Ramasse-pieces', AppLanguage.de: 'Munzsammler', AppLanguage.pt: 'Catador de moedas', AppLanguage.th: 'เก็บเหรียญ' },
    'ps_insurance': { AppLanguage.en: 'Insurance', AppLanguage.ja: '保険', AppLanguage.zhCn: '保险', AppLanguage.zhTw: '保險', AppLanguage.es: 'Seguro', AppLanguage.fr: 'Assurance', AppLanguage.de: 'Versicherung', AppLanguage.pt: 'Seguro', AppLanguage.th: 'ประกัน' },
    'ps_junk_luck': { AppLanguage.en: 'Junk Luck', AppLanguage.ja: '幸運のカス', AppLanguage.zhCn: '好运皮牌', AppLanguage.zhTw: '好運皮牌', AppLanguage.es: 'Suerte de basura', AppLanguage.fr: 'Chance de rebut', AppLanguage.de: 'Schrottgluck', AppLanguage.pt: 'Sorte de lixo', AppLanguage.th: 'โชคพี' },
    'ps_skilled_hand': { AppLanguage.en: 'Skilled Hand', AppLanguage.ja: '熟練の手', AppLanguage.zhCn: '老练之手', AppLanguage.zhTw: '老練之手', AppLanguage.es: 'Mano habil', AppLanguage.fr: 'Main habile', AppLanguage.de: 'Geschickte Hand', AppLanguage.pt: 'Mao habil', AppLanguage.th: 'มือชำนาญ' },
    'ps_bluff': { AppLanguage.en: 'Bluff', AppLanguage.ja: 'ハッタリ', AppLanguage.zhCn: '虚张声势', AppLanguage.zhTw: '虛張聲勢', AppLanguage.es: 'Farol', AppLanguage.fr: 'Bluff', AppLanguage.de: 'Bluff', AppLanguage.pt: 'Blefe', AppLanguage.th: 'บลัฟ' },
    'ps_full_moon': { AppLanguage.en: 'Full Moon', AppLanguage.ja: '満月', AppLanguage.zhCn: '满月', AppLanguage.zhTw: '滿月', AppLanguage.es: 'Luna llena', AppLanguage.fr: 'Pleine lune', AppLanguage.de: 'Vollmond', AppLanguage.pt: 'Lua cheia', AppLanguage.th: 'พระจันทร์เต็มดวง' },
    'ps_golden_eagle': { AppLanguage.en: 'Golden Eagle', AppLanguage.ja: '金鷲', AppLanguage.zhCn: '金鹰', AppLanguage.zhTw: '金鷹', AppLanguage.es: 'Aguila dorada', AppLanguage.fr: 'Aigle dore', AppLanguage.de: 'Goldadler', AppLanguage.pt: 'Aguia dourada', AppLanguage.th: 'นกอินทรีทอง' },
    'ps_gambler': { AppLanguage.en: 'Gambler', AppLanguage.ja: '勝負師', AppLanguage.zhCn: '赌徒', AppLanguage.zhTw: '賭徒', AppLanguage.es: 'Apostador', AppLanguage.fr: 'Joueur', AppLanguage.de: 'Spieler', AppLanguage.pt: 'Apostador', AppLanguage.th: 'นักพนัน' },
    'ps_nagari_memory': { AppLanguage.en: 'Nagari Memory', AppLanguage.ja: '流れの記憶', AppLanguage.zhCn: '流局记忆', AppLanguage.zhTw: '流局記憶', AppLanguage.es: 'Memoria Nagari', AppLanguage.fr: 'Memoire Nagari', AppLanguage.de: 'Nagari-Erinnerung', AppLanguage.pt: 'Memoria Nagari', AppLanguage.th: 'ความจำนาการิ' },
    'ps_dark_horse': { AppLanguage.en: 'Dark Horse', AppLanguage.ja: 'ダークホース', AppLanguage.zhCn: '黑马', AppLanguage.zhTw: '黑馬', AppLanguage.es: 'Caballo oscuro', AppLanguage.fr: 'Outsider', AppLanguage.de: 'Dunkles Pferd', AppLanguage.pt: 'Azarao', AppLanguage.th: 'ม้ามืด' },
    'ps_double_junk': { AppLanguage.en: 'Double Junk Master', AppLanguage.ja: 'ダブルカスの達人', AppLanguage.zhCn: '双皮大师', AppLanguage.zhTw: '雙皮大師', AppLanguage.es: 'Maestro doble basura', AppLanguage.fr: 'Maitre double rebut', AppLanguage.de: 'Doppelschrott-Meister', AppLanguage.pt: 'Mestre lixo duplo', AppLanguage.th: 'จ้าวพีคู่' },
    'ps_comeback_king': { AppLanguage.en: 'Comeback King', AppLanguage.ja: '逆転の名手', AppLanguage.zhCn: '逆转之王', AppLanguage.zhTw: '逆轉之王', AppLanguage.es: 'Rey del regreso', AppLanguage.fr: 'Roi du retour', AppLanguage.de: 'Comeback-Konig', AppLanguage.pt: 'Rei da virada', AppLanguage.th: 'ราชาพลิกกลับ' },
    'ps_flower_viewing': { AppLanguage.en: 'Flower Viewing', AppLanguage.ja: '花見', AppLanguage.zhCn: '赏花', AppLanguage.zhTw: '賞花', AppLanguage.es: 'Contemplacion de flores', AppLanguage.fr: 'Contemplation des fleurs', AppLanguage.de: 'Blumenschau', AppLanguage.pt: 'Contemplacao de flores', AppLanguage.th: 'ชมดอกไม้' },
    'ps_ribbon_weaver': { AppLanguage.en: 'Ribbon Weaver', AppLanguage.ja: '短冊の匠', AppLanguage.zhCn: '条匠', AppLanguage.zhTw: '條匠', AppLanguage.es: 'Tejedor de cintas', AppLanguage.fr: 'Tisseur de rubans', AppLanguage.de: 'Bandweber', AppLanguage.pt: 'Tecedor de fitas', AppLanguage.th: 'ช่างสานริบบิ้น' },
    'ps_sweep_master': { AppLanguage.en: 'Sweep Master', AppLanguage.ja: '一掃の達人', AppLanguage.zhCn: '扫荡大师', AppLanguage.zhTw: '掃蕩大師', AppLanguage.es: 'Maestro del barrido', AppLanguage.fr: 'Maitre du balayage', AppLanguage.de: 'Fegemeister', AppLanguage.pt: 'Mestre da varredura', AppLanguage.th: 'จ้าวกวาด' },
    'ps_rainy_season': { AppLanguage.en: 'Rainy Season', AppLanguage.ja: '梅雨', AppLanguage.zhCn: '梅雨季', AppLanguage.zhTw: '梅雨季', AppLanguage.es: 'Temporada de lluvias', AppLanguage.fr: 'Saison des pluies', AppLanguage.de: 'Regenzeit', AppLanguage.pt: 'Estacao chuvosa', AppLanguage.th: 'ฤดูฝน' },
    'ps_flower_rain': { AppLanguage.en: 'Flower Rain', AppLanguage.ja: '花吹雪', AppLanguage.zhCn: '花雨', AppLanguage.zhTw: '花雨', AppLanguage.es: 'Lluvia de flores', AppLanguage.fr: 'Pluie de fleurs', AppLanguage.de: 'Blutenregen', AppLanguage.pt: 'Chuva de flores', AppLanguage.th: 'ฝนดอกไม้' },
    'ps_flower_bomb': { AppLanguage.en: 'Flower Bomb', AppLanguage.ja: '花爆弾', AppLanguage.zhCn: '花炸弹', AppLanguage.zhTw: '花炸彈', AppLanguage.es: 'Bomba floral', AppLanguage.fr: 'Bombe florale', AppLanguage.de: 'Blutenbombe', AppLanguage.pt: 'Bomba floral', AppLanguage.th: 'ระเบิดดอกไม้' },
    'ps_provoke': { AppLanguage.en: 'Provoke', AppLanguage.ja: '挑発', AppLanguage.zhCn: '挑衅', AppLanguage.zhTw: '挑釁', AppLanguage.es: 'Provocar', AppLanguage.fr: 'Provocation', AppLanguage.de: 'Provokation', AppLanguage.pt: 'Provocar', AppLanguage.th: 'ยั่วยุ' },
    'ps_ppuk_inducer': { AppLanguage.en: 'Ppuk Inducer', AppLanguage.ja: 'ション誘導', AppLanguage.zhCn: '逼爆引导', AppLanguage.zhTw: '逼爆引導', AppLanguage.es: 'Inductor Ppuk', AppLanguage.fr: 'Inducteur Ppuk', AppLanguage.de: 'Ppuk-Ausloser', AppLanguage.pt: 'Indutor Ppuk', AppLanguage.th: 'เครื่องชักจูงปุก' },
    'ps_legendary_tazza': { AppLanguage.en: 'Legendary Tazza', AppLanguage.ja: '伝説のタジャ', AppLanguage.zhCn: '传奇老千', AppLanguage.zhTw: '傳奇老千', AppLanguage.es: 'Tazza legendario', AppLanguage.fr: 'Tazza legendaire', AppLanguage.de: 'Legendarer Tazza', AppLanguage.pt: 'Tazza lendario', AppLanguage.th: 'ตาซซาในตำนาน' },
    'ps_gamblers_instinct': { AppLanguage.en: "Gambler's Instinct", AppLanguage.ja: '博打の直感', AppLanguage.zhCn: '赌徒直觉', AppLanguage.zhTw: '賭徒直覺', AppLanguage.es: 'Instinto de jugador', AppLanguage.fr: 'Instinct du joueur', AppLanguage.de: 'Spielerinstinkt', AppLanguage.pt: 'Instinto de jogador', AppLanguage.th: 'สัญชาตญาณนักพนัน' },
    'ps_time_rewind': { AppLanguage.en: 'Time Rewind', AppLanguage.ja: '時間の巻き戻し', AppLanguage.zhCn: '时光倒流', AppLanguage.zhTw: '時光倒流', AppLanguage.es: 'Rebobinar tiempo', AppLanguage.fr: 'Retour dans le temps', AppLanguage.de: 'Zeitruckspul', AppLanguage.pt: 'Rebobinar tempo', AppLanguage.th: 'ย้อนเวลา' },
    'ps_flower_lord': { AppLanguage.en: 'Flower Lord', AppLanguage.ja: '花の主', AppLanguage.zhCn: '花主', AppLanguage.zhTw: '花主', AppLanguage.es: 'Senor de las flores', AppLanguage.fr: 'Seigneur des fleurs', AppLanguage.de: 'Blutenherr', AppLanguage.pt: 'Senhor das flores', AppLanguage.th: 'เจ้าแห่งดอกไม้' },
    // Talisman (9)
    't_lucky_coin': { AppLanguage.en: 'Lucky Coin', AppLanguage.ja: '幸運のコイン', AppLanguage.zhCn: '幸运硬币', AppLanguage.zhTw: '幸運硬幣', AppLanguage.es: 'Moneda de la suerte', AppLanguage.fr: 'Piece porte-bonheur', AppLanguage.de: 'Glucksmunze', AppLanguage.pt: 'Moeda da sorte', AppLanguage.th: 'เหรียญนำโชค' },
    't_gambler_soul': { AppLanguage.en: "Gambler's Soul", AppLanguage.ja: '勝負師の魂', AppLanguage.zhCn: '赌徒之魂', AppLanguage.zhTw: '賭徒之魂', AppLanguage.es: 'Alma de apostador', AppLanguage.fr: 'Ame du joueur', AppLanguage.de: 'Spielerseele', AppLanguage.pt: 'Alma de apostador', AppLanguage.th: 'วิญญาณนักพนัน' },
    't_mountain_charm': { AppLanguage.en: 'Mountain Charm', AppLanguage.ja: '高嶺山のお守り', AppLanguage.zhCn: '高岭山护符', AppLanguage.zhTw: '高嶺山護符', AppLanguage.es: 'Amuleto de montana', AppLanguage.fr: 'Charme de montagne', AppLanguage.de: 'Bergamulett', AppLanguage.pt: 'Amuleto da montanha', AppLanguage.th: 'เครื่องรางภูเขา' },
    't_moonlight_pouch': { AppLanguage.en: 'Moonlight Pouch', AppLanguage.ja: '月光の袋', AppLanguage.zhCn: '月光袋', AppLanguage.zhTw: '月光袋', AppLanguage.es: 'Bolsa de luz lunar', AppLanguage.fr: 'Pochette au clair de lune', AppLanguage.de: 'Mondlichtbeutel', AppLanguage.pt: 'Bolsa de luar', AppLanguage.th: 'ถุงแสงจันทร์' },
    't_dokkaebi_mallet': { AppLanguage.en: 'Dokkaebi Mallet', AppLanguage.ja: '鬼の金棒', AppLanguage.zhCn: '鬼怪棒槌', AppLanguage.zhTw: '鬼怪棒槌', AppLanguage.es: 'Mazo Dokkaebi', AppLanguage.fr: 'Maillet Dokkaebi', AppLanguage.de: 'Dokkaebi-Hammer', AppLanguage.pt: 'Malho Dokkaebi', AppLanguage.th: 'ค้อนด็อกแกบี' },
    't_samshin_granny': { AppLanguage.en: 'Samshin Granny', AppLanguage.ja: '三神ばあさん', AppLanguage.zhCn: '三神老奶奶', AppLanguage.zhTw: '三神老奶奶', AppLanguage.es: 'Abuela Samshin', AppLanguage.fr: 'Grand-mere Samshin', AppLanguage.de: 'Samshin-Oma', AppLanguage.pt: 'Vovo Samshin', AppLanguage.th: 'ย่าซัมชิน' },
    't_cheaters_glove': { AppLanguage.en: "Cheater's Glove", AppLanguage.ja: 'イカサマの手袋', AppLanguage.zhCn: '骗子手套', AppLanguage.zhTw: '騙子手套', AppLanguage.es: 'Guante de tramposo', AppLanguage.fr: 'Gant du tricheur', AppLanguage.de: 'Betrugerhandschuh', AppLanguage.pt: 'Luva de trapaceiro', AppLanguage.th: 'ถุงมือขี้โกง' },
    't_golden_mat': { AppLanguage.en: 'Golden Mat', AppLanguage.ja: '黄金の花札盤', AppLanguage.zhCn: '黄金花牌台', AppLanguage.zhTw: '黃金花牌檯', AppLanguage.es: 'Tapete dorado', AppLanguage.fr: 'Tapis dore', AppLanguage.de: 'Goldene Matte', AppLanguage.pt: 'Tapete dourado', AppLanguage.th: 'เสื่อทอง' },
    't_gwangbak_shield': { AppLanguage.en: 'Gwangbak Shield', AppLanguage.ja: '光罰シールド', AppLanguage.zhCn: '光罚护盾', AppLanguage.zhTw: '光罰護盾', AppLanguage.es: 'Escudo Gwangbak', AppLanguage.fr: 'Bouclier Gwangbak', AppLanguage.de: 'Gwangbak-Schild', AppLanguage.pt: 'Escudo Gwangbak', AppLanguage.th: 'โล่กวังบัก' },
    // Active (6)
    'a_joker': { AppLanguage.en: 'Exclusive Joker', AppLanguage.ja: '専用ジョーカー', AppLanguage.zhCn: '专属鬼牌', AppLanguage.zhTw: '專屬鬼牌', AppLanguage.es: 'Comodin exclusivo', AppLanguage.fr: 'Joker exclusif', AppLanguage.de: 'Exklusiver Joker', AppLanguage.pt: 'Coringa exclusivo', AppLanguage.th: 'โจ๊กเกอร์พิเศษ' },
    'a_sniper': { AppLanguage.en: 'Sniper', AppLanguage.ja: 'スナイパー', AppLanguage.zhCn: '狙击手', AppLanguage.zhTw: '狙擊手', AppLanguage.es: 'Francotirador', AppLanguage.fr: 'Sniper', AppLanguage.de: 'Scharfschutze', AppLanguage.pt: 'Atirador', AppLanguage.th: 'สไนเปอร์' },
    'a_shuffle': { AppLanguage.en: 'Deck Shuffle', AppLanguage.ja: 'デッキシャッフル', AppLanguage.zhCn: '牌库洗牌', AppLanguage.zhTw: '牌庫洗牌', AppLanguage.es: 'Barajar mazo', AppLanguage.fr: 'Melange du paquet', AppLanguage.de: 'Deck mischen', AppLanguage.pt: 'Embaralhar', AppLanguage.th: 'สับกองไพ่' },
    'a_trick': { AppLanguage.en: 'Trick', AppLanguage.ja: 'トリック', AppLanguage.zhCn: '欺诈', AppLanguage.zhTw: '欺詐', AppLanguage.es: 'Truco', AppLanguage.fr: 'Tour', AppLanguage.de: 'Trick', AppLanguage.pt: 'Truque', AppLanguage.th: 'กลโกง' },
    'a_keen_eye': { AppLanguage.en: 'Keen Eye', AppLanguage.ja: '鋭い目', AppLanguage.zhCn: '锐眼', AppLanguage.zhTw: '銳眼', AppLanguage.es: 'Ojo agudo', AppLanguage.fr: 'Oeil vif', AppLanguage.de: 'Scharfes Auge', AppLanguage.pt: 'Olho aguado', AppLanguage.th: 'ตาคม' },
    'a_card_laundry': { AppLanguage.en: 'Card Laundry', AppLanguage.ja: 'カードロンダリング', AppLanguage.zhCn: '洗牌', AppLanguage.zhTw: '洗牌', AppLanguage.es: 'Lavado de cartas', AppLanguage.fr: 'Blanchiment de cartes', AppLanguage.de: 'Kartenwasche', AppLanguage.pt: 'Lavagem de cartas', AppLanguage.th: 'ซักไพ่' },
    // Consumable (6)
    'c_gwang_scanner': { AppLanguage.en: 'Gwang Scanner', AppLanguage.ja: '光スキャナー', AppLanguage.zhCn: '光牌扫描仪', AppLanguage.zhTw: '光牌掃描儀', AppLanguage.es: 'Escaner Gwang', AppLanguage.fr: 'Scanner Gwang', AppLanguage.de: 'Gwang-Scanner', AppLanguage.pt: 'Scanner Gwang', AppLanguage.th: 'สแกนเนอร์กวัง' },
    'c_safety_helmet': { AppLanguage.en: 'Safety Helmet', AppLanguage.ja: '安全ヘルメット', AppLanguage.zhCn: '安全头盔', AppLanguage.zhTw: '安全頭盔', AppLanguage.es: 'Casco de seguridad', AppLanguage.fr: 'Casque de securite', AppLanguage.de: 'Schutzhelm', AppLanguage.pt: 'Capacete de seguranca', AppLanguage.th: 'หมวกนิรภัย' },
    'c_jackpot_ticket': { AppLanguage.en: 'Jackpot Ticket', AppLanguage.ja: 'ジャックポットチケット', AppLanguage.zhCn: '头奖入场券', AppLanguage.zhTw: '頭獎入場券', AppLanguage.es: 'Boleto Jackpot', AppLanguage.fr: 'Ticket Jackpot', AppLanguage.de: 'Jackpot-Ticket', AppLanguage.pt: 'Bilhete Jackpot', AppLanguage.th: 'ตั๋วแจ็กพอต' },
    'c_pi_magnet': { AppLanguage.en: 'Pi Magnet', AppLanguage.ja: 'カス磁石', AppLanguage.zhCn: '皮牌磁铁', AppLanguage.zhTw: '皮牌磁鐵', AppLanguage.es: 'Iman Pi', AppLanguage.fr: 'Aimant Pi', AppLanguage.de: 'Pi-Magnet', AppLanguage.pt: 'Ima Pi', AppLanguage.th: 'แม่เหล็กพี' },
    'c_ribbon_polish': { AppLanguage.en: 'Ribbon Polish', AppLanguage.ja: '短冊磨き', AppLanguage.zhCn: '条带抛光', AppLanguage.zhTw: '條帶拋光', AppLanguage.es: 'Pulidor de cintas', AppLanguage.fr: 'Polish de rubans', AppLanguage.de: 'Bandpolitur', AppLanguage.pt: 'Polimento de fitas', AppLanguage.th: 'ขัดริบบิ้น' },
    'c_bomb_fuse': { AppLanguage.en: 'Bomb Fuse', AppLanguage.ja: '爆弾導火線', AppLanguage.zhCn: '炸弹引线', AppLanguage.zhTw: '炸彈引線', AppLanguage.es: 'Mecha de bomba', AppLanguage.fr: 'Meche de bombe', AppLanguage.de: 'Bombenzunder', AppLanguage.pt: 'Pavio de bomba', AppLanguage.th: 'ชนวนระเบิด' },
    // Secret (1)
    'x_ogwang_crown': { AppLanguage.en: "Five Brights Crown", AppLanguage.ja: '五光の王冠', AppLanguage.zhCn: '五光王冠', AppLanguage.zhTw: '五光王冠', AppLanguage.es: 'Corona de Cinco Brillantes', AppLanguage.fr: 'Couronne des Cinq Lumieres', AppLanguage.de: 'Krone der Funf Lichter', AppLanguage.pt: 'Coroa dos Cinco Brilhantes', AppLanguage.th: 'มงกุฎห้ากวัง' },
  };

  static const Map<String, Map<AppLanguage, String>> _itemDescs = {
    'S-001': {
      AppLanguage.en: 'Treats the next played deck card as a Joker, allowing you to capture any unmatched card from the field.',
      AppLanguage.ja: '次に出す山札のカードをジョーカーとして扱い、場の好きなカードを1枚確実に獲得します。',
      AppLanguage.zhCn: '将下一张打出的牌库牌视为鬼牌，让你能夺取场上一张任意卡牌。',
      AppLanguage.zhTw: '將下一張打出的牌庫牌視為鬼牌，讓你能奪取場上一張任意卡牌。',
      AppLanguage.es: 'Trata la siguiente carta del mazo como un Comodín, permitiendo capturar cualquier carta sin pareja del campo.',
      AppLanguage.fr: 'Traite la prochaine carte du paquet comme un Joker, permettant de capturer n\'importe quelle carte non associée du terrain.',
      AppLanguage.de: 'Behandelt die nächste Stapelkarte als Joker und ermöglicht es, jede ungepaarte Karte vom Feld zu erbeuten.',
      AppLanguage.pt: 'Trata a próxima carta do baralho como Coringa, permitindo capturar qualquer carta sem par do campo.',
      AppLanguage.th: 'ทำให้ไพ่ใบถัดไปจากกองเป็นโจ๊กเกอร์ ยึดไพ่ใดก็ได้ที่ไม่มีคู่จากสนาม',
    },
    'S-002': {
      AppLanguage.en: 'Forcefully steal one specific card from the opponent\'s captured area. (Once per game)',
      AppLanguage.ja: '相手が獲得したカードの中から、好きなカードを1枚強制的に奪い取ります。(1ゲーム1回)',
      AppLanguage.zhCn: '强制从对手得分区夺取特定的一张牌。（每局限一次）',
      AppLanguage.zhTw: '強制從對手得分區奪取特定的一張牌。（每局限一次）',
      AppLanguage.es: 'Roba una carta específica del área de captura del oponente. (Una vez por juego)',
      AppLanguage.fr: 'Vole de force une carte spécifique de la zone de capture de l\'adversaire. (Une fois par partie)',
      AppLanguage.de: 'Stiehlt eine bestimmte Karte aus dem Gewinnbereich des Gegners. (Einmal pro Spiel)',
      AppLanguage.pt: 'Rouba uma carta específica da área de captura do oponente. (Uma vez por jogo)',
      AppLanguage.th: 'ขโมยไพ่ใบเฉพาะจากพื้นที่ยึดของคู่ต่อสู้ (ครั้งเดียวต่อเกม)',
    },
    'S-003': {
      AppLanguage.en: 'Collect all cards on the field, shuffle them back into the deck, and redeploy them.',
      AppLanguage.ja: '場に出ているカードをすべて回収し、山札と混ぜて再配置します。',
      AppLanguage.zhCn: '将场上所有卡牌收回，与牌库重新洗牌并再次布阵。',
      AppLanguage.zhTw: '將場上所有卡牌收回，與牌庫重新洗牌並再次布陣。',
      AppLanguage.es: 'Recoge todas las cartas del campo, las mezcla en el mazo y las redistribuye.',
      AppLanguage.fr: 'Collecte toutes les cartes du terrain, les mélange dans le paquet et les redéploie.',
      AppLanguage.de: 'Sammelt alle Karten vom Feld ein, mischt sie zurück in den Stapel und verteilt sie neu.',
      AppLanguage.pt: 'Recolhe todas as cartas do campo, embaralha de volta no baralho e redistribui.',
      AppLanguage.th: 'เก็บไพ่ทั้งหมดบนสนาม สับรวมกับกองไพ่แล้ววางใหม่',
    },
    'P-001': {
      AppLanguage.en: 'Significantly increases the chance of Gwang (Bright) cards appearing in the initial deal.',
      AppLanguage.ja: '最初のカード配布時、手札や場に光(光札)が配置される確率が大幅に増加します。',
      AppLanguage.zhCn: '开局发牌时，大幅增加光牌出现在手牌或场上的几率。',
      AppLanguage.zhTw: '開局發牌時，大幅增加光牌出現在手牌或場上的機率。',
      AppLanguage.es: 'Aumenta significativamente la probabilidad de que aparezcan cartas Gwang (Brillantes) en el reparto inicial.',
      AppLanguage.fr: 'Augmente considérablement la chance d\'apparition des cartes Gwang (Lumière) lors de la distribution initiale.',
      AppLanguage.de: 'Erhöht deutlich die Chance, dass Gwang (Licht)-Karten beim ersten Austeilen erscheinen.',
      AppLanguage.pt: 'Aumenta significativamente a chance de cartas Gwang (Brilhantes) aparecerem na distribuição inicial.',
      AppLanguage.th: 'เพิ่มโอกาสอย่างมากที่ไพ่กวัง (สว่าง) จะปรากฏในการแจกไพ่เริ่มต้น',
    },
    'P-002': {
      AppLanguage.en: 'Prevents Game Over once per round by covering the basic bet amount if you go bankrupt.',
      AppLanguage.ja: '該当ラウンドで破産(資金不足)した際、1回だけ基本賭け金をカバーし、ゲームオーバーを防ぎします。',
      AppLanguage.zhCn: '在该回合破产时，仅限一次为你垫付基础赌注，防止游戏结束。',
      AppLanguage.zhTw: '在該回合破破時，僅限一次為你墊付基礎賭注，防止遊戲結束。',
      AppLanguage.es: 'Previene el Game Over una vez por ronda cubriendo la apuesta básica si te arruinas.',
      AppLanguage.fr: 'Empêche le Game Over une fois par manche en couvrant la mise de base en cas de faillite.',
      AppLanguage.de: 'Verhindert einmal pro Runde das Game Over, indem der Grundeinsatz abgedeckt wird, wenn du bankrott gehst.',
      AppLanguage.pt: 'Previne Game Over uma vez por rodada cobrindo a aposta básica se você falir.',
      AppLanguage.th: 'ป้องกัน Game Over หนึ่งครั้งต่อรอบโดยจ่ายเงินเดิมพันพื้นฐานหากคุณล้มละลาย',
    },
    'P-003': {
      AppLanguage.en: 'A high-risk, high-return item that multiplies your final score by 5 times if you win the round.',
      AppLanguage.ja: 'ラウンド勝利時に、最終スコアを無条件に5倍にするハイリスクハイリターンアイテム。',
      AppLanguage.zhCn: '高风险高回报的消耗品，获胜时直接将最终得分乘以5倍。',
      AppLanguage.zhTw: '高風險高回報的消耗品，獲勝時直接將最終得分乘以5倍。',
      AppLanguage.es: 'Un objeto de alto riesgo y alta recompensa que multiplica tu puntuación final por 5 si ganas la ronda.',
      AppLanguage.fr: 'Un objet à haut risque et haute récompense qui multiplie votre score final par 5 si vous gagnez la manche.',
      AppLanguage.de: 'Ein Hochrisiko-Gegenstand, der deine Endpunktzahl bei Rundengewinn mit 5 multipliziert.',
      AppLanguage.pt: 'Um item de alto risco e alta recompensa que multiplica sua pontuação final por 5 se vencer a rodada.',
      AppLanguage.th: 'ไอเทมเสี่ยงสูงผลตอบแทนสูง คูณคะแนนสุดท้าย 5 เท่าหากชนะรอบ',
    },
    'T-001': {
      AppLanguage.en: 'Adds an extra 0.5x to 2x multiplier when you declare 3 Go or more.',
      AppLanguage.ja: 'ゲーム中、3Go以上を宣言した場合、最終倍率に0.5倍〜2倍を追加します。',
      AppLanguage.zhCn: '宣告 3 Go 以上时，最终倍率会随机额外增加 0.5 到 2 倍。',
      AppLanguage.zhTw: '宣告 3 Go 以上時，最終倍率會隨機額外增加 0.5 到 2 倍。',
      AppLanguage.es: 'Agrega un multiplicador extra de 0.5x a 2x al declarar 3 Go o más.',
      AppLanguage.fr: 'Ajoute un multiplicateur supplémentaire de 0,5x à 2x lorsque vous déclarez 3 Go ou plus.',
      AppLanguage.de: 'Fügt einen zusätzlichen 0,5x bis 2x Multiplikator hinzu, wenn du 3 Go oder mehr erklärst.',
      AppLanguage.pt: 'Adiciona um multiplicador extra de 0,5x a 2x ao declarar 3 Go ou mais.',
      AppLanguage.th: 'เพิ่มตัวคูณพิเศษ 0.5x ถึง 2x เมื่อประกาศ 3 Go ขึ้นไป',
    },
    'T-002': {
      AppLanguage.en: 'Defends once against the opponent capturing your cards when you make a Ppeok (Bomb-fail).',
      AppLanguage.ja: 'プレイヤーがションを出した時、相手がそのカードを食べるのを最初の1回だけ防ぎます。',
      AppLanguage.zhCn: '当你打出爆（Ppeok）时，首次防御对手将其吃掉。',
      AppLanguage.zhTw: '當你打出爆（Ppeok）時，首次防禦對手將其吃掉。',
      AppLanguage.es: 'Defiende una vez cuando el oponente intenta capturar tus cartas al hacer Ppeok (fallo de bomba).',
      AppLanguage.fr: 'Defend une fois contre la capture de vos cartes par l\'adversaire lors d\'un Ppeok (echec de bombe).',
      AppLanguage.de: 'Verteidigt einmal dagegen, dass der Gegner deine Karten bei einem Ppeok (Bombenfehler) einfangt.',
      AppLanguage.pt: 'Defende uma vez contra o oponente capturar suas cartas quando voce faz um Ppeok (falha de bomba).',
      AppLanguage.th: 'ป้องกันหนึ่งครั้งเมื่อคู่ต่อสู้พยายามยึดไพ่ของคุณตอนทำปอก (ระเบิดพลาด)',
    },
    // New item descriptions (using ItemDef.description as English, short form for other langs)
    'ps_spring_breeze': { AppLanguage.en: '+3 chips per card captured in months 1-3', AppLanguage.ja: '1~3月カード1枚毎に+3 chips', AppLanguage.zhCn: '1~3月每张+3 chips', AppLanguage.zhTw: '1~3月每張+3 chips', AppLanguage.es: '+3 chips por carta de meses 1-3', AppLanguage.fr: '+3 chips par carte des mois 1-3', AppLanguage.de: '+3 Chips pro Karte der Monate 1-3', AppLanguage.pt: '+3 chips por carta dos meses 1-3', AppLanguage.th: '+3 ชิปต่อไพ่เดือน 1-3' },
    'ps_autumn_harvest': { AppLanguage.en: '+3 chips per card captured in months 9-11', AppLanguage.ja: '9~11月カード1枚毎に+3 chips', AppLanguage.zhCn: '9~11月每张+3 chips', AppLanguage.zhTw: '9~11月每張+3 chips', AppLanguage.es: '+3 chips por carta de meses 9-11', AppLanguage.fr: '+3 chips par carte des mois 9-11', AppLanguage.de: '+3 Chips pro Karte der Monate 9-11', AppLanguage.pt: '+3 chips por carta dos meses 9-11', AppLanguage.th: '+3 ชิปต่อไพ่เดือน 9-11' },
    'ps_summer_heat': { AppLanguage.en: '+3 chips per card captured in months 6-8', AppLanguage.ja: '6~8月カード1枚毎に+3 chips', AppLanguage.zhCn: '6~8月每张+3 chips', AppLanguage.zhTw: '6~8月每張+3 chips', AppLanguage.es: '+3 chips por carta de meses 6-8', AppLanguage.fr: '+3 chips par carte des mois 6-8', AppLanguage.de: '+3 Chips pro Karte der Monate 6-8', AppLanguage.pt: '+3 chips por carta dos meses 6-8', AppLanguage.th: '+3 ชิปต่อไพ่เดือน 6-8' },
    'ps_winter_chill': { AppLanguage.en: 'December cards +8 chips', AppLanguage.ja: '12月カード+8 chips', AppLanguage.zhCn: '12月卡+8 chips', AppLanguage.zhTw: '12月卡+8 chips', AppLanguage.es: 'Cartas de diciembre +8 chips', AppLanguage.fr: 'Cartes de decembre +8 chips', AppLanguage.de: 'Dezember-Karten +8 Chips', AppLanguage.pt: 'Cartas de dezembro +8 chips', AppLanguage.th: 'ไพ่เดือน 12 +8 ชิป' },
    'ps_junk_collector': { AppLanguage.en: 'Junk threshold reduced from 10 to 8', AppLanguage.ja: 'カス必要枚数10→8', AppLanguage.zhCn: '皮牌所需张数10→8', AppLanguage.zhTw: '皮牌所需張數10→8', AppLanguage.es: 'Umbral de basura 10→8', AppLanguage.fr: 'Seuil de rebuts 10→8', AppLanguage.de: 'Schrottschwelle 10→8', AppLanguage.pt: 'Limite de lixo 10→8', AppLanguage.th: 'ขั้นต่ำพี 10→8' },
    'ps_coin_picker': { AppLanguage.en: '+5G per remaining score point on victory', AppLanguage.ja: '勝利時残りスコア1点あたり+5G', AppLanguage.zhCn: '胜利时每剩余分+5G', AppLanguage.zhTw: '勝利時每剩餘分+5G', AppLanguage.es: '+5G por punto restante al ganar', AppLanguage.fr: '+5G par point restant en cas de victoire', AppLanguage.de: '+5G pro verbleibendem Punkt bei Sieg', AppLanguage.pt: '+5G por ponto restante na vitoria', AppLanguage.th: '+5G ต่อคะแนนที่เหลือเมื่อชนะ' },
    'ps_insurance': { AppLanguage.en: 'Nagari loss reduced by 50%', AppLanguage.ja: '流れ損失50%減少', AppLanguage.zhCn: '流局损失减少50%', AppLanguage.zhTw: '流局損失減少50%', AppLanguage.es: 'Perdida por Nagari -50%', AppLanguage.fr: 'Perte Nagari -50%', AppLanguage.de: 'Nagari-Verlust -50%', AppLanguage.pt: 'Perda por Nagari -50%', AppLanguage.th: 'ขาดทุนนาการิ -50%' },
    'ps_junk_luck': { AppLanguage.en: '25% chance +1 junk on capture', AppLanguage.ja: 'カス獲得時25%で+1枚', AppLanguage.zhCn: '吃皮时25%概率+1张', AppLanguage.zhTw: '吃皮時25%機率+1張', AppLanguage.es: '25% prob. +1 basura al capturar', AppLanguage.fr: '25% chance +1 rebut a la capture', AppLanguage.de: '25% Chance +1 Schrott beim Fangen', AppLanguage.pt: '25% chance +1 lixo ao capturar', AppLanguage.th: '25% ได้+1 พี' },
    'ps_skilled_hand': { AppLanguage.en: '15% chance for an extra flip', AppLanguage.ja: '15%で追加めくり', AppLanguage.zhCn: '15%概率额外翻牌', AppLanguage.zhTw: '15%機率額外翻牌', AppLanguage.es: '15% prob. de volteo extra', AppLanguage.fr: '15% chance de retournement extra', AppLanguage.de: '15% Chance auf extra Aufdecken', AppLanguage.pt: '15% chance de virada extra', AppLanguage.th: '15% โอกาสพลิกเพิ่ม' },
    'ps_bluff': { AppLanguage.en: 'Reveal 2 opponent cards at round start', AppLanguage.ja: 'ラウンド開始時相手の手札2枚公開', AppLanguage.zhCn: '回合开始时揭露对手2张牌', AppLanguage.zhTw: '回合開始時揭露對手2張牌', AppLanguage.es: 'Revelar 2 cartas del oponente al inicio', AppLanguage.fr: 'Reveler 2 cartes adverses au debut', AppLanguage.de: '2 Gegnerkarten zu Rundenbeginn aufdecken', AppLanguage.pt: 'Revelar 2 cartas do oponente no inicio', AppLanguage.th: 'เปิดไพ่คู่ต่อสู้ 2 ใบตอนเริ่ม' },
    'ps_full_moon': { AppLanguage.en: '+0.5 mult per bright card captured', AppLanguage.ja: '光獲得毎に+0.5 mult', AppLanguage.zhCn: '每获光牌+0.5 mult', AppLanguage.zhTw: '每獲光牌+0.5 mult', AppLanguage.es: '+0.5 mult por carta brillante', AppLanguage.fr: '+0.5 mult par carte lumiere', AppLanguage.de: '+0.5 Mult pro Lichtkarte', AppLanguage.pt: '+0.5 mult por carta brilhante', AppLanguage.th: '+0.5 ตัวคูณต่อไพ่กวัง' },
    'ps_golden_eagle': { AppLanguage.en: 'x1.5 if you have 5+ animal cards', AppLanguage.ja: '動物5枚以上でx1.5', AppLanguage.zhCn: '5+动物牌x1.5', AppLanguage.zhTw: '5+動物牌x1.5', AppLanguage.es: 'x1.5 con 5+ animales', AppLanguage.fr: 'x1.5 avec 5+ animaux', AppLanguage.de: 'x1.5 bei 5+ Tierkarten', AppLanguage.pt: 'x1.5 com 5+ animais', AppLanguage.th: 'x1.5 เมื่อมี 5+ สัตว์' },
    'ps_gambler': { AppLanguage.en: '+1 mult per Go declaration', AppLanguage.ja: 'Go宣言毎に+1 mult', AppLanguage.zhCn: '每次Go宣言+1 mult', AppLanguage.zhTw: '每次Go宣言+1 mult', AppLanguage.es: '+1 mult por Go', AppLanguage.fr: '+1 mult par Go', AppLanguage.de: '+1 Mult pro Go', AppLanguage.pt: '+1 mult por Go', AppLanguage.th: '+1 ตัวคูณต่อ Go' },
    'ps_nagari_memory': { AppLanguage.en: 'x2.0 if you lost the previous round', AppLanguage.ja: '前ラウンド敗北時x2.0', AppLanguage.zhCn: '上局败北时x2.0', AppLanguage.zhTw: '上局敗北時x2.0', AppLanguage.es: 'x2.0 si perdiste la ronda anterior', AppLanguage.fr: 'x2.0 si vous avez perdu le round precedent', AppLanguage.de: 'x2.0 bei Niederlage in der Vorrunde', AppLanguage.pt: 'x2.0 se perdeu a rodada anterior', AppLanguage.th: 'x2.0 ถ้าแพ้รอบก่อน' },
    'ps_dark_horse': { AppLanguage.en: 'x1.5 to the category with fewest captured', AppLanguage.ja: '最少獲得カテゴリx1.5', AppLanguage.zhCn: '最少分类x1.5', AppLanguage.zhTw: '最少分類x1.5', AppLanguage.es: 'x1.5 a la categoria con menos', AppLanguage.fr: 'x1.5 a la categorie avec le moins', AppLanguage.de: 'x1.5 fur die Kategorie mit den wenigsten', AppLanguage.pt: 'x1.5 para categoria com menos', AppLanguage.th: 'x1.5 หมวดที่มีน้อยสุด' },
    'ps_double_junk': { AppLanguage.en: 'Double junk counts as 5', AppLanguage.ja: 'ダブルカス5枚換算', AppLanguage.zhCn: '双皮算5张', AppLanguage.zhTw: '雙皮算5張', AppLanguage.es: 'Doble basura cuenta como 5', AppLanguage.fr: 'Double rebut compte pour 5', AppLanguage.de: 'Doppelschrott zahlt als 5', AppLanguage.pt: 'Lixo duplo conta como 5', AppLanguage.th: 'พีคู่นับเป็น 5' },
    'ps_comeback_king': { AppLanguage.en: 'x1.5 when behind, x0.8 when winning', AppLanguage.ja: '負けてる時x1.5、勝ってる時x0.8', AppLanguage.zhCn: '落后时x1.5 领先时x0.8', AppLanguage.zhTw: '落後時x1.5 領先時x0.8', AppLanguage.es: 'x1.5 perdiendo, x0.8 ganando', AppLanguage.fr: 'x1.5 en retard, x0.8 en tete', AppLanguage.de: 'x1.5 hinten, x0.8 vorne', AppLanguage.pt: 'x1.5 perdendo, x0.8 ganhando', AppLanguage.th: 'x1.5 ตามหลัง x0.8 นำอยู่' },
    'ps_flower_viewing': { AppLanguage.en: '+8 chips on double match in same turn', AppLanguage.ja: '同ターン2回マッチで+8 chips', AppLanguage.zhCn: '同回合双匹配+8 chips', AppLanguage.zhTw: '同回合雙匹配+8 chips', AppLanguage.es: '+8 chips por doble emparejamiento', AppLanguage.fr: '+8 chips en double match meme tour', AppLanguage.de: '+8 Chips bei Doppelmatch im selben Zug', AppLanguage.pt: '+8 chips por dupla combinacao no mesmo turno', AppLanguage.th: '+8 ชิปจับคู่ 2 ครั้งในเทิร์นเดียว' },
    'ps_ribbon_weaver': { AppLanguage.en: '+2 mult if 4+ ribbons', AppLanguage.ja: '短冊4枚以上で+2 mult', AppLanguage.zhCn: '4+条+2 mult', AppLanguage.zhTw: '4+條+2 mult', AppLanguage.es: '+2 mult con 4+ cintas', AppLanguage.fr: '+2 mult avec 4+ rubans', AppLanguage.de: '+2 Mult bei 4+ Bandern', AppLanguage.pt: '+2 mult com 4+ fitas', AppLanguage.th: '+2 ตัวคูณเมื่อมี 4+ แถบ' },
    'ps_sweep_master': { AppLanguage.en: '+0.3 mult per sweep', AppLanguage.ja: '一掃1回毎に+0.3 mult', AppLanguage.zhCn: '每次扫荡+0.3 mult', AppLanguage.zhTw: '每次掃蕩+0.3 mult', AppLanguage.es: '+0.3 mult por barrido', AppLanguage.fr: '+0.3 mult par balayage', AppLanguage.de: '+0.3 Mult pro Fegen', AppLanguage.pt: '+0.3 mult por varredura', AppLanguage.th: '+0.3 ตัวคูณต่อการกวาด' },
    'ps_rainy_season': { AppLanguage.en: 'December cards match all months', AppLanguage.ja: '12月カードが全月とマッチ', AppLanguage.zhCn: '12月牌匹配所有月', AppLanguage.zhTw: '12月牌匹配所有月', AppLanguage.es: 'Cartas de diciembre emparejan con todo', AppLanguage.fr: 'Cartes decembre associent tous les mois', AppLanguage.de: 'Dezember-Karten passen zu allen Monaten', AppLanguage.pt: 'Cartas de dezembro combinam com todos', AppLanguage.th: 'ไพ่เดือน 12 จับคู่ได้ทุกเดือน' },
    'ps_flower_rain': { AppLanguage.en: '40% chance junk upgrades to ribbon', AppLanguage.ja: '40%でカスが短冊に昇格', AppLanguage.zhCn: '40%概率皮升格为条', AppLanguage.zhTw: '40%機率皮升格為條', AppLanguage.es: '40% prob. basura sube a cinta', AppLanguage.fr: '40% chance rebut promu en ruban', AppLanguage.de: '40% Chance Schrott wird zu Band', AppLanguage.pt: '40% chance lixo vira fita', AppLanguage.th: '40% พีอัปเป็นแถบ' },
    'ps_flower_bomb': { AppLanguage.en: 'x3.0 when hand has 3 cards of same month', AppLanguage.ja: '同月3枚ハンド時x3.0', AppLanguage.zhCn: '手中同月3张时x3.0', AppLanguage.zhTw: '手中同月3張時x3.0', AppLanguage.es: 'x3.0 con 3 cartas del mismo mes', AppLanguage.fr: 'x3.0 avec 3 cartes du meme mois', AppLanguage.de: 'x3.0 bei 3 Karten desselben Monats', AppLanguage.pt: 'x3.0 com 3 cartas do mesmo mes', AppLanguage.th: 'x3.0 เมื่อมี 3 ไพ่เดือนเดียวกัน' },
    'ps_provoke': { AppLanguage.en: 'Reveal hand to opponent for x2.0 score', AppLanguage.ja: '手札公開でスコアx2.0', AppLanguage.zhCn: '展示手牌得分x2.0', AppLanguage.zhTw: '展示手牌得分x2.0', AppLanguage.es: 'Revelar mano para x2.0', AppLanguage.fr: 'Reveler main pour x2.0', AppLanguage.de: 'Hand aufdecken fur x2.0', AppLanguage.pt: 'Revelar mao para x2.0', AppLanguage.th: 'เปิดไพ่ได้คะแนน x2.0' },
    'ps_ppuk_inducer': { AppLanguage.en: 'Steal 2 extra junk when opponent ppuks', AppLanguage.ja: '相手ションで追加カス2枚奪取', AppLanguage.zhCn: '对手爆时额外夺2皮', AppLanguage.zhTw: '對手爆時額外奪2皮', AppLanguage.es: 'Robar 2 extra al ppuk rival', AppLanguage.fr: 'Voler 2 rebuts extra sur ppuk', AppLanguage.de: '2 extra Schrott bei Gegner-Ppuk', AppLanguage.pt: 'Roubar 2 extra no ppuk inimigo', AppLanguage.th: 'ขโมยพี 2 ใบเมื่อคู่ต่อสู้ปุก' },
    'ps_legendary_tazza': { AppLanguage.en: 'All mult x2.0', AppLanguage.ja: '全倍率x2.0', AppLanguage.zhCn: '所有倍率x2.0', AppLanguage.zhTw: '所有倍率x2.0', AppLanguage.es: 'Todo mult x2.0', AppLanguage.fr: 'Tout mult x2.0', AppLanguage.de: 'Alle Mult x2.0', AppLanguage.pt: 'Todo mult x2.0', AppLanguage.th: 'ตัวคูณทั้งหมด x2.0' },
    'ps_gamblers_instinct': { AppLanguage.en: 'Choose 1 of 2 cards from deck each turn', AppLanguage.ja: '毎ターン山から2枚中1枚選択', AppLanguage.zhCn: '每回合从牌库2选1', AppLanguage.zhTw: '每回合從牌庫2選1', AppLanguage.es: 'Elegir 1 de 2 cartas del mazo', AppLanguage.fr: 'Choisir 1 carte sur 2 du paquet', AppLanguage.de: '1 von 2 Karten aus dem Stapel wahlen', AppLanguage.pt: 'Escolher 1 de 2 cartas do baralho', AppLanguage.th: 'เลือก 1 ใน 2 จากกอง' },
    'ps_time_rewind': { AppLanguage.en: 'Rewind 3 turns once per round', AppLanguage.ja: '1ラウンド1回3ターン巻き戻し', AppLanguage.zhCn: '每局可回溯3回合一次', AppLanguage.zhTw: '每局可回溯3回合一次', AppLanguage.es: 'Rebobinar 3 turnos 1 vez', AppLanguage.fr: 'Rembobiner 3 tours 1 fois', AppLanguage.de: '3 Zuge einmal zuruckspulen', AppLanguage.pt: 'Rebobinar 3 turnos 1 vez', AppLanguage.th: 'ย้อน 3 เทิร์น 1 ครั้ง' },
    'ps_flower_lord': { AppLanguage.en: 'Rearrange captured card months once', AppLanguage.ja: '獲得カード月変更1回', AppLanguage.zhCn: '重排已获牌月份1次', AppLanguage.zhTw: '重排已獲牌月份1次', AppLanguage.es: 'Reorganizar meses de cartas 1 vez', AppLanguage.fr: 'Reorganiser les mois des cartes 1 fois', AppLanguage.de: 'Kartenmonate einmal umsortieren', AppLanguage.pt: 'Reorganizar meses das cartas 1 vez', AppLanguage.th: 'จัดเรียงเดือนไพ่ใหม่ 1 ครั้ง' },
    't_lucky_coin': { AppLanguage.en: '20% shop discount', AppLanguage.ja: 'ショップ20%割引', AppLanguage.zhCn: '商店八折', AppLanguage.zhTw: '商店八折', AppLanguage.es: '20% descuento en tienda', AppLanguage.fr: '20% de reduction en boutique', AppLanguage.de: '20% Shoprabatt', AppLanguage.pt: '20% desconto na loja', AppLanguage.th: 'ลด 20% ร้านค้า' },
    't_gambler_soul': { AppLanguage.en: '+0.5~2.0 mult on 3+ Go', AppLanguage.ja: '3Go以上で+0.5~2.0倍', AppLanguage.zhCn: '3Go以上+0.5~2.0倍', AppLanguage.zhTw: '3Go以上+0.5~2.0倍', AppLanguage.es: '+0.5~2.0 mult con 3+ Go', AppLanguage.fr: '+0.5~2.0 mult avec 3+ Go', AppLanguage.de: '+0.5~2.0 Mult bei 3+ Go', AppLanguage.pt: '+0.5~2.0 mult com 3+ Go', AppLanguage.th: '+0.5~2.0 ตัวคูณเมื่อ 3+ Go' },
    't_mountain_charm': { AppLanguage.en: 'Animal card score x1.5', AppLanguage.ja: '動物カードスコアx1.5', AppLanguage.zhCn: '动物牌分数x1.5', AppLanguage.zhTw: '動物牌分數x1.5', AppLanguage.es: 'Puntuacion animal x1.5', AppLanguage.fr: 'Score animal x1.5', AppLanguage.de: 'Tierkarten-Punktzahl x1.5', AppLanguage.pt: 'Pontuacao animal x1.5', AppLanguage.th: 'คะแนนสัตว์ x1.5' },
    't_moonlight_pouch': { AppLanguage.en: 'Random bonus card at round start', AppLanguage.ja: 'ラウンド開始時ランダムボーナスカード', AppLanguage.zhCn: '回合开始时随机奖励牌', AppLanguage.zhTw: '回合開始時隨機獎勵牌', AppLanguage.es: 'Carta bonus aleatoria al inicio', AppLanguage.fr: 'Carte bonus aleatoire au debut', AppLanguage.de: 'Zufalls-Bonuskarte zu Beginn', AppLanguage.pt: 'Carta bonus aleatoria no inicio', AppLanguage.th: 'ไพ่โบนัสสุ่มตอนเริ่มรอบ' },
    't_dokkaebi_mallet': { AppLanguage.en: '10% chance +2G per junk capture', AppLanguage.ja: 'カス獲得時10%で+2G', AppLanguage.zhCn: '吃皮时10%+2G', AppLanguage.zhTw: '吃皮時10%+2G', AppLanguage.es: '10% prob. +2G al capturar basura', AppLanguage.fr: '10% chance +2G par capture rebut', AppLanguage.de: '10% Chance +2G pro Schrottfang', AppLanguage.pt: '10% chance +2G por captura de lixo', AppLanguage.th: '10% +2G ต่อการจับพี' },
    't_samshin_granny': { AppLanguage.en: 'Random common passive at run start', AppLanguage.ja: 'ラン開始時ランダムCommonパッシブ', AppLanguage.zhCn: '运行开始时随机Common被动', AppLanguage.zhTw: '運行開始時隨機Common被動', AppLanguage.es: 'Pasiva comun aleatoria al iniciar', AppLanguage.fr: 'Passive commune aleatoire au debut', AppLanguage.de: 'Zufalls-Common-Passive beim Start', AppLanguage.pt: 'Passiva comum aleatoria ao iniciar', AppLanguage.th: 'พาสซีฟ Common สุ่มตอนเริ่ม' },
    't_cheaters_glove': { AppLanguage.en: 'Card returns to hand on match failure', AppLanguage.ja: 'マッチ失敗時カード手札に戻る', AppLanguage.zhCn: '匹配失败时牌返回手中', AppLanguage.zhTw: '匹配失敗時牌返回手中', AppLanguage.es: 'Carta vuelve a la mano si falla', AppLanguage.fr: 'Carte revient en main si echec', AppLanguage.de: 'Karte kehrt bei Fehlschlag zuruck', AppLanguage.pt: 'Carta volta a mao se falhar', AppLanguage.th: 'ไพ่กลับมือเมื่อจับคู่พลาด' },
    't_golden_mat': { AppLanguage.en: '+15% gold on victory', AppLanguage.ja: '勝利時ゴールド+15%', AppLanguage.zhCn: '胜利时金币+15%', AppLanguage.zhTw: '勝利時金幣+15%', AppLanguage.es: '+15% oro al ganar', AppLanguage.fr: '+15% or en cas de victoire', AppLanguage.de: '+15% Gold bei Sieg', AppLanguage.pt: '+15% ouro na vitoria', AppLanguage.th: '+15% ทองเมื่อชนะ' },
    't_gwangbak_shield': { AppLanguage.en: 'Nullifies gwangbak penalty', AppLanguage.ja: '光罰ペナルティ無効化', AppLanguage.zhCn: '光罚无效化', AppLanguage.zhTw: '光罰無效化', AppLanguage.es: 'Anula penalizacion gwangbak', AppLanguage.fr: 'Annule la penalite gwangbak', AppLanguage.de: 'Gwangbak-Strafe aufheben', AppLanguage.pt: 'Anula penalidade gwangbak', AppLanguage.th: 'ยกเลิกโทษกวังบัก' },
    'a_joker': { AppLanguage.en: 'Capture any 1 card from the field', AppLanguage.ja: '場から好きな1枚を確定獲得', AppLanguage.zhCn: '从场上确定获取1张', AppLanguage.zhTw: '從場上確定獲取1張', AppLanguage.es: 'Captura cualquier carta del campo', AppLanguage.fr: 'Capturez 1 carte du terrain', AppLanguage.de: 'Beliebige 1 Karte vom Feld fangen', AppLanguage.pt: 'Capture qualquer carta do campo', AppLanguage.th: 'ยึดไพ่ 1 ใบจากสนาม' },
    'a_sniper': { AppLanguage.en: 'Steal 1 card from opponent', AppLanguage.ja: '相手のカード1枚を奪取', AppLanguage.zhCn: '夺取对手1张牌', AppLanguage.zhTw: '奪取對手1張牌', AppLanguage.es: 'Robar 1 carta al oponente', AppLanguage.fr: 'Voler 1 carte a l\'adversaire', AppLanguage.de: '1 Karte vom Gegner stehlen', AppLanguage.pt: 'Roubar 1 carta do oponente', AppLanguage.th: 'ขโมย 1 ใบจากคู่ต่อสู้' },
    'a_shuffle': { AppLanguage.en: 'Reshuffle field + deck', AppLanguage.ja: '場+山札を再シャッフル', AppLanguage.zhCn: '重洗场+牌库', AppLanguage.zhTw: '重洗場+牌庫', AppLanguage.es: 'Rebarajar campo + mazo', AppLanguage.fr: 'Remelanger terrain + paquet', AppLanguage.de: 'Feld + Stapel neu mischen', AppLanguage.pt: 'Reembaralhar campo + baralho', AppLanguage.th: 'สับสนาม+กองใหม่' },
    'a_trick': { AppLanguage.en: 'Change month of 1 field card', AppLanguage.ja: '場の1枚の月を変更', AppLanguage.zhCn: '改变场上1张牌的月份', AppLanguage.zhTw: '改變場上1張牌的月份', AppLanguage.es: 'Cambiar mes de 1 carta del campo', AppLanguage.fr: 'Changer le mois d\'1 carte du terrain', AppLanguage.de: 'Monat einer Feldkarte andern', AppLanguage.pt: 'Mudar mes de 1 carta do campo', AppLanguage.th: 'เปลี่ยนเดือนไพ่ 1 ใบ' },
    'a_keen_eye': { AppLanguage.en: 'View top 3 deck cards', AppLanguage.ja: '山上3枚を確認', AppLanguage.zhCn: '查看牌库顶3张', AppLanguage.zhTw: '查看牌庫頂3張', AppLanguage.es: 'Ver 3 cartas superiores del mazo', AppLanguage.fr: 'Voir 3 cartes du dessus', AppLanguage.de: 'Obere 3 Stapelkarten sehen', AppLanguage.pt: 'Ver 3 cartas do topo', AppLanguage.th: 'ดู 3 ใบบนสุด' },
    'a_card_laundry': { AppLanguage.en: 'Move 1 field card to deck bottom', AppLanguage.ja: '場の1枚を山底へ', AppLanguage.zhCn: '将场上1张牌移至牌库底', AppLanguage.zhTw: '將場上1張牌移至牌庫底', AppLanguage.es: 'Mover 1 carta al fondo del mazo', AppLanguage.fr: 'Deplacer 1 carte au fond du paquet', AppLanguage.de: '1 Feldkarte unter den Stapel', AppLanguage.pt: 'Mover 1 carta para o fundo', AppLanguage.th: 'ย้าย 1 ใบไปก้นกอง' },
    'c_gwang_scanner': { AppLanguage.en: 'Increase bright card placement odds on dealing', AppLanguage.ja: '配布時の光カード出現率UP', AppLanguage.zhCn: '发牌时光牌概率提升', AppLanguage.zhTw: '發牌時光牌機率提升', AppLanguage.es: 'Aumentar prob. de brillantes al repartir', AppLanguage.fr: 'Augmenter chances de lumiere au deal', AppLanguage.de: 'Chance auf Lichtkarten beim Austeilen erhohen', AppLanguage.pt: 'Aumentar chance de brilhantes na distribuicao', AppLanguage.th: 'เพิ่มโอกาสกวังตอนแจก' },
    'c_safety_helmet': { AppLanguage.en: 'Prevent bankruptcy once', AppLanguage.ja: '破産を1回防止', AppLanguage.zhCn: '防止破产一次', AppLanguage.zhTw: '防止破產一次', AppLanguage.es: 'Prevenir bancarrota 1 vez', AppLanguage.fr: 'Prevenir la faillite 1 fois', AppLanguage.de: 'Bankrott einmal verhindern', AppLanguage.pt: 'Prevenir falencia 1 vez', AppLanguage.th: 'ป้องกันล้มละลาย 1 ครั้ง' },
    'c_jackpot_ticket': { AppLanguage.en: 'x5 final score on victory', AppLanguage.ja: '勝利時最終スコアx5', AppLanguage.zhCn: '胜利时最终分x5', AppLanguage.zhTw: '勝利時最終分x5', AppLanguage.es: 'x5 puntuacion final al ganar', AppLanguage.fr: 'x5 score final en cas de victoire', AppLanguage.de: 'x5 Endpunktzahl bei Sieg', AppLanguage.pt: 'x5 pontuacao final na vitoria', AppLanguage.th: 'x5 คะแนนสุดท้ายเมื่อชนะ' },
    'c_pi_magnet': { AppLanguage.en: 'Gain extra junk on capture this round', AppLanguage.ja: 'このラウンドカス獲得時+1枚', AppLanguage.zhCn: '本局吃皮时额外+1张', AppLanguage.zhTw: '本局吃皮時額外+1張', AppLanguage.es: '+1 basura extra al capturar esta ronda', AppLanguage.fr: '+1 rebut extra a la capture ce round', AppLanguage.de: '+1 Schrott extra beim Fangen diese Runde', AppLanguage.pt: '+1 lixo extra ao capturar esta rodada', AppLanguage.th: '+1 พีเพิ่มรอบนี้' },
    'c_ribbon_polish': { AppLanguage.en: 'Double ribbon score this round', AppLanguage.ja: 'このラウンド短冊スコアx2', AppLanguage.zhCn: '本局条带分数x2', AppLanguage.zhTw: '本局條帶分數x2', AppLanguage.es: 'x2 puntuacion de cintas esta ronda', AppLanguage.fr: 'x2 score rubans ce round', AppLanguage.de: 'x2 Band-Punktzahl diese Runde', AppLanguage.pt: 'x2 pontuacao de fitas esta rodada', AppLanguage.th: 'x2 คะแนนแถบรอบนี้' },
    'c_bomb_fuse': { AppLanguage.en: 'x4 on bomb/chongtong this round', AppLanguage.ja: 'このラウンド爆弾/総統時x4', AppLanguage.zhCn: '本局炸弹/总统x4', AppLanguage.zhTw: '本局炸彈/總統x4', AppLanguage.es: 'x4 en bomba/chongtong esta ronda', AppLanguage.fr: 'x4 sur bombe/chongtong ce round', AppLanguage.de: 'x4 bei Bombe/Chongtong diese Runde', AppLanguage.pt: 'x4 em bomba/chongtong esta rodada', AppLanguage.th: 'x4 ระเบิด/ชงทงรอบนี้' },
    'x_ogwang_crown': { AppLanguage.en: 'x2.0 with 3+ brights. Unlock: Five Brights once', AppLanguage.ja: '光3枚以上でx2.0 解放条件:五光1回', AppLanguage.zhCn: '3+光牌x2.0 解锁:五光1次', AppLanguage.zhTw: '3+光牌x2.0 解鎖:五光1次', AppLanguage.es: 'x2.0 con 3+ brillantes. Desbloqueo: Cinco Brillantes', AppLanguage.fr: 'x2.0 avec 3+ lumieres. Deblocage: Cinq Lumieres', AppLanguage.de: 'x2.0 bei 3+ Licht. Freischaltung: Funf Lichter', AppLanguage.pt: 'x2.0 com 3+ brilhantes. Desbloquear: Cinco Brilhantes', AppLanguage.th: 'x2.0 เมื่อ 3+ กวัง ปลดล็อค: ห้ากวัง' },
  };

  /// 번역 헬퍼
  String _t(Map<AppLanguage, String> translations) {
    return translations[language] ?? translations[AppLanguage.en] ?? '';
  }

  // ─── [AI 및 스테이지 이름 동적 반환] ───
  String getAiName(dynamic ai) {
    if (language == AppLanguage.ko) return ai.nameKo;
    return ai.nameEn;
  }

  String getStageName(dynamic stage) {
    if (language == AppLanguage.ko) return stage.nameKo;
    return stage.name;
  }
}

