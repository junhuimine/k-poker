/// 🎴 K-Poker — 다국어(i18n) 시스템
///
/// 기기 기본 언어 자동 감지 + 10개 언어 지원
/// 하드코딩 없이 모든 UI 텍스트를 중앙 관리
library;

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
        AppLanguage.ko: '📜 영구 부적 (패시브)', AppLanguage.en: '📜 Permanent Talisman (Passive)', AppLanguage.ja: '📜 永久お守り (パッシブ)', AppLanguage.zhCn: '📜 永久护符 (被动)', AppLanguage.zhTw: '📜 永久護符 (被動)',
        AppLanguage.es: '📜 Talisman permanente (Pasivo)', AppLanguage.fr: '📜 Talisman permanent (Passif)', AppLanguage.de: '📜 Permanenter Talisman (Passiv)', AppLanguage.pt: '📜 Talismã permanente (Passivo)', AppLanguage.th: '📜 เครื่องรางถาวร (พาสซีฟ)',
      },
      'shopPassiveSubtitle': {
        AppLanguage.ko: '한 번 사두면 평생 자동 적용!', AppLanguage.en: 'Buy once and it applies forever!', AppLanguage.ja: '一度買えば永久に自動適用！', AppLanguage.zhCn: '买一次，永久自动生效！', AppLanguage.zhTw: '買一次，永久自動生效！',
        AppLanguage.es: '¡Compra una vez y se aplica para siempre!', AppLanguage.fr: 'Achetez une fois, actif pour toujours !', AppLanguage.de: 'Einmal kaufen, gilt für immer!', AppLanguage.pt: 'Compre uma vez e vale para sempre!', AppLanguage.th: 'ซื้อครั้งเดียว มีผลตลอดไป!',
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
    'S-001': { AppLanguage.en: 'Exclusive Joker', AppLanguage.ja: '専用ジョーカー', AppLanguage.zhCn: '专属鬼牌', AppLanguage.zhTw: '專屬鬼牌', AppLanguage.es: 'Comodín exclusivo', AppLanguage.fr: 'Joker exclusif', AppLanguage.de: 'Exklusiver Joker', AppLanguage.pt: 'Coringa exclusivo', AppLanguage.th: 'โจ๊กเกอร์พิเศษ' },
    'S-002': { AppLanguage.en: 'Sniper', AppLanguage.ja: 'スナイパー', AppLanguage.zhCn: '狙击手', AppLanguage.zhTw: '狙擊手', AppLanguage.es: 'Francotirador', AppLanguage.fr: 'Sniper', AppLanguage.de: 'Scharfschütze', AppLanguage.pt: 'Atirador', AppLanguage.th: 'สไนเปอร์' },
    'S-003': { AppLanguage.en: 'Deck Shuffle', AppLanguage.ja: 'デッキシャッフル', AppLanguage.zhCn: '牌库洗牌', AppLanguage.zhTw: '牌庫洗牌', AppLanguage.es: 'Barajar mazo', AppLanguage.fr: 'Mélange du paquet', AppLanguage.de: 'Deck mischen', AppLanguage.pt: 'Embaralhar', AppLanguage.th: 'สับกองไพ่' },
    'P-001': { AppLanguage.en: 'Gwang Scanner', AppLanguage.ja: '光スキャナー', AppLanguage.zhCn: '光牌扫描仪', AppLanguage.zhTw: '光牌掃描儀', AppLanguage.es: 'Escáner Gwang', AppLanguage.fr: 'Scanner Gwang', AppLanguage.de: 'Gwang-Scanner', AppLanguage.pt: 'Scanner Gwang', AppLanguage.th: 'สแกนเนอร์กวัง' },
    'P-002': { AppLanguage.en: 'Safety Helmet', AppLanguage.ja: '安全ヘルメット', AppLanguage.zhCn: '安全头盔', AppLanguage.zhTw: '安全頭盔', AppLanguage.es: 'Casco de seguridad', AppLanguage.fr: 'Casque de sécurité', AppLanguage.de: 'Schutzhelm', AppLanguage.pt: 'Capacete de segurança', AppLanguage.th: 'หมวกนิรภัย' },
    'P-003': { AppLanguage.en: 'Jackpot Ticket', AppLanguage.ja: 'ジャックポットチケット', AppLanguage.zhCn: '头奖入场券', AppLanguage.zhTw: '頭獎入場券', AppLanguage.es: 'Boleto Jackpot', AppLanguage.fr: 'Ticket Jackpot', AppLanguage.de: 'Jackpot-Ticket', AppLanguage.pt: 'Bilhete Jackpot', AppLanguage.th: 'ตั๋วแจ็กพอต' },
    'T-001': { AppLanguage.en: 'Regular Customer', AppLanguage.ja: '常連客', AppLanguage.zhCn: '常客', AppLanguage.zhTw: '常客', AppLanguage.es: 'Cliente habitual', AppLanguage.fr: 'Client fidèle', AppLanguage.de: 'Stammkunde', AppLanguage.pt: 'Cliente frequente', AppLanguage.th: 'ลูกค้าประจำ' },
    'T-002': { AppLanguage.en: 'Mental Guard', AppLanguage.ja: 'メンタルガード', AppLanguage.zhCn: '精神护盾', AppLanguage.zhTw: '精神護盾', AppLanguage.es: 'Guardia mental', AppLanguage.fr: 'Garde mentale', AppLanguage.de: 'Mentalschutz', AppLanguage.pt: 'Guarda mental', AppLanguage.th: 'การ์ดจิตใจ' },
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
      AppLanguage.fr: 'Défend une fois contre la capture de vos cartes par l\'adversaire lors d\'un Ppeok (échec de bombe).',
      AppLanguage.de: 'Verteidigt einmal dagegen, dass der Gegner deine Karten bei einem Ppeok (Bombenfehler) einfängt.',
      AppLanguage.pt: 'Defende uma vez contra o oponente capturar suas cartas quando você faz um Ppeok (falha de bomba).',
      AppLanguage.th: 'ป้องกันหนึ่งครั้งเมื่อคู่ต่อสู้พยายามยึดไพ่ของคุณตอนทำปอก (ระเบิดพลาด)',
    },
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

