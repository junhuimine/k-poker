---
name: Score Breakdown i18n Missing Keys
description: 10 score breakdown keys from ScoreCalculator were missing in uiTexts, causing raw key names to leak into UI
type: project
---

ScoreCalculator produces ScoreEntry objects with keys like `item_bonus_chips`, `talisman_gwangbak_shield`, `consumable_ribbon_polish`, etc. These are rendered in the score breakdown overlay via `strings.ui(entry.key)`. Since the keys were not in the uiTexts map, `ui()` returned the raw key string.

**Why:** Score entries are created in engine/score_calculator.dart but the i18n keys must be registered in i18n/app_strings.dart uiTexts map.

**How to apply:** When adding new ScoreEntry keys in the calculator, always add corresponding entries to the uiTexts map in app_strings.dart with all 10 language translations.

Fixed 2026-03-30. Added keys: item_bonus_chips, item_bonus_mult, item_bonus_xmult, talisman_gwangbak_shield, talisman_mountain_charm, consumable_ribbon_polish, consumable_bomb_fuse, synergy_fortress, passive_flower_bomb, passive_provoke.
