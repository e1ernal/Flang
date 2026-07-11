#!/usr/bin/env python3
"""Generate the DMG window background (Scripts/dmg-assets/) — a light
background (matching FlangColor's light windowBackground) so Finder's own
black icon-name labels stay readable, with the install instruction in the
system font instead of dmgbuild's generic built-in arrow.

Regenerate after changing the DMG layout in make-dmg.sh (icon_locations,
window_rect) — the arrow position here is derived from those same numbers
and won't stay aligned automatically.

Requires: Pillow (pip3 install --user Pillow).

Usage:
    python3 Scripts/make-dmg-background.py
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT_DIR = Path(__file__).parent / "dmg-assets"

# Colors — DesignSystem.swift FlangColor, light theme.
BG = (245, 243, 240)  # windowBackground light: rgb(0.961,0.953,0.941)
SUBTITLE = (100, 100, 100)
ACCENT = (10, 132, 255)  # accent dark: 0.039/0.518/1.0 — reads fine on light too
CAPTION = (140, 140, 140)

FONT_PATH = "/System/Library/Fonts/SFNS.ttf"

# Must match icon_locations / window_rect in make-dmg.sh.
WINDOW_SIZE = (560, 480)
ICON_SIZE = 128
FLANG_ICON_CENTER = (150, 220)
APPLICATIONS_ICON_CENTER = (410, 220)


def render(scale: int, out_path: Path) -> None:
    w, h = WINDOW_SIZE[0] * scale, WINDOW_SIZE[1] * scale
    img = Image.new("RGB", (w, h), BG)
    draw = ImageDraw.Draw(img)

    def font(size: int, weight: int | None = None) -> ImageFont.FreeTypeFont:
        f = ImageFont.truetype(FONT_PATH, size * scale)
        if weight is not None:
            try:
                f.set_variation_by_axes([weight])
            except Exception:
                pass
        return f

    def center_text(text: str, y: int, fnt: ImageFont.FreeTypeFont, color) -> None:
        bbox = draw.textbbox((0, 0), text, font=fnt)
        text_w = bbox[2] - bbox[0]
        draw.text(((w - text_w) / 2, y * scale), text, font=fnt, fill=color)

    center_text("Drag to Applications to install", 64, font(13), SUBTITLE)

    # icon_locations give each icon's CENTER point, not top-left.
    icon_half = ICON_SIZE / 2
    margin = 14
    x0 = (FLANG_ICON_CENTER[0] + icon_half + margin) * scale
    x1 = (APPLICATIONS_ICON_CENTER[0] - icon_half - margin) * scale
    arrow_y = FLANG_ICON_CENTER[1] * scale
    shaft_width = 3 * scale
    head_w, head_h = 16 * scale, 12 * scale

    shaft_end = x1 - head_w
    draw.line([(x0, arrow_y), (shaft_end, arrow_y)], fill=ACCENT, width=shaft_width)
    draw.polygon(
        [
            (shaft_end, arrow_y - head_h),
            (x1, arrow_y),
            (shaft_end, arrow_y + head_h),
        ],
        fill=ACCENT,
    )

    center_text("flang · flags for your keyboard", 420, font(11), CAPTION)

    img.save(out_path)
    print(f"wrote {out_path} ({w}x{h})")


if __name__ == "__main__":
    OUT_DIR.mkdir(exist_ok=True)
    render(1, OUT_DIR / "background.png")
    render(2, OUT_DIR / "background@2x.png")
