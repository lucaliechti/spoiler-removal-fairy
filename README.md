# Spoiler Removal Fairy 🧚🏻‍♀️

A small browser extension that **completely removes the spoiler “highlights”
strip** SRF Play shows inside its video player. On sports pages that strip almost
always spoils the result (final scores, goal thumbnails), so this collapses it
before you see it.

One toggle: **Hide highlights bar — On / Off**, in the toolbar popup. The UI is
localized in **English, German, French and Italian** (follows your browser’s
language).

Works in **Chrome**, **Firefox**, and **Safari** from a single source.

<img src="extension/icons/icon128.png" width="96" alt="SpoilerRemovalFairy icon" />

---

## How it works

The spoiler strip is **part of the video player**, not a separate page section.
SRF uses the SRG “Letterbox” player (a Video.js skin). Its *subdivisions /
segments* bar renders goal/score thumbnails **inside the player’s fixed 16:9
box**, and the skin reserves room for it with a CSS custom property:

```css
.vjs-srgssr-skin.srgssr-has-subdivisions .vjs-tech { height: calc(100% - var(--segment-height)); }
.srgssr-subdivisions { height: var(--segment-height); }
```

That reserved height is exactly why `display:none` on the strip alone just
leaves a **black band** — the video stays shrunk. So the extension does two
things (pure CSS, in `content.css`):

1. **Forces `--segment-height: 0`** on the player → `calc(100% - 0) = 100%`, so
   the video fills the whole box again and the reserved space collapses.
2. **`display:none` on `.srgssr-subdivisions`** → removes the strip itself.

The player bundle never uses `!important` anywhere, so these `!important`
declarations reliably win over the player’s inline value (verified: overriding
an inline `--segment-height: 84px` resolves to `0px`).

Because it’s CSS, it works no matter how often the single-page app re-renders or
navigates — no `MutationObserver` needed, and it **does not** touch the
“Weitere … Highlights” related-content swimlanes further down the page.

The whole thing is gated on `<html data-srf-hh="on">`. `content.js` just sets
that attribute from a single `hideHighlights` boolean in `storage.local`; every
open SRF tab reacts instantly via `storage.onChanged`, so the toggle takes
effect with **no reload**.

---

## Install (developer / unpacked)

### Chrome (also Edge / Brave / other Chromium)
1. `chrome://extensions`
2. Enable **Developer mode** (top-right).
3. **Load unpacked** → select the `extension/` folder.

### Firefox
1. `about:debugging#/runtime/this-firefox`
2. **Load Temporary Add-on…** → select `extension/manifest.json`.
   (Temporary add-ons clear on restart. For a permanent install, sign the zip
   via [AMO](https://addons.mozilla.org/developers/).)

### Safari (macOS, needs Xcode)
Safari only loads web extensions wrapped in an app:
```bash
./build.sh safari
```
This runs `xcrun safari-web-extension-converter` and creates an Xcode project in
`dist/safari/`. Open it, press **Run**, then enable the extension in
**Safari → Settings → Extensions** (you may need to allow unsigned extensions
via **Develop → Allow Unsigned Extensions**).

---

## Build redistributable zips

```bash
./build.sh          # dist/spoiler-removal-fairy-chrome.zip + ...-firefox.zip
./build.sh safari   # the above + a Safari Xcode project
```

The Chrome zip has `browser_specific_settings` stripped (Chrome warns on it);
the Firefox zip keeps the required `gecko` id.
