"""
create_placeholder_assets.py
Run this in the root of your Flutter project:
    python create_placeholder_assets.py

Requires: pip install Pillow

Generates placeholder PNG assets needed by flutter_launcher_icons
and flutter_native_splash before you have final design files.
Replace with your real assets when ready.
"""

import os

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Pillow not found. Installing...")
    os.system("pip install Pillow")
    from PIL import Image, ImageDraw


def hex_to_rgb(hex_color: str):
    h = hex_color.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))


def draw_bolt(draw: ImageDraw.ImageDraw, size: int, color="white"):
    """Draw a lightning bolt centered in a square of `size` px."""
    s = float(size)
    # Bolt polygon (normalized coords * size)
    points = [
        (s * 0.57, s * 0.04),   # top-right
        (s * 0.26, s * 0.54),   # mid-left
        (s * 0.50, s * 0.50),   # mid-center
        (s * 0.43, s * 0.96),   # bottom-left
        (s * 0.74, s * 0.46),   # mid-right
        (s * 0.50, s * 0.50),   # mid-center (back)
    ]
    draw.polygon(points, fill=color)


def make_solid_icon(path: str, size: int, bg: str = "#2563EB"):
    img = Image.new("RGBA", (size, size), (*hex_to_rgb(bg), 255))
    draw = ImageDraw.Draw(img)
    draw_bolt(draw, size, color="white")
    img.save(path)
    print(f"  ✓  {path}  ({size}×{size})")


def make_transparent_icon(path: str, size: int):
    """Foreground layer — bolt on transparent background."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_bolt(draw, size, color="white")
    img.save(path)
    print(f"  ✓  {path}  ({size}×{size})")


def main():
    os.makedirs("assets/images", exist_ok=True)
    print("Creating placeholder assets for Think Fast...\n")

    # 1024×1024 — main icon (solid background)
    make_solid_icon("assets/images/icon.png", 1024, bg="#2563EB")

    # 1024×1024 — adaptive icon foreground (transparent bg)
    make_transparent_icon("assets/images/icon_foreground.png", 1024)

    # 288×288 — splash logo (transparent bg, white bolt)
    make_transparent_icon("assets/images/splash_logo.png", 288)

    print("\n✅  3 asset files created in assets/images/")
    print("   Run these next:")
    print("     dart run flutter_launcher_icons")
    print("     dart run flutter_native_splash:create")


if __name__ == "__main__":
    main()
