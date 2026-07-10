#!/usr/bin/env python3
"""Generate the DMG window background (Scripts/dmg-assets/), matching
Flang's design system (Flang/UI/DesignSystem.swift, dark "hero" palette —
same one FirstLaunchWindow.swift uses) rather than dmgbuild's generic
built-in arrow.

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

# Colors — DesignSystem.swift FlangColor, dark theme (hero* roles).
BG = (40, 40, 40)  # heroCardBackground dark: rgb(0.157,0.157,0.157)
TITLE = (235, 235, 235)  # heroTitleText dark: white 0.92
SUBTITLE = (150, 150, 150)  # heroSubtitleText dark: white 0.5
ACCENT = (10, 132, 255)  # accent dark: 0.039/0.518/1.0
CAPTION = (110, 110, 110)  # heroCaptionText dark: white 0.3

FONT_PATH = "/System/Library/Fonts/SFNS.ttf"

# Must match icon_locations / window_rect in make-dmg.sh.
WINDOW_SIZE = (540, 380)
ICON_SIZE = 128
FLANG_ICON_CENTER = (140, 170)
APPLICATIONS_ICON_CENTER = (400, 170)


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

    center_text("Flang", 28, font(30, weight=700), TITLE)
    center_text("Drag to Applications to install", 68, font(13), SUBTITLE)

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

    center_text("flang · flags for your keyboard", 348, font(11), CAPTION)

    img.save(out_path)
    print(f"wrote {out_path} ({w}x{h})")


if __name__ == "__main__":
    OUT_DIR.mkdir(exist_ok=True)
    render(1, OUT_DIR / "background.png")
    render(2, OUT_DIR / "background@2x.png")
