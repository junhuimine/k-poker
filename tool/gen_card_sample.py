"""K-Poker 만화 스킨 카드 생성 샘플 - Gemini 3 Pro Image"""
import base64
import sys
from pathlib import Path
from google import genai
from google.genai import types

API_KEY = "AIzaSyCgzX8lE8ZbvMiTUFsZDQ0njnaGjB_ucuY"
OUTPUT_DIR = Path(__file__).parent.parent / "assets" / "images" / "cards_manga_v2"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Defense 포트레이트를 참조 이미지로 로드
DEFENSE_REF_IMAGES = [
    Path("D:/02_project/defense/assets/images/portraits/portrait_bari.png"),
    Path("D:/02_project/defense/assets/images/portraits/portrait_miho.png"),
    Path("D:/02_project/defense/assets/images/enemies/maidenGhost.png"),
]

def load_reference_image(path: Path) -> types.Part:
    """참조 이미지를 Gemini Part로 변환"""
    data = path.read_bytes()
    return types.Part.from_bytes(data=data, mime_type="image/png")


def generate_card(model_id: str, prompt: str, filename: str, ref_images: list[types.Part] | None = None):
    """카드 이미지 생성"""
    client = genai.Client(api_key=API_KEY)

    contents: list[str | types.Part] = []
    if ref_images:
        contents.extend(ref_images)
    contents.append(prompt)

    response = client.models.generate_content(
        model=model_id,
        contents=contents,
        config=types.GenerateContentConfig(
            response_modalities=["IMAGE", "TEXT"],
        ),
    )

    # 이미지 추출 및 저장
    for part in response.candidates[0].content.parts:
        if part.inline_data and part.inline_data.mime_type.startswith("image/"):
            out_path = OUTPUT_DIR / filename
            out_path.write_bytes(part.inline_data.data)
            print(f"Saved: {out_path} ({len(part.inline_data.data) / 1024:.1f} KB)")
            return out_path
        elif part.text:
            print(f"Text response: {part.text[:200]}")

    print("No image generated!")
    return None


STYLE_PROMPT = """You are creating a premium collectible Hwatu (Korean flower card) game card illustration.

STYLE REFERENCE: I've attached reference images showing the target art style - semi-realistic digital illustration with:
- Rich, vibrant colors with dramatic lighting and glow effects
- Dark/moody backgrounds with particle/sparkle effects
- Smooth gradients and gem-like luminous quality
- Mobile RPG / gacha game premium card aesthetic
- Korean traditional + fantasy fusion style

CARD TO CREATE: January Pine & Crane (광/Bright card - highest tier)

COMPOSITION:
- A majestic red-crowned crane (두루미) spreading its wings, landing on an ancient twisted pine tree
- A large crimson sun/moon in the background radiating golden light
- Traditional Korean Hwatu card composition but rendered in premium illustration style
- Dark navy/emerald background with golden light rays

REQUIREMENTS:
- Portrait orientation (3:4 ratio), suitable as a game card
- NO text, NO numbers, NO borders, NO frames - pure illustration only
- The crane should be the focal point with ethereal glow
- Pine needles should have detailed, lush rendering
- Overall feeling: premium, collectible, magical
- Style must match the reference images' quality level
"""

if __name__ == "__main__":
    model = sys.argv[1] if len(sys.argv) > 1 else "gemini-3-pro-image-preview"
    print(f"Using model: {model}")
    print(f"Output dir: {OUTPUT_DIR}")

    # 참조 이미지 로드
    refs = []
    for ref_path in DEFENSE_REF_IMAGES:
        if ref_path.exists():
            refs.append(load_reference_image(ref_path))
            print(f"Loaded reference: {ref_path.name}")
        else:
            print(f"Reference not found: {ref_path}")

    print(f"\nGenerating with {len(refs)} reference images...")
    result = generate_card(
        model_id=model,
        prompt=STYLE_PROMPT,
        filename=f"m01_bright_{model.split('-')[1]}.png",
        ref_images=refs if refs else None,
    )

    if result:
        print(f"\nDone! Check: {result}")
    else:
        print("\nFailed to generate image.")
