# Cosmic Purple — Pop!_OS system theme

Recolors Pop!_OS's stock GTK themes into the **Cosmic Purple** palette and
emits both light and dark variants. Targets Pop!_OS 24.04 (GNOME 46 +
libadwaita) and falls back gracefully on older releases.

```
Cosmic-Purple         ← light variant
Cosmic-Purple-Dark    ← dark  variant
```

Both variants install into `~/.local/share/themes/` so they don't touch
anything under `/usr/share/themes/`.

---

## Install

```
git clone <this-repo>
cd pop_os_purple_theme
sh install.sh                 # build both variants + recolor everything
sh install.sh --apply-dark    # also activate Cosmic-Purple-Dark
sh install.sh --apply-light   # also activate Cosmic-Purple
```

### Flags

| Script | Flag | What it does |
|---|---|---|
| `install.sh` | _(none)_ | Build both variants. Recolor COSMIC native theme. Wire Alt+Shift+P. Ask to install the kitty auto dark/light theme files (when a kitty config dir exists and stdin is a TTY). Ask to install the textfox browser chrome rice (when LibreWolf/Firefox profiles exist and stdin is a TTY). Optionally ask for per-theme wallpapers. Optionally ask about the LibreWolf color-scheme fix. Print manual apply command. |
| `install.sh` | `--apply-dark` | Same as above, **plus** set `gtk-theme=Cosmic-Purple-Dark` and `color-scheme=prefer-dark` via gsettings |
| `install.sh` | `--apply-light` | Same as above, **plus** set `gtk-theme=Cosmic-Purple` and `color-scheme=prefer-light` via gsettings |
| `install.sh` | `--no-prompt` | Skip the interactive prompts (per-theme wallpapers, LibreWolf color-scheme, kitty theme, textfox rice) for scripted installs / CI |
| `install.sh` | `--librewolf` | Apply the LibreWolf color-scheme fix (below) without asking |
| `install.sh` | `--kitty` | Install the kitty auto dark/light theme files (below) without asking |
| `install.sh` | `--textfox` | Install the textfox browser chrome rice (below) without asking |
| `themes/gtk-cosmic-theme.sh` | _(none)_ | Build both `~/.local/share/themes/Cosmic-Purple` and `-Dark` |
| `themes/gtk-cosmic-theme.sh` | `--dark-only` | Only rebuild the dark variant |
| `themes/gtk-cosmic-theme.sh` | `--light-only` | Only rebuild the light variant |
| `themes/gtk-cosmic-theme.sh` | `--help` | Print usage |
| `themes/cosmic-native-recolor.sh` | _(none)_ | Recolors both libcosmic theme variants in `~/.config/cosmic/...CosmicTheme.{Dark,Light}/v2`. Idempotent. |
| `themes/install-shortcut.sh` | _(none)_ | Installs toggle + wallpaper scripts to `~/.local/bin`, binds Alt+Shift+P. Idempotent; rewrites the binding if `$HOME` changed. Wallpapers are opt-in. |
| `themes/install-shortcut.sh` | `--light PATH` / `--dark PATH` | Also install the given light/dark wallpaper images (delegated to `set-wallpaper.sh`) |
| `themes/set-wallpaper.sh` | _(none)_ | Interactive menu: change the light and/or dark wallpaper |
| `themes/set-wallpaper.sh` | `--light PATH` | Set the light-theme wallpaper to `PATH` |
| `themes/set-wallpaper.sh` | `--dark PATH` | Set the dark-theme wallpaper to `PATH` |
| `themes/set-wallpaper.sh` | `--both LIGHT DARK` | Set both wallpapers at once |
| `themes/cosmic-purple-toggle.sh` | _(none)_ | Flips `gtk-theme` + `color-scheme` + `is_dark` **and** swaps the wallpaper light↔dark. Bound to Alt+Shift+P by default. |
| `themes/librewolf-color-scheme.sh` | _(none)_ | Write the three color-scheme prefs into every LibreWolf profile's `user.js` (backup first). Idempotent. |
| `themes/librewolf-color-scheme.sh` | `--help` (`-h`) | Print usage |
| `themes/textfox.sh` | _(none)_ | Install the textfox browser chrome rice into every detected LibreWolf and Firefox profile: purple `userChrome`/`userContent` CSS, the Cosmic Purple theme XPI (sideloaded into `extensions/`), and the 5 matching prefs merged into `user.js` (backup first). Idempotent; preserves every other pref (e.g. the three written by `librewolf-color-scheme.sh`). |
| `themes/textfox.sh` | `--profile DIR` | Only touch the given profile directory (must look like a profile) |
| `themes/textfox.sh` | `--check` | Exit 0 if at least one profile exists, else 1 (no output) |
| `themes/textfox.sh` | `--help` (`-h`) | Print usage |
| `themes/install-kitty-theme.sh` | _(none)_ | Ask for confirmation (when run from a terminal), then install the three kitty auto-theme files (`themes/kitty/*.auto.conf`) into `~/.config/kitty` so kitty follows the system dark/light theme (kitty >= 0.38). Idempotent; prints a message and exits 0 if the kitty config dir is missing. Non-TTY (scripted) runs skip the prompt. |
| `themes/install-kitty-theme.sh` | `--yes` (`-y`) | Install the three kitty auto-theme files without asking |
| `themes/install-kitty-theme.sh` | `--help` (`-h`) | Print usage |

Everything uses `$HOME` (no hardcoded `/home/yourname`) and runs as a normal user — no `sudo` needed.

## Apply

Either of these works after install:

```
gnome-tweaks                                                     # GUI
gsettings set org.gnome.desktop.interface gtk-theme 'Cosmic-Purple-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'    # dark
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'   # light
gsettings set org.gnome.desktop.interface gtk-theme  'Cosmic-Purple'    # light variant
```

`color-scheme` is what libadwaita apps consult to pick dark/light on their
own; set it alongside `gtk-theme`. After switching, **log out and back in**
(or restart GTK apps) for everything to repaint.

## Wallpapers

Alt+Shift+P also swaps the desktop wallpaper to match the theme:

- The images live in `~/.local/share/backgrounds/cosmic-purple/light.jpg`
  and `~/.local/share/backgrounds/cosmic-purple/dark.jpg`.
- `themes/cosmic-purple-toggle.sh` rewrites the `source: Path("...")` line
  in `~/.config/cosmic/com.system76.CosmicBackground/v1/all` — the
  `cosmic-bg` daemon watches that file and repaints **live**, no logout or
  login needed.

Setting wallpapers is **opt-in**. At install time `install.sh` asks
`Set a different wallpaper for each theme (light/dark)? [y/N]` and, on
yes, prompts for a path per theme being installed (`--light-only` → light
only, `--dark-only` → dark only, otherwise both). Pass `--no-prompt` to
skip the question entirely for scripted installs. The paths are forwarded
to `install-shortcut.sh` → `themes/set-wallpaper.sh`.

To change the wallpapers later, use `themes/set-wallpaper.sh` (also
installed to `~/.local/bin/cosmic-purple-set-wallpaper.sh`):

```
sh themes/set-wallpaper.sh --light /path/light.jpg --dark /path/dark.jpg
sh themes/set-wallpaper.sh --both /path/light.jpg /path/dark.jpg
sh themes/set-wallpaper.sh          # interactive menu
```

Re-running is idempotent; old images are overwritten and missing paths are
skipped with a warning. If the theme you just changed is the currently
active one, the new image is applied live right away.

## LibreWolf

LibreWolf ships `privacy.resistFingerprinting = true` by default, which
spoofs every website's `prefers-color-scheme` to `light` — so sites never
follow the system dark/light theme you set here.
`themes/librewolf-color-scheme.sh` fixes that by disabling RFP and
enabling the modern fingerprinting protection (FPP) with a
`CSSPrefersColorScheme` exemption, writing three prefs into every
LibreWolf profile's `user.js`:

```
user_pref("privacy.resistFingerprinting", false);
user_pref("privacy.fingerprintingProtection", true);
user_pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CSSPrefersColorScheme");
```

`install.sh` offers this after building — it only asks when LibreWolf
profiles are found and stdin is a TTY. Pass `--librewolf` to apply it
without asking, or `--no-prompt` to skip the question. Profiles are
found under `~/.config/librewolf/librewolf` (LibreWolf 157+),
`~/.librewolf` and the flatpak path; each profile's `user.js` gets a
timestamped `.bak.<ts>` backup first. Re-running is idempotent — the
three prefs are rewritten, nothing is duplicated.

This only affects how *websites* pick light/dark. The LibreWolf UI theme
itself is a GTK app, themed separately by the GTK themes above — running
this script doesn't change LibreWolf's appearance.

## textfox browser chrome

The repo vendors the **textfox** purple browser chrome rice in
`themes/textfox/` (copied from the textfox_rice project) and installs it
into every detected **LibreWolf and Firefox** profile via
`themes/textfox.sh`:

- `chrome/` — purple `userChrome.css` / `userContent.css` theme (backed up
  to `chrome.bak.<ts>` first)
- `cosmic-purple@lainos.local.xpi` — the Cosmic Purple theme, sideloaded
  into each profile's `extensions/`
- `user.js` — the 5 matching prefs (`toolkit.legacyUserProfileCustomizations.stylesheets`,
  `svg.context-properties.content.enabled`, `layout.css.has-selector.enabled`,
  `xpinstall.signatures.required`, `extensions.activeThemeID`) merged into
  every profile's `user.js` (timestamped `.bak.<ts>` backup first)

The prefs merge never clobbers anything else in `user.js`: it strips only
its own marker line and prior copies of its 5 pref names, then appends
them. Re-running is idempotent (nothing is duplicated), and it coexists
with `librewolf-color-scheme.sh` — running the two scripts in either order
leaves all 8 prefs present exactly once.

Two things stay manual:

1. **Restart the browser** — chrome and prefs load at startup.
2. **Sidebery styles** — Sidebery can't be scripted, so paste
   `themes/textfox/sidebery/styles-editor.txt` into Sidebery →
   Appearance → Styles editor to get the matching tab styling.

`install.sh` offers this after building — it only asks when at least one
profile is found and stdin is a TTY. Pass `--textfox` to install it
without asking, or `--no-prompt` to skip the question entirely.

Detection is **entirely local**: the script only checks for the browser
binaries/config dirs and real profile dirs (`*.default*` or containing
`prefs.js`/`times.json`) on disk. No network access, and no browsing
databases are read.

## kitty

The kitty terminal follows the system dark/light mode **natively** on
kitty **>= 0.38** via three files in its config dir:

```
~/.config/kitty/dark-theme.auto.conf
~/.config/kitty/light-theme.auto.conf
~/.config/kitty/no-preference-theme.auto.conf
```

- `dark-theme.auto.conf` = the cosmic-purple **dark** palette
- `light-theme.auto.conf` = the cosmic-purple **light** palette
- `no-preference-theme.auto.conf` = light (used when the OS reports no
  preference)

kitty detects the OS color scheme through the XDG portal and switches
**live** — no reload and no signal needed. Both Alt+Shift+P (the theme
toggle this repo wires up) and COSMIC Settings → Appearance set that
preference, so kitty follows along either way.

Installing these files is **opt-in / confirmation-gated**: run from a
terminal, `install.sh` asks `Install the Cosmic Purple kitty theme (auto
dark/light)? [y/N]` whenever a kitty config dir exists and stdin is a TTY
— pass `--kitty` to install without asking, or `--no-prompt` to skip the
question entirely. Run directly, `themes/install-kitty-theme.sh` lists
the three files it will write and asks for confirmation too (unless you
pass `--yes`/`-y`, or stdin isn't a TTY, in which case it installs
straight away). Either way a failure is non-fatal. Re-running overwrites
the same content — idempotent.

Kitty **< 0.38** ignores these files (they were added in 0.38), so on
older installs the script is a harmless no-op.

## How it works

Pop!_OS 24.04 has **two separate theming systems** that BOTH need to be
recolored for the whole desktop to look Cosmic Purple:

1. **GTK apps** (LibreWolf, future-installed GTK tools). Themed by
   `gtk-cosmic-theme.sh`, which builds `Cosmic-Purple` and
   `Cosmic-Purple-Dark` from the stock `adw-gtk3` bases.
2. **COSMIC native apps + desktop chrome** (top bar, dock, cosmic-edit,
   cosmic-files, cosmic-term, cosmic-player, all settings panels). Themed
   by `cosmic-native-recolor.sh`, which sed-recolors the user's existing
   libcosmic theme config in place.

Without (2), your GTK theme will apply to LibreWolf but the rest of the
desktop stays stock dark. Without (1), GTK apps stay stock but COSMIC
native UI is purple. The install script runs both.

### What gets recolored

**GTK** (`gtk-cosmic-theme.sh`):

- `blue_1`..`blue_5` palette → cosmic purple gradient (`#dfb8ed` … `#6b2b8a`)
- `accent_bg_color` / `accent_color` → `#ab6fd0` / `#cf6feb`
- `window_bg_color`, `view_bg_color` → cosmic deep purples (dark) or warm
  white-purple (light)
- `headerbar_*`, `sidebar_*`, `dialog_*`, `popover_*`, `card_*` → matched
  cosmic tones
- Information cyan (`#0f9ac8`, `#7ad9f1`) → purple (`#7a59ca`, `#9e91e8`)
  so the whole UI stays in the purple family
- Status colors (green/yellow/orange/red) preserved for clear error/warning/success UX

**COSMIC native** (`cosmic-native-recolor.sh`):

- The libcosmic palette grays (`#1B1B1B`, `#262626`, ...) → cosmic dark purples
- `primary`, `secondary`, `background` chains → cosmic chrome / popup variants
- Text tints `#C2CFE2`, `#B5C1D4`, `#CEDBEF` → cosmic foreground `#d9c7ec`
- Accent purple `#E79CFE` family → cosmic bright `#cf6feb`
- Accent pressed/hover variants → cosmic primary/secondary
- Status colors preserved: warning (yellow), success (green),
  destructive (red), error (red-orange)

What **doesn't** get recolored:

- File-system status indicators (BTRFS blue, ext green) — informational
- Status semantics (yellow warning, green success, red destructive)
- The COSMIC compositor's window-decoration strategy (a separate, much
  bigger problem — see the discussion about Sway in the user's session
  notes; this repo only colors, it doesn't strip window headers)

### Old Pop!_OS releases

If `/usr/share/themes/adw-gtk3` isn't installed (Pop!_OS 22.04 / 22.10 era),
the script falls back to `/usr/share/themes/CoplandOS-GTK` (dark) and
Adwaita (light).

## Revert

Either point back to the stock theme:

```
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'   # or adw-gtk3
```

Or remove the user themes entirely:

```
rm -rf ~/.local/share/themes/Cosmic-Purple ~/.local/share/themes/Cosmic-Purple-Dark
```

The colors don't get baked into anything outside `~/.local/share/themes/`,
so removing the folders is a clean revert.

## Palette

See [`palette.md`](palette.md) for the full hex → role mapping.

---

## Files

| Path | Purpose |
|---|---|
| `README.md`                       | this file |
| `install.sh`                      | one-shot installer (builds both layers + optional gsettings apply + interactive prompts for per-theme wallpapers, the LibreWolf color-scheme fix, the textfox chrome rice and the kitty auto-theme install) |
| `themes/gtk-cosmic-theme.sh`      | builds GTK themes (`Cosmic-Purple` / `Cosmic-Purple-Dark`) for LibreWolf etc. |
| `themes/cosmic-native-recolor.sh` | recolors the user's libcosmic theme in place for cosmic-edit / top bar / etc. |
| `themes/install-shortcut.sh`      | installs the toggle + wallpaper scripts to `~/.local/bin`, binds Alt+Shift+P. Portable across users. |
| `themes/set-wallpaper.sh`         | change the light/dark wallpapers Alt+Shift+P swaps (`--light`/`--dark`/`--both` or interactive menu) |
| `themes/librewolf-color-scheme.sh` | makes LibreWolf websites follow the system dark/light theme (disables RFP, enables FPP with a `CSSPrefersColorScheme` exemption). Idempotent `user.js` writer, backups first. |
| `themes/install-kitty-theme.sh` | installs the kitty auto dark/light theme files (`themes/kitty/`) into `~/.config/kitty` so kitty follows the system dark/light theme natively (kitty >= 0.38). Asks for confirmation when run from a terminal (`--yes`/`-y` skips; non-TTY runs install directly). Idempotent; skips with exit 0 if no kitty config dir. |
| `themes/textfox.sh`              | installs the vendored textfox chrome rice (`themes/textfox/`: `chrome/`, the Cosmic Purple XPI, `user.js` prefs) into every detected LibreWolf and Firefox profile. Backups first, idempotent, preserves unrelated prefs. `--check` / `--profile DIR` / `--help` supported. |
| `themes/textfox/`                | vendored textfox rice: `chrome/` (purple userChrome/userContent CSS), `cosmic-purple@lainos.local.xpi`, `user.js` (single source of truth for the 5 prefs), `sidebery/styles-editor.txt` (manual paste) |
| `themes/cosmic-purple-toggle.sh`  | the actual flipper — swaps theme + wallpaper, bound to Alt+Shift+P |
| `palette.md`                      | color reference |

## Reproducing across machines

This repo is meant to be self-contained. To replicate on a fresh Pop!_OS
install:

```
git clone <this-repo>
cd pop_os_purple_theme
sh install.sh --apply-dark    # or --apply-light
sh install.sh --apply-dark --no-prompt   # scripted: skip the interactive prompts
```

No privileged operations; no dependencies beyond `bash`, `sed`,
`python3` (for the shortcut rebinder), and (for optional apply) `gsettings`.

### Portability

Everything resolves `$HOME` at install time. The Alt+Shift+P binding
bakes in the *current* user's `~/.local/bin/cosmic-purple-toggle.sh`
path into `~/.config/cosmic/.../custom`. Re-run
`sh themes/install-shortcut.sh` on any machine or after a username
change to rewrite the binding to that machine's home.
