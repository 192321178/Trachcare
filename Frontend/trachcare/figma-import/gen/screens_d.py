"""28-36 Admin flow: console, rosters, clinician record, upload, profile."""

from svg_kit import *
from ui import *
from role_kit import *
from screens_c import _chart

ADMIN = "Priya Raman"
PATIENT = ("Ananya Rao", "TC-2041")
LOGGED = {1, 2, 3, 5, 6, 8, 9, 12, 13, 14, 15, 16, 19, 20}


def pick_tile(doc, y, label, sub, icon_name, accent=VIOLET, chosen=False,
              thumb=False):
    w = W - PAGE * 2
    bg = MINT_SOFT if chosen else SURFACE
    stroke = MINT if chosen else OUTLINE
    parts = [soft_shadow(doc, PAGE, y, w, 78, 18, SHADOW, lift=3),
             rect(PAGE, y, w, 78, rx=18, fill=bg, stroke=stroke,
                  sw=1.5 if chosen else 1.2, name="Tile bg"),
             rect(PAGE + 14, y + 15, 48, 48,
                  rx=14, fill=accent if chosen else SURFACE_ALT, name="Icon chip"),
             icon(icon_name, PAGE + 25, y + 26, 26, WHITE if chosen else accent, 1.8,
                  name="Icon"),
             text(PAGE + 74, y + 34, label, 14.5, 700, INK, name="Title"),
             text(PAGE + 74, y + 54, sub, 11, 600, INK_MUTED, name="Hint"),
             icon("check" if chosen else "arrow_right", W - PAGE - 32, y + 30, 20,
                  SUCCESS if chosen else accent, 2.1, name="State")]
    if thumb:
        parts.append(rect(PAGE + 14, y + 15, 48, 48, rx=14, fill=TEAL_DEEP,
                          name="Thumbnail"))
        parts.append(icon("image", PAGE + 25, y + 26, 26, MINT, 1.6, name="Still"))
    return g("Pick tile / %s" % label, *parts)


# ------------------------------------------------------------------ 28 console
def console():
    doc = page("28 Admin - console")
    y = role_appbar(doc, ADMIN, export=True, stops=ADMIN_STOPS)
    y += 22
    sh, y = section_header(doc, PAGE, y, W - PAGE * 2, "What needs managing?",
                           eyebrow_text="Console")
    doc.add(sh)
    y += 12
    doc.add(text(PAGE, y, "Doctors, patients and the therapy library", 11.5, 600,
                 INK_MUTED, name="Subtitle"))
    y += 24

    tiles = [("user", "DOCTORS", "42", VIOLET, "#EDE7FB"),
             ("shield", "PATIENTS", "318", SKY, SKY_SOFT),
             ("video", "LESSONS", "24", TEAL, MINT_SOFT)]
    tw = (W - PAGE * 2 - 16) / 3.0
    for i, (ic, lbl, val, acc, soft) in enumerate(tiles):
        doc.add(stat_tile(doc, PAGE + i * (tw + 8), y, tw, 96, ic, lbl, val, acc, soft,
                          name="Stat / %s" % lbl))
    y += 112

    dests = [("user", "Doctors", "Every clinician with clinic access", "Open",
              VIOLET, "#EDE7FB"),
             ("doc", "Patients", "Records submitted from home", "Open", SKY, SKY_SOFT),
             ("video", "Therapy videos", "Publish a lesson to WatchZone", "Add",
              TEAL, MINT_SOFT)]
    for ic, title, sub, chip_label, acc, soft in dests:
        w = W - PAGE * 2
        doc.add(g("Destination / %s" % title,
                  soft_shadow(doc, PAGE, y, w, 76, 18, SHADOW, lift=4),
                  rect(PAGE, y, w, 76, rx=18, fill=WHITE, name="bg"),
                  rect(PAGE + 16, y + 16, 44, 44, rx=15, fill=soft, name="Icon chip"),
                  icon(ic, PAGE + 27, y + 27, 22, acc, 1.9, name="Icon"),
                  text(PAGE + 74, y + 34, title, 15.5, 700, INK, name="Title"),
                  text(PAGE + 74, y + 54, sub, 11, 600, INK_MUTED, name="Subtitle")))
        c, cw = chip(doc, 0, 0, chip_label, fg=acc, bg=soft, h=28, size=11)
        doc.add(g("Chip / %s" % chip_label, c,
                  transform="translate(%s %s)" % (n(W - PAGE - cw - 16), n(y + 24))))
        y += 88

    doc.add(g("Card / Export",
              rect(PAGE, y, W - PAGE * 2, 88, rx=R_CARD, fill=AMBER_SOFT, name="bg"),
              rect(PAGE, y, 4.5, 88, rx=2.2, fill=AMBER, name="Accent"),
              rect(PAGE + 20, y + 22, 44, 44, rx=15, fill=WHITE, name="Icon chip"),
              icon("doc", PAGE + 31, y + 33, 22, AMBER, 1.9, name="Icon"),
              text(PAGE + 78, y + 40, "Export everything", 15, 700, INK, name="Title"),
              text(PAGE + 78, y + 60, "One CSV of all patient records", 11, 600,
                   "#7A5A18", name="Subtitle"),
              icon("arrow_right", W - PAGE - 34, y + 34, 20, "#B47700", 2.0,
                   name="Go")))

    doc.add(nav_bar(doc, ADMIN_TABS, 0))
    doc.add(safe_footer(doc))
    return "28-admin-console", doc


# ------------------------------------------------------------------ 29 doctors
def doctors():
    doc = page("29 Admin - doctors list")
    y = normal_appbar(doc, "Medical team", "Clinicians with clinic access")
    y += 20
    doc.add(search_box(doc, y, "Search doctors by name", value="meera"))
    y += 66
    doc.add(roster_count(doc, y, "3 records of 42"))
    y += 22
    rows = [("Dr. Meera Nair", "Doctor ID DR-0117", "Open"),
            ("Dr. Arjun Pillai", "Doctor ID DR-0124", "Open"),
            ("Dr. Sara Thomas", "Doctor ID DR-0131", "Open")]
    for title, sub, chip_label in rows:
        doc.add(roster_tile(doc, y, title, sub, chip_label))
        y += 88
    doc.add(text(W / 2, y + 26, "Pull down to refresh the list", 10.5, 600,
                 INK_MUTED, "middle", name="Footer"))
    doc.add(safe_footer(doc))
    return "29-admin-doctors-list", doc


# ------------------------------------------------------------------ 30 doctor detail
def doctor_detail():
    doc = page("30 Admin - doctor detail")
    y = normal_appbar(doc, "Doctor profile", "Read-only clinic record")
    y += 16
    doc.add(g("IconButton / remove",
              rect(W - PAGE - 40, STATUS_H + 22, 40, 40, rx=14,
                   fill="rgba(255,255,255,0.18)", name="bg"),
              icon("trash", W - PAGE - 30, STATUS_H + 32, 20, WHITE, 2.0,
                   name="Remove glyph")))
    doc.add(profile_hero(doc, y, "Dr. Meera Nair", "Registered practitioner",
                         "Doctor ID  DR-0117", glyph="doctor", h=206))
    y += 222

    contact = [("Email", "meera.nair@clinic.in", "mail"),
               ("Phone", "+91 98400 21190", "phone")]
    doc.add(detail_group(doc, y, "Contact", contact))
    y += detail_group_h(contact) + 38

    creds = [("Registration no.", "MN-4412 IND", "shield"),
             ("Display name", "Dr. Meera Nair", "user")]
    doc.add(detail_group(doc, y, "Credentials", creds))
    y += detail_group_h(creds) + 34

    doc.add(button(doc, PAGE, y, W - PAGE * 2, 54, "Edit details", icon_name="edit"))
    y += 66
    doc.add(button(doc, PAGE, y, W - PAGE * 2, 54, "Their patients", icon_name="user",
                   gradient=doc.grad("skybtn", [(0, SKY), (1, "#6BA8DB")],
                                     0, 0, 1, 1)))
    doc.add(safe_footer(doc))
    return "30-admin-doctor-detail", doc


# ------------------------------------------------------------------ 31 add doctor
def add_doctor():
    doc = page("31 Admin - add doctor")
    y = role_appbar(doc, ADMIN, "Team management", stops=ADMIN_STOPS)
    y += 20
    sh, y = section_header(doc, PAGE, y, W - PAGE * 2, "Add a doctor",
                           eyebrow_text="Team")
    doc.add(sh)
    y += 6
    doc.add(text(PAGE, y, "They sign in with this email and password", 11, 600,
                 INK_MUTED, name="Subtitle"))
    y += 26
    doc.add(photo_picker(doc, y, "Tap to add a photo", accent=VIOLET,
                         soft="#EDE7FB", glyph="doctor", h=84))
    y += 100
    grp, y = form_card(doc, y, "Clinician details",
                       [("Display name", "Dr. Sara Thomas", "user"),
                        ("Registration no.", "ST-7710 IND", "shield"),
                        ("Email", "sara.thomas@clinic.in", "mail"),
                        ("Temporary password", "••••••••", "lock", "secret")])
    doc.add(grp)
    y += 16
    doc.add(button(doc, PAGE, y, W - PAGE * 2, 52, "Create doctor", icon_name="check",
                   gradient=doc.grad("adddoc", [(0, VIOLET), (1, "#9C82E4")],
                                     0, 0, 1, 1)))
    doc.add(nav_bar(doc, ADMIN_TABS, 1))
    doc.add(safe_footer(doc))
    return "31-admin-add-doctor", doc


# ------------------------------------------------------------------ 32 patients
def patients():
    doc = page("32 Admin - patients list")
    y = normal_appbar(doc, "Patients", "Records submitted from home")
    y += 20
    doc.add(search_box(doc, y, "Search patients by name"))
    y += 66
    doc.add(roster_count(doc, y, "12 records newest first"))
    y += 22
    rows = [("Ananya Rao", "Patient ID TC-2041  ·  12 Oct", "Chart", True),
            ("Ravi Menon", "Patient ID TC-2044  ·  12 Oct", "Chart", False),
            ("Lakshmi Iyer", "Patient ID TC-2051  ·  11 Oct", "Chart", False),
            ("Imran Sheikh", "Patient ID TC-2063  ·  9 Oct", "Chart", False)]
    for title, sub, chip_label, alarm in rows:
        doc.add(roster_tile(doc, y, title, sub, chip_label, accent=SKY,
                            soft=SKY_SOFT, alarm=alarm))
        y += 88
    doc.add(safe_footer(doc))
    return "32-admin-patients-list", doc


# ------------------------------------------------------------------ 33 chart
def patient_chart():
    doc = page("33 Admin - patient chart")
    _chart(doc)
    doc.add(safe_footer(doc))
    return "33-admin-patient-chart", doc


# ------------------------------------------------------------------ 34 calendar
def calendar():
    doc = page("34 Admin - patient calendar")
    y = normal_appbar(doc, "Daily queries", "Ananya Rao  ·  pick a day")
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
    gid = doc.grad("asel", [(0, MINT_SOFT), (1, WHITE)])
    doc.add(g("Card / Selected day",
              rect(PAGE, y, W - PAGE * 2, ch, rx=R_CARD, fill=gid, stroke=MINT,
                   sw=1.2, name="bg"),
              text(PAGE + 18, y + 26, "OPENED  ·  MON 12 OCT", 9.5, 700, TEAL_DEEP,
                   spacing=1.3, caps=True, name="Eyebrow"),
              text(PAGE + 18, y + 50, "22 / 88 / 96", 20, 800, INK, name="Vitals"),
              text(PAGE + 18, y + 68, "resp / pulse / SpO2   ·   5 of 6 checks", 10.5,
                   600, INK_BODY, name="Meta"),
              text(W - PAGE - 18, y + 92, "Report read-only", 10.5, 600, INK_MUTED,
                   "end", name="Note"),
              rect(W - PAGE - 104, y + 22, 88, 34, rx=13, fill=TEAL, name="Button bg"),
              text(W - PAGE - 60, y + 43, "Open", 12.5, 700, WHITE, "middle",
                   name="Button label")))
    doc.add(safe_footer(doc))
    return "34-admin-patient-calendar", doc


# ------------------------------------------------------------------ 35 upload
def video_upload():
    doc = page("35 Admin - publish a video")
    y = normal_appbar(doc, "Publish a video", "It appears in WatchZone for everyone")
    y += 16
    sh, y = section_header(doc, PAGE, y, W - PAGE * 2, "Name it, then describe it",
                           eyebrow_text="New lesson")
    doc.add(sh)
    y += 18
    doc.add(field(doc, PAGE, y, W - PAGE * 2, "Title",
                  value="Cleaning the inner tube", icon_name="doc"))
    y += 86
    doc.add(field(doc, PAGE, y, W - PAGE * 2, "Description", h=88,
                  value="Rinse, do not scrub", icon_name="report"))
    y += 122
    doc.add(pick_tile(doc, y, "Video file", "tubes-care.mp4  ·  42 MB", "play",
                      accent=VIOLET, chosen=True))
    y += 90
    doc.add(pick_tile(doc, y, "Thumbnail image", "MP4 or JPG still", "image"))
    y += 92
    doc.add(button(doc, PAGE, y, W - PAGE * 2, 54, "Publish video", icon_name="check"))
    y += 70
    doc.add(text(W / 2, y, "Both a video and a thumbnail are required", 10.5, 600,
                 INK_MUTED, "middle", name="Helper"))
    doc.add(safe_footer(doc))
    return "35-admin-publish-video", doc


# ------------------------------------------------------------------ 36 admin profile
def profile():
    doc = page("36 Admin - profile")
    y = normal_appbar(doc, "My profile", "The account behind this console")
    y += 16
    doc.add(profile_hero(doc, y, ADMIN, "Clinic administrator", "Account ID  AD-0001",
                         stops=ADMIN_STOPS, glyph="shield", h=206))
    y += 222

    contact = [("Email", "admin@trachcare.in", "mail"),
               ("Phone", "+91 44 2200 1180", "phone")]
    doc.add(detail_group(doc, y, "Contact", contact))
    y += detail_group_h(contact) + 38

    creds = [("Registration no.", "PR-1102 ADM", "shield"),
             ("Display name", ADMIN, "user")]
    doc.add(detail_group(doc, y, "Credentials", creds))
    y += detail_group_h(creds) + 34

    doc.add(notice(doc, y, "Passwords stay hidden",
                   "Set a new one from the edit screen.", h=68))
    y += 84
    doc.add(button(doc, PAGE, y, W - PAGE * 2, 54, "Edit details", icon_name="edit",
                   gradient=doc.grad("admedit", [(0, VIOLET), (1, "#9C82E4")],
                                     0, 0, 1, 1)))
    doc.add(safe_footer(doc))
    return "36-admin-profile", doc
