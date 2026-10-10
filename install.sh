#!/bin/sh
# install.sh — one-shot Cosmic Purple theme installer.
#
# Builds Cosmic-Purple and Cosmic-Purple-Dark by recoloring Pop!_OS's
# stock adw-gtk3 themes, then optionally applies one of them via gsettings.
#
# Usage:
#     sh install.sh                  # build both, print how to apply
#     sh install.sh --apply-dark     # build both, apply Cosmic-Purple-Dark
#     sh install.sh --apply-light    # build both, apply Cosmic-Purple
#     sh install.sh --dark-only      # build only Cosmic-Purple-Dark
#     sh install.sh --light-only     # build only Cosmic-Purple
#     sh install.sh --no-prompt      # skip the interactive prompts (wallpapers, LibreWolf)
#     sh install.sh --librewolf      # apply the LibreWolf color-scheme fix without asking
#
# Alt+Shift+P is wired to toggle the theme (and the wallpaper, if you opt
# in). After building you're optionally asked whether to set per-theme
# wallpapers; that prompt is skipped with --no-prompt or when stdin isn't
# a TTY (e.g. scripted installs).
#
# If LibreWolf is installed you're also asked whether to make websites
# follow the system dark/light theme (LibreWolf forces sites to "light"
# by default — see themes/librewolf-color-scheme.sh). Pass --librewolf
# to apply it without asking; --no-prompt skips the question entirely.
#
# No sudo needed. Run from anywhere.

set -eu

say()  { printf '%s\n' "$*"; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

BUNDLE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
THEME_SH="$BUNDLE/themes/gtk-cosmic-theme.sh"

[ -f "$THEME_SH" ] || die "missing $THEME_SH"

BUILD_ARGS=
APPLY_THEME=
NO_PROMPT=
LIBREWOLF=
for a in "$@"; do
    case "$a" in
        --dark-only)   BUILD_ARGS="--dark-only"  ;;
        --light-only)  BUILD_ARGS="--light-only" ;;
        --apply-dark)  APPLY_THEME=Cosmic-Purple-Dark ;;
        --apply-light) APPLY_THEME=Cosmic-Purple ;;
        --no-prompt)   NO_PROMPT=1 ;;
        --librewolf)   LIBREWOLF=1 ;;
        --help|-h)
            sed -n '2,26p' "$0"
            exit 0 ;;
        *) die "unknown arg: $a" ;;
    esac
done

say "==> Building Cosmic Purple themes ..."
if [ -n "$BUILD_ARGS" ]; then
    sh "$THEME_SH" $BUILD_ARGS
else
    sh "$THEME_SH"
fi
say ""

# --- recolor COSMIC native (libcosmic) theme in place ----------------------
# This handles the top bar, dock, cosmic-edit, cosmic-files, cosmic-term,
# settings panels — everything libcosmic. Optional, only on COSMIC sessions.
NATIVE_SH="$BUNDLE/themes/cosmic-native-recolor.sh"
if [ -f "$NATIVE_SH" ] && [ -d ~/.config/cosmic ]; then
    say "==> Recoloring COSMIC native theme ..."
    sh "$NATIVE_SH" || say "  (native recolor failed - GTK-only theme will still apply)"
    say ""
fi

# --- optional LibreWolf color-scheme fix (interactive) ----------------------
# LibreWolf ships resistFingerprinting on by default, which spoofs every
# website's prefers-color-scheme to "light" so sites never follow the
# system theme. The fix disables RFP and enables fingerprinting protection
# with a CSSPrefersColorScheme exemption (themes/librewolf-color-scheme.sh).
# Asked only when LibreWolf profiles exist; --librewolf forces it, and
# --no-prompt (or a non-TTY stdin) skips the question. Never fatal.
LW_SH="$BUNDLE/themes/librewolf-color-scheme.sh"
LW_WANT=
if [ -f "$LW_SH" ]; then
    if [ -n "$LIBREWOLF" ]; then
        LW_WANT=1
    elif [ -z "$NO_PROMPT" ] && [ -t 0 ] && sh "$LW_SH" --check >/dev/null 2>&1; then
        printf 'Make LibreWolf websites follow the system dark/light theme? [y/N] '
        _ans=
        read -r _ans || true
        case "$_ans" in
            y|Y|yes|YES|Yes) LW_WANT=1 ;;
        esac
    fi
    if [ -n "$LW_WANT" ]; then
        say "==> Making LibreWolf websites follow the system dark/light theme ..."
        sh "$LW_SH" || say "  (LibreWolf fix failed - continuing anyway)"
        say ""
    fi
fi

# --- optional per-theme wallpapers (interactive) ----------------------------
# Asks whether to set a wallpaper for each theme being installed. Skipped
# entirely with --no-prompt or when stdin isn't a TTY (scripted installs).
LIGHT_WP=
DARK_WP=
prompt_wallpaper() {
    _label=$1
    printf 'Path to the %s-theme wallpaper image (blank to skip): ' "$_label"
    _p=
    read -r _p || true
    if [ -z "$_p" ]; then
        say "  (no path - skipping $_label wallpaper)"
    elif [ -f "$_p" ]; then
        if [ "$_label" = "light" ]; then
            LIGHT_WP=$_p
        else
            DARK_WP=$_p
        fi
    else
        say "  (file not found: $_p - skipping $_label wallpaper)"
    fi
}

# Which themes are being installed (from the build selection).
TARGET=both
case "$BUILD_ARGS" in
    --light-only) TARGET=light ;;
    --dark-only)  TARGET=dark ;;
esac

if [ -z "$NO_PROMPT" ] && [ -t 0 ] && [ -d ~/.config/cosmic ]; then
    printf 'Set a different wallpaper for each theme (light/dark)? [y/N] '
    _ans=
    read -r _ans || true
    case "$_ans" in
        y|Y|yes|YES|Yes)
            case "$TARGET" in
                light) prompt_wallpaper light ;;
                dark)  prompt_wallpaper dark ;;
                *)     prompt_wallpaper light; prompt_wallpaper dark ;;
            esac
            ;;
    esac
fi

# --- install Alt+Shift+P shortcut ------------------------------------------
# Wires Alt+Shift+P to toggle between Cosmic-Purple-Dark and Cosmic-Purple,
# forwarding any wallpapers collected above (opt-in).
SHORTCUT_SH="$BUNDLE/themes/install-shortcut.sh"
if [ -f "$SHORTCUT_SH" ] && [ -d ~/.config/cosmic ]; then
    say "==> Wiring Alt+Shift+P theme-toggle shortcut ..."
    set --
    [ -n "$LIGHT_WP" ] && set -- "$@" --light "$LIGHT_WP"
    [ -n "$DARK_WP" ]  && set -- "$@" --dark  "$DARK_WP"
    sh "$SHORTCUT_SH" "$@" || say "  (shortcut install failed - run manually: sh $SHORTCUT_SH)"
    say ""
fi

# --- optionally apply via gsettings ----------------------------------------
if [ -n "$APPLY_THEME" ] && command -v gsettings >/dev/null 2>&1; then
    SCHEME=prefer-dark
    [ "$APPLY_THEME" = "Cosmic-Purple" ] && SCHEME=prefer-light

    say "==> Applying $APPLY_THEME via gsettings ..."
    gsettings set org.gnome.desktop.interface gtk-theme    "$APPLY_THEME" || die "gsettings gtk-theme failed"
    gsettings set org.gnome.desktop.interface color-scheme "$SCHEME"     || say "  (color-scheme set failed — non-fatal)"
    say "    gtk-theme    = $APPLY_THEME"
    say "    color-scheme = $SCHEME"
    say ""
    say "Log out and back in to see the change everywhere."
elif [ -n "$APPLY_THEME" ]; then
    die "--apply-* requires gsettings (gnome-control-center / GNOME Shell). Use gnome-tweaks instead."
fi

# Always print how to apply at the end so users without --apply-* know what to do.
if [ -z "$APPLY_THEME" ]; then
    say "==> To apply, either:"
    say "    gnome-tweaks"
    say "  or:"
    say "    gsettings set org.gnome.desktop.interface gtk-theme    'Cosmic-Purple-Dark'   # dark"
    say "    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'         # dark"
    say "    gsettings set org.gnome.desktop.interface gtk-theme    'Cosmic-Purple'       # light variant"
    say "    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'        # light variant"
    say ""
    say "  (log out/in after to see the change everywhere)"
fi
