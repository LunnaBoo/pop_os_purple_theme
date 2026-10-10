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
for a in "$@"; do
    case "$a" in
        --dark-only)   BUILD_ARGS="--dark-only"  ;;
        --light-only)  BUILD_ARGS="--light-only" ;;
        --apply-dark)  APPLY_THEME=Cosmic-Purple-Dark ;;
        --apply-light) APPLY_THEME=Cosmic-Purple ;;
        --help|-h)
            sed -n '2,16p' "$0"
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
