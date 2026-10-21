"""19-27 Doctor flow: shell tabs, chart, day report, calendar, forms, profile."""

from svg_kit import *
from ui import *
from role_kit import *

DOCTOR = "Dr. Meera Nair"
PATIENT = ("Ananya Rao", "TC-2041")
LOGGED = {1, 2, 3, 5, 6, 8, 9, 12, 13, 14, 15, 16, 19, 20}


# ------------------------------------------------------------------ 19 overview
def overview():
    doc = page("19 Doctor - overview")
    y = role_appbar(doc, DOCTOR, notif=3)
    y += 22

    sh, y = section_header(doc, PAGE, y, W - PAGE * 2, "Patient updates",
                           eyebrow_text="Today")
    doc.add(sh)
    y += 14
    ch = 126
    doc.add(card(doc, PAGE, y, W - PAGE * 2, ch, name="Card / Update strip"))
    names = [("Ananya", "8:12 AM", True), ("Ravi", "7:50 AM", False),
             ("Lakshmi", "7:31 AM", False), ("Imran", "Yest", False)]
    step = (W - PAGE * 2 - 24) / 4.0
    for i, (nm, when, alarm) in enumerate(names):
        cx = PAGE + 12 + step * i + step / 2
        parts = [circle(cx, y + 40, 24, fill=CORAL_SOFT if alarm else MINT_SOFT,
                        name="Bubble bg"),
                 icon("user", cx - 14, y + 26, 28, CORAL if alarm else TEAL, 1.7,
                      name="Photo"),
                 circle(cx, y + 40, 24, stroke=WHITE, sw=2, name="Ring"),
                 text(cx, y + 76, nm, 10.5, 700, INK, "middle", name="Name"),
                 text(cx, y + 90, when, 9.5, 600, INK_MUTED, "middle", name="Time")]
        if alarm:
            parts.append(circle(cx + 17, y + 23, 7.5, fill=CORAL, stroke=WHITE, sw=2,
                                name="Alert dot"))
        doc.add(g("Update / %s" % nm, *parts))
    y += ch + 16

    w = (W - PAGE * 2 - 12) / 2.0
    doc.add(shortcut_card(doc, PAGE, y, w, 104, "edit", "Add patient",
                          "Start a new chart", accent=TEAL, soft=MINT_SOFT))
    doc.add(shortcut_card(doc, PAGE + w + 12, y, w, 104, "user", "My patients",
                          "12 on your list", accent=SKY, soft=SKY_SOFT))
    y += 104 + 22

    trailing = text(W - PAGE, y + 2, "See all", 11.5, 700, TEAL, "end",
                    name="Trailing")
    sh, y = section_header(doc, PAGE, y, W - PAGE * 2, "Therapy videos",
                           eyebrow_text="WatchZone", trailing=trailing)
    doc.add(sh)
    y += 14
    vw = (W - PAGE * 2 - 12) / 2.0
    doc.add(video_tile(doc, PAGE, y, vw, 194, "Clean the tube",
                       "5 min  ·  twice daily"))
    doc.add(video_tile(doc, PAGE + vw + 12, y, vw, 194, "Trach tie change",
                       "4 min  ·  daily", accent=SKY, fresh=True))
    y += 194 + 18
    doc.add(scroll_hint(doc, y, "Swipe for 8 more lessons"))

    doc.add(nav_bar(doc, DOCTOR_TABS, 0))
    doc.add(safe_footer(doc))
    return "19-doctor-overview", doc


# ------------------------------------------------------------------ 20 patients
def patients():
    doc = page("20 Doctor - my patients")
    y = role_appbar(doc, DOCTOR, "3 patients logged today", notif=3)
    y += 20
    doc.add(search_box(doc, y, "Search patients by name"))
    y += 66
    doc.add(roster_count(doc, y, "12 records"))
    y += 22
    rows = [("Ananya Rao", "Patient ID TC-2041", "Chart", True),
            ("Ravi Menon", "Patient ID TC-2044", "Chart", False),
            ("Lakshmi Iyer", "Patient ID TC-2051", "Chart", False),
            ("Imran Sheikh", "Patient ID TC-2063", "Chart", False)]
    for title, sub, chip_label, alarm in rows:
        doc.add(roster_tile(doc, y, title, sub, chip_label, accent=SKY,
                            soft=SKY_SOFT, alarm=alarm))
        y += 88
    doc.add(text(W / 2, y + 6, "Pull down to refresh the list", 10.5, 600, INK_MUTED,
                 "middle", name="Footer"))

    doc.add(nav_bar(doc, DOCTOR_TABS, 2))
    doc.add(safe_footer(doc))
    return "20-doctor-patients-list", doc


# ------------------------------------------------------------------ 21 chart
def _chart(doc):
    y = normal_appbar(doc, "Patient chart", "%s  ·  %s" % (PATIENT[0], PATIENT[1]))
    y += 14
    tiles = [("wind", "RESP", "22", "min", TEAL, MINT_SOFT),
             ("heart", "PULSE", "88", "bpm", CORAL, CORAL_SOFT),
             ("droplet", "SPO2", "96", "%", SKY, SKY_SOFT)]
    tw = (W - PAGE * 2 - 16) / 3.0
    for i, (ic, lbl, val, unit, acc, soft) in enumerate(tiles):
        doc.add(stat_tile(doc, PAGE + i * (tw + 8), y, tw, 96, ic, lbl, val, acc, soft,
                          unit=unit, name="Vital / %s" % lbl))
    y += 112

    identity = [("Age / sex", "34  ·  Female", "user"),
                ("Next appointment", "Mon 19 Oct", "calendar", TEAL)]
    doc.add(detail_group(doc, y, "Identity", identity))
    y += detail_group_h(identity) + 38

    airway = [("BMI", "24.6", "heart"),
              ("Diagnosis", "Post-traumatic", "doc"),
              ("Tube name size", "Shiley #6", "shield")]
    doc.add(detail_group(doc, y, "Airway and surgical plan", airway))
    y += detail_group_h(airway) + 38

    labs = [("Haemoglobin", "12.4 g/dL", "droplet"),
            ("INR", "1.05", "droplet")]
    doc.add(detail_group(doc, y, "Blood work", labs))
    y += detail_group_h(labs) + 30

    doc.add(button(doc, PAGE, y, (W - PAGE * 2 - 10) * 0.66, 52,
                   "Daily reports", icon_name="calendar",
                   gradient=doc.grad("daily", [(0, AMBER), (1, "#FFC86B")],
                                     0, 0, 1, 1), fg=TEAL_DEEP))
    doc.add(ghost_button(doc, PAGE + (W - PAGE * 2 - 10) * 0.66 + 10, y,
                         (W - PAGE * 2 - 10) * 0.34, 52, "Delete", fg=DANGER,
                         bg=DANGER_SOFT, icon_name="trash"))
    y += 68
    doc.add(scroll_hint(doc, y, "9 lab values and notes below"))


def chart():
    doc = page("21 Doctor - patient chart")
    _chart(doc)
    doc.add(safe_footer(doc))
    return "21-doctor-patient-chart", doc


# ------------------------------------------------------------------ 22 day report
def day_report():
    doc = page("22 Doctor - daily report")
    y = normal_appbar(doc, "Daily updates", "Ananya Rao  ·  12 Oct 2026")
    y += 14
    tiles = [("wind", "RESP", "22", "min", TEAL, MINT_SOFT),
             ("heart", "PULSE", "88", "bpm", CORAL, CORAL_SOFT),
             ("droplet", "SPO2", "96", "%", SKY, SKY_SOFT)]
    tw = (W - PAGE * 2 - 16) / 3.0
    for i, (ic, lbl, val, unit, acc, soft) in enumerate(tiles):
        doc.add(stat_tile(doc, PAGE + i * (tw + 8), y, tw, 96, ic, lbl, val, acc, soft,
                          unit=unit, name="Vital / %s" % lbl))
    y += 112

    checks = [("Daily dressing done", "Yes"), ("Tracheostomy tie changed", "Yes"),
              ("Suctioning done", "No"), ("Secretion colour", "Not answered")]
    ch = 40 + len(checks) * 40 + 8
    doc.add(card(doc, PAGE, y, W - PAGE * 2, ch, name="Card / Airway care"))
    doc.add(text(PAGE + 18, y + 26, "AIRWAY CARE", 9.5, 700, INK_MUTED, spacing=1.4,
                 caps=True, name="Header"))
    ry = y + 48
    for label, ans in checks:
        doc.add(answer_badge(doc, ry, label, ans))
        if ry < y + ch - 44:
            doc.add(line(PAGE + 18, ry + 14, W - PAGE - 18, ry + 14, stroke=DIVIDER,
                         name="Divider"))
        ry += 40
    y += ch + 14

    trial = [("Oral feeds started", "Yes"), ("Cough or breathlessness", "No"),
             ("Breathes via nose", "Yes")]
    ch = 40 + len(trial) * 40 + 8
    doc.add(card(doc, PAGE, y, W - PAGE * 2, ch, fill=SURFACE_MUTED, shadow=False,
                 stroke=DIVIDER, name="Card / Feeding and breathing"))
    doc.add(text(PAGE + 18, y + 26, "FEEDING AND BREATHING TRIAL", 9.5, 700,
                 TEAL, spacing=1.4, caps=True, name="Header"))
    ry = y + 48
    for i, (label, ans) in enumerate(trial):
        doc.add(answer_badge(doc, ry, label, ans, w=W - PAGE * 2))
        if i < len(trial) - 1:
            doc.add(line(PAGE + 18, ry + 14, W - PAGE - 18, ry + 14, stroke=DIVIDER,
                         name="Divider"))
        ry += 40
    y += ch + 18

    doc.add(g("Note / breath duration",
              rect(PAGE, y, W - PAGE * 2, 56, rx=16, fill=WHITE, stroke=MINT, sw=1.4,
                   name="bg"),
              icon("clock", PAGE + 16, y + 18, 20, TEAL, 1.9, name="Icon"),
              text(PAGE + 44, y + 25, "Breath duration, tube blocked", 12, 600,
                   INK_BODY, name="Label"),
              text(W - PAGE - 16, y + 34, "12 minutes", 13.5, 700, TEAL, "end",
                   name="Value")))
    y += 72
    doc.add(text(W / 2, y, "Submitted 12 Oct, 8:12 PM by the caregiver", 10.5, 600,
                 INK_MUTED, "middle", name="Meta"))
    doc.add(safe_footer(doc))
    return "22-doctor-daily-report", doc


# ------------------------------------------------------------------ 23 calendar
def calendar():
    doc = page("23 Doctor - report calendar")
    y = normal_appbar(doc, "Daily query reports", "Ananya Rao  ·  pick a day")
    y += 14
    doc.add(patient_header(doc, PAGE, y, W - PAGE * 2, *PATIENT, h=66))
    y += 82

    grp, y = month_calendar(doc, y, "October 2026", LOGGED, selected=12, today=16,
                            first_col=3, future_from=17)
    doc.add(grp)
    y += 18
    doc.add(calendar_legend(doc, y))
    y += 28

    ch = 112
    gid = doc.grad("sel-day", [(0, MINT_SOFT), (1, WHITE)])
    doc.add(g("Card / Selected day",
              rect(PAGE, y, W - PAGE * 2, ch, rx=R_CARD, fill=gid, stroke=MINT,
                   sw=1.2, name="bg"),
              text(PAGE + 18, y + 26, "SELECTED  ·  MON 12 OCT", 9.5, 700, TEAL_DEEP,
                   spacing=1.3, caps=True, name="Eyebrow"),
              text(PAGE + 18, y + 50, "22 / 88 / 96", 20, 800, INK, name="Vitals"),
              text(PAGE + 18, y + 68, "resp / pulse / SpO2   ·   5 of 6 checks", 10.5,
                   600, INK_BODY, name="Meta"),
              icon("alert", PAGE + 18, y + 80, 15, AMBER, 2.0, name="Flag icon"),
              text(PAGE + 40, y + 92, "Suctioning missed - secretion blank", 10.5,
                   600, "#8A5200", name="Flag"),
              rect(W - PAGE - 104, y + 22, 88, 34, rx=13, fill=TEAL, name="Button bg"),
              text(W - PAGE - 60, y + 43, "Open", 12.5, 700, WHITE, "middle",
                   name="Button label")))
    doc.add(safe_footer(doc))
    return "23-doctor-report-calendar", doc


# ------------------------------------------------------------------ 24 add patient
def add_patient():
    doc = page("24 Doctor - add patient")
    y = normal_appbar(doc, "Add patient", "Create a chart and assign it to you")
    y += 16
    doc.add(photo_picker(doc, y, "Tap to add the patient photo"))
    y += 120

    grp, y = form_card(doc, y, "Identity and contact",
                       [("Name", "Ananya Rao", "user"),
                        ("Age", "34", "clock"),
                        ("Phone", "+91 98400 21190", "phone")])
    doc.add(grp)
    y += 14

    grp, y = form_card(doc, y, "Airway and surgical plan",
                       [("Diagnosis", "Post-traumatic", "doc"),
                        ("Tube name and size", "Shiley #6", "shield")])
    doc.add(grp)
    y += 22
    doc.add(text(PAGE + 4, y, "BASELINE VITALS AND BLOOD WORK FOLLOW BELOW", 9.5,
                 700, INK_MUTED, spacing=1.2, name="More"))
    y += 22
    doc.add(button(doc, PAGE, y, W - PAGE * 2, 54, "Save patient", icon_name="check"))
    doc.add(safe_footer(doc))
    return "24-doctor-add-patient", doc


# ------------------------------------------------------------------ 25 videos tab
def videos():
    doc = page("25 Doctor - therapy videos")
    y = role_appbar(doc, DOCTOR, "8 lessons published", notif=0)
    y += 20
    c, _ = chip(doc, PAGE, y, "Exercise library", fg=VIOLET, bg="#EDE7FB",
                icon_name="sparkle", h=28, size=11)
    doc.add(c)
    y += 44
    doc.add(search_box(doc, y, "Search lessons", value="tube"))
    y += 66
    ch = 236
    for i, (title, meta, acc, fresh) in enumerate([
            ("Cleaning the inner tube", "5 min  ·  twice daily", TEAL, True)]):
        gid = doc.grad("dl-%s" % uid(title), [(0, "#0B3B34"), (0.6, acc),
                                             (1, TEAL_LIGHT)], 0, 0, 1, 1)
        th = 142
        doc.add(soft_shadow(doc, PAGE, y, W - PAGE * 2, ch, R_CARD, SHADOW, lift=5))
        doc.add(g("Video card / %s" % title,
                  rect(PAGE, y, W - PAGE * 2, ch, rx=R_CARD, fill=gid, name="Thumbnail"),
                  circle(PAGE + 250, y + 24, 62, fill=WHITE, opacity=0.08, name="Glow"),
                  pth("M %s %s c 40 -30 80 20 120 -8" % (n(PAGE + 30), n(y + 70)),
                      stroke=WHITE, sw=2, opacity=0.22, name="Waveform"),
                  rect(PAGE, y + th, W - PAGE * 2, ch - th, fill=WHITE, name="Body"),
                  rect(PAGE, y + ch - 16, W - PAGE * 2, 16, rx=R_CARD, fill=WHITE,
                       name="Body bottom"),
                  circle(PAGE + (W - PAGE * 2) / 2, y + th / 2 - 4, 26, fill=WHITE,
                         opacity=0.94, name="Play button"),
                  icon("play", PAGE + (W - PAGE * 2) / 2 - 8, y + th / 2 - 12, 16,
                       TEAL, name="Play glyph"),
                  text(PAGE + 18, y + th + 30, title, 16.5, 700, INK, name="Title"),
                  text(PAGE + 18, y + th + 50, meta, 11, 600, INK_MUTED, name="Meta"),
                  para(PAGE + 18, y + th + 74,
                       wrap("Rinse the inner cannula, never scrub it. Every second "
                            "day.", 50), 11, 15, 500, INK_BODY, name="Description")))
        if fresh:
            cc, _ = chip(doc, W - PAGE - 82, y + th + 18, "New", fg="#8A5200",
                         bg=AMBER_SOFT, icon_name="sparkle", h=26, size=10.5)
            doc.add(cc)
        y += ch + 16
    for title, meta in [("Changing tracheostomy ties", "4 min  ·  daily"),
                        ("Suctioning at home", "6 min  ·  as needed")]:
        doc.add(list_tile(doc, PAGE, y, W - PAGE * 2, title, meta, icon_name="video",
                          h=68))
        y += 80
    doc.add(nav_bar(doc, DOCTOR_TABS, 1))
    doc.add(safe_footer(doc))
    return "25-doctor-therapy-videos", doc


# ------------------------------------------------------------------ 26 profile
def profile():
    doc = page("26 Doctor - profile")
    y = normal_appbar(doc, "My profile", "Your clinician record")
    y += 16
    doc.add(profile_hero(doc, y, DOCTOR, "Registered practitioner",
                         "Doctor ID  DR-0117", glyph="doctor", h=206))
    y += 222

    contact = [("Email", "meera.nair@clinic.in", "mail"),
               ("Phone", "+91 98400 21190", "phone")]
    doc.add(detail_group(doc, y, "Contact", contact))
    y += detail_group_h(contact) + 38

    creds = [("Registration no.", "MN-4412 IND", "shield"),
             ("Display name", DOCTOR, "user")]
    doc.add(detail_group(doc, y, "Credentials", creds))
    y += detail_group_h(creds) + 34

    doc.add(notice(doc, y, "Passwords stay hidden",
                   "Set a new one from the edit screen.", h=68))
    y += 80
    doc.add(button(doc, PAGE, y, W - PAGE * 2, 54, "Edit details", icon_name="edit"))
    doc.add(safe_footer(doc))
    return "26-doctor-profile", doc


# ------------------------------------------------------------------ 27 edit profile
def edit_profile():
    doc = page("27 Doctor - edit profile")
    y = normal_appbar(doc, "Edit profile", "Changes apply next sign-in")
    y += 16
    doc.add(photo_picker(doc, y, "Change picture  ·  camera or gallery"))
    y += 120
    grp, y = form_card(doc, y, "Your details",
                       [("Display name", "Dr. Meera Nair", "user"),
                        ("Registration number", "MN-4412 IND", "shield"),
                        ("Email", "meera.nair@clinic.in", "mail"),
                        ("Phone number", "+91 98400 21190", "phone"),
                        ("Password", "••••••••", "lock", "secret")])
    doc.add(grp)
    y += 22
    doc.add(button(doc, PAGE, y, (W - PAGE * 2 - 10) * 0.62, 52, "Save changes",
                   icon_name="check"))
    doc.add(ghost_button(doc, PAGE + (W - PAGE * 2 - 10) * 0.62 + 10, y,
                         (W - PAGE * 2 - 10) * 0.38, 52, "Cancel"))
    doc.add(safe_footer(doc))
    return "27-doctor-edit-profile", doc
