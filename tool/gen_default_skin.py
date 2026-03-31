"""
K-Poker 기본 스킨 카드 생성 — Imagen 4 Ultra
실제 화투 구도 참조 + 고퀄 만화 일러스트 스타일
"""
import sys
import os
import time
from pathlib import Path
from google import genai
from google.genai import types

os.environ["PYTHONIOENCODING"] = "utf-8"
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.stderr.reconfigure(encoding="utf-8", errors="replace")

API_KEY = "AIzaSyCgzX8lE8ZbvMiTUFsZDQ0njnaGjB_ucuY"
OUTPUT_DIR = Path("D:/02_project/08_k-poker/assets/images/cards")
MODEL = "imagen-4.0-ultra-generate-001"

STYLE = """You are illustrating a premium Korean Hwatu (화투) card for a collectible card game.

ART STYLE — follow this EXACTLY like the reference quality:
- High-quality manga/anime illustration with clean bold linework and vivid cel-shading
- Vivid, highly saturated colors with smooth gradients — the illustration must FILL THE ENTIRE CANVAS edge to edge
- Bright, warm color palette with a golden/amber sky or warm-toned background
- Traditional Korean/Japanese Hwatu card composition reimagined in polished modern manga style
- Every card — including junk cards — must have a FULL, rich composition filling the whole frame
- Even simple flower-only cards should show lush, detailed botanical illustration filling the canvas
- Professional TCG card art quality — bold, clean, vibrant
- Portrait orientation, 3:4 aspect ratio

ABSOLUTE RULES:
- NO text, NO numbers, NO letters, NO symbols, NO icons, NO borders, NO frames
- NO diamond shapes, NO card suit symbols, NO UI elements of any kind
- The illustration must fill the ENTIRE canvas — no empty corners, no blank areas
- Pure illustration only
"""

CARDS = [
    # ━━━ 1월 松 소나무 ━━━
    ("m01_bright",
     "January Pine Crane (송학/光). A red-crowned crane with wings spread stands atop a twisted pine tree. A large red sun disc in the upper portion. The pine has dark green needle clusters on gnarled branches. Background: warm sky with the prominent red sun. This is the most iconic Hwatu card."),
    ("m01_ribbon",
     "January Pine Red Ribbon (송 홍단). Pine tree branches with dark green needle clusters. A bright red ribbon with gold decorative patterns (홍단) hangs vertically among the pine branches. Traditional Hwatu layout — ribbon is prominently displayed in the center."),
    ("m01_junk_1",
     "January Pine Junk (송 피). A lush, full composition of pine tree branches with dense dark green needle clusters filling the entire canvas. A grand old pine trunk curves through the frame with abundant needle bunches. Warm golden sky visible between the branches. Rich botanical detail — every pine needle rendered crisply."),
    ("m01_junk_2",
     "January Pine Junk 2 (송 피). A different angle of pine — looking up through dense pine canopy with twisted branches spreading across the frame. Pine cones hang from branches. Warm amber light filters through the thick green needles. The entire canvas is filled with pine foliage."),

    # ━━━ 2월 梅 매화 ━━━
    ("m02_animal",
     "February Plum Warbler (매조/十). A small yellow-green bush warbler (꾀꼬리) perched on a plum blossom branch, singing. Delicate pink/white five-petaled plum blossoms on dark gnarled branches. Traditional Hwatu composition — bird is the focal point among blossoms."),
    ("m02_ribbon",
     "February Plum Red Ribbon (매 홍단). Plum blossom branches with pink flowers. A bright red ribbon (홍단) with gold patterns displayed prominently among the plum branches. Clean manga style."),
    ("m02_junk_1",
     "February Plum Junk (매 피). Plum blossom branches filling the entire canvas — dark gnarled branches with abundant pink/white five-petaled flowers in various stages of bloom. Warm sky background. Rich, lush composition with blossoms everywhere."),
    ("m02_junk_2",
     "February Plum Junk 2 (매 피). Dense plum blossom canopy seen from below — branches crisscrossing the frame loaded with pink blossoms and buds. A few petals drifting down. Warm golden light. The entire canvas overflows with plum blossoms."),

    # ━━━ 3월 桜 벚꽃 ━━━
    ("m03_bright",
     "March Cherry Curtain (벚꽃 막/光). A dramatic red and gold ornate viewing curtain (幕) draped between cherry blossom trees in full bloom. Clouds of pink cherry blossoms overhead with petals falling. This represents the traditional flower viewing festival. Luxurious, celebratory mood."),
    ("m03_ribbon",
     "March Cherry Red Ribbon (벚 홍단). Cherry blossom branches laden with soft pink flowers. A bright red ribbon (홍단) with patterns among the cherry branches. Falling petals."),
    ("m03_junk_1",
     "March Cherry Junk (벚 피). Abundant cherry blossom branches filling the entire canvas — clouds of soft pink flowers on dark branches. Petals drifting in warm spring breeze. Golden afternoon light. Lush, overflowing sakura scene."),
    ("m03_junk_2",
     "March Cherry Junk 2 (벚 피). A carpet of cherry blossom petals floating on a gentle stream, with blooming branches overhead filling the top of the canvas. Pink petals everywhere — on water, in air, on branches. Warm spring atmosphere."),

    # ━━━ 4월 藤 등나무/흑싸리 ━━━
    ("m04_animal",
     "April Wisteria Cuckoo (흑싸리 두견새/十). A cuckoo bird (두견새) flying among cascading wisteria flower clusters. Long purple/lavender wisteria flowers hang downward like curtains. The bird is mid-flight. In traditional Hwatu, the wisteria hangs from the top and the bird flies below."),
    ("m04_ribbon",
     "April Wisteria Grass Ribbon (초단). Wisteria flower clusters hanging down. A short grass-green ribbon (초단) — simple design, no calligraphy — among the wisteria. The green ribbon contrasts with purple flowers."),
    ("m04_junk_1",
     "April Wisteria Junk (등 피). Cascading wisteria flower clusters filling the entire canvas — long purple/lavender racemes hanging like curtains from twisting vines. Dense, lush, overflowing with blooms. Warm light filtering through."),
    ("m04_junk_2",
     "April Wisteria Junk 2 (등 피). A wisteria tunnel/archway — thick vines overhead with dense purple flower clusters hanging down from all directions, filling the frame. Dappled golden light. Rich botanical abundance."),

    # ━━━ 5월 菖蒲 창포/난초 ━━━
    ("m05_animal",
     "May Iris Bridge (창포 다리/十). A rustic wooden plank bridge (八橋/팔작다리) crossing over water, surrounded by blooming purple/blue iris flowers (창포). The irises have sword-like leaves. In traditional Hwatu, the bridge is the central element with irises growing around it."),
    ("m05_ribbon",
     "May Iris Grass Ribbon (창포 초단). Purple/blue iris flowers with sword-shaped leaves. A grass-green ribbon (초단) among the iris blooms."),
    ("m05_junk_1",
     "May Iris Junk (창포 피). Dense cluster of purple/blue iris flowers filling the canvas — tall sword-shaped leaves and multiple blooms at different heights. Water reflects at the bottom. Lush waterside garden filling every corner."),
    ("m05_junk_2",
     "May Iris Junk 2 (창포 피). Irises growing thickly along a stream bank — purple flowers and green blade leaves packed densely across the frame. Warm afternoon light. Rich, full composition."),

    # ━━━ 6월 牡丹 모란 ━━━
    ("m06_animal",
     "June Peony Butterfly (모란 나비/十). Colorful butterflies fluttering near large, luxurious red/crimson peony flowers in full bloom. In traditional Hwatu, one or two butterflies dance above the peonies. Peonies are big, lush, multi-layered flowers."),
    ("m06_ribbon",
     "June Peony Blue Ribbon (모란 청단). Large red/pink peony flowers. A blue/indigo ribbon (청단) with elegant patterns among the peonies. Rich, opulent."),
    ("m06_junk_1",
     "June Peony Junk (모란 피). Luxurious peony flowers filling the entire canvas — multiple large, multi-layered crimson/pink blooms with lush green leaves. Rich, opulent garden scene packed with peonies at full bloom."),
    ("m06_junk_2",
     "June Peony Junk 2 (모란 피). Close-up view of peony blossoms — enormous, detailed petals in deep red/pink filling the frame. Buds and fully opened flowers at various stages. Warm golden light. Canvas overflowing with peony beauty."),

    # ━━━ 7월 萩 싸리/홍싸리 ━━━
    ("m07_animal",
     "July Bush Clover Boar (홍싸리 멧돼지/十). A wild boar (멧돼지) charging through bush clover (싸리) plants. In traditional Hwatu, the boar is shown running from left to right among the small pink/red bush clover flowers on arching stems. The boar is dark, muscular, fierce."),
    ("m07_ribbon",
     "July Bush Clover Grass Ribbon (싸리 초단). Bush clover with small pink/magenta flowers on arching branches. A grass-green ribbon (초단) among the branches."),
    ("m07_junk_1",
     "July Bush Clover Junk (싸리 피). Dense bush clover (싸리/萩) branches filling the canvas — arching stems loaded with small pink/magenta flowers and tiny green leaves. A wild meadow bursting with bush clover. Warm summer light."),
    ("m07_junk_2",
     "July Bush Clover Junk 2 (싸리 피). Bush clover field — thick clusters of arching branches with pink flowers swaying in summer breeze, filling every part of the frame. Golden sunset light. Rich, wild abundance."),

    # ━━━ 8월 芒 억새/공산 ━━━
    ("m08_bright",
     "August Susuki Moon (공산 달/光). A large, luminous full moon (보름달) dominating the sky above a hill covered in silver pampas grass / susuki (억새). In traditional Hwatu, the moon is very large in the upper half, and the susuki grass fills the lower half with feathery silver plumes. Night sky. This is one of the most beautiful and iconic Hwatu cards."),
    ("m08_animal",
     "August Susuki Geese (억새 기러기/十). A formation of wild geese (기러기) — typically 3 birds in V-formation — flying across the sky above susuki grass. In traditional Hwatu, the geese are shown as dark silhouettes against a lighter sky, with grass below."),
    ("m08_junk_1",
     "August Susuki Junk (억새 피). A vast field of silver pampas grass (억새) filling the entire canvas — tall feathery plumes catching warm amber sunset light. The grass stretches across the whole frame, dense and flowing. Autumn evening atmosphere."),
    ("m08_junk_2",
     "August Susuki Junk 2 (억새 피). Close-up of susuki grass plumes — silvery white feathery tops filling the frame densely, backlit by warm golden twilight. Wind bends the grass gracefully. Rich, full botanical composition."),

    # ━━━ 9월 菊 국화 ━━━
    ("m09_double",
     "September Chrysanthemum Cup (국화 술잔/十). A ceramic sake cup (술잔/盃) placed among blooming golden chrysanthemum flowers. In traditional Hwatu, the cup is small and centrally placed, surrounded by large detailed chrysanthemums with many layered petals. Golden yellow flowers."),
    ("m09_ribbon",
     "September Chrysanthemum Blue Ribbon (국화 청단). Golden chrysanthemum flowers in full bloom. A blue/indigo ribbon (청단) with patterns among the chrysanthemums. Autumn elegance."),
    ("m09_junk_1",
     "September Chrysanthemum Junk (국화 피). Abundant golden chrysanthemum flowers filling the entire canvas — multiple large blooms with hundreds of layered petals, green leaves between them. A rich autumn garden packed with chrysanthemums."),
    ("m09_junk_2",
     "September Chrysanthemum Junk 2 (국화 피). Dense chrysanthemum patch — golden yellow flowers of various sizes filling every corner of the frame. Warm autumn light. Detailed petals rendered with manga precision. Overflowing floral abundance."),

    # ━━━ 10월 楓 단풍 ━━━
    ("m10_animal",
     "October Maple Deer (단풍 사슴/十). A graceful deer standing beneath vivid red/orange maple trees. In traditional Hwatu, the deer looks back over its shoulder, standing under a canopy of brilliant autumn maple leaves. Elegant pose."),
    ("m10_ribbon",
     "October Maple Blue Ribbon (단풍 청단). Brilliant red/orange maple leaves on branches. A blue/indigo ribbon (청단) among the fiery maple foliage. Striking contrast."),
    ("m10_junk_1",
     "October Maple Junk (단풍 피). Brilliant autumn maple branches filling the entire canvas — vivid red, orange, and gold maple leaves densely packed on branches. Warm light filtering through the canopy. A blaze of autumn color edge to edge."),
    ("m10_junk_2",
     "October Maple Junk 2 (단풍 피). Maple leaves at peak autumn — fiery red and gold leaves covering the whole frame, some falling. A thick canopy of maple foliage with warm amber backlighting. Dense, vibrant, full composition."),

    # ━━━ 11월 桐 오동 ━━━
    ("m11_bright",
     "November Paulownia Phoenix (오동 봉황/光). In traditional Hwatu, a small elegant phoenix (봉황) stands atop paulownia (오동나무/桐) leaves. The paulownia has distinctive LARGE heart-shaped leaves and the phoenix is a graceful bird with a long flowing tail — NOT a peacock, NOT a western firebird. Traditional East Asian phoenix (鳳凰) style — slender, elegant, with ribbon-like tail feathers. Yellow and red tones on the phoenix, green heart-shaped paulownia leaves."),
    ("m11_junk_1",
     "November Paulownia Junk (오동 피). Paulownia tree (오동나무/桐) filling the canvas — its distinctive very LARGE heart-shaped leaves (30-40cm wide) densely packed on branches. NOT maple. Broad, heart-shaped leaves with smooth edges. Purple bell-shaped paulownia flowers visible among the foliage. Warm autumn tones."),
    ("m11_junk_2",
     "November Paulownia Junk 2 (오동 피). Dense paulownia canopy — large heart-shaped leaves filling the frame, some turning golden in autumn. Smooth grey trunk visible. Purple bell flowers and seed pods among the broad leaves. NOT maple. Full, rich composition."),
    ("m11_double",
     "November Paulownia Double Junk (오동 쌍피). Paulownia tree in late autumn — large heart-shaped leaves, clusters of purple bell flowers, and brown seed pods filling the canvas. Warm golden-brown tones. NOT maple leaves. Rich botanical detail throughout."),

    # ━━━ 12월 柳 버들/비 ━━━
    ("m12_bright",
     "December Rain Man (비/光). In traditional Hwatu, a figure in traditional Korean clothing holds an umbrella (우산) walking in heavy rain near a weeping willow tree (버들). Rain streaks fill the entire scene. A small frog (개구리) sits nearby. Lightning may flash in the dark stormy sky. The willow's long branches droop in the rain. This is the most dramatic Hwatu card."),
    ("m12_animal",
     "December Willow Swallow (버들 제비/十). A swallow (제비) with forked tail swooping gracefully near a weeping willow tree. In traditional Hwatu, the swallow flies dynamically through drooping willow branches. Light rain falling."),
    ("m12_ribbon",
     "December Willow Ribbon (버들 띠). Weeping willow with long drooping branches. A clearly visible ribbon/banner — muted grey or tan color (this is the only 'plain' ribbon in Hwatu) — hangs prominently among the willow branches. The ribbon should be LARGE and clearly visible. Rain atmosphere."),
    ("m12_double",
     "December Willow Double Junk (버들 쌍피). Weeping willow branches filling the entire canvas, heavy with rain. Long drooping willow fronds with raindrops clinging to every leaf. Dramatic stormy atmosphere with rain streaks across the whole frame. Dense, moody, full composition."),

    # ━━━ 보너스 ━━━
    ("bonus_1",
     "Bonus Joker Card 1. A mystical Korean talisman (부적) design with golden energy swirling around it. Traditional Korean cloud patterns (구름문양) and lotus motifs. Warm golden and crimson tones. Magical, lucky feeling. This is a special wild card."),
    ("bonus_2",
     "Bonus Joker Card 2. A mythical Korean creature — a blue dragon (청룡) or haetae (해태) — rendered in elegant traditional style with modern manga polish. Cool blue and silver tones with ethereal glow. Distinct from Bonus 1. Special wild card."),
]


def main():
    start = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    end = int(sys.argv[2]) if len(sys.argv) > 2 else len(CARDS)

    client = genai.Client(api_key=API_KEY)

    print(f"=== K-Poker 기본 스킨 생성 ===")
    print(f"모델: Imagen 4 Ultra | 스타일: 고퀄 만화")
    print(f"범위: {start}~{end-1} ({end-start}장)")
    print(f"출력: {OUTPUT_DIR}\n")

    ok = 0
    fail = 0

    for i in range(start, min(end, len(CARDS))):
        card_id, desc = CARDS[i]
        out = OUTPUT_DIR / f"{card_id}.png"

        if out.exists():
            print(f"[{i+1:02d}/50] {card_id} — SKIP")
            ok += 1
            continue

        print(f"[{i+1:02d}/50] {card_id} — generating...")
        try:
            resp = client.models.generate_images(
                model=MODEL,
                prompt=STYLE + "\n" + desc,
                config=types.GenerateImagesConfig(number_of_images=1, aspect_ratio="3:4"),
            )
            for img in resp.generated_images:
                out.write_bytes(img.image.image_bytes)
                print(f"  OK ({len(img.image.image_bytes)//1024} KB)")
                ok += 1
        except Exception as e:
            print(f"  FAIL: {e}")
            fail += 1

        if i < end - 1:
            time.sleep(2)

    print(f"\n=== 완료: {ok} OK, {fail} FAIL ===")


if __name__ == "__main__":
    main()
