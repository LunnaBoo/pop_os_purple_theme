#!/bin/sh
# install-kitty-theme.sh — make kitty follow the system dark/light theme.
#
# Requires kitty >= 0.38: kitty reads dark-theme.auto.conf,
# light-theme.auto.conf and no-preference-theme.auto.conf from its config
# dir NATIVELY — no reload or signal needed. kitty detects the OS color
# scheme through the XDG portal and switches live (so Alt+Shift+P and
# COSMIC Settings both apply). dark = the cosmic-purple dark palette,
# light = the cosmic-purple light palette. Older kitty (< 0.38) ignores
# these files, so on such installs this script is a harmless no-op.
#
# This script installs the three theme files (shipped in themes/kitty/)
# into the kitty config dir. When run from a terminal it first lists the
# three files it will write and asks for confirmation (y/yes to install,
# anything else skips). --yes|-y installs without asking; runs without a
# TTY on stdin (scripted) also skip the prompt and install directly.
#
# Usage:
#     sh themes/install-kitty-theme.sh            install the three auto-theme files (asks first)
#     sh themes/install-kitty-theme.sh --yes|-y   install without asking
#     sh themes/install-kitty-theme.sh --help|-h  print this help
#
# KITTY_CONFIG_DIR overrides the kitty config dir (default
# $HOME/.config/kitty). If that dir doesn't exist the script prints a
# message and exits 0 (non-fatal). Idempotent: re-running overwrites the
# files with the same content. No sudo needed; $HOME is resolved at run time.

set -eu

say()   { printf '%s\n' "$*"; }
die()   { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
usage() { sed -n '2,27p' "$0"; }
YES=

for _a in "$@"; do
    case "$_a" in
        --yes|-y)
            YES=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            die "unknown argument: $_a" ;;
    esac
done

BUNDLE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC_DIR="$BUNDLE/kitty"
KITTY_CONFIG_DIR="${KITTY_CONFIG_DIR:-$HOME/.config/kitty}"

[ -d "$SRC_DIR" ] || die "missing theme files dir: $SRC_DIR"

if [ ! -d "$KITTY_CONFIG_DIR" ]; then
    say "kitty config dir not found ($KITTY_CONFIG_DIR) - skipping."
    exit 0
fi

# Ask before writing into the user's kitty config — only when we can
# actually prompt. --yes|-y and non-TTY (scripted) runs skip the question.
if [ -z "$YES" ] && [ -t 0 ]; then
    say "This will install:"
    for _f in dark-theme.auto.conf light-theme.auto.conf no-preference-theme.auto.conf; do
        say "  $KITTY_CONFIG_DIR/$_f"
    done
    printf 'Install the Cosmic Purple kitty theme (auto dark/light) into %s? [y/N] ' "$KITTY_CONFIG_DIR"
    _ans=
    read -r _ans || true
    case "$_ans" in
        y|Y|yes|YES|Yes) ;;
        *) say "Skipped."; exit 0 ;;
    esac
fi

N=0
for _f in dark-theme.auto.conf light-theme.auto.conf no-preference-theme.auto.conf; do
    [ -f "$SRC_DIR/$_f" ] || die "missing $SRC_DIR/$_f"
    install -m 644 "$SRC_DIR/$_f" "$KITTY_CONFIG_DIR/$_f"
    say "  installed $KITTY_CONFIG_DIR/$_f"
    N=$((N + 1))
done

say "Done: installed $N kitty auto-theme file(s). kitty (>= 0.38) now follows the system dark/light theme."