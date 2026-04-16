// 🎴 K-Poker — 게임 엔진 및 턴 진행 (v2.0 오리지널 화투 규칙)
//
// 딜링, 카드 내기, 매칭, 덱 뒤집기, 턴 전환,
// 뻑, 쪽, 따닥, 쓸, 자뻑, 연뻑/삼뻑, 보너스 쌍피, 피 뺏기 처리.

import 'dart:math';
import '../models/card_def.dart';
import '../models/round_state.dart';
import '../models/run_state.dart';
import '../data/all_cards.dart';
import 'card_matcher.dart';

class GameEngine {
  static final Random _random = Random();

  /// 리스트에서 첫 번째 매치만 제거 (freezed 값비교 안전)
  static List<T> _removeOne<T>(List<T> list, T item) {
    bool found = false;
    return list.where((c) {
      if (!found && c == item) {
        found = true;
        return false;
      }
      return true;
    }).toList();
  }

  // ─────────────────────────────────────────────
  // 새로운 라운드 초기화 (딜링) — 50장 기반
  // ─────────────────────────────────────────────
  /// 선(先) 결정: 전판 패자가 선. 첫판이면 랜덤.
  static String determineFirstTurn(String lastRoundWinner) {
    if (lastRoundWinner == 'player') return 'opponent';
    if (lastRoundWinner == 'opponent') return 'player';
    // 첫판 또는 나가리 → 랜덤
    return _random.nextBool() ? 'player' : 'opponent';
  }

  static RoundState createInitialState({RunState? run, String? firstTurn}) {
    List<CardInstance> deck = allCards
        .map((d) => CardInstance(def: d))
        .toList();

    // c_gwang_scanner [광 스캐너]: 바닥이나 핸드(앞 20장)에 광카드 배치 확률 대폭 증가
    const dealZone = fieldSize + handSize * 2; // 8+10+10 = 28
    if (run != null && (run.equippedRoundItemIds.contains('c_gwang_scanner') || run.equippedRoundItemIds.contains('P-001'))) {
      final brights = deck.where((c) => c.def.grade == CardGrade.bright).toList();
      final others = deck.where((c) => c.def.grade != CardGrade.bright).toList();

      brights.shuffle(_random);
      others.shuffle(_random);

      // 광 5장 중 3장을 무조건 딜 영역(바닥+핸드)으로 이관
      final earlyBrights = brights.take(3).toList();
      final lateBrights = brights.skip(3).toList();

      final earlyOthers = dealZone - earlyBrights.length; // 20-3 = 17
      final firstDeal = [...others.take(earlyOthers), ...earlyBrights]..shuffle(_random);
      final restDeck = [...others.skip(earlyOthers), ...lateBrights]..shuffle(_random);
      deck = [...firstDeal, ...restDeck];
    } else {
      deck.shuffle(_random);
    }

    // 50장: 바닥 8, 플레이어 10, 상대 10, 덱 22 (표준 2인 고스톱)
    final field = deck.sublist(0, fieldSize);
    final playerHand = deck.sublist(fieldSize, fieldSize + handSize);
    final opponentHand = deck.sublist(fieldSize + handSize, fieldSize + handSize * 2);
    final remainingDeck = deck.sublist(fieldSize + handSize * 2);

    final turn = firstTurn ?? 'player';
    var state = RoundState(
      deck: remainingDeck,
      field: field,
      playerHand: playerHand,
      opponentHand: opponentHand,
      currentTurn: turn,
    );

    // 바닥에 보너스 쌍피가 깔려 있으면 → 선(플레이어)이 자동 획득 후 덱에서 보충
    state = _handleBonusCardsOnField(state);

    // ── t_moonlight_pouch (달빛 주머니): 판 시작 시 덱에서 랜덤 1장 플레이어 획득 ──
    if (run != null && run.ownedTalismanIds.contains('t_moonlight_pouch')) {
      if (state.deck.isNotEmpty) {
        final bonusCard = state.deck[_random.nextInt(state.deck.length)];
        state = state.copyWith(
          deck: state.deck.where((c) => c != bonusCard).toList(),
          playerCaptured: [...state.playerCaptured, bonusCard],
        );
      }
    }

    // ── ps_flower_bomb (꽃폭탄): 플레이어 핸드에 같은 월 3장 보유 여부 체크 ──
    if (run != null && run.ownedPassiveIds.contains('ps_flower_bomb')) {
      final monthCounts = <int, int>{};
      for (final c in state.playerHand) {
        if (!c.def.isBonus && !c.isDeckDraw) {
          monthCounts[c.def.month] = (monthCounts[c.def.month] ?? 0) + 1;
        }
      }
      if (monthCounts.values.any((v) => v >= 3)) {
        state = state.copyWith(hadTripleMonth: true);
      }
    }

    // ── ps_flower_lord (꽃패의 주인): 바닥 최고가치 카드를 핸드 월로 자동 변경 (1회) ──
    if (run != null && run.ownedPassiveIds.contains('ps_flower_lord')) {
      if (state.field.isNotEmpty && state.playerHand.isNotEmpty) {
        // 바닥에서 가장 가치 높은 카드 찾기
        const gradeValue = {
          CardGrade.bright: 4,
          CardGrade.animal: 3,
          CardGrade.ribbon: 2,
          CardGrade.junk: 1,
        };
        final sortedField = [...state.field]
          ..sort((a, b) =>
              (gradeValue[b.def.grade] ?? 0).compareTo(gradeValue[a.def.grade] ?? 0));
        final bestField = sortedField.first;

        // 핸드에서 가장 많은 월 찾기 (매칭 확률 극대화)
        final handMonthCounts = <int, int>{};
        for (final c in state.playerHand) {
          if (!c.def.isBonus && !c.isDeckDraw) {
            handMonthCounts[c.def.month] = (handMonthCounts[c.def.month] ?? 0) + 1;
          }
        }
        if (handMonthCounts.isNotEmpty) {
          final bestMonth = handMonthCounts.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
          // 바닥 카드의 월을 변경
          if (bestField.def.month != bestMonth) {
            final newDef = CardDef(
              id: bestField.def.id,
              month: bestMonth,
              grade: bestField.def.grade,
              name: bestField.def.name,
              nameKo: bestField.def.nameKo,
              ribbonType: bestField.def.ribbonType,
              isBird: bestField.def.isBird,
              doubleJunk: bestField.def.doubleJunk,
              isBonus: bestField.def.isBonus,
            );
            final newCard = CardInstance(def: newDef, edition: bestField.edition);
            final newField = state.field.map((c) => c == bestField ? newCard : c).toList();
            state = state.copyWith(field: newField, flowerLordUsed: true);
          }
        }
      }
    }

    return state;
  }

  /// 딜링 시 바닥에 보너스 카드가 있으면 선(先)이 자동 획득, 덱에서 보충
  static RoundState _handleBonusCardsOnField(RoundState state) {
    var newState = state;
    var bonusOnField = newState.field.where((c) => c.def.isBonus).toList();
    final isPlayerFirst = newState.currentTurn == 'player';

    while (bonusOnField.isNotEmpty) {
      for (final bonus in bonusOnField) {
        // 바닥에서 제거 → 선이 획득
        final captured = isPlayerFirst ? newState.playerCaptured : newState.opponentCaptured;
        newState = newState.copyWith(
          field: newState.field.where((c) => c != bonus).toList(),
          playerCaptured: isPlayerFirst ? [...captured, bonus] : newState.playerCaptured,
          opponentCaptured: isPlayerFirst ? newState.opponentCaptured : [...captured, bonus],
        );
        // 덱에서 1장 보충
        if (newState.deck.isNotEmpty) {
          final replacement = newState.deck.first;
          newState = newState.copyWith(
            field: [...newState.field, replacement],
            deck: newState.deck.skip(1).toList(),
          );
        }
      }
      // 보충한 카드 중에 또 보너스가 있을 수 있으므로 반복
      bonusOnField = newState.field.where((c) => c.def.isBonus).toList();
    }
    return newState;
  }

  // ─────────────────────────────────────────────
  // 총통 감지
  // ─────────────────────────────────────────────
  static int? getChongtongMonth(List<CardInstance> hand) {
    final monthCount = <int, int>{};
    for (final c in hand) {
      if (c.def.isBonus || c.isDeckDraw) continue;
      monthCount[c.def.month] = (monthCount[c.def.month] ?? 0) + 1;
    }
    for (final entry in monthCount.entries) {
      if (entry.value >= 4) return entry.key;
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // 덱드로 전용 더미 CardDef
  // ─────────────────────────────────────────────
  static const CardDef _deckDrawDef = CardDef(
    id: 'deck_draw',
    month: 0,
    grade: CardGrade.junk,
    name: 'Deck Draw',
    nameKo: '덱 뒤집기',
  );

  static CardInstance createDeckDrawCard() {
    return const CardInstance(def: _deckDrawDef, isDeckDraw: true);
  }

  // ─────────────────────────────────────────────
  // 폭탄 감지 (핸드 3장 + 바닥에 같은 월 1장 이상 필수)
  // ─────────────────────────────────────────────
  static int? getBombMonth(List<CardInstance> hand, List<CardInstance> field) {
    final months = getBombMonths(hand, field);
    return months.isNotEmpty ? months.first : null;
  }

  /// 폭탄 가능한 모든 월 리스트 (복수 세트 대응)
  static List<int> getBombMonths(List<CardInstance> hand, List<CardInstance> field) {
    final monthCounts = <int, int>{};
    for (final card in hand) {
      if (card.def.isBonus || card.isDeckDraw) continue;
      monthCounts[card.def.month] = (monthCounts[card.def.month] ?? 0) + 1;
    }
    final result = <int>[];
    for (final entry in monthCounts.entries) {
      if (entry.value >= 3) {
        final fieldSameMonth = field.where((c) => c.def.month == entry.key).length;
        if (fieldSameMonth >= 1) result.add(entry.key);
      }
    }
    return result;
  }

  // ─────────────────────────────────────────────
  // 피 뺏기 헬퍼 함수 (외부에서 총통 등에서도 호출)
  // ─────────────────────────────────────────────
  static RoundState stealPi(RoundState state, String taker, int count) {
    var newState = state;
    int stolen = 0;

    if (taker == 'player') {
      final opJunks = newState.opponentCaptured
          .where((c) => c.def.grade == CardGrade.junk)
          .toList();
      final toSteal = opJunks.length < count ? opJunks.length : count;
      if (toSteal > 0) {
        final stolenCards = opJunks.sublist(opJunks.length - toSteal);
        newState = newState.copyWith(
          opponentCaptured: newState.opponentCaptured
              .where((c) => !stolenCards.contains(c))
              .toList(),
          playerCaptured: [...newState.playerCaptured, ...stolenCards],
        );
        stolen = toSteal;
      }
    } else {
      final pJunks = newState.playerCaptured
          .where((c) => c.def.grade == CardGrade.junk)
          .toList();
      final toSteal = pJunks.length < count ? pJunks.length : count;
      if (toSteal > 0) {
        final stolenCards = pJunks.sublist(pJunks.length - toSteal);
        newState = newState.copyWith(
          playerCaptured: newState.playerCaptured
              .where((c) => !stolenCards.contains(c))
              .toList(),
          opponentCaptured: [...newState.opponentCaptured, ...stolenCards],
        );
        stolen = toSteal;
      }
    }

    newState = newState.copyWith(lastStolenPiCount: stolen);
    return newState;
  }

  // ─────────────────────────────────────────────
  // 핵심: playTurn (v2.0 — 오리지널 화투 규칙)
  // ─────────────────────────────────────────────
  static RoundState playTurn(RoundState state, CardInstance playedCard,
      {CardInstance? selectedMatch, RunState? run}) {
    var newState = state;
    final currentTurn = newState.currentTurn;

    // 이벤트 초기화
    newState = newState.copyWith(lastSpecialEvent: '', lastStolenPiCount: 0);

    // ── 보너스 카드 처리: 즉시 획득 + 덱에서 1장을 핸드에 추가 (턴 소비 없음) ──
    if (playedCard.def.isBonus) {
      // 핸드에서 제거 + 획득 영역으로
      if (currentTurn == 'player') {
        var newHand = _removeOne(newState.playerHand, playedCard);
        // 덱에서 1장을 핸드에 추가
        if (newState.deck.isNotEmpty) {
          final drawn = newState.deck.first;
          newHand = [...newHand, drawn];
          newState = newState.copyWith(
            deck: newState.deck.skip(1).toList(),
            playerHand: newHand,
            playerCaptured: [...newState.playerCaptured, playedCard],
          );
        } else {
          newState = newState.copyWith(
            playerHand: newHand,
            playerCaptured: [...newState.playerCaptured, playedCard],
          );
        }
      } else {
        var newHand = _removeOne(newState.opponentHand, playedCard);
        if (newState.deck.isNotEmpty) {
          final drawn = newState.deck.first;
          newHand = [...newHand, drawn];
          newState = newState.copyWith(
            deck: newState.deck.skip(1).toList(),
            opponentHand: newHand,
            opponentCaptured: [...newState.opponentCaptured, playedCard],
          );
        } else {
          newState = newState.copyWith(
            opponentHand: newHand,
            opponentCaptured: [...newState.opponentCaptured, playedCard],
          );
        }
      }
      // 턴 소비 안 함 → 플레이어가 다시 카드를 낼 수 있도록 그냥 리턴
      return newState;
    }

    // ── 덱드로 카드 처리: 핸드에서 제거 + 덱 1장만 뒤집어서 매칭 ──
    if (playedCard.isDeckDraw) {
      if (currentTurn == 'player') {
        newState = newState.copyWith(
          playerHand: _removeOne(newState.playerHand, playedCard),
        );
      } else {
        newState = newState.copyWith(
          opponentHand: _removeOne(newState.opponentHand, playedCard),
        );
      }

      List<CardInstance> captured = [];
      if (newState.deck.isNotEmpty) {
        final flippedCard = newState.deck.first;
        newState = newState.copyWith(deck: newState.deck.skip(1).toList());

        // 보너스 카드가 덱에서 나오면 즉시 획득 + 계속 뒤집기 (연속 보너스 대응)
        CardInstance? currentFlip = flippedCard;
        while (currentFlip != null && currentFlip.def.isBonus) {
          if (currentTurn == 'player') {
            newState = newState.copyWith(
              playerCaptured: [...newState.playerCaptured, currentFlip],
            );
          } else {
            newState = newState.copyWith(
              opponentCaptured: [...newState.opponentCaptured, currentFlip],
            );
          }
          if (newState.deck.isNotEmpty) {
            currentFlip = newState.deck.first;
            newState = newState.copyWith(deck: newState.deck.skip(1).toList());
          } else {
            currentFlip = null;
          }
        }
        if (currentFlip != null) {
          // 보너스가 아닌 카드가 나왔으면 매칭 시도
          final deckMatch = executeMatch(currentFlip, newState.field);
          if (deckMatch.matched) {
            captured.addAll(deckMatch.capturedCards);
            newState = newState.copyWith(
              field: newState.field.where((c) => !deckMatch.matchedFieldCards.contains(c)).toList(),
            );
          } else {
            newState = newState.copyWith(field: [...newState.field, currentFlip]);
          }
        }
      }

      if (captured.isNotEmpty) {
        if (currentTurn == 'player') {
          newState = newState.copyWith(playerCaptured: [...newState.playerCaptured, ...captured]);
        } else {
          newState = newState.copyWith(opponentCaptured: [...newState.opponentCaptured, ...captured]);
        }
      }

      newState = _advanceTurn(newState);
      return newState;
    }

    // ═══════════════════════════════════════════
    // 일반 카드 처리 (핵심 로직)
    // ═══════════════════════════════════════════

    // ── STEP 1: 핸드에서 카드 제거 ──
    if (currentTurn == 'player') {
      newState = newState.copyWith(
        playerHand: _removeOne(newState.playerHand, playedCard),
      );
    } else {
      newState = newState.copyWith(
        opponentHand: _removeOne(newState.opponentHand, playedCard),
      );
    }

    // ── STEP 2: 손패 매칭 (보류) ──
    // ps_rainy_season (장마철): 12월 카드가 모든 월과 매칭 가능
    final bool isWildDecember = run != null &&
        run.ownedPassiveIds.contains('ps_rainy_season') &&
        playedCard.def.month == 12;
    final handSameMonth = isWildDecember
        ? newState.field.where((c) => !c.def.isBonus && !c.isDeckDraw).toList()
        : newState.field.where((c) => c.def.month == playedCard.def.month).toList();
    bool handMatched = false;
    List<CardInstance> handCaptured = [];
    // ignore: unused_local_variable
    List<CardInstance> handMatchedField = [];

    if (handSameMonth.length == 3) {
      // 뻑 먹기! 바닥에 3장이 쌓여있고 내가 4번째 카드를 내서 전부 획득
      handMatched = true;
      handCaptured = [playedCard, ...handSameMonth];
      handMatchedField = handSameMonth;
      newState = newState.copyWith(
        field: newState.field.where((c) => c.def.month != playedCard.def.month).toList(),
      );

      // 자뻑 판별: 내가 낸 뻑을 내가 먹으면 피 2장, 아니면 피 1장
      final isSelfPpeok = newState.lastPpeokOwner == currentTurn &&
          newState.lastPpeokMonth == playedCard.def.month;
      if (isSelfPpeok) {
        newState = newState.copyWith(lastSpecialEvent: 'self_ppeok');
        newState = stealPi(newState, currentTurn, 2);
      } else {
        // 상대 뻑을 먹음 -> 멘탈 가드(T-002) 작동 확인
        bool blockSteal = false;
        if (currentTurn == 'opponent' && run != null && run.ownedTalismanIds.contains('T-002') && !state.mentalGuardUsed) {
          blockSteal = true;
          newState = newState.copyWith(mentalGuardUsed: true, lastSpecialEvent: 'ppeok_guard');
        }

        if (!blockSteal) {
          newState = newState.copyWith(lastSpecialEvent: 'ppeok_eat');
          newState = stealPi(newState, currentTurn, 1);
        } else {
          // 멘탈 가드로 피를 뺏기지 않음
          newState = newState.copyWith(lastStolenPiCount: 0);
        }
      }

      // 뻑 추적 초기화 (먹어서 사라짐)
      newState = newState.copyWith(lastPpeokOwner: '', lastPpeokMonth: 0);

      // 연뻑 카운터 초기화 (뻑을 먹으면 상대의 연뻑이 끊긴다)
      if (currentTurn == 'player') {
        newState = newState.copyWith(opponentPpeokCount: 0);
      } else {
        newState = newState.copyWith(playerPpeokCount: 0);
      }
    } else if (handSameMonth.length == 2) {
      // 바닥에 2장: 플레이어 선택 필요
      final target = selectedMatch ?? handSameMonth[0];
      handMatched = true;
      handCaptured = [playedCard, target];
      handMatchedField = [target];
      newState = newState.copyWith(
        field: newState.field.where((c) => c != target).toList(),
      );
    } else if (handSameMonth.length == 1) {
      // 바닥에 1장: 자동 매칭
      handMatched = true;
      handCaptured = [playedCard, handSameMonth[0]];
      handMatchedField = [handSameMonth[0]];
      newState = newState.copyWith(
        field: newState.field.where((c) => c != handSameMonth[0]).toList(),
      );
    } else {
      // 매칭 없음: 바닥에 놓기
      // t_cheaters_glove (사기꾼의 장갑): 매칭 실패 시 카드 핸드로 복귀 (1회/턴)
      final hasGlove = run != null &&
          run.ownedTalismanIds.contains('t_cheaters_glove') &&
          currentTurn == 'player' &&
          !newState.gloveUsedThisTurn;
      if (hasGlove) {
        // 카드를 바닥에 놓지 않고 핸드로 반환
        handMatched = false;
        newState = newState.copyWith(
          playerHand: [...newState.playerHand, playedCard],
          gloveUsedThisTurn: true,
          lastSpecialEvent: 'glove_return',
        );
      } else {
        handMatched = false;
        newState = newState.copyWith(field: [...newState.field, playedCard]);
      }
    }

    // ── STEP 3: 덱에서 카드 뒤집기 ──
    List<CardInstance> deckCaptured = [];
    bool deckMatched = false;
    CardInstance? flippedCard;

    if (newState.deck.isNotEmpty) {
      // ps_gamblers_instinct (도박꾼의 직감): 2장 중 유리한 쪽 자동 선택
      if (run != null &&
          run.ownedPassiveIds.contains('ps_gamblers_instinct') &&
          currentTurn == 'player' &&
          newState.deck.length >= 2) {
        final card1 = newState.deck[0];
        final card2 = newState.deck[1];
        // 매칭 가능한 쪽 선택, 둘 다 가능하면 높은 등급 선택
        final match1 = newState.field.any((c) => c.def.month == card1.def.month);
        final match2 = newState.field.any((c) => c.def.month == card2.def.month);
        if (match2 && !match1) {
          // card2가 더 유리 → card2를 먼저, card1을 덱에 유지
          flippedCard = card2;
          newState = newState.copyWith(
            deck: [newState.deck[0], ...newState.deck.skip(2)],
          );
        } else if (match1 && match2) {
          // 둘 다 매칭 가능 → 높은 등급 선택
          const gradeOrder = {
            CardGrade.bright: 4,
            CardGrade.animal: 3,
            CardGrade.ribbon: 2,
            CardGrade.junk: 1,
          };
          final g1 = gradeOrder[card1.def.grade] ?? 0;
          final g2 = gradeOrder[card2.def.grade] ?? 0;
          if (g2 > g1) {
            flippedCard = card2;
            newState = newState.copyWith(
              deck: [newState.deck[0], ...newState.deck.skip(2)],
            );
          } else {
            flippedCard = card1;
            newState = newState.copyWith(deck: newState.deck.skip(1).toList());
          }
        } else {
          // 기본: 첫 장
          flippedCard = card1;
          newState = newState.copyWith(deck: newState.deck.skip(1).toList());
        }
      } else {
        flippedCard = newState.deck.first;
        newState = newState.copyWith(deck: newState.deck.skip(1).toList());
      }

      // 보너스 카드가 덱에서 나오면 즉시 획득 + 계속 뒤집기 (연속 보너스 대응)
      while (flippedCard != null && flippedCard.def.isBonus) {
        if (currentTurn == 'player') {
          newState = newState.copyWith(playerCaptured: [...newState.playerCaptured, flippedCard]);
        } else {
          newState = newState.copyWith(opponentCaptured: [...newState.opponentCaptured, flippedCard]);
        }
        if (newState.deck.isNotEmpty) {
          flippedCard = newState.deck.first;
          newState = newState.copyWith(deck: newState.deck.skip(1).toList());
        } else {
          flippedCard = null;
        }
      }

      if (flippedCard != null) {
        final deckSameMonth = newState.field.where((c) => c.def.month == flippedCard!.def.month).toList();

        if (deckSameMonth.length == 3) {
          // 뻑 먹기 (덱으로)
          deckMatched = true;
          deckCaptured = [flippedCard, ...deckSameMonth];
          newState = newState.copyWith(
            field: newState.field.where((c) => c.def.month != flippedCard!.def.month).toList(),
          );
          if (newState.lastSpecialEvent != 'ppeok_eat' && newState.lastSpecialEvent != 'ppeok_guard') {
            // 상대 뻑을 덱드로우로 먹을 때도 멘탈가드 판별
            bool blockSteal = false;
            if (currentTurn == 'opponent' && run != null && run.ownedTalismanIds.contains('T-002') && !state.mentalGuardUsed) {
              blockSteal = true;
              newState = newState.copyWith(mentalGuardUsed: true, lastSpecialEvent: 'ppeok_guard');
            }

            if (!blockSteal) {
              newState = newState.copyWith(lastSpecialEvent: 'ppeok_eat');
              newState = stealPi(newState, currentTurn, 1);
            }
          }
        } else if (deckSameMonth.isNotEmpty) {
          final deckMatch = executeMatch(flippedCard, newState.field);
          if (deckMatch.matched) {
            deckMatched = true;
            deckCaptured = deckMatch.capturedCards;
            newState = newState.copyWith(
              field: newState.field.where((c) => !deckMatch.matchedFieldCards.contains(c)).toList(),
            );
          } else {
            newState = newState.copyWith(field: [...newState.field, flippedCard]);
          }
        } else {
          newState = newState.copyWith(field: [...newState.field, flippedCard]);
        }
      }
    }

    // ── STEP 4: 특수 이벤트 판별 ──
    String specialEvent = newState.lastSpecialEvent;
    int stealCount = 0;

    // 이미 ppeok_eat이 세팅되지 않은 경우에만 판별
    if (specialEvent != 'ppeok_eat') {
      if (handMatched && deckMatched &&
          flippedCard != null &&
          playedCard.def.month == flippedCard.def.month &&
          handSameMonth.length == 2) {
        // ── 따닥 (Tadak): 같은 월 4장 동시 획득 ──
        // 손패 + 덱패 + 필드 2장 = 4장 (같은 월)
        specialEvent = 'tadak';
        stealCount = 1;
        newState = _resetPpeokCount(newState, currentTurn);
      } else if (handMatched && deckMatched &&
          flippedCard != null &&
          playedCard.def.month == flippedCard.def.month &&
          handSameMonth.length == 1) {
        // ── 뻑 (Ppeok): 손패가 바닥 1장과 매칭 + 덱패도 같은 월 ──
        // 3장 전부 바닥에 놓기 (이미 획득한 것 되돌리기)
        specialEvent = 'ppeok';
        // 획득 취소 → 바닥에 3장 놓기
        final returnCards = [...handCaptured, ...deckCaptured];
        newState = newState.copyWith(
          field: [...newState.field, ...returnCards],
        );
        handCaptured = [];
        deckCaptured = [];

        // 뻑 추적: 누가 뻑을 냈는지 기록 (자뻑 판별용)
        newState = newState.copyWith(
          lastPpeokOwner: currentTurn,
          lastPpeokMonth: playedCard.def.month,
        );

        // 연뻑 카운터 누적
        if (currentTurn == 'player') {
          final newCount = newState.playerPpeokCount + 1;
          newState = newState.copyWith(playerPpeokCount: newCount);
          if (newCount == 2) {
            specialEvent = 'double_ppeok'; // 이뻑: +3점
            newState = newState.copyWith(
              playerScore: newState.playerScore + 3,
            );
          } else if (newCount >= 3) {
            specialEvent = 'triple_ppeok'; // 삼뻑: 즉시 승리
            newState = newState.copyWith(isFinished: true);
          }
        } else {
          final newCount = newState.opponentPpeokCount + 1;
          newState = newState.copyWith(opponentPpeokCount: newCount);
          if (newCount == 2) {
            specialEvent = 'double_ppeok';
            newState = newState.copyWith(
              opponentScore: newState.opponentScore + 3,
            );
          } else if (newCount >= 3) {
            specialEvent = 'triple_ppeok';
            newState = newState.copyWith(isFinished: true);
          }
        }
      } else if (!handMatched &&
          deckMatched &&
          flippedCard != null &&
          flippedCard.def.month == playedCard.def.month) {
        // ── 쪽 (Chok): 필드에 같은 월 없음 + 덱에서 같은 월 나와서 2장 획득 ──
        specialEvent = 'chok';
        stealCount = 1;
        newState = _resetPpeokCount(newState, currentTurn);
      } else {
        // 일반 턴: 연뻑 카운터 초기화
        newState = _resetPpeokCount(newState, currentTurn);
      }
    }

    // ── STEP 5: 획득 카드 등록 ──
    final allCaptured = [...handCaptured, ...deckCaptured];
    if (allCaptured.isNotEmpty) {
      if (currentTurn == 'player') {
        newState = newState.copyWith(
          playerCaptured: [...newState.playerCaptured, ...allCaptured],
        );
      } else {
        newState = newState.copyWith(
          opponentCaptured: [...newState.opponentCaptured, ...allCaptured],
        );
      }
    }

    // ── STEP 5b: 아이템 효과 — 캡처 카드 후처리 ──
    if (allCaptured.isNotEmpty && currentTurn == 'player' && run != null) {
      final capturedJunks = allCaptured.where((c) => c.def.grade == CardGrade.junk).toList();

      // ps_flower_rain (꽃비): 피 캡처 40% 확률로 띠로 승격
      if (run.ownedPassiveIds.contains('ps_flower_rain') && capturedJunks.isNotEmpty) {
        for (final junk in capturedJunks) {
          if (_random.nextDouble() < 0.4) {
            // 피를 띠로 승격: 같은 월의 가상 띠 카드 생성
            final upgradedDef = CardDef(
              id: '${junk.def.id}_upgraded',
              month: junk.def.month,
              grade: CardGrade.ribbon,
              name: '${junk.def.name} (Upgraded)',
              nameKo: '${junk.def.nameKo} (승격)',
              ribbonType: RibbonType.plain,
            );
            final upgradedCard = CardInstance(def: upgradedDef, edition: junk.edition);
            // playerCaptured에서 junk를 upgradedCard로 교체
            final currentCaptured = newState.playerCaptured.toList();
            final junkIdx = currentCaptured.lastIndexOf(junk);
            if (junkIdx >= 0) {
              currentCaptured[junkIdx] = upgradedCard;
              newState = newState.copyWith(playerCaptured: currentCaptured);
            }
          }
        }
      }

      // ps_junk_luck (둑배기): 피 캡처 시 25% 확률 추가 피 1장
      if (run.ownedPassiveIds.contains('ps_junk_luck') && capturedJunks.isNotEmpty) {
        for (final _ in capturedJunks) {
          if (_random.nextDouble() < 0.25) {
            const bonusCard = CardInstance(
              def: CardDef(
                id: 'bonus_junk_luck',
                month: 0,
                grade: CardGrade.junk,
                name: 'Bonus Junk',
                nameKo: '보너스 피',
                isBonus: true,
              ),
            );
            newState = newState.copyWith(
              playerCaptured: [...newState.playerCaptured, bonusCard],
            );
          }
        }
      }

      // c_pi_magnet (피 자석): 피 캡처 시 100% 추가 피 1장 (소모품)
      if (run.equippedRoundItemIds.contains('c_pi_magnet') && capturedJunks.isNotEmpty) {
        for (final _ in capturedJunks) {
          const bonusCard = CardInstance(
            def: CardDef(
              id: 'bonus_pi_magnet',
              month: 0,
              grade: CardGrade.junk,
              name: 'Magnet Junk',
              nameKo: '자석 피',
              isBonus: true,
            ),
          );
          newState = newState.copyWith(
            playerCaptured: [...newState.playerCaptured, bonusCard],
          );
        }
      }
    }

    // ── STEP 5c: ps_ppuk_inducer (상대 뻑 시 피 2장 탈취) ──
    if (run != null &&
        run.ownedPassiveIds.contains('ps_ppuk_inducer') &&
        currentTurn == 'opponent' &&
        specialEvent == 'ppeok' &&
        !newState.ppukBonusUsed) {
      newState = stealPi(newState, 'player', 2);
      newState = newState.copyWith(ppukBonusUsed: true);
    }

    // ── STEP 6: 쓸 판별 ──
    int sweepCount = newState.sweepCount;
    if (newState.field.isEmpty && allCaptured.isNotEmpty) {
      sweepCount++;
      if (specialEvent == 'chok') {
        specialEvent = 'chok_sweep'; // 쪽+쓸 = 2장 뺏기
        stealCount = 2;
      } else if (specialEvent == '' || specialEvent == 'tadak') {
        // 일반 쓸 or 따닥+쓸
        if (specialEvent == 'tadak') {
          stealCount = 2; // 따닥+쓸
        } else {
          specialEvent = 'sweep';
          stealCount = 1;
        }
      }
    }
    newState = newState.copyWith(sweepCount: sweepCount);

    // ── STEP 7: 피 뺏기 ──
    if (stealCount > 0) {
      newState = stealPi(newState, currentTurn, stealCount);
    }

    // ── STEP 8: 이벤트 상태 저장 ──
    newState = newState.copyWith(lastSpecialEvent: specialEvent);

    // ── STEP 9: 턴 전환 ──
    if (!newState.isFinished) {
      newState = _advanceTurn(newState);
    }

    // ── STEP 10: ps_skilled_hand (노련한 손) — 15% 확률 추가 덱 뒤집기+매칭 ──
    if (run != null &&
        run.ownedPassiveIds.contains('ps_skilled_hand') &&
        currentTurn == 'player' &&
        allCaptured.isNotEmpty &&
        newState.deck.isNotEmpty &&
        !newState.isFinished) {
      if (_random.nextDouble() < 0.15) {
        final extraFlip = newState.deck.first;
        newState = newState.copyWith(deck: newState.deck.skip(1).toList());
        // 보너스 카드 처리
        CardInstance? actualFlip = extraFlip;
        while (actualFlip != null && actualFlip.def.isBonus) {
          newState = newState.copyWith(
            playerCaptured: [...newState.playerCaptured, actualFlip],
          );
          if (newState.deck.isNotEmpty) {
            actualFlip = newState.deck.first;
            newState = newState.copyWith(deck: newState.deck.skip(1).toList());
          } else {
            actualFlip = null;
          }
        }
        if (actualFlip != null) {
          final extraMatch = executeMatch(actualFlip, newState.field);
          if (extraMatch.matched) {
            newState = newState.copyWith(
              field: newState.field.where((c) => !extraMatch.matchedFieldCards.contains(c)).toList(),
              playerCaptured: [...newState.playerCaptured, ...extraMatch.capturedCards],
            );
          } else {
            newState = newState.copyWith(field: [...newState.field, actualFlip]);
          }
        }
      }
    }

    // ── 턴 전환 후 gloveUsedThisTurn 리셋 ──
    newState = newState.copyWith(gloveUsedThisTurn: false);

    return newState;
  }

  /// 연뻑 카운터 초기화 (해당 플레이어가 뻑이 아닌 액션을 한 경우)
  static RoundState _resetPpeokCount(RoundState state, String currentTurn) {
    if (currentTurn == 'player') {
      return state.copyWith(playerPpeokCount: 0);
    } else {
      return state.copyWith(opponentPpeokCount: 0);
    }
  }

  /// 턴 전환 + 종료 체크
  static RoundState _advanceTurn(RoundState state) {
    var newState = state.copyWith(
      currentTurn: state.currentTurn == 'player' ? 'opponent' : 'player',
      turnNumber: state.turnNumber + 1,
    );

    if (newState.playerHand.isEmpty && newState.opponentHand.isEmpty) {
      newState = newState.copyWith(isFinished: true);
    } else if (newState.deck.isEmpty) {
      // 덱 소진 → 더 이상 카드 뒤집기 불가, 라운드 종료
      newState = newState.copyWith(isFinished: true);
    }

    return newState;
  }

  // ─────────────────────────────────────────────
  // 폭탄 실행
  // ─────────────────────────────────────────────
  static RoundState playBomb(RoundState state, int bombMonth) {
    var newState = state;
    final currentTurn = newState.currentTurn;

    // 이벤트 초기화 + bombUsed 플래그 설정 (c_bomb_fuse 효과용)
    newState = newState.copyWith(lastSpecialEvent: 'bomb', lastStolenPiCount: 0, bombUsed: true);

    // 1. 핸드에서 같은 월 카드 3장 추출
    final handBombCards = currentTurn == 'player'
        ? newState.playerHand.where((c) => c.def.month == bombMonth).toList()
        : newState.opponentHand.where((c) => c.def.month == bombMonth).toList();

    if (handBombCards.length < 3) return state;

    // 바닥에 같은 월 카드가 없으면 폭탄 불가
    final fieldSameMonth = newState.field.where((c) => c.def.month == bombMonth).toList();
    if (fieldSameMonth.isEmpty) return state;

    final bombCards = handBombCards.take(3).toList();
    List<CardInstance> capturedInThisTurn = [...bombCards];

    // 덱드로 카드 2장 보충 (클릭하면 덱에서 1장 뒤집어서 바닥 매칭)
    final deckDraw1 = createDeckDrawCard();
    final deckDraw2 = createDeckDrawCard();
    capturedInThisTurn.addAll(fieldSameMonth);

    // 3. 핸드에서 폭탄 카드 제거 + 덱드로 카드 보충
    if (currentTurn == 'player') {
      final remainingHand = newState.playerHand.where((c) => !bombCards.contains(c)).toList();
      newState = newState.copyWith(playerHand: [...remainingHand, deckDraw1, deckDraw2]);
    } else {
      final remainingHand = newState.opponentHand.where((c) => !bombCards.contains(c)).toList();
      newState = newState.copyWith(opponentHand: [...remainingHand, deckDraw1, deckDraw2]);
    }

    // 4. 바닥에서 같은 월 제거
    newState = newState.copyWith(
      field: newState.field.where((c) => c.def.month != bombMonth).toList(),
    );

    // 5. 상대방 피 1장 뺏기
    newState = stealPi(newState, currentTurn, 1);

    // 6. 덱에서 카드 뒤집기
    if (newState.deck.isNotEmpty) {
      final flippedCard = newState.deck.first;
      newState = newState.copyWith(deck: newState.deck.skip(1).toList());

      // 보너스 카드가 연속으로 나올 수 있으므로 while 루프
      CardInstance? currentFlip = flippedCard;
      while (currentFlip != null && currentFlip.def.isBonus) {
        if (currentTurn == 'player') {
          newState = newState.copyWith(playerCaptured: [...newState.playerCaptured, currentFlip]);
        } else {
          newState = newState.copyWith(opponentCaptured: [...newState.opponentCaptured, currentFlip]);
        }
        if (newState.deck.isNotEmpty) {
          currentFlip = newState.deck.first;
          newState = newState.copyWith(deck: newState.deck.skip(1).toList());
        } else {
          currentFlip = null;
        }
      }
      if (currentFlip != null) {
        final sameMonthForFlip = newState.field.where((c) => c.def.month == currentFlip!.def.month).toList();
        if (sameMonthForFlip.isNotEmpty) {
          final deckMatch = executeMatch(currentFlip, newState.field);
          if (deckMatch.matched) {
            capturedInThisTurn.addAll(deckMatch.capturedCards);
            newState = newState.copyWith(
              field: newState.field.where((c) => !deckMatch.matchedFieldCards.contains(c)).toList(),
            );
          } else {
            newState = newState.copyWith(field: [...newState.field, currentFlip]);
          }
        } else {
          newState = newState.copyWith(field: [...newState.field, currentFlip]);
        }
      }
    }

    // 7. 쓸 체크
    int sweepCount = state.sweepCount;
    if (newState.field.isEmpty && capturedInThisTurn.isNotEmpty) {
      sweepCount++;
      // 폭탄+쓸: 추가 피 1장 뺏기
      newState = stealPi(newState, currentTurn, 1);
    }

    // 8. 획득 카드 추가
    if (currentTurn == 'player') {
      newState = newState.copyWith(
        playerCaptured: [...newState.playerCaptured, ...capturedInThisTurn],
        sweepCount: sweepCount,
      );
    } else {
      newState = newState.copyWith(
        opponentCaptured: [...newState.opponentCaptured, ...capturedInThisTurn],
        sweepCount: sweepCount,
      );
    }

    // 9. 연뻑 카운터 초기화
    newState = _resetPpeokCount(newState, currentTurn);

    // 10. 턴 전환 (isDeckDraw 카드는 핸드에 남아서 이후 내 턴에 사용)
    newState = _advanceTurn(newState);

    return newState;
  }
}
