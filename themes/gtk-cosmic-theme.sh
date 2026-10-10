#!/bin/sh
# Build Cosmic-Purple (light) and Cosmic-Purple-Dark (dark) user themes by
# recoloring Pop!_OS's stock adw-gtk3 themes.
#
# What this version clones (Rosé Pine Dawn surface tokens, Aug 2026 build):
#   paper main       : #faf4ed
#   raised surface   : #fffaf3
#   sunken / input   : #f2e9e1
#   primary text     : #575279
#   warm subtle border: #ded5cb
#   ruled line bg    : #f1ece5 (used by hairline rules in the source CSS)
#
# Accent overrides (per user request - exactly two):
#   primary  : #3a1450  (dark saturated purple; dark enough to read poorly on light bg)
#   secondary: #ea9d34  (saturated amber/yellow from RP Dawn gold)
# Anywhere GTK offers accent slots, those two are the only "accent" colors:
#   accent_bg_color = primary, accent_color = secondary highlight,
#   scrollbar_outline_color and wm_highlight take from the secondary palette.
# Everything else stays Rosé Pine Dawn.

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
            sed -n '2,22p' "$0"
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
    SRC_DARK=/usr/share/themes/CoplandOS-GTK
    [ -d /usr/share/themes/Adwaita ] && SRC_LIGHT=/usr/share/themes/Adwaita
else
    die "could not find adw-gtk3 or CoplandOS-GTK in /usr/share/themes"
fi

# --- destinations ------------------------------------------------------------
DST_DARK="$HOME/.local/share/themes/Cosmic-Purple-Dark"
DST_LIGHT="$HOME/.local/share/themes/Cosmic-Purple"

# --- shared accent overrides (primary purple + secondary yellow) ------------
ACCENT_BG="
s|@define-color accent_bg_color @blue_3;|@define-color accent_bg_color #3a1450;|
s|@define-color accent_color @blue_1;|@define-color accent_color #cf6feb;|
s|@define-color accent_color @blue_4;|@define-color accent_color #cf6feb;|
s|@define-color accent_color #78aeed;|@define-color accent_color #cf6feb;|
s|@define-color accent_fg_color white;|@define-color accent_fg_color #faf4ed;|
s|@define-color scrollbar_outline_color white;|@define-color scrollbar_outline_color #ea9d34;|
"

# --- dark theme (Rosé Pine Dusk surface tokens; same accent palette) ---------
# Dusk base/surface/sunken: #191724 / #1f1b2e / #26233a
# Dusk text/overlay:       #e0def4 / #908caa
# Only dark-themed @define-color defaults in stock light are mapped to
# their dusk counterparts, plus the accent overrides from ACCENT_BG.
DARK_BG="
s|@define-color window_bg_color #242424;|@define-color window_bg_color #191724;|
s|@define-color view_bg_color #1e1e1e;|@define-color view_bg_color #1f1b2e;|
s|@define-color headerbar_bg_color #303030;|@define-color headerbar_bg_color #26233a;|
s|@define-color sidebar_bg_color #303030;|@define-color sidebar_bg_color #1f1b2e;|
s|@define-color dialog_bg_color #383838;|@define-color dialog_bg_color #1f1b2e;|
s|@define-color popover_bg_color #383838;|@define-color popover_bg_color #1f1b2e;|
s|@define-color card_bg_color rgba(255, 255, 255, 0.08);|@define-color card_bg_color rgba(224, 222, 244, 0.05);|
s|@define-color headerbar_border_color white;|@define-color headerbar_border_color rgba(224, 222, 244, 0.10);|
s|@define-color headerbar_shade_color rgba(0, 0, 0, 0.36);|@define-color headerbar_shade_color rgba(0, 0, 0, 0.40);|
s|@define-color headerbar_darker_shade_color rgba(0, 0, 0, 0.9);|@define-color headerbar_darker_shade_color rgba(0, 0, 0, 0.90);|
s|@define-color shade_color rgba(0, 0, 0, 0.25);|@define-color shade_color rgba(0, 0, 0, 0.30);|
s|@define-color window_fg_color white;|@define-color window_fg_color #e0def4;|
s|@define-color view_fg_color white;|@define-color view_fg_color #e0def4;|
s|@define-color headerbar_fg_color white;|@define-color headerbar_fg_color #e0def4;|
s|@define-color card_fg_color white;|@define-color card_fg_color #e0def4;|
s|@define-color popover_fg_color white;|@define-color popover_fg_color #e0def4;|
s|@define-color dialog_fg_color white;|@define-color dialog_fg_color #e0def4;|
s|@define-color sidebar_fg_color white;|@define-color sidebar_fg_color #e0def4;|
s|@define-color sidebar_backdrop_color #2a2a2a;|@define-color sidebar_backdrop_color #26233a;|
s|@define-color sidebar_shade_color rgba(0, 0, 0, 0.25);|@define-color sidebar_shade_color rgba(0, 0, 0, 0.30);|
s|@define-color sidebar_border_color rgba(0, 0, 0, 0.36);|@define-color sidebar_border_color rgba(144, 140, 170, 0.30);|
s|@define-color panel_bg_color black;|@define-color panel_bg_color #26233a;|
s|@define-color panel_fg_color white;|@define-color panel_fg_color #e0def4;|
"

# --- light theme (Rosé Pine Dawn surface tokens; same accent palette) ---------
# Stock light values fafafa/ffffff/ebebeb/f2f2f2 are mapped into the
# three RP Dawn surface tiers: paper, raised, sunken.
# Foreground / muted text comes from RP Dawn as well (#575279 / #9893a5).
LIGHT_BG="
s|@define-color window_bg_color #fafafa;|@define-color window_bg_color #faf4ed;|
s|@define-color view_bg_color #ffffff;|@define-color view_bg_color #fffaf3;|
s|@define-color headerbar_bg_color #ebebeb;|@define-color headerbar_bg_color #f2e9e1;|
s|@define-color sidebar_bg_color #ebebeb;|@define-color sidebar_bg_color #fffaf3;|
s|@define-color dialog_bg_color #fafafa;|@define-color dialog_bg_color #fffaf3;|
s|@define-color card_bg_color #ffffff;|@define-color card_bg_color #fffaf3;|
s|@define-color popover_bg_color #ffffff;|@define-color popover_bg_color #fffaf3;|
s|@define-color thumbnail_bg_color #ffffff;|@define-color thumbnail_bg_color #fffaf3;|
s|@define-color new_title_bg_color #ffffff;|@define-color new_title_bg_color #faf4ed;|
s|@define-color headerbar_border_color rgba(0, 0, 0, 0.8);|@define-color headerbar_border_color #ded5cb;|
s|@define-color headerbar_shade_color rgba(0, 0, 0, 0.12);|@define-color headerbar_shade_color rgba(87, 82, 121, 0.08);|
s|@define-color headerbar_darker_shade_color rgba(0, 0, 0, 0.12);|@define-color headerbar_darker_shade_color rgba(87, 82, 121, 0.08);|
s|@define-color shade_color rgba(0, 0, 0, 0.07);|@define-color shade_color rgba(87, 82, 121, 0.07);|
s|@define-color wm_highlight alpha(white,|@define-color wm_highlight alpha(#ea9d34,|g
s|@define-color wm_borders_edge alpha(white,|@define-color wm_borders_edge alpha(#575279,|g
s|@define-color window_fg_color #323232;|@define-color window_fg_color #575279;|
s|@define-color view_fg_color #333333;|@define-color view_fg_color #575279;|
s|@define-color headerbar_fg_color #2f2f2f;|@define-color headerbar_fg_color #575279;|
s|@define-color card_fg_color #333333;|@define-color card_fg_color #575279;|
s|@define-color popover_fg_color #333333;|@define-color popover_fg_color #575279;|
s|@define-color dialog_fg_color #323232;|@define-color dialog_fg_color #575279;|
s|@define-color sidebar_fg_color rgba(0, 0, 0, 0.8);|@define-color sidebar_fg_color #575279;|
s|@define-color sidebar_backdrop_color #f2f2f2;|@define-color sidebar_backdrop_color #f2e9e1;|
s|@define-color sidebar_shade_color rgba(0, 0, 0, 0.07);|@define-color sidebar_shade_color rgba(87, 82, 121, 0.07);|
s|@define-color sidebar_border_color rgba(0, 0, 0, 0.07);|@define-color sidebar_border_color rgba(87, 82, 121, 0.10);|
s|@define-color panel_bg_color black;|@define-color panel_bg_color #f2e9e1;|
s|@define-color panel_fg_color white;|@define-color panel_fg_color #575279;|
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

    # Background tier + foreground mapping + accent override (accent
    # applies equally to light and dark, so apply once at the end).
    SED=$(mktemp -t cosmic-sed.XXXXXX)
    {
        printf '%s\n' "$BG_EXPRS"
        printf '%s\n' "$ACCENT_BG"
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
