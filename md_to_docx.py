"""Convert TrachCare_Report.md to a formatted .docx (headings, tables, lists)."""
import re
from docx import Document
from docx.shared import Pt, Inches, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

SRC = r"C:\Users\sudha\trachcare\TrachCare_Report.md"
OUT = r"C:\Users\sudha\trachcare\TrachCare_Report.docx"

doc = Document()

# ── Page + base style ──────────────────────────────────────
for sec in doc.sections:
    sec.left_margin = Inches(0.9)
    sec.right_margin = Inches(0.9)
    sec.top_margin = Inches(0.9)
    sec.bottom_margin = Inches(0.9)

style = doc.styles['Normal']
style.font.name = 'Calibri'
style.font.size = Pt(11)

TEAL = RGBColor(0x0B, 0x4F, 0x4A)

def set_heading(p, size, color=TEAL, bold=True):
    for r in p.runs:
        r.font.size = Pt(size)
        r.font.bold = bold
        r.font.color.rgb = color
    p.paragraph_format.space_before = Pt(14 if size < 18 else 20)
    p.paragraph_format.space_after = Pt(6)

def md_strip(t):
    t = re.sub(r'\*\*(.+?)\*\*', r'\1', t)
    t = re.sub(r'\*(.+?)\*', r'\1', t)
    t = re.sub(r'`([^`]+)`', r'\1', t)
    return t.strip()

def add_table(rows):
    header, body = rows[0], rows[2:]
    ncol = len(header)
    tbl = doc.add_table(rows=1 + len(body), cols=ncol)
    tbl.style = 'Table Grid'
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    for j, cell in enumerate(header):
        c = tbl.rows[0].cells[j]
        c.text = md_strip(cell)
        for p in c.paragraphs:
            for r in p.runs:
                r.font.bold = True
                r.font.size = Pt(10)
        shd = __import__('docx.oxml', fromlist=['OxmlElement'])
        from docx.oxml.ns import qn
        tcPr = c._tc.get_or_add_tcPr()
        sh = shd.OxmlElement('w:shd')
        sh.set(qn('w:fill'), 'D9EDE9')
        tcPr.append(sh)
    for i, row in enumerate(body):
        for j in range(ncol):
            c = tbl.rows[i + 1].cells[j]
            c.text = md_strip(row[j]) if j < len(row) else ''
            for p in c.paragraphs:
                for r in p.runs:
                    r.font.size = Pt(9.5)
    doc.add_paragraph()

def is_table_line(t):
    return t.strip().startswith('|') and t.strip().endswith('|')

def parse_table_line(t):
    return [c.strip() for c in t.strip().strip('|').split('|')]

with open(SRC, encoding='utf-8') as f:
    lines = f.read().split('\n')

i = 0
in_code = False
while i < len(lines):
    raw = lines[i]
    t = raw.rstrip()

    if t.strip().startswith('```'):
        in_code = not in_code
        i += 1
        continue
    if in_code:
        p = doc.add_paragraph()
        r = p.add_run(t)
        r.font.name = 'Consolas'
        r.font.size = Pt(9)
        i += 1
        continue

    if not t.strip():
        i += 1
        continue

    if t.strip() == '---':
        doc.add_paragraph('_' * 70)
        i += 1
        continue

    # table block
    if is_table_line(t):
        tbl_lines = []
        while i < len(lines) and is_table_line(lines[i]):
            tbl_lines.append(parse_table_line(lines[i]))
            i += 1
        if len(tbl_lines) >= 2 and set(tbl_lines[1][0]) <= set('-: '):
            add_table(tbl_lines)
        continue

    # headings
    m = re.match(r'^(#{1,4})\s+(.*)', t)
    if m:
        level, text = len(m.group(1)), m.group(2)
        p = doc.add_paragraph()
        p.add_run(md_strip(text))
        sizes = {1: 22, 2: 16, 3: 13, 4: 12}
        set_heading(p, sizes.get(level, 12))
        if level == 1:
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        i += 1
        continue

    # numbered/bullet lists
    m = re.match(r'^(\d+\.|[-*])\s+(.*)', t)
    if m:
        p = doc.add_paragraph(style='List Bullet' if m.group(1) != '.' else 'List Number')
        p.add_run(md_strip(m.group(2)))
        i += 1
        continue

    # image placeholders
    if t.startswith('[IMAGE'):
        p = doc.add_paragraph()
        r = p.add_run(md_strip(t))
        r.font.italic = True
        r.font.color.rgb = RGBColor(0x88, 0x88, 0x88)
        i += 1
        continue

    # figure captions / italic paragraphs
    if t.startswith('*') and t.endswith('*') and len(t) > 2:
        p = doc.add_paragraph()
        r = p.add_run(md_strip(t))
        r.font.italic = True
        r.font.size = Pt(10)
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        i += 1
        continue

    # normal paragraph
    p = doc.add_paragraph()
    # render **bold** segments
    parts = re.split(r'(\*\*.+?\*\*)', t)
    for part in parts:
        if part.startswith('**') and part.endswith('**'):
            r = p.add_run(part[2:-2])
            r.bold = True
        else:
            p.add_run(md_strip(part))
    i += 1

doc.save(OUT)
print(f"Saved {OUT}")
