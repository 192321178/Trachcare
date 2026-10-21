# TrachCare — Figma screens

37 importable SVG screens plus a design-system board, generated from the same
design tokens the redesigned Flutter app uses.

```
figma-import/
  svg-src/     00-design-system.svg, 01..36-*.svg   <- import these into Figma
  png/         rendered previews of every screen
  gen/         the Python generator (source of truth)
  preview.html contact sheet — open in a browser to review all screens at once
  TrachCare-UI-design.html   single self-contained page for sharing
```

The 37 files in `svg-src/` are the whole deliverable. Nothing else is needed to
import, and `png/` plus `preview.html` are safe to delete.

## Share with anyone

`TrachCare-UI-design.html` has every screen inlined as base64, so it is one file
with no assets beside it — mail it, drop it on a phone, or send it in chat and it
still opens offline. Filter chips jump between flows, and a URL hash deep-links
into one: `TrachCare-UI-design.html#doctor`. Screens open full size in a
lightbox (arrow keys and `Esc`).

```sh
python gen/showcase.py    # rebuild the page after regenerating the SVGs
```

## Import into Figma

1. Install **Plus Jakarta Sans** first (Google Fonts). Without it Figma substitutes
   the nearest available face and text layers will sit slightly wide.
2. In Figma: **Place image / Import file** (or just drag the SVGs onto the canvas).
   You can select all 37 at once.
3. Each `<g id>` becomes a named frame or group and each `<text>` an editable text
   layer, so the screens arrive as real layers rather than flattened artwork.
4. Phone frames are **390 × 844**; the design-system board is 1300 × 2880.

Two things Figma will not carry over, by design:

- **Shadows** are approximated with stacked translucent rects (SVG filters do not
  survive the round trip). Group `Shadow` can be deleted and replaced with a real
  Figma effect if you prefer.
- **Per-corner radii** are `<path>` elements, not rounded rects, because SVG `rx`
  rounds all four corners.

## What is in the bundle

| File | Screen |
| --- | --- |
| `00-design-system.svg` | Tokens, type scale, radius/spacing, widget kit, file map |
| `01-splash` | Splash |
| `02-welcome-role-picker` | Role picker |
| `03-login-patient` / `04-login-doctor` / `05-login-admin` | Auth, one layout, three roles |
| `06-patient-home-dashboard` | Home |
| `07-patient-spigotting-sheet` | Spigotting check-in |
| `08-patient-therapy-videos` / `09-patient-video-player` | WatchZone |
| `10-patient-daily-records` | Daily records |
| `11-patient-daily-report-form` / `12-patient-daily-report-view` | Daily queries |
| `13-patient-report-calendar` | Report history |
| `14-patient-profile` / `15-patient-edit-profile` | Profile |
| `16-patient-navigation-drawer` | Drawer |
| `17-patient-notification-center` | Notifications |
| `18-patient-about` | About |
| `19-doctor-overview` | Doctor shell tab: updates strip, shortcuts, lesson carousel |
| `20-doctor-patients-list` | Searchable roster with alert dots and Chart chips |
| `21-doctor-patient-chart` | Vitals tiles, identity / airway / blood-work groups |
| `22-doctor-daily-report` | Read-only day report with Yes / No answer badges |
| `23-doctor-report-calendar` | Month grid, legend, selected-day summary |
| `24-doctor-add-patient` | Photo picker and the two form cards |
| `25-doctor-therapy-videos` | Lesson hero plus compact list rows |
| `26-doctor-profile` / `27-doctor-edit-profile` | Clinician record and its edit form |
| `28-admin-console` | Stat row, three destinations, export card |
| `29-admin-doctors-list` | Medical-team roster with a live search value |
| `30-admin-doctor-detail` | Doctor record with remove, edit and their-patients |
| `31-admin-add-doctor` | Credential form inside the Admin shell tab |
| `32-admin-patients-list` | All patients, alarm dot on the flagged chart |
| `33-admin-patient-chart` | Same chart layout as 21 — one shared generator |
| `34-admin-patient-calendar` | Read-only view of a submitted report |
| `35-admin-publish-video` | Title, description, file and thumbnail pick tiles |
| `36-admin-profile` | Violet administrator hero and credentials |

## Visual direction

*Modern clinical calm* — deep teal and mint on near-white, generous whitespace,
soft shadows, 20 px cards. The brand hue family is unchanged from the previous
design. Doctor screens keep the teal brand; Admin screens carry the same layout
with the violet accent already used by `AppColors.violet`.

## Regenerating

The export cannot drift from the app: `gen/svg_kit.py` mirrors the tokens in
[`lib/style/design_system.dart`](../lib/style/design_system.dart), and the staff
chrome in [`gen/role_kit.py`](gen/role_kit.py) mirrors `Appbar.dart`,
`NAppbar.dart`, `TcNavBar`, `TcProfileHero` and `TcRosterScreen`.

```sh
python gen/build.py                    # write all 37 SVGs and validate them
python gen/build.py --check            # validate into a temp dir, leave svg-src alone
bash gen/render.sh svg-src/*.svg       # refresh png/ previews (needs MS Edge)
```

`build.py` fails the build on malformed XML, non-finite opacity, off-canvas
geometry, and any text run whose estimated width leaves the canvas.

## Scope

All three flows — Patient, Doctor and Admin — are redesigned and exported. The
staff roles now share one implementation each: `TcRosterScreen` for every people
list, `TcVideoLibrary` for both video tabs, one `PatientDetails` chart, and one
profile/edit pair per role, all built from `ui_kit.dart` on top of
`style/design_system.dart`.
