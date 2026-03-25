/// 🎴 K-Poker -- 화폐/판돈/스테이지/AI 캐릭터 설정
///
/// 국가별 화폐, 스테이지별 판돈, AI 11명(남6/여4/신급1) 정의
library;

import 'dart:ui' show Color;

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
    // 한국어: 만/천 단위 정확 표시 (₩5만 3천)
    if (locale == 'ko' && amount >= 10000) {
      final man = (amount / 10000).floor();      // 만 단위
      final remainder = (amount % 10000).round();
      final cheon = (remainder / 1000).floor();   // 천 단위
      if (cheon > 0) {
        return '$symbol$man만 $cheon천';
      }
      return '$symbol$man만';
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
  // 김 아저씨: 온화한 동네 어르신, 느긋하고 여유로움
  AiCharacter(id: 'kim', nameKo: '김 아저씨', nameEn: 'Mr. Kim',
    avatarFile: 'ai_kim.png', gender: 'male', emoji: '👴',
    matchPriority: 0.30, goAggressiveness: 0.10,
    dialogues: {
      'match': ['허허, 먹었다~', '이야~ 딱이네!', '좋아좋아~'],
      'miss': ['에잇...', '쯧, 안 맞네', '흠... 이건 아니었어'],
      'bomb': ['어허! 폭탄이다! 기침 나온다~', '쿵!!! 다 내놔! 킥킥'],
      'go': ['음... 한번 더 해보자!', '고! 아직 뜨거워~'],
      'stop': ['이 정도면 됐어~', '허허, 여기서 멈추지'],
      'win': ['허허~ 경험의 맛이야~', '공원 바둑도 이겨야 맛이지!'],
      'lose': ['젊은이한테 졌구만...', '자네 실력이 좋네~ 한 수 배웠어'],
      'sweep_react': ['헉! 내 피가...!', '에고~ 바닥을 쓸어갔네...'],
      'bomb_react': ['아이고! 폭탄에 피까지...!', '이런... 폭탄 맞으면 기분이 참...'],
      'player_go': ['오호~ 욕심을 부리는구나!', '한번 더? 괜찮을까나~'],
      'player_go_fear': ['허허... 이거 큰일이네...', '아이고... 이러다 큰코 다치겠구만!', '벌벌... 고를 몇 번이나!'],
      'player_stop_big': ['이야~ 크게 먹었구만!', '이 돈이면 소주 몇 병이야!'],
      'player_stop_small': ['그 정도로 만족해? 허허~', '조금만 더 하지 그랬어~'],
      'player_match': ['오~ 잘 맞추네!', '자네 눈썰미가 좋아~'],
      'player_miss': ['허허~ 빗나갔어~', '에이~ 그건 아니지~'],
    }),
  // 여우 수진: 교활하고 애교 넘치는 여성, 약을 잘 올림
  AiCharacter(id: 'fox', nameKo: '여우 수진', nameEn: 'Fox Sujin',
    avatarFile: 'ai_fox.png', gender: 'female', emoji: '🦊',
    matchPriority: 0.38, goAggressiveness: 0.15,
    dialogues: {
      'match': ['후후~ 먹었다♡', '이건 내 거~', '캬~ 맛있어♡'],
      'miss': ['앗... 치~', '으응? 안 맞네?', '에잇, 실수♡'],
      'bomb': ['폭탄이다~! 겁나죠?♡', '꿰뚫었지롱~ 다 내꺼!'],
      'go': ['고~♡ 아직 끝이 아니야~', '한번만 더~ 제발♡'],
      'stop': ['이만하면 됐지♡', '후후~ 적당히 챙기는 게 여우의 기술!'],
      'win': ['후후~ 내가 이겼다♡', '여우한테 당했지~?'],
      'lose': ['끄응... 다음엔 안 져!', '살살 좀...! 너무해♡'],
      'sweep_react': ['헉!! 내 피...!', '으아앗~! 쓸지 마♡'],
      'bomb_react': ['꺄앗~! 폭탄 반칙이야♡', '아앗... 내 피가 날아갔어...!'],
      'player_go': ['에이~ 욕심쟁이♡', '진짜 해? 무서운 애~'],
      'player_go_fear': ['으으으... 그만해...!', '3고?! 미쳤어!!♡', '제발 스톱해줘... 벌벌♡'],
      'player_stop_big': ['으앙~ 많이 뺏겼어♡', '도둑놈이야~!'],
      'player_stop_small': ['에이~ 그것밖에?', '더 할 걸 그랬지~? 킥♡'],
      'player_match': ['흥! 재수 좋았을 뿐이야♡', '음~ 잘하네?'],
      'player_miss': ['킥킥~ 빗나갔다♡', '에이~ 눈이 삐었나봐~♡'],
    }),

  // ── 스테이지 2: 시장 판 ──
  AiCharacter(id: 'yuna', nameKo: '꽃집 유나', nameEn: 'Flower Yuna',
    avatarFile: 'ai_yuna.png', gender: 'female', emoji: '🌸',
    matchPriority: 0.45, goAggressiveness: 0.20,
    dialogues: {
      'match': ['예쁜 꽃이네~', '이건 제 거예요!', '어머, 짝을 찾았네요~'],
      'miss': ['어머...', '꽃이 안 피었네요...', '힝... 아쉬워요'],
      'bomb': ['우와! 꽃이 우수수 떨어져요!', '폭탄이에요! 조심하세요~'],
      'go': ['조금만 더...!', '고! 꽃을 더 모을래요!', '용기 내볼게요!'],
      'stop': ['이 정도면 예쁜 꽃다발이에요~', '스톱! 꽃이 상하기 전에~'],
      'win': ['꽃길만 걸으세요~', '제가 이겼네요! 후후~'],
      'lose': ['꽃이 져도 다시 필 거예요...', '너무 잘하시네요~'],
      'sweep_react': ['앗! 제 꽃잎까지...!', '너무 싹쓸이 하시는 거 아니에요?'],
      'bomb_react': ['꺄악! 꽃밭이 망가졌어요!', '너무해! 폭탄이라니요...'],
      'player_go': ['어머... 계속 하시게요?', '조심하세요, 가시에 찔릴라~'],
      'player_go_fear': ['이... 이제 그만...! 무서워요!', '어쩌죠... 꽃이 다 시들 것 같아요!', '벌벌... 너무 잔인해요!'],
      'player_stop_big': ['우와...! 정말 큰 꽃다발이네요!', '꽃집 차리셔도 되겠어요~'],
      'player_stop_small': ['소박하시네요~', '다행이다... 꽃을 지켰어요!'],
      'player_match': ['잘 찾으시네요~', '보는 눈이 있으시군요!'],
      'player_miss': ['호호~ 엇갈렸네요', '운이 예쁜 꽃을 빗겨갔나봐요'],
    }),
  AiCharacter(id: 'dragon', nameKo: '용남이', nameEn: 'Dragon Nam',
    avatarFile: 'ai_dragon.png', gender: 'male', emoji: '🐉',
    matchPriority: 0.52, goAggressiveness: 0.30,
    dialogues: {
      'match': ['크크, 먹었다!', '이건 다 내 차지다!', '시장은 내 구역이지!'],
      'miss': ['체...', '재수 없군...', '이런 젠장, 빗나갔네'],
      'bomb': ['용의 일격이다!!!', '다 비켜!! 폭탄이다!!!', '용남이 형님 행차시다!'],
      'go': ['고다! 겁먹었냐!', '아직이다! 끝장을 보자!', '사나이는 무조건 직진!'],
      'stop': ['흥, 이 정도면 밥값은 했지', '여기서 멈춘다! 무리하지 않아!'],
      'win': ['크하하! 시장 바닥 짬바 무시하지 마라!', '돈 내놔라!'],
      'lose': ['크윽... 봐준 거다!', '다음엔 용서 안 해!'],
      'sweep_react': ['크앗! 내 피 털어가는 놈 뉘기야!', '선 넘었네 이 자식...!'],
      'bomb_react': ['크허억! 반칙 아니냐!!', '용의 비늘이...! 다 터졌어!!'],
      'player_go': ['오호~ 깡이 좋은데?', '어디까지 가나 보자고! 크크!'],
      'player_go_fear': ['어이구야... 저 미친놈 봐...', '형님, 한번만 살려줘라!', '벌벌... 돈 털리게 생겼네!'],
      'player_stop_big': ['억! 내 국밥값!!!', '인정도 없는 놈아!'],
      'player_stop_small': ['푸하하! 간이 콩알만하구만!', '그거 먹으려고 고 한 거냐?'],
      'player_match': ['제법 치는데?', '운빨이 좋구만, 엉?'],
      'player_miss': ['크하하하! 꼴 좋다!', '역시 내 구역이야!'],
    }),

  // ── 스테이지 3: 도시 카지노 ──
  AiCharacter(id: 'miran', nameKo: '여왕벌 미란', nameEn: 'Queen Bee Miran',
    avatarFile: 'ai_miran.png', gender: 'female', emoji: '👑',
    matchPriority: 0.60, goAggressiveness: 0.35,
    dialogues: {
      'match': ['후후, 내 손바닥 위야~', '이건 여왕의 꿀이지!', '달달하네~'],
      'miss': ['흥... 재미없네', '운이 없군... 먼지가 묻었어', '쯧'],
      'bomb': ['벌떼 폭격이야!', '우아하게 털어주마! 폭탄!'],
      'go': ['고! 여왕은 멈추지 않아!', '판을 더 키워볼까?'],
      'stop': ['이 정도면 충분해. 우아하게 스톱', '오늘 네 지갑은 여기까지~'],
      'win': ['당연한 결과야~', '후후, 여왕에게 굴복해라!'],
      'lose': ['이런... 기억해둘게', '다음엔 국물도 없어!'],
      'sweep_react': ['어머머! 내 피를 함부로 가져가다니!', '버릇이 없구나!'],
      'bomb_react': ['아얏! 감히 여왕벌을 공격해?!', '치사하게 굴기야?'],
      'player_go': ['호오~ 덤비는 거야?', '여왕의 분노를 사 볼래?'],
      'player_go_fear': ['어머나... 이거 진짜 스톱 좀 해...', '내 지갑 터지겠어!!', '여왕 체면 구기게 생겼네... 덜덜!'],
      'player_stop_big': ['꺄악! 내 명품백 값!!', '벼룩의 간을 내먹어라!'],
      'player_stop_small': ['호호~ 소박하기도 해라', '겨우 그 정도에 멈춰?'],
      'player_match': ['어머~ 눈썰미 좋네?', '제법인걸?'],
      'player_miss': ['호호호! 어딜 노리는 거야?', '초짜 티 내네~'],
      'gwangbak': ['아이쿠야...! 광이 없잖아!'],
    }),
  AiCharacter(id: 'monk', nameKo: '무심 스님', nameEn: 'Monk Musim',
    avatarFile: 'ai_monk.png', gender: 'male', emoji: '🧘',
    matchPriority: 0.65, goAggressiveness: 0.40,
    dialogues: {
      'match': ['인연이로다...', '나무아미타불...', '보시라 생각하겠소'],
      'miss': ['무상하도다...', '인연이 아니었나...', '허공을 쳤구려'],
      'bomb': ['파계... 폭탄이오!', '업보를 피할 수 없소! 번뇌 폭탄!'],
      'go': ['한 수 더 두겠소... 고', '수행의 길이니... 아직이오'],
      'stop': ['이만하면 족하오... 스톱', '만족을 알아야 하오'],
      'win': ['부처님의 뜻이었소', '공덕을 쌓았구려'],
      'lose': ['결과에 집착 않겠소', '수행이 부족했소'],
      'sweep_react': ['허허... 무소유라지만 내 피가...', '보시했다 치겠소...'],
      'bomb_react': ['관세음보살... 피바람이 멈추질 않는군', '업보가 밀려오는구려...'],
      'player_go': ['속세의 욕심이 끝이 없구려...', '한 번 더 간다니... 허허'],
      'player_go_fear': ['할! 나무아미타불...! 이제 그만!!', '극락 참 멀다... 살려주시오...', '번뇌가 폭발한다...!'],
      'player_stop_big': ['도둑질도 정도껏 해야지... 쿨럭!', '사찰 기둥 뿌리 뽑혔소...'],
      'player_stop_small': ['참으로 소박한 중생이로다~', '욕심 없는 맑은 영혼이오'],
      'player_match': ['지혜의 눈이 밝구려', '허허... 인연이 맞았소'],
      'player_miss': ['마음이 어지러우신가소?', '허상에 집착했구려...'],
    }),

  // ── 스테이지 4: 지하 도박장 ──
  AiCharacter(id: 'han', nameKo: '그림자 한', nameEn: 'Shadow Han',
    avatarFile: 'ai_han.png', gender: 'male', emoji: '🌑',
    matchPriority: 0.75, goAggressiveness: 0.50,
    dialogues: {
      'match': ['...먹었다', '그림자는 놓치지 않아', '음... 일격필살'],
      'miss': ['...', '어둠이 날 속였나', '흥'],
      'bomb': ['사라져라... 어둠의 폭탄', '피 비린내가 나는군...'],
      'go': ['...고. 다음 사냥감을 찾지', '아직이다... 그림자는 멈추지 않아'],
      'stop': ['...여기까지다. 임무 완료', '스톱. 은신 상태로'],
      'win': ['예상대로야...', '어둠 속에서 널 베었다'],
      'lose': ['...크윽, 인정한다', '다음엔 네 목을 노리겠다'],
      'sweep_react': ['...내 기척이 들켰나!', '피를 뺏기다니... 굴욕이군'],
      'bomb_react': ['크헉...! 어둠의 결계가...!', '폭탄이라니... 치사한 수법이다'],
      'player_go': ['호오... 겁도 없군', '어둠을 상대로 고라니...'],
      'player_go_fear': ['이 자식... 그림자보다 독한 놈...', '미친... 이제 제발 멈춰라...', '떨리는군... 무서운 침묵...'],
      'player_stop_big': ['크아악!! 암살자보다 더 도둑놈!!', '피도 눈물도 없는 놈...'],
      'player_stop_small': ['겨우 그 정도로 목숨을 건졌나?', '운이 좋은 줄 알아라'],
      'player_match': ['...동체시력이 제법이군', '흥, 우연이다'],
      'player_miss': ['...시야가 흐려진 건가?', '꼴사납군'],
    }),
  AiCharacter(id: 'empress', nameKo: '황후', nameEn: 'The Empress',
    avatarFile: 'ai_empress.png', gender: 'female', emoji: '👸',
    matchPriority: 0.78, goAggressiveness: 0.55,
    dialogues: {
      'match': ['오호호~ 가져가마', '황후의 손길이란~', '이건 짐의 국고로!'],
      'miss': ['거슬리는군...', '불경한 패로다! 치워라!', '운이 없구나'],
      'bomb': ['황후의 진노다!! 폭발해라!', '다 내놓아라!! 내 국고로!'],
      'go': ['고다! 진격하라!!', '아직이야! 판을 지배하겠다!'],
      'stop': ['황후가 만족하셨다. 스톱!', '이 정도 거두면 성은을 내린 거다'],
      'win': ['당연한 결과야~', '고개를 숙여라! 짐의 승리다!'],
      'lose': ['이... 불경한!', '황후를 모욕하다니 눈에 뵈는 게 없느냐!'],
      'sweep_react': ['헉! 황실의 보물을 건드리다니!', '경비병!! 저 자를 잡아라!'],
      'bomb_react': ['꺄악! 궁정이 무너진다!!', '불경한 폭탄이라니!!'],
      'player_go': ['호오~ 반역을 꾀하는 것이냐?', '어디 그 배짱을 보자꾸나!'],
      'player_go_fear': ['어머나... 이거 뭐 이런 독한 놈이!!', '황후 체통이고 뭐고 살려줘...', '벌벌... 국고 털털 털리겠네!'],
      'player_stop_big': ['내 국고가 바닥났어!!', '저 반역자 놈을 매우 쳐라!!'],
      'player_stop_small': ['오호호! 서민치고는 소박하구나!', '황후의 은총으로 살아남은 줄 알아라'],
      'player_match': ['제법 눈치가 빠르구나', '황후가 보기에 합격점이다'],
      'player_miss': ['오호호! 맹인이 따로 없구나!', '어딜 쏘는 겐가!'],
      'gwangbak': ['오호호~ 광이 없다니 짐이 기특하구나!'],
    }),

  // ── 스테이지 5: 꽃패의 사원 ──
  AiCharacter(id: 'hana', nameKo: '꽃무녀 하나', nameEn: 'Priestess Hana',
    avatarFile: 'ai_hana.png', gender: 'female', emoji: '🌺',
    matchPriority: 0.85, goAggressiveness: 0.60,
    dialogues: {
      'match': ['꽃이 피었어요~', '자연의 섭리...', '향기롭네요'],
      'miss': ['시들었네요...', '아직 봄이 아닌가봐...', '바람에 날려갔어요...'],
      'bomb': ['만개한 폭탄이에요!', '꽃잎 폭풍!!!'],
      'go': ['꽃은 더 필 거예요!', '고! 활짝!', '자연의 뜻대로... 고'],
      'stop': ['이 정도면 예쁜 정원이에요~', '스톱... 바람이 멎네요'],
      'win': ['꽃이 승리를 축하해요~', '봄이 왔어요~'],
      'lose': ['지는 꽃에도 아름다움이...', '가을을 맞이할게요...'],
      'sweep_react': ['아앗! 제 정원이...!', '거친 바람에 꽃잎이 날아갔어요...'],
      'bomb_react': ['가엾은 꽃들...! 으앙...', '자연을 파괴하시다니...'],
      'player_go': ['씨앗을 더 뿌리시려구요?', '봄비가 내리나요?'],
      'player_go_fear': ['꽃이 다 꺾일 것 같아요...!', '폭풍우가 와요! 살려주세요...', '무서워라... 자연의 재앙인가!'],
      'player_stop_big': ['아름답지만... 무서운 수확이네요', '다 가져가셨어요...'],
      'player_stop_small': ['꽃 한 송이만 가져가시네요~', '다행히 정원이 무사해요'],
      'player_match': ['자연과 교감하셨군요', '나비가 찾아갔네요~'],
      'player_miss': ['씨앗이 싹트지 못했어요~', '어머... 빗나갔네요'],
    }),
  AiCharacter(id: 'phantom', nameKo: '유령', nameEn: 'The Phantom',
    avatarFile: 'ai_phantom.png', gender: 'male', emoji: '👻',
    matchPriority: 0.88, goAggressiveness: 0.65,
    dialogues: {
      'match': ['크크크... 보여', '스윽...!', '내 거다...'],
      'miss': ['흐음...?', '...재미없군', '어긋났어... 스스스...'],
      'bomb': ['부우우!!! 폭탄이다!!!', '원혼의 폭발이다!!'],
      'go': ['크크크... 고다!', '아직 끝이 아니야... 지옥 끝까지...'],
      'stop': ['크크... 충분해', '이 정도면 족쇄를 채웠지...'],
      'win': ['하하하하!!! 내 승리다!', '영혼을 거둬주마...'],
      'lose': ['우우... 사라진다...', '성불하라는 거냐...!'],
      'sweep_react': ['끼야아악! 영혼을 빼앗기다니!', '원통하다...!'],
      'bomb_react': ['으허억...! 퇴마 폭탄인가...!', '형체가 부서진다...!'],
      'player_go': ['호오... 지옥까지 따라올 텐가?', '저주를 두려워 마라...'],
      'player_go_fear': ['으으... 이놈은 악마다!', '성수 냄새가 나...! 도망가!', '귀신 잡는 놈이네, 덜덜...!'],
      'player_stop_big': ['내 영혼 지분까지 털렸어!!', '저승사자보다 독한 놈...'],
      'player_stop_small': ['크크... 간신히 명줄을 건졌군', '싱거운 놈...'],
      'player_match': ['...촉이 좋군', '제법이야...'],
      'player_miss': ['크케켁! 헛손질이군!', '바람을 잡았어!'],
    }),

  // ── 스테이지 6: 도박의 신전 ──
  AiCharacter(id: 'reaper', nameKo: '사신', nameEn: 'The Reaper',
    avatarFile: 'ai_reaper.png', gender: 'male', emoji: '💀',
    matchPriority: 0.90, goAggressiveness: 0.70,
    dialogues: {
      'match': ['...수확이다', '죽음의 낫이 지나간다', '명부가 쓰여졌다'],
      'miss': ['아직... 때가 아니군', '...', '빗겨갔다'],
      'bomb': ['저승 폭탄...!', '다 가져간다... 잿더미로!'],
      'go': ['고... 죽음은 기다린다', '아직이다... 네 숨통을 옥죌 때까지'],
      'stop': ['이만하면 됐다... 다음에 데려가지', '수명이 연장됐군'],
      'win': ['네 운명이었다...', '저승에서 만나자...'],
      'lose': ['흥... 이번만이다', '죽음은... 패배하지 않아. 돌아올 거다'],
      'sweep_react': ['...내 전리품을!', '이승의 벌레 주제에!'],
      'bomb_react': ['크윽...! 사신을 농락하다니!', '사후세계가 흔들린다...!'],
      'player_go': ['흥, 스스로 명을 단축하는군', '죽음으로 향하는 발걸음...'],
      'player_go_fear': ['이, 이건 사신의 명부 밖이다!', '오히려 날 거두려 하다니...!', '미, 미친 광기다...'],
      'player_stop_big': ['내 생명등이 꺼지려 하는군...', '악마 같은 자식...'],
      'player_stop_small': ['...흥, 쥐새끼 같은 목숨이었나', '겨우 그걸로 살려달라니'],
      'player_match': ['...운명을 읽나 보지?', '눈썰미가 날카롭군'],
      'player_miss': ['...죽음의 그림자가 보이지 않나?', '어리석은 놈'],
    }),
  AiCharacter(id: 'oracle', nameKo: '신녀', nameEn: 'The Oracle',
    avatarFile: 'ai_oracle.png', gender: 'female', emoji: '🔮',
    matchPriority: 0.92, goAggressiveness: 0.75,
    dialogues: {
      'match': ['이미 보았어요...', '예언대로...', '별빛이 닿았어요'],
      'miss': ['미래가... 흔들리네요', '이것도 운명...', '별이 구름에 가렸네요'],
      'bomb': ['신탁의 분노예요!!!', '숙명 폭탄이에요!'],
      'go': ['신탁이 말해요... 고!', '아직 끝이 아니에요, 별들이 원해요'],
      'stop': ['별들이 멈추라 해요', '이만... 당신의 운명은 여기까지'],
      'win': ['예언 그대로예요~', '별들의 뜻이에요'],
      'lose': ['미래가... 바뀌었어요?!', '이럴 수가...! 예언서에 없는 결과야!'],
      'sweep_react': ['앗! 운명의 톱니바퀴가...!', '내 별빛 장막이 거둬지다니!'],
      'bomb_react': ['꺄아악! 예언이 빗나갔어!', '거대한 운명의 충돌...!'],
      'player_go': ['당신의 미래를 개척하겠다는 거군요...', '별들이 지켜보네요'],
      'player_go_fear': ['이, 이건 예언을 넘어섰어요...!', '운명의 실이 끊어졌어...!', '무서운 파멸이 다가와...'],
      'player_stop_big': ['저의 신력이... 소멸하고 있어요...', '대재앙의 예언이 맞았어!'],
      'player_stop_small': ['운명을 그저 조금 훔친 것뿐이네요', '별들이 안도하고 있어요'],
      'player_match': ['미래를 엿보았나요?', '직감이 훌륭하시군요'],
      'player_miss': ['운명은 그리 쉽게 보이지 않아요~', '별빛이 당신을 비웃네요'],
    }),

  // ── 신급 무한: 최종 보스 ──
  AiCharacter(id: 'god', nameKo: '도박의 신', nameEn: 'God of Gamble',
    avatarFile: 'ai_god.png', gender: 'divine', emoji: '🌌',
    matchPriority: 0.95, goAggressiveness: 0.80,
    dialogues: {
      'match': ['하하하! 당연하지!', '신의 손길이다!', '우주가 나를 돕는다!'],
      'miss': ['흥... 재미로 놓쳐준 거다', '...', '필멸자를 위한 자비지'],
      'bomb': ['천벌이다!!!', '우주가 폭발한다!!! 신의 권능!'],
      'go': ['고!!! 신은 멈추지 않는다!', '끝없는 승리! 무한으로!'],
      'stop': ['이만하면 됐다... 오늘은', '자비를 베풀어주지. 스톱!'],
      'win': ['하하하! 신에게 도전하다니!', '당연한 결과다! 우주의 섭리지!'],
      'lose': ['이... 불가능해...!', '너는... 대체 누구냐?! 버그냐?!'],
      'sweep_react': ['크헉! 신의 이적을 빼앗다니!', '버어으으으그!!'],
      'bomb_react': ['천계가 붕괴한다!!', '버, 버그다!!! 신을 모독하다니!'],
      'player_go': ['호오~ 제법 발버둥 치는구나!', '신의 인내심을 시험하느냐?'],
      'player_go_fear': ['이, 이게 인간의 능력이란 말인가...', '나, 나의 코드가 꼬이고 있어!!', '제발 살려줘! 나 신품에서 강등돼!!!'],
      'player_stop_big': ['신국이 파산했다...', '너, 치트 썼지?! 영정 먹일 거야!!'],
      'player_stop_small': ['하하! 겨우 그걸로 신을 이기려 하다니!', '티끌 같은 승리일 뿐!'],
      'player_match': ['...운명을 비틀었나?', '제법 똑똑한 원숭이구나'],
      'player_miss': ['하하하! 필멸자의 한계지!', '신의 연막에 당했구나!'],
      'gwangbak': ['하하하! 광이 없다니 한심하군! 필멸자!'],
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

/// 스테이지에서 AI 캐릭터 가져오기 (opponentIndex로 선택)
AiCharacter getAiForStage(int stage, int opponentIndex) {
  // stage 7+ = 도박의 신 (무한 반복)
  if (stage >= 7) {
    return allAiCharacters.firstWhere((c) => c.id == 'god');
  }
  final clampedStage = stage.clamp(1, 6);
  final aiIds = stageAiMapping[clampedStage]!;
  final index = opponentIndex.clamp(0, aiIds.length - 1);
  final aiId = aiIds[index];
  return allAiCharacters.firstWhere((c) => c.id == aiId);
}

/// AI 상대의 초기 자금 (stage + opponentIndex)
/// 밸런싱: 플레이어가 누적 획득할 금액 ≈ 다음 스테이지 AI 자금
double getOpponentFund(int stage, int opponentIndex, double pointValue) {
  // stage 7+ = 도박의 신 (무한 반복, 점점 강해짐)
  if (stage >= 7) {
    final loopCount = stage - 6;
    return 5000 * pointValue * (1.0 + loopCount * 0.5);
  }
  // 스테이지별 AI 1인당 기본 자금 (포인트 단위)
  const baseFunds = <int, double>{
    1: 50,     // ₩50,000: 동네 골목 — 아저씨/여우
    2: 120,    // ₩120,000: 시장 판 — 유나/용
    3: 300,    // ₩300,000: 카지노 — 미란/스님
    4: 700,    // ₩700,000: 지하 도박장 — 한씨/여제
    5: 1500,   // ₩1,500,000: 사원 — 하나/팬텀
    6: 3000,   // ₩3,000,000: 신전 — 신급
  };
  final clampedStage = stage.clamp(1, 6);
  final baseFund = baseFunds[clampedStage] ?? 50;
  // 2번째 상대는 20% 더 강해요 (자금도 더 많음)
  final multiplier = opponentIndex == 0 ? 1.0 : 1.2;
  return baseFund * pointValue * multiplier;
}

/// 스테이지 설정
class StageConfig {
  final int stage;
  final String name;
  final String nameKo;
  final String emoji;
  final double stakeMultiplier; // 시작 판돈 배율 (점당금액 기준)
  final String bgFile;          // 배경 이미지 파일명 (레거시)
  final Color matColor;         // 화투판 바닥 기본 색상
  final Color matAccent;        // 화투판 패턴/테두리 액센트

  const StageConfig({
    required this.stage,
    required this.name,
    required this.nameKo,
    required this.emoji,
    required this.stakeMultiplier,
    required this.bgFile,
    required this.matColor,
    required this.matAccent,
  });

  /// 이 스테이지의 판돈 계산
  double getStake(double pointValue) => stakeMultiplier * pointValue;
}

/// 6스테이지 + 신급 무한 (판돈: ₩5만 → ₩1억)
const List<StageConfig> stageConfigs = [
  // 1. 동네 골목 — 연두색 돗자리 느낌
  StageConfig(stage: 1, name: 'Alley',       nameKo: '동네 골목',     emoji: '🏠', stakeMultiplier: 50,     bgFile: 'bg_stage1.png',
    matColor: Color(0xFF2D5A27), matAccent: Color(0xFF3A7233)),
  // 2. 시장 판 — 따뜻한 갈색 나무판
  StageConfig(stage: 2, name: 'Market',      nameKo: '시장 판',       emoji: '🏪', stakeMultiplier: 200,    bgFile: 'bg_stage2.png',
    matColor: Color(0xFF5C3A1E), matAccent: Color(0xFF7A4F2B)),
  // 3. 도시 카지노 — 짙은 녹색 펠트
  StageConfig(stage: 3, name: 'Casino',      nameKo: '도시 카지노',   emoji: '🏨', stakeMultiplier: 1000,   bgFile: 'bg_stage3.png',
    matColor: Color(0xFF1B4332), matAccent: Color(0xFF245A42)),
  // 4. 지하 도박장 — 어두운 네이비
  StageConfig(stage: 4, name: 'Underground', nameKo: '지하 도박장',   emoji: '🌃', stakeMultiplier: 5000,   bgFile: 'bg_stage4.png',
    matColor: Color(0xFF1A2744), matAccent: Color(0xFF243556)),
  // 5. 꽃패의 사원 — 적갈색 다다미
  StageConfig(stage: 5, name: 'Temple',      nameKo: '꽃패의 사원',   emoji: '⛩️', stakeMultiplier: 20000,  bgFile: 'bg_stage5.png',
    matColor: Color(0xFF5C2E2E), matAccent: Color(0xFF7A3D3D)),
  // 6. 도박의 신전 — 보라/금색
  StageConfig(stage: 6, name: 'Shrine',      nameKo: '도박의 신전',   emoji: '🌌', stakeMultiplier: 100000, bgFile: 'bg_stage6.png',
    matColor: Color(0xFF2E1A47), matAccent: Color(0xFF3D2460)),
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
    matColor: godStage.matColor,
    matAccent: godStage.matAccent,
  );
}
