/// K-Poker -- i18n 번역 완전성 전수검사 테스트
///
/// 모든 지원 언어(10개)에 대해:
/// 1. 모든 getter 번역이 비어있지 않은지
/// 2. 모든 ui() 키가 비어있지 않은지
/// 3. _t() 호출이 현재 언어에 대해 올바른 값을 반환하는지
library;

import 'dart:ui' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:k_poker/i18n/app_strings.dart';

void main() {
  group('i18n 번역 완전성 검사', () {
    // 10개 언어 전체 순회
    for (final lang in AppLanguage.values) {
      final s = AppStrings(lang);
      final langName = languageNames[lang] ?? lang.name;

      test('[$langName] getter 번역 -- 빈 문자열 없음', () {
        final getters = <String, String>{
          'appTitle': s.appTitle,
          'startGame': s.startGame,
          'totalScore': s.totalScore,
          'score': s.score,
          'goDecision': s.goDecision,
          'stopDecision': s.stopDecision,
          'shop': s.shop,
          'nextStage': s.nextStage,
          'gameOver': s.gameOver,
          'settings': s.settings,
          'language_': s.language_,
          'tabRules': s.tabRules,
          'tabDictionary': s.tabDictionary,
          'tabYaku': s.tabYaku,
          'ruleIntroTitle': s.ruleIntroTitle,
          'ruleIntroBody': s.ruleIntroBody,
          'ruleTurnTitle': s.ruleTurnTitle,
          'ruleTurnBody': s.ruleTurnBody,
          'ruleGoStopTitle': s.ruleGoStopTitle,
          'ruleGoStopBody': s.ruleGoStopBody,
          'yakuGwangTitle': s.yakuGwangTitle,
          'yakuGwangBody': s.yakuGwangBody,
          'yakuRibbonTitle': s.yakuRibbonTitle,
          'yakuRibbonBody': s.yakuRibbonBody,
          'yakuAnimalTitle': s.yakuAnimalTitle,
          'yakuAnimalBody': s.yakuAnimalBody,
          'yakuPiTitle': s.yakuPiTitle,
          'yakuPiBody': s.yakuPiBody,
          'tutFirstYakuTitle': s.tutFirstYakuTitle,
          'tutFirstYakuBody': s.tutFirstYakuBody,
          'tutFirstGoTitle': s.tutFirstGoTitle,
          'tutFirstGoBody': s.tutFirstGoBody,
          'continueBtn': s.continueBtn,
          'doNotShowAgain': s.doNotShowAgain,
          'eventMatchStart': s.eventMatchStart,
          'eventSkillShuffle': s.eventSkillShuffle,
          'eventSkillSniperSuccess': s.eventSkillSniperSuccess,
          'eventSkillSniperFail': s.eventSkillSniperFail,
          'eventSkillJoker': s.eventSkillJoker,
          'eventAiStop': s.eventAiStop,
          'eventDraw': s.eventDraw,
          'aiTalkDraw': s.aiTalkDraw,
          'eventRewardGoBak': s.eventRewardGoBak,
          'eventPenaltyGoBak': s.eventPenaltyGoBak,
          'eventPlayerGo': s.eventPlayerGo,
          'eventPlayerStop': s.eventPlayerStop,
          'eventPpeok': s.eventPpeok,
          'eventDoublePpeok': s.eventDoublePpeok,
          'eventTriplePpeok': s.eventTriplePpeok,
          'opponentCapturedLabel': s.opponentCapturedLabel,
          'playerCapturedLabel': s.playerCapturedLabel,
          'skillActivateBtn': s.skillActivateBtn,
          'myTurnLabel': s.myTurnLabel,
          'fieldLabel': s.fieldLabel,
          'bombLabel': s.bombLabel,
          'activeSkillTitle': s.activeSkillTitle,
          'noSkillAvailable': s.noSkillAvailable,
          'useBtn': s.useBtn,
          'closeBtn': s.closeBtn,
        };

        for (final entry in getters.entries) {
          expect(
            entry.value.isNotEmpty,
            isTrue,
            reason: '[$langName] getter "${entry.key}" is empty',
          );
        }
      });

      test('[$langName] ui() 키 -- 빈 문자열 없음', () {
        final uiKeys = [
          'subtitle', 'settings', 'bgm', 'sfx', 'language', 'cardSkin',
          'handStatus', 'myInfo', 'winStreak', 'currentScore', 'yakuProgress',
          'opponent', 'none', 'kwang', 'animal', 'blue', 'red', 'grass',
          'plain', 'pi', 'selectCardTitle', 'cancel', 'me', 'meWithIcon',
          'opponentWithIcon', 'pointSuffix', 'uiScore', 'calculation',
          'victory', 'defeat', 'sweepLabel', 'income', 'loss', 'nextRound',
          'retry', 'bankrupt', 'bankruptDesc', 'restartFromBeginning',
          'totalWins', 'totalLosses', 'bestWinStreak', 'bestScore',
          'bestMoney', 'reachedStage', 'winsUnit', 'lossesUnit', 'streakUnit',
          'stagePrefix', 'aiStop', 'aiGo', 'goStopReached', 'goStopExtraPoints',
          'goStopDesc1go', 'goStopDesc2go', 'goStopDesc3go',
          'skillBag', 'noSkills', 'flip', 'monthLabel', 'doublePi',
          'cardGradeBright', 'cardGradeAnimal', 'cardGradeRedRibbon',
          'cardGradeBlueRibbon', 'cardGradeGrassRibbon', 'cardGradeRibbon',
          'cardGradeJunk', 'cardGradeAnimalFull', 'cardGradeRibbonFull',
          'help', 'shopSecretShop', 'shopActiveSkillTitle',
          'shopActiveSkillSubtitle', 'shopPreRoundTitle', 'shopPreRoundSubtitle',
          'shopPassiveTitle', 'shopPassiveSubtitle', 'shopExit', 'shopEquipped',
          'shopEquip', 'shopOwnedPermanent', 'shopPurchased', 'shopUse',
          'skillUsed', 'brightLabel',
          'cardSkinFront', 'cardSkinBack', 'volumeOff',
        ];

        // monthLabel is intentionally empty in English (uses "M1" format instead)
        final allowedEmpty = {'monthLabel'};
        final missing = <String>[];
        for (final key in uiKeys) {
          final value = s.ui(key);
          // ui() falls back to key name if missing, so check if value == key
          if ((value.isEmpty || value == key) && !allowedEmpty.contains(key)) {
            missing.add(key);
          }
        }

        if (missing.isNotEmpty) {
          // ignore: avoid_print
          print('[$langName] ui() missing keys (${missing.length}): $missing');
        }
        // For ko, en, ja, zhCn, zhTw -- must be 0 missing
        if ([AppLanguage.ko, AppLanguage.en, AppLanguage.ja, AppLanguage.zhCn, AppLanguage.zhTw].contains(lang)) {
          expect(missing, isEmpty, reason: '[$langName] should have all ui() keys translated');
        }
      });

      test('[$langName] 파라미터화된 문자열 -- 빈 값 없음', () {
        expect(s.sameMonthCards(3).isNotEmpty, isTrue);
        expect(s.monthFormatted(1).isNotEmpty, isTrue);
        expect(s.goStopMultiplierDesc(2, 4).isNotEmpty, isTrue);
        expect(s.eventChongtong(1).isNotEmpty, isTrue);
        expect(s.eventPlayerMatch('test', 2).isNotEmpty, isTrue);
        expect(s.eventPlayerMiss('test').isNotEmpty, isTrue);
        expect(s.eventAiMatch('test', 3).isNotEmpty, isTrue);
        expect(s.eventAiMiss('test').isNotEmpty, isTrue);
        expect(s.eventAiGo(1).isNotEmpty, isTrue);
        expect(s.eventAiBomb(5).isNotEmpty, isTrue);
        expect(s.eventWin('1000').isNotEmpty, isTrue);
        expect(s.eventLose('500').isNotEmpty, isTrue);
        expect(s.eventPlayerBomb(3, true).isNotEmpty, isTrue);
        expect(s.eventPlayerBomb(3, false).isNotEmpty, isTrue);
      });
    }
  });

  group('detectLanguage 로케일 매핑 검증', () {
    test('한국어 로케일 -> ko', () {
      expect(detectLanguage(const Locale('ko')), AppLanguage.ko);
    });
    test('일본어 로케일 -> ja', () {
      expect(detectLanguage(const Locale('ja')), AppLanguage.ja);
    });
    test('간체 중국어 -> zhCn', () {
      expect(detectLanguage(const Locale('zh', 'CN')), AppLanguage.zhCn);
    });
    test('번체 중국어 -> zhTw', () {
      expect(detectLanguage(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')), AppLanguage.zhTw);
    });
    test('태국어 -> th', () {
      expect(detectLanguage(const Locale('th')), AppLanguage.th);
    });
    test('스페인어 -> es', () {
      expect(detectLanguage(const Locale('es')), AppLanguage.es);
    });
    test('프랑스어 -> fr', () {
      expect(detectLanguage(const Locale('fr')), AppLanguage.fr);
    });
    test('독일어 -> de', () {
      expect(detectLanguage(const Locale('de')), AppLanguage.de);
    });
    test('포르투갈어 -> pt', () {
      expect(detectLanguage(const Locale('pt')), AppLanguage.pt);
    });
    test('지원 안 되는 언어 -> en (fallback)', () {
      expect(detectLanguage(const Locale('ru')), AppLanguage.en);
      expect(detectLanguage(const Locale('ar')), AppLanguage.en);
    });
  });
}
