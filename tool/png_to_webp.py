"""PNG -> WebP 일괄 변환.

카드 이미지(assets/images/cards/*.png)를 WebP로 변환.
원본 PNG는 변환 후 삭제하지 않음 (코드 치환 후 수동 삭제).
"""
from PIL import Image
import glob
import os
import sys

SRC_DIR = "assets/images/cards"
QUALITY = 92  # lossy, 시각적 차이 거의 없음
METHOD = 6    # 압축 품질 최대 (느리지만 최소 크기)


def convert_one(png_path: str) -> tuple[int, int]:
    webp_path = png_path[:-4] + ".webp"
    with Image.open(png_path) as im:
        has_alpha = im.mode in ("RGBA", "LA") or (im.mode == "P" and "transparency" in im.info)
        if has_alpha:
            # 알파 유지 — lossless로 가거나 lossy+alpha 품질 분리
            im.save(webp_path, "WEBP", lossless=True, method=METHOD)
        else:
            # 불투명 — lossy 고품질
            if im.mode != "RGB":
                im = im.convert("RGB")
            im.save(webp_path, "WEBP", quality=QUALITY, method=METHOD)
    return os.path.getsize(png_path), os.path.getsize(webp_path)


def main() -> int:
    pngs = sorted(glob.glob(os.path.join(SRC_DIR, "*.png")))
    if not pngs:
        print(f"No PNG found in {SRC_DIR}", file=sys.stderr)
        return 1

    total_png = 0
    total_webp = 0
    for p in pngs:
        png_size, webp_size = convert_one(p)
        total_png += png_size
        total_webp += webp_size
        print(f"  {os.path.basename(p):<28} {png_size // 1024:>5} KB -> {webp_size // 1024:>5} KB")

    pct = 100 * total_webp / total_png if total_png else 0
    print(f"\nTotal: {total_png // 1024 // 1024} MB -> {total_webp // 1024 // 1024} MB ({pct:.1f}% of original)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
