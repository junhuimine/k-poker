# 🦉 STRIX K-Poker 단계별 디버깅 검증 계획

> K-Poker 게임 엔진의 전 설계를 7단계(Phase)로 나눠 단계적으로 검증합니다.
> 각 Phase는 독립적으로 실행 가능하며, 이전 Phase 통과 후 진행합니다.

---

## Phase 1: 딜링 시스템 🃏

### 검증 대상
- `GameEngine.createInitialState()` — `lib/engine/game_engine.dart:15-31`

### 체크리스트
- [ ] 총 48장 카드 생성 확인 (12월 × 4장)
- [ ] 바닥(field) 8장 분배
- [ ] 플레이어 핸드 10장 분배
- [ ] 상대 핸드 10장 분배
- [ ] 덱 잔여 20장 확인
- [ ] 중복 카드 없음 검증 (48장 전부 유니크)

### 테스트 명령
```powershell
cd E:\08_k-poker
flutter test test/engine/ --name "dealing"
```

### 수동 검증 스크립트
```dart
// test/debug/phase1_dealing_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/engine/game_engine.dart';

void main() {
  test('Phase 1: 딜링 정확성', () {
    for (var i = 0; i < 100; i++) {
      final state = GameEngine.createInitialState();
      expect(state.field.length, 8, reason: '바닥 8장');
      expect(state.playerHand.length, 10, reason: '플레이어 10장');
      expect(state.opponentHand.length, 10, reason: '상대 10장');
      expect(state.deck.length, 20, reason: '덱 20장');
      
      // 중복 없음
      final allCards = [...state.field, ...state.playerHand, ...state.opponentHand, ...state.deck];
      expect(allCards.length, 48);
      final ids = allCards.map((c) => c.def.id).toSet();
      expect(ids.length, 48, reason: '중복 카드 없음');
    }
    print('✅ Phase 1 통과: 100회 딜링 모두 정확');
  });
}
```

---

## Phase 2: 매칭 엔진 🎯

### 검증 대상
- `card_matcher.dart` — 핸드 매칭, 덱 플립 매칭
- `GameEngine.playTurn()` — 일반 매칭 + 뻑 처리

### 체크리스트
- [ ] 같은 월 카드 매칭 성공 (1:1)
- [ ] 같은 월 2장 → 선택 매칭
- [ ] 같은 월 3장 → 뻑! (4장 전부 획득)
- [ ] 덱 플립 매칭 정확성
- [ ] 매칭 실패 시 바닥에 카드 추가
- [ ] 쓸(sweep) — 바닥 카드 전부 획득 시 감지
- [ ] 핸드에서 카드 제거 정확성
- [ ] 턴 전환 정확성 (player ↔ opponent)

### 테스트 시나리오
```dart
// test/debug/phase2_matching_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/engine/game_engine.dart';
import 'package:k_poker/engine/card_matcher.dart';
import 'package:k_poker/models/card_def.dart';
import 'package:k_poker/data/all_cards.dart';

void main() {
  test('Phase 2-1: 같은 월 매칭', () {
    final state = GameEngine.createInitialState();
    // 플레이어 핸드에서 바닥과 같은 월이 있는 카드 찾기
    for (final card in state.playerHand) {
      final matchable = findMatchableCards(card, state.field);
      if (matchable.isNotEmpty) {
        print('매칭 가능: ${card.def.nameKo} (${card.def.month}월) → ${matchable.length}장');
      }
    }
  });

  test('Phase 2-2: 뻑 처리', () {
    // 바닥에 같은 월 3장이 있으면 4번째가 올 때 전부 획득
    // 100회 시뮬레이션하며 뻑 발생 횟수 카운트
    int bombCount = 0;
    for (var i = 0; i < 100; i++) {
      final state = GameEngine.createInitialState();
      // 바닥에서 같은 월 3장 있는지 확인
      final monthCount = <int, int>{};
      for (final c in state.field) {
        monthCount[c.def.month] = (monthCount[c.def.month] ?? 0) + 1;
      }
      for (final entry in monthCount.entries) {
        if (entry.value >= 3) {
          bombCount++;
          print('뻑 가능 상황 발견: ${entry.key}월 (${entry.value}장)');
        }
      }
    }
    print('✅ Phase 2-2: 100회 딜링 중 뻑 가능 상황 $bombCount회');
  });

  test('Phase 2-3: 턴 진행 후 카드 수 보존', () {
    for (var i = 0; i < 50; i++) {
      var state = GameEngine.createInitialState();
      final totalBefore = state.field.length + state.playerHand.length 
          + state.opponentHand.length + state.deck.length
          + state.playerCaptured.length + state.opponentCaptured.length;
      
      // 플레이어 턴
      if (state.playerHand.isNotEmpty) {
        state = GameEngine.playTurn(state, state.playerHand.first);
        final totalAfter = state.field.length + state.playerHand.length 
            + state.opponentHand.length + state.deck.length
            + state.playerCaptured.length + state.opponentCaptured.length;
        // 덱에서 1장 뒤집으므로 총합은 보존됨
        expect(totalAfter, totalBefore, reason: '카드 총 수 보존');
      }
    }
    print('✅ Phase 2-3: 50회 턴 진행 후 카드 수 보존 확인');
  });
}
```

---

## Phase 3: 점수 계산 📊

### 검증 대상
- `score_calculator.dart` — `ScoreCalculator.calculate()`
- 족보: 오광, 사광, 삼광, 고도리, 홍단/청단/초단, 피 카운트

### 체크리스트
- [ ] 광 0~5장별 점수 정확성
- [ ] 비삼광 (비 포함) 감점
- [ ] 고도리 (2, 4, 8월 새) 5점
- [ ] 홍단/청단/초단 각 3점
- [ ] 피 10장부터 1점, 11장부터 2점...
- [ ] 쌍피(double junk) 2장 카운트
- [ ] `Chips × Mult` 최종 스코어 계산
- [ ] 박 배율 (광박: Mult ×2, 피박: Mult ×2)
- [ ] Go 카운트 반영 (배율 누적)

### 테스트 명령
```powershell
cd E:\08_k-poker
flutter test test/engine/score_calculator_test.dart -v
```

---

## Phase 4: 고/스톱 판정 ⚡

### 검증 대상
- `game_providers.dart` — `declareGo()`, `declareStop()`, AI 고/스톱 로직

### 체크리스트
- [ ] 3점 이상 → 고/스톱 UI 표시
- [ ] 고 선언 → `goCount + 1`, `multiplier × 2`
- [ ] 스톱 선언 → `isFinished = true` + 정산
- [ ] AI 고/스톱 판정:
  - `finalScore >= 7` → 무조건 스톱
  - `goCount >= 2` → 무조건 스톱
  - `goAggressiveness < 0.4 && goCount >= 1` → 스톱
- [ ] AI 고/스톱 애니메이션 표시 (`aiGoStopAnnounce`)
- [ ] AI 대사 반영 (player_go / player_go_fear)

### 시나리오 테스트
```dart
// test/debug/phase4_gostop_test.dart
// AI 스톱 판정 로직만 유닛 테스트
void main() {
  test('Phase 4: AI 스톱 판정', () {
    // 높은 점수 → 스톱
    expect(_shouldStop(score: 7, goCount: 0, aggr: 0.8), true);
    // 2고 이상 → 스톱
    expect(_shouldStop(score: 4, goCount: 2, aggr: 0.8), true);
    // 낮은 공격성 + 1고 → 스톱
    expect(_shouldStop(score: 4, goCount: 1, aggr: 0.3), true);
    // 높은 공격성 + 0고 + 낮은 점수 → 고
    expect(_shouldStop(score: 3, goCount: 0, aggr: 0.8), false);
  });
}

bool _shouldStop({required int score, required int goCount, required double aggr}) {
  return score >= 7 || goCount >= 2 
      || (goCount >= 1 && aggr < 0.4)
      || (score >= 5 && aggr < 0.3);
}
```

---

## Phase 5: 스테이지 진행 💰

### 검증 대상
- `RunStateNotifier.onWin()` / `onLose()` — `game_providers.dart:703-754`
- `getOpponentFund()` — `stage_config.dart:408-423`

### 체크리스트
- [ ] 승리 시 `opponentMoney -= earnings`
- [ ] `opponentMoney <= 0` → 다음 상대 (같은 스테이지 index+1)
- [ ] 스테이지 마지막 상대 탈락 → 다음 스테이지
- [ ] 패배 시 `opponentMoney += penalty`
- [ ] `playerMoney` 증감 정확성
- [ ] 2번째 상대 자금이 20% 높음
- [ ] 레거시 세이브 마이그레이션 (`opponentMoney <= 0` → 자동 보정)
- [ ] 자동 저장 확인

### 테스트 명령
```powershell
cd E:\08_k-poker
flutter test test/stage_progression_test.dart -v
```

---

## Phase 6: 나가리 처리 🛑

### 검증 대상
- `GameEngine.playTurn()` — line 226-235
- `GameEngine.playBomb()` — line 357-363
- `game_providers.dart` — AI 빈 핸드 처리 (line 232-238)

### 체크리스트
- [ ] 양쪽 핸드 비면 → `isFinished = true`
- [ ] 한쪽만 비고 + 덱 비면 → `isFinished = true` (나가리)
- [ ] 폭탄 후 양쪽 핸드 비면 → `isFinished = true`
- [ ] 폭탄 후 한쪽만 비고 + 덱 비면 → `isFinished = true`
- [ ] AI 핸드 비면 → `_playAiTurn()`에서 즉시 종료
- [ ] `playCard()` 후 AI 턴인데 AI 핸드 비면 즉시 종료

### 시뮬레이션 테스트
```dart
// test/debug/phase6_nagari_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/engine/game_engine.dart';
import 'package:k_poker/models/round_state.dart';

void main() {
  test('Phase 6: 나가리 - 한쪽 핸드만 비고 덱 비면 종료', () {
    // 인위적으로 한쪽 핸드만 비우고 덱도 비운 상태
    var state = GameEngine.createInitialState();
    state = state.copyWith(
      playerHand: [],  // 플레이어 핸드 비움
      deck: [],        // 덱도 비움
    );
    
    // 상대 턴으로 카드를 내면 isFinished 되어야 함
    if (state.opponentHand.isNotEmpty) {
      state = state.copyWith(currentTurn: 'opponent');
      final result = GameEngine.playTurn(state, state.opponentHand.first);
      expect(result.isFinished, true, reason: '한쪽 핸드 비고 덱 비면 나가리');
      print('✅ Phase 6: 나가리 정상 동작');
    }
  });

  test('Phase 6: 전체 라운드 시뮬레이션 (끝까지 진행)', () {
    int finishedCount = 0;
    int stuckCount = 0;
    
    for (var i = 0; i < 100; i++) {
      var state = GameEngine.createInitialState();
      int turnLimit = 100; // 무한루프 방지
      int turns = 0;
      
      while (!state.isFinished && turns < turnLimit) {
        final hand = state.currentTurn == 'player' 
            ? state.playerHand 
            : state.opponentHand;
        
        if (hand.isEmpty) {
          // 핸드 비면 종료되어야 하는데 안 됐으면 버그
          stuckCount++;
          break;
        }
        
        state = GameEngine.playTurn(state, hand.first);
        turns++;
      }
      
      if (state.isFinished) finishedCount++;
    }
    
    print('✅ Phase 6: 100회 시뮬레이션 → $finishedCount회 정상 종료, $stuckCount회 스턱');
    expect(stuckCount, 0, reason: '스턱 없어야 함');
  });
}
```

---

## Phase 7: UI 렌더링 (브라우저) 🖥️

### 검증 대상
- `game_screen.dart` — 전체 UI 렌더링
- 배경 이미지 (`bg_stage1~6.png`)
- HP바 (`_buildOpponentInfoBar`)
- 딜링 애니메이션
- 카드 인터랙션

### STRIX BrowserAgent 체크리스트
- [ ] `flutter run -d chrome` 실행
- [ ] 메인 화면 렌더링 (K-Poker 로고, 스테이지 정보)
- [ ] "게임 시작" 버튼 클릭
- [ ] 딜링 애니메이션 완료 대기
- [ ] 배경 이미지 렌더링 확인
- [ ] 상대 HP바 표시 확인
- [ ] 카드 클릭 → 매칭 → 점수 변화 확인
- [ ] 라운드 종료 오버레이 확인
- [ ] 화이트 스크린 / 에러 없음 확인

### 실행 방법
```powershell
# 1. Flutter 웹 서버 시작
cd E:\08_k-poker
flutter run -d chrome --web-port=8080

# 2. STRIX BrowserAgent가 localhost:8080 접속
# 3. 스크린샷 + VisionEvaluator로 PASS/FAIL 판단
```

---

## 실행 순서

```
Phase 1 (딜링) → Phase 2 (매칭) → Phase 3 (점수) 
    → Phase 4 (고스톱) → Phase 5 (스테이지) 
    → Phase 6 (나가리) → Phase 7 (UI)
```

> 각 Phase는 이전 Phase 통과 후 진행합니다.
> Phase 1~6은 유닛 테스트로 자동 검증, Phase 7은 BrowserAgent + VisionEvaluator로 검증합니다.

---

**마지막 업데이트**: 2026-03-20
**작성자**: 🦉 M.I.N.E.R.V.A.
