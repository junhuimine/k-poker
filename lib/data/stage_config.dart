/// 🎴 K-Poker -- 화폐/판돈/스테이지/AI 캐릭터 설정
///
/// 국가별 화폐, 스테이지별 판돈, AI 11명(남6/여4/신급1) 정의

/// 국가별 화폐 설정
class CurrencyConfig {
  final String locale;     // 'ko', 'en', 'ja', 'zh', 'es' 등
  final String symbol;     // '₩', '$', '¥', '€'
  final String name;       // '원', 'Dollar', '円' 등
  final double pointValue; // 점당 금액
  final String format;     // 포맷 패턴

  const CurrencyConfig({
    required this.locale,
    required this.symbol,
    required this.name,
    required this.pointValue,
    this.format = '#,###',
  });

  /// 금액 포맷팅
  String formatAmount(double amount) {
    if (amount >= 1000000000) {
      return '$symbol${(amount / 100000000).toStringAsFixed(1)}억';
    }
    if (amount >= 100000000) {
      return '$symbol${(amount / 100000000).toStringAsFixed(0)}억';
    }
    if (amount >= 10000 && locale == 'ko') {
      return '$symbol${(amount / 10000).toStringAsFixed(0)}만';
    }
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(locale == 'ko' ? 0 : 1)}${locale == 'ko' ? ',000' : 'K'}';
    }
    return '$symbol${amount.toStringAsFixed(locale == 'ko' || locale == 'ja' ? 0 : 2)}';
  }

  /// 정확한 금액 표시
  String formatExact(double amount) {
    if (locale == 'ko' || locale == 'ja') {
      return '$symbol${amount.round().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}

/// 지원하는 화폐 목록
const Map<String, CurrencyConfig> currencies = {
  'ko': CurrencyConfig(locale: 'ko', symbol: '₩', name: '원', pointValue: 1000),
  'en': CurrencyConfig(locale: 'en', symbol: '\$', name: 'Dollar', pointValue: 0.50),
  'ja': CurrencyConfig(locale: 'ja', symbol: '¥', name: '円', pointValue: 50),
  'zh': CurrencyConfig(locale: 'zh', symbol: '¥', name: '元', pointValue: 2),
  'es': CurrencyConfig(locale: 'es', symbol: '€', name: 'Euro', pointValue: 0.50),
  'fr': CurrencyConfig(locale: 'fr', symbol: '€', name: 'Euro', pointValue: 0.50),
  'de': CurrencyConfig(locale: 'de', symbol: '€', name: 'Euro', pointValue: 0.50),
  'pt': CurrencyConfig(locale: 'pt', symbol: 'R\$', name: 'Real', pointValue: 2.50),
  'ru': CurrencyConfig(locale: 'ru', symbol: '₽', name: 'Рубль', pointValue: 45),
  'ar': CurrencyConfig(locale: 'ar', symbol: '\$', name: 'Dollar', pointValue: 0.50),
};

/// 로케일에 맞는 화폐 가져오기
CurrencyConfig getCurrencyForLocale(String langCode) {
  return currencies[langCode] ?? currencies['en']!;
}

/// AI 캐릭터 정의 (남6 / 여4 / 신급1 = 11명)
class AiCharacter {
  final String id;
  final String nameKo;
  final String nameEn;
  final String avatarFile;
  final String gender;
  final String emoji;
  final double matchPriority;
  final double goAggressiveness;
  final Map<String, List<String>> dialogues; // 상황별 대사

  const AiCharacter({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.avatarFile,
    required this.gender,
    required this.emoji,
    required this.matchPriority,
    required this.goAggressiveness,
    this.dialogues = const {},
  });

  /// 상황별 랜덤 대사 반환
  String? getDialogue(String situation) {
    final lines = dialogues[situation];
    if (lines == null || lines.isEmpty) return null;
    return lines[DateTime.now().millisecond % lines.length];
  }
}

/// AI 캐릭터 11명 전체 목록
const List<AiCharacter> allAiCharacters = [
  // ── 스테이지 1: 동네 골목 ──
  AiCharacter(id: 'kim', nameKo: '김 아저씨', nameEn: 'Mr. Kim',
    avatarFile: 'ai_kim.png', gender: 'male', emoji: '👴',
    matchPriority: 0.30, goAggressiveness: 0.10,
    dialogues: {
      'match': ['허허, 먹었다~', '이야~ 딱이네!', '좋아좋아~'],
      'miss': ['에잇...', '쯧, 안 맞네', '흠...'],
      'bomb': ['어허! 폭탄이다!', '쿵!!! 다 내놔!'],
      'go': ['음... 한번 더!', '고! ...맞나?'],
      'stop': ['이 정도면 됐어', '여기서 멈추지~'],
      'win': ['허허~ 이 정도는 해야지~', '역시 경험이야!'],
      'lose': ['젊은이한테 졌구만...', '자네 실력이 좋네~'],
    }),
  AiCharacter(id: 'fox', nameKo: '여우 수진', nameEn: 'Fox Sujin',
    avatarFile: 'ai_fox.png', gender: 'female', emoji: '🦊',
    matchPriority: 0.38, goAggressiveness: 0.15,
    dialogues: {
      'match': ['후후~ 먹었다♡', '이건 내 거~', '캬~!'],
      'miss': ['앗...', '으응? 안 맞네?', '치~'],
      'bomb': ['폭탄이다~! 겁나죠?♡', '꿰뚫었지롱~'],
      'go': ['고~♡ 한번만 더!', '아직 끝이 아니야~'],
      'stop': ['이만하면 됐지♡', '칭찬해줘~'],
      'win': ['후후~ 내가 이겼다♡', '여우한테 당했지?'],
      'lose': ['끄응... 다음엔 안 져!', '살살 좀...!'],
    }),

  // ── 스테이지 2: 시장 판 ──
  AiCharacter(id: 'yuna', nameKo: '꽃집 유나', nameEn: 'Flower Yuna',
    avatarFile: 'ai_yuna.png', gender: 'female', emoji: '🌸',
    matchPriority: 0.45, goAggressiveness: 0.20,
    dialogues: {
      'match': ['예쁜 꽃이네~', '이건 제 거예요!'],
      'miss': ['어머...', '꽃이 안 피었네요...'],
      'go': ['조금만 더...!', '고! 꽃을 더 모을래요!'],
      'stop': ['이 정도면 예쁜 꽃다발이에요~', '스톱!'],
    }),
  AiCharacter(id: 'dragon', nameKo: '용남이', nameEn: 'Dragon Nam',
    avatarFile: 'ai_dragon.png', gender: 'male', emoji: '🐉',
    matchPriority: 0.52, goAggressiveness: 0.30,
    dialogues: {
      'match': ['크크, 먹었다!', '오라! 내 손으로!'],
      'miss': ['체...', '재수 없군...'],
      'bomb': ['용의 일격!!!', '폭탄이다!!!'],
      'go': ['고다! 겁먹었냐!', '아직이다!'],
      'stop': ['흥, 이 정도면 됐다', '여기서 멈춘다'],
    }),

  // ── 스테이지 3: 도시 카지노 ──
  AiCharacter(id: 'miran', nameKo: '여왕벌 미란', nameEn: 'Queen Bee Miran',
    avatarFile: 'ai_miran.png', gender: 'female', emoji: '👑',
    matchPriority: 0.60, goAggressiveness: 0.35,
    dialogues: {
      'match': ['후후, 내 손바닥 위야~', '이건 여왕의 것!'],
      'miss': ['흥... 재미없네', '운이 없군'],
      'go': ['고! 여왕은 멈추지 않아!', '아직이야~'],
      'stop': ['이 정도면 충분해', '우아하게 마무리~'],
      'win': ['당연한 결과야~', '후후, 여왕답지?'],
      'lose': ['이런... 기억해둘게', '다음엔 안 봐줘!'],
      'gwangbak': ['아이쿠야...! 광이 없잖아!'],
    }),
  AiCharacter(id: 'monk', nameKo: '무심 스님', nameEn: 'Monk Musim',
    avatarFile: 'ai_monk.png', gender: 'male', emoji: '🧘',
    matchPriority: 0.65, goAggressiveness: 0.40,
    dialogues: {
      'match': ['인연이로다...', '나무아미타불...'],
      'miss': ['무상하도다...', '인연이 아니었나...'],
      'go': ['한 수 더 두겠소', '고... 수행의 길이니'],
      'stop': ['이만하면 족하오', '만족을 알아야 하오'],
      'win': ['부처님의 뜻이었소', '공덕을 쌓았구려'],
      'lose': ['결과에 집착 않겠소', '수행이 부족했소'],
    }),

  // ── 스테이지 4: 지하 도박장 ──
  AiCharacter(id: 'han', nameKo: '그림자 한', nameEn: 'Shadow Han',
    avatarFile: 'ai_han.png', gender: 'male', emoji: '🌑',
    matchPriority: 0.75, goAggressiveness: 0.50,
    dialogues: {
      'match': ['...먹었다', '그림자는 놓치지 않아'],
      'miss': ['...', '흥'],
      'bomb': ['사라져라...', '끝이다...'],
      'go': ['...고', '아직이다...'],
      'stop': ['...여기까지다', '충분해'],
      'win': ['예상대로야...', '어둠 속에서 빛을 보았다'],
      'lose': ['...인정한다', '다음엔 없을 거다'],
    }),
  AiCharacter(id: 'empress', nameKo: '황후', nameEn: 'The Empress',
    avatarFile: 'ai_empress.png', gender: 'female', emoji: '👸',
    matchPriority: 0.78, goAggressiveness: 0.55,
    dialogues: {
      'match': ['오호호~ 가져가마', '황후의 손길이란~'],
      'miss': ['거슬리는군...', '불경한 패로다!'],
      'go': ['고다! 황후의 명이다!', '아직이야!'],
      'stop': ['황후가 만족하셨다', '이 정도면 됐어'],
      'win': ['당연한 결과야~', '고개를 숙여라!'],
      'lose': ['이... 불경한!', '다음엔 참수야!'],
      'gwangbak': ['오호호~ 광이 없다니!'],
    }),

  // ── 스테이지 5: 꽃패의 사원 ──
  AiCharacter(id: 'hana', nameKo: '꽃무녀 하나', nameEn: 'Priestess Hana',
    avatarFile: 'ai_hana.png', gender: 'female', emoji: '🌺',
    matchPriority: 0.85, goAggressiveness: 0.60,
    dialogues: {
      'match': ['꽃이 피었어요~', '자연의 섭리...'],
      'miss': ['시들었네요...', '아직 봄이 아닌가봐...'],
      'go': ['꽃은 더 필 거예요!', '고! 활짝!'],
      'stop': ['이 정도면 예쁜 정원이에요~'],
      'win': ['꽃이 승리를 축하해요~'],
      'lose': ['지는 꽃에도 아름다움이...'],
    }),
  AiCharacter(id: 'phantom', nameKo: '유령', nameEn: 'The Phantom',
    avatarFile: 'ai_phantom.png', gender: 'male', emoji: '👻',
    matchPriority: 0.88, goAggressiveness: 0.65,
    dialogues: {
      'match': ['크크크... 보여', '스윽...!'],
      'miss': ['흐음...?', '...재미없군'],
      'bomb': ['부우우!!! 폭탄이다!!!'],
      'go': ['크크크... 고다!', '아직 끝이 아니야...'],
      'stop': ['크크... 충분해', '이 정도면 됐어...'],
      'win': ['하하하하!!! 내 승리다!'],
      'lose': ['우우... 사라진다...'],
    }),

  // ── 스테이지 6: 도박의 신전 ──
  AiCharacter(id: 'reaper', nameKo: '사신', nameEn: 'The Reaper',
    avatarFile: 'ai_reaper.png', gender: 'male', emoji: '💀',
    matchPriority: 0.90, goAggressiveness: 0.70,
    dialogues: {
      'match': ['...수확이다', '죽음의 낫이 지나간다'],
      'miss': ['아직... 때가 아니군', '...'],
      'bomb': ['저승 폭탄...!', '다 가져간다...'],
      'go': ['고... 죽음은 기다린다', '아직이다...'],
      'stop': ['이만하면 됐다... 다음에 데려가지'],
      'win': ['네 운명이었다...', '저승에서 만나자...'],
      'lose': ['흥... 이번만이다', '죽음은... 패배하지 않아'],
    }),
  AiCharacter(id: 'oracle', nameKo: '신녀', nameEn: 'The Oracle',
    avatarFile: 'ai_oracle.png', gender: 'female', emoji: '🔮',
    matchPriority: 0.92, goAggressiveness: 0.75,
    dialogues: {
      'match': ['이미 보았어요...', '예언대로...'],
      'miss': ['미래가... 흔들리네요', '이것도 운명...'],
      'go': ['신탁이 말해요... 고!', '아직 끝이 아니에요'],
      'stop': ['별들이 멈추라 해요', '이만...'],
      'win': ['예언 그대로예요~', '별들의 뜻이에요'],
      'lose': ['미래가... 바뀌었어요?!', '이럴 수가...!'],
    }),

  // ── 신급 무한: 최종 보스 ──
  AiCharacter(id: 'god', nameKo: '도박의 신', nameEn: 'God of Gamble',
    avatarFile: 'ai_god.png', gender: 'divine', emoji: '🌌',
    matchPriority: 0.95, goAggressiveness: 0.80,
    dialogues: {
      'match': ['하하하! 당연하지!', '신의 손길이다!'],
      'miss': ['흥... 재미로 놓쳐준 거다', '...'],
      'bomb': ['천벌이다!!!', '우주가 폭발한다!!!'],
      'go': ['고!!! 신은 멈추지 않는다!', '끝없는 승리!'],
      'stop': ['이만하면 됐다... 오늘은', '자비를 베풀어주지'],
      'win': ['하하하! 신에게 도전하다니!', '당연한 결과다!'],
      'lose': ['이... 불가능해...!', '너는... 대체 누구냐?!'],
      'gwangbak': ['하하하! 광이 없다니 한심하군!'],
    }),
];

/// 스테이지별 AI 매핑 (각 스테이지 2명 + 신급 1명 = 13명)
const Map<int, List<String>> stageAiMapping = {
  1: ['kim', 'fox'],
  2: ['yuna', 'dragon'],
  3: ['miran', 'monk'],
  4: ['han', 'empress'],
  5: ['hana', 'phantom'],
  6: ['reaper', 'oracle'],
  7: ['god'], // 신급 무한
};

/// 스테이지에서 AI 캐릭터 가져오기 (판 번호에 따라 교대)
AiCharacter getAiForStage(int stage, int roundNumber) {
  final clampedStage = stage.clamp(1, 6);
  final aiIds = stageAiMapping[clampedStage]!;
  final index = roundNumber % aiIds.length;
  final aiId = aiIds[index];
  return allAiCharacters.firstWhere((c) => c.id == aiId);
}

/// 스테이지 설정
class StageConfig {
  final int stage;
  final String name;
  final String nameKo;
  final String emoji;
  final double stakeMultiplier; // 시작 판돈 배율 (점당금액 기준)
  final String bgFile;          // 배경 이미지 파일명

  const StageConfig({
    required this.stage,
    required this.name,
    required this.nameKo,
    required this.emoji,
    required this.stakeMultiplier,
    required this.bgFile,
  });

  /// 이 스테이지의 판돈 계산
  double getStake(double pointValue) => stakeMultiplier * pointValue;
}

/// 6스테이지 + 신급 무한 (판돈: ₩5만 → ₩1억)
const List<StageConfig> stageConfigs = [
  StageConfig(stage: 1, name: 'Alley',       nameKo: '동네 골목',     emoji: '🏠', stakeMultiplier: 50,     bgFile: 'bg_stage1.png'),
  StageConfig(stage: 2, name: 'Market',      nameKo: '시장 판',       emoji: '🏪', stakeMultiplier: 200,    bgFile: 'bg_stage2.png'),
  StageConfig(stage: 3, name: 'Casino',      nameKo: '도시 카지노',   emoji: '🏨', stakeMultiplier: 1000,   bgFile: 'bg_stage3.png'),
  StageConfig(stage: 4, name: 'Underground', nameKo: '지하 도박장',   emoji: '🌃', stakeMultiplier: 5000,   bgFile: 'bg_stage4.png'),
  StageConfig(stage: 5, name: 'Temple',      nameKo: '꽃패의 사원',   emoji: '⛩️', stakeMultiplier: 20000,  bgFile: 'bg_stage5.png'),
  StageConfig(stage: 6, name: 'Shrine',      nameKo: '도박의 신전',   emoji: '🌌', stakeMultiplier: 100000, bgFile: 'bg_stage6.png'),
];

/// 스테이지 설정 가져오기 (신급 무한은 stage 6 재사용 + 판돈 증가)
StageConfig getStageConfig(int stage) {
  if (stage <= 6) return stageConfigs[stage - 1];
  // 신급 무한: stage 6 설정 + 판돈 50% 증가 (반복마다)
  final godStage = stageConfigs[5];
  final loopCount = stage - 6;
  return StageConfig(
    stage: stage,
    name: 'Shrine +$loopCount',
    nameKo: '도박의 신전 +$loopCount',
    emoji: '🌌',
    stakeMultiplier: godStage.stakeMultiplier * (1.0 + loopCount * 0.5),
    bgFile: 'bg_stage6.png',
  );
}
