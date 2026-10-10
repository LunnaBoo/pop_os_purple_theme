# Cosmic Purple palette

Reference for the colors used by `Cosmic-Purple` (light) and
`Cosmic-Purple-Dark` (dark). Dark, light, and accent columns describe the
role each hex plays in the corresponding variant.

| Hex      | Role | Used in |
|----------|------|---------|
| `#14081a` | darkest bg (view, dark only)              | Cosmic-Purple-Dark |
| `#1a0d21` | secondary dark (window, panels, sidebar-backdrop) | Cosmic-Purple-Dark |
| `#2a1036` | chrome bg (headerbar, sidebar, panel)     | Cosmic-Purple-Dark |
| `#341f3d` | popup / dialog bg                         | Cosmic-Purple-Dark |
| `#3c2147` | reserved deep-purple (not in theme, but used by `textfox_rice` sidebar) | reference |
| `#6b2b8a` | dim purple — borders / deepest accent     | both variants |
| `#ab6fd0` | primary accent (selection, focus, links)  | both variants |
| `#cf6feb` | bright accent — hover, highlight          | both variants |
| `#d9c7ec` | foreground / text                         | Cosmic-Purple-Dark |
| `#dfb8ed` | blue_1 — light accent (selection halo)    | both variants |
| `#9945b5` | blue_4 — darker accent                    | both variants |
| `#7a59ca` | replaced cyan — info/secondary action     | both variants |
| `#9e91e8` | replaced cyan — info hover                | both variants |
| `#fbf8fc` | window bg, dialog bg                      | Cosmic-Purple (light) |
| `#fdfaff` | view bg                                   | Cosmic-Purple (light) |
| `#efe5f4` | headerbar / sidebar bg                    | Cosmic-Purple (light) |
| `#1a0d21` | foreground / text on light variant        | Cosmic-Purple (light) |
| `rgba(107, 43, 138, 0.50)` | headerbar border           | Cosmic-Purple (light) |
| `rgba(107, 43, 138, 0.10)` | sidebar border / shade    | Cosmic-Purple (light) |
| `rgba(217, 199, 236, 0.08)` | card surface                | Cosmic-Purple-Dark |
| `rgba(20, 8, 26, 0.40)`  | headerbar / sidebar shade   | Cosmic-Purple-Dark |

## How colors map to GTK roles

GTK's themes use symbolic color names (`window_bg_color`, `accent_bg_color`,
etc.) defined as `@define-color` in CSS. Both Pop!_OS and our themes use
those names. To use these colors in your own CSS overrides, reference
them with `@`-prefixed identifiers:

```css
/* override per-app — drop into ~/.config/gtk-4.0/gtk.css or similar */
window {
    background: @window_bg_color;
    color:      @window_fg_color;
}

selection, .accent {
    background: @accent_bg_color;
    color:      @accent_fg_color;
}
```

## Why these values

These map to the Firefox `Cosmic Purple` theme at
`textfox_rice/cosmic-purple/cosmic-purple@lainos.local.xpi` and its
`manifest.json`:

| XPI `colors` field | Hex used in repo |
|---|---|
| `frame`         `rgb(38, 19, 48)`  | `#261330` ~ `#1a0d21` (window_bg) |
| `toolbar`       `rgb(59, 29, 67)`  | `#3b1d43` ~ `#2a1036` (headerbar/sidebar) |
| `popup`         `rgb(52, 31, 61)`  | `#341f3d` (dialog/popover) |
| `tab_line`      `rgb(207, 111, 235)` | `#cf6feb` (bright accent) |
| `icons`         `rgb(213, 151, 234)` | `#d597ea` ~ `#d9c7ec` (foreground) |
| `sidebar`       `rgb(146, 0, 191)` | `#9200bf` ~ `#ab6fd0` (accent) |

The README palette table (`#14081a` … `#d9c7ec`) was the canonical
reference for the original rice; this script extends it into a system-wide
GTK theme by mapping each role to the closest matching GTK semantic
variable.
