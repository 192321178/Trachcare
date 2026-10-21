"""Role-shell chrome shared by the Doctor and Admin exports.

Mirrors components/Appbar.dart, ui_kit.dart's TcNavBar / TcProfileHero /
TcDetailGroup / TcRosterScreen geometry so the two staff flows read as one
system next to the patient screens in ui.py.
"""

from svg_kit import *
from ui import *

DOCTOR_TABS = [("Overview", "home"), ("Videos", "video"), ("Patients", "user")]
ADMIN_TABS = [("Overview", "grid"), ("Add doctor", "user"), ("Videos", "video")]

ADMIN_STOPS = [(0, "#4A2F9E"), (0.55, VIOLET), (1, "#9C82E4")]


def role_appbar(doc, name, subtitle=None, notif=0, export=False, stops=None,
                y=STATUS_H, h=104):
    """Appbar - full-bleed brand gradient, menu leading, bell/export trailing."""
    stops = stops or [(0, TEAL_DEEP), (0.55, TEAL), (1, TEAL_LIGHT)]
    gid = doc.grad("role-hdr-%s" % uid(name), stops, 0.1, 0, 0.9, 1)
    sub = subtitle or ("Ready to export" if export else "How are you today?")
    parts = [rect(0, y, W, h, fill=gid, name="Appbar bleed"),
             corner_rect(0, y + h - 24, W, 44, top=26, fill=SURFACE,
                         name="Bottom curve"),
             circle(W - 30, y + 10, 54, fill=WHITE, opacity=0.06, name="Glow 1"),
             circle(20, y + h - 12, 38, fill=WHITE, opacity=0.05, name="Glow 2"),
             rect(PAGE - 6, y + 18, 40, 40, rx=13, fill="rgba(255,255,255,0.16)",
                  name="Menu chip"),
             icon("menu", PAGE + 2, y + 26, 22, WHITE, 2.0, name="Menu icon"),
             rect(W - PAGE - 42, y + 18, 42, 42, rx=14, fill="rgba(255,255,255,0.16)",
                  name="Action chip"),
             icon("doc" if export else "bell", W - PAGE - 32, y + 28, 22, WHITE, 1.9,
                  name="Action icon")]
    if notif:
        parts += [rect(W - PAGE - 14, y + 14, 20, 17, rx=8.5, fill=CORAL,
                       stroke=WHITE, sw=1.6, name="Badge bg"),
                  text(W - PAGE - 4, y + 26.5, str(notif), 9.5, 800, WHITE, "middle",
                       name="Badge count")]
    parts.append(text(PAGE + 54, y + 44, "Hi, %s" % name, 17.5, 800, WHITE,
                      name="Greeting"))
    parts.append(text(PAGE + 54, y + 64, sub, 11.5, 500, "rgba(255,255,255,0.78)",
                      name="Role"))
    doc.add(g("Component / Appbar", *parts))
    return y + h


def search_box(doc, y, hint, value="", x=PAGE, w=None):
    w = w if w is not None else W - PAGE * 2
    parts = [rect(x, y, w, 52, rx=R_FIELD, fill=SURFACE, stroke=OUTLINE, sw=1.2,
                  name="Search bg"),
             icon("search", x + 16, y + 16, 20, INK_MUTED, 1.8, name="Search icon"),
             text(x + 48, y + 31, value or hint, 13.5, 500 if value else 400,
                  INK if value else INK_MUTED, name="Value")]
    if value:
        parts.append(icon("close", x + w - 30, y + 17, 18, INK_MUTED, 2.0,
                          name="Clear"))
    return g("Component / TcRoster search", *parts)


def roster_tile(doc, y, title, sub, chip_label=None, accent=TEAL, soft=MINT_SOFT,
                h=76, icon_name="user", x=PAGE, w=None, alarm=False):
    w = w if w is not None else W - PAGE * 2
    parts = [soft_shadow(doc, x, y, w, h, 18, SHADOW, lift=4),
             rect(x, y, w, h, rx=18, fill=WHITE, name="Tile bg"),
             circle(x + 38, y + h / 2, 23, fill=soft, name="Photo well"),
             icon(icon_name, x + 24, y + h / 2 - 14, 28, accent, 1.7, name="Photo"),
             circle(x + 38, y + h / 2, 23, stroke=WHITE, sw=2, name="Ring"),
             text(x + 74, y + h / 2 - 3, title, 15, 700, INK, name="Title"),
             text(x + 74, y + h / 2 + 15, sub, 11, 600, INK_MUTED, name="Id")]
    if alarm:
        parts.append(circle(x + 55, y + h / 2 - 16, 7.5, fill=CORAL, stroke=WHITE,
                            sw=2, name="Alert dot"))
    if chip_label:
        c, cw = chip(doc, 0, 0, chip_label, fg=accent, bg=soft, h=26, size=10.5,
                     icon_name="chevron_right")
        parts.append(g("Chip / %s" % chip_label, c,
                       transform="translate(%s %s)" % (n(x + w - cw - 14),
                                                       n(y + h / 2 - 13))))
    return g("List tile / %s" % title, *parts)


def roster_count(doc, y, label):
    return text(PAGE + 4, y, label, 10.5, 700, INK_MUTED, spacing=1.2, caps=True,
                name="Count")


def profile_hero(doc, y, name, role, idlabel, stops=None, glyph="doctor",
                 h=206, x=PAGE, w=None):
    """TcProfileHero - gradient card, centred avatar, name, role and ID chip."""
    w = w if w is not None else W - PAGE * 2
    stops = stops or [(0, TEAL_DEEP), (0.6, TEAL), (1, TEAL_LIGHT)]
    gid = doc.grad("hero-%s" % uid(name), stops, 0.1, 0, 0.9, 1)
    cx = x + w / 2
    parts = [soft_shadow(doc, x, y, w, h, R_CARD, SHADOW_TEAL, lift=6),
             rect(x, y, w, h, rx=R_CARD, fill=gid, name="Hero bg"),
             circle(x + w - 18, y + 12, 58, fill=WHITE, opacity=0.07, name="Glow 1"),
             circle(x + 22, y + h - 8, 44, fill=WHITE, opacity=0.05, name="Glow 2"),
             circle(cx, y + 52, 40, fill="rgba(255,255,255,0.28)", name="Avatar pad"),
             circle(cx, y + 52, 37, fill=WHITE, name="Photo"),
             icon(glyph, cx - 19, y + 33, 38, TEAL, 1.6, name="Photo glyph"),
             text(cx, y + 122, name, 21, 800, WHITE, "middle", spacing=-0.4,
                  name="Name"),
             text(cx, y + 143, role, 11.5, 500, "rgba(255,255,255,0.8)", "middle",
                  name="Role")]
    tw = measure(idlabel, 10.5, 700) + 30
    parts += [rect(cx - tw / 2, y + h - 44, tw, 28, rx=14, fill="rgba(255,255,255,0.18)",
                   stroke="rgba(255,255,255,0.35)", sw=1, name="Id chip bg"),
              text(cx, y + h - 25, idlabel, 10.5, 700, WHITE, "middle", spacing=0.6,
                   name="Id chip")]
    return g("Component / TcProfileHero", *parts)


def detail_group(doc, y, title, rows, card_name=None):
    """TcDetailGroup - eyebrow above a white card of TcDetailRow items."""
    h = 34 + len(rows) * 36 + 6
    parts = [text(PAGE + 4, y + 10, title, 10, 700, INK_MUTED, spacing=1.4,
                  caps=True, name="Eyebrow"),
             card(doc, PAGE, y + 22, W - PAGE * 2, h, fill=WHITE, shadow=False,
                  stroke=DIVIDER, sw=1.2, name=card_name or "Card / %s" % title)]
    yy = y + 22 + 42
    for i, item in enumerate(rows):
        label, value = item[0], item[1]
        ic = item[2] if len(item) > 2 else None
        color = item[3] if len(item) > 3 else INK
        parts.append(detail_row(doc, PAGE + 18, yy, W - PAGE * 2 - 36, label, value,
                                icon_name=ic, value_color=color,
                                rule=i < len(rows) - 1, name="Row / %s" % label))
        yy += 36
    return g("Group / %s" % title, *parts)


def detail_group_h(rows):
    return 34 + len(rows) * 36 + 6


def month_calendar(doc, y, title, logged, selected, today, first_col,
                   future_from=32, days=31, weeks=5):
    """TableCalendar mock shared by both staff calendars. Returns the next y."""
    ch = 336
    parts = [card(doc, PAGE, y, W - PAGE * 2, ch, name="Card / Table calendar"),
             g("Month header",
               rect(PAGE + 14, y + 16, 32, 32, rx=11, fill=SURFACE_MUTED,
                    name="Prev bg"),
               icon("chevron_left", PAGE + 22, y + 24, 16, INK_BODY, 2.0, name="Prev"),
               text(W / 2, y + 38, title, 16.5, 700, INK, "middle", name="Month"),
               rect(W - PAGE - 46, y + 16, 32, 32, rx=11, fill=SURFACE_MUTED,
                    name="Next bg"),
               icon("chevron_right", W - PAGE - 38, y + 24, 16, INK_BODY, 2.0,
                    name="Next"))]
    gx = PAGE + 18
    gw = (W - PAGE * 2 - 36) / 7.0
    ry = y + 66
    for i, d in enumerate(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]):
        parts.append(text(gx + gw * i + gw / 2, ry, d, 10.5, 700, INK_MUTED, "middle",
                          name="Weekday %s" % d))
    ry += 26
    for week in range(weeks):
        for col in range(7):
            idx = week * 7 + col - first_col + 1
            cx = gx + gw * col + gw / 2
            cy = ry + week * 50 + 16
            if idx < 1 or idx > days:
                continue
            bg, fg, dot = None, INK_BODY, False
            if idx == selected:
                bg, fg = TEAL, WHITE
            elif idx in logged:
                dot, fg = True, TEAL_DEEP
            elif idx >= future_from:
                fg = INK_MUTED
            if bg:
                parts.append(circle(cx, cy, 17, fill=bg, name="Day %d selected" % idx))
            if idx == today:
                parts.append(circle(cx, cy, 17, stroke=AMBER, sw=1.8,
                                    name="Day %d today" % idx))
            parts.append(text(cx, cy + 4.5, str(idx), 12.5, 700 if bg else 600, fg,
                              "middle", name="Day %d" % idx))
            if dot:
                parts.append(circle(cx, cy + 12, 2.4, fill=TEAL_LIGHT,
                                    name="Dot %d" % idx))
    return g("Component / TableCalendar", *parts), y + ch


def calendar_legend(doc, y):
    return g("Legend",
             circle(PAGE + 6, y, 5, fill=TEAL, name="Swatch reported"),
             text(PAGE + 18, y + 4, "Report submitted", 10.5, 600, INK_MUTED, name="L1"),
             circle(PAGE + 130, y, 5, stroke=AMBER, sw=1.6, fill="none",
                    name="Swatch today"),
             text(PAGE + 142, y + 4, "Today", 10.5, 600, INK_MUTED, name="L2"),
             circle(PAGE + 208, y, 5, fill=OUTLINE, name="Swatch locked"),
             text(PAGE + 220, y + 4, "Future", 10.5, 600, INK_MUTED, name="L3"))


def answer_badge(doc, y, label, answer, x=PAGE, w=None):
    """TcBadge row - the read-only Yes/No answers of a daily report."""
    w = w if w is not None else W - PAGE * 2
    ok = answer == "Yes"
    fg = SUCCESS if ok else DANGER
    bg = SUCCESS_SOFT if ok else DANGER_SOFT
    if answer == "Not answered":
        fg, bg = INK_MUTED, SURFACE_ALT
    return g("Answer / %s" % label,
             text(x + 18, y, label, 12.5, 600, INK_BODY, name="Label"),
             rect(x + w - 18 - 92, y - 14, 92, 24, rx=12, fill=bg, name="Badge bg"),
             text(x + w - 18 - 46, y + 2, answer, 10.5, 700, fg, "middle",
                  name="Badge label"))


def notice(doc, y, title, body, icon_name="lock", bg=SKY_SOFT, accent=SKY,
           fg="#1D5A8C", h=64):
    return g("Notice",
             rect(PAGE, y, W - PAGE * 2, h, rx=16, fill=bg, name="bg"),
             icon(icon_name, PAGE + 16, y + h / 2 - 10, 20, accent, 1.9, name="Icon"),
             para(PAGE + 44, y + (24 if title else 20),
                  ([title] if title else []) + wrap(body, 40), 11, 15,
                  500 if not title else 600, fg, name="Copy"))


def photo_picker(doc, y, label="Tap to add a photo", accent=TEAL, soft=MINT_SOFT,
                 glyph="doctor", h=104):
    """TcCard with the avatar + camera badge used on the add/edit forms."""
    w = W - PAGE * 2
    return g("Card / Photo picker",
             card(doc, PAGE, y, w, h, name="bg"),
             circle(PAGE + 52, y + h / 2, 32, fill=soft, name="Avatar well"),
             icon(glyph, PAGE + 34, y + h / 2 - 18, 36, accent, 1.6, name="Glyph"),
             circle(PAGE + 52, y + h / 2, 32, stroke=WHITE, sw=2.5, name="Ring"),
             circle(PAGE + 74, y + h / 2 + 20, 13, fill=accent, stroke=WHITE, sw=2.5,
                    name="Camera chip"),
             icon("camera", PAGE + 68, y + h / 2 + 14, 12, WHITE, 2.1, name="Camera"),
             text(PAGE + 102, y + h / 2 - 4, "Profile photo", 14.5, 700, INK,
                  name="Title"),
             text(PAGE + 102, y + h / 2 + 14, label, 11.5, 600, INK_MUTED,
                  name="Hint"))


def form_card(doc, y, title, fields):
    """A section of TcField rows inside one muted card (Add patients style)."""
    w = W - PAGE * 2
    pitch = 66
    h = 40 + len(fields) * pitch + 8
    parts = [card(doc, PAGE, y, w, h, fill=SURFACE_MUTED, shadow=False,
                  stroke=DIVIDER, sw=1.2, name="Card / %s" % title),
             text(PAGE + 16, y + 26, title, 10, 700, TEAL, spacing=1.4, caps=True,
                  name="Header")]
    fy = y + 38
    for f in fields:
        label, value, ic = f[0], f[1], f[2]
        kind = f[3] if len(f) > 3 else "text"
        parts.append(field(doc, PAGE + 16, fy, w - 32, label, value=value,
                           icon_name=ic,
                           suffix=g("IconButton / reveal",
                                    icon("eye", PAGE + w - 64, fy + 34, 16, INK_MUTED,
                                         1.7, name="Eye")) if kind == "secret" else None))
        fy += pitch
    return g("Form / %s" % title, *parts), y + h


def shortcut_card(doc, x, y, w, h, glyph, title, sub, accent=TEAL, soft=MINT_SOFT):
    return g("Shortcut / %s" % title,
             soft_shadow(doc, x, y, w, h, 18, SHADOW, lift=4),
             rect(x, y, w, h, rx=18, fill=WHITE, name="bg"),
             rect(x + 14, y + 14, 38, 38, rx=13, fill=soft, name="Icon chip"),
             icon(glyph, x + 23, y + 23, 20, accent, 1.9, name="Icon"),
             text(x + 14, y + h - 34, title, 14, 700, INK, name="Title"),
             text(x + 14, y + h - 16, sub, 10.5, 600, INK_MUTED, name="Subtitle"),
             icon("arrow_right", x + w - 32, y + h - 30, 17, accent, 2.0, name="Go"))


def video_tile(doc, x, y, w, h, title, meta, accent=TEAL, fresh=False):
    gid = doc.grad("vt2-%s" % uid(title), [(0, "#0B3B34"), (0.6, accent),
                                           (1, TEAL_LIGHT)], 0, 0, 1, 1)
    th = h - 74
    parts = [soft_shadow(doc, x, y, w, h, 18, SHADOW, lift=4),
             rect(x, y, w, h, rx=18, fill=gid, name="Thumbnail"),
             circle(x + w - 26, y + 16, 40, fill=WHITE, opacity=0.08, name="Glow"),
             rect(x, y + th - 6, w, 80, fill=WHITE, name="Body"),
             rect(x, y + h - 16, w, 16, rx=18, fill=WHITE, name="Body bottom"),
             circle(x + w / 2, y + th / 2 - 4, 21, fill=WHITE, opacity=0.95,
                    name="Play button"),
             pth("M %s %s l 10 6 l -10 6 z" % (n(x + w / 2 - 4), n(y + th / 2 - 10)),
                 fill=TEAL, name="Play glyph"),
             text(x + 14, y + th + 20, title, 13.5, 700, INK, name="Title"),
             text(x + 14, y + th + 38, meta, 10.5, 600, INK_MUTED, name="Meta")]
    if fresh:
        c, _ = chip(doc, x + w - 62, y + 12, "New", fg="#8A5200", bg=AMBER_SOFT,
                    icon_name="sparkle", h=24, size=10)
        parts.append(c)
    return g("Video card / %s" % title, *parts)


def scroll_hint(doc, y, label):
    return g("Scroll hint",
             line(PAGE, y, W / 2 - 60, y, stroke=DIVIDER, name="L"),
             text(W / 2, y + 4, label, 10, 600, INK_MUTED, "middle", spacing=1.0,
                  caps=True, name="Label"),
             line(W / 2 + 60, y, W - PAGE, y, stroke=DIVIDER, name="R"))
