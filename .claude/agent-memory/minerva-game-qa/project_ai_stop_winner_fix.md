---
name: AI Stop Winner Bug Fix
description: Critical bug in playAiCard where AI stop did not set winner:'opponent', causing dokbak/gobak to misfire as draw
type: project
---

In game_providers.dart, the `playAiCard` method's AI stop branch (line ~751) was setting `isFinished: true` but NOT `winner: 'opponent'`. The older `_playAiTurn` method correctly set both.

**Why:** When player declares Go and AI subsequently stops, `_handleRoundEnd` checks `goButNoIncrease = anyoneGo && winner == null && !isDraw`. With winner=null and player go count > 0, this evaluates to true, causing the round to be treated as nagari (draw) instead of player loss with 2x dokbak penalty.

**How to apply:** Always verify winner is set in all stop paths. Both `playAiCard` and `_playAiTurn` must mirror each other's logic.

Fixed 2026-03-30.
