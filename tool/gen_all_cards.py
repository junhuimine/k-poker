"""
K-Poker 만화 스킨 카드 전체 생성 — Imagen 4 Ultra
50장 (48장 + 보너스 2장) 1장씩 생성 + 퀄리티 확인
"""
import sys
import os
import time

os.environ["PYTHONIOENCODING"] = "utf-8"
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.stderr.reconfigure(encoding="utf-8", errors="replace")
from pathlib import Path
from google import genai
from google.genai import types

API_KEY = "AIzaSyCslJxg4Up-BtdQ4wPv6TG5xmyRTR4bJzI"
OUTPUT_DIR = Path(__file__).parent.parent / "assets" / "images" / "cards_manga_v2"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# ── 공통 스타일 프리픽스 ──
STYLE_PREFIX = """You are creating a premium collectible Korean Hwatu (화투/花札) card illustration for a mobile card game.

ART STYLE — MANDATORY:
- Semi-realistic digital painting, mobile RPG / gacha game premium card aesthetic
- Rich, vibrant saturated colors with dramatic cinematic lighting
- Dark moody background (deep navy, emerald, or black) with golden sparkle/particle effects and ethereal glow
- Smooth color gradients with gem-like luminous quality
- Korean traditional art motifs fused with modern fantasy illustration
- The subject should feel alive, magical, and collectible
- Portrait orientation, 3:4 aspect ratio

STRICT RULES:
- NO text, NO numbers, NO letters, NO borders, NO frames, NO UI elements
- Pure illustration only — the image should fill the entire canvas
- Must faithfully represent the traditional Hwatu card subject described below
"""

# ── 50장 카드 프롬프트 정의 ──
# 각 카드: (파일명, 한국어이름, 상세 설명)
CARDS: list[tuple[str, str, str]] = [
    # ━━━ 1월 松 소나무 ━━━
    (
        "m01_bright",
        "1월 광 — 송학 (소나무와 학)",
        """SUBJECT: January — Pine & Crane (송학/松鶴) — BRIGHT card (highest tier)

A majestic red-crowned crane (두루미/丹頂鶴) with wings fully spread, gracefully perched on or taking flight from a grand, ancient twisted pine tree (소나무).
A large crimson sun disc sits in the upper background, radiating warm golden light rays through the pine branches.
The pine tree has a distinctive S-curved trunk with lush, detailed dark green needle clusters.
The crane is white with black-tipped wings and a red crown marking on its head.
Atmosphere: regal, auspicious, the most prestigious card in Hwatu.""",
    ),
    (
        "m01_ribbon",
        "1월 띠 — 송 홍단 (소나무 빨간띠)",
        """SUBJECT: January — Pine Red Ribbon (송 홍단) — RIBBON card

A section of an elegant pine tree with detailed dark green needle clusters.
A red ribbon (홍단) with delicate traditional Korean calligraphy-style decorative patterns flows gracefully among the pine branches.
The ribbon is bright crimson/vermillion, slightly translucent with a silk-like sheen, gently swaying as if caught by wind.
Focus on the contrast between the deep green pine needles and the vivid red ribbon.""",
    ),
    (
        "m01_junk_1",
        "1월 피1 — 송 피 (소나무 피)",
        """SUBJECT: January — Pine Junk 1 (송 피) — JUNK card (lowest tier)

A small, simple composition of pine tree branches with characteristic dark green needle clusters (솔잎).
Less elaborate than the Bright or Ribbon cards — a humble, quiet scene focusing on the natural beauty of pine needles and bark.
A few pine cones may be visible. The mood is understated and peaceful.
Still maintain the premium art style but with a simpler, more minimalist composition.""",
    ),
    (
        "m01_junk_2",
        "1월 피2 — 송 피 (소나무 피)",
        """SUBJECT: January — Pine Junk 2 (송 피) — JUNK card (lowest tier)

A different angle/composition of pine tree elements — perhaps a close-up of pine branches against a moonlit sky, or pine bark texture with a few scattered needles.
Simpler than the Bright card but still beautiful. Distinct from Junk 1 — different framing, different mood.
Focus on the essence of pine: endurance, evergreen strength.""",
    ),

    # ━━━ 2월 梅 매화 ━━━
    (
        "m02_animal",
        "2월 십 — 매조 (매화와 꾀꼬리)",
        """SUBJECT: February — Plum Blossom & Warbler (매조/梅鳥) — ANIMAL card

A small, vivid bush warbler (꾀꼬리/鶯) — bright yellow-green plumage — perched on a branch of a plum blossom tree (매화나무).
The plum blossoms are delicate five-petaled flowers in soft pink/white, blooming on dark, gnarled branches. Some petals are falling.
Early spring atmosphere — the first signs of warmth after winter.
The bird should be the focal point, singing among the blossoms.""",
    ),
    (
        "m02_ribbon",
        "2월 띠 — 매 홍단 (매화 빨간띠)",
        """SUBJECT: February — Plum Red Ribbon (매 홍단) — RIBBON card

Plum blossom branches with delicate pink/white five-petaled flowers in bloom.
A bright crimson ribbon (홍단) with traditional decorative patterns woven gracefully through the branches.
Focus on the ephemeral beauty of plum blossoms and the vivid red ribbon contrast.
Some falling petals for added elegance.""",
    ),
    (
        "m02_junk_1",
        "2월 피1 — 매 피 (매화 피)",
        """SUBJECT: February — Plum Junk 1 (매 피) — JUNK card

Simple composition of plum blossom branches with a few open flowers.
Minimalist, peaceful scene — no birds, no ribbon. Pure appreciation of plum blossoms.
Dark branches with soft pink/white blossoms against a moody background.""",
    ),
    (
        "m02_junk_2",
        "2월 피2 — 매 피 (매화 피)",
        """SUBJECT: February — Plum Junk 2 (매 피) — JUNK card

Alternative composition of plum blossoms — perhaps buds about to bloom, or a single branch with scattered petals.
Distinct from Junk 1 in framing and mood. Quiet, understated beauty.""",
    ),

    # ━━━ 3월 桜 벚꽃 ━━━
    (
        "m03_bright",
        "3월 광 — 벚꽃 막걸리 (벚꽃과 막/커튼)",
        """SUBJECT: March — Cherry Blossom Curtain (벚꽃 막) — BRIGHT card (highest tier)

A dramatic scene of a viewing curtain/tent (막/幕) beneath a canopy of magnificent cherry blossom trees (벚나무) in full bloom.
The curtain is ornate — rich red/gold fabric with traditional Korean patterns, draped between cherry trees.
Cherry blossoms (벚꽃) are in full, spectacular bloom overhead — clouds of soft pink petals, many falling like snow.
This represents hanami (꽃놀이) — the traditional cherry blossom viewing festival.
Atmosphere: celebratory, luxurious, peak spring beauty.""",
    ),
    (
        "m03_ribbon",
        "3월 띠 — 벚 홍단 (벚꽃 빨간띠)",
        """SUBJECT: March — Cherry Red Ribbon (벚 홍단) — RIBBON card

Cherry blossom branches laden with soft pink blossoms.
A bright red ribbon (홍단) with traditional patterns flowing among the cherry branches.
Petals falling gently. The mood is romantic and spring-like.""",
    ),
    (
        "m03_junk_1",
        "3월 피1 — 벚 피 (벚꽃 피)",
        """SUBJECT: March — Cherry Junk 1 (벚 피) — JUNK card

Simple composition of cherry blossom branches with pink flowers.
Perhaps a close-up of a single branch with blossoms and a few falling petals.
Understated spring beauty.""",
    ),
    (
        "m03_junk_2",
        "3월 피2 — 벚 피 (벚꽃 피)",
        """SUBJECT: March — Cherry Junk 2 (벚 피) — JUNK card

Alternative cherry blossom composition — maybe scattered petals on water or wind-blown branches.
Distinct from Junk 1. Peaceful, ephemeral mood.""",
    ),

    # ━━━ 4월 藤 등나무 ━━━
    (
        "m04_animal",
        "4월 십 — 등 두견새 (등나무와 두견새)",
        """SUBJECT: April — Wisteria & Cuckoo (등 두견새) — ANIMAL card

A cuckoo bird (두견새/杜鵑) — a slender brown/grey bird — in flight or perched near cascading wisteria (등나무/藤) flowers.
Wisteria hangs in long, elegant purple/lavender clusters drooping downward like curtains of flowers.
The cuckoo is shown mid-call or in graceful flight among the wisteria.
Atmosphere: late spring elegance, slightly melancholic beauty.""",
    ),
    (
        "m04_ribbon",
        "4월 띠 — 등 초단 (등나무 초록띠)",
        """SUBJECT: April — Wisteria Grass Ribbon (등 초단) — RIBBON card

Wisteria branches with purple/lavender flower clusters hanging down.
A grass-green ribbon (초단) — short, with simple design — woven among the wisteria.
The green ribbon contrasts with the purple flowers. Spring garden mood.""",
    ),
    (
        "m04_junk_1",
        "4월 피1 — 등 피 (등나무 피)",
        """SUBJECT: April — Wisteria Junk 1 (등 피) — JUNK card

Simple wisteria flower clusters hanging from vines. No bird, no ribbon.
Focus on the drooping purple/lavender flowers. Quiet elegance.""",
    ),
    (
        "m04_junk_2",
        "4월 피2 — 등 피 (등나무 피)",
        """SUBJECT: April — Wisteria Junk 2 (등 피) — JUNK card

Alternative wisteria composition — perhaps a close-up of flower clusters or vine tendrils.
Distinct from Junk 1.""",
    ),

    # ━━━ 5월 菖 창포 (난초/붓꽃) ━━━
    (
        "m05_animal",
        "5월 십 — 창포 다리 (창포와 나무다리)",
        """SUBJECT: May — Iris & Wooden Bridge (창포 다리/八橋) — ANIMAL card

A scenic wooden plank bridge (팔작다리/八橋) arching over a pond or stream, surrounded by blooming iris flowers (창포/菖蒲).
The irises are deep purple/blue with elegant sword-like leaves growing from the water's edge.
The bridge is rustic wood planks in a zigzag pattern, a classic Japanese/Korean garden element.
Atmosphere: serene garden, still water reflecting irises.""",
    ),
    (
        "m05_ribbon",
        "5월 띠 — 창포 초단 (창포 초록띠)",
        """SUBJECT: May — Iris Grass Ribbon (창포 초단) — RIBBON card

Iris flowers (deep purple/blue) with their distinctive sword-shaped leaves.
A grass-green ribbon (초단) woven among the iris blooms.
Waterside garden atmosphere.""",
    ),
    (
        "m05_junk_1",
        "5월 피1 — 창포 피 (창포 피)",
        """SUBJECT: May — Iris Junk 1 (창포 피) — JUNK card

Simple iris flowers growing by water. No bridge, no ribbon.
Focus on the elegant purple blooms and blade-like leaves.""",
    ),
    (
        "m05_junk_2",
        "5월 피2 — 창포 피 (창포 피)",
        """SUBJECT: May — Iris Junk 2 (창포 피) — JUNK card

Alternative iris composition — perhaps a single bloom reflected in still water.
Distinct from Junk 1.""",
    ),

    # ━━━ 6월 牡 모란 ━━━
    (
        "m06_animal",
        "6월 십 — 모란 나비 (모란과 나비)",
        """SUBJECT: June — Peony & Butterfly (모란 나비) — ANIMAL card

One or two colorful butterflies fluttering near large, luxurious peony flowers (모란/牡丹) in full bloom.
Peonies are big, lush, multi-layered flowers in deep red/pink/crimson.
The butterflies have detailed, colorful wings — perhaps a yellow swallowtail.
Atmosphere: peak summer abundance, wealth and prosperity (peony = king of flowers in Korean culture).""",
    ),
    (
        "m06_ribbon",
        "6월 띠 — 모란 청단 (모란 파란띠)",
        """SUBJECT: June — Peony Blue Ribbon (모란 청단) — RIBBON card

Lush peony flowers in deep red/pink.
A blue/indigo ribbon (청단) with elegant traditional patterns woven among the peony blooms.
Rich, opulent summer mood.""",
    ),
    (
        "m06_junk_1",
        "6월 피1 — 모란 피 (모란 피)",
        """SUBJECT: June — Peony Junk 1 (모란 피) — JUNK card

Simple peony blossoms — perhaps a single large bloom or peony buds.
No butterfly, no ribbon. Focus on the flower's natural beauty.""",
    ),
    (
        "m06_junk_2",
        "6월 피2 — 모란 피 (모란 피)",
        """SUBJECT: June — Peony Junk 2 (모란 피) — JUNK card

Alternative peony composition — maybe petals scattering or a side view of the bloom.
Distinct from Junk 1.""",
    ),

    # ━━━ 7월 萩 싸리 ━━━
    (
        "m07_animal",
        "7월 십 — 싸리 멧돼지 (싸리나무와 멧돼지)",
        """SUBJECT: July — Bush Clover & Wild Boar (싸리 멧돼지) — ANIMAL card

A powerful wild boar (멧돼지/猪) charging or standing boldly among bush clover (싸리/萩) plants.
Bush clover has small, delicate pink/magenta flowers on arching stems with tiny leaves.
The boar is muscular, dark-bristled, fierce — a dramatic contrast with the delicate flowers.
Atmosphere: wild energy, late summer vitality, untamed nature.""",
    ),
    (
        "m07_ribbon",
        "7월 띠 — 싸리 초단 (싸리 초록띠)",
        """SUBJECT: July — Bush Clover Grass Ribbon (싸리 초단) — RIBBON card

Bush clover branches with tiny pink/magenta flowers.
A grass-green ribbon (초단) among the delicate branches.
Late summer wildflower atmosphere.""",
    ),
    (
        "m07_junk_1",
        "7월 피1 — 싸리 피 (싸리 피)",
        """SUBJECT: July — Bush Clover Junk 1 (싸리 피) — JUNK card

Simple bush clover branches with small pink flowers. No boar, no ribbon.
Gentle, wild meadow mood.""",
    ),
    (
        "m07_junk_2",
        "7월 피2 — 싸리 피 (싸리 피)",
        """SUBJECT: July — Bush Clover Junk 2 (싸리 피) — JUNK card

Alternative bush clover composition. Distinct from Junk 1.
Perhaps wind-blown branches or a wider meadow scene.""",
    ),

    # ━━━ 8월 芒 억새 ━━━
    (
        "m08_bright",
        "8월 광 — 억새 달 (억새밭의 보름달)",
        """SUBJECT: August — Susuki Moon (억새 달) — BRIGHT card (highest tier)

A magnificent full moon (보름달/望月) — large, luminous, golden-white — rising over a field of silver pampas grass / susuki (억새/芒).
The susuki grass has tall feathery plumes that glow silver-gold in the moonlight, swaying gently.
A vast night sky surrounds the moon. The grass stretches to the horizon.
Atmosphere: serene autumn night, harvest moon (추석/秋夕), romantic melancholy.
This is one of the most iconic and beautiful Hwatu cards.""",
    ),
    (
        "m08_animal",
        "8월 십 — 억새 기러기 (억새와 기러기)",
        """SUBJECT: August — Susuki & Wild Geese (억새 기러기) — ANIMAL card

A formation of wild geese (기러기/雁) — typically 3 birds in a V-formation — flying across an autumn sky above susuki grass fields.
The geese are silhouetted or detailed against the twilight/dusk sky.
Below, silver pampas grass (억새) plumes sway in the wind.
Atmosphere: autumn migration, changing seasons, poetic longing.""",
    ),
    (
        "m08_junk_1",
        "8월 피1 — 억새 피 (억새 피)",
        """SUBJECT: August — Susuki Junk 1 (억새 피) — JUNK card

Simple susuki/pampas grass plumes swaying in autumn wind.
No moon, no geese. Focus on the graceful silver grass.
Quiet autumn field mood.""",
    ),
    (
        "m08_junk_2",
        "8월 피2 — 억새 피 (억새 피)",
        """SUBJECT: August — Susuki Junk 2 (억새 피) — JUNK card

Alternative susuki composition — perhaps a close-up of feathery plumes or grass at sunset.
Distinct from Junk 1.""",
    ),

    # ━━━ 9월 菊 국화 ━━━
    (
        "m09_double",
        "9월 십 — 국화 술잔 (국화와 술잔)",
        """SUBJECT: September — Chrysanthemum & Sake Cup (국화 술잔/菊盃) — ANIMAL card (double junk)

A elegant sake/rice wine cup (술잔/盃) placed among blooming chrysanthemum flowers (국화/菊).
The cup is ceramic, possibly with blue/white traditional patterns, with golden wine inside reflecting the flowers.
Large, detailed chrysanthemums — golden yellow, with many layered petals — surround the cup.
Atmosphere: autumn festival, 중양절 (Double Ninth Festival), refined elegance.
This card represents the tradition of drinking chrysanthemum wine.""",
    ),
    (
        "m09_ribbon",
        "9월 띠 — 국화 청단 (국화 파란띠)",
        """SUBJECT: September — Chrysanthemum Blue Ribbon (국화 청단) — RIBBON card

Golden chrysanthemum flowers in full bloom.
A blue/indigo ribbon (청단) with traditional patterns among the chrysanthemums.
Autumn elegance, golden and blue contrast.""",
    ),
    (
        "m09_junk_1",
        "9월 피1 — 국화 피 (국화 피)",
        """SUBJECT: September — Chrysanthemum Junk 1 (국화 피) — JUNK card

Simple chrysanthemum blooms — golden yellow, detailed petals.
No cup, no ribbon. Pure flower appreciation.
Autumn garden mood.""",
    ),
    (
        "m09_junk_2",
        "9월 피2 — 국화 피 (국화 피)",
        """SUBJECT: September — Chrysanthemum Junk 2 (국화 피) — JUNK card

Alternative chrysanthemum composition. Distinct from Junk 1.
Perhaps a single perfect bloom or chrysanthemum buds.""",
    ),

    # ━━━ 10월 楓 단풍 ━━━
    (
        "m10_animal",
        "10월 십 — 단풍 사슴 (단풍과 사슴)",
        """SUBJECT: October — Maple & Deer (단풍 사슴/鹿) — ANIMAL card

A graceful deer (사슴/鹿) standing or resting beneath vibrant autumn maple trees (단풍나무/楓).
The maple leaves are ablaze in vivid reds, oranges, and golds — peak autumn foliage.
The deer is elegant — perhaps a young buck with small antlers, looking alert.
Atmosphere: peak autumn beauty, serene forest, traditional East Asian painting subject.""",
    ),
    (
        "m10_ribbon",
        "10월 띠 — 단풍 청단 (단풍 파란띠)",
        """SUBJECT: October — Maple Blue Ribbon (단풍 청단) — RIBBON card

Brilliant red/orange maple leaves on branches.
A blue/indigo ribbon (청단) with traditional patterns among the maple foliage.
The contrast of fiery red leaves and cool blue ribbon is striking.""",
    ),
    (
        "m10_junk_1",
        "10월 피1 — 단풍 피 (단풍 피)",
        """SUBJECT: October — Maple Junk 1 (단풍 피) — JUNK card

Simple maple leaf branches in autumn colors. No deer, no ribbon.
Focus on the beauty of red/orange/gold maple leaves.
Perhaps some leaves falling.""",
    ),
    (
        "m10_junk_2",
        "10월 피2 — 단풍 피 (단풍 피)",
        """SUBJECT: October — Maple Junk 2 (단풍 피) — JUNK card

Alternative maple composition — maybe fallen leaves on water or a single vivid branch.
Distinct from Junk 1.""",
    ),

    # ━━━ 11월 桐 오동 ━━━
    (
        "m11_bright",
        "11월 광 — 오동 봉황 (오동나무와 봉황)",
        """SUBJECT: November — Paulownia & Phoenix (오동 봉황/鳳凰) — BRIGHT card (highest tier)

A magnificent phoenix (봉황/鳳凰) — the mythical Korean/East Asian firebird — with elaborate, flowing tail feathers, spreading its wings majestically above or perched on a paulownia tree (오동나무/桐).
The phoenix has golden, red, and multicolored plumage with long, ornate tail feathers streaming behind it.
The paulownia tree has large, heart-shaped leaves and may show its purple bell-shaped flowers.
Atmosphere: supreme nobility, mythical power. The phoenix only rests on the paulownia tree in legend.
This is the second most prestigious Bright card after January's Crane.""",
    ),
    (
        "m11_junk_1",
        "11월 피1 — 오동 피 (오동 피)",
        """SUBJECT: November — Paulownia Junk 1 (오동 피) — JUNK card

Simple paulownia tree — large heart-shaped leaves, perhaps a few purple bell-shaped flowers.
No phoenix. Quiet autumn scene.
The paulownia has smooth grey bark and distinctive oversized leaves.""",
    ),
    (
        "m11_junk_2",
        "11월 피2 — 오동 피 (오동 피)",
        """SUBJECT: November — Paulownia Junk 2 (오동 피) — JUNK card

Alternative paulownia composition — maybe fallen leaves or bare winter branches.
Distinct from Junk 1. Late autumn mood transitioning to winter.""",
    ),
    (
        "m11_double",
        "11월 쌍피 — 오동 쌍피",
        """SUBJECT: November — Paulownia Double Junk (오동 쌍피) — DOUBLE JUNK card

Paulownia composition slightly more elaborate than regular junk cards.
Perhaps paulownia seed pods or a fuller branch scene.
Worth double the points of a regular junk card — slightly more interesting composition.""",
    ),

    # ━━━ 12월 柳 버들 / 비 ━━━
    (
        "m12_bright",
        "12월 광 — 비 (비오는 버들/소야 Rain Man)",
        """SUBJECT: December — Rain / Ono no Michikaze (비/柳に小野道風) — BRIGHT card (highest tier)

A dramatic scene in pouring rain — a figure holding a traditional Korean/Japanese umbrella (우산/番傘) walks along a path near a weeping willow tree (버들/柳).
Heavy rain streaks fill the scene. Lightning or stormy sky in the background.
The weeping willow's branches hang down, swaying in the storm.
A small frog (개구리) may be visible, leaping or sitting nearby — this is a traditional element.
Atmosphere: dramatic storm, resilience, the beauty in adversity.
This is the most unique and dramatic Bright card in Hwatu.""",
    ),
    (
        "m12_animal",
        "12월 십 — 버들 제비 (버들과 제비)",
        """SUBJECT: December — Willow & Swallow (버들 제비/燕) — ANIMAL card

A swallow (제비/燕) in graceful, acrobatic flight — swooping near a weeping willow tree (버들/柳).
The swallow has a forked tail, dark blue-black upper body and light underside.
Weeping willow branches with long, slender leaves hang down elegantly.
Light rain may be falling. The swallow flies skillfully through the willow branches.
Atmosphere: end of year, dynamic movement, coming and going.""",
    ),
    (
        "m12_ribbon",
        "12월 띠 — 버들 띠 (버들 띠)",
        """SUBJECT: December — Willow Ribbon (버들 띠) — RIBBON card (plain type)

Weeping willow branches with their characteristic long, slender drooping leaves.
A plain ribbon — not red, blue, or green, but a neutral/muted tone — among the willow branches.
Rain or mist atmosphere. End-of-year melancholy.
This is the only "plain" ribbon in Hwatu, worth less than colored ribbons.""",
    ),
    (
        "m12_double",
        "12월 쌍피 — 버들 쌍피",
        """SUBJECT: December — Willow Double Junk (버들 쌍피) — DOUBLE JUNK card

Willow branches in rain — a simpler composition but slightly more detailed than regular junk.
Perhaps willow catkins or rain-heavy branches.
Worth double points. Storm/rain atmosphere.""",
    ),

    # ━━━ 보너스 쌍피 (조커) ━━━
    (
        "bonus_1",
        "보너스 쌍피 1",
        """SUBJECT: Bonus Double Junk 1 — Joker card

A mystical, ornate design representing a wild/bonus card in a Korean Hwatu deck.
Design concept: a traditional Korean lucky charm or talisman (부적/符籍) with glowing mystical energy.
Perhaps a stylized lotus, cloud pattern (구름문양), or mythical creature emerging from swirling energy.
Golden and crimson tones with magical sparkle effects.
Should feel special, lucky, and different from the monthly flower cards.""",
    ),
    (
        "bonus_2",
        "보너스 쌍피 2",
        """SUBJECT: Bonus Double Junk 2 — Joker card

A second mystical bonus card design, distinct from Bonus 1.
Design concept: a mythical Korean motif — perhaps a haetae (해태/獬豸), a phoenix feather, or a celestial dragon scale.
Blue and silver tones with ethereal glow effects to contrast with Bonus 1's warm palette.
Should feel equally special but visually distinct.""",
    ),
]


def generate_card(client: genai.Client, card_id: str, card_name: str, description: str) -> Path | None:
    """Imagen 4 Ultra로 카드 1장 생성"""
    full_prompt = STYLE_PREFIX + "\n" + description

    try:
        response = client.models.generate_images(
            model="imagen-4.0-ultra-generate-001",
            prompt=full_prompt,
            config=types.GenerateImagesConfig(
                number_of_images=1,
                aspect_ratio="3:4",
            ),
        )

        for img in response.generated_images:
            out_path = OUTPUT_DIR / f"{card_id}.png"
            out_path.write_bytes(img.image.image_bytes)
            size_kb = len(img.image.image_bytes) / 1024
            print(f"  ✅ Saved: {card_id}.png ({size_kb:.0f} KB)")
            return out_path

    except Exception as e:
        print(f"  ❌ Error: {e}")
        return None

    print("  ❌ No image generated")
    return None


def main():
    # 시작 인덱스 (이어서 생성할 때 사용)
    start_idx = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    end_idx = int(sys.argv[2]) if len(sys.argv) > 2 else len(CARDS)

    client = genai.Client(api_key=API_KEY)

    print(f"=== K-Poker 만화 카드 생성 ===")
    print(f"모델: Imagen 4 Ultra")
    print(f"범위: {start_idx} ~ {end_idx - 1} (총 {end_idx - start_idx}장)")
    print(f"출력: {OUTPUT_DIR}")
    print()

    success = 0
    fail = 0

    for i in range(start_idx, min(end_idx, len(CARDS))):
        card_id, card_name, description = CARDS[i]

        # 이미 생성된 카드 스킵
        existing = OUTPUT_DIR / f"{card_id}.png"
        if existing.exists():
            print(f"[{i+1:02d}/50] {card_name} — SKIP (already exists)")
            success += 1
            continue

        print(f"[{i+1:02d}/50] {card_name} — generating...")
        result = generate_card(client, card_id, card_name, description)

        if result:
            success += 1
        else:
            fail += 1

        # API rate limit 대비 짧은 대기
        if i < end_idx - 1:
            time.sleep(2)

    print(f"\n=== 완료: {success} 성공, {fail} 실패 ===")


if __name__ == "__main__":
    main()
