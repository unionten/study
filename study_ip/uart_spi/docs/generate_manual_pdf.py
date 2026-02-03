from __future__ import annotations

import pathlib

from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas


def _wrap_lines(text: str, width: int) -> list[str]:
    lines: list[str] = []
    for raw in text.splitlines():
        if not raw:
            lines.append("")
            continue
        s = raw
        while len(s) > width:
            lines.append(s[:width])
            s = s[width:]
        lines.append(s)
    return lines


def main() -> int:
    root = pathlib.Path(__file__).resolve().parent
    md = (root / "manual.md").read_text(encoding="utf-8")
    out = root / "manual.pdf"

    c = canvas.Canvas(str(out), pagesize=A4)
    w, h = A4
    margin = 36
    x = margin
    y = h - margin

    font_name = "Helvetica"
    font_size = 10

    c.setFont(font_name, font_size)
    line_h = font_size * 1.35

    for line in _wrap_lines(md, 95):
        if y < margin + line_h:
            c.showPage()
            c.setFont(font_name, font_size)
            y = h - margin
        c.drawString(x, y, line)
        y -= line_h

    c.save()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

