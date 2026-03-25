/// 🎴 K-Poker — 다국어(i18n) 시스템
///
/// 기기 기본 언어 자동 감지 + 10개 언어 지원
/// 하드코딩 없이 모든 UI 텍스트를 중앙 관리
library;

import 'package:flutter/material.dart';

import 'ai_dialogues_en.dart';
import 'ai_dialogues_ja.dart';
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

  // ─── [도움말/도감 시스템 텍스트] ───
  String get tabRules => _t({
    AppLanguage.ko: '규칙', AppLanguage.en: 'Rules', AppLanguage.ja: 'ルール', AppLanguage.zhCn: '规则', AppLanguage.zhTw: '規則',
  });
  String get tabDictionary => _t({
    AppLanguage.ko: '도감', AppLanguage.en: 'Cards', AppLanguage.ja: '図鑑', AppLanguage.zhCn: '图鉴', AppLanguage.zhTw: '圖鑑',
  });
  String get tabYaku => _t({
    AppLanguage.ko: '족보', AppLanguage.en: 'Yaku', AppLanguage.ja: '役', AppLanguage.zhCn: '牌型', AppLanguage.zhTw: '牌型',
  });

  String get ruleIntroTitle => _t({
    AppLanguage.ko: '🎴 게임 기본 규칙', AppLanguage.en: '🎴 Basic Rules', AppLanguage.ja: '🎴 基本ルール', AppLanguage.zhCn: '🎴 基本规则', AppLanguage.zhTw: '🎴 基本規則',
  });
  String get ruleIntroBody => _t({
    AppLanguage.ko: 'K-Poker(화투)는 같은 계절(1~12월)의 무늬를 맞춰 카드를 획득하는 한국 전통 고스톱 기반 카드 배틀입니다.',
    AppLanguage.en: 'K-Poker (Hwatu) is a card battle based on traditional Korean Go-Stop, where you match cards of the same month/season to capture them.',
    AppLanguage.ja: 'K-Poker(花札)は、同じ月(季節)の手札を合わせてカードを獲得する、韓国の伝統的な「ゴーストップ」ベースのカードバトルです。',
    AppLanguage.zhCn: 'K-Poker (花牌) 是一款基于韩国传统 Go-Stop 的卡牌对战游戏，通过匹配同月/季节的卡牌来进行。',
    AppLanguage.zhTw: 'K-Poker (花牌) 是一款基於韓國傳統 Go-Stop 的卡牌對戰遊戲，透過配對同月/季節的卡牌來進行。',
  });

  String get ruleTurnTitle => _t({
    AppLanguage.ko: '🔄 턴 진행', AppLanguage.en: '🔄 Turn Flow', AppLanguage.ja: '🔄 ターンの進行', AppLanguage.zhCn: '🔄 回合流程', AppLanguage.zhTw: '🔄 回合流程',
  });
  String get ruleTurnBody => _t({
    AppLanguage.ko: '1. 내 손의 카드를 필드에 내어 같은 무늬를 맞춥니다.\n2. 덱에서 카드 1장을 뒤집어 필드에 냅니다.\n3. 매칭된 카드들을 내 공간으로 가져와 점수를 계산합니다!',
    AppLanguage.en: '1. Play a card from your hand to match the field.\n2. Flip 1 card from the deck to the field.\n3. Take all matched cards into your captured area to score!',
    AppLanguage.ja: '1. 手札からカードを出し、場の同じ柄に合わせます。\n2. 山札から1枚めくり、場に出します。\n3. マッチしたカードを獲得エリアに入れ、役と点数を作ります！',
    AppLanguage.zhCn: '1. 出一张手牌以匹配场上的花色。\n2. 从牌库翻开一张牌到场上。\n3. 将匹配成功的卡牌收入得分区！',
    AppLanguage.zhTw: '1. 出一張手牌以配對場上的花色。\n2. 從牌庫翻開一張牌到場上。\n3. 將配對成功的卡牌收入得分區！',
  });

  String get ruleGoStopTitle => _t({
    AppLanguage.ko: '🔥 고 & 스톱', AppLanguage.en: '🔥 Go & Stop', AppLanguage.ja: '🔥 ゴー & ストップ', AppLanguage.zhCn: '🔥 Go & Stop', AppLanguage.zhTw: '🔥 Go & Stop',
  });
  String get ruleGoStopBody => _t({
    AppLanguage.ko: '획득한 점수가 3점 이상이 되면 선택할 수 있습니다.\n• GO: 게임을 계속합니다. 추가 점수와 2배율(3고 이상) 혜택을 얻지만, 상대가 먼저 점수를 내면 패배합니다(독박)!\n• STOP: 즉시 승리하며 베팅금을 얻어 스테이지를 넘깁니다.',
    AppLanguage.en: 'Available when you reach 3 or more points.\n• GO: Continue playing. You get multiplier bonuses (at 3 GO), but if the opponent scores first, you lose instantly (Dokbak)!\n• STOP: Win immediately and claim the bet money to clear the stage.',
    AppLanguage.ja: '3点以上になった時に選択できます。\n• GO：継続します。追加点や倍率ボーナス(3GO以上)を得ますが、相手に先に点数を取られると即敗北(独り被り)となります！\n• STOP：すぐに勝利し、賭け金を獲得してステージをクリアします。',
    AppLanguage.zhCn: '到达3分时可进行选择。\n• GO：继续游戏。可获得额外倍率(3 Go 以上)，但若对手先得分则立即失败(反加)。\n• STOP：立即胜利并带走奖金，进入下一关。',
    AppLanguage.zhTw: '到達3分時可進行選擇。\n• GO：繼續遊戲。可獲得額外倍率(3 Go 以上)，但若對手先得分則立即失敗(反加)。\n• STOP：立即勝利並帶走獎金，進入下一關。',
  });

  // ─── [족보 안내 텍스트] ───
  String get yakuGwangTitle => _t({
    AppLanguage.ko: '🌟 광 (Kwang)', AppLanguage.en: '🌟 Kwang (Bright)', AppLanguage.ja: '🌟 光 (光札)', AppLanguage.zhCn: '🌟 光', AppLanguage.zhTw: '🌟 光',
  });
  String get yakuGwangBody => _t({
    AppLanguage.ko: '• 삼광: 광 3장 = 3점 (비광 포함시 2점)\n• 사광: 광 4장 = 4점\n• 오광: 광 5장 = 15점 (최강의 족보!)',
    AppLanguage.en: '• 3 Kwang: 3 Bright cards = 3 pts (2 pts if Rain card is included)\n• 4 Kwang: 4 Bright cards = 4 pts\n• 5 Kwang: All 5 Bright cards = 15 pts (Max!)',
    AppLanguage.ja: '• 三光：光札3枚 = 3点 (雨入りは2点)\n• 四光：光札4枚 = 4点\n• 五光：光札5枚 = 15点 (最強役!)',
    AppLanguage.zhCn: '• 三光：3张光牌 = 3分 (若含雨光则为2分)\n• 四光：4张光牌 = 4分\n• 五光：集齐5张光牌 = 15分 (最强!)',
    AppLanguage.zhTw: '• 三光：3張光牌 = 3分 (若含雨光則為2分)\n• 四光：4張光牌 = 4分\n• 五光：集齊5張光牌 = 15分 (最強!)',
  });

  String get yakuRibbonTitle => _t({
    AppLanguage.ko: '🎀 홍단 / 청단 / 초단', AppLanguage.en: '🎀 Dan (Ribbon)', AppLanguage.ja: '🎀 短 (赤短/青短/草短)', AppLanguage.zhCn: '🎀 短 (红/青/草短)', AppLanguage.zhTw: '🎀 短 (紅/青/草短)',
  });
  String get yakuRibbonBody => _t({
    AppLanguage.ko: '• 홍단: 글씨 있는 빨간 띠 3장 = 3점\n• 청단: 파란 띠 3장 = 3점\n• 초단: 글씨 없는 빨간 띠 3장 = 3점',
    AppLanguage.en: '• Red Ribbon: 3 Red Titled = 3 pts\n• Blue Ribbon: 3 Blue = 3 pts\n• Grass Ribbon: 3 Plain Red = 3 pts',
    AppLanguage.ja: '• 赤短：文字入り赤短冊3枚 = 3点\n• 青短：青短冊3枚 = 3点\n• 草短：文字なし赤短冊3枚 = 3点',
    AppLanguage.zhCn: '• 红短：3张带字红短 = 3分\n• 青短：3张青短 = 3分\n• 草短：3张无字红短 = 3分',
    AppLanguage.zhTw: '• 紅短：3張帶字紅短 = 3分\n• 青短：3張青短 = 3分\n• 草短：3張無字紅短 = 3分',
  });

  String get yakuAnimalTitle => _t({
    AppLanguage.ko: '🦌 멍텅구리 (고도리/열끗)', AppLanguage.en: '🦌 Godori & Animal', AppLanguage.ja: '🦌 動物 (猪鹿蝶/タネ)', AppLanguage.zhCn: '🦌 动物 (役鸟/十分)', AppLanguage.zhTw: '🦌 動物 (役鳥/十分)',
  });
  String get yakuAnimalBody => _t({
    AppLanguage.ko: '• 고도리: 새 그림 3장(2, 4, 8월) = 5점\n• 열끗: 동물 5장 = 1점 (이후 1장당 1점 추가)\n• 멍따: 열끗 7장 이상 = 점수 2배 폭증!',
    AppLanguage.en: '• Godori: 3 Bird cards (Feb, Apr, Aug) = 5 pts\n• Animal: 5 Animal cards = 1 pt (+1 pt per extra)\n• Mung-tta: 7+ Animal cards = Score x2!',
    AppLanguage.ja: '• 猪鹿蝶(ゴドリ)：鳥の絵3枚(2,4,8月) = 5点\n• タネ：動物5枚 = 1点 (以降1枚ごとに+1)\n• タネの倍付け：動物7枚以上 = スコア2倍！',
    AppLanguage.zhCn: '• 高鸟：集齐3张特定的鸟类牌 = 5分\n• 十分：5张动物牌 = 1分 (之后每多1张+1)\n• 十分翻倍：7张以上动物牌 = 总分 x2!',
    AppLanguage.zhTw: '• 高鳥：集齊3張特定的鳥類牌 = 5分\n• 十分：5張動物牌 = 1分 (之後每多1張+1)\n• 十分翻倍：7張以上動物牌 = 總分 x2!',
  });

  String get yakuPiTitle => _t({
    AppLanguage.ko: '🍂 피 (Pi)', AppLanguage.en: '🍂 Pi (Junk)', AppLanguage.ja: '🍂 カス (皮)', AppLanguage.zhCn: '🍂 皮 (杂牌)', AppLanguage.zhTw: '🍂 皮 (雜牌)',
  });
  String get yakuPiBody => _t({
    AppLanguage.ko: '• 피: 가장 흔한 카드. 10장 = 1점 (이후 1장당 1점 추가)\n• 쌍피: 피 2장으로 취급되는 특수 카드!',
    AppLanguage.en: '• Pi: Common cards. 10 Pi = 1 pt (+1 pt per extra)\n• Double Pi (Ssang-Pi): Counts as 2 Pi cards!',
    AppLanguage.ja: '• カス：最も一般的なカード。10枚 = 1点(以降+1)\n• 双皮(サンピ)：カス2枚分として計算される特殊カード！',
    AppLanguage.zhCn: '• 皮：最普通的杂牌。10张=1分 (之后每多1张+1)\n• 双皮：视为2张皮的稀有卡！',
    AppLanguage.zhTw: '• 皮：最普通的雜牌。10張=1分 (之後每多1張+1)\n• 雙皮：視為2張皮的稀有卡！',
  });

  // ─── [실시간 튜토리얼 팝업 텍스트] ───
  String get tutFirstYakuTitle => _t({
    AppLanguage.ko: '🎉 첫 족보 완성!', AppLanguage.en: '🎉 First Yaku!', AppLanguage.ja: '🎉 初役完成！', AppLanguage.zhCn: '🎉 首次达成牌型！', AppLanguage.zhTw: '🎉 首次達成牌型！',
  });
  String get tutFirstYakuBody => _t({
    AppLanguage.ko: '족보를 완성하여 점수를 획득했습니다!\n총 점수가 3점을 넘기면 [고/스톱]을 통해 게임의 승부를 결정지을 수 있습니다. 족보 점수는 우측 패널을 통해 언제든 확인할 수 있어요.',
    AppLanguage.en: 'You gained points by completing a Yaku!\nReach 3 points to decide whether to GO or STOP. You can always check your Yaku checklist on the right panel.',
    AppLanguage.ja: '役を完成してスコアを獲得しました！\n合計3点を超えると、[GO]または[STOP]で勝負を決められます。完成した役の状況は右側のパネルで確認できます。',
    AppLanguage.zhCn: '你完成了一个牌型并获得了分数！\n总分达到3分时可以宣告 GO 或 STOP。你可以随时在右侧面板查看牌型进度。',
    AppLanguage.zhTw: '你完成了一個牌型並獲得了分數！\n總分達到3分時可以宣告 GO 或 STOP。你可以隨時在右側面板查看牌型進度。',
  });

  String get tutFirstGoTitle => _t({
    AppLanguage.ko: '🔥 첫 GO!', AppLanguage.en: '🔥 First GO!', AppLanguage.ja: '🔥 初のGO！', AppLanguage.zhCn: '🔥 首次宣告 GO！', AppLanguage.zhTw: '🔥 首次宣告 GO！',
  });
  String get tutFirstGoBody => _t({
    AppLanguage.ko: '고를 외치셨군요! 상남자다운 선택입니다.\n고를 할수록 보너스 배율이 커지지만, 만약 다음 턴에 상대방이 먼저 3점을 내고 스톱해버리면 [독박]을 쓰고 패배하게 됩니다! 무운을 빕니다!',
    AppLanguage.en: 'You called GO! A bold choice.\nEach GO increases your score multipliers, but if your opponent reaches 3 points and calls STOP first, you will lose instantly (Dokbak). Good luck!',
    AppLanguage.ja: 'GOを宣言しましたね！強気な選択です！\nGOをするほど倍率が上がりますが、次に相手が先に3点でSTOPを宣言してしまうと、独り被り(ドクバク)で敗北になります！健闘を祈ります！',
    AppLanguage.zhCn: '你宣告了 GO！勇敢的选择。\n每次 GO 都会增加分数倍率，但如果对方先达到3分并喊 STOP，你将直接失败(反加)。祝你好运！',
    AppLanguage.zhTw: '你宣告了 GO！勇敢的選擇。\n每次 GO 都會增加分數倍率，但如果對方先達到3分並喊 STOP，你將直接失敗(反加)。祝你好運！',
  });

  String get continueBtn => _t({
    AppLanguage.ko: '확인', AppLanguage.en: 'Understood', AppLanguage.ja: '確認', AppLanguage.zhCn: '确定', AppLanguage.zhTw: '確定',
  });
  String get doNotShowAgain => _t({
    AppLanguage.ko: '다시 보지 않기', AppLanguage.en: 'Do not show again', AppLanguage.ja: '次回から表示しない', AppLanguage.zhCn: '不再显示', AppLanguage.zhTw: '不再顯示',
  });

  // ─── [인게임 특수 이벤트 텍스트] ───
  String get eventMatchStart => _t({
    AppLanguage.ko: '🎴 새 라운드 시작!', AppLanguage.en: '🎴 New Round Started!', AppLanguage.ja: '🎴 新しいラウンドが開始！', AppLanguage.zhCn: '🎴 新回合开始！', AppLanguage.zhTw: '🎴 新回合開始！'
  });
  String eventChongtong(int month) => _t({
    AppLanguage.ko: '🎆 총통! $month월 4장! 즉시 승리! (+3점)', AppLanguage.en: '🎆 Chongtong! All 4 cards of Month $month! Instant Win! (+3)', AppLanguage.ja: '🎆 総統！$month月の4枚！即勝利！(+3点)', AppLanguage.zhCn: '🎆 总统！$month月4张！直接获胜！(+3分)', AppLanguage.zhTw: '🎆 總統！$month月4張！直接獲勝！(+3分)'
  });
  String get eventSkillShuffle => _t({
    AppLanguage.ko: '🌪️ [덱 셔플] 발동! 필드와 덱을 재배열했습니다!', AppLanguage.en: '🌪️ [Deck Shuffle] Reordered field and deck!', AppLanguage.ja: '🌪️ [デッキシャッフル] 発動！場と山札を再配置！', AppLanguage.zhCn: '🌪️ [洗牌] 发动！重新排列场上和牌堆！', AppLanguage.zhTw: '🌪️ [洗牌] 發動！重新排列場上和牌堆！'
  });
  String get eventSkillSniperSuccess => _t({
    AppLanguage.ko: '🎯 [스나이퍼] 발동! 상대 피 1장을 탈취했습니다!', AppLanguage.en: '🎯 [Sniper] Stole 1 Junk from opponent!', AppLanguage.ja: '🎯 [スナイパー] 相手のカスを1枚奪取！', AppLanguage.zhCn: '🎯 [狙击] 夺取对手1张皮！', AppLanguage.zhTw: '🎯 [狙擊] 奪取對手1張皮！'
  });
  String get eventSkillSniperFail => _t({
    AppLanguage.ko: '🎯 [스나이퍼] 뺏을 수 있는 피가 없습니다!', AppLanguage.en: '🎯 [Sniper] Opponent has no Junk to steal!', AppLanguage.ja: '🎯 [スナイパー] 奪えるカスがありません！', AppLanguage.zhCn: '🎯 [狙击] 对方没有可以夺取的皮！', AppLanguage.zhTw: '🎯 [狙擊] 對方沒有可以奪取的皮！'
  });
  String get eventSkillJoker => _t({
    AppLanguage.ko: '🃏 [전용 조커] 강력한 다음 턴을 준비합니다!', AppLanguage.en: '🃏 [Joker] Preparing a powerful next turn!', AppLanguage.ja: '🃏 [ジョーカー] 強力な次のターンを準備します！', AppLanguage.zhCn: '🃏 [小丑] 准备强力的下一回合！', AppLanguage.zhTw: '🃏 [小丑] 準備強力的下一回合！'
  });

  String eventPlayerMatch(String name, int count) => _t({
    AppLanguage.ko: '✅ $name → $count장 획득!', AppLanguage.en: '✅ $name → Captured $count!', AppLanguage.ja: '✅ $name → $count枚獲得！', AppLanguage.zhCn: '✅ $name → 获得 $count 张！', AppLanguage.zhTw: '✅ $name → 獲得 $count 張！'
  });
  String eventPlayerMiss(String name) => _t({
    AppLanguage.ko: '❌ $name → 매칭 실패', AppLanguage.en: '❌ $name → Missed', AppLanguage.ja: '❌ $name → マッチ失敗', AppLanguage.zhCn: '❌ $name → 匹配失败', AppLanguage.zhTw: '❌ $name → 匹配失敗'
  });
  String eventAiMatch(String name, int count) => _t({
    AppLanguage.ko: '🤖 AI: $name → $count장 획득', AppLanguage.en: '🤖 AI: $name → Captured $count', AppLanguage.ja: '🤖 AI: $name → $count枚獲得', AppLanguage.zhCn: '🤖 AI: $name → 获得 $count 张', AppLanguage.zhTw: '🤖 AI: $name → 獲得 $count 張'
  });
  String eventAiMiss(String name) => _t({
    AppLanguage.ko: '🤖 AI: $name', AppLanguage.en: '🤖 AI: $name', AppLanguage.ja: '🤖 AI: $name', AppLanguage.zhCn: '🤖 AI: $name', AppLanguage.zhTw: '🤖 AI: $name'
  });

  String get eventAiStop => _t({
    AppLanguage.ko: '🤖 AI: 스톱! 라운드 종료!', AppLanguage.en: '🤖 AI: STOP! Round ended!', AppLanguage.ja: '🤖 AI: ストップ！ ラウンド終了！', AppLanguage.zhCn: '🤖 AI: 停！ 回合结束！', AppLanguage.zhTw: '🤖 AI: 停！ 回合結束！'
  });
  String eventAiGo(int count) => _t({
    AppLanguage.ko: '🤖🔥 AI: 고! ×$count', AppLanguage.en: '🤖🔥 AI: GO! ×$count', AppLanguage.ja: '🤖🔥 AI: ゴー！ ×$count', AppLanguage.zhCn: '🤖🔥 AI: 继续！ ×$count', AppLanguage.zhTw: '🤖🔥 AI: 繼續！ ×$count'
  });
  String eventAiBomb(int month) => _t({
    AppLanguage.ko: '🤖💣 AI: $month월 폭탄!', AppLanguage.en: '🤖💣 AI: Bomb of Month $month!', AppLanguage.ja: '🤖💣 AI: $month月の爆弾！', AppLanguage.zhCn: '🤖💣 AI: $month月炸弹！', AppLanguage.zhTw: '🤖💣 AI: $month月炸彈！'
  });

  String get eventDraw => _t({
    AppLanguage.ko: '🤝 무승부! (나가리)', AppLanguage.en: '🤝 Draw! (Nagari)', AppLanguage.ja: '🤝 引き分け！ (流れ)', AppLanguage.zhCn: '🤝 平局！ (流局)', AppLanguage.zhTw: '🤝 平局！ (流局)'
  });
  String get aiTalkDraw => _t({
    AppLanguage.ko: '무승부다!', AppLanguage.en: 'It\'s a draw!', AppLanguage.ja: '引き分けだな！', AppLanguage.zhCn: '平局！', AppLanguage.zhTw: '平局！'
  });
  String get eventRewardGoBak => _t({
    AppLanguage.ko: '🎉 상대 고박(Go-Bak)! 점수 2배 획득!', AppLanguage.en: '🎉 Opponent Go-Bak! Double points!', AppLanguage.ja: '🎉 相手の被り(ドクバク)！得点2倍！', AppLanguage.zhCn: '🎉 对手反加(Go-Bak)！分数乘2！', AppLanguage.zhTw: '🎉 對手反加(Go-Bak)！分數乘2！'
  });
  String eventWin(String amount) => _t({
    AppLanguage.ko: '🏆 승리! +$amount', AppLanguage.en: '🏆 Win! +$amount', AppLanguage.ja: '🏆 勝利！ +$amount', AppLanguage.zhCn: '🏆 获胜！ +$amount', AppLanguage.zhTw: '🏆 獲勝！ +$amount'
  });
  String get eventPenaltyGoBak => _t({
    AppLanguage.ko: '💀 유저 고박(Go-Bak)! 벌금 2배!', AppLanguage.en: '💀 Player Go-Bak! Double penalty!', AppLanguage.ja: '💀 自分の被り(ドクバク)！罰金2倍！', AppLanguage.zhCn: '💀 玩家反加(Go-Bak)！罚款乘2！', AppLanguage.zhTw: '💀 玩家反加(Go-Bak)！罰款乘2！'
  });
  String eventLose(String amount) => _t({
    AppLanguage.ko: '💀 패배... -$amount', AppLanguage.en: '💀 Lose... -$amount', AppLanguage.ja: '💀 敗北... -$amount', AppLanguage.zhCn: '💀 失败... -$amount', AppLanguage.zhTw: '💀 失敗... -$amount'
  });

  String get eventPlayerGo => _t({
    AppLanguage.ko: '🔥 고! 선언! (배율 증가)', AppLanguage.en: '🔥 GO! Declared! (Multiplier increased)', AppLanguage.ja: '🔥 ゴー！ 宣言！ (倍率増加)', AppLanguage.zhCn: '🔥 继续！宣告！ (倍率增加)', AppLanguage.zhTw: '🔥 繼續！宣告！ (倍率增加)'
  });
  String get eventPlayerStop => _t({
    AppLanguage.ko: '🛑 스톱! 라운드 종료!', AppLanguage.en: '🛑 STOP! Round ended!', AppLanguage.ja: '🛑 ストップ！ ラウンド終了！', AppLanguage.zhCn: '🛑 停！ 回合结束！', AppLanguage.zhTw: '🛑 停！ 回合結束！'
  });
  String eventPlayerBomb(int month, bool stolen) => _t({
    AppLanguage.ko: '💣 폭탄! $month월 3장 일괄 획득!' + (stolen ? ' + 상대 피 빼앗기!' : ''),
    AppLanguage.en: '💣 Bomb! Captured 3 of Month $month!' + (stolen ? ' + Stole Junk!' : ''),
    AppLanguage.ja: '💣 爆弾！$month月3枚獲得！' + (stolen ? ' + 相手のカス奪う！' : ''),
    AppLanguage.zhCn: '💣 炸弹！一次获得3张$month月！' + (stolen ? ' + 夺取对手皮！' : ''),
    AppLanguage.zhTw: '💣 炸彈！一次獲得3張$month月！' + (stolen ? ' + 奪取對手皮！' : '')
  });

  String get eventPpeok => _t({
    AppLanguage.ko: '💥 뻑! 아무것도 먹지 못하고 바닥에 쌓인다!', AppLanguage.en: '💥 Ppeok! Cards stack on the board!', AppLanguage.ja: '💥 ション！何も取れずに場に積まれる！', AppLanguage.zhCn: '💥 爆！什么都没吃到，留在场上！', AppLanguage.zhTw: '💥 爆！什麼都沒吃到，留在場上！'
  });
  String get eventDoublePpeok => _t({
    AppLanguage.ko: '🔥🔥 연뻑!! +3점 획득!', AppLanguage.en: '🔥🔥 Double Ppeok!! +3 points!', AppLanguage.ja: '🔥🔥 連続ション！！ +3点獲得！', AppLanguage.zhCn: '🔥🔥 连爆！！ +3分！', AppLanguage.zhTw: '🔥🔥 連爆！！ +3分！'
  });
  String get eventTriplePpeok => _t({
    AppLanguage.ko: '🔥🔥🔥 삼뻑!!! 즉시 승리!!!', AppLanguage.en: '🔥🔥🔥 Triple Ppeok!!! Instant Win!!!', AppLanguage.ja: '🔥🔥🔥 3連続ション！！！ 即勝利！！！', AppLanguage.zhCn: '🔥🔥🔥 三连爆！！！ 直接获胜！！！', AppLanguage.zhTw: '🔥🔥🔥 三連爆！！！ 直接獲勝！！！'
  });
  String eventChok(bool stolen) => _t({
    AppLanguage.ko: '✌️ 쪽!' + (stolen ? ' 상대 피 빼앗기!' : ''),
    AppLanguage.en: '✌️ Chok!' + (stolen ? ' Stole Junk!' : ''),
    AppLanguage.ja: '✌️ チュッ！' + (stolen ? ' 相手のカス奪う！' : ''),
    AppLanguage.zhCn: '✌️ 吻！' + (stolen ? ' 夺取对手皮！' : ''),
    AppLanguage.zhTw: '✌️ 吻！' + (stolen ? ' 奪取對手皮！' : '')
  });
  String eventChokSweep(bool stolen) => _t({
    AppLanguage.ko: '✌️🌊 쪽 + 쓸!' + (stolen ? ' 상대 피 빼앗기!' : ''),
    AppLanguage.en: '✌️🌊 Chok + Sweep!' + (stolen ? ' Stole Junk!' : ''),
    AppLanguage.ja: '✌️🌊 チュッ + 掃き！' + (stolen ? ' 相手のカス奪う！' : ''),
    AppLanguage.zhCn: '✌️🌊 吻 + 清空！' + (stolen ? ' 夺取对手皮！' : ''),
    AppLanguage.zhTw: '✌️🌊 吻 + 清空！' + (stolen ? ' 奪取對手皮！' : '')
  });
  String eventTadak(bool stolen) => _t({
    AppLanguage.ko: '⚡ 따닥!' + (stolen ? ' 상대 피 빼앗기!' : ''),
    AppLanguage.en: '⚡ Tadak!' + (stolen ? ' Stole Junk!' : ''),
    AppLanguage.ja: '⚡ タダック(連鎖)！' + (stolen ? ' 相手のカス奪う！' : ''),
    AppLanguage.zhCn: '⚡ 连打！' + (stolen ? ' 夺取对手皮！' : ''),
    AppLanguage.zhTw: '⚡ 連打！' + (stolen ? ' 奪取對手皮！' : '')
  });
  String eventSweep(bool stolen) => _t({
    AppLanguage.ko: '🌊 쓸!' + (stolen ? ' 상대 피 빼앗기!' : ''),
    AppLanguage.en: '🌊 Sweep!' + (stolen ? ' Stole Junk!' : ''),
    AppLanguage.ja: '🌊 掃き！' + (stolen ? ' 相手のカス奪う！' : ''),
    AppLanguage.zhCn: '🌊 清空！' + (stolen ? ' 夺取对手皮！' : ''),
    AppLanguage.zhTw: '🌊 清空！' + (stolen ? ' 奪取對手皮！' : '')
  });
  String eventPpeokEat(bool stolen) => _t({
    AppLanguage.ko: '💥 뻑 먹기! 4장 일괄 획득!' + (stolen ? ' + 피 빼앗기!' : ''),
    AppLanguage.en: '💥 Ppeok Eat! Captured all 4!' + (stolen ? ' + Stole Junk!' : ''),
    AppLanguage.ja: '💥 ション食い！4枚一括獲得！' + (stolen ? ' + カス奪う！' : ''),
    AppLanguage.zhCn: '💥 吃爆！全数获得！' + (stolen ? ' + 夺取皮！' : ''),
    AppLanguage.zhTw: '💥 吃爆！全數獲得！' + (stolen ? ' + 奪取皮！' : '')
  });
  String eventSelfPpeok(bool stolen) => _t({
    AppLanguage.ko: '💥🔥 자뻑 먹기! 4장 획득!' + (stolen ? ' + 피 빼앗기!' : ''),
    AppLanguage.en: '💥🔥 Self Ppeok! Captured all 4!' + (stolen ? ' + Stole Junk!' : ''),
    AppLanguage.ja: '💥🔥 自爆食い！4枚獲得！' + (stolen ? ' + カス奪う！' : ''),
    AppLanguage.zhCn: '💥🔥 自吃爆！全数获得！' + (stolen ? ' + 夺取皮！' : ''),
    AppLanguage.zhTw: '💥🔥 自吃爆！全數獲得！' + (stolen ? ' + 奪取皮！' : '')
  });
  String eventGeneralBomb(bool stolen) => _t({
    AppLanguage.ko: '💣 폭탄!' + (stolen ? ' 상대 피 빼앗기!' : ''),
    AppLanguage.en: '💣 Bomb!' + (stolen ? ' Stole Junk!' : ''),
    AppLanguage.ja: '💣 爆弾！' + (stolen ? ' 相手のカス奪う！' : ''),
    AppLanguage.zhCn: '💣 炸弹！' + (stolen ? ' 夺取对手皮！' : ''),
    AppLanguage.zhTw: '💣 炸彈！' + (stolen ? ' 奪取對手皮！' : '')
  });

  // ─── [AI 캐릭터 대사 번역] ───
  String getAiDialogue(String aiId, String situation, List<String> defaultKoLines) {
    if (defaultKoLines.isEmpty) return '...';
    final int index = DateTime.now().millisecond % defaultKoLines.length;

    if (language == AppLanguage.ko) return defaultKoLines[index];

    Map<String, Map<String, List<String>>>? targetMap;
    switch (language) {
      case AppLanguage.en: targetMap = aiDialoguesEn; break;
      case AppLanguage.ja: targetMap = aiDialoguesJa; break;
      case AppLanguage.zhCn:
      case AppLanguage.zhTw: targetMap = aiDialoguesZh; break;
      default: return defaultKoLines[index];
    }

    if (targetMap != null) {
      final charMap = targetMap[aiId];
      if (charMap != null) {
        final situationLines = charMap[situation];
        if (situationLines != null && situationLines.isNotEmpty) {
          return situationLines[index % situationLines.length];
        }
      }
    }
    return defaultKoLines[index];
  }

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
    'S-001': { AppLanguage.en: 'Exclusive Joker', AppLanguage.ja: '専用ジョーカー', AppLanguage.zhCn: '专属鬼牌', AppLanguage.zhTw: '專屬鬼牌' },
    'S-002': { AppLanguage.en: 'Sniper', AppLanguage.ja: 'スナイパー', AppLanguage.zhCn: '狙击手', AppLanguage.zhTw: '狙擊手' },
    'S-003': { AppLanguage.en: 'Deck Shuffle', AppLanguage.ja: 'デッキシャッフル', AppLanguage.zhCn: '牌库洗牌', AppLanguage.zhTw: '牌庫洗牌' },
    'P-001': { AppLanguage.en: 'Gwang Scanner', AppLanguage.ja: '光スキャナー', AppLanguage.zhCn: '光牌扫描仪', AppLanguage.zhTw: '光牌掃描儀' },
    'P-002': { AppLanguage.en: 'Safety Helmet', AppLanguage.ja: '安全ヘルメット', AppLanguage.zhCn: '安全头盔', AppLanguage.zhTw: '安全頭盔' },
    'P-003': { AppLanguage.en: 'Jackpot Ticket', AppLanguage.ja: 'ジャックポットチケット', AppLanguage.zhCn: '头奖入场券', AppLanguage.zhTw: '頭獎入場券' },
    'T-001': { AppLanguage.en: 'Regular Customer', AppLanguage.ja: '常連客', AppLanguage.zhCn: '常客', AppLanguage.zhTw: '常客' },
    'T-002': { AppLanguage.en: 'Mental Guard', AppLanguage.ja: 'メンタルガード', AppLanguage.zhCn: '精神护盾', AppLanguage.zhTw: '精神護盾' },
  };

  static const Map<String, Map<AppLanguage, String>> _itemDescs = {
    'S-001': {
      AppLanguage.en: 'Treats the next played deck card as a Joker, allowing you to capture any unmatched card from the field.',
      AppLanguage.ja: '次に出す山札のカードをジョーカーとして扱い、場の好きなカードを1枚確実に獲得します。',
      AppLanguage.zhCn: '将下一张打出的牌库牌视为鬼牌，让你能夺取场上一张任意卡牌。',
      AppLanguage.zhTw: '將下一張打出的牌庫牌視為鬼牌，讓你能奪取場上一張任意卡牌。',
    },
    'S-002': {
      AppLanguage.en: 'Forcefully steal one specific card from the opponent\'s captured area. (Once per game)',
      AppLanguage.ja: '相手が獲得したカードの中から、好きなカードを1枚強制的に奪い取ります。(1ゲーム1回)',
      AppLanguage.zhCn: '强制从对手得分区夺取特定的一张牌。（每局限一次）',
      AppLanguage.zhTw: '強制從對手得分區奪取特定的一張牌。（每局限一次）',
    },
    'S-003': {
      AppLanguage.en: 'Collect all cards on the field, shuffle them back into the deck, and redeploy them.',
      AppLanguage.ja: '場に出ているカードをすべて回収し、山札と混ぜて再配置します。',
      AppLanguage.zhCn: '将场上所有卡牌收回，与牌库重新洗牌并再次布阵。',
      AppLanguage.zhTw: '將場上所有卡牌收回，與牌庫重新洗牌並再次布陣。',
    },
    'P-001': {
      AppLanguage.en: 'Significantly increases the chance of Gwang (Bright) cards appearing in the initial deal.',
      AppLanguage.ja: '最初のカード配布時、手札や場に光(光札)が配置される確率が大幅に増加します。',
      AppLanguage.zhCn: '开局发牌时，大幅增加光牌出现在手牌或场上的几率。',
      AppLanguage.zhTw: '開局發牌時，大幅增加光牌出現在手牌或場上的機率。',
    },
    'P-002': {
      AppLanguage.en: 'Prevents Game Over once per round by covering the basic bet amount if you go bankrupt.',
      AppLanguage.ja: '該当ラウンドで破産(資金不足)した際、1回だけ基本賭け金をカバーし、ゲームオーバーを防ぎします。',
      AppLanguage.zhCn: '在该回合破产时，仅限一次为你垫付基础赌注，防止游戏结束。',
      AppLanguage.zhTw: '在該回合破破時，僅限一次為你墊付基礎賭注，防止遊戲結束。',
    },
    'P-003': {
      AppLanguage.en: 'A high-risk, high-return item that multiplies your final score by 5 times if you win the round.',
      AppLanguage.ja: 'ラウンド勝利時に、最終スコアを無条件に5倍にするハイリスクハイリターンアイテム。',
      AppLanguage.zhCn: '高风险高回报的消耗品，获胜时直接将最终得分乘以5倍。',
      AppLanguage.zhTw: '高風險高回報的消耗品，獲勝時直接將最終得分乘以5倍。',
    },
    'T-001': {
      AppLanguage.en: 'Adds an extra 0.5x to 2x multiplier when you declare 3 Go or more.',
      AppLanguage.ja: 'ゲーム中、3Go以上を宣言した場合、最終倍率に0.5倍〜2倍を追加します。',
      AppLanguage.zhCn: '宣告 3 Go 以上时，最终倍率会随机额外增加 0.5 到 2 倍。',
      AppLanguage.zhTw: '宣告 3 Go 以上時，最終倍率會隨機額外增加 0.5 到 2 倍。',
    },
    'T-002': {
      AppLanguage.en: 'Defends once against the opponent capturing your cards when you make a Ppeok (Bomb-fail).',
      AppLanguage.ja: 'プレイヤーがションを出した時、相手がそのカードを食べるのを最初の1回だけ防ぎます。',
      AppLanguage.zhCn: '当你打出爆（Ppeok）时，首次防御对手将其吃掉。',
      AppLanguage.zhTw: '當你打出爆（Ppeok）時，首次防禦對手將其吃掉。',
    },
  };

  /// 번역 헬퍼
  String _t(Map<AppLanguage, String> translations) {
    return translations[language] ?? translations[AppLanguage.en] ?? '';
  }
}
