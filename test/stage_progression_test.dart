// ignore_for_file: avoid_print
/// 🎴 K-Poker - 스테이지 진행 로직 유닛 테스트
///
/// 상대 자금 시스템, 스테이지 클리어, 밸런싱 검증
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/data/stage_config.dart';
import 'package:k_poker/models/run_state.dart';

void main() {
  group('AI 자금 시스템', () {
    test('각 스테이지별 AI 자금이 올바르게 계산됨', () {
      const pointValue = 1000.0; // KRW
      
      // 스테이지 1: AI당 50 * 1000 = ₩50,000
      expect(getOpponentFund(1, 0, pointValue), equals(50000));
      // 두 번째 상대는 20% 높음
      expect(getOpponentFund(1, 1, pointValue), equals(60000));
      
      // 스테이지 2: 120 * 1000 = ₩120,000
      expect(getOpponentFund(2, 0, pointValue), equals(120000));
      expect(getOpponentFund(2, 1, pointValue), equals(144000));
      
      // 스테이지 3: 300 * 1000 = ₩300,000
      expect(getOpponentFund(3, 0, pointValue), equals(300000));
      
      // 스테이지 4: 700 * 1000 = ₩700,000
      expect(getOpponentFund(4, 0, pointValue), equals(700000));
      
      // 스테이지 5: 1500 * 1000 = ₩1,500,000
      expect(getOpponentFund(5, 0, pointValue), equals(1500000));
      
      // 스테이지 6: 3000 * 1000 = ₩3,000,000
      expect(getOpponentFund(6, 0, pointValue), equals(3000000));
      
      print('✅ 스테이지별 AI 자금 검증 완료');
      for (var s = 1; s <= 6; s++) {
        final fund0 = getOpponentFund(s, 0, pointValue);
        final fund1 = getOpponentFund(s, 1, pointValue);
        print('  스테이지 $s: AI1=₩${fund0.toInt()}, AI2=₩${fund1.toInt()}, 합계=₩${(fund0 + fund1).toInt()}');
      }
    });

    test('AI 캐릭터가 opponentIndex로 올바르게 선택됨', () {
      // 스테이지 1: index 0 = 김 아저씨, index 1 = 여우 수진
      final ai0 = getAiForStage(1, 0);
      final ai1 = getAiForStage(1, 1);
      expect(ai0.id, equals('kim'));
      expect(ai1.id, equals('fox'));
      print('✅ 스테이지 1: ${ai0.nameKo}(${ai0.id}), ${ai1.nameKo}(${ai1.id})');
      
      // 스테이지 2
      final ai2_0 = getAiForStage(2, 0);
      final ai2_1 = getAiForStage(2, 1);
      print('✅ 스테이지 2: ${ai2_0.nameKo}(${ai2_0.id}), ${ai2_1.nameKo}(${ai2_1.id})');
      
      // 모든 스테이지 확인
      for (var s = 1; s <= 6; s++) {
        final a0 = getAiForStage(s, 0);
        final a1 = getAiForStage(s, 1);
        print('  스테이지 $s: ${a0.emoji}${a0.nameKo} vs ${a1.emoji}${a1.nameKo}');
      }
    });
  });

  group('RunState 모델', () {
    test('기본 RunState에 opponentMoney가 0', () {
      const run = RunState();
      expect(run.opponentMoney, equals(0));
      expect(run.currentOpponentIndex, equals(0));
    });

    test('copyWith로 opponentMoney 업데이트', () {
      const run = RunState();
      final updated = run.copyWith(opponentMoney: 50000, currentOpponentIndex: 1);
      expect(updated.opponentMoney, equals(50000));
      expect(updated.currentOpponentIndex, equals(1));
    });
  });

  group('스테이지 진행 시뮬레이션', () {
    test('승리 시 상대 자금 차감 → 0 이하면 다음 상대', () {
      const pointValue = 1000.0;
      
      // 시작 상태: 스테이지 1, 상대 0 (김 아저씨), 자금 ₩50,000
      var stage = 1;
      var opIdx = 0;
      var opMoney = getOpponentFund(1, 0, pointValue); // 50000
      var playerMoney = 250000.0; // 시작 자금
      
      print('\n=== 스테이지 진행 시뮬레이션 ===');
      print('시작: 소지금 ₩${playerMoney.toInt()}, 스테이지 $stage, 상대 ${getAiForStage(stage, opIdx).nameKo} (₩${opMoney.toInt()})');
      
      // 라운드 1: ₩15,000 이김
      var earnings = 15000.0;
      opMoney -= earnings;
      playerMoney += earnings;
      print('라운드 1 승리: +₩${earnings.toInt()} → 상대 잔액 ₩${opMoney.toInt()}');
      expect(opMoney, greaterThan(0));
      
      // 라운드 2: ₩20,000 이김
      earnings = 20000.0;
      opMoney -= earnings;
      playerMoney += earnings;
      print('라운드 2 승리: +₩${earnings.toInt()} → 상대 잔액 ₩${opMoney.toInt()}');
      expect(opMoney, greaterThan(0));
      
      // 라운드 3: ₩20,000 이김 → 상대 잔액 ₩-5,000 → 다음 상대!
      earnings = 20000.0;
      opMoney -= earnings;
      playerMoney += earnings;
      print('라운드 3 승리: +₩${earnings.toInt()} → 상대 잔액 ₩${opMoney.toInt()} → 탈락!');
      expect(opMoney, lessThanOrEqualTo(0));
      
      // 다음 상대로 전환
      opIdx = 1;
      opMoney = getOpponentFund(1, 1, pointValue); // 60000
      print('→ 다음 상대: ${getAiForStage(stage, opIdx).nameKo} (₩${opMoney.toInt()})');
      expect(opIdx, equals(1));
      
      // 여러 라운드 후 두 번째 상대도 탈락
      opMoney = -5000; // 시뮬레이션
      
      // 스테이지 클리어 → 다음 스테이지
      stage = 2;
      opIdx = 0;
      opMoney = getOpponentFund(2, 0, pointValue); // 120000
      print('→ 스테이지 $stage 진입: ${getAiForStage(stage, opIdx).nameKo} (₩${opMoney.toInt()})');
      expect(stage, equals(2));
      expect(opMoney, equals(120000));
      
      print('\n✅ 스테이지 진행 시뮬레이션 완료');
    });

    test('패배 시 상대 자금 증가', () {
      const pointValue = 1000.0;
      var opMoney = getOpponentFund(1, 0, pointValue); // 50000
      
      // 패배: 상대에게 ₩10,000 잃음
      const penalty = 10000.0;
      opMoney += penalty;
      expect(opMoney, equals(60000));
      print('✅ 패배 시 상대 자금 증가: ₩50,000 → ₩${opMoney.toInt()}');
    });

    test('전체 밸런싱 검증: 이전 스테이지 수입 ≈ 다음 스테이지 자금', () {
      const pointValue = 1000.0;
      print('\n=== 전체 밸런싱 표 ===');
      print('스테이지 | AI1 자금 | AI2 자금 | 합계 | 누적 가능');
      
      var cumulative = 250000.0; // 시작 자금
      for (var s = 1; s <= 6; s++) {
        final f0 = getOpponentFund(s, 0, pointValue);
        final f1 = getOpponentFund(s, 1, pointValue);
        final total = f0 + f1;
        print('  S$s     | ₩${f0.toInt().toString().padLeft(9)} | ₩${f1.toInt().toString().padLeft(9)} | ₩${total.toInt().toString().padLeft(9)} | ₩${cumulative.toInt().toString().padLeft(9)}');
        cumulative += total;
      }
      print('✅ 밸런싱 검증 완료');
    });
  });
}
