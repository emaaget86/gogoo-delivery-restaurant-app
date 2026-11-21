"""Rebuild notification_icon.png as white glyph on transparent background."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "assets" / "image" / "1000020265.png"
DEST = ROOT / "android" / "app" / "src" / "main" / "res" / "drawable" / "notification_icon.png"


def main() -> None:
    im = Image.open(SRC).convert("RGBA")
    w, h = im.size
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    src = im.load()
    dst = out.load()

    for y in range(h):
        for x in range(w):
            r, g, b, a = src[x, y]
            if a < 20:
                continue
            # Drop near-white paper and cyan brand backgrounds.
            if r > 240 and g > 240 and b > 240:
                continue
            if abs(r - 0) < 50 and abs(g - 212) < 55 and abs(b - 216) < 55:
                continue
            if abs(r - 0) < 40 and abs(g - 180) < 80 and abs(b - 190) < 80 and g > 140:
                continue
            # Keep yellow / dark / colored logo marks as opaque white.
            luminance = (r + g + b) / 3
            # Also keep bright yellow (high r+g)
            is_yellow = r > 180 and g > 150 and b < 120
            is_mark = luminance < 230 or is_yellow
            if is_mark:
                dst[x, y] = (255, 255, 255, 255)

    bbox = out.getbbox()
    if bbox:
        out = out.crop(bbox)
    side = max(out.size)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(out, ((side - out.size[0]) // 2, (side - out.size[1]) // 2), out)
    canvas = canvas.resize((96, 96), Image.Resampling.LANCZOS)
    DEST.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(DEST)
    # Verify transparency exists
    alphas = [px[3] for px in canvas.getdata()]
    print(f"Wrote {DEST} transparent_pixels={sum(1 for a in alphas if a == 0)} opaque={sum(1 for a in alphas if a > 200)}")


if __name__ == "__main__":
    main()
