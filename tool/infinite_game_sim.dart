import 'dart:math';

import '../lib/models/card_def.dart';
import '../lib/models/round_state.dart';
import '../lib/models/run_state.dart';
import '../lib/engine/game_engine.dart';
import '../lib/engine/score_calculator.dart';
import '../lib/engine/card_matcher.dart';

void main() {
  print('Starting Infinite K-Poker Simulation...');
  final random = Random();
  int gamesPlayed = 0;
  int crashCount = 0;
  
  while (gamesPlayed < 500000) {
    gamesPlayed++;
    // print('Game $gamesPlayed...');
    
    try {
      final run = RunState(
        stage: 1,
        money: 10000,
        currentOpponentIndex: 0,
        opponentMoney: 10000,
      );
      
      var state = GameEngine.createInitialState(run: run);
      state = state.copyWith(
        currentTurn: 'player',
        isFinished: false,
      );
      
      int maxTurns = 200; // infinite loop prevention
      int turns = 0;
      
      while (!state.isFinished && turns < maxTurns) {
        turns++;
        final isPlayer = state.currentTurn == 'player';
        final hand = isPlayer ? state.playerHand : state.opponentHand;
        
        if (hand.isEmpty) {
          // If hand is empty, usually game finishes or nagari. We force finish here to avoid infinite loops if engine doesn't handle it well.
          state = state.copyWith(isFinished: true);
          break;
        }

        // --- 1. Decide card to play ---
        CardInstance playedCard = hand[random.nextInt(hand.length)];

        // --- 2. Decide target on field if ambiguity exists ---
        CardInstance? selectedMatch;
        final matchable = findMatchableCards(playedCard, state.field);
        if (matchable.length >= 2) {
          // It could be 2 or 3 same month cards on the field.
          if (matchable.length == 2) {
            // Need to pick one.
            selectedMatch = matchable[random.nextInt(matchable.length)];
          }
        }

        // --- 3. Execute Turn ---
        state = GameEngine.playTurn(state, playedCard, selectedMatch: selectedMatch, run: run);

        // --- 4. Evaluate Score & Go/Stop logic ---
        bool goStopTriggered = false;
        
        // Let's assume after the turn, if it was player's turn, we calculate player's score.
        // Wait, playTurn might flip the turn at the end via _advanceTurn!
        // So the player who JUST played is what we need to evaluate.
        final justPlayed = isPlayer ? 'player' : 'opponent';
        final evalScoreState = state;
        
        if (justPlayed == 'player') {
          final result = ScoreCalculator.calculate(evalScoreState, run);
          state = state.copyWith(playerScore: result.finalScore);
          
          if (result.finalScore >= 3) {
            // Did player just cross the threshold or get a new point while pending Go?
            // Real logic uses a threshold memory, but we can just say if score > (some tracked score), or randomly decide.
            // Let's just say a random chance to Go if goCount < 5, else Stop.
            if (state.goCount < 5 && random.nextBool()) { // Go
              state = state.copyWith(
                goCount: state.goCount + 1,
                // In game_providers.dart `declareGo` doesn't change turn, wait, if we say Go, we just continue. 
                // Wait! does player saying Go skip opponent's turn? No! `currentTurn` remains whatever `playTurn` set it to!
              );
            } else { // Stop
              state = state.copyWith(isFinished: true);
              break;
            }
          }
        } else {
          // AI logic for evaluate
          final aiScoreState = state.copyWith(
            playerCaptured: state.opponentCaptured,
            opponentCaptured: state.playerCaptured,
            goCount: state.opponentGoCount,
          );
          final result = ScoreCalculator.calculate(aiScoreState, run);
          state = state.copyWith(opponentScore: result.finalScore);
          
          if (result.finalScore >= 3) {
            if (state.opponentGoCount < 3 && random.nextDouble() > 0.3) {
              state = state.copyWith(opponentGoCount: state.opponentGoCount + 1);
            } else {
              state = state.copyWith(isFinished: true);
              break;
            }
          }
        }
      }
      
      if (turns >= maxTurns) {
        print('Game $gamesPlayed: INFINITE LOOP OR EXCEEDED MAX TURNS! Turns: $turns. State: $state');
      }
      
    } catch (e, stackTrace) {
      crashCount++;
      print('CRASH on Game $gamesPlayed: $e');
      print(stackTrace);
    }
  }
  
  print('Simulation Finished. Total Games: $gamesPlayed. Total Crashes: $crashCount');
}
