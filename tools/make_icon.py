from PIL import Image, ImageDraw, ImageFont
import os

BASE = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BG = "#141414"
FG = "#FFFFFF"

def rounded_rect(draw, xy, radius, fill):
    x0, y0, x1, y1 = xy
    draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill)

def make_icon(size, text="LX"):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    radius = int(size * 0.18)
    rounded_rect(draw, (0, 0, size, size), radius, BG)

    font_size = int(size * 0.54)
    font_path = r"C:\Windows\Fonts\arialbd.ttf"
    try:
        font = ImageFont.truetype(font_path, font_size)
    except Exception:
        font = ImageFont.load_default()

    draw.text((size / 2, size / 2), text, font=font, fill=FG, anchor="mm")
    return img


sizes = [16, 32, 48, 64, 128, 256, 512]
icons = [make_icon(s) for s in sizes]

out_png = os.path.join(BASE, "assets", "icons", "localx.png")
icons[-1].save(out_png, "PNG")

out_ico = os.path.join(BASE, "assets", "icons", "localx.ico")
icons[0].save(out_ico, format="ICO", sizes=[(s, s) for s in sizes[:-1]])

out_ico2 = os.path.join(BASE, "windows", "runner", "resources", "app_icon.ico")
icons[0].save(out_ico2, format="ICO", sizes=[(s, s) for s in sizes[:-1]])

print("icons ok")
