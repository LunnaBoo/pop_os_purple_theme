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
    # Rosé Pine Dusk surface tones:
    #   paper main       : #191724   base window bg (Dusk "base")
    #   raised surface   : #1f1b2e   cards / popovers (Dusk "surface")
    #   sunken           : #26233a   inputs / active tab (Dusk "highlight_med")
    #   deeper bezel     : #2c293d   borders / hover-tone
    #   text             : #e0def4   primary fg
    #   muted text       : #908caa   overlay
    # Stock Dark uses a different gray ramp than stock Light; this
    # mapping handles the actual COSMIC Dark stock hex values.
    find "$THEME_DIR" -type f -exec sed -i -E \
      -e 's|#1B1B1B|#0d0a1f|gi' \
      -e 's|#262626|#100c20|gi' \
      -e 's|#272727|#0d0a1f|gi' \
      -e 's|#2E2E2E|#1f1b2e|gi' \
      -e 's|#343434|#1a1530|gi' \
      -e 's|#363636|#1f1b2e|gi' \
      -e 's|#3B3B3B|#1f1b2e|gi' \
      -e 's|#434343|#1f1b2e|gi' \
      -e 's|#4A4A4A|#26233a|gi' \
      -e 's|#4F4F4F|#1f1b2e|gi' \
      -e 's|#585858|#26233a|gi' \
      -e 's|#5E5E5E|#26233a|gi' \
      -e 's|#626262|#26233a|gi' \
      -e 's|#C0C0C0|#e0def4|gi' \
      -e 's|#CACACA|#e0def4|gi' \
      -e 's|#D0D0D0|#e0def4|gi' \
      -e 's|#E7E7E7|#e0def4|gi' \
      -e 's|#F8F8F8|#e0def4|gi' \
      -e 's|#BEBEBE|#383447|gi' \
      -e 's|#444444|#383447|gi' \
      -e 's|#515151|#383447|gi' \
      -e 's|#9E9E9E|#908caa|gi' \
      -e 's|#808080|#908caa|gi' \
      \
      -e 's|#E79CFE|#cf6feb|gi' \
      -e 's|#CD91DF|#b85ed5|gi' \
      -e 's|#7E598A|#a04dc0|gi' \
      -e 's|#CF7DFF|#cf6feb|gi' \
      -e 's|#63D0DF|#cf6feb|gi' \
      -e 's|#63BAC6|#b85ed5|gi' \
      -e 's|#3C737A|#a04dc0|gi' \
      -e 's|#3E88FF|#cf6feb|gi' \
      -e 's|#326870|#cf6feb|gi' \
      -e 's|#48B9C7|#cf6feb|gi' \
      -e 's|#92CF9C|#9893a5|gi' \
      -e 's|#F7E062|#ea9d34|gi' \
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
      -e 's|#68217C|#cf6feb|gi' \
      -e 's|#3D0C11|#cf6feb|gi' \
      -e 's|#451D21|#b85ed5|gi' \
      -e 's|#7D6567|#a04dc0|gi' \
      -e 's|#9E8688|#9893a5|gi' \
      -e 's|#A7B0C2|#9893a5|gi' \
      -e 's|#D58CFF|#ea9d34|gi' \
      -e 's|#00525A|#cf6feb|gi' \
      -e 's|#14555C|#b85ed5|gi' \
      -e 's|#5F888C|#a04dc0|gi' \
      -e 's|#7FA8AC|#9893a5|gi' \
      -e 's|#326870|#cf6feb|gi' \
      -e 's|#3C737A|#cf6feb|gi' \
      -e 's|#63BAC6|#cf6feb|gi' \
      -e 's|#63D0DF|#cf6feb|gi' \
      -e 's|#534800|#ea9d34|gi' \
      {} \;
}

# Toggle / icon-button knob visibility.
# libcosmic's toggle widget pulls its knob color from
# `cosmic.ron`'s icon_button.on (and button.border for the outline).
# Stock has them at #161616FF (near-black) which is invisible against
# the dark-purple accent track. Override to the paper / Dusk text so
# the knob contrasts against the track.
fix_toggle_knob_light() {
    find "$1" -type f -exec sed -i -E \
      -e 's|^[[:space:]]+on: "#161616FF"|on: "#faf4edFF"|' \
      -e 's|^[[:space:]]+on: "#272727FF"|on: "#faf4edFF"|' \
      -e 's|^[[:space:]]+on: "#383447FF"|on: "#faf4edFF"|' \
      -e 's|^[[:space:]]+on_disabled: "#161616A6"|on_disabled: "#faf4edA6"|' \
      -e 's|^[[:space:]]+on_disabled: "#383447A6"|on_disabled: "#faf4edA6"|' \
      -e 's|^[[:space:]]+border: "#161616FF"|border: "#ded5cbFF"|' \
      -e 's|^[[:space:]]+border: "#383447FF"|border: "#ded5cbFF"|' \
      -e 's|^[[:space:]]+disabled_border: "#16161680"|disabled_border: "#faf4ed80"|' \
      -e 's|^[[:space:]]+disabled_border: "#38344780"|disabled_border: "#faf4ed80"|' \
      {} \;
}
fix_toggle_knob_dark() {
    find "$1" -type f -exec sed -i -E \
      -e 's|^[[:space:]]+on: "#161616FF"|on: "#e0def4FF"|' \
      -e 's|^[[:space:]]+on: "#383447FF"|on: "#e0def4FF"|' \
      -e 's|^[[:space:]]+on_disabled: "#161616A6"|on_disabled: "#e0def4A6"|' \
      -e 's|^[[:space:]]+on_disabled: "#383447A6"|on_disabled: "#e0def4A6"|' \
      -e 's|^[[:space:]]+border: "#161616FF"|border: "#e0def480"|' \
      -e 's|^[[:space:]]+disabled_border: "#16161680"|disabled_border: "#e0def480"|' \
      {} \;
}

# -- Dark variant (always present) -------------------------------------------
recolor_dark "$SRC_DARK"
fix_toggle_knob_dark "$SRC_DARK"
say "recolored: $SRC_DARK  (toggle-knob fix applied)"

# -- Light variant - only if it already exists ------------------------------
if [ -d "$SRC_LIGHT" ]; then
    BAK_LIGHT=$SRC_LIGHT.bak-cosmic-purple.$TS
    cp -a "$SRC_LIGHT" "$BAK_LIGHT"
    say "backup: $BAK_LIGHT"
    recolor_light "$SRC_LIGHT"
    fix_toggle_knob_light "$SRC_LIGHT"
    say "recolored: $SRC_LIGHT  (toggle-knob fix applied)"
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
apply_palette_accent() {
    find "$1" -type f -exec sed -i -E \
      -e 's|(accent_purple: ")(#[0-9a-fA-F]{6,8}")|\1#cf6feb"|g' \
      -e 's|(accent_blue: ")(#[0-9a-fA-F]{6,8}")|\1#ea9d34"|g' \
      -e 's|(accent_yellow: ")(#[0-9a-fA-F]{6,8}")|\1#ea9d34"|g' \
      {} \;
}
apply_palette_accent "$SRC_DARK"
[ -d "$SRC_LIGHT" ] && apply_palette_accent "$SRC_LIGHT"
say "  accent palette overrides applied"
# (Intentionally NOT re-running the recolor here - it would undo palette
# overrides like accent_blue since the recolor mapping covers #00525A.)
say "  accent pass complete"

# -- Active window hint (focus border color) -------------------------------
# Drive the focused-window border to your primary purple. Bright
# saturated purple so it stands out on both light cream and dark dusk.
# Some(...) wrapper is the RON format for Option<Color>; window_hint=1
# enables the border (None disables it, the default which left users
# unable to tell which window was focused).
for V in "$SRC_DARK" "$SRC_LIGHT"; do
    [ -f "$V/active_hint" ] || continue
    printf 'Some("#cf6febFF")\n' > "$V/active_hint"
    printf '1\n' > "$V/window_hint"
done
say "  active_hint = Some(\"#cf6febFF\"), window_hint = 1 (focus border on, bright purple)"

say ""
say "Done. Log out + log in to see the change everywhere."
say "  - Top bar, dock, cosmic-edit / cosmic-files / cosmic-term: surface tiers copy Rosé Pine Dawn"
say "  - Accent buttons / focus:        #3a1450 (deep purple, primary)"
say "  - Accent secondary / scrollbar / wm highlight: #ea9d34 (yellow)"
say "  - LibreWolf (and any GTK app):   Cosmic-Purple-Dark (this script sets it as a default)"
say ""
say "Revert: see header comments in this script."
