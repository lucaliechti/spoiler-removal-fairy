#!/usr/bin/env bash
#
# Build distributable packages for Chrome, Firefox and Safari.
#
#   ./build.sh            # build chrome + firefox zips into dist/
#   ./build.sh safari     # also run the Safari Web Extension converter (macOS + Xcode)
#
set -euo pipefail
cd "$(dirname "$0")"

SRC="extension"
OUT="dist"
rm -rf "$OUT"
mkdir -p "$OUT/chrome" "$OUT/firefox"

# Files that ship in the extension (everything except the icon generator).
copy_src() {
  local dest="$1"
  mkdir -p "$dest/icons"
  cp "$SRC"/manifest.json "$SRC"/content.js "$SRC"/content.css \
     "$SRC"/popup.html "$SRC"/popup.css "$SRC"/popup.js "$dest/"
  cp "$SRC"/icons/icon16.png "$SRC"/icons/icon32.png \
     "$SRC"/icons/icon48.png "$SRC"/icons/icon128.png "$dest/icons/"
  cp -R "$SRC"/_locales "$dest/_locales"
}

copy_src "$OUT/firefox"   # Firefox keeps browser_specific_settings (gecko id)

copy_src "$OUT/chrome"
# Chrome tolerates but warns on browser_specific_settings; strip it for a clean load.
node -e '
  const fs = require("fs");
  const p = "'"$OUT"'/chrome/manifest.json";
  const m = JSON.parse(fs.readFileSync(p, "utf8"));
  delete m.browser_specific_settings;
  fs.writeFileSync(p, JSON.stringify(m, null, 2) + "\n");
'

# zip them up
( cd "$OUT/chrome"  && zip -qr -X ../spoiler-removal-fairy-chrome.zip .  )
( cd "$OUT/firefox" && zip -qr -X ../spoiler-removal-fairy-firefox.zip . )
echo "Built:"
echo "  $OUT/spoiler-removal-fairy-chrome.zip   (Load unpacked: chrome://extensions)"
echo "  $OUT/spoiler-removal-fairy-firefox.zip  (about:debugging > Load Temporary Add-on)"

if [ "${1:-}" = "safari" ]; then
  if ! command -v xcrun >/dev/null 2>&1; then
    echo "safari: xcrun not found — install Xcode + command line tools." >&2
    exit 1
  fi
  echo "Running Safari Web Extension converter..."
  xcrun safari-web-extension-converter "$OUT/chrome" \
    --project-location "$OUT/safari" \
    --app-name "SpoilerRemovalFairy" \
    --bundle-identifier "ch.local.spoiler-removal-fairy" \
    --no-open --force
  echo "Safari Xcode project: $OUT/safari  — open it, then Run to install into Safari."
fi
