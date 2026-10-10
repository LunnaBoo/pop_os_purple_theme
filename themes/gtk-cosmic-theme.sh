#!/bin/sh
# Build Cosmic-Purple (light) and Cosmic-Purple-Dark (dark) user themes by
# recoloring Pop!_OS's stock adw-gtk3 themes to match the Cosmic Purple palette.
#
# Targets Pop!_OS 24.04 (GNOME 46 / libadwaita). Falls back to older
# CoplandOS-GTK if adw-gtk3 is not present (legacy 22.04 / 22.10).
#
# The base themes live under /usr/share/themes. GTK prefers a same-named
# theme under ~/.local/share/themes, so we copy there and recolor the
# @define-color declarations in *.css with sed.
#
# Run as your normal user (no root needed):
#     sh gtk-cosmic-theme.sh
#
# After running, apply them either:
#     gnome-tweaks                                              # GUI
#     gsettings set org.gnome.desktop.interface gtk-theme 'Cosmic-Purple-Dark'
#     gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
#
# Pass --dark-only or --light-only to build just one variant.

set -eu

say()  { printf '%s\n' "$*"; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

BUILD_DARK=1
BUILD_LIGHT=1
for a in "$@"; do
    case "$a" in
        --dark-only)  BUILD_LIGHT=0 ;;
        --light-only) BUILD_DARK=0 ;;
        --help|-h)
            sed -n '2,20p' "$0"
            exit 0 ;;
        *) die "unknown arg: $a" ;;
    esac
done

# --- pick the base themes ----------------------------------------------------
SRC_DARK=
SRC_LIGHT=
if [ -d /usr/share/themes/adw-gtk3-dark ] && [ -d /usr/share/themes/adw-gtk3 ]; then
    SRC_DARK=/usr/share/themes/adw-gtk3-dark
    SRC_LIGHT=/usr/share/themes/adw-gtk3
elif [ -d /usr/share/themes/CoplandOS-GTK ]; then
    # Legacy Pop!_OS release. CoplandOS-GTK is itself a "dark-ish" theme; we
    # use it as the dark base and the older Adwaita as the light fallback.
    SRC_DARK=/usr/share/themes/CoplandOS-GTK
    [ -d /usr/share/themes/Adwaita ] && SRC_LIGHT=/usr/share/themes/Adwaita
else
    die "could not find adw-gtk3 or CoplandOS-GTK in /usr/share/themes"
fi

# --- destinations ------------------------------------------------------------
DST_DARK="$HOME/.local/share/themes/Cosmic-Purple-Dark"
DST_LIGHT="$HOME/.local/share/themes/Cosmic-Purple"

# Each line below is a single s|...|...| BRE expression. We deliberately
# avoid sed -E (extended regex) because rgba(...) patterns contain parens
# that would otherwise need escaping everywhere.
#
# Order matters only when one match could swallow another; ours don't.

# Accent: blue_1..blue_5 gradient -> cosmic purple gradient.
# Some themes use @blue_N as accent, others hardcode an accent_color hex —
# handle both, since both adw-gtk3-dark (hardcoded #78aeed) and adw-gtk3
# (@blue_4) reach this line.
ACCENT_BG="
s|@define-color blue_1 #99c1f1;|@define-color blue_1 #dfb8ed;|
s|@define-color blue_2 #62a0ea;|@define-color blue_2 #cf6feb;|
s|@define-color blue_3 #3584e4;|@define-color blue_3 #ab6fd0;|
s|@define-color blue_4 #1c71d8;|@define-color blue_4 #9945b5;|
s|@define-color blue_5 #1a5fb4;|@define-color blue_5 #6b2b8a;|
s|@define-color accent_bg_color @blue_3;|@define-color accent_bg_color #ab6fd0;|
s|@define-color accent_color @blue_1;|@define-color accent_color #cf6feb;|
s|@define-color accent_color @blue_4;|@define-color accent_color #cf6feb;|
s|@define-color accent_color #78aeed;|@define-color accent_color #cf6feb;|
"

# Info/link cyan -> cosmic purple.
INFO_BG="
s|#0f9ac8|#7a59ca|g
s|#7ad9f1|#9e91e8|g
"

# Dark theme backgrounds + foregrounds (matched by full @define-color line).
DARK_BG="
s|@define-color window_bg_color #242424;|@define-color window_bg_color #1a0d21;|
s|@define-color view_bg_color #1e1e1e;|@define-color view_bg_color #14081a;|
s|@define-color headerbar_bg_color #303030;|@define-color headerbar_bg_color #2a1036;|
s|@define-color sidebar_bg_color #303030;|@define-color sidebar_bg_color #2a1036;|
s|@define-color dialog_bg_color #383838;|@define-color dialog_bg_color #341f3d;|
s|@define-color popover_bg_color #383838;|@define-color popover_bg_color #341f3d;|
s|@define-color card_bg_color rgba(255, 255, 255, 0.08);|@define-color card_bg_color rgba(217, 199, 236, 0.08);|
s|@define-color headerbar_border_color white;|@define-color headerbar_border_color #6b2b8a;|
s|@define-color headerbar_shade_color rgba(0, 0, 0, 0.36);|@define-color headerbar_shade_color rgba(20, 8, 26, 0.40);|
s|@define-color headerbar_darker_shade_color rgba(0, 0, 0, 0.9);|@define-color headerbar_darker_shade_color rgba(20, 8, 26, 0.90);|
s|@define-color shade_color rgba(0, 0, 0, 0.25);|@define-color shade_color rgba(20, 8, 26, 0.30);|
s|@define-color window_fg_color white;|@define-color window_fg_color #d9c7ec;|
s|@define-color view_fg_color white;|@define-color view_fg_color #d9c7ec;|
s|@define-color headerbar_fg_color white;|@define-color headerbar_fg_color #d9c7ec;|
s|@define-color card_fg_color white;|@define-color card_fg_color #d9c7ec;|
s|@define-color popover_fg_color white;|@define-color popover_fg_color #d9c7ec;|
s|@define-color dialog_fg_color white;|@define-color dialog_fg_color #d9c7ec;|
s|@define-color sidebar_fg_color white;|@define-color sidebar_fg_color #d9c7ec;|
s|@define-color sidebar_backdrop_color #2a2a2a;|@define-color sidebar_backdrop_color #1a0d21;|
s|@define-color sidebar_shade_color rgba(0, 0, 0, 0.25);|@define-color sidebar_shade_color rgba(20, 8, 26, 0.30);|
s|@define-color sidebar_border_color rgba(0, 0, 0, 0.36);|@define-color sidebar_border_color rgba(107, 43, 138, 0.30);|
s|@define-color panel_bg_color black;|@define-color panel_bg_color #1a0d21;|
s|@define-color panel_fg_color white;|@define-color panel_fg_color #d9c7ec;|
"

# Light theme backgrounds + foregrounds.
# E-ink paper palette with subtle yellow/beige tint:
#   paper main       (window):          #c5c4ba   R197 G196 B186 (subtle aged paper)
#   paper secondary  (view, card, popover, thumb): #c9c8c0   R201 G200 B192 (lighter)
#   paper bezel      (headerbar, sidebar, panel):  #b8b6ac   R184 G182 B172 (darker)
#   ink              (text):            #1a0d21    cosmic dark foreground
#   accent:          cosmic purple (unchanged)
# The B channel is dropped 8-10 units relative to R/G to evoke warm beige
# without being yellow enough to look "tinted".
LIGHT_BG="
s|@define-color window_bg_color #fafafa;|@define-color window_bg_color #c5c4ba;|
s|@define-color view_bg_color #ffffff;|@define-color view_bg_color #c9c8c0;|
s|@define-color headerbar_bg_color #ebebeb;|@define-color headerbar_bg_color #b8b6ac;|
s|@define-color sidebar_bg_color #ebebeb;|@define-color sidebar_bg_color #b8b6ac;|
s|@define-color dialog_bg_color #fafafa;|@define-color dialog_bg_color #c5c4ba;|
s|@define-color card_bg_color #ffffff;|@define-color card_bg_color #c9c8c0;|
s|@define-color popover_bg_color #ffffff;|@define-color popover_bg_color #c9c8c0;|
s|@define-color thumbnail_bg_color #ffffff;|@define-color thumbnail_bg_color #c9c8c0;|
s|@define-color new_title_bg_color #ffffff;|@define-color new_title_bg_color #c5c4ba;|
s|@define-color headerbar_border_color rgba(0, 0, 0, 0.8);|@define-color headerbar_border_color rgba(107, 43, 138, 0.50);|
s|@define-color headerbar_shade_color rgba(0, 0, 0, 0.12);|@define-color headerbar_shade_color rgba(20, 8, 26, 0.18);|
s|@define-color headerbar_darker_shade_color rgba(0, 0, 0, 0.12);|@define-color headerbar_darker_shade_color rgba(20, 8, 26, 0.18);|
s|@define-color shade_color rgba(0, 0, 0, 0.07);|@define-color shade_color rgba(20, 8, 26, 0.10);|
s|@define-color scrollbar_outline_color white;|@define-color scrollbar_outline_color #ab6fd0;|
s|@define-color wm_highlight alpha(white,|@define-color wm_highlight alpha(#1a0d21,|g
s|@define-color wm_borders_edge alpha(white,|@define-color wm_borders_edge alpha(#1a0d21,|g
s|@define-color window_fg_color #323232;|@define-color window_fg_color #1a0d21;|
s|@define-color view_fg_color #333333;|@define-color view_fg_color #1a0d21;|
s|@define-color headerbar_fg_color #2f2f2f;|@define-color headerbar_fg_color #1a0d21;|
s|@define-color card_fg_color #333333;|@define-color card_fg_color #1a0d21;|
s|@define-color popover_fg_color #333333;|@define-color popover_fg_color #1a0d21;|
s|@define-color dialog_fg_color #323232;|@define-color dialog_fg_color #1a0d21;|
s|@define-color sidebar_fg_color rgba(0, 0, 0, 0.8);|@define-color sidebar_fg_color #1a0d21;|
s|@define-color sidebar_backdrop_color #f2f2f2;|@define-color sidebar_backdrop_color #b8b6ac;|
s|@define-color sidebar_shade_color rgba(0, 0, 0, 0.07);|@define-color sidebar_shade_color rgba(20, 8, 26, 0.10);|
s|@define-color sidebar_border_color rgba(0, 0, 0, 0.07);|@define-color sidebar_border_color rgba(107, 43, 138, 0.20);|
s|@define-color panel_bg_color black;|@define-color panel_bg_color #b8b6ac;|
s|@define-color panel_fg_color white;|@define-color panel_fg_color #1a0d21;|
"

# --- recolor one theme directory --------------------------------------------
recolor() {
    DST=$1
    BG_EXPRS=$2

    rm -rf "$DST"
    mkdir -p "$(dirname "$DST")"
    cp -a "$SRC_BASE" "$DST"

    # Rename the theme in index.theme so GNOME finds it under its new name.
    sed -i \
        -e "s|^Name=.*|Name=$(basename "$DST")|" \
        -e "s|^GtkTheme=.*|GtkTheme=$(basename "$DST")|" \
        "$DST/index.theme"

    # Only *.css files carry color logic; binary PNG/SVG assets stay
    # untouched (their blue pixels are baked into icon shapes).

    # Write the combined sed script to a temp file (one expression per line).
    SED=$(mktemp -t cosmic-sed.XXXXXX)
    {
        printf '%s\n' "$ACCENT_BG"
        printf '%s\n' "$BG_EXPRS"
        printf '%s\n' "$INFO_BG"
    } > "$SED"

    find "$DST" -type f -name '*.css' -print0 | xargs -0 sed -i -f "$SED"
    rm -f "$SED"
}

# --- build -------------------------------------------------------------------
if [ "$BUILD_DARK" = 1 ]; then
    SRC_BASE=$SRC_DARK
    recolor "$DST_DARK" "$DARK_BG"
    say "Built: $DST_DARK"
fi

if [ "$BUILD_LIGHT" = 1 ]; then
    SRC_BASE=$SRC_LIGHT
    recolor "$DST_LIGHT" "$LIGHT_BG"
    say "Built: $DST_LIGHT"
fi

# --- gsettings hint ----------------------------------------------------------
if command -v gsettings >/dev/null 2>&1; then
    CUR=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "''")
    case "$CUR" in
        *Cosmic-Purple*) say "gsettings: gtk-theme already set to a Cosmic-Purple variant ($CUR)" ;;
        *) say ""
           say "Apply the theme with:"
           say "  gsettings set org.gnome.desktop.interface gtk-theme 'Cosmic-Purple-Dark'"
           say "  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'    # for dark"
           say "  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'   # for light"
           say "  gsettings set org.gnome.desktop.interface gtk-theme  'Cosmic-Purple'   # light variant"
           say "Log out/in (or restart GTK apps) to see it." ;;
    esac
else
    say ""
    say "To apply: Settings -> Appearance -> Themes -> Cosmic-Purple[-Dark]"
fi
