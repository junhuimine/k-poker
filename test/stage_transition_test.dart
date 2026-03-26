// ignore_for_file: avoid_print
/// 🎴 K-Poker — 스테이지 전환 로직 검증 (flutter test)
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/data/stage_config.dart';

void main() {
  group('스테이지별 AI 캐릭터 매핑', () {
    final expected = {
      1: [['kim', '김 아저씨'], ['fox', '여우 수진']],
      2: [['yuna', '꽃집 유나'], ['dragon', '용남이']],
      3: [['miran', '여왕벌 미란'], ['monk', '무심 스님']],
      4: [['han', '그림자 한'], ['empress', '황후']],
      5: [['hana', '꽃무녀 하나'], ['phantom', '유령']],
      6: [['reaper', '사신'], ['oracle', '신녀']],
    };

    for (final entry in expected.entries) {
      for (int i = 0; i < entry.value.length; i++) {
        test('Stage ${entry.key} Op$i = ${entry.value[i][1]}', () {
          final ai = getAiForStage(entry.key, i);
          expect(ai.id, entry.value[i][0]);
          expect(ai.nameKo, entry.value[i][1]);
        });
      }
    }

    test('Stage 7 = 도박의 신', () {
      final ai = getAiForStage(7, 0);
      expect(ai.id, 'god');
      expect(ai.nameKo, '도박의 신');
    });

    test('Stage 8+ = 도박의 신 (무한)', () {
      for (int s = 8; s <= 10; s++) {
        final ai = getAiForStage(s, 0);
        expect(ai.id, 'god');
      }
    });
  });

  group('상대 자금', () {
    const pv = 1000.0;

    test('Stage 1 Op0 = ₩50,000', () {
      expect(getOpponentFund(1, 0, pv), 50000.0);
    });

    test('Stage 1 Op1 = ₩60,000 (1.2x)', () {
      expect(getOpponentFund(1, 1, pv), 60000.0);
    });

    test('Stage 6 Op0 = ₩3,000,000', () {
      expect(getOpponentFund(6, 0, pv), 3000000.0);
    });

    test('Stage 7 (신급) = ₩7,500,000', () {
      // loopCount=1 → 5000*1000*(1+0.5) = 7,500,000
      expect(getOpponentFund(7, 0, pv), 7500000.0);
    });

    test('Stage 8 (신급+2) > Stage 7', () {
      expect(getOpponentFund(8, 0, pv), greaterThan(getOpponentFund(7, 0, pv)));
    });
  });

  group('스테이지 전환 시뮬레이션', () {
    test('상대 자금 0 → 다음 상대/스테이지 전환', () {
      int stage = 1;
      int opIdx = 0;
      const pv = 1000.0;
      double opMoney = getOpponentFund(1, 0, pv);
      // ignore: unused_local_variable
      int stagesCleared = 0;

      // 스테이지별 예상 라운드당 수입 증가를 반영한 감소량
      // 높은 스테이지일수록 판돈이 커지므로 라운드당 수입도 증가
      double earningPerRound(int s) => 5000.0 * s;

      for (int round = 0; round < 2000; round++) {
        opMoney -= earningPerRound(stage);

        if (opMoney <= 0) {
          final clampedStage = stage.clamp(1, 6);
          final aiIds = stageAiMapping[clampedStage]!;
          if (opIdx + 1 < aiIds.length) {
            opIdx++;
            opMoney = getOpponentFund(stage, opIdx, pv);
          } else {
            stage++;
            opIdx = 0;
            stagesCleared++;
            if (stage >= 7) {
              opMoney = getOpponentFund(stage, 0, pv);
            } else {
              opMoney = getOpponentFund(stage, opIdx, pv);
            }
          }

          if (stage > 7) break; // 신도 이김
        }
      }

      // 도박의 신까지 도달 확인
      expect(stage, greaterThanOrEqualTo(7),
        reason: '스테이지 7(도박의 신)에 도달해야 함');
    });
  });

  group('StageConfig', () {
    test('Stage 1~6 설정 정상', () {
      for (int s = 1; s <= 6; s++) {
        final config = getStageConfig(s);
        expect(config.stage, s);
        expect(config.nameKo.isNotEmpty, true);
      }
    });

    test('Stage 7+ (신급 무한) 설정', () {
      final c7 = getStageConfig(7);
      expect(c7.nameKo, contains('신전'));

      final c8 = getStageConfig(8);
      expect(c8.stakeMultiplier, greaterThan(c7.stakeMultiplier));
    });
  });
}
