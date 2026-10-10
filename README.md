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

Pop!_OS 24.04 ships stock GTK themes at:

| Path | Purpose |
|---|---|
| `/usr/share/themes/adw-gtk3`      | light base |
| `/usr/share/themes/adw-gtk3-dark` | dark  base |

GTK prefers a same-named theme under `~/.local/share/themes/`, so the
script copies the bases there and `sed`-replaces a focused set of
`@define-color` declarations in every `*.css` file. Only CSS is touched —
binary PNG/SVG assets (toggle/check icon shapes) are left alone so widget
imagery doesn't break.

### What gets recolored

- `blue_1`..`blue_5` palette → cosmic purple gradient (`#dfb8ed` … `#6b2b8a`)
- `accent_bg_color` / `accent_color` → `#ab6fd0` / `#cf6feb`
- `window_bg_color`, `view_bg_color` → cosmic deep purples (dark) or warm
  white-purple (light)
- `headerbar_*`, `sidebar_*`, `dialog_*`, `popover_*`, `card_*` → matched
  cosmic tones
- Information cyan (`#0f9ac8`, `#7ad9f1`) → purple (`#7a59ca`, `#9e91e8`)
  so the whole UI stays in the purple family

What **doesn't** get recolored:

- `.storage-bar .btrfs`, `.ext3`, etc. — those are filesystem-specific
  status indicators (blue for btrfs, green for ext) and stay as-is.
- Status colors (green/yellow/orange/red palette) — kept so error states,
  warnings, success accents still read clearly.
- The GNOME Shell itself — Pop!_OS uses pop-shell and rarely applies a
  classic gnome-shell theme. Open an issue if you want that wired up.

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
| `install.sh`                      | one-shot installer (builds + optional gsettings apply) |
| `themes/gtk-cosmic-theme.sh`      | the actual recoloring logic |
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
