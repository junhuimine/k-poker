"""
app_strings.dart에 베트남어(AppLanguage.vi) 지원을 추가하는 스크립트.

버그 수정 3개:
1. re.sub lambda 사용 → vi_value 내 \\n이 실제 줄바꿈이 되지 않도록
2. find_en_value 역방향 검색 → 가장 가까운 en 값 반환
3. ${...? '...'} 보간 문자열 스킵 → regex 조기 종료 방지
"""
import re
import os

VI_DICT: dict[str, str] = {
    'K-Poker: Hwatu Gambler': 'K-Poker: Tay Bài Hoa',
    'Start Game': 'Bắt đầu',
    'TOTAL SCORE': 'TỔNG ĐIỂM',
    'Score': 'Điểm',
    'Go!': 'Tiếp tục!',
    'Stop!': 'Dừng!',
    'Shop': 'Cửa hàng',
    'Next Stage': 'Giai đoạn tiếp',
    'Game Over': 'Trò chơi kết thúc',
    'Settings': 'Cài đặt',
    'Language': 'Ngôn ngữ',
    'Hwatu Roguelike': 'Hoa Bài Roguelike',
    'BGM': 'Nhạc nền',
    'SFX': 'Âm thanh',
    'Card Back Design': 'Thiết kế mặt sau',
    'Card Front Design': 'Thiết kế mặt trước',
    'OFF': 'TẮT',
    'Hand Status': 'Trạng thái bài',
    'My Profile': 'Hồ sơ của tôi',
    ' Win Streak': ' Chuỗi thắng',
    'Current Score': 'Điểm hiện tại',
    'Yaku Progress': 'Tiến độ bài',
    'Opponent': 'Đối thủ',
    'None': 'Không có',
    'Bright': 'Sáng',
    'Animal': 'Thú',
    'Blue Ribbon': 'Ruy băng xanh',
    'Red Ribbon': 'Ruy băng đỏ',
    'Grass Ribbon': 'Ruy băng cỏ',
    'Ribbon': 'Ruy băng',
    'Junk': 'Rác',
    'Select a card to capture': 'Chọn lá bài để lấy',
    'Cancel': 'Hủy',
    'Me': 'Tôi',
    'pts': 'đ',
    'Calc': 'Tính',
    'Victory!': 'Chiến thắng!',
    'Defeat...': 'Thất bại...',
    'Sweep': 'Quét',
    'Income': 'Thu nhập',
    'Loss': 'Thua lỗ',
    'Next Round →': 'Vòng tiếp →',
    'Retry!': 'Thử lại!',
    'Score Detail': 'Chi tiết điểm',
    'Total': 'Tổng',
    'Five Brights': 'Năm Sáng',
    'Four Brights': 'Bốn Sáng',
    'Rainy Four Brights': 'Bốn Sáng Mưa',
    'Rainy Three Brights': 'Ba Sáng Mưa',
    'Three Brights': 'Ba Sáng',
    'Godori': 'Godori',
    'Red Ribbons': 'Ruy băng đỏ',
    'Blue Ribbons': 'Ruy băng xanh',
    'Grass Ribbons': 'Ruy băng cỏ',
    '{count} Ribbons': '{count} Ruy băng',
    '{count} Animals': '{count} Thú',
    '{count} Junks': '{count} Rác',
    '{count} Sweeps': '{count} Quét',
    '{count} Go': '{count} Go',
    '{count} Go Multiplier': 'Nhân {count} Go',
    'Regular Customer': 'Khách quen',
    'Chrysanthemum Cup -> Double Junk': 'Chén cúc -> Rác đôi',
    'Jackpot Ticket': 'Vé Jackpot',
    'Bright Penalty': 'Phạt Sáng',
    'Junk Penalty': 'Phạt Rác',
    'Ribbon Penalty': 'Phạt Ruy băng',
    'Animal Penalty': 'Phạt Thú',
    'Item Bonus': 'Thưởng đồ',
    'Item Multiplier': 'Nhân đồ',
    'Item xMult': 'xMult đồ',
    'Bright Penalty Shield': 'Khiên phạt sáng',
    'Mountain Charm (Animal x1.5)': 'Bùa núi (Thú x1.5)',
    'Ribbon Polish (Ribbon x2)': 'Đánh bóng (x2)',
    'Bomb Fuse (Bomb x4)': 'Ngòi bom (Bom x4)',
    'Fortress (Penalty -25%)': 'Pháo đài (Phạt -25%)',
    'Flower Bomb (x3)': 'Bom hoa (x3)',
    'Provoke (x2)': 'Khiêu khích (x2)',
    'Shake x2': 'Lắc x2',
    'Shake!': 'Lắc!',
    'Score x2!': 'Điểm x2!',
    'Ppuck': 'Ppuck',
    'Double Ppuck': 'Ppuck đôi',
    '+3 pts': '+3 đ',
    'Triple Ppuck': 'Ppuck ba',
    'Instant Win': 'Thắng ngay',
    'Jjok': 'Jjok',
    'Jjok Sweep': 'Jjok Quét',
    'Steal 2 Junks': 'Cướp 2 Rác',
    'Ttadak': 'Ttadak',
    'Ppuck Eat': 'Ăn Ppuck',
    'Absorb 4 cards': 'Hấp thu 4 lá',
    'Self Ppuck': 'Tự Ppuck',
    '4 cards + Steal 2 Junks!': '4 lá + Cướp 2 Rác!',
    'Bomb': 'Bom',
    'Chongtong': 'Chongtong',
    'Capture 4 cards instantly': 'Lấy 4 lá ngay',
    'Bankrupt!': 'Phá sản!',
    'You ran out of money...': 'Hết tiền rồi...',
    'Start Over': 'Bắt đầu lại',
    'Total Wins': 'Tổng thắng',
    'Total Losses': 'Tổng thua',
    'Best Streak': 'Chuỗi thắng tốt nhất',
    'Best Score': 'Điểm cao nhất',
    'Best Money': 'Tiền nhiều nhất',
    'Stage Reached': 'Giai đoạn đạt được',
    'W': 'T',
    'L': 'T',
    ' streak': ' chuỗi',
    'Stage': 'Giai đoạn',
    '3 pts reached!': 'Đạt 3 điểm!',
    'Extra points!': 'Điểm bổ sung!',
    'Go(1 Go) → +1 pt | Stop to win now': 'Go(1 Go) → +1 đ | Dừng để thắng',
    'Go(2 Go) → +2 pts | Stop to win now': 'Go(2 Go) → +2 đ | Dừng để thắng',
    'Go(3 Go) → Score x2! | Stop to win now': 'Go(3 Go) → Điểm x2! | Dừng để thắng',
    'Skill Bag': 'Túi kỹ năng',
    'No skills or talismans': 'Không có kỹ năng hay bùa',
    'Flip': 'Lật',
    'Double': 'Đôi',
    'Red': 'Đỏ',
    'Blue': 'Xanh',
    'Grass': 'Cỏ',
    'Animal (10-pt)': 'Thú (10 điểm)',
    'Ribbon (Dan)': 'Ruy băng (Dan)',
    'Help': 'Trợ giúp',
    'Secret Shop': 'Cửa hàng bí mật',
    '⚡ In-game Active Skills (Consumable)': '⚡ Kỹ năng chủ động (Tiêu hao)',
    'Activate anytime during the game without using a turn!': 'Kích hoạt bất cứ lúc nào không tốn lượt!',
    '🛡️ Round Equipment (One-time)': '🛡️ Trang bị vòng (Một lần)',
    'Equip before the round starts! (Expires when round ends)': 'Trang bị trước vòng bắt đầu! (Hết hạn khi xong)',
    '🔮 Passive Skills': '🔮 Kỹ năng bị động',
    'Auto-activates while owned! Aim for synergies': 'Tự động kích hoạt khi sở hữu! Tìm sức mạnh tổng hợp',
    '📜 Talismans': '📜 Bùa hộ mệnh',
    'Buy once, applies for the entire run!': 'Mua một lần, dùng cả run!',
    'Finish Shopping / To Lobby →': 'Kết thúc mua sắm / Lobby →',
    '✅ Equipped': '✅ Đã trang bị',
    'Equip': 'Trang bị',
    '✅ Permanently Owned': '✅ Sở hữu vĩnh viễn',
    'Purchased': 'Đã mua',
    'Use': 'Dùng',
    'Skill Used!': 'Đã dùng kỹ năng!',
    'SOLD OUT': 'HẾT HÀNG',
    '🔒 LOCKED': '🔒 KHÓA',
    '-- Synergy --': '-- Sức mạnh --',
    '-- Inventory --': '-- Kho đồ --',
    'Active': 'Chủ động',
    'Passive': 'Bị động',
    'Talisman': 'Bùa',
    'Consumable': 'Tiêu hao',
    'Unlock: Achieve Five Brights once': 'Mở khóa: Đạt Năm Sáng một lần',
    'Rules': 'Luật chơi',
    'Cards': 'Bài',
    'Yaku': 'Yaku',
}

# 복잡한 Dart 보간 문자열 (내부에 '를 포함) 감지 여부
_TH_RE = re.compile(r"AppLanguage\.th:\s*'([^']*)'")


def has_unclosed_interpolation(th_value: str) -> bool:
    """${...? '...'} 보간에서 regex가 '에서 조기 종료했는지 감지"""
    open_brace = th_value.count('${')
    close_brace = th_value.count('}')
    return open_brace > close_brace


def find_en_value(lines: list[str], th_line_idx: int) -> str:
    """th 라인에서 가장 가까운 AppLanguage.en 값을 역방향으로 탐색"""
    # 같은 줄에서 먼저 찾기
    en_match = re.search(r"AppLanguage\.en:\s*'([^']*)'", lines[th_line_idx])
    if en_match:
        return en_match.group(1)
    # 역방향으로 최대 10줄 탐색 (가장 가까운 en 우선)
    for j in range(th_line_idx - 1, max(-1, th_line_idx - 11), -1):
        en_match = re.search(r"AppLanguage\.en:\s*'([^']*)'", lines[j])
        if en_match:
            return en_match.group(1)
    return ''


def add_vi_translations(lines: list[str], lang_names_range: tuple[int, int]) -> list[str]:
    """각 AppLanguage.th 라인에 AppLanguage.vi를 같은 라인에 삽입.

    - languageNames 블록 스킵 (별도 처리)
    - ${...? '...'} 보간 문자열 스킵 (regex 안전)
    - lambda 사용으로 vi_value 내 \\n 보존
    """
    start, end = lang_names_range
    result: list[str] = []

    for i, line in enumerate(lines):
        # languageNames 블록 스킵
        if start <= i <= end:
            result.append(line)
            continue

        # AppLanguage.vi가 이미 있으면 스킵
        if 'AppLanguage.vi' in line:
            result.append(line)
            continue

        th_match = _TH_RE.search(line)
        if not th_match:
            result.append(line)
            continue

        th_value = th_match.group(1)

        # Dart 보간 내부 '가 있어서 regex가 조기 종료한 경우 스킵
        if has_unclosed_interpolation(th_value):
            result.append(line)
            continue

        en_value = find_en_value(lines, i)
        # en_value가 \로 끝나면 regex가 escaped quote에서 조기 종료한 것 → 스킵
        if en_value.endswith('\\'):
            result.append(line)
            continue
        vi_value = VI_DICT.get(en_value, en_value) if en_value else th_value
        # 작은따옴표 이스케이프
        vi_value = vi_value.replace("'", "\\'")

        # lambda 사용: re.sub 교체 문자열 이스케이프 방지
        def make_repl(vv: str):
            def _repl(m: re.Match) -> str:
                return m.group(0) + f", AppLanguage.vi: '{vv}'"
            return _repl

        new_line = _TH_RE.sub(make_repl(vi_value), line)
        result.append(new_line)

    return result


def find_lang_names_range(lines: list[str]) -> tuple[int, int]:
    """languageNames 블록의 시작/끝 줄 번호 반환"""
    start = -1
    for i, line in enumerate(lines):
        if 'const Map<AppLanguage, String> languageNames' in line:
            start = i
        if start >= 0 and i > start and line.strip() == '};':
            return start, i
    return -1, -1


def process_file(path: str) -> None:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # ① AppLanguage enum
    content = content.replace(
        '  th, // ภาษาไทย\n}',
        '  th, // ภาษาไทย\n  vi, // Tiếng Việt\n}'
    ).replace(
        '/// 지원 언어 목록 (10개)',
        '/// 지원 언어 목록 (11개)'
    )

    # ② languageNames
    content = content.replace(
        "  AppLanguage.th: 'ภาษาไทย',\n};",
        "  AppLanguage.th: 'ภาษาไทย',\n  AppLanguage.vi: 'Tiếng Việt',\n};"
    )

    # ③ detectLanguage
    content = content.replace(
        "    case 'th': return AppLanguage.th;\n    default: return AppLanguage.en;",
        "    case 'th': return AppLanguage.th;\n    case 'vi': return AppLanguage.vi;\n    default: return AppLanguage.en;"
    )

    # ④ getAiDialogue
    content = content.replace(
        "      case AppLanguage.th: targetMap = aiDialoguesTh; break;\n      default: return defaultKoLines[index];",
        "      case AppLanguage.th: targetMap = aiDialoguesTh; break;\n      case AppLanguage.vi: targetMap = aiDialoguesVi; break;\n      default: return defaultKoLines[index];"
    )

    # ⑤ 번역 맵 inline vi 삽입
    lines = content.splitlines(keepends=True)
    lang_range = find_lang_names_range(lines)
    lines = add_vi_translations(lines, lang_range)
    content = ''.join(lines)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

    vi_count = content.count('AppLanguage.vi')
    print(f'완료! AppLanguage.vi 항목 수: {vi_count}')


if __name__ == '__main__':
    dart_file = os.path.join(os.path.dirname(__file__), '..', 'lib', 'i18n', 'app_strings.dart')
    process_file(dart_file)
