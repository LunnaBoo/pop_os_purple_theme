#!/bin/sh
# Recolor the user's COSMIC native (libcosmic) theme in place. Affects the
# top bar, dock, cosmic-edit / cosmic-files / cosmic-term / cosmic-player,
# settings panels, dialogs, buttons - everything libcosmic.
#
# Surface tier ladder this clones (Rosé Pine Dawn):
#   paper main       : #faf4ed
#   raised surface   : #fffaf3
#   sunken / input   : #f2e9e1
#   primary text     : #575279
#   muted text       : #9893a5
#   warning yellow   : #ea9d34 (also used as the user's "secondary" accent)
#   destructive      : #b4637a (rose-red, kept from RP Dawn)
#   success          : keep
#
# Accent overrides (per user request - exactly two):
#   primary  : #3a1450  (dark saturated purple)
#   secondary: #ea9d34  (saturated amber/yellow)
#
# Per-machine operation: reads the user's existing theme config and
# recolors just the colors. Backups are kept with *.bak-cosmic-purple.<ts>.
#
# Revert:
#     rm -rf ~/.config/cosmic/com.system76.CosmicTheme.Dark/v2
#     mv ~/.config/cosmic/com.system76.CosmicTheme.Dark/v2.bak-cosmic-purple.* \
#        ~/.config/cosmic/com.system76.CosmicTheme.Dark/v2
#     rm ~/.config/cosmic/com.system76.CosmicTk/v1/apply_theme_global
#     gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'

set -eu

say()  { printf '%s\n' "$*"; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[ -d ~/.config/cosmic/com.system76.CosmicTheme.Dark/v2 ] \
    || die "no CosmicTheme.Dark/v2 config - this isn't a COSMIC session?"

# -- backup -------------------------------------------------------------------
SRC_DARK=~/.config/cosmic/com.system76.CosmicTheme.Dark/v2
SRC_LIGHT=~/.config/cosmic/com.system76.CosmicTheme.Light/v2
TS=$(date +%Y%m%d-%H%M%S)

BAK_DARK=$SRC_DARK.bak-cosmic-purple.$TS
cp -a "$SRC_DARK" "$BAK_DARK"
say "backup: $BAK_DARK"

# -- mappings for both variants ------------------------------------------------
# Each recolor_X maps the STOCK .ron hex values from /usr/share/cosmic
# (which use gray/white tones and an unrelated "love red" accent) into
# Rosé Pine Dawn surface tiers and the user's two accents.

# --- DARK -----------------------------------------------------------------
# Rosé Pine Dusk:
#   paper (window bg)         : #191724
#   surface (raised)          : #1f1b2e
#   sunken / overlay low      : #26233a
#   text (fg / muted)         : #e0def4 / #908caa
# Stock dark hex codes and their replacements (idempotent - covers both
# original stock and previous recolor outputs from this script).
recolor_dark() {
    THEME_DIR=$1
    find "$THEME_DIR" -type f -exec sed -i -E \
      -e 's|#2B2E34|#191724|gi' \
      -e 's|#383B42|#1f1b2e|gi' \
      -e 's|#40434A|#1f1b2e|gi' \
      -e 's|#484C52|#26233a|gi' \
      -e 's|#4E5158|#26233a|gi' \
      -e 's|#53565C|#2c293d|gi' \
      -e 's|#5B5D63|#2c293d|gi' \
      -e 's|#5F6268|#2c293d|gi' \
      -e 's|#63666B|#383447|gi' \
      -e 's|#6D6F75|#383447|gi' \
      -e 's|#717479|#383447|gi' \
      -e 's|#1B1B1B|#0d0a1f|gi' \
      -e 's|#262626|#100c20|gi' \
      -e 's|#303030|#1a1530|gi' \
      -e 's|#C2CFE2|#e0def4|gi' \
      -e 's|#B5C1D4|#e0def4|gi' \
      -e 's|#CEDBEF|#e0def4|gi' \
      -e 's|#DFECFF|#d1c8ec|gi' \
      -e 's|#D8E5F9|#d1c8ec|gi' \
      -e 's|#C5D2E5|#d1c8ec|gi' \
      -e 's|#E79CFE|#3a1450|gi' \
      -e 's|#CD91DF|#5a1d8a|gi' \
      -e 's|#7E598A|#2a0c40|gi' \
      -e 's|#00525A|#3a1450|gi' \
      -e 's|#14555C|#5a1d8a|gi' \
      -e 's|#5F888C|#2a0c40|gi' \
      -e 's|#7FA8AC|#9893a5|gi' \
      -e 's|#326870|#cf6feb|gi' \
      -e 's|#3C737A|#cf6feb|gi' \
      -e 's|#63BAC6|#cf6feb|gi' \
      -e 's|#63D0DF|#cf6feb|gi' \
      {} \;
}

# --- LIGHT ----------------------------------------------------------------
recolor_light() {
    THEME_DIR=$1
    find "$THEME_DIR" -type f -exec sed -i -E \
      -e 's|#D7D7D7|#faf4ed|gi' \
      -e 's|#EBEBEB|#f2e9e1|gi' \
      -e 's|#FCFCFC|#fffaf3|gi' \
      -e 's|#FAFCFF|#fffaf3|gi' \
      -e 's|#FCFCFF|#fffaf3|gi' \
      -e 's|#F7F7F7|#fffaf3|gi' \
      -e 's|#FFFFFF|#fffaf3|gi' \
      -e 's|#CED8EA|#faf4ed|gi' \
      \
      -e 's|#DADADA|#f2e9e1|gi' \
      -e 's|#DEDEDE|#fffaf3|gi' \
      -e 's|#E2E2E2|#fffaf3|gi' \
      -e 's|#DDDDDD|#faf4ed|gi' \
      -e 's|#EEEEEE|#fffaf3|gi' \
      -e 's|#E1EBFE|#fffaf3|gi' \
      -e 's|#F0F5FF|#fffaf3|gi' \
      -e 's|#F1F6FF|#fffaf3|gi' \
      -e 's|#F5F5F5|#fffaf3|gi' \
      -e 's|#F6F6F6|#fffaf3|gi' \
      -e 's|#F3F7FF|#faf4ed|gi' \
      \
      -e 's|#C2C2C2|#ded5cb|gi' \
      -e 's|#CACACA|#ded5cb|gi' \
      -e 's|#D2D2D2|#ded5cb|gi' \
      -e 's|#B0B0B0|#ded5cb|gi' \
      \
      -e 's|#c5c5c1|#faf4ed|gi' \
      -e 's|#c9c9c5|#fffaf3|gi' \
      -e 's|#b8b8b4|#f2e9e1|gi' \
      -e 's|#b3b1a8|#ded5cb|gi' \
      \
      -e 's|#2C3444|#575279|gi' \
      -e 's|#0B1220|#575279|gi' \
      -e 's|#1F2736|#575279|gi' \
      -e 's|#68217C|#3a1450|gi' \
      -e 's|#3D0C11|#3a1450|gi' \
      -e 's|#451D21|#5a1d8a|gi' \
      -e 's|#7D6567|#2a0c40|gi' \
      -e 's|#9E8688|#9893a5|gi' \
      -e 's|#A7B0C2|#9893a5|gi' \
      -e 's|#D58CFF|#ea9d34|gi' \
      -e 's|#00525A|#3a1450|gi' \
      -e 's|#14555C|#5a1d8a|gi' \
      -e 's|#5F888C|#2a0c40|gi' \
      -e 's|#7FA8AC|#9893a5|gi' \
      -e 's|#326870|#cf6feb|gi' \
      -e 's|#3C737A|#cf6feb|gi' \
      -e 's|#63BAC6|#cf6feb|gi' \
      -e 's|#63D0DF|#cf6feb|gi' \
      -e 's|#534800|#ea9d34|gi' \
      {} \;
}

# -- Dark variant (always present) -------------------------------------------
recolor_dark "$SRC_DARK"
say "recolored: $SRC_DARK"

# -- Light variant - only if it already exists ------------------------------
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
printf 'false\n' > "$TK/apply_theme_global"

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme    'Cosmic-Purple-Dark' || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'        || true
fi

# -- Accent overrides (apply to BOTH Dark and Light variant configs) ----------
# Per user: accents are exactly two.
#   primary = #3a1450 (dark saturated purple)
#   secondary = #ea9d34 (the yellow from the reference image)
# The accent{,_,button,text,*} fields below drive buttons/links/toggles.
say ""
say "==> Forcing accent palette overrides (primary #3a1450, secondary #ea9d34)..."
for VARIANT in "$SRC_DARK"; do
    find "$VARIANT" -type f -exec sed -i -E \
      -e 's|"accent_purple: "#[0-9a-fA-F]{6,8}"|"accent_purple: "#3a1450"|g' \
      -e 's|"accent_blue: "#[0-9a-fA-F]{6,8}"|"accent_blue: "#ea9d34"|g' \
      -e 's|"accent_yellow: "#[0-9a-fA-F]{6,8}"|"accent_yellow: "#ea9d34"|g' \
      {} \;
done
if [ -d "$SRC_LIGHT" ]; then
    find "$SRC_LIGHT" -type f -exec sed -i -E \
      -e 's|"accent_purple: "#[0-9a-fA-F]{6,8}"|"accent_purple: "#3a1450"|g' \
      -e 's|"accent_blue: "#[0-9a-fA-F]{6,8}"|"accent_blue: "#ea9d34"|g' \
      -e 's|"accent_yellow: "#[0-9a-fA-F]{6,8}"|"accent_yellow: "#ea9d34"|g' \
      {} \;
fi
# (Intentionally NOT re-running the recolor here - it would undo palette
# overrides like accent_blue since the recolor mapping covers #00525A.)
say "  accent pass complete"

say ""
say "Done. Log out + log in to see the change everywhere."
say "  - Top bar, dock, cosmic-edit / cosmic-files / cosmic-term: surface tiers copy Rosé Pine Dawn"
say "  - Accent buttons / focus:        #3a1450 (deep purple, primary)"
say "  - Accent secondary / scrollbar / wm highlight: #ea9d34 (yellow)"
say "  - LibreWolf (and any GTK app):   Cosmic-Purple-Dark (this script sets it as a default)"
say ""
say "Revert: see header comments in this script."
