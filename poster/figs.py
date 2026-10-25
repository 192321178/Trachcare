#!/usr/bin/env python3
"""Generate report figures for the TrachCare PDD report.

Draws phone mockups approximating the shipped screens, plus architecture,
schema, flow and timeline diagrams. Output: poster/figs/*.png
"""
import os
from PIL import Image, ImageDraw, ImageFont

OUT = os.path.join(os.path.dirname(__file__), 'figs')
os.makedirs(OUT, exist_ok=True)

TEAL = (15, 118, 110)
TEAL_DK = (17, 94, 89)
TEAL_LT = (204, 251, 241)
MINT = (236, 253, 245)
INK = (15, 23, 42)
MUTED = (100, 116, 139)
LINE = (203, 213, 225)
CARD = (255, 255, 255)
BG = (241, 245, 249)
AMBER = (217, 119, 6)
RED = (220, 38, 38)
GREEN = (22, 163, 74)


def font(sz, bold=False):
    paths = [
        'C:/Windows/Fonts/seguisb.ttf' if bold else 'C:/Windows/Fonts/segoeui.ttf',
        'C:/Windows/Fonts/arialbd.ttf' if bold else 'C:/Windows/Fonts/arial.ttf',
    ]
    for p in paths:
        if os.path.exists(p):
            return ImageFont.truetype(p, sz)
    return ImageFont.load_default()


F = lambda s: font(s)
FB = lambda s: font(s, True)


def phone(w=300, h=620, title='TrachCare'):
    """Blank phone frame with teal header. Returns (img, draw, content_y)."""
    img = Image.new('RGB', (w, h), BG)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, w - 1, h - 1], radius=28, outline=INK, width=3)
    d.rounded_rectangle([0, 0, w - 1, 64], radius=28, fill=TEAL)
    d.rectangle([0, 40, w, 64], fill=TEAL)
    d.text((16, 30), title, font=FB(19), fill='white')
    return img, d, 78


def card(d, x, y, w, h, r=10, fill=CARD, outline=LINE):
    d.rounded_rectangle([x, y, x + w, y + h], radius=r, fill=fill, outline=outline, width=1)


def textbar(d, x, y, w, h=9, color=LINE, r=4):
    d.rounded_rectangle([x, y, x + w, y + h], radius=r, fill=color)


def chip(d, x, y, label, bg=TEAL_LT, fg=TEAL_DK):
    w = 10 + d.textlength(label, font=F(11))
    d.rounded_rectangle([x, y, x + w, y + 20], radius=10, fill=bg)
    d.text((x + 5, y + 3), label, font=F(11), fill=fg)
    return w


def button(d, x, y, w, label, h=40):
    d.rounded_rectangle([x, y, x + w, y + h], radius=12, fill=TEAL)
    tw = d.textlength(label, font=FB(13))
    d.text((x + (w - tw) / 2, y + h / 2 - 9), label, font=FB(13), fill='white')


def field(d, x, y, w, label, value=''):
    d.text((x + 8, y - 14), label, font=F(11), fill=MUTED)
    card(d, x, y, w, 42, r=10)
    if value:
        d.text((x + 34, y + 12), value, font=FB(14), fill=INK)
    d.ellipse([x + 10, y + 14, x + 24, y + 28], outline=MUTED, width=2)


def ecg(d, x, y, w, h=36):
    """ECG trace strip."""
    card(d, x, y, w, h, r=8, fill=(248, 250, 252))
    mid = y + h // 2
    pts, px = [], x + 6
    while px < x + w - 6:
        seg = min(28, x + w - 6 - px)
        pts += [(px, mid), (px + seg * .35, mid), (px + seg * .45, mid - h * .34),
                (px + seg * .55, mid + h * .34), (px + seg * .65, mid)]
        px += seg
    d.line(pts, fill=TEAL, width=2)


def save(img, name):
    img.save(os.path.join(OUT, name))
    print(' ', name)


# ─────────────── 1. SPLASH ───────────────
img = Image.new('RGB', (300, 620), TEAL_DK)
d = ImageDraw.Draw(img)
d.rounded_rectangle([0, 0, 299, 619], radius=28, outline=INK, width=3)
d.rounded_rectangle([0, 0, 299, 619], radius=28, fill=TEAL_DK)
d.ellipse([110, 190, 190, 270], fill='white')
d.text((140, 208), 'T', font=FB(40), fill=TEAL_DK)
tw = d.textlength('TrachCare', font=FB(30))
d.text(((300 - tw) / 2, 300), 'TrachCare', font=FB(30), fill='white')
tw = d.textlength('Tracheostomy care, guided at home', font=F(12))
d.text(((300 - tw) / 2, 345), 'Tracheostomy care, guided at home',
       font=F(12), fill=(190, 230, 226))
# ecg
mid = 430; pts = []; px = 50
while px < 250:
    pts += [(px, mid), (px + 8, mid), (px + 11, mid - 16), (px + 14, mid + 16), (px + 17, mid)]
    px += 30
d.line(pts, fill='white', width=2)
save(img, 'fig_7_1_splash.png')

# ─────────────── 2. LOGIN ───────────────
img, d, y = phone(title='Welcome back')
card(d, 16, 90, 268, 320, r=14)
d.text((32, 110), 'Patient sign in', font=FB(15), fill=INK)
field(d, 32, 150, 236, 'Username or Email', 'santhosh@gmail.com')
field(d, 32, 230, 236, 'Password', '*' * 12)
button(d, 32, 300, 236, 'Sign in')
d.text((60, 370), 'Forgot password?', font=F(11), fill=TEAL)
d.text((52, 440), 'New to TrachCare? Create an account', font=F(11), fill=MUTED)
save(img, 'fig_7_2_login.png')

# ─────────────── 3. PATIENT DASHBOARD ───────────────
img, d, y = phone(title='Hello, Santhosh')
chip(d, 16, 74, 'PATIENT PORTAL')
ecg(d, 16, 104, 268, 40)
card(d, 16, 158, 268, 96)
d.ellipse([30, 178, 74, 222], outline=TEAL, width=4)
d.ellipse([36, 184, 68, 216], outline=TEAL_LT, width=3)
d.text((86, 182), 'Spigotting status', font=FB(12), fill=INK)
d.text((86, 202), 'Day 14 of weaning', font=F(11), fill=MUTED)
chip(d, 200, 168, 'ON TRACK')
card(d, 16, 266, 268, 80)
d.text((28, 278), 'Daily update', font=FB(13), fill=INK)
d.text((28, 300), 'Vitals and care status for today', font=F(11), fill=MUTED)
button(d, 170, 296, 100, 'Log now', h=32)
card(d, 16, 358, 268, 70)
d.text((28, 370), 'Therapy videos', font=FB(13), fill=INK)
d.text((28, 392), 'Tie change · Dressing · Suctioning', font=F(10.5), fill=MUTED)
d.rectangle([16, 470, 284, 560], fill=MINT)
for i, ic in enumerate(['Home', 'Videos', 'Alerts', 'Profile']):
    d.ellipse([40 + i * 60, 492, 64 + i * 60, 516], outline=TEAL, width=2)
    d.text((36 + i * 60, 528), ic, font=F(9), fill=TEAL_DK)
save(img, 'fig_7_3_patient_dash.png')

# ─────────────── 4. DAILY UPDATE ───────────────
img, d, y = phone(title='Daily update')
chip(d, 16, 74, 'TODAY')
for i, (lbl, val) in enumerate([
        ('Respiratory rate', '18 /min'), ('Heart rate', '82 bpm'),
        ('SpO2', '97 %'), ('Tube status', 'Clean, patent')]):
    field(d, 16, 110 + i * 70, 268, lbl, val)
button(d, 16, 400, 268, 'Submit report')
d.text((46, 460), 'Submitted reports go straight to your doctor', font=F(10.5), fill=MUTED)
save(img, 'fig_7_4_daily_update.png')

# ─────────────── 5. DOCTOR DASHBOARD ───────────────
img, d, y = phone(title='Doctor console')
chip(d, 16, 74, 'DR. VARSHA')
ecg(d, 16, 104, 268, 40)
row = [('Patients', '7'), ('Reports', '23'), ('Flagged', '2')]
for i, (t, v) in enumerate(row):
    card(d, 16 + i * 92, 158, 84, 64)
    d.text((24 + i * 92, 166), v, font=FB(20), fill=TEAL_DK)
    d.text((24 + i * 92, 194), t, font=F(10.5), fill=MUTED)
d.text((16, 240), 'Patients', font=FB(14), fill=INK)
for i, (nm, st, c) in enumerate([('Santhosh', 'stable', GREEN),
                               ('Sivanesan', 'review', AMBER),
                               ('Gowrishankar', 'flagged', RED)]):
    card(d, 16, 262 + i * 58, 268, 50)
    d.ellipse([28, 272 + i * 58, 56, 300 + i * 58], fill=TEAL_LT)
    d.text((34, 279 + i * 58), nm[0], font=FB(13), fill=TEAL_DK)
    d.text((66, 272 + i * 58), nm, font=FB(12), fill=INK)
    d.text((66, 292 + i * 58), 'Last report 08:12', font=F(9.5), fill=MUTED)
    chip(d, 212, 274 + i * 58, st.upper())
save(img, 'fig_7_5_doctor_dash.png')

# ─────────────── 6. ADD PATIENT ───────────────
img, d, y = phone(title='Add patient')
d.ellipse([110, 84, 190, 164], outline=TEAL, width=3)
d.ellipse([140, 114, 160, 134], outline=TEAL, width=2)
d.text((110, 172), 'Add photo', font=F(10), fill=TEAL)
for i, lbl in enumerate(['Name', 'Email', 'Phone', 'Age', 'Diagnosis']):
    field(d, 16, 200 + i * 64, 268, lbl)
button(d, 16, 540, 268, 'Submit for review')
save(img, 'fig_7_6_add_patient.png')

# ─────────────── 7. APPROVALS ───────────────
img, d, y = phone(title='Approvals')
chip(d, 16, 74, '3 PENDING')
for i, nm in enumerate(['Dr. Ravi', 'Dr. Sham', 'A. Kumar']):
    card(d, 16, 108 + i * 140, 268, 128)
    d.ellipse([28, 120 + i * 140, 60, 152 + i * 140], fill=TEAL_LT)
    d.text((70, 124 + i * 140), nm, font=FB(13), fill=INK)
    d.text((70, 144 + i * 140), 'applied 22 Oct', font=F(10), fill=MUTED)
    chip(d, 200, 122 + i * 140, 'PENDING', bg=(254, 243, 199), fg=AMBER)
    d.rounded_rectangle([28, 178 + i * 140, 136, 210 + i * 140], radius=8,
                        outline=RED, width=2)
    d.text((62, 186 + i * 140), 'REJECT', font=FB(10), fill=RED)
    d.rounded_rectangle([148, 178 + i * 140, 272, 210 + i * 140], radius=8,
                        fill=TEAL)
    d.text((186, 186 + i * 140), 'APPROVE', font=FB(10), fill='white')
save(img, 'fig_7_7_approvals.png')

# ─────────────── 8. VIDEO LIBRARY ───────────────
img, d, y = phone(title='Therapy library')
for i, (t, s) in enumerate([('Tracheostomy tie change', '4:12'),
                            ('Dressing change', '6:03'),
                            ('Suctioning technique', '5:47')]):
    card(d, 16, 96 + i * 150, 268, 138)
    d.rounded_rectangle([24, 104 + i * 150, 276, 186 + i * 150], radius=8,
                        fill=TEAL_DK)
    d.polygon([(140, 130 + i * 150), (140, 160 + i * 150),
               (170, 145 + i * 150)], fill='white')
    d.text((28, 194 + i * 150), t, font=FB(11.5), fill=INK)
    chip(d, 28, 216 + i * 150, s)
save(img, 'fig_7_8_videos.png')

# ─────────────── 9. WIREFRAMES (4 lo-fi phones) ───────────────
img = Image.new('RGB', (760, 420), 'white')
d = ImageDraw.Draw(img)
titles = ['1 Login', '2 Daily report', '3 Doctor monitor', '4 Admin']
for i, t in enumerate(titles):
    x = 20 + i * 185
    d.rounded_rectangle([x, 10, x + 165, 390], radius=18, outline=INK, width=2)
    d.rectangle([x + 2, 12, x + 163, 44], fill=LINE)
    for j in range(3):
        d.rectangle([x + 14, 60 + j * 48, x + 150, 96 + j * 48],
                    outline=LINE, width=2)
    d.rectangle([x + 14, 216, x + 150, 248], fill=(148, 163, 184))
    d.rectangle([x + 14, 262, x + 150, 288], outline=LINE, width=2)
    d.text((x + 24, 396), t, font=FB(13), fill=INK)
save(img, 'fig_5_2_wireframes.png')

# ─────────────── 10. ARCHITECTURE ───────────────
img = Image.new('RGB', (980, 420), 'white')
d = ImageDraw.Draw(img)
d.text((20, 12), 'TrachCare system architecture', font=FB(20), fill=INK)


def box(x, y, w, h, title, lines, fill):
    d.rounded_rectangle([x, y, x + w, y + h], radius=12, fill=fill,
                        outline=TEAL, width=2)
    tw = d.textlength(title, font=FB(15))
    d.text((x + (w - tw) / 2, y + 12), title, font=FB(15), fill=TEAL_DK)
    for j, l in enumerate(lines):
        tw = d.textlength(l, font=F(11.5))
        d.text((x + (w - tw) / 2, y + 44 + j * 18), l, font=F(11.5), fill=INK)


box(30, 90, 260, 230, 'Flutter app', [
    'Patient / Doctor / Admin', 'Dashboards and forms',
    'media_kit video player', 'local session store'], MINT)
box(380, 90, 230, 230, 'Apache + PHP', [
    'REST JSON endpoints', 'auth / OTP / approvals',
    'uploads handler', 'prepared statements'], TEAL_LT)
box(700, 90, 250, 230, 'MariaDB', [
    'trachcare schema', '7 tables', 'phpMyAdmin',
    'uploads/ files'], (219, 234, 254))
for x1 in (290, 610):
    d.line([x1 + 8, 205, x1 + 82, 205], fill=TEAL, width=3)
    d.polygon([(x1 + 82, 205), (x1 + 70, 199), (x1 + 70, 211)], fill=TEAL)
d.text((300, 180), 'HTTP JSON', font=F(11), fill=MUTED)
d.text((620, 180), 'SQL', font=F(11), fill=MUTED)
save(img, 'fig_6_1_architecture.png')

# ─────────────── 11. DB SCHEMA ───────────────
img = Image.new('RGB', (980, 460), 'white')
d = ImageDraw.Draw(img)
d.text((20, 10), 'Database schema (trachcare)', font=FB(20), fill=INK)
tables = [
    ('addpatients', ['patient_id PK', 'name, email, phone', 'vitals + labs',
                     'image_path', 'doctor_id FK']),
    ('doctorprofile', ['doctor_id PK', 'username, email', 'doctor_reg_no',
                       'image_path', 'status']),
    ('adminlogin', ['id PK', 'username, email', 'status']),
    ('dailyupdates', ['id PK', 'patient_id FK', 'vitals', 'created_at']),
    ('patientvideotable', ['s.no PK', 'title', 'Video_url', 'Thumbnail_url']),
    ('spiotting_status', ['id', 'patient_id', 'status']),
    ('otp_codes', ['id PK', 'email, role', 'code', 'expires_at', 'used']),
]
for i, (t, cols) in enumerate(tables):
    x = 30 + (i % 4) * 240
    y = 60 + (i // 4) * 190
    card(d, x, y, 220, 30 + len(cols) * 20 + 10)
    d.rectangle([x, y, x + 220, y + 30], fill=TEAL)
    tw = d.textlength(t, font=FB(12))
    d.text((x + (220 - tw) / 2, y + 7), t, font=FB(12), fill='white')
    for j, c in enumerate(cols):
        d.text((x + 10, y + 38 + j * 20), c, font=F(10.5), fill=INK)
save(img, 'fig_6_2_schema.png')

# ─────────────── 12. USER FLOW ───────────────
img = Image.new('RGB', (980, 300), 'white')
d = ImageDraw.Draw(img)
d.text((20, 10), 'User flow', font=FB(20), fill=INK)
steps = ['Login\n(3 roles)', 'Role\ndashboard', 'Submit /\nreview', 'Server\nPHP+MySQL', 'Result\n& alerts']
for i, s in enumerate(steps):
    x = 40 + i * 190
    card(d, x, 110, 140, 70, fill=TEAL_LT, outline=TEAL)
    lines = s.split('\n')
    for j, l in enumerate(lines):
        tw = d.textlength(l, font=FB(12))
        d.text((x + 70 - tw / 2, 122 + j * 20), l, font=FB(12), fill=TEAL_DK)
    if i < 4:
        d.line([x + 142, 145, x + 186, 145], fill=TEAL, width=3)
        d.polygon([(x + 186, 145), (x + 174, 139), (x + 174, 151)], fill=TEAL)
save(img, 'fig_flow.png')

# ─────────────── 13. TIMELINE ───────────────
img = Image.new('RGB', (980, 220), 'white')
d = ImageDraw.Draw(img)
d.text((20, 10), 'Project timeline', font=FB(20), fill=INK)
stages = [('Analysis', 0, 2), ('Design', 1.5, 3), ('Backend', 3, 5),
          ('App build', 4, 8), ('Hardening', 7.5, 9), ('Release', 9, 10)]
for i, (name, a, b) in enumerate(stages):
    y = 50 + i * 26
    d.text((20, y), name, font=FB(11), fill=INK)
    d.rounded_rectangle([140 + a * 78, y, 140 + b * 78, y + 16], radius=8,
                        fill=TEAL)
d.line([140, 42, 920, 42], fill=LINE, width=1)
for w in range(11):
    d.text((140 + w * 78 - 6, 190), f'W{w}', font=F(9), fill=MUTED)
save(img, 'fig_timeline.png')

print('done:', len(os.listdir(OUT)), 'figures in', OUT)
