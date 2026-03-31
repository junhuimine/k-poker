"""
deploy_zip.py -- itch.io ZIP generator
========================================
Run after deploy_patch.py.

IMPORTANT: Do NOT use PowerShell Compress-Archive!
           It causes 403 for all assets on itch.io.
           Always use Python zipfile.

Usage:
  python tool/deploy_zip.py
"""

import zipfile, os, sys

SRC = os.path.join(os.path.dirname(os.path.dirname(__file__)), "build", "web")
OUT = os.path.join(os.path.dirname(os.path.dirname(__file__)), "k-poker-itchio.zip")

if __name__ == "__main__":
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

    if not os.path.exists(SRC):
        print("[!] build/web not found -- run flutter build web --release + deploy_patch.py first")
        exit(1)

    print(f"\n[*] Creating itch.io ZIP...")
    print(f"    src: {SRC}")
    print(f"    out: {OUT}\n")

    count = 0
    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
        for root, dirs, files in os.walk(SRC):
            # skip hidden/tool directories
            dirs[:] = [d for d in dirs if not d.startswith('.')]
            for fname in files:
                full = os.path.join(root, fname)
                arcname = os.path.relpath(full, SRC).replace(os.sep, '/')
                z.write(full, arcname)
                count += 1

    size_mb = os.path.getsize(OUT) / (1024 * 1024)
    print(f"[OK] ZIP created!")
    print(f"     files: {count}")
    print(f"     size:  {size_mb:.1f} MB")
    print(f"     path:  {OUT}")
    print(f"\n  -> Upload to itch.io: {OUT}\n")
