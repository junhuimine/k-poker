/// 🎴 K-Poker — 48장 화투 카드 데이터
/// 
/// Single Source of Truth. 이 파일만 수정하면 전체 게임에 반영.

import '../models/card_def.dart';

/// 48장 카드 전체 정의
final List<CardDef> allCards = [
  // ─── 1월 (松 소나무) ───
  const CardDef(id: 'm01_bright', month: 1, grade: CardGrade.bright, name: 'Pine Crane', nameKo: '송학'),
  const CardDef(id: 'm01_ribbon', month: 1, grade: CardGrade.ribbon, name: 'Pine Red Ribbon', nameKo: '송 홍단', ribbonType: RibbonType.red),
  const CardDef(id: 'm01_junk_1', month: 1, grade: CardGrade.junk, name: 'Pine Junk 1', nameKo: '송 피 1'),
  const CardDef(id: 'm01_junk_2', month: 1, grade: CardGrade.junk, name: 'Pine Junk 2', nameKo: '송 피 2'),

  // ─── 2월 (梅 매화) ───
  const CardDef(id: 'm02_animal', month: 2, grade: CardGrade.animal, name: 'Plum Warbler', nameKo: '매조', isBird: true),
  const CardDef(id: 'm02_ribbon', month: 2, grade: CardGrade.ribbon, name: 'Plum Red Ribbon', nameKo: '매 홍단', ribbonType: RibbonType.red),
  const CardDef(id: 'm02_junk_1', month: 2, grade: CardGrade.junk, name: 'Plum Junk 1', nameKo: '매 피 1'),
  const CardDef(id: 'm02_junk_2', month: 2, grade: CardGrade.junk, name: 'Plum Junk 2', nameKo: '매 피 2'),

  // ─── 3월 (桜 벚꽃) ───
  const CardDef(id: 'm03_bright', month: 3, grade: CardGrade.bright, name: 'Cherry Curtain', nameKo: '벚꽃 막걸리'),
  const CardDef(id: 'm03_ribbon', month: 3, grade: CardGrade.ribbon, name: 'Cherry Red Ribbon', nameKo: '벚 홍단', ribbonType: RibbonType.red),
  const CardDef(id: 'm03_junk_1', month: 3, grade: CardGrade.junk, name: 'Cherry Junk 1', nameKo: '벚 피 1'),
  const CardDef(id: 'm03_junk_2', month: 3, grade: CardGrade.junk, name: 'Cherry Junk 2', nameKo: '벚 피 2'),

  // ─── 4월 (藤 등나무) ───
  const CardDef(id: 'm04_animal', month: 4, grade: CardGrade.animal, name: 'Wisteria Cuckoo', nameKo: '등 두견새', isBird: true),
  const CardDef(id: 'm04_ribbon', month: 4, grade: CardGrade.ribbon, name: 'Wisteria Grass Ribbon', nameKo: '등 초단', ribbonType: RibbonType.grass),
  const CardDef(id: 'm04_junk_1', month: 4, grade: CardGrade.junk, name: 'Wisteria Junk 1', nameKo: '등 피 1'),
  const CardDef(id: 'm04_junk_2', month: 4, grade: CardGrade.junk, name: 'Wisteria Junk 2', nameKo: '등 피 2'),

  // ─── 5월 (菖 창포) ───
  const CardDef(id: 'm05_animal', month: 5, grade: CardGrade.animal, name: 'Iris Bridge', nameKo: '창포 다리'),
  const CardDef(id: 'm05_ribbon', month: 5, grade: CardGrade.ribbon, name: 'Iris Grass Ribbon', nameKo: '창포 초단', ribbonType: RibbonType.grass),
  const CardDef(id: 'm05_junk_1', month: 5, grade: CardGrade.junk, name: 'Iris Junk 1', nameKo: '창포 피 1'),
  const CardDef(id: 'm05_junk_2', month: 5, grade: CardGrade.junk, name: 'Iris Junk 2', nameKo: '창포 피 2'),

  // ─── 6월 (牡 모란) ───
  const CardDef(id: 'm06_animal', month: 6, grade: CardGrade.animal, name: 'Peony Butterfly', nameKo: '모란 나비'),
  const CardDef(id: 'm06_ribbon', month: 6, grade: CardGrade.ribbon, name: 'Peony Blue Ribbon', nameKo: '모란 청단', ribbonType: RibbonType.blue),
  const CardDef(id: 'm06_junk_1', month: 6, grade: CardGrade.junk, name: 'Peony Junk 1', nameKo: '모란 피 1'),
  const CardDef(id: 'm06_junk_2', month: 6, grade: CardGrade.junk, name: 'Peony Junk 2', nameKo: '모란 피 2'),

  // ─── 7월 (萩 싸리) ───
  const CardDef(id: 'm07_animal', month: 7, grade: CardGrade.animal, name: 'Bush Clover Boar', nameKo: '싸리 멧돼지'),
  const CardDef(id: 'm07_ribbon', month: 7, grade: CardGrade.ribbon, name: 'Bush Clover Grass Ribbon', nameKo: '싸리 초단', ribbonType: RibbonType.grass),
  const CardDef(id: 'm07_junk_1', month: 7, grade: CardGrade.junk, name: 'Bush Clover Junk 1', nameKo: '싸리 피 1'),
  const CardDef(id: 'm07_junk_2', month: 7, grade: CardGrade.junk, name: 'Bush Clover Junk 2', nameKo: '싸리 피 2'),

  // ─── 8월 (芒 억새) ───
  const CardDef(id: 'm08_bright', month: 8, grade: CardGrade.bright, name: 'Susuki Moon', nameKo: '억새 달'),
  const CardDef(id: 'm08_animal', month: 8, grade: CardGrade.animal, name: 'Susuki Geese', nameKo: '억새 기러기', isBird: true),
  const CardDef(id: 'm08_junk_1', month: 8, grade: CardGrade.junk, name: 'Susuki Junk 1', nameKo: '억새 피 1'),
  const CardDef(id: 'm08_junk_2', month: 8, grade: CardGrade.junk, name: 'Susuki Junk 2', nameKo: '억새 피 2'),

  // ─── 9월 (菊 국화) ───
  const CardDef(id: 'm09_double', month: 9, grade: CardGrade.animal, name: 'Chrysanthemum Cup', nameKo: '국화 술잔', doubleJunk: true),
  const CardDef(id: 'm09_ribbon', month: 9, grade: CardGrade.ribbon, name: 'Chrysanthemum Blue Ribbon', nameKo: '국화 청단', ribbonType: RibbonType.blue),
  const CardDef(id: 'm09_junk_1', month: 9, grade: CardGrade.junk, name: 'Chrysanthemum Junk 1', nameKo: '국화 피 1'),
  const CardDef(id: 'm09_junk_2', month: 9, grade: CardGrade.junk, name: 'Chrysanthemum Junk 2', nameKo: '국화 피 2'),

  // ─── 10월 (楓 단풍) ───
  const CardDef(id: 'm10_animal', month: 10, grade: CardGrade.animal, name: 'Maple Deer', nameKo: '단풍 사슴'),
  const CardDef(id: 'm10_ribbon', month: 10, grade: CardGrade.ribbon, name: 'Maple Blue Ribbon', nameKo: '단풍 청단', ribbonType: RibbonType.blue),
  const CardDef(id: 'm10_junk_1', month: 10, grade: CardGrade.junk, name: 'Maple Junk 1', nameKo: '단풍 피 1'),
  const CardDef(id: 'm10_junk_2', month: 10, grade: CardGrade.junk, name: 'Maple Junk 2', nameKo: '단풍 피 2'),

  // ─── 11월 (桐 오동) ───
  const CardDef(id: 'm11_bright', month: 11, grade: CardGrade.bright, name: 'Paulownia Phoenix', nameKo: '오동 봉황'),
  const CardDef(id: 'm11_junk_1', month: 11, grade: CardGrade.junk, name: 'Paulownia Junk 1', nameKo: '오동 피 1'),
  const CardDef(id: 'm11_junk_2', month: 11, grade: CardGrade.junk, name: 'Paulownia Junk 2', nameKo: '오동 피 2'),
  const CardDef(id: 'm11_double', month: 11, grade: CardGrade.junk, name: 'Paulownia Double Junk', nameKo: '오동 쌍피', doubleJunk: true),

  // ─── 12월 (柳 버들 / 비) ───
  const CardDef(id: 'm12_bright', month: 12, grade: CardGrade.bright, name: 'Willow Rain', nameKo: '비'),
  const CardDef(id: 'm12_animal', month: 12, grade: CardGrade.animal, name: 'Willow Swallow', nameKo: '버들 제비'),
  const CardDef(id: 'm12_ribbon', month: 12, grade: CardGrade.ribbon, name: 'Willow Ribbon', nameKo: '버들 띠', ribbonType: RibbonType.plain),
  const CardDef(id: 'm12_double', month: 12, grade: CardGrade.junk, name: 'Willow Double Junk', nameKo: '버들 쌍피', doubleJunk: true),

  // ─── 보너스 쌍피 (조커) 2장 ───
  const CardDef(id: 'bonus_1', month: 13, grade: CardGrade.junk, name: 'Bonus Double Junk 1', nameKo: '보너스 쌍피 1', doubleJunk: true, isBonus: true),
  const CardDef(id: 'bonus_2', month: 13, grade: CardGrade.junk, name: 'Bonus Double Junk 2', nameKo: '보너스 쌍피 2', doubleJunk: true, isBonus: true),
];

/// 총 카드 수
const int totalCards = 50;

/// 딜링 규칙 (50장: 바닥 8, 플레이어 10, 상대 10, 덱 22)
const int handSize = 10;
const int fieldSize = 8;

/// 특정 월의 카드 4장 가져오기
List<CardDef> getCardsByMonth(int month) => allCards.where((c) => c.month == month).toList();

/// 광 카드 5장
List<CardDef> getBrightCards() => allCards.where((c) => c.grade == CardGrade.bright).toList();

/// 고도리 새 카드 3장
List<CardDef> getBirdCards() => allCards.where((c) => c.isBird).toList();

/// 빨간 띠 카드 (1~3월)
List<CardDef> getRedRibbonCards() => allCards.where((c) => c.ribbonType == RibbonType.red).toList();

/// 파란 띠 카드 (6,9,10월)
List<CardDef> getBlueRibbonCards() => allCards.where((c) => c.ribbonType == RibbonType.blue).toList();

/// 초단 카드 (4,5,7월)
List<CardDef> getGrassRibbonCards() => allCards.where((c) => c.ribbonType == RibbonType.grass).toList();
