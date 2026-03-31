"""
K-Poker — 만화 스타일 화투 카드 생성기
Google AI Studio Imagen 4.0 API로 50장 생성
"""

import requests
import base64
import time
import sys
from pathlib import Path
from typing import Optional

# ── 설정 ──
KEY_FILE = Path(__file__).parent / "geminikey.txt"
MODEL = "imagen-4.0-generate-001"
API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:predict"
OUTPUT_DIR = Path(__file__).parent.parent / "assets" / "images" / "cards_manga"

# 리미트 대응: Imagen 4.0 무료 tier = 분당 10회
DELAY_BETWEEN_REQUESTS = 7.0  # 안전 마진 포함


def load_api_key() -> str:
    """API 키 파일에서 읽기"""
    key = KEY_FILE.read_text(encoding="utf-8").strip()
    if not key.startswith("AIza"):
        raise RuntimeError(f"유효하지 않은 API 키: {key[:10]}...")
    return key


def generate_image(prompt: str, api_key: str) -> Optional[bytes]:
    """Imagen 4.0 API로 이미지 생성"""
    payload = {
        "instances": [{"prompt": prompt}],
        "parameters": {
            "sampleCount": 1,
            "aspectRatio": "3:4",
            "outputOptions": {"mimeType": "image/png"},
        },
    }

    resp = requests.post(
        f"{API_URL}?key={api_key}",
        json=payload,
        headers={"Content-Type": "application/json"},
        timeout=120,
    )

    if resp.status_code == 429:
        print("  [RATE LIMIT] — 30초 대기...")
        time.sleep(30)
        resp = requests.post(
            f"{API_URL}?key={api_key}",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=120,
        )

    if resp.status_code != 200:
        print(f"  [FAIL] API 에러 {resp.status_code}: {resp.text[:300]}")
        return None

    data = resp.json()
    predictions = data.get("predictions", [])
    if not predictions:
        print(f"  [FAIL] 빈 응답")
        return None

    b64_image = predictions[0].get("bytesBase64Encoded", "")
    if not b64_image:
        print(f"  [FAIL] base64 데이터 없음")
        return None

    return base64.b64decode(b64_image)


# ── 화투 카드별 프롬프트 ──

MONTH_INFO: dict[int, dict[str, str]] = {
    1:  {"flower": "pine tree", "ko": "소나무/학", "color": "dark green", "bright_element": "crane bird standing under pine with red sun"},
    2:  {"flower": "plum blossom", "ko": "매화/꾀꼬리", "color": "pink red", "animal": "bush warbler bird perched on branch"},
    3:  {"flower": "cherry blossom", "ko": "벚꽃/커튼", "color": "soft pink", "bright_element": "elegant curtain draped under cherry tree"},
    4:  {"flower": "wisteria", "ko": "등/뻐꾸기", "color": "purple", "animal": "cuckoo bird flying over wisteria"},
    5:  {"flower": "iris orchid", "ko": "난초/다리", "color": "violet blue", "animal": "wooden bridge over iris pond with moonlight"},
    6:  {"flower": "peony", "ko": "모란/나비", "color": "deep crimson red", "animal": "pair of butterflies dancing around peonies"},
    7:  {"flower": "bush clover", "ko": "싸리/멧돼지", "color": "warm orange", "animal": "wild boar charging through bush clover field"},
    8:  {"flower": "pampas grass and full moon", "ko": "억새/달/기러기", "color": "golden yellow", "bright_element": "majestic full moon over pampas grass field", "animal": "V-formation geese flying across full moon"},
    9:  {"flower": "chrysanthemum", "ko": "국화/술잔", "color": "bright yellow"},
    10: {"flower": "maple leaves", "ko": "단풍/사슴", "color": "red orange", "animal": "deer standing gracefully among maple leaves"},
    11: {"flower": "paulownia", "ko": "오동/봉황", "color": "brown gold", "bright_element": "mythical phoenix rising from paulownia tree"},
    12: {"flower": "willow in rain", "ko": "비/제비/사람", "color": "dark blue grey", "bright_element": "man with umbrella and swallow bird in rain", "animal": "swallow bird flying through rain and willow"},
}

STYLE_BASE = (
    "manga anime style Korean Hwatu flower card game illustration, "
    "bold black outlines, vibrant cel-shaded coloring, "
    "traditional Korean floral art meets Japanese manga aesthetic, "
    "clean vertical card design, detailed linework, "
    "no text, no numbers, no border frame, "
    "white or simple gradient background"
)

CARD_PROMPTS: dict[str, str] = {}

for m_num, info in MONTH_INFO.items():
    m_id = f"m{m_num:02d}"
    flower = info["flower"]
    color = info["color"]
    style = f"{STYLE_BASE}, {color} color palette, {flower} theme"

    # Bright (광)
    if "bright_element" in info:
        CARD_PROMPTS[f"{m_id}_bright"] = (
            f"{style}, BRIGHT premium card, {info['bright_element']}, "
            f"dramatic golden lighting, majestic and powerful atmosphere, "
            f"glowing aura effect, most valuable card in the set"
        )

    # Animal (열끗)
    if "animal" in info:
        CARD_PROMPTS[f"{m_id}_animal"] = (
            f"{style}, ANIMAL card, {info['animal']}, "
            f"dynamic natural scene with {flower}, lively and detailed"
        )

    # Ribbon (띠)
    ribbon_types: dict[int, str] = {
        1: "red poetry ribbon banner", 2: "red poetry ribbon",
        3: "red poetry ribbon banner", 4: "plain red ribbon strip",
        5: "plain red ribbon strip", 6: "blue poetry ribbon banner",
        7: "plain red ribbon strip", 9: "blue poetry ribbon banner",
        10: "blue poetry ribbon banner", 12: "plain red ribbon strip",
    }
    if m_num in ribbon_types:
        CARD_PROMPTS[f"{m_id}_ribbon"] = (
            f"{style}, RIBBON card, {ribbon_types[m_num]} draped among {flower}, "
            f"decorative flowing banner, elegant composition"
        )

    # Junk (피) x2
    for j in [1, 2]:
        variant = "scattered petals falling" if j == 1 else "single elegant stem"
        CARD_PROMPTS[f"{m_id}_junk_{j}"] = (
            f"{style}, JUNK simple card, minimalist {flower} pattern, "
            f"{variant}, subtle and clean, common card"
        )

    # Double junk (쌍피)
    if m_num in [9, 11, 12]:
        CARD_PROMPTS[f"{m_id}_double"] = (
            f"{style}, DOUBLE JUNK card, two {flower} patterns side by side, "
            f"worth double points, slightly more ornate than regular junk"
        )

# Bonus cards (보너스 쌍피)
CARD_PROMPTS["bonus_1"] = (
    f"{STYLE_BASE}, BONUS special card, golden sparkle design, "
    f"double cherry blossom pattern, premium shimmering effect, "
    f"golden and pink colors, rare collector card feeling"
)
CARD_PROMPTS["bonus_2"] = (
    f"{STYLE_BASE}, BONUS special card, silver sparkle design, "
    f"double chrysanthemum pattern, premium shimmering effect, "
    f"silver and yellow colors, rare collector card feeling"
)


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"K-Poker Manga Card Generator (Imagen 4.0)")
    print(f"   Output: {OUTPUT_DIR}")
    print(f"   Total cards: {len(CARD_PROMPTS)}")
    print()

    # 이미 생성된 카드 건너뛰기
    existing = {f.stem for f in OUTPUT_DIR.glob("*.png")}
    to_generate = {k: v for k, v in CARD_PROMPTS.items() if k not in existing}

    if not to_generate:
        print("All cards already generated!")
        return

    print(f"   Already done: {len(existing)}")
    print(f"   To generate: {len(to_generate)}")
    print(f"   ETA: ~{len(to_generate) * DELAY_BETWEEN_REQUESTS / 60:.1f} min")
    print()

    api_key = load_api_key()
    print("API key loaded")
    print()

    success = 0
    fail = 0
    total = len(to_generate)

    for i, (card_id, prompt) in enumerate(to_generate.items(), 1):
        print(f"[{i}/{total}] Generating: {card_id}")

        image_bytes = generate_image(prompt, api_key)

        if image_bytes:
            out_path = OUTPUT_DIR / f"{card_id}.png"
            out_path.write_bytes(image_bytes)
            size_kb = len(image_bytes) // 1024
            print(f"  OK: {out_path.name} ({size_kb}KB)")
            success += 1
        else:
            fail += 1
            # 재시도
            print(f"  Retrying in 15s...")
            time.sleep(15)
            image_bytes = generate_image(prompt, api_key)
            if image_bytes:
                out_path = OUTPUT_DIR / f"{card_id}.png"
                out_path.write_bytes(image_bytes)
                print(f"  Retry OK: {out_path.name}")
                success += 1
                fail -= 1

        if i < total:
            time.sleep(DELAY_BETWEEN_REQUESTS)

    print()
    print(f"Done! Success: {success}, Failed: {fail}")
    print(f"Output: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
