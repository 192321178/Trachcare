"""Splash, welcome, auth, patient dashboard, sheets, therapy, player."""

from svg_kit import *
from ui import *


# ------------------------------------------------------------------ 01 splash
def splash():
    doc = page("01 Splash", bg=TEAL_DEEP, status=False)
    doc.add(rect(0, 0, W, H, fill=doc.grad("bg", [(0, TEAL_DEEP), (0.52, TEAL), (1, TEAL_LIGHT)],
                                           0.15, 0, 0.85, 1), name="Background gradient"))
    rid = doc.radial("glow-a", [(0, MINT, 0.55), (1, MINT, 0)])
    rid2 = doc.radial("glow-b", [(0, WHITE, 0.35), (1, WHITE, 0)])
    doc.add(g("Decor / glow",
              circle(96, 150, 190, fill=rid, name="Glow top"),
              circle(360, 700, 210, fill=rid2, name="Glow bottom")))
    doc.add(status_bar(doc, dark=True))

    cx, cy = W / 2, 318
    doc.add(g("Logo lockup",
              soft_shadow(doc, cx - 58, cy - 58, 116, 116, 32, "rgba(0,0,0,0.35)", lift=7),
              rect(cx - 58, cy - 58, 116, 116, rx=32, fill=WHITE, name="Logo card"),
              rect(cx - 58, cy - 58, 116, 116, rx=32, stroke=MINT, sw=1.2, opacity=0.6,
                   name="Logo border"),
              icon("lungs", cx - 26, cy - 26, 52, TEAL, 1.7, name="Lungs mark"),
              circle(cx, cy + 26, 3.4, fill=MINT, name="Mark base")))
    doc.add(g("Wordmark",
              text(cx, 424, "TrachCare", 34, 800, WHITE, "middle", spacing=-0.6,
                   name="Title"),
              text(cx, 452, "Tracheostomy care, guided at home", 13.5, 500,
                   "rgba(255,255,255,0.82)", "middle", name="Tagline")))

    doc.add(g("Loading",
              circle(cx - 20, 528, 5, fill=WHITE, opacity=0.95, name="Dot 1"),
              circle(cx, 528, 5, fill=WHITE, opacity=0.6, name="Dot 2"),
              circle(cx + 20, 528, 5, fill=WHITE, opacity=0.3, name="Dot 3"),
              text(cx, 556, "Preparing your care plan", 11.5, 600,
                   "rgba(255,255,255,0.6)", "middle", spacing=0.6, caps=True,
                   name="Status")))
    doc.add(text(cx, 792, "Version 2.0.0  ·  built with Flutter", 10.5, 500,
                 "rgba(255,255,255,0.45)", "middle", name="Version"))
    doc.add(home_indicator(doc, dark=True))
    return "01-splash", doc


# ------------------------------------------------------------------ 02 welcome
def welcome():
    doc = page("02 Welcome - role picker", status=False)
    gid = doc.grad("hero", [(0, TEAL_DEEP), (0.6, TEAL), (1, TEAL_LIGHT)], 0.1, 0, 0.9, 1)
    doc.add(rect(0, 0, W, 300, fill=gid, name="Hero gradient"),
            circle(W - 40, 40, 90, fill=WHITE, opacity=0.06, name="Glow"),
            status_bar(doc, dark=True))
    doc.add(g("Hero copy",
              text(PAGE, 108, "Welcome to", 11, 700, MINT, spacing=2.0, caps=True,
                   name="Eyebrow"),
              text(PAGE, 142, "TrachCare", 32, 800, WHITE, spacing=-0.8, name="Title"),
              para(PAGE, 172, wrap("Your guided airway routine at home - every day, "
                                    "every check, in one place.", 40), 13.5, 20.5, 500,
                   "rgba(255,255,255,0.85)", name="Lede"),
              icon("sparkle", 250, 92, 26, MINT, name="Sparkle")))

    sheet_top = 236
    doc.add(g("Sheet",
              soft_shadow(doc, 0, sheet_top, W, H - sheet_top, R_SHEET, SHADOW, lift=8),
              corner_rect(0, sheet_top, W, H - sheet_top, top=R_SHEET, fill=SURFACE,
                         name="Sheet surface"),
              drag_handle(doc, W / 2, sheet_top + 14)))

    y = sheet_top + 52
    doc.add(text(PAGE, y, "Choose how you want to continue", 11, 700, INK_MUTED,
                 spacing=1.4, caps=True, name="Prompt"))
    y += 22

    for label, sub, ic, accent, soft in (
        ("Patient", "Daily routine, videos and records", "user", TEAL, MINT_SOFT),
        ("Doctor", "Review patients and update plans", "doctor", SKY, SKY_SOFT)):
        doc.add(card(doc, PAGE, y, W - PAGE * 2, 92, fill=WHITE, shadow=True,
                     name="Role card / %s" % label))
        doc.add(rect(PAGE, y, W - PAGE * 2, 92, rx=R_CARD, stroke=DIVIDER, sw=1,
                     fill="none", name="Border"))
        doc.add(g("Role / %s" % label,
                  rect(PAGE + 18, y + 22, 48, 48, rx=16, fill=soft, name="Icon chip"),
                  icon(ic, PAGE + 30, y + 34, 24, accent, 1.9, name="Icon"),
                  text(PAGE + 80, y + 38, label, 17.5, 700, INK, name="Title"),
                  text(PAGE + 80, y + 59, sub, 11.5, 500, INK_MUTED, name="Subtitle"),
                  icon("chevron_right", W - PAGE - 34, y + 38, 18, INK_MUTED, 2.0,
                       name="Chevron")))
        y += 104

    y += 14
    doc.add(g("Admin entry",
              line(PAGE + 60, y + 4, W / 2 - 40, y + 4, stroke=DIVIDER, name="Rule left"),
              text(W / 2, y + 8, "or", 11, 600, INK_MUTED, "middle", name="Or"),
              line(W / 2 + 40, y + 4, W - PAGE - 60, y + 4, stroke=DIVIDER,
                   name="Rule right")))
    y += 26
    doc.add(g("Button / admin text",
              icon("shield", W / 2 - 78, y + 6, 16, TEAL, 2.0, name="Icon"),
              text(W / 2 - 54, y + 19, "Continue as clinic admin", 14.5, 700, TEAL,
                   name="Label")))
    y += 52
    doc.add(para(W / 2, y + 20,
                 wrap("Protected health information stays on this device's account only.",
                      52), 10.5, 15, 500, INK_MUTED, "middle", name="Footnote"))
    doc.add(safe_footer(doc))
    return "02-welcome-role-picker", doc


# ------------------------------------------------------------------ 03-05 login
def login(role, accent, accent_soft, icon_name, hint, cta, field1, illustration):
    title = {"Patient": "03 Login - patient", "Doctor": "04 Login - doctor",
             "Admin": "05 Login - admin"}[role]
    doc = page(title, status=False)
    gid = doc.grad("auth-hero", [(0, TEAL_DEEP), (0.55, TEAL), (1, accent)], 0, 0, 1, 1)
    doc.add(rect(0, 0, W, 268, fill=gid, name="Hero"),
            circle(W - 30, 30, 86, fill=WHITE, opacity=0.07, name="Glow 1"),
            circle(30, 250, 62, fill=WHITE, opacity=0.05, name="Glow 2"),
            status_bar(doc, dark=True),
            back_pill(doc, PAGE, STATUS_H + 8))
    doc.add(g("Hero copy",
              text(PAGE, 132, "%s portal" % role, 11, 700, MINT, spacing=1.8, caps=True,
                   name="Eyebrow"),
              text(PAGE, 166, "Welcome back", 28, 800, WHITE, spacing=-0.7, name="Title"),
              para(PAGE, 194, wrap(hint, 42), 12.5, 19, 500, "rgba(255,255,255,0.85)",
                   name="Hint")))
    doc.add(g("Illustration",
              circle(W - 74, 150, 42, fill=WHITE, opacity=0.13, name="Well"),
              icon(illustration, W - 96, 128, 44, WHITE, 1.6, name=icon_name or "art")))

    sheet_top = 250
    doc.add(g("Auth sheet",
              soft_shadow(doc, 0, sheet_top, W, H - sheet_top, R_SHEET, SHADOW, lift=8),
              corner_rect(0, sheet_top, W, H - sheet_top, top=R_SHEET, fill=WHITE,
                         name="Sheet surface"),
              drag_handle(doc, W / 2, sheet_top + 14)))

    y = sheet_top + 54
    doc.add(text(PAGE, y, "%s sign in" % role, 19, 700, INK, name="Form title"), )
    y += 8
    gid2 = doc.grad("underline", [(0, accent), (1, accent_soft)])
    doc.add(line(PAGE, y + 16, PAGE + 62, y + 16, stroke=gid2, sw=3, cap="round",
                 name="Underline"))
    y += 40

    doc.add(field(doc, PAGE, y, W - PAGE * 2, field1[0], value=field1[1],
                  icon_name=field1[2]))
    y += 74
    doc.add(field(doc, PAGE, y, W - PAGE * 2, "Password", value="••••••••",
                  icon_name="lock",
                  suffix=g("IconButton / visibility",
                           icon("eye", W - PAGE - 40, y + 28, 18, INK_MUTED, 1.7, name="Eye"))))
    y += 94
    doc.add(g("Row / helpers",
              rect(PAGE, y - 12, 18, 18, rx=6, fill=MINT_SOFT, stroke=MINT, sw=1.2,
                   name="Checkbox bg"),
              icon("check", PAGE + 3, y - 9, 12, TEAL, 2.4, name="Check"),
              text(PAGE + 26, y + 1, "Keep me signed in", 11.5, 600, INK_BODY, name="Label"),
              text(W - PAGE, y + 1, "Forgot password?", 11.5, 700, TEAL, "end",
                   name="Forgot")))
    y += 30
    doc.add(button(doc, PAGE, y, W - PAGE * 2, 54, cta,
                   gradient=doc.grad("cta", [(0, TEAL), (1, accent)], 0, 0, 1, 0)))
    y += 84
    doc.add(g("Divider",
              line(PAGE, y, W / 2 - 44, y, stroke=DIVIDER, name="L"),
              text(W / 2, y + 4, "secure sign-in", 10, 600, INK_MUTED, "middle",
                   spacing=1.2, caps=True, name="Label"),
              line(W / 2 + 44, y, W - PAGE, y, stroke=DIVIDER, name="R")))
    y += 34
    doc.add(g("Notice",
              rect(PAGE, y, W - PAGE * 2, 52, rx=14, fill=SURFACE_MUTED, name="Notice bg"),
              icon("shield", PAGE + 16, y + 16, 20, TEAL_LIGHT, 1.8, name="Icon"),
              para(PAGE + 46, y + 22, wrap("Your details are only used to open your "
                                           "TrachCare account.", 42), 11, 16, 500,
                   INK_MUTED, name="Copy")))
    doc.add(safe_footer(doc))
    slug = {"03 Login - patient": "03-login-patient",
            "04 Login - doctor": "04-login-doctor",
            "05 Login - admin": "05-login-admin"}[title]
    return slug, doc


def login_patient():
    return login("Patient", TEAL_LIGHT, MINT_SOFT, "user",
                 "Log in to view your therapy plan and daily breathing sessions.",
                 "Sign in", ("Patient ID", "TC-2041", "user"), "heart")


def login_doctor():
    return login("Doctor", SKY, SKY_SOFT, "doctor",
                 "Review your patients, daily vitals and spigotting progress.",
                 "Sign in", ("Doctor ID", "DR-0117", "doctor"), "report")


def login_admin():
    return login("Admin", VIOLET, "#EDE7FB", "shield",
                 "Manage doctors, patients and the therapy video library.",
                 "Sign in", ("Admin ID", "AD-0001", "shield"), "grid")


# ------------------------------------------------------------------ 06 dashboard
def dashboard(doc=None, dim=False):
    doc = doc or page("06 Patient - home dashboard")
    y = gradient_appbar(doc, "Ananya", "Tracheostomy recovery  ·  Day 21")

    y += 18
    # --- spigotting progress card
    ch = 178
    doc.add(card(doc, PAGE, y, W - PAGE * 2, ch, name="Card / Spigotting schedule"))
    doc.add(g("Spigotting card",
              text(PAGE + 18, y + 28, "TODAY'S ROUTINE", 9.5, 700, TEAL_LIGHT,
                   spacing=1.4, caps=True, name="Eyebrow"),
              text(PAGE + 18, y + 50, "Spigotting schedule", 17, 700, INK, name="Title"),
              progress_ring(doc, W - PAGE - 46, y + 44, 25, 3, 5, label="3/5", size=11)))
    yy = y + 74
    doc.add(text(PAGE + 18, yy, "5 sessions  ·  3 attended", 11, 600, INK_MUTED,
                 name="Meta"))
    dots = [("10 AM", "done"), ("12 PM", "done"), ("2 PM", "done"),
            ("4 PM", "open"), ("6 PM", "idle")]
    step = (W - PAGE * 2 - 36) / 5.0
    for i, (lbl, st) in enumerate(dots):
        cx = PAGE + 18 + step * i + step / 2
        cy = yy + 42
        if st == "done":
            doc.add(circle(cx, cy, 11, fill=TEAL, name="Dot %s" % lbl))
            doc.add(icon("check", cx - 5.5, cy - 5.5, 11, WHITE, 2.6, name="Check"))
        elif st == "open":
            doc.add(circle(cx, cy, 17, fill=AMBER_SOFT, name="Open ring"))
            doc.add(circle(cx, cy, 11, fill=WHITE, stroke=AMBER, sw=2.2, name="Dot open"))
            doc.add(circle(cx, cy, 4, fill=AMBER, name="Pulse"))
        else:
            doc.add(circle(cx, cy, 11, fill=SURFACE_ALT, stroke=OUTLINE, sw=1.4,
                           name="Dot idle"))
        doc.add(text(cx, cy + 30, lbl, 9.5, 600, TEAL if st == "open" else INK_MUTED,
                     "middle", name="Time %s" % lbl))
    y += ch + 16

    # --- appointment card
    ch = 104
    gid = doc.grad("appt", [(0, MINT), (1, MINT_SOFT)])
    doc.add(g("Card / Next appointment",
              rect(PAGE, y, W - PAGE * 2, ch, rx=R_CARD, fill=gid, name="bg"),
              circle(PAGE + 42, y + 44, 24, fill=WHITE, name="Doctor photo"),
              icon("doctor", PAGE + 30, y + 32, 24, TEAL, 1.8, name="Doctor glyph"),
              text(PAGE + 78, y + 28, "NEXT APPOINTMENT", 9, 700, TEAL_DEEP, spacing=1.2,
                   caps=True, name="Eyebrow"),
              text(PAGE + 78, y + 48, "Dr. Meera Nair", 16, 700, INK, name="Doctor"),
              text(PAGE + 78, y + 68, "Mon 19 Oct  ·  11:30 AM  ·  ENT OPD", 11.5, 500,
                   INK_BODY, name="When"),
              rect(W - PAGE - 96, y + 20, 80, 30, rx=15, fill=WHITE, name="Chip bg"),
              text(W - PAGE - 56, y + 39, "Reschedule", 10.5, 700, TEAL, "middle",
                   name="Chip label")))
    y += ch + 16

    # --- exercise carousel
    ch = 196
    gid = doc.grad("ex", [(0, "#0B3B34"), (0.5, TEAL), (1, TEAL_LIGHT)], 0, 0, 1, 1)
    doc.add(g("Card / Guided exercise",
              soft_shadow(doc, PAGE, y, W - PAGE * 2, ch, R_CARD, SHADOW_TEAL, lift=6),
              rect(PAGE, y, W - PAGE * 2, ch, rx=R_CARD, fill=gid, name="Thumbnail"),
              circle(PAGE + 250, y + 40, 70, fill=WHITE, opacity=0.08, name="Glow"),
              pth("M %s %s q 30 -34 62 -6 t 60 -10 t 58 14" % (n(PAGE + 40), n(y + 90)),
                  stroke=WHITE, sw=2.4, opacity=0.25, name="Airway line"),
              rect(PAGE, y + 96, W - PAGE * 2, ch - 96, fill=doc.grad(
                  "scrim", [(0, "rgba(7,26,23,0.0)"), (0.35, "rgba(7,26,23,0.72)"),
                            (1, "rgba(7,26,23,0.94)")], 0, 0, 0, 1), rx=0, name="Scrim"),
              text(PAGE + 20, y + 132, "NOW PLAYING LESSON 3 OF 8", 9, 700, MINT,
                   spacing=1.3, caps=True, name="Eyebrow"),
              text(PAGE + 20, y + 156, "Changing your tracheostomy ties", 16, 700,
                   WHITE, name="Title"),
              text(PAGE + 20, y + 176, "4 min  ·  suction-free  ·  do twice daily", 11,
                   500, "rgba(255,255,255,0.75)", name="Meta"),
              circle(W - PAGE - 34, y + 158, 20, fill=WHITE, name="Play button"),
              icon("play", W - PAGE - 41, y + 152, 14, TEAL, name="Play glyph"),
              g("Carousel dots",
                circle(W / 2 - 18, y + ch + 16, 3.5, fill=TEAL, name="Active"),
                circle(W / 2 - 6, y + ch + 16, 3.5, fill=OUTLINE, name="Dot"),
                circle(W / 2 + 6, y + ch + 16, 3.5, fill=OUTLINE, name="Dot"),
                circle(W / 2 + 18, y + ch + 16, 3.5, fill=OUTLINE, name="Dot"))))
    y += ch + 34

    doc.add(nav_bar(doc, [("Home", "home"), ("Therapy", "video"), ("Records", "doc")], 0))
    doc.add(safe_footer(doc))
    if dim:
        doc.add(rect(0, 0, W, H, fill=INK, opacity=0.46, name="Scrim"))
    return doc


def dashboard_screen():
    return "06-patient-home-dashboard", dashboard()


# ------------------------------------------------------------------ 07 spigotting sheet
def spigotting_sheet():
    doc = page("07 Patient - spigotting check-in")
    # dimmed dashboard context, drawn compactly
    y = gradient_appbar(doc, "Ananya", "Tracheostomy recovery  ·  Day 21")
    doc.add(card(doc, PAGE, y + 14, W - PAGE * 2, 150, name="Context / schedule card"))
    doc.add(skeleton(doc, PAGE + 20, y + 34, 130, 12, name="Context line"))
    doc.add(skeleton(doc, PAGE + 20, y + 56, 200, 10, name="Context line"))
    doc.add(skeleton(doc, PAGE + 20, y + 86, 260, 34, 12, name="Context dots"))
    doc.add(skeleton(doc, PAGE, y + 186, W - PAGE * 2, 96, 20, name="Context card"))
    doc.add(skeleton(doc, PAGE, y + 294, W - PAGE * 2, 150, 20, name="Context card"))
    doc.add(nav_bar(doc, [("Home", "home"), ("Therapy", "video"), ("Records", "doc")], 0))
    doc.add(rect(0, 0, W, H, fill=INK, opacity=0.5, name="Scrim"))

    sh = 468
    grp, y = bottom_sheet(doc, sh, "Spigotting check-in")
    doc.add(grp)
    doc.add(g("Sheet header",
              text(PAGE, y + 22, "2 PM session", 9.5, 700, TEAL_LIGHT, spacing=1.4,
                   caps=True, name="Eyebrow"),
              text(PAGE, y + 46, "Spigotting check-in", 20, 700, INK, name="Title"),
              rect(W - PAGE - 34, y + 8, 34, 34, rx=12, fill=SURFACE_MUTED, name="Close bg"),
              icon("close", W - PAGE - 27, y + 15, 18, INK_MUTED, 2.0, name="Close")))
    y += 66
    doc.add(para(PAGE, y, wrap("Did the patient tolerate the spigot without distress?",
                               44), 12.5, 16, 500, INK_BODY, name="Question"))
    y += 34
    w = (W - PAGE * 2 - 12) / 2.0
    for i, (lbl, sub, acc, soft, on) in enumerate([
            ("Yes", "breathing through the nose", TEAL, MINT_SOFT, True),
            ("No", "tube left open for air", CORAL, CORAL_SOFT, False)]):
        x = PAGE + i * (w + 12)
        doc.add(g("Choice / %s" % lbl,
                  rect(x, y, w, 78, rx=16, fill=soft if on else SURFACE_MUTED,
                       stroke=acc if on else OUTLINE, sw=1.8 if on else 1, name="bg"),
                  circle(x + 22, y + 26, 9, fill=WHITE, stroke=acc if on else OUTLINE,
                         sw=1.8, name="Radio"),
                  circle(x + 22, y + 26, 4.5, fill=acc, opacity=1 if on else 0.25,
                         name="Radio dot"),
                  text(x + 38, y + 31, lbl, 15.5, 700, INK, name="Label"),
                  para(x + 16, y + 54, wrap(sub, 24), 10.5, 14, 500, INK_MUTED,
                       name="Sub")))
    y += 100
    doc.add(text(PAGE, y, "How long could the patient keep the spigot in?", 12.5, 500,
                 INK_BODY, name="Question 2"))
    y += 16
    doc.add(field(doc, PAGE, y, W - PAGE * 2 - 96, "", value="12", hint="minutes",
                  icon_name="clock", h=48))
    x = PAGE + (W - PAGE * 2 - 96) + 12
    for i, m in enumerate(["5", "10", "20"]):
        doc.add(rect(x + i * 30, y + 8, 26, 32, rx=10,
                     fill=MINT_SOFT if m == "10" else SURFACE_MUTED,
                     stroke=TEAL if m == "10" else OUTLINE, sw=1.4,
                     name="Quick %s min" % m))
        doc.add(text(x + i * 30 + 13, y + 28, m, 11.5, 700,
                     TEAL if m == "10" else INK_MUTED, "middle", name="Label"))
    y += 68
    doc.add(g("Notice",
              rect(PAGE, y, W - PAGE * 2, 58, rx=14, fill=AMBER_SOFT, name="bg"),
              icon("alert", PAGE + 14, y + 20, 18, "#C97E00", 1.9, name="Icon"),
              para(PAGE + 40, y + 24,
                   wrap("Coughing or breathlessness ends the session - log it, "
                        "don't force it.", 42), 10.5, 14, 600, "#8A5200",
                   name="Copy")))
    y += 74
    doc.add(button(doc, PAGE, y, W - PAGE * 2, 54, "Save check-in", icon_name="check"))
    doc.add(home_indicator(doc))
    return "07-patient-spigotting-sheet", doc


# ------------------------------------------------------------------ 08 therapy list
def videos():
    doc = page("08 Patient - therapy videos")
    y = normal_appbar(doc, "WatchZone", "Guided tracheostomy care at home")
    y += 18
    doc.add(field(doc, PAGE, y - 22, W - PAGE * 2, "", hint="Search lessons",
                  icon_name="search", filled=False, h=50))
    y += 42
    x = PAGE
    for i, (lbl, on) in enumerate([("All", True), ("Tube care", False),
                                   ("Suctioning", False), ("Ties", False)]):
        c, w = chip(doc, x, y, lbl, fg=WHITE if on else INK_BODY,
                    bg=TEAL if on else SURFACE_ALT,
                    icon_name="check" if on else None, h=32, size=12)
        doc.add(c)
        x += w + 8
    y += 52

    lessons = [
        ("Cleaning the inner tube", "5 min  ·  twice daily", "Every second day the inner "
         "tube comes out - rinse, don't scrub.", TEAL, True, 124),
        ("Changing tracheostomy ties", "4 min  ·  daily", "Keep two hands on the tube "
         "while you swap the ties.", SKY, False, 96),
    ]
    for title, meta, desc, acc, fresh, thumb_h in lessons:
        ch = thumb_h + 96
        gid = doc.grad("vt-%s" % uid(title),
                       [(0, "#0B3B34"), (0.6, acc), (1, TEAL_LIGHT)], 0, 0, 1, 1)
        doc.add(soft_shadow(doc, PAGE, y, W - PAGE * 2, ch, R_CARD, SHADOW, lift=5))
        doc.add(g("Video card / %s" % title,
                  rect(PAGE, y, W - PAGE * 2, ch, rx=R_CARD, fill=gid, name="Thumbnail"),
                  circle(PAGE + 240, y + 20, 62, fill=WHITE, opacity=0.08, name="Glow"),
                  pth("M %s %s c 40 -30 80 20 120 -8" % (n(PAGE + 30), n(y + 60)),
                      stroke=WHITE, sw=2, opacity=0.22, name="Waveform"),
                  rect(PAGE, y + thumb_h - 4, W - PAGE * 2, ch - thumb_h + 4, fill=WHITE,
                       rx=0, name="Body"),
                  rect(PAGE, y + ch - 16, W - PAGE * 2, 16, rx=R_CARD, fill=WHITE,
                       name="Body bottom"),
                  circle(PAGE + (W - PAGE * 2) / 2, y + thumb_h / 2 - 6, 26, fill=WHITE,
                         opacity=0.94, name="Play button"),
                  icon("play", PAGE + (W - PAGE * 2) / 2 - 8, y + thumb_h / 2 - 14, 16,
                       TEAL, name="Play glyph"),
                  text(W - PAGE - 46, y + thumb_h / 2 - 22, "HD", 9, 700, WHITE, "middle",
                       opacity=0.75, name="Quality"),
                  text(PAGE + 18, y + thumb_h + 24, title, 16.5, 700, INK, name="Title"),
                  text(PAGE + 18, y + thumb_h + 44, meta, 11, 600, INK_MUTED, name="Meta"),
                  para(PAGE + 18, y + thumb_h + 66, wrap(desc, 52), 11, 15, 500, INK_BODY,
                       name="Description")))
        if fresh:
            c, _ = chip(doc, W - PAGE - 82, y + thumb_h + 14, "New", fg="#8A5200",
                        bg=AMBER_SOFT, icon_name="sparkle", h=26, size=10.5)
            doc.add(c)
        y += ch + 16
    doc.add(g("List hint",
              line(PAGE, y + 6, W - PAGE, y + 6, stroke=DIVIDER, name="Rule"),
              text(W / 2, y + 30, "6 more lessons in your plan", 11.5, 600, INK_MUTED,
                   "middle", name="More")))
    doc.add(nav_bar(doc, [("Home", "home"), ("Therapy", "video"), ("Records", "doc")], 1))
    doc.add(safe_footer(doc))
    return "08-patient-therapy-videos", doc


# ------------------------------------------------------------------ 09 video player
def video_player():
    doc = page("09 Patient - video player", bg="#04100E", status=False)
    doc.add(rect(0, 0, W, H, fill="#04100E", name="Theatre background"))
    doc.add(status_bar(doc, dark=True))
    y = normal_appbar(doc, "WatchZone", "Back to therapy", y=STATUS_H + 4, h=58)
    y += 12
    vw, vh = W - PAGE * 2, (W - PAGE * 2) * 9.0 / 16.0
    gid = doc.grad("frame", [(0, "#0B3B34"), (0.55, TEAL), (1, "#062A25")], 0, 0, 1, 1)
    doc.add(g("Video surface",
              rect(PAGE, y, vw, vh, rx=18, fill=gid, name="Frame"),
              circle(PAGE + vw / 2, y + vh / 2, 30, fill=WHITE, opacity=0.95,
                     name="Play"),
              pth("M %s %s l 13 8 l -13 8 z" % (n(PAGE + vw / 2 - 6), n(y + vh / 2 - 8)),
                  fill=TEAL, name="Play glyph"),
              rect(PAGE, y + vh - 52, vw, 52, fill=doc.grad(
                  "ctrl-scrim", [(0, "rgba(4,16,14,0)"), (1, "rgba(4,16,14,0.85)")],
                  0, 0, 0, 1), name="Control scrim"),
              rect(PAGE + 14, y + vh - 22, vw - 28, 4, rx=2, fill="rgba(255,255,255,0.3)",
                   name="Track"),
              rect(PAGE + 14, y + vh - 22, (vw - 28) * 0.38, 4, rx=2, fill=MINT,
                   name="Buffered"),
              circle(PAGE + 14 + (vw - 28) * 0.38, y + vh - 20, 6, fill=WHITE,
                    name="Thumb"),
              g("Controls row",
                icon("play", PAGE + 14, y + vh - 44, 15, WHITE, name="Play"),
                icon("refresh", PAGE + 48, y + vh - 44, 15, WHITE, name="Replay"),
                rect(PAGE + 82, y + vh - 45, 26, 20, rx=7,
                     fill="rgba(255,255,255,0.16)", name="Speed pill"),
                text(PAGE + 95, y + vh - 31, "1x", 10.5, 700, WHITE, "middle",
                     name="Speed label"),
                text(PAGE + vw - 14, y + vh - 33, "1:32 / 4:05", 10, 600,
                     "rgba(255,255,255,0.75)", "end", name="Timecode"))))
    y += vh + 20
    doc.add(g("Now playing",
              text(PAGE, y, "NOW PLAYING", 9.5, 700, MINT, spacing=1.6, caps=True,
                   name="Eyebrow"),
              text(PAGE, y + 24, "Changing tracheostomy ties", 20, 700, WHITE,
                   name="Title"),
              text(PAGE, y + 44, "Lesson 3 of 8  ·  4 minutes  ·  daily", 11.5, 500,
                   "rgba(255,255,255,0.6)", name="Meta")))
    y += 62
    ch = 118
    doc.add(g("Card / focus",
              rect(PAGE, y, W - PAGE * 2, ch, rx=R_CARD, fill="#0C211D",
                   stroke="rgba(167,219,175,0.16)", sw=1, name="bg"),
              text(PAGE + 18, y + 26, "WHAT TO FOCUS ON", 9, 700, TEAL_LIGHT, spacing=1.3,
                   caps=True, name="Eyebrow"),
              para(PAGE + 18, y + 46, wrap("Wash your hands, prepare the new ties before "
                                           "removing the old ones, and keep one hand on "
                                           "the tube at all times.", 48), 12, 18, 500,
                   "#C9DBD5", name="Body")))
    y += ch + 14
    doc.add(g("Care tip",
              rect(PAGE, y, W - PAGE * 2, 64, rx=16, fill="rgba(46,158,139,0.16)",
                   name="bg"),
              rect(PAGE, y, 4, 64, rx=2, fill=TEAL_LIGHT, name="Accent"),
              icon("info", PAGE + 18, y + 22, 20, MINT, 1.9, name="Icon"),
              para(PAGE + 46, y + 27,
                   wrap("If the patient coughs hard, stop and re-check before "
                        "continuing.", 42), 11, 15, 600, "#D6ECE4", name="Tip")))
    y += 86
    doc.add(g("Footer",
              rect(W / 2 - 30, y, 60, 60, rx=20, fill="#0C211D", name="Logo card"),
              icon("lungs", W / 2 - 15, y + 15, 30, TEAL_LIGHT, 1.7, name="Logo"),
              text(W / 2, y + 82, "Hope this video helps you", 11.5, 600,
                   "rgba(255,255,255,0.55)", "middle", name="Line")))
    doc.add(home_indicator(doc, dark=True))
    return "09-patient-video-player", doc
