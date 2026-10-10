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
sh install.sh                # build both variants
sh install.sh --apply-dark   # also set Cosmic-Purple-Dark  via gsettings
sh install.sh --apply-light  # also set Cosmic-Purple        via gsettings
```

The installer does the same thing the long way:

```
sh themes/gtk-cosmic-theme.sh                 # build both
sh themes/gtk-cosmic-theme.sh --dark-only     # only dark
sh themes/gtk-cosmic-theme.sh --light-only    # only light
```

Both scripts must run as your normal user — no `sudo` needed.

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
| `palette.md`                      | color reference |

## Reproducing across machines

This repo is meant to be self-contained. To replicate on a fresh Pop!_OS
install:

```
git clone <this-repo>
cd pop_os_purple_theme
sh install.sh --apply-dark    # or --apply-light
```

No privileged operations; no dependencies beyond `bash`, `sed`, and (for
optional apply) `gsettings`.
