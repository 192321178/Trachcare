"""SVG primitives + TrachCare design tokens for the Figma import bundle.

Every value here mirrors lib/style/design_system.dart so the exported screens
and the shipped Flutter theme cannot drift silently.
"""

# ---------------------------------------------------------------- canvas
W, H = 390, 844
STATUS_H = 54          # iOS status bar
NAV_H = 96             # bottom TcNavBar band

# ---------------------------------------------------------------- palette
TEAL = "#0E6B5E"
TEAL_DEEP = "#084741"
TEAL_LIGHT = "#2E9E8B"
MINT = "#A7DBAF"
MINT_SOFT = "#DFF3E6"
SURFACE = "#FDFEFD"
SURFACE_MUTED = "#F2F6F4"
SURFACE_ALT = "#E8F1ED"
INK = "#0F2A24"
INK_BODY = "#3B554E"
INK_MUTED = "#7A938C"
OUTLINE = "#D6E2DC"
DIVIDER = "#EAF1EE"
AMBER = "#F4A82B"
AMBER_SOFT = "#FFF3DC"
CORAL = "#E8735A"
CORAL_SOFT = "#FDE8E3"
SKY = "#3B82C4"
SKY_SOFT = "#E3EFF9"
VIOLET = "#7C5CD6"
SUCCESS = "#17A06B"
SUCCESS_SOFT = "#DCF5EA"
DANGER = "#D9455F"
DANGER_SOFT = "#FBE4E8"
THEATRE = "#071A17"
WHITE = "#FFFFFF"

# ---------------------------------------------------------------- type / shape
FONT = "Plus Jakarta Sans, Inter, ui-sans-serif, sans-serif"
MONO = "JetBrains Mono, ui-monospace, monospace"

R_CARD = 20
R_SHEET = 28
R_FIELD = 14
R_BUTTON = 14
PAGE = 20

SHADOW = "rgba(15,42,36,0.10)"
SHADOW_TEAL = "rgba(14,107,94,0.22)"


def n(v):
    if isinstance(v, float):
        s = ("%.3f" % v).rstrip("0").rstrip(".")
        return s if s not in ("", "-0") else "0"
    return str(v)


def esc(s):
    return (str(s).replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace('"', "&quot;"))


# ---------------------------------------------------------------- primitives
def g(name, *kids, opacity=None, transform=None, clip=None):
    a = ['id="%s"' % esc(name)]
    if opacity is not None:
        a.append('opacity="%s"' % n(opacity))
    if transform:
        a.append('transform="%s"' % transform)
    if clip:
        a.append('clip-path="%s"' % clip)
    body = "".join(k for k in kids if k)
    return "<g %s>%s</g>" % (" ".join(a), body)


def rect(x, y, w, h, fill="none", rx=0, stroke=None, sw=1, opacity=None,
         name="Rect", dash=None):
    a = ['id="%s"' % name, 'x="%s"' % n(x), 'y="%s"' % n(y),
         'width="%s"' % n(w), 'height="%s"' % n(h)]
    if rx:
        a.append('rx="%s"' % n(rx))
    a.append('fill="%s"' % fill)
    if stroke:
        a += ['stroke="%s"' % stroke, 'stroke-width="%s"' % n(sw)]
        if dash:
            a.append('stroke-dasharray="%s"' % dash)
    if opacity is not None:
        a.append('opacity="%s"' % n(opacity))
    return "<rect %s/>" % " ".join(a)


def circle(cx, cy, r, fill="none", stroke=None, sw=1, opacity=None,
           name="Circle", dash=None, cap="round", transform=None):
    a = ['id="%s"' % name, 'cx="%s"' % n(cx), 'cy="%s"' % n(cy),
         'r="%s"' % n(r), 'fill="%s"' % fill]
    if stroke:
        a += ['stroke="%s"' % stroke, 'stroke-width="%s"' % n(sw)]
        if dash:
            a.append('stroke-dasharray="%s"' % dash)
        a.append('stroke-linecap="%s"' % cap)
    if transform:
        a.append('transform="%s"' % transform)
    if opacity is not None:
        a.append('opacity="%s"' % n(opacity))
    return "<circle %s/>" % " ".join(a)


def pth(d, fill="none", stroke=None, sw=1.6, opacity=None, name="Path",
        cap="round", join="round", dash=None):
    a = ['id="%s"' % name, 'd=d' if False else 'd="%s"' % d, 'fill="%s"' % fill]
    if stroke:
        a += ['stroke="%s"' % stroke, 'stroke-width="%s"' % n(sw),
              'stroke-linecap="%s"' % cap, 'stroke-linejoin="%s"' % join]
        if dash:
            a.append('stroke-dasharray="%s"' % dash)
    if opacity is not None:
        a.append('opacity="%s"' % n(opacity))
    return "<path %s/>" % " ".join(a)


def rrect_path(x, y, w, h, tl=0, tr=0, br=0, bl=0):
    """Rounded rectangle as a path so a shape can round only one edge - the
    trick every gradient header and bottom sheet in this app relies on."""
    x2, y2 = x + w, y + h
    return ("M %s %s H %s A %s %s 0 0 1 %s %s V %s A %s %s 0 0 1 %s %s H %s"
            " A %s %s 0 0 1 %s %s V %s A %s %s 0 0 1 %s %s Z"
            % (n(x + tl), n(y), n(x2 - tr), n(tr), n(tr), n(x2), n(y + tr),
               n(y2 - br), n(br), n(br), n(x2 - br), n(y2), n(x + bl),
               n(bl), n(bl), n(x), n(y2 - bl), n(y + tl), n(tl), n(tl),
               n(x + tl), n(y)))


def corner_rect(x, y, w, h, top=0, bottom=0, fill=SURFACE, stroke=None, sw=1,
                name="Rounded rect", opacity=None):
    return pth(rrect_path(x, y, w, h, top, top, bottom, bottom), fill=fill,
               stroke=stroke, sw=sw, opacity=opacity, name=name)


def line(x1, y1, x2, y2, stroke=DIVIDER, sw=1, opacity=None, name="Line",
         dash=None, cap="round"):
    a = ['id="%s"' % name, 'x1="%s"' % n(x1), 'y1="%s"' % n(y1),
         'x2="%s"' % n(x2), 'y2="%s"' % n(y2), 'stroke="%s"' % stroke,
         'stroke-width="%s"' % n(sw)]
    if dash:
        a.append('stroke-dasharray="%s"' % dash)
    if cap:
        a.append('stroke-linecap="%s"' % cap)
    if opacity is not None:
        a.append('opacity="%s"' % n(opacity))
    return "<line %s/>" % " ".join(a)


def text(x, y, s, size=14, weight=400, color=INK, anchor="start",
         spacing=0.0, opacity=None, family=FONT, name="Text", caps=False,
         lh=None):
    body = esc(s.upper() if caps else s)
    a = ['id="%s"' % name, 'x="%s"' % n(x), 'y="%s"' % n(y),
         'font-family="%s"' % family, 'font-size="%s"' % n(size),
         'font-weight="%s"' % weight, 'fill="%s"' % color,
         'text-anchor="%s"' % anchor]
    if spacing:
        a.append('letter-spacing="%s"' % n(spacing))
    if opacity is not None:
        a.append('opacity="%s"' % n(opacity))
    if lh:
        a.append('line-height="%s"' % n(lh))
    return "<text %s>%s</text>" % (" ".join(a), body)


def para(x, y, lines, size=14, lh=None, weight=400, color=INK_BODY,
         anchor="start", spacing=0.0, name="Paragraph", opacity=None):
    """Each line its own <text> node - imports into Figma as separate
    text layers, which is more editable than one wrapped layer."""
    lh = lh or size * 1.55
    out = []
    for i, ln in enumerate(lines):
        out.append(text(x, y + i * lh, ln, size, weight, color, anchor,
                        spacing, opacity, name="%s %d" % (name, i + 1)))
    return g(name, *out)


# ---------------------------------------------------------------- icons
# 24x24 grid, drawn with strokes so they import as editable vector shapes.
_ICONS = {
    "home": '<path d="M4 10.5 12 4l8 6.5V20a1 1 0 0 1-1 1h-4v-6H9v6H5a1 1 0 0 1-1-1z"/>',
    "video": '<path d="M3 7.5A2.5 2.5 0 0 1 5.5 5h8A2.5 2.5 0 0 1 16 7.5v9A2.5 2.5 0 0 1 13.5 19h-8A2.5 2.5 0 0 1 3 16.5z"/><path d="M16 10.5 21 7.5v9l-5-3z"/>',
    "pill": '<path d="M8.5 3.5 3.5 8.5a5 5 0 0 0 7 7l5-5a5 5 0 0 0-7-7z"/><path d="M7 7l7 7"/>',
    "calendar": '<rect x="3.5" y="5.5" width="17" height="15" rx="3"/><path d="M3.5 10.5h17M8 3.5v4M16 3.5v4"/>',
    "user": '<circle cx="12" cy="8" r="3.6"/><path d="M5 20a7 7 0 0 1 14 0"/>',
    "bell": '<path d="M7 10a5 5 0 0 1 10 0c0 4 1.5 5.5 1.5 5.5h-13S7 14 7 10z"/><path d="M10 18.5a2 2 0 0 0 4 0"/>',
    "chevron_left": '<path d="M14.5 6 8.5 12l6 6"/>',
    "chevron_right": '<path d="M9.5 6l6 6-6 6"/>',
    "chevron_down": '<path d="M6 9.5l6 6 6-6"/>',
    "menu": '<path d="M4 7h16M4 12h16M4 17h10"/>',
    "close": '<path d="M6.5 6.5l11 11M17.5 6.5l-11 11"/>',
    "check": '<path d="M5 12.5l4.5 4.5L19 7"/>',
    "camera": '<path d="M4 8.5h3l1.5-2h7L17 8.5h3v10H4z"/><circle cx="12" cy="13.5" r="3.2"/>',
    "logout": '<path d="M15 5H6a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h9"/><path d="M18.5 12H10M16 9l3 3-3 3"/>',
    "search": '<circle cx="11" cy="11" r="6"/><path d="M15.5 15.5 20 20"/>',
    "heart": '<path d="M12 19.5S4.5 14.8 4.5 9.8A4.3 4.3 0 0 1 12 7a4.3 4.3 0 0 1 7.5 2.8c0 5-7.5 9.7-7.5 9.7z"/>',
    "wind": '<path d="M3 8.5h9a2.75 2.75 0 1 0-2.75-2.75"/><path d="M3 13h12a3 3 0 1 1-3 3"/><path d="M3 17.5h6"/>',
    "clock": '<circle cx="12" cy="12" r="8"/><path d="M12 7.5V12l3 2"/>',
    "info": '<circle cx="12" cy="12" r="8"/><path d="M12 11v5M12 8.2v.6"/>',
    "shield": '<path d="M12 3.5 5.5 6v6c0 4 3 6.5 6.5 8.5C15.5 18.5 18.5 16 18.5 12V6z"/><path d="M9.5 12l2 2 3.5-4"/>',
    "doctor": '<path d="M6 3.5v6a6 6 0 0 0 12 0v-6"/><path d="M12 15.5V19a3 3 0 0 0 6 0v-1.5"/><circle cx="18" cy="17.5" r="1.6"/>',
    "lock": '<rect x="5" y="10.5" width="14" height="9.5" rx="2.5"/><path d="M8 10.5V8a4 4 0 0 1 8 0v2.5"/>',
    "mail": '<rect x="3.5" y="5.5" width="17" height="13" rx="3"/><path d="m3.5 9 8.5 5 8.5-5"/>',
    "phone": '<rect x="7" y="3" width="10" height="18" rx="2.5"/><path d="M11 6.5h2"/>',
    "edit": '<path d="M4.5 19.5h4L19 9a2.5 2.5 0 0 0-3.5-3.5L5 16z"/><path d="M14.5 6.5 17.5 9.5"/>',
    "play": '<path d="M8.5 6.5 18 12l-9.5 5.5z"/>',
    "play_circle": '<circle cx="12" cy="12" r="8.2"/><path d="M10.5 9.2 15 12l-4.5 2.8z"/>',
    "droplet": '<path d="M12 3.5c3.5 4 5.5 6.4 5.5 9A5.5 5.5 0 0 1 6.5 12.5c0-2.6 2-5 5.5-9z"/>',
    "doc": '<path d="M6 3.5h7l5 5v12H6z"/><path d="M13 3.5v5h5"/><path d="M8.5 13h7M8.5 16.5h5"/>',
    "alert": '<path d="M12 4.5 20 19H4z"/><path d="M12 9.5v4M12 16.4v.4"/>',
    "grid": '<rect x="4" y="4" width="7" height="7" rx="2"/><rect x="13" y="4" width="7" height="7" rx="2"/><rect x="4" y="13" width="7" height="7" rx="2"/><rect x="13" y="13" width="7" height="7" rx="2"/>',
    "image": '<rect x="3.5" y="5.5" width="17" height="13" rx="3"/><circle cx="9" cy="10.5" r="1.6"/><path d="m4.5 17.5 5-4.5 4 3.5 3-2.5 4 3.5"/>',
    "sparkle": '<path d="M12 4.5l1.7 4.3 4.3 1.7-4.3 1.7L12 16.5l-1.7-4.3L6 10.5l4.3-1.7z"/><path d="M18.5 16.5l.8 1.9 1.9.8-1.9.8-.8 1.9-.8-1.9-1.9-.8 1.9-.8z"/>',
    "lungs": '<path d="M12 4v9"/><path d="M9.5 8.5C7 8.5 5.5 11 5.5 14.5S7 19.5 9 19.5s2.5-1.5 2.5-4"/><path d="M14.5 8.5C17 8.5 18.5 11 18.5 14.5S17 19.5 15 19.5s-2.5-1.5-2.5-4"/>',
    "report": '<path d="M5.5 20.5v-9M12 20.5V6.5M18.5 20.5v-6"/><path d="M3.5 20.5h17"/>',
    "refresh": '<path d="M19 12a7 7 0 1 1-2.4-5.3"/><path d="M19.5 4v4h-4"/>',
    "settings": '<circle cx="12" cy="12" r="3"/><path d="M12 4v2.5M12 17.5V20M4 12h2.5M17.5 12H20M6.4 6.4l1.8 1.8M15.8 15.8l1.8 1.8M17.6 6.4l-1.8 1.8M8.2 15.8l-1.8 1.8"/>',
    "dots": '<circle cx="6" cy="12" r="1.4"/><circle cx="12" cy="12" r="1.4"/><circle cx="18" cy="12" r="1.4"/>',
    "arrow_right": '<path d="M5 12h13M13.5 7.5 18.5 12l-5 4.5"/>',
    "eye": '<path d="M2.5 12S6 5.8 12 5.8 21.5 12 21.5 12 18 18.2 12 18.2 2.5 12 2.5 12z"/><circle cx="12" cy="12" r="2.8"/>',
    "eye_off": '<path d="M4 4l16 16"/><path d="M9.6 6.6A9.6 9.6 0 0 1 12 6.2c6 0 9.5 6.2 9.5 6.2a17 17 0 0 1-2.8 3.5"/><path d="M6.4 8.6A16.6 16.6 0 0 0 2.5 12.4S6 18.6 12 18.6c1.2 0 2.3-.2 3.3-.6"/>',
    "trash": '<path d="M4.5 7h15"/><path d="M9.5 7V4.6h5V7"/><path d="M6.6 7l.9 12.9a1 1 0 0 0 1 .9h7a1 1 0 0 0 1-.9L17.4 7"/><path d="M10.4 11v5.6M13.6 11v5.6"/>',
}

_FILLED = {"play", "sparkle"}


def icon(kind, x, y, size=24, color=INK, sw=1.7, opacity=None, name=None):
    """Icons are authored on a 24px grid and scaled, so `sw` stays the visible
    stroke width in canvas units instead of being rescaled twice."""
    raw = _ICONS[kind]
    if kind in _FILLED:
        raw = raw.replace("<path ", '<path fill="%s" stroke="none" ' % color)
    else:
        style = ('fill="none" stroke="%s" stroke-width="%s" stroke-linecap="round" '
                 'stroke-linejoin="round"' % (color, n(sw)))
        for tag in ("path", "circle", "rect"):
            raw = raw.replace("<%s " % tag, '<%s %s ' % (tag, style))
    s = size / 24.0
    return g("icon / %s" % (name or kind), raw,
             transform="translate(%s %s) scale(%s)" % (n(x), n(y), n(s)),
             opacity=opacity)


def glyph(name, cx, cy, size=20, color=INK, sw=1.7, bg=None, badge=None,
          opacity=None):
    """Icon optionally centred inside a soft circular chip."""
    parts = []
    if bg:
        parts.append(circle(cx, cy, size * (0.9 if badge is None else 0.95), fill=bg,
                            name="icon bg"))
    parts.append(icon(name, cx - size / 2, cy - size / 2, size, color, sw, opacity))
    if badge:
        parts.append(circle(cx + size * 0.72, cy - size * 0.72, 4.2, fill=badge,
                            stroke=WHITE, sw=1.6, name="badge dot"))
    return g("Glyph / %s" % name, *parts)


# ---------------------------------------------------------------- document
class Doc:
    def __init__(self, layer, bg=SURFACE, w=W, h=H):
        self.layer = layer
        self.bg = bg
        self.w = w
        self.h = h
        self.defs = []
        self.body = []

    def grad(self, id_, stops, x1=0.0, y1=0.0, x2=1.0, y2=1.0):
        s = "".join('<stop offset="%s" stop-color="%s"/>' % (n(o), c) for o, c in stops)
        self.defs.append('<linearGradient id="%s" x1="%s" y1="%s" x2="%s" y2="%s">%s'
                         "</linearGradient>" % (id_, n(x1), n(y1), n(x2), n(y2), s))
        return "url(#%s)" % id_

    def radial(self, id_, stops, cx=0.5, cy=0.5, r=0.5):
        s = "".join('<stop offset="%s" stop-color="%s" stop-opacity="%s"/>'
                    % (n(o), c, n(op)) for o, c, op in stops)
        self.defs.append('<radialGradient id="%s" cx="%s" cy="%s" r="%s">%s'
                         "</radialGradient>" % (id_, n(cx), n(cy), n(r), s))
        return "url(#%s)" % id_

    def clip_round(self, id_, x, y, w, h, rx):
        self.defs.append('<clipPath id="%s"><rect x="%s" y="%s" width="%s" height="%s" rx="%s"/>'
                         "</clipPath>" % (id_, n(x), n(y), n(w), n(h), n(rx)))
        return "url(#%s)" % id_

    def add(self, *parts):
        self.body.extend(p for p in parts if p)

    def render(self):
        defs = "<defs>%s</defs>" % "".join(self.defs) if self.defs else ""
        return ('<svg xmlns="http://www.w3.org/2000/svg" '
                'xmlns:xlink="http://www.w3.org/1999/xlink" '
                'id="%s" width="%s" height="%s" viewBox="0 0 %s %s">%s%s</svg>'
                % (esc(self.layer), n(self.w), n(self.h), n(self.w), n(self.h), defs,
                   g(self.layer, rect(0, 0, self.w, self.h, fill=self.bg, name="Canvas"),
                     *self.body)))


# ---------------------------------------------------------------- components
def status_bar(doc, dark=False, time="9:41"):
    c = WHITE if dark else INK
    bars = "".join(rect(308 + i * 4.2, 26 - (4 + i * 2.2), 2.6, 4 + i * 2.2,
                        fill=c, rx=1.2, name="Signal %d" % i) for i in range(4))
    cx = 331.0
    wifi = (pth("M %s %s A 6.4 6.4 0 0 1 %s %s" % (n(cx - 6.4), n(25.6), n(cx + 6.4), n(25.6)),
                stroke=c, sw=1.5, name="Wifi outer") +
            pth("M %s %s A 3.6 3.6 0 0 1 %s %s" % (n(cx - 3.6), n(26.4), n(cx + 3.6), n(26.4)),
                stroke=c, sw=1.5, name="Wifi inner") +
            circle(cx, 28.4, 1.2, fill=c, name="Wifi dot"))
    battery = (rect(343.5, 18.5, 22, 11, rx=3.4, stroke=c, sw=1.2, opacity=0.45,
                    name="Battery body") +
               rect(345.7, 20.7, 15.2, 6.6, rx=2, fill=c, name="Battery level") +
               rect(367, 21.7, 1.8, 4.6, rx=1, fill=c, opacity=0.45, name="Battery tip"))
    return g("System / Status bar",
             text(32, 27, time, 13.5, 700, c, name="Time"),
             g("Connectivity", bars, wifi, battery))



def home_indicator(doc, dark=False):
    return rect((W - 134) / 2, 826, 134, 5, fill=WHITE if dark else INK, rx=2.6,
                opacity=0.85 if not dark else 0.4, name="System / Home indicator")


def soft_shadow(doc, x, y, w, h, rx=R_CARD, color=SHADOW, lift=6, spread=0):
    """Flat approximation of AppShadows.card - Figma imports translucent rects
    reliably, SVG filters do not survive the round trip."""
    out = []
    for i in range(lift):
        d = lift - i
        out.append(rect(x - spread + d * 0.6, y + d * 1.15, w + spread * 2 - d * 1.2,
                        h + d * 1.4, fill=color, rx=rx + d * 0.5,
                        opacity=0.055, name="shadow %d" % i))
    return g("Shadow", *out)


def card(doc, x, y, w, h, fill=WHITE, rx=R_CARD, shadow=True, stroke=None,
         sw=1, name="Card", glow=False):
    parts = []
    if shadow:
        parts.append(soft_shadow(doc, x, y, w, h, rx,
                                 SHADOW_TEAL if glow else SHADOW))
    parts.append(rect(x, y, w, h, fill=fill, rx=rx, stroke=stroke, sw=sw, name=name))
    return g(name, *parts)


def eyebrow(doc, x, y, label, color=TEAL_LIGHT, anchor="start", size=10.5):
    return text(x, y, label, size, 700, color, anchor, spacing=1.6,
                caps=True, name="Eyebrow")


def section_header(doc, x, y, w, title, eyebrow_text=None, trailing=None,
                   size=19, color=INK):
    parts = []
    cy = y
    if eyebrow_text:
        parts.append(eyebrow(doc, x, cy, eyebrow_text))
        cy += 18
        parts.append(text(x, cy, title, size, 700, color, name="Title"))
        cy += 12
    else:
        parts.append(text(x, cy, title, size, 700, color, name="Title"))
        cy += 12
    if trailing:
        parts.append(trailing)
    return g("Section header", *parts), cy


def chip(doc, x, y, label, fg=TEAL, bg=MINT_SOFT, icon_name=None, pad_x=10,
         size=11.5, weight=700, h=26, radius=None):
    radius = radius if radius is not None else h / 2
    tw = measure(label, size, weight)
    w = pad_x * 2 + tw + (12 if icon_name else 0)
    parts = [rect(0, 0, w, h, fill=bg, rx=radius, name="Chip bg")]
    tx = pad_x
    if icon_name:
        parts.append(icon(icon_name, pad_x, (h - 13) / 2, 13, fg, 1.9, name="Chip icon"))
        tx = pad_x + 17
    parts.append(text(tx, h / 2 + size * 0.36, label, size, weight, fg, name="Chip label"))
    return g("Chip / %s" % label, *parts, transform="translate(%s %s)" % (n(x), n(y))), w


def button(doc, x, y, w, h, label, gradient=None, fill=None, fg=WHITE,
           icon_name=None, radius=R_BUTTON, size=15, weight=700, name="Button",
           stroke=None, sw=1.4):
    paint = gradient or fill or TEAL
    parts = [soft_shadow(doc, x, y, w, h, radius, SHADOW_TEAL, lift=5, spread=1),
             rect(x, y, w, h, fill=paint, rx=radius, stroke=stroke, sw=sw, name="Button bg")]
    if icon_name:
        parts.append(icon(icon_name, x + w / 2 - measure(label, size, weight) / 2 - 11,
                          y + h / 2 - 8, 16, fg, 2.1, name="Button icon"))
    parts.append(text(x + w / 2 + (8 if icon_name else 0), y + h / 2 + size * 0.36,
                      label, size, weight, fg, "middle", spacing=0.1, name="Button label"))
    return g(name, *parts)


def ghost_button(doc, x, y, w, h, label, fg=TEAL, bg=SURFACE_ALT, icon_name=None,
                 radius=R_BUTTON, size=14.5):
    b = button(doc, x, y, w, h, label, fill=bg, fg=fg, icon_name=icon_name,
               radius=radius, size=size, name="Button / secondary")
    return b


def field(doc, x, y, w, label, value="", icon_name=None, hint=None, filled=True,
          radius=R_FIELD, h=None, focused=False, suffix=None):
    label_h = 0
    y0 = y
    if label:
        label_h = 22
        y0 = y + 22
    h = h or 52
    parts = [rect(x, y0, w, h, fill=SURFACE if filled else SURFACE_MUTED, rx=radius,
                  stroke=TEAL if focused else OUTLINE, sw=1.8 if focused else 1.2,
                  name="Field bg")]
    tx = x + 14
    if icon_name:
        parts.append(icon(icon_name, x + 14, y0 + h / 2 - 9, 18,
                          TEAL if focused else INK_MUTED, 1.7, name="Field icon"))
        tx = x + 40
    parts.append(text(tx, y0 + h / 2 + 5, value if value else (hint or ""), 14.5,
                      500 if value else 400, INK if value else INK_MUTED,
                      name="Field value"))
    if suffix:
        parts.append(suffix)
    out = []
    if label:
        out.append(text(x, y + 14, label, 12, 700, INK_BODY, name="Field label"))
    out += parts
    return g("Field / %s" % (label or hint or "field"), *out)


def avatar(doc, cx, cy, r, image_label="Photo", ring=True, color=TEAL,
           initials=None, bg=MINT_SOFT):
    parts = [circle(cx, cy, r, fill=bg, name="Avatar fill"),
             rect(cx - r * 0.62, cy + r * 0.1, r * 1.24, r, rx=r * 0.6, fill=color,
                  opacity=0.18, name=image_label)]
    if initials:
        parts.append(text(cx, cy + r * 0.3, initials, r * 0.85, 700, color, "middle",
                          name="Initials"))
    else:
        parts.append(icon("user", cx - r * 0.55, cy - r * 0.62, r * 1.1, color, 1.8,
                          name="Placeholder"))
    if ring:
        parts.append(circle(cx, cy, r + 3, stroke=WHITE, sw=3, name="Ring"))
        parts.append(circle(cx, cy, r + 6.5, stroke=color, sw=1.2, opacity=0.28,
                            name="Ring outer"))
    return g("Avatar", *parts)


def progress_ring(doc, cx, cy, r, value, total, color=TEAL, track=DIVIDER,
                  sw=6, label=None, sub=None, size=17):
    c = 2 * 3.141592653589793 * r
    dash = c * (value / float(total))
    parts = [circle(cx, cy, r, stroke=track, sw=sw, name="Track", cap="butt"),
             circle(cx, cy, r, stroke=color, sw=sw, name="Progress",
                    dash="%.2f %.2f" % (dash, c - dash), cap="round",
                    transform="rotate(-90 %s %s)" % (n(cx), n(cy)))]
    if label:
        parts.append(text(cx, cy + size * 0.3, label, size, 700, INK, "middle",
                          name="Value"))
    if sub:
        parts.append(text(cx, cy + size * 0.3 + 13, sub, 9.5, 600, INK_MUTED, "middle",
                          name="Denominator"))
    return g("Progress ring", *parts)


def segmented(doc, x, y, w, h, options, active=0, fg_active=WHITE,
              bg_active=TEAL, bg=SURFACE_MUTED, radius=12, size=12.5):
    parts = [rect(x, y, w, h, fill=bg, rx=radius, name="Track")]
    each = w / len(options)
    for i, o in enumerate(options):
        if i == active:
            parts.append(rect(x + each * i + 2, y + 2, each - 4, h - 4, fill=bg_active,
                              rx=radius - 3, name="Active segment"))
        parts.append(text(x + each * i + each / 2, y + h / 2 + size * 0.35, o, size,
                          700 if i == active else 600,
                          fg_active if i == active else INK_MUTED, "middle",
                          name="Option %s" % o))
    return g("Segmented / %s" % ",".join(options), *parts)


def nav_bar(doc, items, active, y=None, x=PAGE, w=None):
    y = y if y is not None else 760
    w = w if w is not None else W - x * 2
    parts = [soft_shadow(doc, x, y, w, 66, 22, SHADOW, lift=5),
             rect(x, y, w, 66, fill=WHITE, rx=22, name="Nav bar bg")]
    each = w / len(items)
    for i, (name, ic) in enumerate(items):
        cx = x + each * i + each / 2
        on = i == active
        if on:
            parts.append(rect(cx - 26, y + 8, 52, 42, fill=MINT_SOFT, rx=15,
                              name="Active pill"))
        parts.append(icon(ic, cx - 11, y + 15, 22, TEAL if on else INK_MUTED, 1.9,
                          name="%s icon" % name))
        parts.append(text(cx, y + 44, name, 10, 700 if on else 600,
                          TEAL if on else INK_MUTED, "middle", name=name))
    return g("Component / TcNavBar", *parts)



def gradient_header(doc, x, y, w, h, title, subtitle=None, rx=R_CARD,
                    stops=None, trailing=None, leading=None):
    stops = stops or [(0, TEAL), (1, TEAL_LIGHT)]
    gid = doc.grad("hdr-%s" % uid(title), stops, 0, 0, 1, 1)
    parts = [rect(x, y, w, h, fill=gid, rx=rx, name="Header gradient")]
    parts.append(circle(x + w - 24, y + 6, 58, fill=WHITE, opacity=0.07, name="Glow 1"))
    parts.append(circle(x + 20, y + h - 4, 42, fill=WHITE, opacity=0.06, name="Glow 2"))
    ty = y + 34 if not subtitle else y + 30
    if leading:
        parts.append(leading)
    parts.append(text(x + 20 if not leading else x + 62, ty, title, 19, 700, WHITE,
                      name="Header title"))
    if subtitle:
        parts.append(text(x + 20 if not leading else x + 62, ty + 19, subtitle, 12,
                          500, "rgba(255,255,255,0.82)", name="Header subtitle"))
    if trailing:
        parts.append(trailing)
    return g("Component / TcPageHeader", *parts)


def sheet_scrim(doc, sheet_h, y=None):
    y = y if y is not None else H - sheet_h
    return rect(0, 0, W, H, fill=INK, opacity=0.42, name="Scrim")


def drag_handle(doc, cx, y):
    return rect(cx - 18, y, 36, 4.5, fill=OUTLINE, rx=2.3, name="Drag handle")


def skeleton(doc, x, y, w, h, rx=8, name="Skeleton"):
    return rect(x, y, w, h, fill=SURFACE_ALT, rx=rx, opacity=0.9, name=name)


def stat_tile(doc, x, y, w, h, icon_name, label, value, accent=TEAL,
              accent_soft=MINT_SOFT, unit=None, name=None):
    name = name or "Stat / %s" % label
    parts = [rect(x, y, w, h, fill=SURFACE_MUTED, rx=16, name="Tile bg"),
             rect(x + 14, y + 14, 30, 30, rx=10, fill=accent_soft, name="Icon chip"),
             icon(icon_name, x + 21, y + 21, 16, accent, 1.9, name="Icon"),
             text(x + 14, y + h - 26, label, 10.5, 600, INK_MUTED, spacing=0.4,
                  caps=True, name="Label"),
             text(x + 14, y + h - 8, value, 19, 700, INK, name="Value")]
    if unit:
        parts.append(text(x + 14 + measure(value, 19, 700) + 4, y + h - 8, unit, 10.5,
                          600, INK_MUTED, name="Unit"))
    return g(name, *parts)


def detail_row(doc, x, y, w, label, value, icon_name=None, value_color=INK,
               rule=True, name="Detail row"):
    parts = []
    tx = x
    if icon_name:
        parts.append(icon(icon_name, x, y - 10, 15, INK_MUTED, 1.8, name="Row icon"))
        tx = x + 21
    parts.append(text(tx, y, label, 13, 500, INK_MUTED, name="Label"))
    parts.append(text(x + w, y, value, 13.5, 700, value_color, "end", name="Value"))
    if rule:
        parts.append(line(x, y + 14, x + w, y + 14, stroke=DIVIDER, name="Divider"))
    return g(name, *parts)


def list_tile(doc, x, y, w, title, sub, icon_name=None, img=None, chevron=True,
              badge=None, h=64, rx=16, fill=WHITE, stroke=DIVIDER):
    parts = [rect(x, y, w, h, fill=fill, rx=rx, stroke=stroke, sw=1, name="Tile bg")]
    ix = x + 14
    if img:
        parts.append(rect(ix, y + (h - 44) / 2, 44, 44, fill=MINT_SOFT, rx=12, name=img))
        parts.append(icon("play" if icon_name is None else icon_name,
                          ix + 14, y + h / 2 - 8, 16, TEAL, 2.1, name="Thumb icon"))
        ix += 56
    elif icon_name:
        parts.append(rect(ix, y + (h - 40) / 2, 40, 40, rx=12, fill=SURFACE_ALT,
                          name="Icon chip"))
        parts.append(icon(icon_name, ix + 11, y + h / 2 - 9, 18, TEAL, 1.8, name="Icon"))
        ix += 52
    parts.append(text(ix, y + h / 2 - 2, title, 14.5, 700, INK, name="Title"))
    parts.append(text(ix, y + h / 2 + 15, sub, 11.5, 500, INK_MUTED, name="Subtitle"))
    if badge:
        parts.append(badge)
    if chevron:
        parts.append(icon("chevron_right", x + w - 28, y + h / 2 - 9, 18, INK_MUTED, 1.8,
                          name="Chevron"))
    return g("List tile / %s" % title, *parts)


def empty_state(doc, cx, cy, icon_name, title, message):
    parts = [circle(cx, cy - 22, 34, fill=SURFACE_ALT, name="Icon well"),
             icon(icon_name, cx - 15, cy - 37, 30, INK_MUTED, 1.7, name="Icon"),
             text(cx, cy + 26, title, 15.5, 700, INK, "middle", name="Title"),
             text(cx, cy + 45, message, 12, 500, INK_MUTED, "middle", name="Message")]
    return g("Component / TcEmptyState", *parts)


def phone_frame(doc):
    return rect(-1, -1, W + 2, H + 2, fill="none", stroke=INK, sw=2, rx=44,
                opacity=0.12, name="Device frame")


# ---------------------------------------------------------------- metrics
# Approximate advance widths so chips/buttons can auto-size without a font
# engine. Good enough at the sizes used here; Figma re-measures on import.
_AVG = {400: 0.512, 500: 0.528, 600: 0.545, 700: 0.562, 800: 0.578}


def measure(s, size, weight=400):
    f = _AVG.get(weight, 0.52)
    return len(str(s)) * size * f + (size * 0.02 * len(str(s)))


def uid(seed):
    out = ""
    for ch in str(seed):
        out += ch if ch.isalnum() else "-"
    return out[:24]


def wrap(s, max_chars):
    words = str(s).split()
    lines, cur = [], ""
    for wd in words:
        if len(cur) + len(wd) + 1 <= max_chars:
            cur = (cur + " " + wd).strip()
        else:
            if cur:
                lines.append(cur)
            cur = wd
    if cur:
        lines.append(cur)
    return lines
