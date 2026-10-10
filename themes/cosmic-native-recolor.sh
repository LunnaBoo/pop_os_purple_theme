#!/bin/sh
# Recolor the user's COSMIC native (libcosmic) theme in place to the
# Cosmic Purple palette. Affects:
#   - top bar
#   - dock
#   - cosmic-edit, cosmic-files, cosmic-term, cosmic-player, etc.
#   - settings panels, dialogs, buttons, every libcosmic widget
#
# How it differs from gtk-cosmic-theme.sh:
#   - GTK themes (~/.local/share/themes/Cosmic-Purple*) for GTK apps
#     (LibreWolf, future-installed GTK tools, gnome-shell run as fallback).
#   - This script: recolors the libcosmic COSMIC native theme on the fly,
#     keeping every other setting (spacing, corner radii, gaps, etc.) intact.
#
# Per-machine operation: reads the user's existing theme config and
# recolors just the colors. Backups are kept at the original path with
# `*.bak-cosmic-purple.<timestamp>` so it's a one-liner revert.
#
# Run after install.sh, then log out + log in.
#     sh cosmic-native-recolor.sh
#
# Revert:
#     rm -rf ~/.config/cosmic/com.system76.CosmicTheme.Dark/v2
#     mv ~/.config/cosmic/com.system76.CosmicTheme.Dark/v2.bak-cosmic-purple.* ~/.config/cosmic/com.system76.CosmicTheme.Dark/v2
#     rm ~/.config/cosmic/com.system76.CosmicTk/v1/apply_theme_global
#     gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'

set -eu

say()  { printf '%s\n' "$*"; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# -- detect -------------------------------------------------------------------
[ -d ~/.config/cosmic/com.system76.CosmicTheme.Dark/v2 ] \
    || die "no CosmicTheme.Dark/v2 config - this isn't a COSMIC session?"

# -- backup -------------------------------------------------------------------
SRC_DARK=~/.config/cosmic/com.system76.CosmicTheme.Dark/v2
SRC_LIGHT=~/.config/cosmic/com.system76.CosmicTheme.Light/v2
TS=$(date +%Y%m%d-%H%M%S)

BAK_DARK=$SRC_DARK.bak-cosmic-purple.$TS
cp -a "$SRC_DARK" "$BAK_DARK"
say "backup: $BAK_DARK"

# -- mappings (targeted to specific hex values that exist in the stock theme,
#    so status colors (success green / warning yellow / destructive red) and
#    alpha-channel variants are preserved correctly) -----------------------

recolor_dark() {
    THEME_DIR=$1
    find "$THEME_DIR" -type f -exec sed -i -E \
      -e 's|#2B2E34|#1a0d21|gi' \
      -e 's|#383B42|#2a1036|gi' \
      -e 's|#40434A|#2a1036|gi' \
      -e 's|#484C52|#341f3d|gi' \
      -e 's|#4E5158|#341f3d|gi' \
      -e 's|#53565C|#3c2147|gi' \
      -e 's|#5B5D63|#3c2147|gi' \
      -e 's|#5F6268|#3c2147|gi' \
      -e 's|#63666B|#4a2a55|gi' \
      -e 's|#6D6F75|#4a2a55|gi' \
      -e 's|#717479|#4a2a55|gi' \
      -e 's|#1B1B1B|#14081a|gi' \
      -e 's|#262626|#1a0d21|gi' \
      -e 's|#303030|#1f0d2a|gi' \
      -e 's|#C2CFE2|#d9c7ec|gi' \
      -e 's|#B5C1D4|#d9c7ec|gi' \
      -e 's|#CEDBEF|#d9c7ec|gi' \
      -e 's|#DFECFF|#dfb8ed|gi' \
      -e 's|#D8E5F9|#dfb8ed|gi' \
      -e 's|#C5D2E5|#d9c7ec|gi' \
      -e 's|#E79CFE|#cf6feb|gi' \
      -e 's|#CD91DF|#cf6feb|gi' \
      -e 's|#7E598A|#ab6fd0|gi' \
      {} \;
}

# Light variant uses different hex values (light blue-gray backgrounds,
# darker reddish-purple accent). Mapped to cosmic purple *light* palette.
recolor_light() {
    THEME_DIR=$1
    find "$THEME_DIR" -type f -exec sed -i -E \
      -e 's|#CED8EA|#fbf8fc|gi' \
      -e 's|#F0F5FF|#fdfaff|gi' \
      -e 's|#F1F6FF|#fdfaff|gi' \
      -e 's|#F3F7FF|#fbf8fc|gi' \
      -e 's|#2C3444|#1a0d21|gi' \
      -e 's|#0B1220|#1a0d21|gi' \
      -e 's|#1F2736|#1a0d21|gi' \
      -e 's|#68217C|#ab6fd0|gi' \
      -e 's|#3D0C11|#cf6feb|gi' \
      -e 's|#451D21|#ab6fd0|gi' \
      -e 's|#7D6567|#9945b5|gi' \
      -e 's|#9E8688|#dfb8ed|gi' \
      -e 's|#A7B0C2|#6b2b8a|gi' \
      -e 's|#D58CFF|#cf6feb|gi' \
      {} \;
}

# Dark variant (always present if you're on a COSMIC session).
recolor_dark "$SRC_DARK"
say "recolored: $SRC_DARK"

# Light variant - only if already exists. Skipped silently otherwise;
# run cosmic-settings once with light mode to materialize it, then re-run.
if [ -d "$SRC_LIGHT" ]; then
    BAK_LIGHT=$SRC_LIGHT.bak-cosmic-purple.$TS
    cp -a "$SRC_LIGHT" "$BAK_LIGHT"
    say "backup: $BAK_LIGHT"
    recolor_light "$SRC_LIGHT"
    say "recolored: $SRC_LIGHT"
fi

# -- pin GTK theme so cosmic-settings-daemon doesn't fight us ----------------
TK=~/.config/cosmic/com.system76.CosmicTk/v1
mkdir -p "$TK"
# apply_theme_global=false stops the daemon from re-applying adw-gtk3-dark
# on every login.
printf 'false\n' > "$TK/apply_theme_global"

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme    'Cosmic-Purple-Dark' || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'        || true
fi

say ""
say "Done. Log out + log in to see the change everywhere."
say "  - COSMIC top bar, dock, settings, dialogs: Cosmic Purple"
say "  - cosmic-edit, cosmic-files, cosmic-term, cosmic-player: Cosmic Purple"
say "  - LibreWolf (and any GTK app): Cosmic-Purple-Dark"
say ""
say "Revert: see header comments in this script."
