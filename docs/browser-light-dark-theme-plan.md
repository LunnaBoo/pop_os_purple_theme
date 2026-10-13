# Browser light/dark theme — implementation plan

**Status:** planned, not yet built
**Scope:** make LibreWolf **and** Firefox browser chrome (tabs, toolbar,
sidebar, urlbar, menus, new-tab) switch light↔dark **live** with the
existing `Alt+Shift+P` system toggle.
**Out of scope:** designing/building the actual light theme art. That is
built externally and dropped in; this document defines the contract it
must satisfy and the repo wiring.

The theme itself is built elsewhere. Everything under
"Deliverables" is what gets produced externally; everything under
"Integration" is what this repo does once those artifacts land.

---

## 1. Locked decisions

1. **Artifact scope:** scheme-aware theme XPI (light + dark variants)
   **plus** a light chrome CSS layer.
2. **File layout:** same filenames / in-place replace. The light CSS is
   added as a new file imported from the existing `userChrome.css` /
   `userContent.css`; the XPI keeps the name
   `cosmic-purple@lainos.local.xpi`.

Consequence: **no changes to `themes/textfox.sh`,
`themes/cosmic-purple-toggle.sh`, or `themes/install-shortcut.sh` are
required.** `textfox.sh` already copies the whole `chrome/` directory and
the fixed XPI name, so a re-run installs the new content automatically.

---

## 2. Current state (evidence)

- Live LibreWolf profile: `~/.config/librewolf/librewolf/zvr304mw.default-default`
  - `prefs.js`: `browser.theme.toolbar-theme = 0` (dark, pinned)
  - `prefs.js`: `extensions.activeThemeID = "cosmic-purple@lainos.local"`
    (the XPI **is** active in this profile)
  - `widget.use-xdg-desktop-portal.settings` absent → default `2` (auto),
    i.e. the XDG portal path is available.
- Websites already follow the system scheme via
  `themes/librewolf-color-scheme.sh` (disables RFP, enables FPP with a
  `CSSPrefersColorScheme` exemption). Firefox (no RFP by default) already
  follows the system scheme out of the box.
- **Only the browser chrome is stuck dark.**

### Why the chrome doesn't switch today

The active theme XPI is **single-variant dark**, so Gecko pins
`browser.theme.toolbar-theme = 0`. Chrome-context
`prefers-color-scheme` derives from the active theme, so a plain
`@media (prefers-color-scheme)` block in `userChrome.css` would **never**
flip — regardless of what the OS reports. The XPI has to become
scheme-aware as well.

There are two independent hardcoded sources of chrome colour:

1. `themes/textfox/chrome/config.css` — the rice's explicit surfaces
   (`--tf-bg: #2a1036`, `--lwt-accent-color`, sidebar `#3c2147`, header
   `#2a1036`, newtab/in-content backgrounds).
2. `cosmic-purple@lainos.local.xpi` — the WebExtension theme's
   `theme.colors` block (toolbar/frame/popup/field/icons).

Both must get a light variant.

---

## 3. Live mechanism (no plumbing changes)

```
Alt+Shift+P
  └─ themes/cosmic-purple-toggle.sh
       └─ gsettings set org.gnome.desktop.interface color-scheme \
            prefer-light | prefer-dark
            └─ XDG portal: org.freedesktop.appearance → color-scheme
                 └─ Gecko LookAndFeel live update
                      ├─ chrome prefers-color-scheme re-evaluates
                      │    → the light CSS layer switches
                      └─ LightweightThemeConsumer re-picks
                           theme (light) vs dark_theme (dark)
                           → the XPI colors switch
```

This is the same live path kitty already uses (see README → kitty). It is
**restart-free** while the browser is running.

---

## 4. Deliverable A — scheme-aware theme XPI

Rebuild `themes/textfox/cosmic-purple@lainos.local.xpi` so its
`manifest.json` ships **both** variants. Key facts (verified against MDN /
Extension Workshop / the built-in `firefox-light-dark` theme):

- `theme` = the variant used in **light** mode.
- `dark_theme` = the variant used in **dark** mode (same structure as
  `theme`: `images`, `properties`, `colors`).
- `color_scheme` and `content_color_scheme` live under
  **`theme.properties`** (not at the top level of `theme`). Values:
  `auto` | `light` | `dark` | `system`. Use `"system"` so the chrome and
  content schemes follow the OS.
- **Bump `version`** (e.g. `1.0` → `1.1.0`). Same-id XPI content swaps with
  an unchanged version may not be re-read.

### Target `manifest.json` (template)

```json
{
  "manifest_version": 2,
  "version": "1.1.0",
  "name": "Cosmic Purple",
  "theme": {
    "images": { "additional_backgrounds": ["images/0.jpg"] },
    "properties": {
      "additional_backgrounds_alignment": ["left bottom"],
      "additional_backgrounds_tiling": ["repeat"],
      "color_scheme": "system",
      "content_color_scheme": "system"
    },
    "colors": {
      "toolbar": "rgb(239, 229, 244)",
      "toolbar_text": "rgb(26, 13, 33)",
      "frame": "rgb(251, 248, 252)",
      "tab_background_text": "rgb(107, 43, 138)",
      "toolbar_field": "rgb(253, 250, 255)",
      "toolbar_field_text": "rgb(26, 13, 33)",
      "tab_line": "rgb(154, 69, 181)",
      "popup": "rgb(251, 248, 252)",
      "popup_text": "rgb(26, 13, 33)",
      "icons": "rgb(107, 43, 138)",
      "ntp_background": "rgb(253, 250, 255)",
      "sidebar": "rgb(171, 111, 208)",
      "toolbar_field_highlight": "rgb(171, 111, 208)",
      "tab_loading": "rgb(207, 111, 235)"
    }
  },
  "dark_theme": {
    "images": { "additional_backgrounds": ["images/0.jpg"] },
    "properties": {
      "additional_backgrounds_alignment": ["left bottom"],
      "additional_backgrounds_tiling": ["repeat"]
    },
    "colors": {
      "toolbar": "rgb(59, 29, 67)",
      "toolbar_text": "rgb(224, 222, 244)",
      "frame": "rgb(38, 19, 48)",
      "tab_background_text": "rgb(144, 140, 170)",
      "toolbar_field": "rgb(72, 41, 82)",
      "toolbar_field_text": "rgb(224, 222, 244)",
      "tab_line": "rgb(207, 111, 235)",
      "popup": "rgb(52, 31, 61)",
      "popup_text": "rgb(224, 222, 244)",
      "icons": "rgb(213, 151, 234)",
      "ntp_background": "rgb(56, 31, 67)",
      "sidebar": "rgb(146, 0, 191)",
      "toolbar_field_highlight": "rgb(144, 140, 170)",
      "tab_loading": "rgb(207, 111, 235)"
    }
  },
  "browser_specific_settings": {
    "gecko": { "id": "cosmic-purple@lainos.local" }
  }
}
```

The `dark_theme.colors` above are exactly the current dark palette; only
the **light** `theme.colors` are new. Note that `overwrites.css` derives
its tab hover/selected tints from `--toolbar-field-color` /
`--toolbar-bgcolor` (i.e. from these theme colors), so getting the light
`theme.colors` right automatically fixes part of the chrome.

---

## 5. Deliverable B — light chrome CSS layer

Add one file that mirrors `themes/textfox/chrome/config.css` but for light
mode, wrapped in `@media (prefers-color-scheme: light)`. Import it
**after** `config.css` in **both** `userChrome.css` and `userContent.css`
(both currently import `config.css`).

Suggested filename: `themes/textfox/chrome/config-light.css`.

### Contract (override exactly what `config.css` sets)

| Selector / variable (from `config.css`) | Dark (current) | Light (proposed) |
|---|---|---|
| `--tf-bg` | `#2a1036` | `#efe5f4` |
| `--lwt-accent-color` | `#2a1036 !important` | `#efe5f4 !important` |
| `--tf-accent` | `#cf6feb` | `#ab6fd0` |
| `--tf-border` | `#6b2b8a` | `#6b2b8a` (works on both) |
| sidebar surfaces (`#sidebar-main`, `#sidebar-box`, `box#vertical-tabs`, `#tabbrowser-tabs[orient="vertical"]`) | `#3c2147` | `#efe5f4` |
| `sidebar-panel-header` bg / color / fill | `#2a1036` / `#d9c7ec` / `#d9c7ec` | `#efe5f4` / `#1a0d21` / `#1a0d21` |
| `--newtab-background-color` | `#2a1036` | `#fdfaff` |
| `--in-content-page-background` | `#2a1036` | `#fdfaff` |

Colors come from `palette.md`'s light variant:
`#fbf8fc` (window/dialog), `#fdfaff` (view), `#efe5f4` (headerbar/
sidebar), `#1a0d21` (text), accents `#ab6fd0` / `#cf6feb`.

### Template (`config-light.css`)

```css
/* config-light.css — light variant of config.css.
   Imported AFTER config.css so it wins at equal specificity.
   Only overrides the values config.css sets; the media query keeps it
   inert unless the browser/OS scheme is light. */
@media (prefers-color-scheme: light) {
  :root {
    --tf-bg: #efe5f4;
    --lwt-accent-color: #efe5f4 !important;
    --tf-accent: #ab6fd0;
    --tf-border: #6b2b8a;
  }

  #sidebar-main,
  #sidebar-box,
  box#vertical-tabs,
  #tabbrowser-tabs[orient="vertical"] {
    background-color: #efe5f4 !important;
  }

  sidebar-panel-header,
  #sidebar-panel-header,
  #sidebar-box sidebar-panel-header,
  #sidebar-main sidebar-panel-header {
    background-color: #efe5f4 !important;
    color: #1a0d21 !important;
    fill: #1a0d21 !important;
  }
}

/* New Tab / Home background */
@-moz-document url("about:newtab"), url("about:home") {
  @media (prefers-color-scheme: light) {
    :root, body { --newtab-background-color: #fdfaff !important; }
  }
}

/* Firefox in-content pages (about:preferences, about:addons, etc.) */
@-moz-document url-prefix("about:"),
               url-prefix("chrome://browser/content/") {
  @media (prefers-color-scheme: light) {
    :root { --in-content-page-background: #fdfaff !important; }
  }
}
```

`@media` nested inside `@-moz-document` keeps the two `url()`-scoped
rules valid in Gecko. If a given Gecko build rejects the nesting, invert
it (`@-moz-document` inside `@media`) — both orders work on current
releases.

### `userChrome.css` / `userContent.css` change

Add, immediately after the existing `@import url("config.css");` line:

```css
@import url("config-light.css");
```

Import order matters: `config-light.css` must come **after**
`config.css` (and after `overwrites.css`, which it also relies on) so it
overrides at equal specificity.

---

## 6. Firefox support

**Yes — and it is nearly free.** No extra artifact is needed for Firefox:

- `themes/textfox.sh` already discovers and installs into Firefox
  profiles (`~/.mozilla/firefox`, the flatpak `org.mozilla.firefox`, and
  the snap `firefox` roots) using the **same** `chrome/` directory, the
  **same** XPI, and the **same** `user.js` prefs. So both browser
  families get the scheme-aware XPI and the light CSS layer from the
  identical source files.
- **Sites:** Firefox already follows the system scheme by default (no RFP
  to undo), so no `librewolf-color-scheme.sh` equivalent is required.
- **Chrome:** Firefox's built-in default ("System theme — auto") already
  follows the OS live; once the Cosmic Purple XPI is the active theme,
  the `theme` + `dark_theme` split makes it follow the OS live too.

Cost added for Firefox: essentially **zero packaging**, but a bit more
**verification** (LibreWolf and Firefox differ in how readily they
activate a sideloaded theme — see risks). Nothing in the repo has to
branch on browser.

---

## 7. Integration steps (once artifacts land)

1. Add `themes/textfox/chrome/config-light.css` (Deliverable B).
2. Add `@import url("config-light.css");` after `config.css` in
   `themes/textfox/chrome/userChrome.css` and
   `themes/textfox/chrome/userContent.css`.
3. Replace `themes/textfox/cosmic-purple@lainos.local.xpi` in place
   (Deliverable A, version bumped). Filename unchanged.
4. Update docs:
   - `README.md` → "textfox browser chrome" section + script table
     (`themes/textfox/` entry) to mention the light variant and the live
     behaviour on `Alt+Shift+P`.
   - `palette.md` → note the XPI now maps light + dark roles.
   - `install.sh` header comments mentioning the rice (optional).
5. No changes to `themes/textfox.sh`,
   `themes/cosmic-purple-toggle.sh`, or `themes/install-shortcut.sh`.

---

## 8. Verification checklist

Preconditions: a LibreWolf profile with the rice installed (present today).
For Firefox, repeat against an existing Firefox profile.

1. `sh themes/textfox.sh` — expect `chrome/` backed up + replaced (diff
   path) and the XPI re-copied.
2. Restart the browser.
3. `about:addons` → Appearance → "Cosmic Purple" is active.
4. `about:config`:
   - `extensions.activeThemeID` = `cosmic-purple@lainos.local`
   - `browser.theme.toolbar-theme` is **no longer a fixed `0`** — expect
     `2`, or a value that changes with the scheme.
5. With the browser **open**, press `Alt+Shift+P`:
   - chrome flips light↔dark **live** (no restart),
   - websites follow (already the case),
   - toggle back returns to dark.
6. `about:newtab` and `about:preferences` follow the scheme.
7. Profile `chrome/` contains `config-light.css`; `git status` shows only
   the intended files.
8. Sanity: `rm -rf` of nothing, no stray files.

---

## 9. Rollback

`themes/textfox.sh` backs up `chrome/` → `chrome.bak.<ts>` and
`user.js` → `user.js.bak.<ts>` on every non-identical run. To revert:

```
mv <profile>/chrome.bak.<ts> <profile>/chrome   # or restore just config-light.css removal
```

and restart. The system toggle and `install-shortcut.sh` are untouched by
this work.

---

## 10. Risks / gotchas

- **Same-id XPI not reloading:** changing `manifest.json` with an
  unchanged `version` may be ignored. Always bump `version`.
- **Sideload activation differs per browser:** LibreWolf keeps
  `extensions.activeThemeID` (confirmed active in `prefs.js`). Firefox
  release derives `activeThemeID` at startup and auto-disables sideloaded
  extensions per `extensions.autoDisableScopes` (default `15`). If the
  Firefox theme does not activate, either enable it once via
  `about:addons`, or add `user_pref("extensions.autoDisableScopes", 0);`
  to the rice's `user.js` (a `themes/textfox/user.js` change — would be
  the one place Firefox needs an extra pref; confirm before adding).
- **`activeThemeID` in `user.js` is derived** and may be overwritten at
  startup; it currently works in LibreWolf but is not guaranteed on
  Firefox. Verify, don't assume.
- **Portal availability:** live switching needs
  `widget.use-xdg-desktop-portal.settings` enabled (default `2`). Without
  a portal, Gecko falls back to GTK theme changes (still live); if
  neither changes, a restart is required. Fallback design if the portal
  path never works: the toggle writes `ui.systemUsesDarkTheme` (0/1) into
  each profile's `user.js` — restart-only, strictly worse, not chosen
  here.
- **New-tab wallpaper interaction:** `chrome/content/newtab.css` uses
  `.lightWallpaper` / `.darkWallpaper` classes for custom about:newtab
  wallpapers; confirm the new `--newtab-background-color` override
  coexists with those.
- **`overwrites.css` tab tints** derive from the theme's
  `toolbar_field` / `toolbar` colors — re-check hover/selected states in
  light mode after the XPI change.
- **Same version in both profiles:** keep exactly one XPI file in the
  repo; `textfox.sh` copies by fixed name, so a stale second file would
  be dead weight.

---

## 11. Non-goals

- Building the light theme art (external).
- Changing the `Alt+Shift+P` binding, the toggle's theme/wallpaper logic,
  or the GTK/libcosmic layers.
- Touching `themes/firefox-content-eink.css` (separate content overrides).
- Per-site theming, Sidebery styling (still a manual paste), or the
  `librewolf-color-scheme.sh` pref set.

---

## Appendix — reference paths

| Concern | Path |
|---|---|
| Rice chrome (dark) | `themes/textfox/chrome/config.css` |
| Rice chrome (light, NEW) | `themes/textfox/chrome/config-light.css` |
| Theme XPI | `themes/textfox/cosmic-purple@lainos.local.xpi` |
| `user.js` prefs (single source) | `themes/textfox/user.js` |
| Chrome/content imports | `themes/textfox/chrome/userChrome.css`, `userContent.css` |
| Installer (no change) | `themes/textfox.sh` (XPI copy at line ~120) |
| Toggle (no change) | `themes/cosmic-purple-toggle.sh` |
| Palette reference | `palette.md` |
