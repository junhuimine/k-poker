// 🎴 K-Poker — 게임 엔진 및 턴 진행
//
// 딜링, 카드 내기, 매칭, 덱 뒤집기, 턴 전환, 뻑, 나가리 등 처리.

import 'dart:math';
import '../models/card_def.dart';
import '../models/round_state.dart';
import '../data/all_cards.dart';
import 'card_matcher.dart';

class GameEngine {
  static final Random _random = Random();

  /// 새로운 라운드 초기화 (딜링)
  static RoundState createInitialState() {
    // 1. 카드 셔플
    final List<CardInstance> deck = allCards.map((d) => CardInstance(def: d)).toList()..shuffle(_random);

    // 2. 분배 (바닥 8, 플레이어 10, 상대 10, 남은 덱 20)
    final field = deck.sublist(0, 8);
    final playerHand = deck.sublist(8, 18);
    final opponentHand = deck.sublist(18, 28);
    final remainingDeck = deck.sublist(28);

    // 3. 바닥에 같은 월 3장이면 뻑 스택으로 표시
    return RoundState(
      deck: remainingDeck,
      field: field,
      playerHand: playerHand,
      opponentHand: opponentHand,
    );
  }

  /// 총통 감지: 핸드에 같은 월 카드 4장이 있으면 해당 월 반환
  static int? getChongtongMonth(List<CardInstance> hand) {
    final monthCount = <int, int>{};
    for (final c in hand) {
      monthCount[c.def.month] = (monthCount[c.def.month] ?? 0) + 1;
    }
    for (final entry in monthCount.entries) {
      if (entry.value >= 4) return entry.key;
    }
    return null;
  }

  /// 덱드로 전용 더미 CardDef
  static final CardDef _deckDrawDef = CardDef(
    id: 'deck_draw',
    month: 0,
    grade: CardGrade.junk,
    name: 'Deck Draw',
    nameKo: '덱 뒤집기',
  );

  /// 덱드로 카드 생성 (폭탄 보충용)
  static CardInstance createDeckDrawCard() {
    return CardInstance(def: _deckDrawDef, isDeckDraw: true);
  }

  /// 플레이어가 카드를 냈을 때의 처리
  static RoundState playTurn(RoundState state, CardInstance playedCard, {CardInstance? selectedMatch}) {
    var newState = state;

    // ── 덱드로 카드 처리: 핸드에서 제거 + 덱 1장만 뒤집어서 매칭 ──
    if (playedCard.isDeckDraw) {
      // 핸드에서 제거
      if (newState.currentTurn == 'player') {
        newState = newState.copyWith(
          playerHand: newState.playerHand.where((c) => c != playedCard).toList(),
        );
      } else {
        newState = newState.copyWith(
          opponentHand: newState.opponentHand.where((c) => c != playedCard).toList(),
        );
      }

      // 덱에서 1장 뒤집기
      List<CardInstance> captured = [];
      if (newState.deck.isNotEmpty) {
        final flippedCard = newState.deck.first;
        newState = newState.copyWith(deck: newState.deck.skip(1).toList());

        final sameMonth = newState.field.where((c) => c.def.month == flippedCard.def.month).toList();
        if (sameMonth.length == 3) {
          // 뻑! 4장 전부 획득
          captured.addAll(sameMonth);
          captured.add(flippedCard);
          newState = newState.copyWith(
            field: newState.field.where((c) => c.def.month != flippedCard.def.month).toList(),
          );
        } else if (sameMonth.isNotEmpty) {
          final deckMatch = executeDeckFlip(flippedCard, newState.field);
          if (deckMatch.matched) {
            captured.addAll(deckMatch.capturedCards);
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

      // 획득 카드 추가
      if (captured.isNotEmpty) {
        if (newState.currentTurn == 'player') {
          newState = newState.copyWith(
            playerCaptured: [...newState.playerCaptured, ...captured],
          );
        } else {
          newState = newState.copyWith(
            opponentCaptured: [...newState.opponentCaptured, ...captured],
          );
        }
      }

      // 턴 전환
      newState = newState.copyWith(
        currentTurn: newState.currentTurn == 'player' ? 'opponent' : 'player',
        turnNumber: newState.turnNumber + 1,
      );
      if (newState.playerHand.isEmpty && newState.opponentHand.isEmpty) {
        newState = newState.copyWith(isFinished: true);
      }
      return newState;
    }
    
    // ── 뻑 체크: 바닥에 같은 월 3장 있으면 4번째가 올 때 전부 획득 ──
    final sameMonthOnField = newState.field.where((c) => c.def.month == playedCard.def.month).toList();
    
    List<CardInstance> capturedInThisTurn = [];
    
    if (sameMonthOnField.length == 3) {
      // 뻑! 같은 월 3장 + 내 카드 → 4장 전부 획득
      capturedInThisTurn.addAll(sameMonthOnField);
      capturedInThisTurn.add(playedCard);
      newState = newState.copyWith(
        field: newState.field.where((c) => c.def.month != playedCard.def.month).toList(),
      );
    } else {
      // 일반 매칭
      final handMatch = executeMatch(playedCard, newState.field, selectedMatch: selectedMatch);
      
      if (handMatch.matched) {
        capturedInThisTurn.addAll(handMatch.capturedCards);
        newState = newState.copyWith(
          field: newState.field.where((c) => !handMatch.matchedFieldCards.contains(c)).toList(),
        );
      } else {
        newState = newState.copyWith(
          field: [...newState.field, playedCard],
        );
      }
    }
    
    // 2. 핸드에서 카드 제거
    if (newState.currentTurn == 'player') {
      newState = newState.copyWith(
        playerHand: newState.playerHand.where((c) => c != playedCard).toList(),
      );
    } else {
      newState = newState.copyWith(
        opponentHand: newState.opponentHand.where((c) => c != playedCard).toList(),
      );
    }

    // 3. 덱에서 카드 뒤집기
    if (newState.deck.isNotEmpty) {
      final flippedCard = newState.deck.first;
      
      // 뒤집은 카드도 뻑 체크
      final sameMonthForFlip = newState.field.where((c) => c.def.month == flippedCard.def.month).toList();
      
      newState = newState.copyWith(
        deck: newState.deck.skip(1).toList(),
      );

      if (sameMonthForFlip.length == 3) {
        // 뻑! 뒤집은 카드로 4장 완성
        capturedInThisTurn.addAll(sameMonthForFlip);
        capturedInThisTurn.add(flippedCard);
        newState = newState.copyWith(
          field: newState.field.where((c) => c.def.month != flippedCard.def.month).toList(),
        );
      } else {
        final deckMatch = executeDeckFlip(flippedCard, newState.field);
        
        if (deckMatch.matched) {
          capturedInThisTurn.addAll(deckMatch.capturedCards);
          newState = newState.copyWith(
            field: newState.field.where((c) => !deckMatch.matchedFieldCards.contains(c)).toList(),
          );
        } else {
          newState = newState.copyWith(
            field: [...newState.field, flippedCard],
          );
        }
      }
    }

    // 4. 쓸 체크 (바닥이 비면 쓸!)
    final isSweep = newState.field.isEmpty && capturedInThisTurn.isNotEmpty;
    int sweepCount = state.sweepCount;
    if (isSweep) sweepCount++;

    // 5. 획득한 카드 추가
    if (newState.currentTurn == 'player') {
      newState = newState.copyWith(
        playerCaptured: [...newState.playerCaptured, ...capturedInThisTurn],
        sweepCount: sweepCount,
      );
    } else {
      newState = newState.copyWith(
        opponentCaptured: [...newState.opponentCaptured, ...capturedInThisTurn],
      );
    }

    // 6. 턴 전환
    newState = newState.copyWith(
      currentTurn: newState.currentTurn == 'player' ? 'opponent' : 'player',
      turnNumber: newState.turnNumber + 1,
    );

    // 7. 종료 체크 (나가리 포함)
    if (newState.playerHand.isEmpty && newState.opponentHand.isEmpty) {
      newState = newState.copyWith(isFinished: true);
    }
    // 덱이 비고 양쪽 핸드도 비면 나가리
    if (newState.deck.isEmpty && newState.playerHand.isEmpty && newState.opponentHand.isEmpty) {
      newState = newState.copyWith(isFinished: true);
    }

    return newState;
  }

  /// 핸드에 같은 월 3장이 있는지 확인 (폭탄 가능 여부)
  static int? getBombMonth(List<CardInstance> hand) {
    final monthCounts = <int, int>{};
    for (final card in hand) {
      monthCounts[card.def.month] = (monthCounts[card.def.month] ?? 0) + 1;
    }
    for (final entry in monthCounts.entries) {
      if (entry.value >= 3) return entry.key;
    }
    return null;
  }

  /// 폭탄 실행: 같은 월 3장을 한번에 내서 바닥 카드까지 획득 + 상대 피 1장 빼앗기
  static RoundState playBomb(RoundState state, int bombMonth) {
    var newState = state;

    // 1. 핸드에서 같은 월 카드 3장 추출
    final handBombCards = newState.currentTurn == 'player'
        ? newState.playerHand.where((c) => c.def.month == bombMonth).toList()
        : newState.opponentHand.where((c) => c.def.month == bombMonth).toList();

    if (handBombCards.length < 3) return state; // 안전장치

    final bombCards = handBombCards.take(3).toList(); // 3장만
    List<CardInstance> capturedInThisTurn = [...bombCards];

    // 덱드로 카드 2장 보충 (3장 내고 2장 보충 = 순감 1장)
    final deckDraw1 = createDeckDrawCard();
    final deckDraw2 = createDeckDrawCard();

    // 2. 바닥에서 같은 월 카드 모두 획득
    final fieldSameMonth = newState.field.where((c) => c.def.month == bombMonth).toList();
    capturedInThisTurn.addAll(fieldSameMonth);

    // 3. 핸드에서 폭탄 카드 제거
    if (newState.currentTurn == 'player') {
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

    // 5. 상대방 피 1장 빼앗기
    CardInstance? stolenJunk;
    if (newState.currentTurn == 'player') {
      final opJunks = newState.opponentCaptured.where((c) => c.def.grade == CardGrade.junk).toList();
      if (opJunks.isNotEmpty) {
        stolenJunk = opJunks.last;
        newState = newState.copyWith(
          opponentCaptured: newState.opponentCaptured.where((c) => c != stolenJunk).toList(),
        );
        capturedInThisTurn.add(stolenJunk);
      }
    } else {
      final pJunks = newState.playerCaptured.where((c) => c.def.grade == CardGrade.junk).toList();
      if (pJunks.isNotEmpty) {
        stolenJunk = pJunks.last;
        newState = newState.copyWith(
          playerCaptured: newState.playerCaptured.where((c) => c != stolenJunk).toList(),
        );
        capturedInThisTurn.add(stolenJunk);
      }
    }

    // 6. 덱에서 카드 뒤집기
    if (newState.deck.isNotEmpty) {
      final flippedCard = newState.deck.first;
      final sameMonthForFlip = newState.field.where((c) => c.def.month == flippedCard.def.month).toList();

      newState = newState.copyWith(
        deck: newState.deck.skip(1).toList(),
      );

      if (sameMonthForFlip.isNotEmpty) {
        final deckMatch = executeDeckFlip(flippedCard, newState.field);
        if (deckMatch.matched) {
          capturedInThisTurn.addAll(deckMatch.capturedCards);
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

    // 7. 쓸 체크
    final isSweep = newState.field.isEmpty && capturedInThisTurn.isNotEmpty;
    int sweepCount = state.sweepCount;
    if (isSweep) sweepCount++;

    // 8. 획득 카드 추가
    if (newState.currentTurn == 'player') {
      newState = newState.copyWith(
        playerCaptured: [...newState.playerCaptured, ...capturedInThisTurn],
        sweepCount: sweepCount,
      );
    } else {
      newState = newState.copyWith(
        opponentCaptured: [...newState.opponentCaptured, ...capturedInThisTurn],
      );
    }

    // 9. 턴 전환
    newState = newState.copyWith(
      currentTurn: newState.currentTurn == 'player' ? 'opponent' : 'player',
      turnNumber: newState.turnNumber + 1,
    );

    // 10. 종료 체크
    if (newState.playerHand.isEmpty && newState.opponentHand.isEmpty) {
      newState = newState.copyWith(isFinished: true);
    }

    return newState;
  }
}
