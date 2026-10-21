"""00 - design system board: tokens, type scale, components."""

from svg_kit import *
from ui import *

BW, BH = 1300, 2880
M = 64


def swatch(doc, x, y, w, h, name, hexv):
    dark = hexv in (TEAL, TEAL_DEEP, TEAL_LIGHT, INK, SKY, VIOLET, DANGER, CORAL,
                    THEATRE, AMBER, SUCCESS)
    fg = WHITE if dark else INK
    return g("Token / %s" % name,
             rect(x, y, w, h, fill=hexv, rx=14, stroke=DIVIDER, sw=1, name="Swatch"),
             text(x + 14, y + h - 30, name, 12, 700, fg, name="Name"),
             text(x + 14, y + h - 13, hexv.upper(), 10.5, 500, fg, opacity=0.75,
                  family=MONO, name="Hex"))


def row(doc, x, y, label, sample):
    doc.add(text(x, y - 16, label, 10, 700, INK_MUTED, spacing=1.3, caps=True,
                 name="Label"))
    doc.add(sample)


def board():
    doc = Doc("Screen / 00 Design system", bg="#F7FAF8", w=BW, h=BH)
    doc.add(rect(0, 0, BW, 190, fill=doc.grad("ds-hero", [(0, TEAL_DEEP), (0.6, TEAL),
                                                          (1, TEAL_LIGHT)], 0, 0, 1, 0.4),
                 name="Hero"),
            circle(BW - 120, 20, 180, fill=WHITE, opacity=0.06, name="Glow"),
            text(M, 76, "TRACHCARE", 11.5, 700, MINT, spacing=4.0, caps=True,
                 name="Eyebrow"),
            text(M, 118, "Design system", 40, 800, WHITE, spacing=-1.2, name="Title"),
            text(M, 148, "Modern clinical calm  ·  teal and mint on near-white  ·  "
                         "tokens mirror lib/style/design_system.dart", 14, 500,
                 "rgba(255,255,255,0.85)", name="Subtitle"))

    # ---------------------------------------------------------- colour tokens
    y = 240
    doc.add(eyebrow(doc, M, y, "01  Colour", TEAL_LIGHT, size=12))
    doc.add(text(M, y + 28, "Palette", 26, 700, INK, name="Section title"))
    doc.add(text(M, y + 50, "Brand and semantic colour tokens. Everything on this board "
                            "is one of these 22 values.", 13, 500, INK_MUTED,
                 name="Section note"))
    y += 78
    groups = [
        ("Brand", [("teal", TEAL), ("tealDeep", TEAL_DEEP), ("tealLight", TEAL_LIGHT),
                   ("mint", MINT), ("mintSoft", MINT_SOFT), ("success", SUCCESS)]),
        ("Surfaces & ink", [("surface", SURFACE), ("surfaceMuted", SURFACE_MUTED),
                             ("surfaceAlt", SURFACE_ALT), ("ink", INK),
                             ("inkBody", INK_BODY), ("inkMuted", INK_MUTED)]),
        ("Signal", [("amber", AMBER), ("coral", CORAL), ("sky", SKY), ("violet", VIOLET),
                    ("danger", DANGER), ("theatre", THEATRE)]),
        ("Soft tints", [("mintSoft", MINT_SOFT), ("amberSoft", AMBER_SOFT),
                        ("coralSoft", CORAL_SOFT), ("skySoft", SKY_SOFT),
                        ("successSoft", SUCCESS_SOFT), ("dangerSoft", DANGER_SOFT)]),
    ]
    sw, sh, gap = 186, 96, 16
    for title, items in groups:
        doc.add(text(M, y, title, 11, 700, TEAL, spacing=1.4, caps=True, name="Group"))
        y += 16
        for i, (nm, hx) in enumerate(items):
            col, rw = i % 6, i // 6
            doc.add(swatch(doc, M + col * (sw + gap), y + rw * (sh + gap), sw, sh, nm, hx))
        y += ((len(items) + 5) // 6) * (sh + gap) + 22

    # ---------------------------------------------------------- type + spacing
    doc.add(eyebrow(doc, M, y, "02  Type and shape", TEAL_LIGHT, size=12))
    y += 24
    panel_h = 330
    doc.add(card(doc, M, y, (BW - M * 2 - 20) * 0.58, panel_h, name="Panel / Type scale"))
    tx, ty = M + 28, y + 78
    doc.add(text(M + 28, y + 28, "Type scale - Plus Jakarta Sans", 15, 700, INK,
                 name="Panel title"))
    scale = [("Display", 34, 800, "TrachCare", INK),
             ("Title", 22, 800, "Spigotting schedule", INK),
             ("Section", 17, 700, "Care routine", INK),
             ("Body", 13.5, 500, "Take the reading after ten minutes of rest.", INK_BODY),
             ("Caption", 11.5, 500, "Mon 19 Oct · 11:30 AM · ENT OPD", INK_MUTED),
             ("Eyebrow", 10, 700, "TODAY'S ROUTINE", TEAL_LIGHT)]
    for label, size, weight, sample, color in scale:
        doc.add(text(tx, ty, sample, size, weight, color, name="Specimen %s" % label))
        doc.add(text(M + 28 + (BW - M * 2 - 20) * 0.58 - 128, ty,
                     "%s / %s" % (label, size), 10.5, 600, INK_MUTED, "end",
                     name="Token %s" % label))
        ty += 30 if size < 15 else (36 if size < 20 else 44)

    doc.add(card(doc, M + (BW - M * 2 - 20) * 0.58 + 20, y, (BW - M * 2 - 20) * 0.42,
                 panel_h, name="Panel / Radius and spacing"))
    rx = M + (BW - M * 2 - 20) * 0.58 + 48
    doc.add(text(rx, y + 28, "Radius and spacing", 15, 700, INK, name="Panel title"))
    ry = y + 58
    for label, val, w, h in [("card 20", R_CARD, 116, 62), ("sheet 28", R_SHEET, 116, 62),
                             ("field 14", R_FIELD, 116, 44), ("button 14", R_BUTTON, 84, 44)]:
        doc.add(rect(rx, ry, w, h, rx=val, fill=MINT_SOFT, stroke=MINT, sw=1.2,
                     name="Radius %s" % label))
        doc.add(text(rx + w + 16, ry + h / 2 + 4, label, 11.5, 600, INK_BODY, name="Label"))
        ry += h + 14
    sx = rx + 200
    doc.add(text(sx, y + 58, "Spacing", 11.5, 700, INK_MUTED, spacing=1.3, caps=True,
                 name="Spacing title"))
    sy = y + 74
    for label, v in [("xs 4", 4), ("sm 8", 8), ("md 12", 12), ("lg 16", 16), ("xl 20", 20),
                     ("xxl 24", 24), ("page 20", 20)]:
        doc.add(rect(sx, sy, v, 10, rx=3, fill=TEAL, opacity=0.75, name="Space %s" % label))
        doc.add(text(sx + v + 10, sy + 9, label, 10.5, 600, INK_MUTED, name="Label"))
        sy += 22

    y += panel_h + 40

    # ---------------------------------------------------------- components
    doc.add(eyebrow(doc, M, y, "03  Components", TEAL_LIGHT, size=12))
    doc.add(text(M, y + 28, "Widget kit", 26, 700, INK, name="Section title"))
    doc.add(text(M, y + 50, "Each maps to a widget in lib/components/ui_kit.dart.", 13,
                 500, INK_MUTED, name="Section note"))
    y += 78

    colw = (BW - M * 2 - 40) / 3.0
    # column 1 - buttons
    cx1 = M
    doc.add(text(cx1, y, "TcButton", 13, 700, INK, name="Component name"))
    doc.add(button(doc, cx1, y + 14, colw - 40, 54, "Submit report", icon_name="check"))
    doc.add(button(doc, cx1, y + 82, colw - 40, 54, "Save", fill=SURFACE_ALT, fg=TEAL,
                   name="Button / tonal"))
    doc.add(ghost_button(doc, cx1, y + 150, colw - 40, 54, "Cancel", icon_name="close"))
    doc.add(g("Button / destructive",
              rect(cx1, y + 218, colw - 40, 54, rx=R_BUTTON, fill=DANGER_SOFT,
                   stroke="#F3C2CC", sw=1.2, name="bg"),
              icon("logout", cx1 + 30, y + 238, 16, DANGER, 2.0, name="Icon"),
              text(cx1 + 56, y + 250, "Sign out", 14.5, 700, DANGER, name="Label")))
    row(doc, cx1, y + 296, "TcField", field(doc, cx1, y + 302, colw - 40, "Patient ID",
                                            value="TC-2041", icon_name="user"))
    doc.add(field(doc, cx1, y + 366, colw - 40, "Password", value="••••••••",
                  icon_name="lock", focused=True,
                  suffix=g("IconButton / reveal",
                           icon("eye", cx1 + colw - 82, y + 392, 18, INK_MUTED, 1.7,
                                name="Eye"))))

    # column 2 - chips, badges, tiles
    cx2 = M + colw + 20
    doc.add(text(cx2, y, "TcBadge / TcChip", 13, 700, INK, name="Component name"))
    xx = cx2
    for lbl, fg, bg, ic in [("Verified", TEAL, MINT_SOFT, "check"),
                            ("Due 8 PM", "#8A5200", AMBER_SOFT, "clock"),
                            ("Missed", DANGER, DANGER_SOFT, "alert"),
                            ("New", "#1D5A8C", SKY_SOFT, "sparkle")]:
        c, w = chip(doc, xx, y + 14, lbl, fg=fg, bg=bg, icon_name=ic, h=30, size=11.5)
        doc.add(c)
        xx += w + 10
    xx = cx2
    for lbl, fg, bg in [("Day 21", TEAL_DEEP, MINT_SOFT), ("Spigotting", "#1D5A8C",
                                                           SKY_SOFT)]:
        c, w = chip(doc, xx, y + 56, lbl, fg=fg, bg=bg, h=30, size=11.5)
        doc.add(c)
        xx += w + 10
    row(doc, cx2, y + 112, "TcStatTile",
        stat_tile(doc, cx2, y + 118, colw - 40, 96, "droplet", "RESP", "22", TEAL,
                  MINT_SOFT, unit="br/min"))
    row(doc, cx2, y + 252, "TcSegmented / progress",
        segmented(doc, cx2, y + 258, colw - 40, 40, ["Yes", "No"], active=0))
    doc.add(g("Progress samples",
              progress_ring(doc, cx2 + 40, y + 336, 26, 3, 5, label="3/5", size=13),
              progress_ring(doc, cx2 + 116, y + 336, 26, 1, 5, color=AMBER, label="1/5",
                            size=13),
              g("Session dots",
                *[circle(cx2 + 190 + i * 30, y + 336, 11,
                         fill=TEAL if i < 2 else (WHITE if i == 2 else SURFACE_ALT),
                         stroke=AMBER if i == 2 else OUTLINE,
                         sw=2.2 if i == 2 else 1.2, name="Dot %d" % i)
                  for i in range(5)])))

    # column 3 - cards, avatar, nav
    cx3 = M + (colw + 20) * 2
    doc.add(text(cx3, y, "TcCard / TcAvatar", 13, 700, INK, name="Component name"))
    doc.add(card(doc, cx3, y + 14, colw - 40, 96, name="Example card"))
    doc.add(g("Card content",
              rect(cx3 + 16, y + 30, 40, 40, rx=13, fill=MINT_SOFT, name="Icon chip"),
              icon("video", cx3 + 28, y + 42, 24, TEAL, 1.8, name="Icon"),
              text(cx3 + 66, y + 46, "Changing ties", 14, 700, INK, name="Title"),
              text(cx3 + 66, y + 64, "4 min · daily", 11, 600, INK_MUTED, name="Meta"),
              icon("chevron_right", cx3 + colw - 72, y + 40, 18, INK_MUTED, 2.0,
                   name="Chevron")))
    doc.add(g("Avatar row",
              avatar(doc, cx3 + 34, y + 152, 26, initials="AR"),
              avatar(doc, cx3 + 104, y + 152, 26, bg=CORAL_SOFT, color=CORAL,
                     initials="MN"),
              g("IconButton",
                rect(cx3 + 152, y + 130, 44, 44, rx=15, fill=WHITE, stroke=DIVIDER, sw=1.2,
                     name="bg"),
                icon("bell", cx3 + 165, y + 143, 18, INK, 1.9, name="Bell"),
                circle(cx3 + 190, y + 134, 8, fill=CORAL, stroke=WHITE, sw=2,
                       name="Badge")),
              g("Badge",
                circle(cx3 + 232, y + 152, 22, fill=SURFACE_ALT, name="well"),
                icon("sparkle", cx3 + 221, y + 141, 22, TEAL, name="glyph"))))
    doc.add(detail_row(doc, cx3, y + 214, colw - 40, "Secretion", "white, thin"))
    doc.add(detail_row(doc, cx3, y + 246, colw - 40, "Spigotting", "Tolerated 12 min",
                       value_color=TEAL, rule=False))
    doc.add(nav_bar(doc, [("Home", "home"), ("Therapy", "video"), ("Records", "doc")], 0,
                    x=cx3, y=y + 272, w=colw - 40))
    doc.add(g("Empty state",
              rect(cx3, y + 356, colw - 40, 150, rx=R_CARD, fill=SURFACE_MUTED,
                   stroke=DIVIDER, sw=1, name="bg"),
              empty_state(doc, cx3 + (colw - 40) / 2, y + 424, "doc",
                          "Nothing logged yet", "Open today's queries to start")))

    y += 560

    # ---------------------------------------------------------- file map
    doc.add(eyebrow(doc, M, y, "04  Bundle contents", TEAL_LIGHT, size=12))
    doc.add(text(M, y + 28, "Screens in this export", 26, 700, INK, name="Section title"))
    y += 56
    files = [
        ("01 Splash", "gradient, glow, wordmark, loading state"),
        ("02 Welcome - role picker", "hero, role cards, admin entry"),
        ("03/04/05 Login", "one AuthScreen, three roles"),
        ("06 Home dashboard", "spigotting progress, lesson carousel"),
        ("07 Spigotting check-in", "sheet, Yes/No choices, minutes"),
        ("08 Therapy videos", "search, filter chips, lesson cards"),
        ("09 Video player", "dark theatre, controls, focus notes"),
        ("10 Daily records", "patient header, actions, medicine"),
        ("11 Daily report form", "vitals, checklist, spigotting"),
        ("12 Daily report view", "read-only vitals, answers, notes"),
        ("13 Report calendar", "month grid, logged/today/future"),
        ("14 Profile", "hero, avatar, details, sign out"),
        ("15 Edit profile", "avatar editor, TcField list, save"),
        ("16 Navigation drawer", "gradient header, tiles, logout"),
        ("17 Notification center", "sheet, reminders, swipe hint"),
        ("18 About", "hero and collapsible sections"),
        ("19 Doctor overview", "appbar, updates strip, shortcuts"),
        ("20 Doctor patients", "search roster, alert dot, chips"),
        ("21 Patient chart", "profile hero, detail groups"),
        ("22 Day report", "vitals tiles, Yes/No answer badges"),
        ("23 Report calendar", "same TableCalendar as patient"),
        ("24 Add patient", "photo picker, form cards"),
        ("25 Therapy videos", "lesson hero, compact list"),
        ("26/27 Doctor profile", "hero, credentials, password note"),
        ("28 Admin console", "stat row, destinations, export"),
        ("29 Admin doctors", "roster, search value, clear icon"),
        ("30 Doctor record", "hero, contact, remove action"),
        ("31 Add doctor", "photo picker, credential fields"),
        ("32/33 Admin patients", "roster and shared chart"),
        ("34 Patient calendar", "month grid, selected-day card"),
        ("35 Publish a video", "fields, pick tiles, publish"),
        ("36 Admin profile", "violet hero, edit action"),
    ]
    cw = (BW - M * 2 - 40) / 3.0
    for i, (f, d) in enumerate(files):
        col, rw = i % 3, i // 3
        x = M + col * (cw + 20)
        yy = y + rw * 58
        doc.add(g("File / %s" % f,
                  rect(x, yy, cw, 48, rx=14, fill=WHITE, stroke=DIVIDER, sw=1,
                       name="Row bg"),
                  rect(x + 12, yy + 12, 24, 24, rx=8, fill=MINT_SOFT, name="Chip"),
                  icon("image", x + 17, yy + 17, 14, TEAL, 2.0, name="File icon"),
                  text(x + 48, yy + 21, f, 12.5, 700, INK, name="File"),
                  text(x + 48, yy + 37, d, 10.5, 500, INK_MUTED, name="Contents")))
    y += ((len(files) + 2) // 3) * 58 + 24

    doc.add(g("Import notes",
              rect(M, y, BW - M * 2, 96, rx=18, fill=TEAL_DEEP, name="bg"),
              text(M + 24, y + 30, "Figma", 13, 700, MINT, spacing=1.6, caps=True,
                   name="Label"),
              text(M + 24, y + 58, "Place > Import file - pick the SVGs. Each <g id> "
                                   "becomes a named frame or group, every <text> an "
                                   "editable layer.", 14, 500, WHITE, name="Line 1"),
              text(M + 24, y + 78, "Install Plus Jakarta Sans first, or Figma will "
                                   "substitute the nearest available font.", 11.5, 500,
                   "rgba(255,255,255,0.7)", name="Line 2")))
    return "00-design-system", doc
