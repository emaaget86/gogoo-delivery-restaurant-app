"""Generate Android mipmap launcher icons from 1000020061.png without flutter_launcher_icons."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "assets" / "image" / "1000020061.png"
RES = ROOT / "android" / "app" / "src" / "main" / "res"
BG = (0, 212, 216, 255)  # #00D4D8

SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

FOREGROUND_SIZES = {
    "drawable-mdpi": 108,
    "drawable-hdpi": 162,
    "drawable-xhdpi": 216,
    "drawable-xxhdpi": 324,
    "drawable-xxxhdpi": 432,
}


def make_square(im: Image.Image, size: int) -> Image.Image:
    im = im.convert("RGBA")
    # Fit inside size with contain, then pad on brand cyan.
    im.thumbnail((size, size), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (size, size), BG)
    x = (size - im.width) // 2
    y = (size - im.height) // 2
    canvas.paste(im, (x, y), im)
    return canvas


def main() -> None:
    src = Image.open(SRC).convert("RGBA")
    for folder, size in SIZES.items():
        out_dir = RES / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        icon = make_square(src, size)
        icon.save(out_dir / "ic_launcher.png")
        print(f"Wrote {folder}/ic_launcher.png ({size}x{size})")

    # Adaptive foreground (safe zone inset handled in mipmap-anydpi xml).
    for folder, size in FOREGROUND_SIZES.items():
        out_dir = RES / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        fg = make_square(src, size)
        fg.save(out_dir / "ic_launcher_foreground.png")
        print(f"Wrote {folder}/ic_launcher_foreground.png ({size}x{size})")

    # Base drawable foreground used by adaptive icon xml.
    drawable = RES / "drawable"
    drawable.mkdir(parents=True, exist_ok=True)
    make_square(src, 432).save(drawable / "ic_launcher_foreground.png")
    print("Wrote drawable/ic_launcher_foreground.png")
    print("Launcher icons generated.")


if __name__ == "__main__":
    main()
