"""Emit a single self-contained HTML showcase of every exported screen.

The output (`figma-import/TrachCare-UI-design.html`) inlines each SVG as a
base64 data URI so it can be mailed, dropped on a phone, or opened offline with
no assets alongside it.
"""

import base64
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SVG = os.path.join(HERE, "..", "svg-src")
OUT = os.path.join(HERE, "..", "TrachCare-UI-design.html")

# (slug, title, group) — group drives the filter chips.
SCREENS = [
    ("00-design-system", "Design system", "system"),
    ("01-splash", "Splash", "patient"),
    ("02-welcome-role-picker", "Welcome / role picker", "shared"),
    ("03-login-patient", "Login · Patient", "shared"),
    ("04-login-doctor", "Login · Doctor", "shared"),
    ("05-login-admin", "Login · Admin", "shared"),
    ("06-patient-home-dashboard", "Home dashboard", "patient"),
    ("07-patient-spigotting-sheet", "Spigotting check-in", "patient"),
    ("08-patient-therapy-videos", "WatchZone videos", "patient"),
    ("09-patient-video-player", "Video player", "patient"),
    ("10-patient-daily-records", "Daily records", "patient"),
    ("11-patient-daily-report-form", "Daily report form", "patient"),
    ("12-patient-daily-report-view", "Daily report view", "patient"),
    ("13-patient-report-calendar", "Report calendar", "patient"),
    ("14-patient-profile", "Profile", "patient"),
    ("15-patient-edit-profile", "Edit profile", "patient"),
    ("16-patient-navigation-drawer", "Navigation drawer", "patient"),
    ("17-patient-notification-center", "Notifications", "patient"),
    ("18-patient-about", "About", "patient"),
    ("19-doctor-overview", "Doctor overview", "doctor"),
    ("20-doctor-patients-list", "My patients", "doctor"),
    ("21-doctor-patient-chart", "Patient chart", "doctor"),
    ("22-doctor-daily-report", "Day report", "doctor"),
    ("23-doctor-report-calendar", "Report calendar", "doctor"),
    ("24-doctor-add-patient", "Add patient", "doctor"),
    ("25-doctor-therapy-videos", "Therapy videos", "doctor"),
    ("26-doctor-profile", "Profile", "doctor"),
    ("27-doctor-edit-profile", "Edit profile", "doctor"),
    ("28-admin-console", "Admin console", "admin"),
    ("29-admin-doctors-list", "Doctors roster", "admin"),
    ("30-admin-doctor-detail", "Doctor detail", "admin"),
    ("31-admin-add-doctor", "Add doctor", "admin"),
    ("32-admin-patients-list", "Patients roster", "admin"),
    ("33-admin-patient-chart", "Patient chart", "admin"),
    ("34-admin-patient-calendar", "Patient calendar", "admin"),
    ("35-admin-publish-video", "Publish video", "admin"),
    ("36-admin-profile", "Profile", "admin"),
]

GROUP_LABEL = {
    "system": "Design system",
    "shared": "Shared entry",
    "patient": "Patient flow",
    "doctor": "Doctor flow",
    "admin": "Admin flow",
}

TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>TrachCare — full app UI design</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
  :root {
    --ink: #0E2A2A;
    --muted: #5F7A7A;
    --teal: #0F6E6E;
    --mint: #14C0A8;
    --soft: #E8F6F3;
    --line: #D9E7E5;
    --bg: #F6FAF9;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0; background: var(--bg); color: var(--ink);
    font-family: "Plus Jakarta Sans", -apple-system, Segoe UI, Roboto, sans-serif;
    -webkit-font-smoothing: antialiased;
  }
  .hero {
    padding: 64px 28px 56px; text-align: center; color: #fff;
    background: radial-gradient(120% 120% at 12% 0%, #14C0A8 0%, #0F6E6E 52%, #0A4E52 100%);
  }
  .hero .mark {
    display: inline-flex; align-items: center; gap: 10px;
    font-size: 13px; font-weight: 700; letter-spacing: .18em; text-transform: uppercase;
    opacity: .92;
  }
  .hero .mark i {
    width: 26px; height: 26px; border-radius: 9px; background: rgba(255,255,255,.22);
    display: inline-block; position: relative;
  }
  .hero .mark i::after {
    content: ""; position: absolute; inset: 7px 5px; border-radius: 4px;
    border: 2px solid #fff; border-top: 0; border-left: 0;
  }
  .hero h1 { font-size: clamp(30px, 5vw, 52px); line-height: 1.08; margin: 18px 0 14px; font-weight: 800; letter-spacing: -.02em; }
  .hero p { max-width: 640px; margin: 0 auto 26px; font-size: clamp(15px, 1.6vw, 18px); line-height: 1.65; opacity: .93; }
  .chips { display: flex; flex-wrap: wrap; gap: 8px; justify-content: center; }
  .chips span {
    background: rgba(255,255,255,.16); border: 1px solid rgba(255,255,255,.3);
    border-radius: 999px; padding: 7px 15px; font-size: 12.5px; font-weight: 600;
  }
  .bar {
    position: sticky; top: 0; z-index: 5; background: rgba(246,250,249,.94);
    backdrop-filter: blur(10px); border-bottom: 1px solid var(--line);
    padding: 14px 20px; display: flex; gap: 8px; align-items: center;
    justify-content: center; flex-wrap: wrap;
  }
  .bar button {
    font: inherit; font-size: 13px; font-weight: 600; cursor: pointer;
    border: 1px solid var(--line); background: #fff; color: var(--muted);
    padding: 8px 16px; border-radius: 999px; transition: .18s;
  }
  .bar button:hover { border-color: var(--mint); color: var(--teal); }
  .bar button.on { background: var(--teal); border-color: var(--teal); color: #fff; }
  .bar .count { font-size: 12.5px; color: var(--muted); margin-left: 6px; font-weight: 600; }
  main { max-width: 1500px; margin: 0 auto; padding: 8px 24px 64px; }
  .band {
    margin: 44px 0 20px; display: flex; align-items: baseline; gap: 14px;
    border-bottom: 1px solid var(--line); padding-bottom: 12px;
  }
  .band h2 { margin: 0; font-size: 21px; font-weight: 800; letter-spacing: -.01em; }
  .band em { font-style: normal; font-size: 13px; color: var(--muted); }
  .grid { display: grid; gap: 30px 22px; grid-template-columns: repeat(auto-fill, minmax(232px, 1fr)); }
  .grid.system { grid-template-columns: minmax(320px, 880px); justify-content: center; }
  figure { margin: 0; }
  .phone {
    position: relative; background: #10201F; border-radius: 34px; padding: 9px;
    box-shadow: 0 14px 34px -14px rgba(10,60,60,.42); cursor: zoom-in; transition: .2s;
  }
  .phone::before {
    content: ""; position: absolute; top: 17px; left: 50%; transform: translateX(-50%);
    width: 74px; height: 5px; border-radius: 999px; background: rgba(255,255,255,.28); z-index: 2;
  }
  .phone img { display: block; width: 100%; border-radius: 26px; background: #fff; }
  figure:hover .phone { transform: translateY(-5px); box-shadow: 0 22px 44px -14px rgba(10,60,60,.5); }
  figure.board .phone { border-radius: 20px; padding: 6px; }
  figure.board .phone::before { display: none; }
  figure.board .phone img { border-radius: 14px; }
  figcaption { margin-top: 11px; text-align: center; font-size: 12.5px; font-weight: 600; color: var(--muted); }
  figcaption b { display: block; color: var(--ink); font-size: 13.5px; font-weight: 700; margin-bottom: 2px; }
  .lb {
    position: fixed; inset: 0; background: rgba(6,22,22,.9); display: none;
    align-items: center; justify-content: center; z-index: 20; padding: 4vh 4vw;
  }
  .lb.on { display: flex; }
  .lb img { max-width: 100%; max-height: 88vh; border-radius: 18px; box-shadow: 0 30px 80px rgba(0,0,0,.6); }
  .lb .nav, .lb .close { position: fixed; background: rgba(255,255,255,.12); border: 1px solid rgba(255,255,255,.26); color: #fff; font: inherit; cursor: pointer; border-radius: 999px; }
  .lb .nav { top: 50%; transform: translateY(-50%); width: 46px; height: 46px; font-size: 20px; line-height: 1; }
  .lb .nav.prev { left: 18px; } .lb .nav.next { right: 18px; }
  .lb .close { top: 20px; right: 20px; padding: 9px 18px; font-size: 13px; font-weight: 600; }
  .lb .cap { position: fixed; bottom: 22px; left: 0; right: 0; text-align: center; color: rgba(255,255,255,.85); font-size: 13.5px; font-weight: 600; }
  footer { border-top: 1px solid var(--line); background: #fff; padding: 40px 24px 56px; }
  footer .cols { max-width: 1100px; margin: 0 auto; display: grid; gap: 30px; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
  footer h3 { margin: 0 0 9px; font-size: 12px; letter-spacing: .13em; text-transform: uppercase; color: var(--teal); }
  footer p { margin: 0; font-size: 14px; line-height: 1.7; color: var(--muted); }
  @media (max-width: 700px) {
    .hero { padding: 46px 18px 40px; }
    main { padding: 8px 14px 48px; }
    .grid { gap: 22px 14px; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); }
    .phone { border-radius: 22px; padding: 6px; }
    .phone img { border-radius: 16px; }
    .phone::before { top: 11px; width: 46px; height: 4px; }
    figcaption { font-size: 11px; }
  }
</style>
</head>
<body>
<header class="hero">
  <span class="mark"><i></i> TrachCare</span>
  <h1>The whole app, redesigned</h1>
  <p>Modern clinical calm — deep teal and mint on near-white, soft shadows, 20&nbsp;px cards.
     Every screen of the Patient, Doctor and Admin flows, exported at 390&nbsp;&times;&nbsp;844.</p>
  <div class="chips">
    <span>__COUNT__ screens</span><span>3 roles</span><span>390 &times; 844</span>
    <span>Figma-ready layers</span><span>Flutter &middot; Material 3</span>
  </div>
</header>

<nav class="bar" id="bar">
  <button data-f="all" class="on">All</button>
  <button data-f="system">Design system</button>
  <button data-f="shared">Shared entry</button>
  <button data-f="patient">Patient</button>
  <button data-f="doctor">Doctor</button>
  <button data-f="admin">Admin</button>
  <span class="count" id="count"></span>
</nav>

<main id="main"></main>

<footer>
  <div class="cols">
    <div>
      <h3>Design direction</h3>
      <p>One teal family carries all three roles, with violet reserved for Admin so staff
         screens never read as patient screens. Type is Plus Jakarta Sans throughout.</p>
    </div>
    <div>
      <h3>How it was built</h3>
      <p>Tokens live in <code>lib/style/design_system.dart</code> and the widget kit in
         <code>lib/components/ui_kit.dart</code>. These images come from the same values,
         regenerated by <code>figma-import/gen/build.py</code>, so the page cannot drift from the app.</p>
    </div>
    <div>
      <h3>For designers</h3>
      <p>The <code>figma-import/svg-src</code> folder holds the same __COUNT__ screens as layered
         SVGs — import them straight into Figma and every group and text run stays editable.</p>
    </div>
  </div>
</footer>

<div class="lb" id="lb">
  <button class="nav prev" id="prev" aria-label="Previous">&#8249;</button>
  <img id="lbi" alt="">
  <button class="nav next" id="next" aria-label="Next">&#8250;</button>
  <button class="close" id="closeb">Close &#10005;</button>
  <div class="cap" id="cap"></div>
</div>

<script>
const S = __DATA__;
const LBL = __LABELS__;
const ORDER = ["system", "shared", "patient", "doctor", "admin"];
let filter = "all", open = -1, shown = [];

function matches(s) { return filter === "all" || s.grp === filter; }

function render() {
  const m = document.getElementById("main");
  m.innerHTML = "";
  shown = S.filter(matches);
  ORDER.forEach(g => {
    const items = shown.filter(s => s.grp === g);
    if (!items.length) return;
    if (filter === "all") {
      const b = document.createElement("div");
      b.className = "band";
      b.innerHTML = `<h2>${LBL[g]}</h2><em>${items.length} screen${items.length > 1 ? "s" : ""}</em>`;
      m.appendChild(b);
    }
    const grid = document.createElement("div");
    grid.className = "grid" + (g === "system" ? " system" : "");
    items.forEach(s => {
      const f = document.createElement("figure");
      if (s.grp === "system") f.className = "board";
      f.innerHTML =
        `<div class="phone" data-i="${S.indexOf(s)}"><img src="data:image/svg+xml;base64,${s.b64}" alt="${s.title}" loading="lazy"></div>` +
        `<figcaption><b>${s.title}</b>${s.slug.slice(0, 2)}</figcaption>`;
      grid.appendChild(f);
    });
    m.appendChild(grid);
  });
  document.getElementById("count").textContent = shown.length + " of " + S.length;
}

function lightbox(i) {
  open = i;
  const s = S[i];
  document.getElementById("lbi").src = "data:image/svg+xml;base64," + s.b64;
  document.getElementById("cap").textContent = LBL[s.grp] + "  ·  " + s.title;
  document.getElementById("lb").classList.add("on");
}

function step(d) {
  const pos = shown.indexOf(S[open]);
  const nx = shown[pos + d];
  if (nx) lightbox(S.indexOf(nx));
}

document.getElementById("bar").addEventListener("click", e => {
  const b = e.target.closest("button");
  if (b) { location.hash = b.dataset.f; setFilter(b.dataset.f); }
});

document.getElementById("main").addEventListener("click", e => {
  const p = e.target.closest(".phone");
  if (p) lightbox(+p.dataset.i);
});

document.getElementById("closeb").onclick = () => document.getElementById("lb").classList.remove("on");
document.getElementById("prev").onclick = () => step(-1);
document.getElementById("next").onclick = () => step(1);
document.getElementById("lb").addEventListener("click", e => {
  if (e.target.id === "lb") document.getElementById("lb").classList.remove("on");
});
document.addEventListener("keydown", e => {
  if (!document.getElementById("lb").classList.contains("on")) return;
  if (e.key === "Escape") document.getElementById("lb").classList.remove("on");
  if (e.key === "ArrowLeft") step(-1);
  if (e.key === "ArrowRight") step(1);
});

function setFilter(f) {
  if (f !== "all" && !LBL[f]) return;
  filter = f;
  document.querySelectorAll(".bar button").forEach(x => x.classList.toggle("on", x.dataset.f === f));
  render();
}

window.addEventListener("hashchange", () => setFilter(location.hash.slice(1)));

setFilter(location.hash.slice(1) || "all");
</script>
</body>
</html>
"""


def main():
    payload = []
    for slug, title, grp in SCREENS:
        path = os.path.join(SVG, slug + ".svg")
        if not os.path.exists(path):
            raise SystemExit("missing SVG: " + path)
        with open(path, "rb") as fh:
            raw = fh.read()
        payload.append({
            "slug": slug,
            "title": title,
            "grp": grp,
            "b64": base64.b64encode(raw).decode("ascii"),
        })

    html = (TEMPLATE
            .replace("__DATA__", json.dumps(payload, separators=(",", ":")))
            .replace("__LABELS__", json.dumps(GROUP_LABEL))
            .replace("__COUNT__", str(len(payload))))

    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(html)
    kb = os.path.getsize(OUT) / 1024
    print("wrote %s  (%d screens, %.0f KB)" % (OUT, len(payload), kb))


if __name__ == "__main__":
    main()
