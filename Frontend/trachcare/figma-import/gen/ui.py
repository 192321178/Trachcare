"""Shared phone chrome used across the exported screens."""

from svg_kit import *


def page(title, bg=SURFACE, status=True):
    """status=False for screens whose hero is a dark gradient and draws its own."""
    doc = Doc("Screen / %s" % title, bg=bg)
    if status:
        doc.add(status_bar(doc))
    return doc


def back_pill(doc, x, y, dark=False):
    return g("IconButton / back",
             rect(x, y, 38, 38, rx=13, fill="rgba(255,255,255,0.18)" if not dark else WHITE,
                  name="bg"),
             icon("chevron_left", x + 11, y + 11, 16, WHITE if not dark else INK, 2.2,
                  name="chevron"))


def normal_appbar(doc, title, subtitle=None, back=True, y=STATUS_H + 6, h=64):
    """NormalAppbar / Duplicate_Appbar - brand gradient bar, white title."""
    gid = doc.grad("appbar-%s" % uid(title), [(0, TEAL), (1, TEAL_LIGHT)], 0, 0, 1, 0.6)
    parts = [rect(PAGE, y, W - PAGE * 2, h, fill=gid, rx=26, name="Appbar gradient"),
             circle(W - 44, y + 4, 34, fill=WHITE, opacity=0.07, name="Glow")]
    tx = PAGE + 20
    if back:
        parts.append(back_pill(doc, tx, y + 13))
        tx += 50
    parts.append(text(tx, y + (28 if subtitle else 38), title, 17, 700, WHITE, name="Title"))
    if subtitle:
        parts.append(text(tx, y + 47, subtitle, 11.5, 500, "rgba(255,255,255,0.8)",
                          name="Subtitle"))
    doc.add(g("Component / NormalAppbar", *parts))
    return y + h


def gradient_appbar(doc, name, role, notif_count=2, y=STATUS_H):
    """The patient home Appbar - full-bleed teal gradient header block."""
    gid = doc.grad("home-hdr", [(0, TEAL_DEEP), (0.55, TEAL), (1, TEAL_LIGHT)],
                   0.1, 0, 0.9, 1)
    parts = [rect(0, y, W, 116, fill=gid, rx=0, name="Appbar bleed"),
             corner_rect(0, y + 96, W, 44, top=26, fill=SURFACE, name="Bottom curve"),
             circle(W - 30, y + 12, 56, fill=WHITE, opacity=0.06, name="Glow 1"),
             circle(24, y + 92, 40, fill=WHITE, opacity=0.05, name="Glow 2"),
             icon("menu", PAGE, y + 24, 22, WHITE, 2.0, name="Menu icon"),
             rect(W - PAGE - 42, y + 18, 42, 42, rx=14, fill="rgba(255,255,255,0.16)",
                  name="Bell chip"),
             icon("bell", W - PAGE - 32, y + 28, 22, WHITE, 1.9, name="Bell icon")]
    if notif_count:
        parts += [circle(W - PAGE - 8, y + 24, 8, fill=CORAL, stroke="rgba(8,71,65,0.9)",
                         sw=2, name="Badge bg"),
                  text(W - PAGE - 8, y + 27.6, str(notif_count), 9.5, 700, WHITE, "middle",
                       name="Badge count")]
    parts.append(text(PAGE, y + 68, "Hi, %s" % name, 21, 700, WHITE, name="Greeting"))
    parts.append(text(PAGE, y + 88, role, 12, 500, "rgba(255,255,255,0.78)", name="Role"))
    doc.add(g("Component / Appbar", *parts))
    return y + 116


def avatar_mini(doc, cx, cy, r=19, color=MINT_SOFT, ink=TEAL, initial=None):
    parts = [circle(cx, cy, r, fill=color, name="Avatar bg"),
             circle(cx, cy, r + 2.5, stroke=WHITE, sw=2.2, name="Ring")]
    if initial:
        parts.append(text(cx, cy + r * 0.35, initial, r * 0.9, 700, ink, "middle",
                          name="Initial"))
    else:
        parts.append(icon("user", cx - r * 0.6, cy - r * 0.62, r * 1.2, ink, 1.9,
                          name="Silhouette"))
    return g("Avatar / small", *parts)


def patient_header(doc, x, y, w, name, pid, h=74, photo="Patient photo"):
    """TcPatientHeader - the Namecard that used to be duplicated eight times."""
    gid = doc.grad("ph-%s" % uid(name), [(0, TEAL), (1, TEAL_LIGHT)])
    parts = [soft_shadow(doc, x, y, w, h, R_CARD, SHADOW, lift=4),
             rect(x, y, w, h, fill=gid, rx=R_CARD, name="Header bg"),
             circle(x + 40, y + h / 2, 24, fill=WHITE, name=photo),
             icon("image", x + 28, y + h / 2 - 12, 24, MINT, 1.7, name="Photo glyph"),
             circle(x + 40, y + h / 2, 24, stroke="rgba(255,255,255,0.7)", sw=2,
                    name="Avatar ring"),
             text(x + 76, y + 30, name, 16, 700, WHITE, name="Name"),
             text(x + 76, y + 49, "Patient ID  ·  %s" % pid, 11.5, 500,
                  "rgba(255,255,255,0.8)", name="Patient ID")]
    return g("Component / TcPatientHeader", *parts)


def bottom_sheet(doc, h, name="Bottom sheet", y=None):
    """Scrim + rounded sheet surface, returns (group, sheet_top)."""
    top = y if y is not None else H - h
    parts = [rect(0, 0, W, H, fill=INK, opacity=0.46, name="Scrim"),
             soft_shadow(doc, 0, top, W, h, R_SHEET, "rgba(8,71,65,0.30)", lift=7),
             corner_rect(0, top, W, h, top=R_SHEET, fill=WHITE, name="Sheet surface"),
             drag_handle(doc, W / 2, top + 12)]
    return g("Overlay / %s" % name, *parts), top + 26


def overlay_page(title, bg=SURFACE):
    """Screens whose top edge is a scrim - the white status bar is added last."""
    return Doc("Screen / %s" % title, bg=bg)


def safe_footer(doc):
    return home_indicator(doc)


def scrim_top(doc, sheet_top):
    return rect(0, 0, W, sheet_top, fill=INK, opacity=0.46, name="Scrim")
