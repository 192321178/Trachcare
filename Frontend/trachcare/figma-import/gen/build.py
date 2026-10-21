"""Generate the Figma-importable SVG bundle.

    python gen/build.py            # regenerate every screen
    python gen/build.py --check    # write to a temp dir and validate only

Each screen is a multi-layer 390x844 SVG (plus one landscape design-system
board). Figma imports `<g id>` as frames/groups and `<text>` as text layers.
"""

import os
import re
import sys
import tempfile
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from svg_kit import *          # noqa: E402
import design_system           # noqa: E402
import screens_a               # noqa: E402
import screens_b               # noqa: E402
import screens_c               # noqa: E402
import screens_d               # noqa: E402

OUT = os.path.abspath(os.path.join(HERE, "..", "svg-src"))

SCREENS = [
    design_system.board,
    screens_a.splash,
    screens_a.welcome,
    screens_a.login_patient,
    screens_a.login_doctor,
    screens_a.login_admin,
    screens_a.dashboard_screen,
    screens_a.spigotting_sheet,
    screens_a.videos,
    screens_a.video_player,
    screens_b.records,
    screens_b.report_form,
    screens_b.report_view,
    screens_b.calendar,
    screens_b.profile,
    screens_b.edit_profile,
    screens_b.drawer,
    screens_b.notifications,
    screens_b.about,
    screens_c.overview,
    screens_c.patients,
    screens_c.chart,
    screens_c.day_report,
    screens_c.calendar,
    screens_c.add_patient,
    screens_c.videos,
    screens_c.profile,
    screens_c.edit_profile,
    screens_d.console,
    screens_d.doctors,
    screens_d.doctor_detail,
    screens_d.add_doctor,
    screens_d.patients,
    screens_d.patient_chart,
    screens_d.calendar,
    screens_d.video_upload,
    screens_d.profile,
]

BAD_OPACITY = re.compile(r'opacity="(nan|inf|None|-?\d+(?:\.\d+)?e[+-]?\d+)"', re.I)

TEXT_TAG = re.compile(r'<text ([^>]*)>([^<]*)</text>')
ATTR = re.compile(r'([\w-]+)="([^"]*)"')

# The rasteriser falls back to a wider face than Plus Jakarta Sans, so allow
# the same slack before calling a run clipped.
SLACK = 1.06


def check_text_runs(svg):
    """Flag <text> runs whose estimated advance width leaves the canvas."""
    root = re.search(r'<svg[^>]*\bwidth="(\d+)"', svg)
    if not root:
        return []
    canvas = float(root.group(1))
    out = []
    for attrs, body in TEXT_TAG.findall(svg):
        a = dict(ATTR.findall(attrs))
        if "x" not in a or not body.strip():
            continue
        size = float(a.get("font-size", 14))
        anchor = a.get("text-anchor", "start")
        w = measure(body, size, int(float(a.get("font-weight", 400)))) * SLACK
        x = float(a["x"])
        if anchor == "end":
            left, right = x - w, x
        elif anchor == "middle":
            left, right = x - w / 2, x + w / 2
        else:
            left, right = x, x + w
        if right > canvas - 2 or left < 2:
            out.append('text clipped: "%s" spans %.0f..%.0f of %.0f'
                       % (body[:38], left, right, canvas))
    return out


def validate(slug, svg):
    problems, notes = [], []
    try:
        ET.fromstring(svg)
    except ET.ParseError as e:
        m = re.search(r"column (\d+)", str(e))
        col = int(m.group(1)) if m else 0
        problems.append("XML: %s | %s" % (e, svg[max(0, col - 90):col + 30]))
    if BAD_OPACITY.search(svg):
        problems.append("non-finite opacity attribute")
    for m in re.finditer(r'(?:x|x1|x2|cx)="(-\d+(?:\.\d+)?)"', svg):
        if float(m.group(1)) < -4:
            problems.append("off-canvas geometry %s" % m.group(0))
    ids = re.findall(r'<g id="([^"]*)"', svg)
    dupes = sorted({i for i in ids if ids.count(i) > 1})
    if dupes:
        # Figma treats layer names as labels, not identifiers - harmless.
        notes.append("repeated layer names: %s" % ", ".join(dupes[:6]))
    notes.extend(check_text_runs(svg))
    return problems, notes


def main():
    argv = sys.argv[1:]
    if "--to" in argv:
        out = argv[argv.index("--to") + 1]
    elif "--check" in argv:
        out = tempfile.mkdtemp(prefix="trachcare-svg-")
    else:
        out = OUT
    os.makedirs(out, exist_ok=True)
    failed = []
    written = 0
    for fn in SCREENS:
        slug, doc = fn()
        svg = doc.render()
        problems, notes = validate(slug, svg)
        if problems:
            failed.append((slug, problems))
            print("FAIL %s" % slug)
            for p in problems:
                print("     %s" % p)
            continue
        path = os.path.join(out, slug + ".svg")
        with open(path, "w", encoding="utf-8") as f:
            f.write(svg)
        written += 1
        print("ok   %-34s %6.1f KB%s" % (slug + ".svg", len(svg) / 1024.0,
                                         "   (%s)" % "; ".join(notes) if notes else ""))
    print("\n%d screens written to %s" % (written, out))
    if failed:
        print("%d screens failed validation" % len(failed))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
