/// K-Poker -- 풀 로그라이크 상점 아이템 카탈로그 (51개)
///
/// 모든 아이템의 정적 정의를 한 곳에서 관리.
/// 패시브(29), 부적(9), 액티브(6), 소모품(6), 비밀(1)
library;

// ═══════════════════════════════════════
//  Enums
// ═══════════════════════════════════════

enum Rarity { common, rare, epic, legendary, secret }

enum ItemSlot {
  activeInGame,    // 인게임 수동 발동 (소모성)
  passiveAlways,   // 보유 시 자동 발동
  talisman,        // 런 전체 영구 효과
  consumableRound, // 1라운드 소모품
}

enum ItemTag {
  gwang,
  animal,
  ribbon,
  junk,
  go,
  bomb,
  economy,
  defense,
  attack,
  tazza,
  season,
}

// ═══════════════════════════════════════
//  ItemDef 모델
// ═══════════════════════════════════════

class ItemDef {
  final String id;
  final String name;        // 영어 이름
  final String nameKo;      // 한국어 이름
  final String description; // 영어 설명
  final String descKo;      // 한국어 설명
  final String emoji;
  final Rarity rarity;
  final ItemSlot slot;
  final List<ItemTag> tags;
  final int baseCost;
  // 수치 효과
  final int chips;
  final double mult;
  final double xMult;        // 1.0 = 없음
  final Map<String, dynamic> params; // 아이템별 고유 파라미터

  const ItemDef({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.description,
    required this.descKo,
    required this.emoji,
    required this.rarity,
    required this.slot,
    required this.tags,
    required this.baseCost,
    this.chips = 0,
    this.mult = 0.0,
    this.xMult = 1.0,
    this.params = const {},
  });
}

// ═══════════════════════════════════════
//  전체 아이템 카탈로그 (51개)
// ═══════════════════════════════════════

const List<ItemDef> itemCatalog = [
  // ─────────────────────────────────────
  //  패시브 (29개) — passiveAlways
  // ─────────────────────────────────────

  // 1. ps_spring_breeze
  ItemDef(
    id: 'ps_spring_breeze',
    name: 'Spring Breeze',
    nameKo: '봄바람',
    description: '+3 chips per card captured in months 1-3',
    descKo: '1~3월 장당 +3 chips',
    emoji: '🌸',
    rarity: Rarity.common,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.season],
    baseCost: 80,
    chips: 3,
    params: {'months': [1, 2, 3]},
  ),

  // 2. ps_autumn_harvest
  ItemDef(
    id: 'ps_autumn_harvest',
    name: 'Autumn Harvest',
    nameKo: '가을걷이',
    description: '+3 chips per card captured in months 9-11',
    descKo: '9~11월 장당 +3 chips',
    emoji: '🍂',
    rarity: Rarity.common,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.season],
    baseCost: 80,
    chips: 3,
    params: {'months': [9, 10, 11]},
  ),

  // 3. ps_junk_collector
  ItemDef(
    id: 'ps_junk_collector',
    name: 'Junk Collector',
    nameKo: '피 수집가',
    description: 'Junk scoring threshold reduced from 10 to 8',
    descKo: '피 필요장수 10 -> 8',
    emoji: '🗑️',
    rarity: Rarity.common,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.junk],
    baseCost: 100,
    params: {'junkThreshold': 8},
  ),

  // 4. ps_coin_picker
  ItemDef(
    id: 'ps_coin_picker',
    name: 'Coin Picker',
    nameKo: '동전 줍기',
    description: '+5G per remaining score point on victory',
    descKo: '승리 시 잔여점수당 +5G',
    emoji: '🪙',
    rarity: Rarity.common,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.economy],
    baseCost: 90,
    params: {'goldPerPoint': 5},
  ),

  // 5. ps_insurance
  ItemDef(
    id: 'ps_insurance',
    name: 'Insurance',
    nameKo: '보험',
    description: 'Nagari loss reduced by 50%',
    descKo: '나가리 손실 50% 감소',
    emoji: '🛡️',
    rarity: Rarity.common,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.defense],
    baseCost: 100,
    params: {'lossReduction': 0.5},
  ),

  // 6. ps_junk_luck
  ItemDef(
    id: 'ps_junk_luck',
    name: 'Junk Luck',
    nameKo: '둑배기',
    description: '25% chance to gain +1 junk on junk capture',
    descKo: '피 캡처 25% 확률 추가 피 1장',
    emoji: '🍀',
    rarity: Rarity.common,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.junk],
    baseCost: 90,
    params: {'chance': 0.25, 'bonusJunk': 1},
  ),

  // 7. ps_skilled_hand
  ItemDef(
    id: 'ps_skilled_hand',
    name: 'Skilled Hand',
    nameKo: '노련한 손',
    description: '15% chance for an extra flip on matching',
    descKo: '매칭 15% 확률 추가 뒤집기',
    emoji: '🤲',
    rarity: Rarity.common,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.tazza],
    baseCost: 100,
    chips: 10,
    mult: 1.0,
    params: {'chance': 0.15},
  ),

  // 8. ps_bluff
  ItemDef(
    id: 'ps_bluff',
    name: 'Bluff',
    nameKo: '허세',
    description: 'Reveal 2 opponent cards at round start',
    descKo: '판 시작 시 상대 패 2장 공개',
    emoji: '😏',
    rarity: Rarity.common,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.attack],
    baseCost: 80,
    params: {'revealCount': 2},
  ),

  // 9. ps_summer_heat
  ItemDef(
    id: 'ps_summer_heat',
    name: 'Summer Heat',
    nameKo: '여름 열기',
    description: '+3 chips per card captured in months 6-8',
    descKo: '6~8월 장당 +3 chips',
    emoji: '☀️',
    rarity: Rarity.common,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.season],
    baseCost: 80,
    chips: 3,
    params: {'months': [6, 7, 8]},
  ),

  // 10. ps_winter_chill
  ItemDef(
    id: 'ps_winter_chill',
    name: 'Winter Chill',
    nameKo: '겨울 한파',
    description: 'December cards +8 chips',
    descKo: '12월 카드 +8 chips',
    emoji: '❄️',
    rarity: Rarity.common,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.season],
    baseCost: 80,
    chips: 8,
    params: {'months': [12]},
  ),

  // 11. ps_full_moon
  ItemDef(
    id: 'ps_full_moon',
    name: 'Full Moon',
    nameKo: '보름달',
    description: '+0.5 mult per bright card captured',
    descKo: '광 캡처마다 +0.5 mult',
    emoji: '🌕',
    rarity: Rarity.rare,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.gwang],
    baseCost: 180,
    mult: 0.5,
    params: {'perBright': 0.5},
  ),

  // 12. ps_golden_eagle
  ItemDef(
    id: 'ps_golden_eagle',
    name: 'Golden Eagle',
    nameKo: '금독수리',
    description: 'x1.5 if you have 5+ animal cards',
    descKo: '동물 5장+ x1.5',
    emoji: '🦅',
    rarity: Rarity.rare,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.animal],
    baseCost: 200,
    xMult: 1.5,
    params: {'threshold': 5},
  ),

  // 13. ps_gambler
  ItemDef(
    id: 'ps_gambler',
    name: 'Gambler',
    nameKo: '승부사',
    description: '+1 mult per Go declaration',
    descKo: 'Go 선언마다 +1 mult',
    emoji: '🎰',
    rarity: Rarity.rare,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.go],
    baseCost: 220,
    mult: 1.0,
    params: {'multPerGo': 1.0},
  ),

  // 14. ps_nagari_memory
  ItemDef(
    id: 'ps_nagari_memory',
    name: 'Nagari Memory',
    nameKo: '나가리의 기억',
    description: 'x2.0 if you lost the previous round',
    descKo: '이전 판 패배 시 x2.0',
    emoji: '💭',
    rarity: Rarity.rare,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.defense],
    baseCost: 180,
    xMult: 2.0,
    params: {'requirePreviousLoss': true},
  ),

  // 15. ps_dark_horse
  ItemDef(
    id: 'ps_dark_horse',
    name: 'Dark Horse',
    nameKo: '다크호스',
    description: 'x1.5 to the category with fewest captured cards',
    descKo: '가장 적게 먹은 카테고리 x1.5',
    emoji: '🐴',
    rarity: Rarity.rare,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.animal],
    baseCost: 200,
    xMult: 1.5,
  ),

  // 16. ps_double_junk
  ItemDef(
    id: 'ps_double_junk',
    name: 'Double Junk Master',
    nameKo: '쌍피 마스터',
    description: 'Double junk counts as 5 junk cards',
    descKo: '쌍피 피 5장으로 계산',
    emoji: '✌️',
    rarity: Rarity.rare,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.junk],
    baseCost: 160,
    params: {'doubleJunkValue': 5},
  ),

  // 17. ps_comeback_king
  ItemDef(
    id: 'ps_comeback_king',
    name: 'Comeback King',
    nameKo: '역전의 명수',
    description: 'x1.5 when behind, x0.8 when winning',
    descKo: '뒤지고 있을 때 x1.5, 이기면 x0.8',
    emoji: '👑',
    rarity: Rarity.rare,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.defense],
    baseCost: 180,
    xMult: 1.5,
    params: {'behindXMult': 1.5, 'aheadXMult': 0.8},
  ),

  // 18. ps_flower_viewing
  ItemDef(
    id: 'ps_flower_viewing',
    name: 'Flower Viewing',
    nameKo: '꽃놀이',
    description: '+8 chips on double match in the same turn',
    descKo: '같은 턴 2회 매칭 +8 chips',
    emoji: '🌺',
    rarity: Rarity.rare,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.season],
    baseCost: 160,
    chips: 8,
    params: {'requiredMatches': 2},
  ),

  // 19. ps_ribbon_weaver
  ItemDef(
    id: 'ps_ribbon_weaver',
    name: 'Ribbon Weaver',
    nameKo: '띠 장인',
    description: '+2 mult if you have 4+ ribbon cards',
    descKo: '띠 4장+ +2 mult',
    emoji: '🎀',
    rarity: Rarity.rare,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.ribbon],
    baseCost: 170,
    mult: 2.0,
    params: {'threshold': 4},
  ),

  // 20. ps_sweep_master
  ItemDef(
    id: 'ps_sweep_master',
    name: 'Sweep Master',
    nameKo: '쓸어먹기 달인',
    description: '+0.3 mult per sweep',
    descKo: '쓸 횟수당 +0.3 mult',
    emoji: '🧹',
    rarity: Rarity.rare,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.bomb],
    baseCost: 190,
    mult: 0.3,
    params: {'multPerSweep': 0.3},
  ),

  // 21. ps_rainy_season
  ItemDef(
    id: 'ps_rainy_season',
    name: 'Rainy Season',
    nameKo: '장마철',
    description: 'December cards match with all months',
    descKo: '12월 카드가 모든 월과 매칭',
    emoji: '🌧️',
    rarity: Rarity.epic,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.tazza],
    baseCost: 350,
    params: {'wildcardMonth': 12},
  ),

  // 22. ps_flower_rain
  ItemDef(
    id: 'ps_flower_rain',
    name: 'Flower Rain',
    nameKo: '꽃비',
    description: '40% chance to upgrade junk capture to ribbon',
    descKo: '피 캡처 40% 확률 띠 승격',
    emoji: '🌸',
    rarity: Rarity.epic,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.junk, ItemTag.ribbon],
    baseCost: 380,
    params: {'upgradeChance': 0.4},
  ),

  // 23. ps_flower_bomb
  ItemDef(
    id: 'ps_flower_bomb',
    name: 'Flower Bomb',
    nameKo: '꽃폭탄',
    description: 'x3.0 when hand has 3 cards of same month',
    descKo: '같은 월 3장 핸드 시 x3.0',
    emoji: '💣',
    rarity: Rarity.epic,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.bomb],
    baseCost: 400,
    xMult: 3.0,
    params: {'sameMonthThreshold': 3},
  ),

  // 24. ps_provoke
  ItemDef(
    id: 'ps_provoke',
    name: 'Provoke',
    nameKo: '도발',
    description: 'Reveal hand to opponent for x2.0 score',
    descKo: '핸드 공개 → 점수 x2.0',
    emoji: '🔥',
    rarity: Rarity.epic,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.attack, ItemTag.go],
    baseCost: 350,
    xMult: 2.0,
    params: {'xMult': 2.0},
  ),

  // 25. ps_ppuk_inducer
  ItemDef(
    id: 'ps_ppuk_inducer',
    name: 'Ppuk Inducer',
    nameKo: '뻑 유도',
    description: 'Steal 2 extra junk when opponent ppuks (once/round)',
    descKo: '상대 뻑 시 추가 피 2장 탈취 (1회/판)',
    emoji: '⚡',
    rarity: Rarity.epic,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.attack],
    baseCost: 320,
    params: {'bonusSteal': 2, 'usesPerRound': 1},
  ),

  // 26. ps_legendary_tazza
  ItemDef(
    id: 'ps_legendary_tazza',
    name: 'Legendary Tazza',
    nameKo: '전설의 타짜',
    description: 'All mult x2.0',
    descKo: '모든 mult x2.0',
    emoji: '⭐',
    rarity: Rarity.legendary,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.tazza],
    baseCost: 800,
    xMult: 2.0,
  ),

  // 27. ps_gamblers_instinct
  ItemDef(
    id: 'ps_gamblers_instinct',
    name: "Gambler's Instinct",
    nameKo: '도박꾼의 직감',
    description: 'Choose 1 of 2 cards from deck each turn',
    descKo: '덱 2장 중 1장 선택',
    emoji: '🧠',
    rarity: Rarity.legendary,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.tazza],
    baseCost: 700,
    params: {'choiceCount': 2},
  ),

  // 28. ps_time_rewind
  ItemDef(
    id: 'ps_time_rewind',
    name: 'Time Rewind',
    nameKo: '시간 되감기',
    description: 'Rewind 3 turns once per round',
    descKo: '3턴 전 되돌리기 1회/판',
    emoji: '⏪',
    rarity: Rarity.legendary,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.tazza],
    baseCost: 750,
    params: {'rewindTurns': 3, 'usesPerRound': 1},
  ),

  // 29. ps_flower_lord
  ItemDef(
    id: 'ps_flower_lord',
    name: 'Flower Lord',
    nameKo: '꽃패의 주인',
    description: 'Rearrange captured card months once per round',
    descKo: '카드 월 재배치 1회/판',
    emoji: '👸',
    rarity: Rarity.legendary,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.gwang, ItemTag.ribbon],
    baseCost: 800,
    params: {'usesPerRound': 1},
  ),

  // ─────────────────────────────────────
  //  부적 (9개) — talisman
  // ─────────────────────────────────────

  // 30. t_lucky_coin
  ItemDef(
    id: 't_lucky_coin',
    name: 'Lucky Coin',
    nameKo: '행운의 동전',
    description: '20% shop discount',
    descKo: '상점 20% 할인',
    emoji: '🪙',
    rarity: Rarity.rare,
    slot: ItemSlot.talisman,
    tags: [ItemTag.economy],
    baseCost: 250,
    params: {'discount': 0.2},
  ),

  // 31. t_gambler_soul
  ItemDef(
    id: 't_gambler_soul',
    name: "Gambler's Soul",
    nameKo: '승부사의 혼',
    description: '+0.5~2.0 mult bonus on 3+ Go',
    descKo: '3고+ 배율 +0.5~2.0',
    emoji: '🔥',
    rarity: Rarity.rare,
    slot: ItemSlot.talisman,
    tags: [ItemTag.go],
    baseCost: 300,
    params: {'minGoCount': 3, 'minMult': 0.5, 'maxMult': 2.0},
  ),

  // 32. t_mountain_charm
  ItemDef(
    id: 't_mountain_charm',
    name: 'Mountain Charm',
    nameKo: '고령산 부적',
    description: 'Animal card score x1.5',
    descKo: '동물 점수 x1.5',
    emoji: '⛰️',
    rarity: Rarity.rare,
    slot: ItemSlot.talisman,
    tags: [ItemTag.animal],
    baseCost: 280,
    xMult: 1.5,
  ),

  // 33. t_moonlight_pouch
  ItemDef(
    id: 't_moonlight_pouch',
    name: 'Moonlight Pouch',
    nameKo: '달빛 주머니',
    description: 'Random bonus card at round start',
    descKo: '판 시작 랜덤 보너스 카드',
    emoji: '🌙',
    rarity: Rarity.epic,
    slot: ItemSlot.talisman,
    tags: [ItemTag.gwang],
    baseCost: 400,
    params: {'bonusCards': 1},
  ),

  // 34. t_dokkaebi_mallet
  ItemDef(
    id: 't_dokkaebi_mallet',
    name: 'Dokkaebi Mallet',
    nameKo: '도깨비 방망이',
    description: '10% chance to gain +2G per junk capture',
    descKo: '피 캡처마다 10% +2G',
    emoji: '🔨',
    rarity: Rarity.rare,
    slot: ItemSlot.talisman,
    tags: [ItemTag.economy],
    baseCost: 220,
    params: {'chance': 0.1, 'goldBonus': 2},
  ),

  // 35. t_samshin_granny
  ItemDef(
    id: 't_samshin_granny',
    name: 'Samshin Granny',
    nameKo: '삼신할머니',
    description: 'Random common passive at run start',
    descKo: '런 시작 랜덤 Common 패시브',
    emoji: '👵',
    rarity: Rarity.epic,
    slot: ItemSlot.talisman,
    tags: [ItemTag.tazza],
    baseCost: 450,
    params: {'giftRarity': 'common'},
  ),

  // 36. t_cheaters_glove
  ItemDef(
    id: 't_cheaters_glove',
    name: "Cheater's Glove",
    nameKo: '사기꾼의 장갑',
    description: 'Card returns to hand on match failure',
    descKo: '매칭 실패 시 카드 복귀',
    emoji: '🧤',
    rarity: Rarity.rare,
    slot: ItemSlot.talisman,
    tags: [ItemTag.defense],
    baseCost: 260,
  ),

  // 37. t_golden_mat
  ItemDef(
    id: 't_golden_mat',
    name: 'Golden Mat',
    nameKo: '황금 화투판',
    description: '+15% gold on victory',
    descKo: '승리 시 골드 +15%',
    emoji: '✨',
    rarity: Rarity.epic,
    slot: ItemSlot.talisman,
    tags: [ItemTag.economy],
    baseCost: 500,
    params: {'goldBonus': 0.15},
  ),

  // 38. t_gwangbak_shield
  ItemDef(
    id: 't_gwangbak_shield',
    name: 'Gwangbak Shield',
    nameKo: '광박 방패',
    description: 'Nullifies gwangbak penalty',
    descKo: '광박 무효화',
    emoji: '🛡️',
    rarity: Rarity.rare,
    slot: ItemSlot.talisman,
    tags: [ItemTag.defense, ItemTag.gwang],
    baseCost: 300,
  ),

  // ─────────────────────────────────────
  //  액티브 (6개) — activeInGame
  // ─────────────────────────────────────

  // 39. a_joker
  ItemDef(
    id: 'a_joker',
    name: 'Exclusive Joker',
    nameKo: '전용 조커',
    description: 'Capture any 1 card from the field',
    descKo: '아무 카드 1장 확정 획득',
    emoji: '🃏',
    rarity: Rarity.rare,
    slot: ItemSlot.activeInGame,
    tags: [ItemTag.tazza],
    baseCost: 200,
  ),

  // 40. a_sniper
  ItemDef(
    id: 'a_sniper',
    name: 'Sniper',
    nameKo: '스나이퍼',
    description: 'Steal 1 card from opponent',
    descKo: '상대 카드 1장 탈취',
    emoji: '🎯',
    rarity: Rarity.epic,
    slot: ItemSlot.activeInGame,
    tags: [ItemTag.attack],
    baseCost: 400,
  ),

  // 41. a_shuffle
  ItemDef(
    id: 'a_shuffle',
    name: 'Deck Shuffle',
    nameKo: '덱 셔플',
    description: 'Reshuffle field + deck',
    descKo: '필드+덱 재셔플',
    emoji: '🌪️',
    rarity: Rarity.common,
    slot: ItemSlot.activeInGame,
    tags: [ItemTag.tazza],
    baseCost: 120,
  ),

  // 42. a_trick
  ItemDef(
    id: 'a_trick',
    name: 'Trick',
    nameKo: '속임수',
    description: 'Change month of 1 field card',
    descKo: '바닥 카드 1장 월 변경',
    emoji: '🃏',
    rarity: Rarity.epic,
    slot: ItemSlot.activeInGame,
    tags: [ItemTag.tazza],
    baseCost: 350,
  ),

  // 43. a_keen_eye
  ItemDef(
    id: 'a_keen_eye',
    name: 'Keen Eye',
    nameKo: '눈썰미',
    description: 'View top 3 deck cards and reorder',
    descKo: '덱 위 3장 확인+순서변경',
    emoji: '👁️',
    rarity: Rarity.common,
    slot: ItemSlot.activeInGame,
    tags: [ItemTag.tazza],
    baseCost: 100,
  ),

  // 44. a_card_laundry
  ItemDef(
    id: 'a_card_laundry',
    name: 'Card Laundry',
    nameKo: '카드 세탁',
    description: 'Return 1 field card to deck',
    descKo: '바닥 카드 1장 덱으로 반환',
    emoji: '🧼',
    rarity: Rarity.common,
    slot: ItemSlot.activeInGame,
    tags: [ItemTag.tazza],
    baseCost: 90,
  ),

  // ─────────────────────────────────────
  //  소모품 (6개) — consumableRound
  // ─────────────────────────────────────

  // 45. c_gwang_scanner
  ItemDef(
    id: 'c_gwang_scanner',
    name: 'Gwang Scanner',
    nameKo: '광 스캐너',
    description: 'Increase bright card placement odds on dealing',
    descKo: '딜링 시 광 배치 확률 증가',
    emoji: '🔦',
    rarity: Rarity.rare,
    slot: ItemSlot.consumableRound,
    tags: [ItemTag.gwang],
    baseCost: 150,
  ),

  // 46. c_safety_helmet
  ItemDef(
    id: 'c_safety_helmet',
    name: 'Safety Helmet',
    nameKo: '안전모',
    description: 'Prevent bankruptcy once',
    descKo: '파산 1회 방어',
    emoji: '🪖',
    rarity: Rarity.rare,
    slot: ItemSlot.consumableRound,
    tags: [ItemTag.defense],
    baseCost: 250,
  ),

  // 47. c_jackpot_ticket
  ItemDef(
    id: 'c_jackpot_ticket',
    name: 'Jackpot Ticket',
    nameKo: '잭팟 티켓',
    description: 'x5 final score on victory',
    descKo: '승리 시 x5',
    emoji: '🎫',
    rarity: Rarity.epic,
    slot: ItemSlot.consumableRound,
    tags: [ItemTag.economy],
    baseCost: 500,
    xMult: 5.0,
  ),

  // 48. c_pi_magnet
  ItemDef(
    id: 'c_pi_magnet',
    name: 'Pi Magnet',
    nameKo: '피 자석',
    description: 'Gain extra junk on junk capture this round',
    descKo: '라운드 중 피 캡처 시 추가 피',
    emoji: '🧲',
    rarity: Rarity.common,
    slot: ItemSlot.consumableRound,
    tags: [ItemTag.junk],
    baseCost: 80,
    params: {'bonusJunk': 1},
  ),

  // 49. c_ribbon_polish
  ItemDef(
    id: 'c_ribbon_polish',
    name: 'Ribbon Polish',
    nameKo: '띠 광택제',
    description: 'Double ribbon score this round',
    descKo: '라운드 띠 점수 2배',
    emoji: '💅',
    rarity: Rarity.rare,
    slot: ItemSlot.consumableRound,
    tags: [ItemTag.ribbon],
    baseCost: 200,
    xMult: 2.0,
  ),

  // 50. c_bomb_fuse
  ItemDef(
    id: 'c_bomb_fuse',
    name: 'Bomb Fuse',
    nameKo: '폭탄 도화선',
    description: 'x4 on bomb/chongtong this round',
    descKo: '폭탄/총통 시 x4',
    emoji: '💥',
    rarity: Rarity.epic,
    slot: ItemSlot.consumableRound,
    tags: [ItemTag.bomb],
    baseCost: 350,
    xMult: 4.0,
  ),

  // ─────────────────────────────────────
  //  비밀 (1개) — passiveAlways + secret
  // ─────────────────────────────────────

  // 51. x_ogwang_crown
  ItemDef(
    id: 'x_ogwang_crown',
    name: "Five Brights Crown",
    nameKo: '오광의 왕관',
    description: 'x2.0 with 3+ bright cards. Unlock: achieve Ogwang once',
    descKo: '광 3장+ x2.0 / 해금조건: 오광 1회',
    emoji: '👑',
    rarity: Rarity.secret,
    slot: ItemSlot.passiveAlways,
    tags: [ItemTag.gwang],
    baseCost: 600,
    xMult: 2.0,
    params: {'brightThreshold': 3, 'unlockCondition': 'ogwang_once'},
  ),
];

// ═══════════════════════════════════════
//  헬퍼 함수
// ═══════════════════════════════════════

/// ID로 아이템 검색
ItemDef? findCatalogItem(String id) {
  for (final item in itemCatalog) {
    if (item.id == id) return item;
  }
  // 레거시 ID 호환 매핑
  return _legacyIdMap[id];
}

/// 슬롯별 필터
List<ItemDef> getItemsBySlot(ItemSlot slot) =>
    itemCatalog.where((i) => i.slot == slot).toList();

/// 희귀도별 필터
List<ItemDef> getItemsByRarity(Rarity rarity) =>
    itemCatalog.where((i) => i.rarity == rarity).toList();

/// 태그별 필터
List<ItemDef> getItemsByTag(ItemTag tag) =>
    itemCatalog.where((i) => i.tags.contains(tag)).toList();

// ═══════════════════════════════════════
//  레거시 ID -> 신규 ID 매핑
// ═══════════════════════════════════════

/// 기존 아이템 ID를 신규 카탈로그로 변환 (세이브 호환)
const Map<String, String> legacyIdToNewId = {
  'S-001': 'a_joker',
  'S-002': 'a_sniper',
  'S-003': 'a_shuffle',
  'P-001': 'c_gwang_scanner',
  'P-002': 'c_safety_helmet',
  'P-003': 'c_jackpot_ticket',
  'T-001': 't_gambler_soul',
  'T-002': 't_cheaters_glove',
};

/// 레거시 ID -> ItemDef 매핑 (findCatalogItem 폴백용)
final Map<String, ItemDef> _legacyIdMap = {
  for (final entry in legacyIdToNewId.entries)
    entry.key: itemCatalog.firstWhere((i) => i.id == entry.value),
};

/// 레거시 ID를 신규 ID로 변환 (없으면 원본 반환)
String migrateItemId(String id) => legacyIdToNewId[id] ?? id;
