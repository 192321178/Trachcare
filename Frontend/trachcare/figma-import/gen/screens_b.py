"""Records, reports, calendar, profile, drawer, notifications, about."""

from svg_kit import *
from ui import *

PATIENT = ("Ananya Rao", "TC-2041")


def mini_dashboard(doc):
    """Compact dashboard used as the dimmed context behind overlays."""
    gradient_appbar(doc, PATIENT[0], "Tracheostomy recovery  ·  Day 21")
    y = 170 + 14
    doc.add(card(doc, PAGE, y, W - PAGE * 2, 150, name="Context / schedule"))
    doc.add(skeleton(doc, PAGE + 20, y + 22, 140, 12, name="Line"))
    doc.add(skeleton(doc, PAGE + 20, y + 46, 210, 10, name="Line"))
    doc.add(skeleton(doc, PAGE + 20, y + 74, 250, 34, 12, name="Dots"))
    doc.add(skeleton(doc, PAGE + 20, y + 118, 180, 10, name="Line"))
    y += 166
    doc.add(skeleton(doc, PAGE, y, W - PAGE * 2, 92, R_CARD, name="Context card"))
    y += 108
    doc.add(skeleton(doc, PAGE, y, W - PAGE * 2, 172, R_CARD, name="Context card"))
    doc.add(nav_bar(doc, [("Home", "home"), ("Therapy", "video"), ("Records", "doc")], 0))
    doc.add(rect(0, 0, W, H, fill=INK, opacity=0.5, name="Scrim"))


# ------------------------------------------------------------------ 10 records
def records():
    doc = page("10 Patient - daily records")
    y = normal_appbar(doc, "Daily records", "Everything your doctor reviews")
    y += 16
    doc.add(patient_header(doc, PAGE, y, W - PAGE * 2, *PATIENT))
    y += 90

    c, _ = chip(doc, W - PAGE - 92, y + 18, "Today logged", fg="#0B6B45",
                bg=SUCCESS_SOFT, icon_name="check", h=28, size=11)
    doc.add(card(doc, PAGE, y, W - PAGE * 2, 104, name="Action / update queries"))
    doc.add(g("Action / update",
              rect(PAGE + 18, y + 22, 46, 46, rx=15, fill=MINT_SOFT, name="Icon chip"),
              icon("doc", PAGE + 30, y + 34, 24, TEAL, 1.8, name="Icon"),
              text(PAGE + 78, y + 40, "Update today's queries", 16, 700, INK, name="Title"),
              text(PAGE + 78, y + 60, "Vitals, dressing, suctioning and spigotting", 11.5,
                   500, INK_MUTED, name="Subtitle"),
              icon("chevron_right", W - PAGE - 32, y + 44, 18, INK_MUTED, 2.0,
                   name="Chevron"), c))
    y += 120

    doc.add(card(doc, PAGE, y, W - PAGE * 2, 92, name="Action / report history"))
    doc.add(g("Action / history",
              rect(PAGE + 18, y + 22, 46, 46, rx=15, fill=SKY_SOFT, name="Icon chip"),
              icon("calendar", PAGE + 30, y + 34, 24, SKY, 1.8, name="Icon"),
              text(PAGE + 78, y + 38, "Report history", 16, 700, INK, name="Title"),
              text(PAGE + 78, y + 58, "21 days recorded  ·  last opened 12 Oct", 11.5,
                   500, INK_MUTED, name="Subtitle"),
              icon("chevron_right", W - PAGE - 32, y + 38, 18, INK_MUTED, 2.0,
                   name="Chevron")))
    y += 108

    doc.add(g("Safety note",
              rect(PAGE, y, W - PAGE * 2, 88, rx=R_CARD, fill=AMBER_SOFT, name="bg"),
              rect(PAGE, y, 4, 88, rx=2, fill=AMBER, name="Accent"),
              icon("alert", PAGE + 20, y + 18, 20, "#B47700", 1.9, name="Icon"),
              text(PAGE + 48, y + 26, "Before you fill this in", 12.5, 700, INK,
                   name="Title"),
              para(PAGE + 20, y + 46, wrap("Take the reading after the patient has rested "
                                           "for 10 minutes. Note anything that felt "
                                           "different today.", 54), 11, 16, 500,
                   "#7A5A18", name="Body")))
    y += 104
    doc.add(g("Medication reminder",
              text(PAGE, y, "TODAY'S MEDICINE", 9.5, 700, INK_MUTED, spacing=1.4,
                   caps=True, name="Eyebrow"),
              text(PAGE, y + 22, "2 of 3 doses taken", 15.5, 700, INK, name="Title")))
    yy = y + 38
    for name, dose, state in [("Saline nebulisation", "twice daily", "done"),
                              ("Mupirocin ointment", "after tie change", "open")]:
        doc.add(list_tile(doc, PAGE, yy, W - PAGE * 2, name, dose, icon_name="pill",
                          badge=g("Status",
                                  rect(W - PAGE - 84, yy + 20, 70, 24, rx=12,
                                       fill=SUCCESS_SOFT if state == "done" else AMBER_SOFT,
                                       name="bg"),
                                  text(W - PAGE - 49, yy + 36,
                                       "Taken" if state == "done" else "Due 8 PM", 10.5,
                                       700, "#0B6B45" if state == "done" else "#B47700",
                                       "middle", name="Label"))))
        yy += 72
    doc.add(nav_bar(doc, [("Home", "home"), ("Therapy", "video"), ("Records", "doc")], 2))
    doc.add(safe_footer(doc))
    return "10-patient-daily-records", doc


# ------------------------------------------------------------------ 11 report form
def report_form():
    doc = page("11 Patient - daily report form")
    y = normal_appbar(doc, "Daily queries", "Day 21  ·  19 Oct")
    y += 14
    doc.add(patient_header(doc, PAGE, y, W - PAGE * 2, *PATIENT, h=66))
    y += 82

    # Vitals
    rows = [("Respiratory rate", "22", "breaths/min"), ("Heart rate", "88", "bpm"),
            ("SPO2 @ room air", "96", "%")]
    ch = 24 + len(rows) * 46 + 14
    doc.add(card(doc, PAGE, y, W - PAGE * 2, ch, fill=SURFACE_MUTED, shadow=False,
                 stroke=DIVIDER, name="Section / Vitals"))
    doc.add(text(PAGE + 16, y + 24, "VITALS", 10, 700, TEAL, spacing=1.4, caps=True,
                 name="Header"))
    ry = y + 38
    for label, val, unit in rows:
        doc.add(g("Field row / %s" % label,
                  text(PAGE + 16, ry + 20, label, 12.5, 600, INK_BODY, name="Label"),
                  rect(W - PAGE - 148, ry, 78, 34, rx=10, fill=WHITE, stroke=OUTLINE,
                       sw=1.2, name="Input"),
                  text(W - PAGE - 138, ry + 22, val, 14, 700, INK, name="Value"),
                  text(W - PAGE - 8, ry + 22, unit, 9.5, 600, INK_MUTED, "end",
                       name="Unit")))
        ry += 46
    y += ch + 12

    # Care checklist
    q = [("Daily dressing done?", 0), ("Tracheostomy tie changed?", 0),
         ("Suctioning done?", 1), ("Started on oral feeds?", 0)]
    extra = 46
    ch = 24 + len(q) * 40 + extra + 14
    doc.add(card(doc, PAGE, y, W - PAGE * 2, ch, name="Section / Care routine"))
    doc.add(text(PAGE + 16, y + 24, "CARE ROUTINE", 10, 700, TEAL, spacing=1.4, caps=True,
                 name="Header"))
    ry = y + 34
    for label, active in q:
        doc.add(g("Question / %s" % label,
                  text(PAGE + 16, ry + 22, label, 12.5, 600, INK_BODY, name="Label"),
                  segmented(doc, W - PAGE - 116, ry + 4, 100, 28, ["Yes", "No"],
                            active=active)))
        ry += 40
    if extra:
        doc.add(g("Conditional field",
                  text(PAGE + 16, ry + 22, "Secretion colour", 11.5, 600, TEAL,
                       name="Label"),
                  rect(W - PAGE - 168, ry + 2, 152, 32, rx=10, fill=MINT_SOFT,
                       stroke=MINT, sw=1.2, name="Input"),
                  text(W - PAGE - 156, ry + 23, "white, thin", 12.5, 600, TEAL_DEEP,
                       name="Value"),
                  icon("chevron_down", W - PAGE - 34, ry + 11, 14, TEAL, 2.0,
                       name="Chevron")))
    y += ch + 12

    # Spigotting dropdown
    doc.add(g("Dropdown / Spigotting status",
              text(PAGE + 16, y + 22, "Spigotting status", 12.5, 700, INK, name="Label"),
              rect(W - PAGE - 176, y, 160, 42, rx=R_FIELD, fill=WHITE, stroke=TEAL,
                   sw=1.6, name="Field"),
              text(W - PAGE - 160, y + 26, "Tolerated 12 min", 13, 600, INK, name="Value"),
              icon("chevron_down", W - PAGE - 34, y + 15, 14, TEAL, 2.0, name="Chevron")))
    y += 56

    doc.add(button(doc, PAGE, y, W - PAGE * 2, 52, "Submit today's report",
                   icon_name="check"))
    y += 66
    doc.add(text(W / 2, y, "Submitting closes the day and notifies Dr. Meera Nair", 10.5,
                 600, INK_MUTED, "middle", name="Helper"))
    doc.add(safe_footer(doc))
    return "11-patient-daily-report-form", doc


# ------------------------------------------------------------------ 12 report view
def report_view():
    doc = page("12 Patient - daily report view")
    y = normal_appbar(doc, "Daily queries report", "12 Oct 2026")
    y += 14
    doc.add(patient_header(doc, PAGE, y, W - PAGE * 2, *PATIENT, h=66))
    y += 82

    tiles = [("droplet", "RESP", "22", "min", TEAL, MINT_SOFT),
             ("heart", "PULSE", "88", "bpm", CORAL, CORAL_SOFT),
             ("lungs", "SPO2", "96", "%", SKY, SKY_SOFT)]
    tw = (W - PAGE * 2 - 16) / 3.0
    for i, (ic, lbl, val, unit, acc, soft) in enumerate(tiles):
        doc.add(stat_tile(doc, PAGE + i * (tw + 8), y, tw, 96, ic, lbl, val, acc, soft,
                          unit=unit, name="Vital / %s" % lbl))
    y += 112

    ch = 216
    doc.add(card(doc, PAGE, y, W - PAGE * 2, ch, name="Card / Care checklist"))
    doc.add(text(PAGE + 18, y + 26, "CARE CHECKLIST", 9.5, 700, INK_MUTED, spacing=1.4,
                 caps=True, name="Header"))
    ry = y + 46
    for label, ans in [("Daily dressing", "Yes"), ("Tracheostomy tie changed", "Yes"),
                       ("Suctioning done", "No"), ("Oral feeds started", "Yes"),
                       ("Changed to green tube", "No"),
                       ("Breathless via nose blocked", "Yes")]:
        ok = ans == "Yes"
        doc.add(g("Answer / %s" % label,
                  text(PAGE + 18, ry, label, 12.5, 600, INK_BODY, name="Label"),
                  rect(W - PAGE - 88, ry - 13, 70, 22, rx=11,
                       fill=SUCCESS_SOFT if ok else DANGER_SOFT, name="Answer bg"),
                  text(W - PAGE - 53, ry + 2.5, ans, 10.5, 700,
                       "#0B6B45" if ok else DANGER, "middle", name="Answer")))
        if ry < y + ch - 40:
            doc.add(line(PAGE + 18, ry + 14, W - PAGE - 18, ry + 14, stroke=DIVIDER,
                         name="Divider"))
        ry += 30
    y += ch + 12

    doc.add(card(doc, PAGE, y, W - PAGE * 2, 118, fill=SURFACE_MUTED, shadow=False,
                 stroke=DIVIDER, name="Card / Notes"))
    yy = y + 30
    for label, val, color in [("Secretion", "white, thin", INK),
                              ("Spigotting", "Tolerated 12 min", TEAL),
                              ("Logged", "19 Oct, 8:12 PM", INK)]:
        doc.add(detail_row(doc, PAGE + 18, yy, W - PAGE * 2 - 36, label, val,
                           value_color=color, rule=label != "Logged",
                           name="Row / %s" % label))
        yy += 30
    y += 134
    doc.add(ghost_button(doc, PAGE, y, (W - PAGE * 2 - 10) / 2, 50, "Earlier days",
                         icon_name="calendar"))
    doc.add(button(doc, PAGE + (W - PAGE * 2 - 10) / 2 + 10, y, (W - PAGE * 2 - 10) / 2,
                   50, "Share with doctor", icon_name="arrow_right",
                   gradient=doc.grad("share", [(0, TEAL), (1, TEAL_LIGHT)])))
    doc.add(safe_footer(doc))
    return "12-patient-daily-report-view", doc


# ------------------------------------------------------------------ 13 calendar
def calendar():
    doc = page("13 Patient - report calendar")
    y = normal_appbar(doc, "Report history", "Pick a day to open its report")
    y += 14
    doc.add(patient_header(doc, PAGE, y, W - PAGE * 2, *PATIENT, h=66))
    y += 82

    ch = 336
    doc.add(card(doc, PAGE, y, W - PAGE * 2, ch, name="Card / Table calendar"))
    doc.add(g("Month header",
              rect(PAGE + 14, y + 16, 32, 32, rx=11, fill=SURFACE_MUTED, name="Prev bg"),
              icon("chevron_left", PAGE + 22, y + 24, 16, INK_BODY, 2.0, name="Prev"),
              text(W / 2, y + 38, "October 2026", 16.5, 700, INK, "middle", name="Month"),
              rect(W - PAGE - 46, y + 16, 32, 32, rx=11, fill=SURFACE_MUTED, name="Next bg"),
              icon("chevron_right", W - PAGE - 38, y + 24, 16, INK_BODY, 2.0, name="Next")))
    gx = PAGE + 18
    gw = (W - PAGE * 2 - 36) / 7.0
    ry = y + 66
    for i, d in enumerate(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]):
        doc.add(text(gx + gw * i + gw / 2, ry, d, 10.5, 700, INK_MUTED, "middle",
                     name="Weekday %s" % d))
    logged = {1, 2, 3, 5, 6, 8, 9, 12, 13, 14, 15, 16, 19, 20}
    selected, today, future = 12, 21, 22
    ry += 26
    first_col = 3  # 1 Oct 2026 falls on a Thursday
    for week in range(5):
        for col in range(7):
            idx = week * 7 + col - first_col + 1
            cx = gx + gw * col + gw / 2
            cy = ry + week * 50 + 16
            if idx < 1 or idx > 31:
                continue
            bg, fg, ring, dot = None, INK_BODY, False, False
            if idx == selected:
                bg, fg = TEAL, WHITE
            elif idx in logged:
                dot, fg = True, TEAL_DEEP
            elif idx >= future:
                fg, ring = INK_MUTED, False
            if idx == today:
                ring = True
            if bg:
                doc.add(circle(cx, cy, 17, fill=bg, name="Day %d selected" % idx))
            if ring:
                doc.add(circle(cx, cy, 17, stroke=AMBER, sw=1.8, name="Day %d today" % idx))
            doc.add(text(cx, cy + 4.5, str(idx), 12.5, 700 if bg else 600, fg, "middle",
                         name="Day %d" % idx))
            if dot:
                doc.add(circle(cx, cy + 12, 2.4, fill=TEAL_LIGHT, name="Dot %d" % idx))
    y += ch + 14

    doc.add(g("Legend",
              circle(PAGE + 6, y, 5, fill=TEAL, name="Swatch logged"),
              text(PAGE + 18, y + 4, "Report submitted", 10.5, 600, INK_MUTED, name="L1"),
              circle(PAGE + 130, y, 5, stroke=AMBER, sw=1.6, fill="none",
                     name="Swatch today"),
              text(PAGE + 142, y + 4, "Today", 10.5, 600, INK_MUTED, name="L2"),
              circle(PAGE + 208, y, 5, fill=OUTLINE, name="Swatch future"),
              text(PAGE + 220, y + 4, "Future", 10.5, 600, INK_MUTED, name="L3")))
    y += 26

    ch = 116
    gid = doc.grad("sel", [(0, MINT_SOFT), (1, WHITE)])
    doc.add(g("Card / Selected day",
              rect(PAGE, y, W - PAGE * 2, ch, rx=R_CARD, fill=gid, stroke=MINT, sw=1.2,
                   name="bg"),
              text(PAGE + 18, y + 26, "SELECTED  ·  MON 12 OCT", 9.5, 700, TEAL_DEEP,
                   spacing=1.3, caps=True, name="Eyebrow"),
              text(PAGE + 18, y + 50, "22 / 88 / 96", 20, 800, INK, name="Vitals"),
              text(PAGE + 18, y + 68, "resp / pulse / SpO2   ·   5 of 6 checks done", 10.5,
                   600, INK_BODY, name="Meta"),
              icon("alert", PAGE + 18, y + 82, 15, AMBER, 2.0, name="Flag icon"),
              text(PAGE + 40, y + 93, "Suctioning missed - secretion noted", 10.5, 600,
                   "#8A5200", name="Flag"),
              rect(W - PAGE - 104, y + 24, 88, 34, rx=13, fill=TEAL, name="Button bg"),
              text(W - PAGE - 60, y + 45, "Open", 12.5, 700, WHITE, "middle",
                   name="Button label")))
    doc.add(safe_footer(doc))
    return "13-patient-report-calendar", doc


# ------------------------------------------------------------------ 14 profile
def profile():
    doc = page("14 Patient - profile", status=False)
    gid = doc.grad("prof-hero", [(0, TEAL_DEEP), (0.6, TEAL), (1, TEAL_LIGHT)],
                   0.1, 0, 0.9, 1)
    doc.add(rect(0, 0, W, 210, fill=gid, name="Hero"),
            circle(W - 26, 26, 78, fill=WHITE, opacity=0.07, name="Glow"),
            status_bar(doc, dark=True),
            back_pill(doc, PAGE, STATUS_H + 6),
            text(W / 2, STATUS_H + 30, "Profile", 17, 700, WHITE, "middle", name="Title"))
    doc.add(corner_rect(0, 186, W, 44, top=26, fill=SURFACE, name="Hero curve"))

    cx = W / 2
    doc.add(g("Avatar block",
              circle(cx, 196, 44, fill=MINT_SOFT, name="Photo"),
              icon("image", cx - 18, 178, 36, TEAL, 1.6, name="Photo glyph"),
              circle(cx, 196, 44, stroke=WHITE, sw=3.5, name="Ring"),
              circle(cx + 32, 218, 13, fill=TEAL, stroke=WHITE, sw=2.5, name="Edit chip"),
              icon("edit", cx + 26, 212, 12, WHITE, 2.2, name="Edit")))
    doc.add(g("Identity",
              text(cx, 274, PATIENT[0], 23, 800, INK, "middle", spacing=-0.4,
                   name="Name"),
              text(cx, 296, "Tracheostomy recovery  ·  Day 21", 12, 500, INK_MUTED,
                   "middle", name="Caption")))
    bx0 = cx - (20 + measure("Verified patient", 11, 700) + 20 + 8 +
                 20 + measure("ID  TC-2041", 11, 700) + 20) / 2
    c1, w1 = chip(doc, bx0, 308, "Verified patient", fg=TEAL, bg=MINT_SOFT,
                  icon_name="check", h=28, size=11)
    c2, _ = chip(doc, bx0 + w1 + 8, 308, "ID  TC-2041", fg="#8A5200", bg=AMBER_SOFT,
                 icon_name="info", h=28, size=11)
    doc.add(g("Badges", c1, c2))

    y = 360
    doc.add(card(doc, PAGE, y, W - PAGE * 2, 214, name="Card / Personal details"))
    doc.add(text(PAGE + 18, y + 26, "PERSONAL DETAILS", 9.5, 700, INK_MUTED, spacing=1.4,
                 caps=True, name="Header"))
    yy = y + 52
    for label, val in [("Age / sex", "34  ·  Female"), ("Phone", "+91 98400 21190"),
                       ("Email", "ananya.rao@mail.com"), ("Diagnosis", "Post-traumatic "
                        "tracheostomy"), ("Primary doctor", "Dr. Meera Nair, ENT")]:
        doc.add(detail_row(doc, PAGE + 18, yy, W - PAGE * 2 - 36, label, val,
                           rule=label != "Primary doctor", icon_name=None,
                           name="Row / %s" % label))
        yy += 32
    y += 230
    doc.add(button(doc, PAGE, y, W - PAGE * 2, 54, "Edit profile", icon_name="edit"))
    y += 70
    doc.add(g("Button / sign out",
              rect(PAGE, y, W - PAGE * 2, 50, rx=R_BUTTON, fill=DANGER_SOFT,
                   stroke="#F3C2CC", sw=1.2, name="bg"),
              icon("logout", W / 2 - 62, y + 17, 16, DANGER, 2.0, name="Icon"),
              text(W / 2 + 10, y + 30, "Sign out", 14.5, 700, DANGER, "middle",
                   name="Label")))
    doc.add(safe_footer(doc))
    return "14-patient-profile", doc


# ------------------------------------------------------------------ 15 edit profile
def edit_profile():
    doc = page("15 Patient - edit profile")
    y = normal_appbar(doc, "Edit profile", "Changes sync to your care team")
    y += 20
    cx = W / 2
    doc.add(g("Avatar editor",
              circle(cx, y + 42, 44, fill=MINT_SOFT, name="Photo"),
              icon("image", cx - 18, y + 24, 36, TEAL, 1.6, name="Glyph"),
              circle(cx, y + 42, 44, stroke=OUTLINE, sw=2, name="Ring"),
              circle(cx + 34, y + 66, 15, fill=TEAL, stroke=WHITE, sw=3, name="Camera chip"),
              icon("camera", cx + 27, y + 59, 14, WHITE, 2.0, name="Camera"),
              text(cx, y + 108, "Change photo", 12.5, 700, TEAL, "middle", name="Action")))
    y += 126

    fields = [("Full name", "Ananya Rao", "user", False),
              ("Email", "ananya.rao@mail.com", "mail", False),
              ("Phone", "+91 98400 21190", "phone", False),
              ("New password", "••••••••", "lock", True)]
    doc.add(card(doc, PAGE, y, W - PAGE * 2, 24 + len(fields) * 66 + 12,
                 fill=SURFACE_MUTED, shadow=False, stroke=DIVIDER,
                 name="Card / Form fields"))
    doc.add(text(PAGE + 16, y + 24, "YOUR DETAILS", 9.5, 700, TEAL, spacing=1.4,
                 caps=True, name="Header"))
    fy = y + 36
    for label, val, ic, secret in fields:
        doc.add(field(doc, PAGE + 16, fy, W - PAGE * 2 - 32, label, value=val,
                      icon_name=ic,
                      suffix=g("IconButton / reveal",
                               icon("eye", W - PAGE - 48, fy + 34, 16, INK_MUTED, 1.7, name="Eye")) if secret else None))
        fy += 66
    y += 24 + len(fields) * 66 + 12 + 18
    doc.add(g("Notice",
              rect(PAGE, y, W - PAGE * 2, 44, rx=14, fill=SKY_SOFT, name="bg"),
              icon("info", PAGE + 14, y + 13, 18, SKY, 1.9, name="Icon"),
              text(PAGE + 40, y + 27, "Password changes sign out other devices", 10.5,
                   600, "#1D5A8C", name="Copy")))
    y += 60
    doc.add(button(doc, PAGE, y, (W - PAGE * 2 - 10) * 0.62, 52, "Save changes",
                   icon_name="check"))
    doc.add(ghost_button(doc, PAGE + (W - PAGE * 2 - 10) * 0.62 + 10, y,
                         (W - PAGE * 2 - 10) * 0.38, 52, "Cancel"))
    doc.add(safe_footer(doc))
    return "15-patient-edit-profile", doc


# ------------------------------------------------------------------ 16 drawer
def drawer():
    doc = overlay_page("16 Patient - navigation drawer")
    mini_dashboard(doc)
    pw = 306
    gid = doc.grad("dw", [(0, TEAL_DEEP), (0.6, TEAL), (1, TEAL_LIGHT)], 0, 0, 1, 1)
    doc.add(g("Overlay / Navigation drawer",
              soft_shadow(doc, 0, 0, pw, H, 0, "rgba(8,71,65,0.35)", lift=6),
              rect(0, 0, pw, H, fill=WHITE, rx=0, name="Drawer surface"),
              rect(0, 0, pw, 158, fill=gid, name="Header gradient"),
              corner_rect(0, 134, pw, 40, top=26, fill=WHITE, name="Header curve"),
              circle(pw - 20, 14, 52, fill=WHITE, opacity=0.07, name="Glow"),
              circle(44, 96, 26, fill=WHITE, name="Photo"),
              icon("user", 30, 82, 28, TEAL, 1.8, name="Silhouette"),
              circle(44, 96, 26, stroke="rgba(255,255,255,0.7)", sw=2, name="Ring"),
              text(82, 92, PATIENT[0], 15.5, 700, WHITE, name="Name"),
              text(82, 112, "Patient ID  TC-2041", 10.5, 500, "rgba(255,255,255,0.8)",
                   name="ID"),
              icon("close", pw - 34, 96, 18, "rgba(255,255,255,0.9)", 2.0, name="Close")))
    y = 186
    items = [("user", "My profile", "Details and care team", False),
             ("doc", "Daily records", "Vitals and checks", False),
             ("calendar", "Report history", "21 days logged", False),
             ("video", "Therapy videos", "8 lessons", False),
             ("bell", "Notifications", "2 unread", True),
             ("info", "About TrachCare", "", False)]
    for ic, title, sub, badge in items:
        doc.add(list_tile(doc, 16, y, pw - 32, title, sub or " ", icon_name=ic, h=56,
                          chevron=True,
                          badge=circle(pw - 44, y + 28, 8, fill=CORAL, name="Unread")
                          if badge else None))
        y += 64
    y += 4
    doc.add(line(24, y, pw - 24, y, stroke=DIVIDER, sw=1.4, name="Divider"))
    y += 18
    doc.add(g("Button / logout",
              rect(16, y, pw - 32, 48, rx=R_BUTTON, fill=DANGER_SOFT, stroke="#F3C2CC",
                   sw=1.2, name="bg"),
              icon("logout", 34, y + 16, 16, DANGER, 2.0, name="Icon"),
              text(58, y + 29, "Sign out", 13.5, 700, DANGER, name="Label")))
    doc.add(text(20, 806, "TrachCare 2.0.0", 10, 600, INK_MUTED, name="Version"))
    doc.add(status_bar(doc, dark=True))
    return "16-patient-navigation-drawer", doc


# ------------------------------------------------------------------ 17 notifications
def notifications():
    doc = overlay_page("17 Patient - notification center")
    mini_dashboard(doc)
    sh = 330
    grp, y = bottom_sheet(doc, sh, "Notification center")
    doc.add(grp)
    doc.add(g("Sheet header",
              text(PAGE, y + 24, "Notification Center", 19, 700, INK, name="Title"),
              rect(W - PAGE - 66, y + 4, 54, 30, rx=15, fill=SURFACE_MUTED,
                   name="Close pill"),
              text(W - PAGE - 39, y + 23.5, "Close", 11.5, 700, INK_BODY, "middle",
                   name="Close label"),
              text(PAGE, y + 44, "2 reminders  ·  today", 11.5, 600, INK_MUTED,
                   name="Subtitle")))
    y += 62
    for title, sub, when, state in [
        ("Spigotting status", "You missed the 4 PM routine", "2 min ago", "open"),
        ("Medication due", "Saline nebulisation - 8 PM dose", "1 hr ago", "done")]:
        doc.add(g("Reminder / %s" % title,
                  rect(PAGE, y, W - PAGE * 2, 84, rx=16, fill=WHITE, stroke=DIVIDER,
                       sw=1.2, name="bg"),
                  rect(PAGE, y, 4.5, 84, rx=2.2,
                       fill=AMBER if state == "open" else TEAL_LIGHT, name="Accent"),
                  circle(PAGE + 34, y + 30, 15,
                         fill=AMBER_SOFT if state == "open" else MINT_SOFT, name="Icon bg"),
                  icon("bell", PAGE + 26, y + 22, 16,
                       "#B47700" if state == "open" else TEAL, 2.0, name="Icon"),
                  text(PAGE + 60, y + 28, title, 14, 700, INK, name="Title"),
                  text(PAGE + 60, y + 47, sub, 11.5, 500, INK_BODY, name="Subtitle"),
                  text(PAGE + 60, y + 66, when, 10, 600, INK_MUTED, name="Time"),
                  icon("close", W - PAGE - 28, y + 14, 14, INK_MUTED, 2.0,
                       name="Swipe hint")))
        y += 96
    doc.add(text(W / 2, y - 2, "Swipe a card left or right to dismiss it", 10.5, 600,
                 INK_MUTED, "middle", name="Hint"))
    doc.add(home_indicator(doc))
    doc.add(status_bar(doc, dark=True))
    return "17-patient-notification-center", doc


# ------------------------------------------------------------------ 18 about
def about():
    doc = page("18 Patient - about", status=False)
    gid = doc.grad("about-hero", [(0, TEAL_DEEP), (0.55, TEAL), (1, TEAL_LIGHT)],
                   0.1, 0, 0.9, 1)
    doc.add(rect(0, 0, W, 268, fill=gid, name="Hero"),
            circle(W - 30, 40, 90, fill=WHITE, opacity=0.07, name="Glow 1"),
            circle(30, 236, 64, fill=WHITE, opacity=0.05, name="Glow 2"),
            status_bar(doc, dark=True),
            back_pill(doc, PAGE, STATUS_H + 6),
            rect(W / 2 - 34, 120, 68, 68, rx=22, fill=WHITE, name="Logo card"),
            icon("lungs", W / 2 - 17, 137, 34, TEAL, 1.7, name="Logo"),
            text(W / 2, 220, "About TrachCare", 22, 800, WHITE, "middle", spacing=-0.4,
                 name="Title"),
            text(W / 2, 244, "Why this app exists, and what it does", 12, 500,
                 "rgba(255,255,255,0.8)", "middle", name="Subtitle"))
    doc.add(corner_rect(0, 254, W, 44, top=26, fill=SURFACE, name="Hero curve"))

    y = 300
    sections = [
        ("What is a tracheostomy?", "lungs", True,
         "A tracheostomy is a surgical airway created through the neck, often needed "
         "after respiratory failure or trauma. After the operation, daily airway "
         "management prevents complications - and doing that well at home is hard."),
        ("Mobile health in tracheostomy care", "video", False, ""),
        ("What TrachCare includes", "play_circle", False, ""),
        ("Empowering patients and caregivers", "heart", False, ""),
        ("Research and evaluation", "report", False, ""),
    ]
    for i, (title, ic, open_, body) in enumerate(sections):
        lines = wrap(body, 46) if open_ else []
        h = 58 if not open_ else 58 + 12 + len(lines) * 17 + 16
        doc.add(card(doc, PAGE, y, W - PAGE * 2, h, fill=WHITE, shadow=True,
                     name="Expansion %d / %s" % (i + 1, title)))
        doc.add(g("Expansion / %s" % title,
                  rect(PAGE + 16, y + 12, 34, 34, rx=12, fill=MINT_SOFT,
                       name="Icon chip"),
                  icon(ic, PAGE + 25, y + 21, 17, TEAL, 1.9, name="Icon"),
                  text(PAGE + 60, y + 34, title, 14.5, 700, INK, name="Title"),
                  icon("chevron_down" if open_ else "chevron_right", W - PAGE - 34,
                       y + 21, 16, INK_MUTED, 2.0, name="Chevron")))
        if open_:
            doc.add(line(PAGE + 60, y + 56, W - PAGE - 20, y + 56, stroke=DIVIDER,
                         name="Rule"))
            doc.add(para(PAGE + 16, y + 78, lines, 12, 17, 500, INK_BODY,
                         name="Body"))
        y += h + 10
    doc.add(g("Footer",
              text(W / 2, y + 14, "TrachCare  ·  version 2.0.0", 11, 600, INK_MUTED,
                   "middle", name="Version"),
              text(W / 2, y + 32, "Made for post-operative tracheostomy care at home",
                   10.5, 500, INK_MUTED, "middle", name="Tagline")))
    doc.add(safe_footer(doc))
    return "18-patient-about", doc
