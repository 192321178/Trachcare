#!/bin/bash
# Renders svg-src/*.png at 390x944 (headless Edge reserves ~100px of window
# chrome, so 390x844 clips the bottom nav band).
cd "$(dirname "$0")/.." || exit 1
EDGE="/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
[ -x "$EDGE" ] || EDGE="/c/Program Files/Microsoft/Edge/Application/msedge.exe"
mkdir -p png
for f in "$@"; do
  base=$(basename "$f" .svg)
  rm -f "png/$base.png"
  "$EDGE" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
    --window-size=390,944 \
    --screenshot="C:/Users/AD-LAB/trachcare/figma-import/png/$base.png" \
    "file:///C:/Users/AD-LAB/trachcare/figma-import/svg-src/$base.svg" >/dev/null 2>&1
done
sleep 4
ls -l png | tail -n +2
