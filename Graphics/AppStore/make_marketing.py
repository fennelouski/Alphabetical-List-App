#!/usr/bin/env python3
"""Composite raw simulator screenshots into App Store marketing images.

Layouts: single (headline + one framed screenshot), duo/trio fans, and a macOS
window-chrome set built from the iPad/iPhone captures (there is no Mac App Store
listing for an iOS app; these are for web/marketing use).
"""
import math, os
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.abspath(__file__))
RAW_IPHONE = os.path.join(ROOT, "raw", "iphone")
RAW_IPAD = os.path.join(ROOT, "raw", "ipad")
OUT = os.path.join(ROOT, "marketing")

FONT = "/System/Library/Fonts/HelveticaNeue.ttc"
BOLD = 1  # ttc index

# Background gradient pairs (top-left -> bottom-right), pulled from the app's
# note-card palette so the sheets feel on-brand.
GRADS = [
    ((58, 48, 100), (18, 16, 40)),      # indigo night
    ((36, 94, 90), (10, 30, 34)),       # deep teal
    ((122, 76, 40), (40, 20, 12)),      # warm umber
    ((30, 60, 114), (8, 14, 34)),       # classic blue
    ((44, 100, 60), (10, 26, 18)),      # forest
    ((96, 54, 120), (26, 12, 40)),      # plum
    ((198, 168, 120), (232, 220, 200)), # light sand
    ((176, 196, 220), (232, 240, 248)), # light sky
]


def gradient(size, c0, c1):
    w, h = size
    base = Image.new("RGB", (2, 2))
    base.putpixel((0, 0), c0); base.putpixel((1, 0), tuple((a + b) // 2 for a, b in zip(c0, c1)))
    base.putpixel((0, 1), tuple((a + b) // 2 for a, b in zip(c0, c1))); base.putpixel((1, 1), c1)
    return base.resize((w, h), Image.BICUBIC)


def rounded(im, radius):
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, im.size[0] - 1, im.size[1] - 1], radius, fill=255)
    out = im.convert("RGBA")
    out.putalpha(mask)
    return out


def with_shadow(card, blur=40, alpha=140, offset=(0, 24)):
    pad = blur * 3
    w, h = card.size
    layer = Image.new("RGBA", (w + pad * 2, h + pad * 2), (0, 0, 0, 0))
    sh = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle(
        [pad + offset[0], pad + offset[1], pad + w + offset[0], pad + h + offset[1]],
        radius=60, fill=(0, 0, 0, alpha))
    sh = sh.filter(ImageFilter.GaussianBlur(blur))
    layer.alpha_composite(sh)
    layer.alpha_composite(card, (pad, pad))
    return layer


def frame_shot(path, target_h, radius=60, border=6):
    im = Image.open(path).convert("RGB")
    scale = target_h / im.height
    im = im.resize((int(im.width * scale), target_h), Image.LANCZOS)
    card = rounded(im, radius)
    d = ImageDraw.Draw(card)
    d.rounded_rectangle([0, 0, card.width - 1, card.height - 1], radius,
                        outline=(255, 255, 255, 90), width=border)
    return card


def mac_window(path, target_w):
    """Wrap a screenshot in macOS window chrome (title bar + traffic lights)."""
    im = Image.open(path).convert("RGB")
    scale = target_w / im.width
    im = im.resize((target_w, int(im.height * scale)), Image.LANCZOS)
    bar_h = max(52, target_w // 28)
    win = Image.new("RGB", (im.width, im.height + bar_h), (236, 234, 238))
    ImageDraw.Draw(win).rectangle([0, 0, im.width, bar_h], fill=(230, 228, 233))
    win.paste(im, (0, bar_h))
    d = ImageDraw.Draw(win)
    r = bar_h // 4
    for i, col in enumerate([(255, 95, 86), (255, 189, 46), (39, 201, 63)]):
        cx = bar_h // 2 + i * (r * 2 + r)
        d.ellipse([cx - r, bar_h // 2 - r, cx + r, bar_h // 2 + r], fill=col)
    return with_shadow(rounded(win, 24), blur=30, alpha=120, offset=(0, 14))


def fit_text(draw, text, max_w, start_size):
    size = start_size
    while size > 30:
        font = ImageFont.truetype(FONT, size, index=BOLD)
        if draw.textlength(text, font=font) <= max_w:
            return font
        size -= 4
    return ImageFont.truetype(FONT, size, index=BOLD)


def draw_headline(canvas, text, y, light_bg=False):
    d = ImageDraw.Draw(canvas)
    color = (30, 30, 40) if light_bg else (255, 255, 255)
    lines = text.split("\n")
    font = None
    for line in lines:
        f = fit_text(d, line, canvas.width * 0.88, canvas.width // 14)
        font = f if font is None or f.size < font.size else font
    for line in lines:
        w = d.textlength(line, font=font)
        d.text(((canvas.width - w) / 2, y), line, font=font, fill=color)
        y += int(font.size * 1.18)
    return y


def single(bg_pair, headline, shot, out_path, size, light=False):
    canvas = gradient(size, *bg_pair).convert("RGBA")
    y = draw_headline(canvas, headline, int(size[1] * 0.045), light)
    avail = size[1] - y - int(size[1] * 0.05)
    card = with_shadow(frame_shot(shot, avail))
    canvas.alpha_composite(card, ((size[0] - card.width) // 2, y + int(size[1] * 0.02) - 120))
    canvas.convert("RGB").save(out_path, "PNG")


def fan(bg_pair, headline, shots, out_path, size, angles, light=False):
    canvas = gradient(size, *bg_pair).convert("RGBA")
    y = draw_headline(canvas, headline, int(size[1] * 0.045), light)
    n = len(shots)
    shot_h = int(size[1] * (0.52 if n == 2 else 0.44))
    span = size[0] * (0.50 if n == 2 else 0.72)  # distance between outer card centers
    for i, (shot, ang) in enumerate(zip(shots, angles)):
        card = with_shadow(frame_shot(shot, shot_h), blur=36, alpha=120)
        card = card.rotate(ang, expand=True, resample=Image.BICUBIC)
        cx = size[0] // 2 + int((i / (n - 1) - 0.5) * span)
        cy = y + int((size[1] - y) * 0.48)
        canvas.alpha_composite(card, (cx - card.width // 2, cy - card.height // 2))
    canvas.convert("RGB").save(out_path, "PNG")


def mac_sheet(bg_pair, headline, shots, out_path, light=False):
    size = (2880, 1800)
    canvas = gradient(size, *bg_pair).convert("RGBA")
    y = draw_headline(canvas, headline, 90, light)
    if len(shots) == 1:
        win = mac_window(shots[0], 1900)
        canvas.alpha_composite(win, ((size[0] - win.width) // 2, y + 40))
    else:
        widths = [1500, 1100] if len(shots) == 2 else [1300, 950, 950]
        xs = [size[0] // 2 - 1150, size[0] // 2 + 250] if len(shots) == 2 else [140, 1500, 2000]
        ys = [y + 60, y + 260] if len(shots) == 2 else [y + 60, y + 200, y + 420]
        for shot, w, x, yy in zip(shots, widths, xs, ys):
            win = mac_window(shot, w)
            canvas.alpha_composite(win, (x, yy))
    canvas.convert("RGB").save(out_path, "PNG")


def ip(n):  # raw iphone path by prefix number
    for f in sorted(os.listdir(RAW_IPHONE)):
        if f.startswith(f"iphone_{n:02d}"):
            return os.path.join(RAW_IPHONE, f)
    raise KeyError(n)


def pad(n):
    for f in sorted(os.listdir(RAW_IPAD)):
        if f.startswith(f"ipad_{n:02d}"):
            return os.path.join(RAW_IPAD, f)
    raise KeyError(n)


IPHONE = (1320, 2868)
IPAD = (2064, 2752)

# (kind, gradient, headline, shots, angles, light)
IPHONE_PLAN = [
    ("single", 0, "Every note gets\nits own colour", [1], None, False),
    ("single", 3, "Your lists, sorted\nA to Z. Automatically.", [13], None, False),
    ("single", 4, "Groceries to gift ideas,\nrecognisable at a glance", [3], None, False),
    ("single", 1, "Make a list.\nWatch it sort itself.", [9], None, False),
    ("single", 6, "Fast, full-screen\nwriting", [8], None, True),
    ("single", 2, "No folders. No fuss.\nJust lists.", [6], None, False),
    ("single", 5, "Dark mode that keeps\nyour colours readable", [15], None, False),
    ("single", 7, "Start a new list\nin two taps", [11], None, True),
    ("fan", 0, "A place for\nevery list", [2, 3], (6, -6), False),
    ("fan", 3, "Light or dark,\nalways colourful", [1, 13], (5, -5), False),
    ("fan", 1, "From groceries\nto big plans", [9, 5], (7, -7), False),
    ("fan", 6, "Notes that organise\nthemselves", [4, 17], (6, -6), True),
    ("fan", 2, "Write it. Sort it.\nDone.", [8, 12, 2], (8, 0, -8), False),
    ("fan", 4, "Colour-coded,\ncover to cover", [3, 1, 16], (9, 0, -9), False),
    ("fan", 5, "Fun, fast,\ncolourful lists", [14, 13, 5], (8, 0, -8), False),
]

IPAD_PLAN = [
    ("single", 0, "Your list and your note,\nside by side", [1], None, False),
    ("single", 3, "Every note gets its own colour", [2], None, False),
    ("single", 4, "Built for iPad", [3], None, False),
    ("single", 1, "Make a list. Watch it sort itself.", [4], None, False),
    ("single", 6, "Fast, full-screen writing", [5], None, True),
    ("single", 2, "No folders. No fuss. Just lists.", [7], None, False),
    ("single", 5, "Dark mode that keeps\nyour colours readable", [10], None, False),
    ("single", 7, "Start a new list in two taps", [6], None, True),
    ("fan", 0, "A place for every list", [2, 3], (4, -4), False),
    ("fan", 3, "Light or dark, always colourful", [1, 10], (4, -4), False),
    ("fan", 1, "From groceries to big plans", [12, 8], (5, -5), False),
    ("fan", 6, "Notes that organise themselves", [4, 15], (4, -4), True),
    ("fan", 2, "Write it. Sort it. Done.", [5, 9, 11], (6, 0, -6), False),
    ("fan", 4, "Colour-coded, cover to cover", [2, 1, 13], (6, 0, -6), False),
    ("fan", 5, "Fun, fast, colourful lists", [11, 10, 14], (6, 0, -6), False),
]

MAC_PLAN = [
    (0, "Every note gets its own colour", [pad(1)]),
    (3, "Your lists, sorted A to Z", [pad(2)]),
    (4, "Built for your Mac, too", [pad(3)]),
    (1, "Make a list. Watch it sort itself.", [pad(4)]),
    (6, "Fast, full-screen writing", [pad(5)]),
    (2, "No folders. No fuss. Just lists.", [pad(7)]),
    (5, "Dark mode that keeps your colours readable", [pad(10)]),
    (7, "Start a new list in two taps", [pad(6)]),
    (0, "A place for every list", [pad(2), ip(3)]),
    (3, "Light or dark, always colourful", [pad(1), pad(10)]),
    (1, "From groceries to big plans", [pad(12), ip(9)]),
    (6, "Notes that organise themselves", [pad(4), ip(17)]),
    (2, "Write it. Sort it. Done.", [pad(5), ip(8), ip(2)]),
    (4, "Colour-coded, cover to cover", [pad(2), ip(1), ip(16)]),
    (5, "Fun, fast, colourful lists", [pad(11), ip(13), ip(5)]),
]


def run_plan(plan, raw_fn, size, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    for i, (kind, g, headline, shots, angles, light) in enumerate(plan, 1):
        out = os.path.join(out_dir, f"mkt_{i:02d}.png")
        paths = [raw_fn(n) for n in shots]
        if kind == "single":
            single(GRADS[g], headline, paths[0], out, size, light)
        else:
            fan(GRADS[g], headline, paths, out, size, angles, light)
        print("wrote", out)


if __name__ == "__main__":
    run_plan(IPHONE_PLAN, ip, IPHONE, os.path.join(OUT, "iphone"))
    run_plan(IPAD_PLAN, pad, IPAD, os.path.join(OUT, "ipad"))
    mac_out = os.path.join(OUT, "mac")
    os.makedirs(mac_out, exist_ok=True)
    for i, (g, headline, shots) in enumerate(MAC_PLAN, 1):
        out = os.path.join(mac_out, f"mkt_{i:02d}.png")
        light = g in (6, 7)
        mac_sheet(GRADS[g], headline, shots, out, light)
        print("wrote", out)
