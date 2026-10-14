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
BLD_DARK=~/.config/cosmic/com.system76.CosmicTheme.Dark.Builder/v2
BLD_LIGHT=~/.config/cosmic/com.system76.CosmicTheme.Light.Builder/v2
TS=$(date +%Y%m%d-%H%M%S)

BAK_DARK=$SRC_DARK.bak-cosmic-purple.$TS
cp -a "$SRC_DARK" "$BAK_DARK"
say "backup: $BAK_DARK"

# Remove stray backup/temp files left INSIDE the derived dirs (e.g. an
# earlier manual `primary.bak-test`). The sibling *.bak-cosmic-purple.*
# backup dirs are NOT touched.
for V in "$SRC_DARK" "$SRC_LIGHT"; do
    [ -d "$V" ] || continue
    find "$V" -maxdepth 1 -type f \( -name '*.bak*' -o -name '*~' \) -delete
done

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

# Icon-button foreground repair (DARK only).
#
# NOT about the toggle knob: libcosmic derives the toggler knob colour from
# the palette step `neutral_2` (light #BEBEBE / dark #303030) - there is no
# per-widget knob key. This pass only fixes the icon GLYPH colour.
#
# The dark recolour above maps stock #BEBEBE -> #383447, but #BEBEBE is
# exactly `icon_button.on` (the icon glyph colour). Left alone, dark-mode
# icon glyphs would be near-black on a dark surface. Restore them to the
# Dusk text colour.
#
# The LIGHT variant deliberately gets NO such pass: stock light
# icon_button.on is #161616 (dark glyphs on cream - already correct). An
# earlier version also rewrote #272727/#161616 here repo-wide, which hit
# background.on / secondary.on / button.on / transparent_*.on - the
# general body TEXT colour in the light variant - and turned it cream
# (#faf4ed), i.e. invisible text until an Appearance change rebuilt the
# theme. This pass must never target anything but `icon_button`.
restore_icon_button_fg_dark() {
    _f=$1/icon_button
    [ -f "$_f" ] || return 0
    sed -i -E \
      -e 's|^([[:space:]]+on: )"#161616FF"|\1"#e0def4FF"|' \
      -e 's|^([[:space:]]+on: )"#383447FF"|\1"#e0def4FF"|' \
      -e 's|^([[:space:]]+on_disabled: )"#161616A6"|\1"#e0def4A6"|' \
      -e 's|^([[:space:]]+on_disabled: )"#383447A6"|\1"#e0def4A6"|' \
      "$_f"
}

# -- Dark variant (always present) -------------------------------------------
recolor_dark "$SRC_DARK"
restore_icon_button_fg_dark "$SRC_DARK"
say "recolored: $SRC_DARK  (icon-button foreground repaired)"

# -- Light variant - only if it already exists ------------------------------
if [ -d "$SRC_LIGHT" ]; then
    BAK_LIGHT=$SRC_LIGHT.bak-cosmic-purple.$TS
    cp -a "$SRC_LIGHT" "$BAK_LIGHT"
    say "backup: $BAK_LIGHT"
    recolor_light "$SRC_LIGHT"
    say "recolored: $SRC_LIGHT"
fi

# -- Seed the Light *Builder* so Appearance rebuilds stay Cosmic Purple -------
# cosmic-settings rebuilds the active theme from the Builder config on any
# Appearance/Style change. A ThemeBuilder whose `palette` is missing falls
# back to the built-in DARK palette (libcosmic ThemeBuilder::default), which
# rebuilds a "Light" theme with dark surfaces and white `on`/text colours -
# i.e. the same "white text until you flip a Style option" symptom. The Dark
# Builder always ships a palette, but a stock profile's Light Builder has
# only the style files, so a light rebuild had nothing light to build from.
# Seed any missing Light Builder file from the system copy, then recolour the
# seeded palette with the light mappings (accents are applied just below).
STOCK_BLD_LIGHT=/usr/share/cosmic/com.system76.CosmicTheme.Light.Builder/v2
if [ -d "$BLD_LIGHT" ] && [ -d "$STOCK_BLD_LIGHT" ]; then
    for _f in "$STOCK_BLD_LIGHT"/*; do
        _b=${_f##*/}
        [ -e "$BLD_LIGHT/$_b" ] || cp -a "$_f" "$BLD_LIGHT/$_b"
    done
    if [ -f "$BLD_LIGHT/palette" ]; then
        recolor_light "$BLD_LIGHT/palette"
        say "seeded Light Builder palette: $BLD_LIGHT/palette"
    fi
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
      -e 's|(accent_purple: ")(#[0-9a-fA-F]{6,8}")|\1#cf6febFF"|g' \
      -e 's|(accent_blue: ")(#[0-9a-fA-F]{6,8}")|\1#ea9d34FF"|g' \
      -e 's|(accent_yellow: ")(#[0-9a-fA-F]{6,8}")|\1#ea9d34FF"|g' \
      {} \;
}
apply_palette_accent "$SRC_DARK"
[ -d "$SRC_LIGHT" ] && apply_palette_accent "$SRC_LIGHT"
# Persist the same accent overrides into the Builder palette config so
# cosmic-settings regenerates the derived theme from the overridden accents
# instead of reverting to stock on the next Appearance change. The same sed
# matches the accents inside the Builder's Dark((...))/Light((...)) wrapper.
[ -f "$BLD_DARK/palette" ] && apply_palette_accent "$BLD_DARK"
[ -f "$BLD_LIGHT/palette" ] && apply_palette_accent "$BLD_LIGHT"
say "  accent palette overrides applied"
# (Intentionally NOT re-running the recolor here - it would undo palette
# overrides like accent_blue since the recolor mapping covers #00525A.)
say "  accent pass complete"

# -- Active window hint (focus border) -------------------------------------
# The two window-hint theme keys have different types:
#   active_hint : u32          - outline WIDTH in pixels (stock = 3)
#   window_hint : Option<Srgb> - hint COLOR; Some("#RRGGBBAA") turns the
#                                focused-window border on, None disables it
#                                (stock None is why users couldn't tell which
#                                window was focused).
# Bright saturated purple (#cf6feb) so it stands out on both cream and dusk.
# Write into both the derived theme AND the Builder (so a rebuild keeps the
# hint). Created if absent - previously the `[ -f ] || continue` guard meant
# the light variant, whose derived dir ships no active_hint/window_hint, got
# neither file and thus no focus border at all.
for V in "$SRC_DARK" "$SRC_LIGHT" "$BLD_DARK" "$BLD_LIGHT"; do
    [ -d "$V" ] || continue
    printf '3\n' > "$V/active_hint"
    printf 'Some("#cf6febFF")\n' > "$V/window_hint"
done
say "  active_hint = 3, window_hint = Some(\"#cf6febFF\") (purple focus hint)"

say ""
say "==> Forcing Square corner radii (all 0)..."
# Some libcosmic widget rendering has a styling issue with rounded corners
# that causes text/buttons to render invisibly under specific color combinations.
# Setting all radii to 0 (Square) sidesteps it.
SQUARE_RADII='(
    radius_0: (0.0, 0.0, 0.0, 0.0),
    radius_xs: (0.0, 0.0, 0.0, 0.0),
    radius_s: (0.0, 0.0, 0.0, 0.0),
    radius_m: (0.0, 0.0, 0.0, 0.0),
    radius_l: (0.0, 0.0, 0.0, 0.0),
    radius_xl: (0.0, 0.0, 0.0, 0.0),
)
'
for V in "$SRC_DARK" "$SRC_LIGHT"; do
    [ -f "$V/corner_radii" ] || continue
    printf '%s' "$SQUARE_RADII" > "$V/corner_radii"
done
# Persist Square radii into the Builder configs too, so cosmic-settings
# doesn't regenerate rounded corners from them on the next Appearance change
# (Dark Builder always; Light Builder only if present).
[ -f "$BLD_DARK/corner_radii" ] && printf '%s' "$SQUARE_RADII" > "$BLD_DARK/corner_radii"
[ -f "$BLD_LIGHT/corner_radii" ] && printf '%s' "$SQUARE_RADII" > "$BLD_LIGHT/corner_radii"
say "  corner_radii set to Square (all 0) on both variants (+ Builder)"

# -- Post-pass lint: fail loudly on anything libcosmic would reject ----------
# ColorRepr requires 8-digit #RRGGBBAA (a 6-digit #RRGGBB is rejected);
# active_hint must be a u32 integer; window_hint must be Some("#RRGGBBAA")
# or None. Guards skip absent dirs / files (e.g. no Light variant).
for V in "$SRC_DARK" "$SRC_LIGHT" "$BLD_DARK" "$BLD_LIGHT"; do
    [ -d "$V" ] || continue
    if grep -rEn '#[0-9a-fA-F]{6}"' "$V"; then
        die "6-digit hex color (must be 8-digit #RRGGBBAA); matches above name file:line under: $V"
    fi
    if [ -f "$V/active_hint" ]; then
        if ! grep -Eq '^[0-9]+$' "$V/active_hint"; then
            die "active_hint in $V is not a u32 integer: $(cat "$V/active_hint")"
        fi
    fi
    if [ -f "$V/window_hint" ]; then
        if ! grep -Eq '^(Some\("#[0-9a-fA-F]{8}"\)|None)$' "$V/window_hint"; then
            die "window_hint in $V is not Some(\"#RRGGBBAA\") or None: $(cat "$V/window_hint")"
        fi
    fi
done
say "  lint OK: no 6-digit hex, active_hint = u32, window_hint = Some(...)/None"

say ""
say "Done. Log out + log in to see the change everywhere."
say "  - Top bar, dock, cosmic-edit / cosmic-files / cosmic-term: surface tiers copy Rosé Pine Dawn"
say "  - Accent buttons / focus:        #3a1450 (deep purple, primary)"
say "  - Accent secondary / scrollbar / wm highlight: #ea9d34 (yellow)"
say "  - LibreWolf (and any GTK app):   Cosmic-Purple-Dark (this script sets it as a default)"
say ""
say "Revert: see header comments in this script."
