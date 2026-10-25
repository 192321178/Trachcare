#!/usr/bin/env python3
"""Build TrachCare_App_Presentation.pptx - a 21-slide project deck in the same
structure as the reference presentation (title, problem, planner, competitive
analysis, personas, empathy map, pain points, journey map, wireframes, lo/hi-fi
UI, dev stack, design iterations, architecture, accessibility, takeaways,
next steps, connect)."""
import os
import qrcode
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

FIGS = os.path.join(os.path.dirname(__file__), 'figs')
OUT = os.path.join(os.path.dirname(__file__), 'TrachCare_App_Presentation.pptx')
QR_PATH = os.path.join(FIGS, 'qr_linkedin_santhosh.png')

LINKEDIN = ('https://www.linkedin.com/in/santhosh-l-53093b376'
            '?utm_source=share_via&utm_content=profile&utm_medium=member_android')
NAME = 'Santhosh L'
REGNO = '192321178'
EMAIL = 'santhoshl1178.sse@saveetha.com'
FOOTER = 'TrachCare | Virtusa Project'

TEAL = RGBColor(0x0F, 0x76, 0x6E)
TEAL_DK = RGBColor(0x11, 0x5E, 0x59)
TEAL_LT = RGBColor(0xCC, 0xFB, 0xF1)
MINT = RGBColor(0xEC, 0xFD, 0xF5)
INK = RGBColor(0x0F, 0x17, 0x2A)
MUTED = RGBColor(0x47, 0x55, 0x69)
LINE = RGBColor(0xCB, 0xD5, 0xE1)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)
AMBER = RGBColor(0xB4, 0x5E, 0x09)

# ── QR code ──
qr = qrcode.QRCode(border=2, box_size=12)
qr.add_data(LINKEDIN)
qr.make(fit=True)
qr.make_image(fill_color='black', back_color='white').save(QR_PATH)

prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)
BLANK = prs.slide_layouts[6]
SW, SH = 13.333, 7.5

slide = None


def new_slide():
    global slide
    slide = prs.slides.add_slide(BLANK)
    return slide


def rect(x, y, w, h, fill=WHITE, line=LINE, radius=True, line_w=1.0, adj=0.08):
    shp = slide.shapes.add_shape(
        MSO_SHAPE.ROUNDED_RECTANGLE if radius else MSO_SHAPE.RECTANGLE,
        Inches(x), Inches(y), Inches(w), Inches(h))
    if radius:
        try:
            shp.adjustments[0] = adj
        except Exception:
            pass
    if fill is None:
        shp.fill.background()
    else:
        shp.fill.solid()
        shp.fill.fore_color.rgb = fill
    if line is None:
        shp.line.fill.background()
    else:
        shp.line.color.rgb = line
        shp.line.width = Pt(line_w)
    shp.shadow.inherit = False
    return shp


def text(x, y, w, h, runs, size=13, color=INK, bold=False, align=PP_ALIGN.LEFT,
         anchor=MSO_ANCHOR.TOP, leading=1.15):
    tb = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = tb.text_frame
    tf.word_wrap = True
    tf.vertical_anchor = anchor
    tf.margin_left = tf.margin_right = Emu(0)
    tf.margin_top = tf.margin_bottom = Emu(0)
    if isinstance(runs, str):
        runs = [runs]
    first = True
    for para in runs:
        p = tf.paragraphs[0] if first else tf.add_paragraph()
        first = False
        p.alignment = align
        p.line_spacing = leading
        if isinstance(para, str):
            para = [(para, bold, color, size)]
        for t, b, c, s in para:
            r = p.add_run()
            r.text = t
            r.font.size = Pt(s)
            r.font.bold = b
            r.font.color.rgb = c
            r.font.name = 'Segoe UI'
    return tb


def header(title, num=None):
    """Standard slide header + footer."""
    bar = rect(0, 0, SW, 0.9, fill=TEAL_DK, line=None, radius=False)
    text(0.5, 0.22, 10.5, 0.5, title, size=26, color=WHITE, bold=True)
    if num:
        text(12.2, 0.25, 0.9, 0.45, str(num), size=20, color=TEAL_LT,
             bold=True, align=PP_ALIGN.RIGHT)
    ln = rect(0, 0.9, SW, 0.05, fill=TEAL, line=None, radius=False)
    text(0.5, 7.12, 6, 0.3, FOOTER, size=9, color=MUTED)


def pic(path, x, y, h=None, w=None, from_figs=True):
    kw = {}
    if h:
        kw['height'] = Inches(h)
    if w:
        kw['width'] = Inches(w)
    p = os.path.join(FIGS, path) if from_figs else path
    return slide.shapes.add_picture(p, Inches(x), Inches(y), **kw)


def card(x, y, w, h, title, body, title_color=TEAL_DK, fill=WHITE):
    rect(x, y, w, h, fill=fill)
    text(x + 0.2, y + 0.12, w - 0.4, 0.35, title, size=15, color=title_color,
         bold=True)
    text(x + 0.2, y + 0.5, w - 0.4, h - 0.6, body, size=12, color=INK,
         leading=1.18)


def bullets(x, y, w, h, items, size=13, gap_color=TEAL, leading=1.2):
    paras = []
    for it in items:
        if isinstance(it, str):
            paras.append([('\u2022 ', True, gap_color, size), (it, False, INK, size)])
        else:
            paras.append([('\u2022 ', True, gap_color, size)] + it)
    text(x, y, w, h, paras, leading=leading)


# ═══════════ SLIDE 1 — TITLE ═══════════
new_slide()
rect(0, 0, SW, SH, fill=MINT, line=None, radius=False)
rect(0, 0, SW, 2.9, fill=TEAL_DK, line=None, radius=False)
logo = slide.shapes.add_shape(MSO_SHAPE.OVAL, Inches(0.6), Inches(0.55),
                              Inches(0.75), Inches(0.75))
logo.fill.solid(); logo.fill.fore_color.rgb = TEAL
logo.line.color.rgb = TEAL_LT; logo.line.width = Pt(2); logo.shadow.inherit = False
tf = logo.text_frame; tf.text = 'T'
tf.paragraphs[0].alignment = PP_ALIGN.CENTER
r = tf.paragraphs[0].runs[0]
r.font.size = Pt(30); r.font.bold = True; r.font.color.rgb = WHITE
r.font.name = 'Segoe UI'
text(1.55, 0.5, 10.8, 0.75, 'TrachCare — Tracheostomy Home Care App',
     size=34, color=WHITE, bold=True)
text(1.55, 1.3, 9.6, 1.3,
     'A Flutter mobile application that guides discharged tracheostomy '
     'patients through daily care — structured vitals reports, a timed '
     'spigotting schedule, therapy videos and a doctor review console.',
     size=16, color=TEAL_LT, leading=1.25)
# student photo
pic('student_photo.png', 11.35, 0.35, h=2.3)
rect(11.33, 0.33, 1.62, 2.34, fill=None, line=WHITE, line_w=2, radius=False)
# details card
rect(0.6, 3.4, 7.2, 3.3, fill=WHITE)
text(0.85, 3.6, 6.8, 0.4, 'Presented by', size=13, color=MUTED, bold=True)
text(0.85, 3.95, 6.8, 0.55, NAME, size=28, color=TEAL_DK, bold=True)
text(0.85, 4.6, 6.8, 0.4, f'Reg. No.  {REGNO}', size=16, color=INK)
text(0.85, 5.05, 6.8, 0.4, EMAIL, size=14, color=MUTED)
text(0.85, 5.6, 6.8, 0.35,
     [[('Department:  ', True, INK, 14), ('BTech IT', False, INK, 14)]])
text(0.85, 6.0, 6.8, 0.35,
     [[('Timeline:  ', True, INK, 14), ('03 Months — 25th Oct 2026',
       False, INK, 14)]])
# QR card
rect(8.2, 3.4, 4.55, 3.3, fill=WHITE)
text(8.45, 3.6, 4.0, 0.35, 'Scan to connect', size=13, color=MUTED, bold=True)
rect(8.55, 4.0, 1.9, 1.9, fill=WHITE, line=LINE)
pic('qr_linkedin_santhosh.png', 8.6, 4.05, h=1.8)
text(10.6, 4.05, 2.0, 2.1, [
    [('LinkedIn', True, TEAL_DK, 15)],
    [('Scan the QR code to view my profile', False, MUTED, 11)],
], leading=1.2)
text(8.45, 6.1, 4.0, 0.4, 'Patient · Doctor · Admin — one platform',
     size=11.5, color=TEAL_DK, bold=True)

# ═══════════ SLIDE 2 — PROBLEM STATEMENT ═══════════
new_slide()
header('Problem Statement', 2)
rect(0.6, 1.5, 12.1, 2.4, fill=MINT)
text(1.0, 1.85, 11.3, 1.8, [
    [('Ravi, a post-operative tracheostomy patient recovering at home, ',
      False, INK, 20),
     ('needs a structured way to record daily tube care, vitals and '
      'spigotting progress ', True, TEAL_DK, 20),
     ('because today his follow-up depends on phone calls and memory — and '
      'his doctor cannot see deterioration between visits.', False, INK, 20)],
], leading=1.35, anchor=MSO_ANCHOR.MIDDLE)
bullets(0.9, 4.4, 11.6, 2.3, [
    'Daily care reported informally over calls or chat — clinical detail is lost.',
    'No day-by-day record: missed dressing changes or failed spigotting attempts surface only at the next visit.',
    'Doctors cannot track weaning progress remotely; patients have no guided routine at home.',
], size=14, leading=1.5)

# ═══════════ SLIDE 3 — PROJECT PLANNER ═══════════
new_slide()
header('Project Planner', 3)
months = ['September', 'October', 'November', 'December', 'January']
stages = [('Concept dev', 0, 1), ('Research', 0, 1), ('Frontend dev', 1, 2),
          ('Backend dev', 2, 3), ('Database', 2, 3), ('Redesign', 3, 4),
          ('Launch', 4, 5)]
gx, gy, cw, rh = 2.6, 1.6, 1.9, 0.62
for i, m in enumerate(months):
    text(gx + i * cw, gy, cw, 0.35, m, size=13, color=TEAL_DK, bold=True,
         align=PP_ALIGN.CENTER)
for j, (name, s, e) in enumerate(stages):
    y = gy + 0.55 + j * rh
    text(0.6, y + 0.08, 1.95, 0.4, name, size=13, color=INK, bold=True,
         align=PP_ALIGN.RIGHT)
    for i in range(5):
        rect(gx + i * cw, y, cw - 0.08, rh - 0.16, fill=WHITE, line=LINE,
             radius=False)
    rect(gx + s * cw, y, (e - s) * cw - 0.08, rh - 0.16, fill=TEAL,
         line=None)
text(0.6, 6.5, 12, 0.4,
     '15-week plan: analysis → design → Flutter build → PHP/MySQL backend → '
     'hardening → demo', size=12, color=MUTED, align=PP_ALIGN.CENTER)

# ═══════════ SLIDE 4 — COMPETITIVE ANALYSIS ═══════════
new_slide()
header('Competitive Analysis', 4)
rows = [
    ('Criteria', 'TrachCare', 'Generic telehealth', 'WhatsApp / phone', 'Physical review'),
    ('Tracheostomy-specific care', '\u2713', '\u2014', '\u2014', 'Partial'),
    ('Structured daily vitals form', '\u2713', '\u2014', '\u2014', 'At visit only'),
    ('Spigotting session schedule', '\u2713', '\u2014', '\u2014', '\u2014'),
    ('Guided exercise videos', '\u2713', 'Rarely', 'Ad hoc links', 'Verbal'),
    ('Calendar of daily reports', '\u2713', 'Partial', '\u2014', '\u2014'),
    ('PDF export of patient record', '\u2713', 'Partial', '\u2014', 'File copies'),
]
tx, ty, tw, th = 0.6, 1.35, 12.1, 3.1
colw = [4.3, 1.95, 1.95, 1.95, 1.95]
nr, nc = len(rows), 5
tbl = slide.shapes.add_table(nr, nc, Inches(tx), Inches(ty),
                             Inches(tw), Inches(th)).table
for i, wd in enumerate(colw):
    tbl.columns[i].width = Inches(wd)
for ri, row in enumerate(rows):
    for ci, val in enumerate(row):
        cell = tbl.cell(ri, ci)
        cell.text = val
        p = cell.text_frame.paragraphs[0]
        p.alignment = PP_ALIGN.CENTER if ci else PP_ALIGN.LEFT
        r = p.runs[0]
        r.font.size = Pt(12); r.font.name = 'Segoe UI'
        r.font.bold = (ri == 0 or ci == 0)
        r.font.color.rgb = WHITE if ri == 0 else INK
        cell.fill.solid()
        cell.fill.fore_color.rgb = TEAL_DK if ri == 0 else (
            MINT if ci == 1 else WHITE)
card(0.6, 4.75, 5.9, 2.05, 'Gap Analysis', [
    [('\u2022 ', True, TEAL, 12), ('No structured daily record of home care', False, INK, 12)],
    [('\u2022 ', True, TEAL, 12), ('Spigotting / weaning progress untracked', False, INK, 12)],
    [('\u2022 ', True, TEAL, 12), ('No shared record between patient, doctor and admin', False, INK, 12)],
    [('\u2022 ', True, TEAL, 12), ('No audit trail of reported care', False, INK, 12)],
])
card(6.85, 4.75, 5.85, 2.05, 'Our Uniqueness', [
    [('\u2022 ', True, TEAL, 12), ('Complete tracheostomy home-care tracking in one app', False, INK, 12)],
    [('\u2022 ', True, TEAL, 12), ('Role-based access for Patient, Doctor and Admin', False, INK, 12)],
    [('\u2022 ', True, TEAL, 12), ('Daily reports, timed spigotting, videos and PDF export', False, INK, 12)],
])

# ═══════════ SLIDE 5 — PERSONA 1 (PATIENT) ═══════════
new_slide()
header('User Persona : Ravi (Patient)', 5)
text(0.6, 1.15, 12, 0.5,
     '\u201cI want my daily tube care recorded properly without a hospital '
     'visit every week.\u201d', size=16, color=TEAL_DK, bold=True)
face = slide.shapes.add_shape(MSO_SHAPE.OVAL, Inches(0.7), Inches(1.9),
                              Inches(1.0), Inches(1.0))
face.fill.solid(); face.fill.fore_color.rgb = TEAL
face.line.fill.background(); face.shadow.inherit = False
tf = face.text_frame; tf.text = 'R'
tf.paragraphs[0].alignment = PP_ALIGN.CENTER
r = tf.paragraphs[0].runs[0]
r.font.size = Pt(34); r.font.bold = True; r.font.color.rgb = WHITE
info = [('AGE', '58'), ('OCCUPATION', 'Retired clerk'),
        ('STATUS', 'Married'), ('LOCATION', 'Chennai, India')]
for i, (k, v) in enumerate(info):
    y = 3.1 + i * 0.75
    text(0.7, y, 2.2, 0.3, k, size=11, color=MUTED, bold=True)
    text(0.7, y + 0.28, 2.2, 0.35, v, size=14, color=INK)
card(3.2, 1.9, 4.7, 4.6, 'Goals & Needs', [
    [('\u2022 ', True, TEAL, 12.5), ('Follow daily tracheostomy care steps correctly', False, INK, 12.5)],
    [('\u2022 ', True, TEAL, 12.5), ('Record vitals and tube-care tasks without paperwork', False, INK, 12.5)],
    [('\u2022 ', True, TEAL, 12.5), ('Track spigotting (weaning) progress day by day', False, INK, 12.5)],
    [('\u2022 ', True, TEAL, 12.5), ('Learn correct care from guided exercise videos', False, INK, 12.5)],
    [('\u2022 ', True, TEAL, 12.5), ('Stay connected to the treating doctor between visits', False, INK, 12.5)],
])
card(8.2, 1.9, 4.5, 4.6, 'Frustrations', [
    [('\u2022 ', True, AMBER, 12.5), ('Unsure which readings matter and how often to record', False, INK, 12.5)],
    [('\u2022 ', True, AMBER, 12.5), ('Forgets care steps and session timings', False, INK, 12.5)],
    [('\u2022 ', True, AMBER, 12.5), ('Cannot reach the doctor quickly when worried', False, INK, 12.5)],
    [('\u2022 ', True, AMBER, 12.5), ('No feedback on whether readings are normal', False, INK, 12.5)],
    [('\u2022 ', True, AMBER, 12.5), ('Paper diary entries are lost or incomplete', False, INK, 12.5)],
])

# ═══════════ SLIDE 6 — PERSONA 2 (DOCTOR) ═══════════
new_slide()
header('User Persona : Dr. Meera (Doctor)', 6)
text(0.6, 1.15, 12, 0.5,
     '\u201cI need to see each patient\u2019s daily progress at a glance, not '
     'reconstruct it from phone calls.\u201d', size=16, color=TEAL_DK,
     bold=True)
face = slide.shapes.add_shape(MSO_SHAPE.OVAL, Inches(0.7), Inches(1.9),
                              Inches(1.0), Inches(1.0))
face.fill.solid(); face.fill.fore_color.rgb = TEAL_DK
face.line.fill.background(); face.shadow.inherit = False
tf = face.text_frame; tf.text = 'M'
tf.paragraphs[0].alignment = PP_ALIGN.CENTER
r = tf.paragraphs[0].runs[0]
r.font.size = Pt(34); r.font.bold = True; r.font.color.rgb = WHITE
info = [('AGE', '41'), ('OCCUPATION', 'ENT surgeon'),
        ('STATUS', 'Married'), ('LOCATION', 'Chennai, India')]
for i, (k, v) in enumerate(info):
    y = 3.1 + i * 0.75
    text(0.7, y, 2.2, 0.3, k, size=11, color=MUTED, bold=True)
    text(0.7, y + 0.28, 2.2, 0.35, v, size=14, color=INK)
card(3.2, 1.9, 4.7, 4.6, 'Goals & Needs', [
    [('\u2022 ', True, TEAL, 12.5), ('Register discharged patients with full clinical baseline', False, INK, 12.5)],
    [('\u2022 ', True, TEAL, 12.5), ('Review each patient\u2019s daily report by date on a calendar', False, INK, 12.5)],
    [('\u2022 ', True, TEAL, 12.5), ('See who submitted today\u2019s update at a glance', False, INK, 12.5)],
    [('\u2022 ', True, TEAL, 12.5), ('Track spigotting session completion remotely', False, INK, 12.5)],
    [('\u2022 ', True, TEAL, 12.5), ('Export a complete patient record as PDF', False, INK, 12.5)],
])
card(8.2, 1.9, 4.5, 4.6, 'Frustrations', [
    [('\u2022 ', True, AMBER, 12.5), ('Verbal phone updates lose clinical detail', False, INK, 12.5)],
    [('\u2022 ', True, AMBER, 12.5), ('No comparable day-by-day history between visits', False, INK, 12.5)],
    [('\u2022 ', True, AMBER, 12.5), ('Worsening vitals trends are invisible until urgent', False, INK, 12.5)],
    [('\u2022 ', True, AMBER, 12.5), ('Managing many home-care patients by memory', False, INK, 12.5)],
    [('\u2022 ', True, AMBER, 12.5), ('No printable record for the patient file', False, INK, 12.5)],
])

# ═══════════ SLIDE 7 — EMPATHY MAP ═══════════
new_slide()
header('Empathy Maps', 7)
quads = [('SAYS', ['\u201cIt is easy to log my daily care now\u201d',
                  '\u201cMy records feel secure\u201d',
                  '\u201cThe videos show me exactly what to do\u201d'], MINT),
         ('DOES', ['Submits a daily vitals + care-task form',
                   'Follows the timed spigotting sessions',
                   'Watches therapy videos and checks the calendar'], WHITE),
         ('THINKS', ['Is my breathing-hold time improving?',
                     'Did the doctor see today\u2019s report?',
                     'Am I doing the dressing correctly?'], WHITE),
         ('FEELS', ['Reassured — doctor watches progress daily',
                    'Confident — guided routine at home',
                    'Motivated — visible day-by-day recovery'], MINT)]
pos = [(0.6, 1.5), (6.85, 1.5), (0.6, 4.15), (6.85, 4.15)]
for (title, items, fill), (x, y) in zip(quads, pos):
    rect(x, y, 5.85, 2.4, fill=fill)
    text(x + 0.2, y + 0.12, 3, 0.35, title, size=15, color=TEAL_DK, bold=True)
    bullets(x + 0.2, y + 0.55, 5.4, 1.7, items, size=12.5, leading=1.25)
text(5.35, 6.75, 7.4, 0.35, 'Users: patient · caregiver · doctor · admin',
     size=11, color=MUTED, align=PP_ALIGN.RIGHT)

# ═══════════ SLIDE 8 — PAIN POINTS ═══════════
new_slide()
header('Pain Points', 8)
pains = [
    ('1', 'Daily care is complex and paper diaries are incomplete, so '
          'clinically important details are lost.'),
    ('2', 'Spigotting weaning sessions are easy to forget and impossible to '
          'review without a timed record.'),
    ('3', 'Doctors cannot see patient progress between visits — a worsening '
          'trend stays invisible until it becomes an emergency.'),
]
for i, (n, t) in enumerate(pains):
    x = 0.6 + i * 4.15
    rect(x, 1.7, 3.9, 3.6, fill=WHITE)
    c = slide.shapes.add_shape(MSO_SHAPE.OVAL, Inches(x + 0.25), Inches(2.0),
                               Inches(0.75), Inches(0.75))
    c.fill.solid(); c.fill.fore_color.rgb = TEAL
    c.line.fill.background(); c.shadow.inherit = False
    tf = c.text_frame; tf.text = n
    tf.paragraphs[0].alignment = PP_ALIGN.CENTER
    r = tf.paragraphs[0].runs[0]
    r.font.size = Pt(26); r.font.bold = True; r.font.color.rgb = WHITE
    text(x + 0.25, 3.05, 3.4, 2.0, t, size=14, color=INK, leading=1.3)
text(0.6, 5.8, 12.1, 0.7,
     'TrachCare turns daily tracheostomy care into structured digital reports '
     'with a timed schedule and a doctor review console.',
     size=14, color=TEAL_DK, bold=True, align=PP_ALIGN.CENTER)

# ═══════════ SLIDE 9 — STORYBOARD ═══════════
new_slide()
header('Storyboard', 9)
steps = [
    ('Discharge', 'Doctor registers the patient with baseline clinical details'),
    ('Daily care', 'Patient logs vitals and care tasks in a guided form'),
    ('Spigotting', 'Timed sessions tracked through the day on the dashboard'),
    ('Review', 'Doctor reviews reports on a calendar, flags issues'),
    ('Export', 'Full patient record exported as PDF for the file'),
]
for i, (t, d) in enumerate(steps):
    x = 0.6 + i * 2.5
    rect(x, 1.7, 2.3, 2.9, fill=MINT if i % 2 == 0 else WHITE)
    c = slide.shapes.add_shape(MSO_SHAPE.OVAL, Inches(x + 0.15),
                               Inches(1.9), Inches(0.55), Inches(0.55))
    c.fill.solid(); c.fill.fore_color.rgb = TEAL_DK
    c.line.fill.background(); c.shadow.inherit = False
    tf = c.text_frame; tf.text = str(i + 1)
    tf.paragraphs[0].alignment = PP_ALIGN.CENTER
    r = tf.paragraphs[0].runs[0]
    r.font.size = Pt(20); r.font.bold = True; r.font.color.rgb = WHITE
    text(x + 0.15, 2.6, 2.0, 0.4, t, size=15, color=TEAL_DK, bold=True)
    text(x + 0.15, 3.05, 2.0, 1.4, d, size=12, color=INK, leading=1.25)
    if i < 4:
        text(x + 2.3, 2.9, 0.25, 0.4, '\u2192', size=18, color=TEAL, bold=True)
pic('fig_7_3_patient_dash.png', 2.2, 5.0, h=1.9)
pic('fig_7_5_doctor_dash.png', 5.0, 5.0, h=1.9)
text(7.4, 5.35, 5.3, 1.2, [
    [('Patient dashboard', True, TEAL_DK, 13),
     (' — daily update, spigotting status, videos', False, INK, 12)],
    '',
    [('Doctor monitor', True, TEAL_DK, 13),
     (' — today\u2019s updates and patient list', False, INK, 12)],
], leading=1.25)

# ═══════════ SLIDE 10 — USER JOURNEY MAP ═══════════
new_slide()
header('User Journey Map', 10)
stages_j = ['Awareness', 'Onboarding', 'Daily Care', 'Doctor Review', 'Recovery']
data = [
    ('Actions', ['Hears about app at discharge', 'Doctor registers patient; '
                 'patient logs in', 'Submits vitals, care tasks, spigotting',
                 'Doctor checks today\u2019s reports on calendar',
                 'PDF export; follow-up completed']),
    ('Goals', ['Understand home-care routine', 'Get set up quickly',
               'Keep a consistent record', 'Catch problems early',
               'Evidence of progress']),
    ('Touchpoints', ['Hospital counselling', 'Role login screens',
                     'Dashboard, daily form, session chips',
                     'Calendar, report detail, alerts', 'Reports, PDF, visits']),
    ('Feeling', ['Anxious', 'Hopeful', 'Building habit', 'Reassured',
                 'Motivated']),
]
tx, ty = 0.6, 1.45
tbl = slide.shapes.add_table(5, 6, Inches(tx), Inches(ty),
                             Inches(12.1), Inches(5.0)).table
tbl.columns[0].width = Inches(1.7)
for i in range(1, 6):
    tbl.columns[i].width = Inches(2.08)
tbl.rows[0].height = Inches(0.55)
for j, s in enumerate(stages_j):
    c = tbl.cell(0, j + 1); c.text = s
    p = c.text_frame.paragraphs[0]; p.alignment = PP_ALIGN.CENTER
    r = p.runs[0]; r.font.bold = True; r.font.size = Pt(12)
    r.font.color.rgb = WHITE; r.font.name = 'Segoe UI'
    c.fill.solid(); c.fill.fore_color.rgb = TEAL_DK
c = tbl.cell(0, 0); c.text = 'Stage'
p = c.text_frame.paragraphs[0]
r = p.runs[0]; r.font.bold = True; r.font.size = Pt(12)
r.font.color.rgb = WHITE; r.font.name = 'Segoe UI'
c.fill.solid(); c.fill.fore_color.rgb = TEAL
for i, (label, cells) in enumerate(data):
    c = tbl.cell(i + 1, 0); c.text = label
    p = c.text_frame.paragraphs[0]
    r = p.runs[0]; r.font.bold = True; r.font.size = Pt(11.5)
    r.font.color.rgb = TEAL_DK; r.font.name = 'Segoe UI'
    c.fill.solid(); c.fill.fore_color.rgb = TEAL_LT
    for j, val in enumerate(cells):
        c = tbl.cell(i + 1, j + 1); c.text = val
        p = c.text_frame.paragraphs[0]
        r = p.runs[0]; r.font.size = Pt(10.5); r.font.name = 'Segoe UI'
        r.font.color.rgb = INK
        c.fill.solid(); c.fill.fore_color.rgb = WHITE if i % 2 else MINT

# ═══════════ SLIDE 11 — PAPER WIREFRAMES ═══════════
new_slide()
header('Paper Wireframes', 11)
rect(0.6, 1.4, 12.1, 4.6, fill=WHITE)
pic('fig_5_2_wireframes.png', 2.4, 1.7, h=4.0)
text(0.6, 6.2, 12.1, 0.5,
     'Early sketches of the three role flows — patient daily check-in, '
     'doctor review and admin management.', size=13, color=MUTED,
     align=PP_ALIGN.CENTER)

# ═══════════ SLIDE 12 — LOW FIDELITY ═══════════
new_slide()
header('Low Fidelity UI Design', 12)
lo = [('fig_7_2_login.png', 'Role login'),
      ('fig_7_4_daily_update.png', 'Daily update form'),
      ('fig_7_6_add_patient.png', 'Add patient')]
for i, (f, cap) in enumerate(lo):
    x = 1.5 + i * 3.7
    rect(x - 0.15, 1.5, 2.55, 4.9, fill=WHITE)
    pic(f, x, 1.65, h=4.4)
    text(x - 0.15, 6.15, 2.55, 0.35, cap, size=12, color=MUTED,
         align=PP_ALIGN.CENTER)

# ═══════════ SLIDE 13 — HIGH FIDELITY ═══════════
new_slide()
header('High Fidelity UI Design', 13)
hi = [('fig_7_1_splash.png', 'Splash'), ('fig_7_3_patient_dash.png', 'Patient home'),
      ('fig_7_5_doctor_dash.png', 'Doctor monitor'),
      ('fig_7_7_approvals.png', 'Approvals'), ('fig_7_8_videos.png', 'Video library')]
for i, (f, cap) in enumerate(hi):
    x = 0.85 + i * 2.45
    rect(x - 0.1, 1.5, 2.15, 4.6, fill=WHITE)
    pic(f, x, 1.62, h=4.15)
    text(x - 0.1, 6.0, 2.15, 0.35, cap, size=11.5, color=MUTED,
         align=PP_ALIGN.CENTER)
text(0.6, 6.5, 12.1, 0.4,
     'Teal healthcare theme · shared design system · IBM Plex Sans',
     size=12, color=TEAL_DK, align=PP_ALIGN.CENTER, bold=True)

# ═══════════ SLIDE 14 — DEV STACK ═══════════
new_slide()
header('Development Stack', 14)
layers = [
    ('FRONT END', 'Flutter (Dart)', 'Role-based screens for Patient, Doctor '
     'and Admin · one codebase for Android, Windows and web · media_kit '
     'video, table_calendar, image_picker', MINT),
    ('BACK END', 'PHP REST API', 'JSON endpoints over HTTPS on Apache · '
     'auth/Patient/Doctor/Admin routes · multipart uploads for photos, '
     'videos and thumbnails', WHITE),
    ('DATABASE', 'MySQL / MariaDB', 'trachcare schema — patients, daily '
     'reports, spigotting status, video catalogue · triggers auto-provision '
     'login, profile and status rows', MINT),
]
for i, (tag, title, desc, fill) in enumerate(layers):
    x = 0.9 + i * 4.2
    rect(x, 1.8, 3.9, 3.6, fill=fill)
    rect(x + 0.25, 2.1, 1.6, 0.5, fill=TEAL_DK, line=None)
    text(x + 0.25, 2.2, 1.6, 0.35, tag, size=11, color=WHITE, bold=True,
         align=PP_ALIGN.CENTER)
    text(x + 0.25, 2.8, 3.4, 0.5, title, size=20, color=TEAL_DK, bold=True)
    text(x + 0.25, 3.4, 3.4, 1.9, desc, size=12.5, color=INK, leading=1.3)
text(0.6, 5.9, 12.1, 0.7,
     'Flutter client \u2192 HTTP/JSON \u2192 PHP endpoints \u2192 MySQL — '
     'three-tier design with role-separated APIs',
     size=14, color=MUTED, align=PP_ALIGN.CENTER)

# ═══════════ SLIDE 15 — GESTALT ITERATIONS ═══════════
new_slide()
header("Gestalt's Principles : UXD Design Iterations", 15)
rect(0.6, 1.5, 5.9, 2.3, fill=WHITE)
text(0.85, 1.65, 5, 0.35, 'VERSION 0.1', size=14, color=MUTED, bold=True)
bullets(0.85, 2.1, 5.4, 1.5, [
    'Washed-out pastel green/peach palette',
    'Heavy shadows, inconsistent widgets',
    'Duplicated name cards and video lists',
], size=13, leading=1.4)
rect(6.85, 1.5, 5.85, 2.3, fill=MINT)
text(7.1, 1.65, 5, 0.35, 'VERSION 0.2', size=14, color=TEAL_DK, bold=True)
bullets(7.1, 2.1, 5.3, 1.5, [
    'One teal healthcare theme + shared design system',
    'Recognizable icons, clear card-based layout',
    'Colour-coded statuses and good visual hierarchy',
], size=13, leading=1.4)
text(6.4, 2.4, 0.5, 0.6, '\u2192', size=26, color=TEAL, bold=True)
prins = [('Similarity', 'Shared AppCard / VideoCard / PatientNameCard '
          'widgets keep repeated content visually consistent'),
         ('Proximity', 'Daily-update fields grouped into Vitals / Daily '
          'care / Spigotting cards'),
         ('Common region', 'Status chips and story rings group related '
          'patient state'),
         ('Figure-ground', 'Gradient headers separate identity from content')]
for i, (t, d) in enumerate(prins):
    x = 0.6 + (i % 2) * 6.25
    y = 4.15 + (i // 2) * 1.35
    rect(x, y, 6.05, 1.2, fill=WHITE)
    text(x + 0.2, y + 0.1, 5.6, 0.3, t, size=13, color=TEAL_DK, bold=True)
    text(x + 0.2, y + 0.42, 5.6, 0.7, d, size=11, color=INK, leading=1.15)

# ═══════════ SLIDE 16 — NIELSEN HEURISTICS ═══════════
new_slide()
header("Nielsen's Heuristic Principles : Iterations", 16)
items = [
    ('Visibility of system status', 'Spigotting session chips show done / '
     'current / locked states with colour coding.'),
    ('Match with the real world', 'Care tasks use clinical wording '
     '(dressing, tie change, suctioning) with Yes/No chips.'),
    ('User control & freedom', 'Edit profile, back navigation and explicit '
     'dialogs on every destructive action.'),
    ('Error prevention', 'Required vitals validated before submit; '
     'sessions unlock only in time order.'),
    ('Recognition over recall', 'Dashboard shows next appointment, '
     'today\u2019s sessions and last report without searching.'),
    ('Feedback', 'Toasts, upload progress and empty states confirm every '
     'action.'),
]
for i, (t, d) in enumerate(items):
    x = 0.6 + (i % 2) * 6.25
    y = 1.5 + (i // 2) * 1.75
    rect(x, y, 6.05, 1.6, fill=WHITE if i % 3 else MINT)
    text(x + 0.2, y + 0.12, 5.6, 0.35, t, size=14, color=TEAL_DK, bold=True)
    text(x + 0.2, y + 0.5, 5.6, 1.0, d, size=12, color=INK, leading=1.2)

# ═══════════ SLIDE 17 — ARCHITECTURE ═══════════
new_slide()
header('Software Architecture', 17)
rect(0.6, 1.5, 12.1, 4.4, fill=WHITE)
pic('fig_6_1_architecture.png', 1.6, 1.9, h=3.5)
text(0.6, 6.15, 12.1, 0.5,
     'Three-tier design: Flutter app \u2192 PHP REST API (JSON over HTTPS) '
     '\u2192 MySQL "trachcare" schema with provisioning triggers.',
     size=13, color=MUTED, align=PP_ALIGN.CENTER)

# ═══════════ SLIDE 18 — WCAG ACCESSIBILITY ═══════════
new_slide()
header('WCAG — Accessibility Considerations', 18)
acc = [
    ('1', 'Simple, clear layouts with readable contrast and the teal theme '
          'make the app easy for all users to understand.'),
    ('2', 'Large touch targets (\u226548 dp), readable text and Yes/No chips '
          'let elderly patients log daily care with few taps.'),
    ('3', 'Guided exercise videos, clear labels and status feedback support '
          'caregivers with limited clinical or digital experience.'),
]
for i, (n, t) in enumerate(acc):
    y = 1.6 + i * 1.7
    rect(0.6, y, 12.1, 1.5, fill=MINT if i % 2 == 0 else WHITE)
    c = slide.shapes.add_shape(MSO_SHAPE.OVAL, Inches(0.9), Inches(y + 0.35),
                               Inches(0.75), Inches(0.75))
    c.fill.solid(); c.fill.fore_color.rgb = TEAL
    c.line.fill.background(); c.shadow.inherit = False
    tf = c.text_frame; tf.text = n
    tf.paragraphs[0].alignment = PP_ALIGN.CENTER
    r = tf.paragraphs[0].runs[0]
    r.font.size = Pt(26); r.font.bold = True; r.font.color.rgb = WHITE
    text(2.0, y + 0.3, 10.3, 1.0, t, size=15, color=INK, leading=1.3)

# ═══════════ SLIDE 19 — TAKEAWAYS ═══════════
new_slide()
header('Takeaways', 19)
rect(0.6, 1.5, 5.9, 4.6, fill=MINT)
text(0.85, 1.65, 5.4, 0.4, 'Impact', size=17, color=TEAL_DK, bold=True)
text(0.85, 2.15, 5.4, 3.6, [
    [('TrachCare gives discharged tracheostomy patients a guided daily '
      'routine and gives doctors a structured record between visits.',
      False, INK, 14)],
    '',
    [('It replaces informal phone-call follow-up with an auditable, '
      'day-by-day clinical history.', False, INK, 14)],
    '',
    [('The same role-based pattern extends to other post-surgical '
      'home-care pathways.', False, INK, 14)],
], leading=1.3)
rect(6.85, 1.5, 5.85, 4.6, fill=WHITE)
text(7.1, 1.65, 5.4, 0.4, 'What I learned', size=17, color=TEAL_DK, bold=True)
text(7.1, 2.15, 5.4, 3.6, [
    [('A shared design system keeps ~40 role screens consistent and fast '
      'to iterate.', False, INK, 14)],
    '',
    [('Database triggers can safely auto-provision related rows on '
      'patient registration.', False, INK, 14)],
    '',
    [('Shipping an MVP early and iterating on feedback beats polishing '
      'in isolation.', False, INK, 14)],
], leading=1.3)

# ═══════════ SLIDE 20 — NEXT STEPS ═══════════
new_slide()
header('Next Steps', 20)
nxt = [
    ('1', 'Usability testing', 'Run structured walkthroughs with patients, '
     'caregivers and the care team; refine the daily form from feedback.'),
    ('2', 'Clinical alerts', 'Flag abnormal vitals and escalate missed '
     'daily reports to the treating doctor with push notifications.'),
    ('3', 'Smarter care', 'Offline-first sync, multi-language support, '
     'medication schedules and AI-assisted trend summaries.'),
]
for i, (n, t, d) in enumerate(nxt):
    x = 0.6 + i * 4.15
    rect(x, 1.7, 3.9, 4.3, fill=WHITE)
    c = slide.shapes.add_shape(MSO_SHAPE.OVAL, Inches(x + 0.25), Inches(2.0),
                               Inches(0.75), Inches(0.75))
    c.fill.solid(); c.fill.fore_color.rgb = TEAL_DK
    c.line.fill.background(); c.shadow.inherit = False
    tf = c.text_frame; tf.text = n
    tf.paragraphs[0].alignment = PP_ALIGN.CENTER
    r = tf.paragraphs[0].runs[0]
    r.font.size = Pt(26); r.font.bold = True; r.font.color.rgb = WHITE
    text(x + 0.25, 2.95, 3.4, 0.5, t, size=17, color=TEAL_DK, bold=True)
    text(x + 0.25, 3.5, 3.4, 2.3, d, size=13, color=INK, leading=1.3)

# ═══════════ SLIDE 21 — LET'S CONNECT ═══════════
new_slide()
rect(0, 0, SW, SH, fill=TEAL_DK, line=None, radius=False)
text(0.6, 0.8, 8, 0.8, "Let's Connect", size=40, color=WHITE, bold=True)
text(0.6, 1.75, 8, 0.9,
     'Thank you for your time reviewing my work. Scan the QR code or '
     'reach out to keep in touch.', size=16, color=TEAL_LT, leading=1.3)
rect(0.6, 3.0, 3.3, 3.3, fill=WHITE, line=None)
pic('qr_linkedin_santhosh.png', 0.75, 3.15, h=3.0)
text(0.6, 6.4, 3.3, 0.35, 'Scan — LinkedIn profile', size=12,
     color=TEAL_LT, align=PP_ALIGN.CENTER)
text(4.5, 3.15, 6.4, 2.4, [
    [(NAME, True, WHITE, 26)],
    [(f'Reg. No. {REGNO}', False, TEAL_LT, 15)],
    [(EMAIL, False, TEAL_LT, 15)],
    '',
    [('BTech IT  ·  TrachCare Project', False, WHITE, 13)],
], leading=1.35)
pic('student_photo.png', 10.4, 2.6, h=3.6)
rect(10.38, 2.58, 2.44, 3.64, fill=None, line=TEAL_LT, line_w=2, radius=False)
text(0.6, 7.05, 12, 0.3, FOOTER, size=10, color=TEAL_LT)

prs.save(OUT)
print('written:', OUT)
