/// K-Poker -- 시너지 정의 (태그 기반 9개 + 숨겨진 3개)
///
/// 아이템 태그 조합에 따라 자동 발동하는 보너스 효과.
/// SynergyEvaluator에서 런타임 판정에 사용.
library;

import 'item_catalog.dart';

// ═══════════════════════════════════════
//  SynergyDef 모델
// ═══════════════════════════════════════

class SynergyDef {
  final String id;
  final String name;
  final String nameKo;
  final ItemTag requiredTag;
  final int requiredCount;
  final int bonusChips;
  final double bonusMult;
  final double bonusXMult;    // 1.0 = 없음
  final String description;
  final String descKo;

  const SynergyDef({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.requiredTag,
    required this.requiredCount,
    this.bonusChips = 0,
    this.bonusMult = 0.0,
    this.bonusXMult = 1.0,
    required this.description,
    required this.descKo,
  });
}

/// 숨겨진 시너지 (특정 아이템 ID 조합)
class HiddenSynergyDef {
  final String id;
  final String name;
  final String nameKo;
  final List<String> requiredItemIds;
  final int bonusChips;
  final double bonusMult;
  final double bonusXMult;    // 1.0 = 없음
  final String description;
  final String descKo;

  const HiddenSynergyDef({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.requiredItemIds,
    this.bonusChips = 0,
    this.bonusMult = 0.0,
    this.bonusXMult = 1.0,
    required this.description,
    required this.descKo,
  });
}

// ═══════════════════════════════════════
//  태그 기반 시너지 (9개)
// ═══════════════════════════════════════

const List<SynergyDef> tagSynergies = [
  // 1. syn_gwang_master
  SynergyDef(
    id: 'syn_gwang_master',
    name: 'Bright Master',
    nameKo: '광 마스터',
    requiredTag: ItemTag.gwang,
    requiredCount: 3,
    bonusChips: 3,
    description: '+3 points from gwang synergy',
    descKo: '광 태그 3개: +3점',
  ),

  // 2. syn_animal_kingdom
  SynergyDef(
    id: 'syn_animal_kingdom',
    name: 'Animal Kingdom',
    nameKo: '동물 왕국',
    requiredTag: ItemTag.animal,
    requiredCount: 3,
    bonusMult: 0.5,
    description: '+0.5 mult per animal captured',
    descKo: '동물 태그 3개: 동물 캡처 +0.5 mult',
  ),

  // 3. syn_ribbon_collector
  SynergyDef(
    id: 'syn_ribbon_collector',
    name: 'Ribbon Collector',
    nameKo: '띠 컬렉터',
    requiredTag: ItemTag.ribbon,
    requiredCount: 3,
    bonusChips: 1,
    description: 'Ribbon score even with less than 5',
    descKo: '띠 태그 3개: 띠 5장 미만도 1점',
  ),

  // 4. syn_junk_empire
  SynergyDef(
    id: 'syn_junk_empire',
    name: 'Junk Empire',
    nameKo: '피 제국',
    requiredTag: ItemTag.junk,
    requiredCount: 3,
    description: 'Junk threshold reduced by additional 1',
    descKo: '피 태그 3개: 필요장수 추가 -1',
  ),

  // 5. syn_gamblers_path
  SynergyDef(
    id: 'syn_gamblers_path',
    name: "Gambler's Path",
    nameKo: '승부사의 길',
    requiredTag: ItemTag.go,
    requiredCount: 2,
    bonusMult: 0.3,
    description: '+0.3 mult starting from 1-Go',
    descKo: 'Go 태그 2개: 1고부터 +0.3 mult',
  ),

  // 6. syn_demolition
  SynergyDef(
    id: 'syn_demolition',
    name: 'Demolition Expert',
    nameKo: '폭파 전문가',
    requiredTag: ItemTag.bomb,
    requiredCount: 2,
    bonusChips: 2,
    description: '+2 chips per sweep/bomb',
    descKo: '폭탄 태그 2개: 쓸/폭탄 +2 chips',
  ),

  // 7. syn_tycoon
  SynergyDef(
    id: 'syn_tycoon',
    name: 'Tycoon',
    nameKo: '재벌',
    requiredTag: ItemTag.economy,
    requiredCount: 3,
    description: 'Additional 10% shop discount',
    descKo: '경제 태그 3개: 추가 할인 10%',
  ),

  // 8. syn_fortress
  SynergyDef(
    id: 'syn_fortress',
    name: 'Fortress',
    nameKo: '요새',
    requiredTag: ItemTag.defense,
    requiredCount: 3,
    description: 'Bak penalty reduced by 25%',
    descKo: '방어 태그 3개: 박 패널티 -25%',
  ),

  // 9. syn_tazza_school
  SynergyDef(
    id: 'syn_tazza_school',
    name: 'Tazza School',
    nameKo: '타짜 유파',
    requiredTag: ItemTag.tazza,
    requiredCount: 3,
    bonusChips: 5,
    description: '+5 chips per card manipulation',
    descKo: '타짜 태그 3개: 카드 조작 +5 chips',
  ),
];

// ═══════════════════════════════════════
//  숨겨진 시너지 (특정 아이템 ID 조합, 3개)
// ═══════════════════════════════════════

const List<HiddenSynergyDef> hiddenSynergies = [
  // 10. syn_invincible
  HiddenSynergyDef(
    id: 'syn_invincible',
    name: 'Invincible',
    nameKo: '천하무적',
    requiredItemIds: ['ps_legendary_tazza', 'ps_gamblers_instinct'],
    bonusXMult: 1.5,
    description: 'All effects +50%',
    descKo: '전설의 타짜 + 도박꾼의 직감: 모든 효과 +50%',
  ),

  // 11. syn_moonlight
  HiddenSynergyDef(
    id: 'syn_moonlight',
    name: 'Moonlight Dominion',
    nameKo: '월광 지배',
    requiredItemIds: ['ps_full_moon', 'x_ogwang_crown'],
    description: '+10G per bright captured',
    descKo: '보름달 + 오광의 왕관: 광 캡처마다 +10G',
  ),

  // 12. syn_junk_lord
  HiddenSynergyDef(
    id: 'syn_junk_lord',
    name: 'Junk Lord',
    nameKo: '피의 군주',
    requiredItemIds: ['ps_junk_collector', 'ps_double_junk'],
    bonusXMult: 2.0,
    description: 'Junk score x2.0',
    descKo: '피 수집가 + 쌍피 마스터: 피 점수 x2.0',
  ),
];

// ═══════════════════════════════════════
//  헬퍼 함수
// ═══════════════════════════════════════

/// 보유 아이템 ID 목록에서 활성 태그 시너지를 계산
List<SynergyDef> getActiveTagSynergies(List<String> ownedItemIds) {
  // 보유 아이템의 태그별 카운트 집계
  final Map<ItemTag, int> tagCounts = {};
  for (final id in ownedItemIds) {
    final item = findCatalogItem(id);
    if (item == null) continue;
    for (final tag in item.tags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }
  }

  return tagSynergies
      .where((syn) => (tagCounts[syn.requiredTag] ?? 0) >= syn.requiredCount)
      .toList();
}

/// 보유 아이템 ID 목록에서 활성 숨겨진 시너지를 계산
List<HiddenSynergyDef> getActiveHiddenSynergies(List<String> ownedItemIds) {
  final idSet = ownedItemIds.toSet();
  return hiddenSynergies
      .where((syn) => syn.requiredItemIds.every(idSet.contains))
      .toList();
}
