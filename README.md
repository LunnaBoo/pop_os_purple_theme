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
| `install.sh` | _(none)_ | Build both variants. Recolor COSMIC native theme. Wire Alt+Shift+P. Print manual apply command. |
| `install.sh` | `--apply-dark` | Same as above, **plus** set `gtk-theme=Cosmic-Purple-Dark` and `color-scheme=prefer-dark` via gsettings |
| `install.sh` | `--apply-light` | Same as above, **plus** set `gtk-theme=Cosmic-Purple` and `color-scheme=prefer-light` via gsettings |
| `themes/gtk-cosmic-theme.sh` | _(none)_ | Build both `~/.local/share/themes/Cosmic-Purple` and `-Dark` |
| `themes/gtk-cosmic-theme.sh` | `--dark-only` | Only rebuild the dark variant |
| `themes/gtk-cosmic-theme.sh` | `--light-only` | Only rebuild the light variant |
| `themes/gtk-cosmic-theme.sh` | `--help` | Print usage |
| `themes/cosmic-native-recolor.sh` | _(none)_ | Recolors both libcosmic theme variants in `~/.config/cosmic/...CosmicTheme.{Dark,Light}/v2`. Idempotent. |
| `themes/install-shortcut.sh` | _(none)_ | Installs toggle script + binds Alt+Shift+P. Idempotent; rewrites the binding if `$HOME` changed. |
| `themes/cosmic-purple-toggle.sh` | _(none)_ | Flips `gtk-theme` + `color-scheme` + `is_dark`. Bound to Alt+Shift+P by default. |

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
| `install.sh`                      | one-shot installer (builds both layers + optional gsettings apply) |
| `themes/gtk-cosmic-theme.sh`      | builds GTK themes (`Cosmic-Purple` / `Cosmic-Purple-Dark`) for LibreWolf etc. |
| `themes/cosmic-native-recolor.sh` | recolors the user's libcosmic theme in place for cosmic-edit / top bar / etc. |
| `themes/install-shortcut.sh`      | installs the toggle script + binds Alt+Shift+P. Portable across users. |
| `themes/cosmic-purple-toggle.sh`  | the actual flipper — bound to Alt+Shift+P |
| `palette.md`                      | color reference |

## Reproducing across machines

This repo is meant to be self-contained. To replicate on a fresh Pop!_OS
install:

```
git clone <this-repo>
cd pop_os_purple_theme
sh install.sh --apply-dark    # or --apply-light
```

No privileged operations; no dependencies beyond `bash`, `sed`,
`python3` (for the shortcut rebinder), and (for optional apply) `gsettings`.

### Portability

Everything resolves `$HOME` at install time. The Alt+Shift+P binding
bakes in the *current* user's `~/.local/bin/cosmic-purple-toggle.sh`
path into `~/.config/cosmic/.../custom`. Re-run
`sh themes/install-shortcut.sh` on any machine or after a username
change to rewrite the binding to that machine's home.
