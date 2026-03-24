/// 🎴 K-Poker — 신규 3분류 아이템 정의 (상점 시스템용)
///
/// 1. 인게임 액티브 (ActiveSkill)
/// 2. 라운드 장착 소모품 (PreRoundItem)
/// 3. 영구 패시브 부적 (PassiveTalisman)

enum ItemCategory {
  activeSkill,
  preRoundItem,
  passiveTalisman,
}

abstract class BaseItemDef {
  final String id;
  final String name;
  final String nameKo;
  final String description;
  final String emoji;
  final int shopCost; // 가격 (Gold)
  final ItemCategory category;

  const BaseItemDef({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.description,
    required this.emoji,
    required this.shopCost,
    required this.category,
  });
}

// ── 1. 인게임 액티브 (즉발성) ──
class ActiveSkill extends BaseItemDef {
  const ActiveSkill({
    required super.id,
    required super.name,
    required super.nameKo,
    required super.description,
    super.emoji = '⚡',
    required super.shopCost,
  }) : super(category: ItemCategory.activeSkill);
}

// ── 2. 라운드 장착 (일회성) ──
class PreRoundItem extends BaseItemDef {
  const PreRoundItem({
    required super.id,
    required super.name,
    required super.nameKo,
    required super.description,
    super.emoji = '🛡️',
    required super.shopCost,
  }) : super(category: ItemCategory.preRoundItem);
}

// ── 3. 영구 부적 (지속성) ──
class PassiveTalisman extends BaseItemDef {
  const PassiveTalisman({
    required super.id,
    required super.name,
    required super.nameKo,
    required super.description,
    super.emoji = '📜',
    required super.shopCost,
  }) : super(category: ItemCategory.passiveTalisman);
}


// ═══════════════════════════════════════
// K-Poker 정식 출시 아이템 목록
// ═══════════════════════════════════════

final List<ActiveSkill> shopActiveSkills = [
  const ActiveSkill(
    id: 'S-001',
    name: 'Exclusive Joker',
    nameKo: '전용 조커',
    emoji: '🃏',
    description: '현재 턴에 내는 덱 카드가 조커로 취급되어, 바닥의 짝이 없는 원하는 카드 1장을 확정 획득합니다.',
    shopCost: 200,
  ),
  const ActiveSkill(
    id: 'S-002',
    name: 'Sniper',
    nameKo: '스나이퍼',
    emoji: '🎯',
    description: '종류(피, 광, 열끗 등)와 무관하게 상대방이 획득한 카드 중 원하는 카드 1장을 강제로 빼앗아 옵니다. (1게임 1회)',
    shopCost: 500,
  ),
  const ActiveSkill(
    id: 'S-003',
    name: 'Deck Shuffle',
    nameKo: '덱 셔플',
    emoji: '🌪️',
    description: '현재 바닥에 깔린 필드 카드를 모두 걷어 덱과 다시 섞은 후 재배열합니다.',
    shopCost: 150,
  ),
];

final List<PreRoundItem> shopPreRoundItems = [
  const PreRoundItem(
    id: 'P-001',
    name: 'Gwang Scanner',
    nameKo: '광 스캐너',
    emoji: '🔦',
    description: '시작 시 딜링 단계에서 핸드나 필드에 광(光) 카드가 배치될 확률이 대폭 증가합니다.',
    shopCost: 100,
  ),
  const PreRoundItem(
    id: 'P-002',
    name: 'Safety Helmet',
    nameKo: '안전모',
    emoji: '🪖',
    description: '해당 라운드에서 파산(돈 부족) 시, 1회 한정으로 기본 판돈을 커버해 주어 게임 오버를 방지합니다.',
    shopCost: 300,
  ),
  const PreRoundItem(
    id: 'P-003',
    name: 'Jackpot Ticket',
    nameKo: '잭팟 티켓',
    emoji: '🎫',
    description: '해당 라운드 승리 시 시스템이 계산한 최종 점수에 무조건 5배를 추가로 곱해주는 하이리스크 하이리턴 소모품입니다.',
    shopCost: 1000,
  ),
];

final List<PassiveTalisman> shopPassiveTalismans = [
  const PassiveTalisman(
    id: 'T-001',
    name: 'Regular Customer',
    nameKo: '단골손님',
    emoji: '🤝',
    description: '게임 중 3고(Go) 이상 선언 시, 최종 배율에 0.5배 ~ 2배를 추가로 곱해줍니다.',
    shopCost: 1500,
  ),
  const PassiveTalisman(
    id: 'T-002',
    name: 'Mental Guard',
    nameKo: '멘탈 가드',
    emoji: '🛡️',
    description: '플레이어가 뻑을 냈을 때, 상대가 해당 뻑 카드를 먹지 못하게 첫 1회어 방어합니다.',
    shopCost: 800,
  ),
];

/// ID로 아이템을 검색하는 헬퍼 함수
BaseItemDef? findItemById(String id) {
  for (var s in shopActiveSkills) if (s.id == id) return s;
  for (var p in shopPreRoundItems) if (p.id == id) return p;
  for (var t in shopPassiveTalismans) if (t.id == id) return t;
  return null;
}
