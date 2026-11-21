"""Prepare launcher, splash, and notification icons from brand source PNGs."""
from __future__ import annotations

import os
import shutil
from pathlib import Path

try:
    from PIL import Image, ImageOps
except ImportError as exc:
    raise SystemExit("Pillow is required: pip install Pillow") from exc

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "assets" / "image"
ANDROID_RES = ROOT / "android" / "app" / "src" / "main" / "res"

SRC_ICON = ASSETS / "1000020061.png"
SRC_SPLASH = ASSETS / "1000020063.png"
SRC_NOTIF = ASSETS / "1000020265.png"


def ensure_sources() -> None:
    downloads = Path.home() / "Downloads"
    mapping = {
        SRC_ICON: downloads / "1000020061.png",
        SRC_SPLASH: downloads / "splash neww.png",
        SRC_NOTIF: downloads / "notification icon.png",
    }
    for dest, src in mapping.items():
        if not dest.exists():
            if not src.exists():
                raise SystemExit(f"Missing source: {src}")
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dest)
            print(f"Copied {src.name} -> {dest}")
        else:
            print(f"OK {dest.name}")


def make_white_silhouette(src: Path, dest: Path, size: int = 96) -> None:
    """Android status-bar icons must be white alpha; color assets render as blank disks."""
    im = Image.open(src).convert("RGBA")
    # Crop near-empty margins so the glyph fills the canvas.
    bbox = im.getbbox()
    if bbox:
        im = im.crop(bbox)

    # Build alpha from luminance of non-near-white pixels (works for cyan/yellow logos).
    r, g, b, a = im.split()
    gray = ImageOps.grayscale(Image.merge("RGB", (r, g, b)))
    # Invert so dark/colored marks become opaque white.
    # Treat near-white / near-cyan backgrounds as transparent.
    pixels = []
    for gy, ay in zip(gray.getdata(), a.getdata()):
        if ay < 16:
            pixels.append(0)
            continue
        # High luminance + low saturation-ish -> background
        # Keep mid/low luminance and saturated yellow marks opaque.
        alpha = 255 - gy if gy < 245 else 0
        # Boost saturated bright yellows (high R+G, lower B)
        pixels.append(max(0, min(255, alpha if alpha > 0 else 0)))

    # Better pass: use any non-background colored pixel as opaque.
    datas = list(im.getdata())
    out_pixels = []
    for (rr, gg, bb, aa) in datas:
        if aa < 16:
            out_pixels.append((255, 255, 255, 0))
            continue
        # Background cyan ~ (0, 212, 216) and near-white
        is_cyan = abs(rr - 0) < 40 and abs(gg - 212) < 45 and abs(bb - 216) < 45
        is_white = rr > 245 and gg > 245 and bb > 245
        if is_cyan or is_white:
            out_pixels.append((255, 255, 255, 0))
        else:
            out_pixels.append((255, 255, 255, 255))

    out = Image.new("RGBA", im.size)
    out.putdata(out_pixels)
    bbox = out.getbbox()
    if bbox:
        out = out.crop(bbox)
    # Pad to square
    w, h = out.size
    side = max(w, h)
    canvas = Image.new("RGBA", (side, side), (255, 255, 255, 0))
    canvas.paste(out, ((side - w) // 2, (side - h) // 2), out)
    canvas = canvas.resize((size, size), Image.Resampling.LANCZOS)
    dest.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(dest)
    print(f"Wrote notification silhouette {dest}")


def copy_splash_drawables() -> None:
    # Full-bleed-friendly centered brand for pre-Flutter splash.
    nodpi = ANDROID_RES / "drawable-nodpi"
    nodpi.mkdir(parents=True, exist_ok=True)
    splash_brand = nodpi / "splash_brand.png"
    splash_icon = nodpi / "splash_icon.png"

    splash = Image.open(SRC_SPLASH).convert("RGBA")
    # Prefer contain without clipping: keep full image for splash_brand.
    splash.save(splash_brand)
    # Android 12+ splash icon should be a smaller centered mark.
    icon = Image.open(SRC_ICON).convert("RGBA")
    icon_side = 288
    icon = icon.resize((icon_side, icon_side), Image.Resampling.LANCZOS)
    icon.save(splash_icon)

    # Keep drawable/splash.png in sync for any legacy refs.
    drawable = ANDROID_RES / "drawable"
    drawable.mkdir(parents=True, exist_ok=True)
    splash.save(drawable / "splash.png")
    print("Updated Android splash drawables")


def main() -> None:
    ensure_sources()
    # Keep Flutter asset aliases current.
    shutil.copy2(SRC_ICON, ASSETS / "logo.png")
    shutil.copy2(SRC_ICON, ASSETS / "gogo_partner_icon.png")
    shutil.copy2(SRC_ICON, ASSETS / "gogo_mark.png")
    shutil.copy2(SRC_SPLASH, ASSETS / "splash.png")

    notif_drawable = ANDROID_RES / "drawable" / "notification_icon.png"
    make_white_silhouette(SRC_NOTIF, notif_drawable, size=96)
    # Also keep a full-color asset copy for in-app image uses if needed.
    shutil.copy2(SRC_NOTIF, ASSETS / "notification_brand_icon.png")

    copy_splash_drawables()
    print("Brand asset preparation complete.")


if __name__ == "__main__":
    main()
