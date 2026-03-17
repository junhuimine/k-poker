// 🎴 K-Poker — 타짜 기술 & 부적 정의 (32기술 + 7부적)

/// 기술 등급
enum SkillRarity { common, rare, epic, legendary }

/// 기술 카테고리
enum SkillCategory { foundation, scaling, explosion, economy }

/// 기술 효과 타입
enum SkillEffectType {
  pointsBonus,
  multiplierAdd,
  multiplierMult,
  ruleBend,
  cardManipulate,
  drawBonus,
  economy,
}

/// 기술 정의
class SkillDef {
  final String id;
  final String name;
  final String nameKo;
  final String description;
  final String emoji;
  final SkillRarity rarity;
  final SkillCategory category;
  final SkillEffectType effectType;
  final int shopCost;

  const SkillDef({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.description,
    this.emoji = '🃏',
    required this.rarity,
    required this.category,
    required this.effectType,
    required this.shopCost,
  });
}

/// 부적 정의
class Talisman {
  final String id;
  final String name;
  final String nameKo;
  final String description;
  final String emoji;
  final int shopCost;

  const Talisman({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.description,
    this.emoji = '🧿',
    required this.shopCost,
  });
}

// ═══════════════════════════════════════
//  🟢 COMMON (12개) — 기반 기술
// ═══════════════════════════════════════

final List<SkillDef> allSkills = [
  // ── Common ──
  const SkillDef(
    id: 'spring_breeze', name: 'Spring Breeze', nameKo: '봄바람', emoji: '🌸',
    description: '1~3월 매칭 시 점수 +2',
    rarity: SkillRarity.common, category: SkillCategory.foundation,
    effectType: SkillEffectType.pointsBonus, shopCost: 3,
  ),
  const SkillDef(
    id: 'autumn_harvest', name: 'Autumn Harvest', nameKo: '가을걷이', emoji: '🍂',
    description: '9~11월 매칭 시 점수 +2',
    rarity: SkillRarity.common, category: SkillCategory.foundation,
    effectType: SkillEffectType.pointsBonus, shopCost: 3,
  ),
  const SkillDef(
    id: 'junk_collector', name: 'Junk Collector', nameKo: '피 수집가', emoji: '🗑️',
    description: '피 점수 필요 장수 10→8장',
    rarity: SkillRarity.common, category: SkillCategory.foundation,
    effectType: SkillEffectType.ruleBend, shopCost: 4,
  ),
  const SkillDef(
    id: 'keen_eye', name: 'Keen Eye', nameKo: '눈썰미', emoji: '👁️',
    description: '매 턴 덱 맨 위 카드 미리보기',
    rarity: SkillRarity.common, category: SkillCategory.foundation,
    effectType: SkillEffectType.ruleBend, shopCost: 3,
  ),
  const SkillDef(
    id: 'quick_wrist', name: 'Quick Wrist', nameKo: '빠른 손목', emoji: '✋',
    description: '매칭 실패 시 카드 손으로 복귀 (1회/판)',
    rarity: SkillRarity.common, category: SkillCategory.foundation,
    effectType: SkillEffectType.cardManipulate, shopCost: 3,
  ),
  const SkillDef(
    id: 'skilled_hand', name: 'Skilled Hand', nameKo: '노련한 손', emoji: '🤲',
    description: '매칭 시 15% 확률 추가 뒤집기',
    rarity: SkillRarity.common, category: SkillCategory.foundation,
    effectType: SkillEffectType.drawBonus, shopCost: 4,
  ),
  const SkillDef(
    id: 'coin_picker', name: 'Coin Picker', nameKo: '동전 줍기', emoji: '🪙',
    description: '매 판 종료 시 잔여 점수만큼 보너스 금화',
    rarity: SkillRarity.common, category: SkillCategory.economy,
    effectType: SkillEffectType.economy, shopCost: 3,
  ),
  const SkillDef(
    id: 'bottom_deal', name: 'Bottom Deal', nameKo: '밑장 빼기', emoji: '🎴',
    description: '덱 맨 아래 카드도 선택 가능',
    rarity: SkillRarity.common, category: SkillCategory.foundation,
    effectType: SkillEffectType.cardManipulate, shopCost: 4,
  ),
  const SkillDef(
    id: 'card_laundry', name: 'Card Laundry', nameKo: '카드 세탁', emoji: '🧹',
    description: '바닥 카드 1장을 덱으로 되돌리기 (1회/판)',
    rarity: SkillRarity.common, category: SkillCategory.foundation,
    effectType: SkillEffectType.cardManipulate, shopCost: 3,
  ),
  const SkillDef(
    id: 'bluff', name: 'Bluff', nameKo: '허세', emoji: '😏',
    description: '매 판 시작 시 상대 패 2장 엿보기',
    rarity: SkillRarity.common, category: SkillCategory.foundation,
    effectType: SkillEffectType.ruleBend, shopCost: 3,
  ),
  const SkillDef(
    id: 'insurance', name: 'Insurance', nameKo: '보험', emoji: '🛡️',
    description: '나가리 시 소지금 손실 50% 감소',
    rarity: SkillRarity.common, category: SkillCategory.economy,
    effectType: SkillEffectType.economy, shopCost: 4,
  ),
  const SkillDef(
    id: 'junk_luck', name: 'Junk Luck', nameKo: '둑배기', emoji: '🍀',
    description: '피 매칭 시 25% 확률로 추가 피 1장',
    rarity: SkillRarity.common, category: SkillCategory.foundation,
    effectType: SkillEffectType.drawBonus, shopCost: 3,
  ),

  // ── Rare (10개) ──
  const SkillDef(
    id: 'full_moon', name: 'Full Moon', nameKo: '보름달', emoji: '🌕',
    description: '광 먹을 때마다 멀티 +0.5 (영구)',
    rarity: SkillRarity.rare, category: SkillCategory.scaling,
    effectType: SkillEffectType.multiplierAdd, shopCost: 6,
  ),
  const SkillDef(
    id: 'flower_viewing', name: 'Flower Viewing', nameKo: '꽃놀이', emoji: '🌺',
    description: '같은 턴 2회 매칭 → 보너스 +5',
    rarity: SkillRarity.rare, category: SkillCategory.scaling,
    effectType: SkillEffectType.pointsBonus, shopCost: 6,
  ),
  const SkillDef(
    id: 'gambler', name: 'Gambler', nameKo: '승부사', emoji: '🎰',
    description: 'Go 선언마다 멀티 +1 추가 (실패 시 ×0.5)',
    rarity: SkillRarity.rare, category: SkillCategory.scaling,
    effectType: SkillEffectType.multiplierAdd, shopCost: 7,
  ),
  const SkillDef(
    id: 'nagari_memory', name: 'Nagari Memory', nameKo: '나가리의 기억', emoji: '💭',
    description: '이전 판 실패 시 이번 판 멀티 +100%',
    rarity: SkillRarity.rare, category: SkillCategory.scaling,
    effectType: SkillEffectType.multiplierMult, shopCost: 5,
  ),
  const SkillDef(
    id: 'dark_horse', name: 'Dark Horse', nameKo: '다크호스', emoji: '🐴',
    description: '가장 적게 먹은 카테고리 ×2',
    rarity: SkillRarity.rare, category: SkillCategory.explosion,
    effectType: SkillEffectType.multiplierMult, shopCost: 7,
  ),
  const SkillDef(
    id: 'golden_eagle', name: 'Golden Eagle', nameKo: '금독수리', emoji: '🦅',
    description: '동물 5장+ 시 ×1.5 (4장 이하면 -2점)',
    rarity: SkillRarity.rare, category: SkillCategory.scaling,
    effectType: SkillEffectType.multiplierMult, shopCost: 6,
  ),
  const SkillDef(
    id: 'flower_storm', name: 'Flower Storm', nameKo: '꽃보라', emoji: '🌪️',
    description: '매칭 시 30% 확률 인접 월 카드도 흡수',
    rarity: SkillRarity.rare, category: SkillCategory.scaling,
    effectType: SkillEffectType.cardManipulate, shopCost: 8,
  ),
  const SkillDef(
    id: 'tazza_eye', name: "Tazza's Eye", nameKo: '타짜의 눈', emoji: '🔮',
    description: '덱 카드 3장 미리보기 + 순서 선택',
    rarity: SkillRarity.rare, category: SkillCategory.foundation,
    effectType: SkillEffectType.ruleBend, shopCost: 7,
  ),
  const SkillDef(
    id: 'double_junk_master', name: 'Double Junk Master', nameKo: '쌍피 마스터', emoji: '✌️',
    description: '쌍피 먹으면 피 5장으로 계산',
    rarity: SkillRarity.rare, category: SkillCategory.scaling,
    effectType: SkillEffectType.pointsBonus, shopCost: 6,
  ),
  const SkillDef(
    id: 'comeback_king', name: 'Comeback King', nameKo: '역전의 명수', emoji: '👑',
    description: '뒤지고 있을 때 모든 점수 ×1.5 (이기고 있으면 ×0.8)',
    rarity: SkillRarity.rare, category: SkillCategory.scaling,
    effectType: SkillEffectType.multiplierMult, shopCost: 6,
  ),

  // ── Epic (6개) — 룰 왜곡! ──
  const SkillDef(
    id: 'trick', name: 'Trick', nameKo: '속임수', emoji: '🃏',
    description: '바닥 카드 1장 월 변경 (1회/판)',
    rarity: SkillRarity.epic, category: SkillCategory.explosion,
    effectType: SkillEffectType.ruleBend, shopCost: 10,
  ),
  const SkillDef(
    id: 'flower_bomb', name: 'Flower Bomb', nameKo: '꽃폭탄', emoji: '💣',
    description: '손에 3장 같은 월 → 4장 풀매칭 + ×3',
    rarity: SkillRarity.epic, category: SkillCategory.explosion,
    effectType: SkillEffectType.multiplierMult, shopCost: 12,
  ),
  const SkillDef(
    id: 'provoke', name: 'Provoke', nameKo: '도발', emoji: '🔥',
    description: '핸드 3장 공개 → 이 판 ×3 (실패 시 ×0.3)',
    rarity: SkillRarity.epic, category: SkillCategory.explosion,
    effectType: SkillEffectType.multiplierMult, shopCost: 10,
  ),
  const SkillDef(
    id: 'rainy_season', name: 'Rainy Season', nameKo: '장마철', emoji: '🌧️',
    description: '비(12월) 카드가 모든 월과 매칭 가능',
    rarity: SkillRarity.epic, category: SkillCategory.explosion,
    effectType: SkillEffectType.ruleBend, shopCost: 12,
  ),
  const SkillDef(
    id: 'flower_rain', name: 'Flower Rain', nameKo: '꽃비', emoji: '🌸',
    description: '피 먹을 때 40% 확률 띠로 승격',
    rarity: SkillRarity.epic, category: SkillCategory.explosion,
    effectType: SkillEffectType.cardManipulate, shopCost: 11,
  ),
  const SkillDef(
    id: 'ppuk_inducer', name: 'Ppuk Inducer', nameKo: '뻑 유도', emoji: '⚡',
    description: '상대에게 뻑(3장 스택) 강제 (1회/판)',
    rarity: SkillRarity.epic, category: SkillCategory.explosion,
    effectType: SkillEffectType.ruleBend, shopCost: 10,
  ),

  // ── Legendary (4개) — 게임 체인저! ──
  const SkillDef(
    id: 'legendary_tazza', name: 'Legendary Tazza', nameKo: '전설의 타짜', emoji: '⭐',
    description: '모든 멀티플라이어 ×2',
    rarity: SkillRarity.legendary, category: SkillCategory.explosion,
    effectType: SkillEffectType.multiplierMult, shopCost: 20,
  ),
  const SkillDef(
    id: 'gamblers_instinct', name: "Gambler's Instinct", nameKo: '도박꾼의 직감', emoji: '🧠',
    description: '매 턴 카드 2장 중 선택 가능',
    rarity: SkillRarity.legendary, category: SkillCategory.explosion,
    effectType: SkillEffectType.ruleBend, shopCost: 18,
  ),
  const SkillDef(
    id: 'time_rewind', name: 'Time Rewind', nameKo: '시간 되감기', emoji: '⏪',
    description: '판 중 1번, 3턴 전으로 되돌리기',
    rarity: SkillRarity.legendary, category: SkillCategory.explosion,
    effectType: SkillEffectType.ruleBend, shopCost: 20,
  ),
  const SkillDef(
    id: 'flower_lord', name: 'Flower Lord', nameKo: '꽃패의 주인', emoji: '👸',
    description: '먹은 카드의 월을 자유 재배치 (1회/판)',
    rarity: SkillRarity.legendary, category: SkillCategory.explosion,
    effectType: SkillEffectType.cardManipulate, shopCost: 20,
  ),
];

// ═══════════════════════════════════════
//  부적 (7개)
// ═══════════════════════════════════════

final List<Talisman> allTalismans = [
  const Talisman(
    id: 'lucky_coin', name: 'Lucky Coin', nameKo: '행운의 동전', emoji: '🪙',
    description: '상점 가격 20% 할인', shopCost: 5,
  ),
  const Talisman(
    id: 'gambler_soul', name: "Gambler's Soul", nameKo: '승부사의 혼', emoji: '🔥',
    description: '점수가 높을수록 보너스 멀티 (+1%/점)', shopCost: 7,
  ),
  const Talisman(
    id: 'cheater_glove', name: "Cheater's Glove", nameKo: '사기꾼의 장갑', emoji: '🧤',
    description: '매칭 실패 시 카드가 손으로 복귀', shopCost: 6,
  ),
  const Talisman(
    id: 'mountain_charm', name: 'Mountain Charm', nameKo: '고령산 부적', emoji: '⛰️',
    description: '동물 카드 점수 ×1.5', shopCost: 6,
  ),
  const Talisman(
    id: 'moonlight_pouch', name: 'Moonlight Pouch', nameKo: '달빛 주머니', emoji: '🌙',
    description: '매 판 시작 시 랜덤 보너스 카드 1장', shopCost: 7,
  ),
  const Talisman(
    id: 'dokkaebi_mallet', name: 'Dokkaebi Mallet', nameKo: '도깨비 방망이', emoji: '🔨',
    description: '피 먹을 때마다 10% 확률로 금화 +1', shopCost: 5,
  ),
  const Talisman(
    id: 'samshin_granny', name: 'Samshin Granny', nameKo: '삼신할머니', emoji: '👵',
    description: '런 시작 시 랜덤 Common 기술 1개 지급', shopCost: 8,
  ),
];
