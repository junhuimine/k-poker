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
  static RoundState createInitialState({RunState? run}) {
    List<CardInstance> deck = allCards
        .map((d) => CardInstance(def: d))
        .toList();

    // P-001 [광 스캐너]: 바닥이나 핸드(앞 20장)에 광카드 배치 확률 대폭 증가
    if (run != null && run.equippedRoundItemIds.contains('P-001')) {
      final brights = deck.where((c) => c.def.grade == CardGrade.bright).toList();
      final others = deck.where((c) => c.def.grade != CardGrade.bright).toList();
      
      brights.shuffle(_random);
      others.shuffle(_random);

      // 광 5장 중 3장을 무조건 초반 20장 덱풀로 이관
      final earlyBrights = brights.take(3).toList();
      final lateBrights = brights.skip(3).toList();

      final first20 = [...others.take(20 - 3), ...earlyBrights]..shuffle(_random);
      final rest30 = [...others.skip(17), ...lateBrights]..shuffle(_random);
      deck = [...first20, ...rest30];
    } else {
      deck.shuffle(_random);
    }

    // 50장: 바닥 10, 플레이어 10, 상대 10, 덱 20
    final field = deck.sublist(0, fieldSize);
    final playerHand = deck.sublist(fieldSize, fieldSize + handSize);
    final opponentHand = deck.sublist(fieldSize + handSize, fieldSize + handSize * 2);
    final remainingDeck = deck.sublist(fieldSize + handSize * 2);

    var state = RoundState(
      deck: remainingDeck,
      field: field,
      playerHand: playerHand,
      opponentHand: opponentHand,
    );

    // 바닥에 보너스 쌍피가 깔려 있으면 → 선(플레이어)이 자동 획득 후 덱에서 보충
    state = _handleBonusCardsOnField(state);

    return state;
  }

  /// 딜링 시 바닥에 보너스 카드가 있으면 플레이어가 자동 획득, 덱에서 보충
  static RoundState _handleBonusCardsOnField(RoundState state) {
    var newState = state;
    var bonusOnField = newState.field.where((c) => c.def.isBonus).toList();

    while (bonusOnField.isNotEmpty) {
      for (final bonus in bonusOnField) {
        // 바닥에서 제거
        newState = newState.copyWith(
          field: newState.field.where((c) => c != bonus).toList(),
          playerCaptured: [...newState.playerCaptured, bonus],
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
  // 폭탄 감지
  // ─────────────────────────────────────────────
  static int? getBombMonth(List<CardInstance> hand) {
    final monthCounts = <int, int>{};
    for (final card in hand) {
      if (card.def.isBonus || card.isDeckDraw) continue;
      monthCounts[card.def.month] = (monthCounts[card.def.month] ?? 0) + 1;
    }
    for (final entry in monthCounts.entries) {
      if (entry.value >= 3) return entry.key;
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // 피 뺏기 헬퍼 함수
  // ─────────────────────────────────────────────
  static RoundState _stealPi(RoundState state, String taker, int count) {
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
    final handSameMonth = newState.field.where((c) => c.def.month == playedCard.def.month).toList();
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
        newState = _stealPi(newState, currentTurn, 2);
      } else {
        // 상대 뻑을 먹음 -> 멘탈 가드(T-002) 작동 확인
        bool blockSteal = false;
        if (currentTurn == 'opponent' && run != null && run.ownedTalismanIds.contains('T-002') && !state.mentalGuardUsed) {
          blockSteal = true;
          newState = newState.copyWith(mentalGuardUsed: true, lastSpecialEvent: 'ppeok_guard');
        }

        if (!blockSteal) {
          newState = newState.copyWith(lastSpecialEvent: 'ppeok_eat');
          newState = _stealPi(newState, currentTurn, 1);
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
      handMatched = false;
      newState = newState.copyWith(field: [...newState.field, playedCard]);
    }

    // ── STEP 3: 덱에서 카드 뒤집기 ──
    List<CardInstance> deckCaptured = [];
    bool deckMatched = false;
    CardInstance? flippedCard;

    if (newState.deck.isNotEmpty) {
      flippedCard = newState.deck.first;
      newState = newState.copyWith(deck: newState.deck.skip(1).toList());

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
              newState = _stealPi(newState, currentTurn, 1);
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
      newState = _stealPi(newState, currentTurn, stealCount);
    }

    // ── STEP 8: 이벤트 상태 저장 ──
    newState = newState.copyWith(lastSpecialEvent: specialEvent);

    // ── STEP 9: 턴 전환 ──
    if (!newState.isFinished) {
      newState = _advanceTurn(newState);
    }

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
    } else if (newState.deck.isEmpty &&
        (newState.playerHand.isEmpty || newState.opponentHand.isEmpty)) {
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

    // 이벤트 초기화
    newState = newState.copyWith(lastSpecialEvent: 'bomb', lastStolenPiCount: 0);

    // 1. 핸드에서 같은 월 카드 3장 추출
    final handBombCards = currentTurn == 'player'
        ? newState.playerHand.where((c) => c.def.month == bombMonth).toList()
        : newState.opponentHand.where((c) => c.def.month == bombMonth).toList();

    if (handBombCards.length < 3) return state;

    final bombCards = handBombCards.take(3).toList();
    List<CardInstance> capturedInThisTurn = [...bombCards];

    // 덱드로 카드 2장 보충 (클릭하면 덱에서 1장 뒤집어서 바닥 매칭)
    final deckDraw1 = createDeckDrawCard();
    final deckDraw2 = createDeckDrawCard();

    // 2. 바닥에서 같은 월 카드 모두 획득
    final fieldSameMonth = newState.field.where((c) => c.def.month == bombMonth).toList();
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
    newState = _stealPi(newState, currentTurn, 1);

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
      newState = _stealPi(newState, currentTurn, 1);
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
