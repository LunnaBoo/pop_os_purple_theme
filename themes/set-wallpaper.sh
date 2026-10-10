#!/bin/sh
# set-wallpaper.sh
#
# Sets/changes the per-theme wallpapers that Alt+Shift+P swaps between.
#
# Usage:
#     set-wallpaper.sh --light PATH            set the light-theme wallpaper
#     set-wallpaper.sh --dark PATH             set the dark-theme wallpaper
#     set-wallpaper.sh --both LIGHT DARK       set both
#     set-wallpaper.sh --help | -h             this help
#     set-wallpaper.sh                         interactive menu (on a TTY)
#
# Images are copied to ~/.local/share/backgrounds/cosmic-purple/{light,dark}.jpg
# and registered with COSMIC so they show up in the wallpaper picker
# (~/.config/cosmic/...CosmicSettings.Wallpaper/v1/custom-images).
# If the theme you just changed is the currently-active one, the new image
# is applied live via ~/.config/cosmic/...CosmicBackground/v1/all (the
# cosmic-bg daemon repaints immediately).
#
# Idempotent: re-running with the same image is harmless.
#
# Run via `sh themes/set-wallpaper.sh` from the repo, or from
# ~/.local/bin/cosmic-purple-set-wallpaper.sh after install.

set -eu

say()  { printf '%s\n' "$*"; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

usage() { sed -n '2,23p' "$0"; }

WP_DIR="$HOME/.local/share/backgrounds/cosmic-purple"
WP_LIGHT="$WP_DIR/light.jpg"
WP_DARK="$WP_DIR/dark.jpg"
BG_CONF="$HOME/.config/cosmic/com.system76.CosmicBackground/v1/all"
MODE_FILE="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"
CUSTOM_IMAGES="$HOME/.config/cosmic/com.system76.CosmicSettings.Wallpaper/v1/custom-images"

# rewrite_wallpaper NEWPATH
# Rewrites only the `source: Path("...")` value in the COSMIC background
# config, preserving every other field and the surrounding formatting.
# Non-fatal: a missing config or a rewrite failure only warns.
rewrite_wallpaper() {
    _wp=$1
    [ -f "$BG_CONF" ] || return 0
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$BG_CONF" "$_wp" <<'PYEOF' || warn "could not update $BG_CONF"
import re, sys
path, wp = sys.argv[1], sys.argv[2]
src = open(path).read()
new, n = re.subn(r'source:\s*Path\("[^"]*"\)',
                 'source: Path("%s")' % wp.replace('\\', '\\\\').replace('"', '\\"'),
                 src, count=1)
if n != 1:
    sys.exit(1)
open(path, 'w').write(new)
PYEOF
    else
        sed -i "s|source:[[:space:]]*Path(\"[^\"]*\")|source: Path(\"$_wp\")|" "$BG_CONF" \
            || warn "could not update $BG_CONF"
    fi
}

# apply_current
# Applies whichever installed wallpaper matches the current theme mode
# (dark -> dark.jpg, light -> light.jpg), so the change repaints live if
# that theme is the active one. Skips silently if BG_CONF is missing.
apply_current() {
    [ -f "$BG_CONF" ] || return 0
    _mode=$(tr -d '[:space:]' < "$MODE_FILE" 2>/dev/null || printf 'true')
    case "$_mode" in
        true|1)
            [ -f "$WP_DARK" ] || return 0
            rewrite_wallpaper "$WP_DARK"
            ;;
        *)
            [ -f "$WP_LIGHT" ] || return 0
            rewrite_wallpaper "$WP_LIGHT"
            ;;
    esac
}

# install_one SLOT SRC   (SLOT = light|dark)
# Copies SRC to $WP_DIR/$SLOT.jpg. Empty or missing SRC -> warn + skip.
install_one() {
    _slot=$1
    _src=$2
    if [ -z "$_src" ]; then
        warn "$_slot wallpaper: no path given, skipping"
        return 0
    fi
    if [ ! -f "$_src" ]; then
        warn "$_slot wallpaper: file not found: $_src (skipping)"
        return 0
    fi
    if ! mkdir -p "$WP_DIR" 2>/dev/null; then
        warn "could not create $WP_DIR (skipping $_slot wallpaper)"
        return 0
    fi
    if ! install -m 644 "$_src" "$WP_DIR/$_slot.jpg"; then
        warn "failed to install $_slot wallpaper from $_src"
        return 0
    fi
    say "Installed $_slot-theme wallpaper: $WP_DIR/$_slot.jpg"
}

# register IMG...
# Idempotently adds the given existing image paths to the COSMIC wallpaper
# picker registry. Non-fatal (warns if python3 is missing or it fails).
register() {
    [ "$#" -gt 0 ] || return 0
    if ! command -v python3 >/dev/null 2>&1; then
        warn "python3 unavailable - skipping wallpaper registration"
        return 0
    fi
    if ! mkdir -p "$(dirname "$CUSTOM_IMAGES")" 2>/dev/null; then
        warn "could not create $(dirname "$CUSTOM_IMAGES") - skipping wallpaper registration"
        return 0
    fi
    python3 - "$CUSTOM_IMAGES" "$@" <<'PYEOF' || warn "failed to register wallpapers in $CUSTOM_IMAGES"
import os, sys
path = sys.argv[1]
imgs = [p for p in sys.argv[2:] if os.path.exists(p)]
if not imgs:
    sys.exit(0)
if not os.path.exists(path):
    src = '[\n]'
else:
    src = open(path).read()
# Collect paths already present (lines like   "/abs/path.jpg",  ).
existing, lines = [], src.splitlines(True)
for l in lines:
    t = l.strip()
    if t.startswith('"'):
        t = t[1:]
        if t.endswith('",'):
            t = t[:-2]
        elif t.endswith('"'):
            t = t[:-1]
        existing.append(t)
new = [p for p in imgs if p not in existing]
if new:
    out, done = [], False
    for l in lines:
        if not done and l.strip() == ']':
            for p in new:
                out.append('    "%s",\n' % p)
            done = True
        out.append(l)
    if not done:
        # No closing ']' seen: rebuild a fresh array, keeping old entries.
        out = ['[\n'] + ['    "%s",\n' % p for p in existing + new] + [']\n']
    open(path, 'w').write(''.join(out))
PYEOF
}

# --- argument handling ------------------------------------------------------
LIGHT_SRC=
DARK_SRC=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --light)
            [ "$#" -ge 2 ] || die "--light requires a PATH"
            LIGHT_SRC=$2
            shift 2
            ;;
        --dark)
            [ "$#" -ge 2 ] || die "--dark requires a PATH"
            DARK_SRC=$2
            shift 2
            ;;
        --both)
            [ "$#" -ge 3 ] || die "--both requires LIGHT and DARK paths"
            LIGHT_SRC=$2
            DARK_SRC=$3
            shift 3
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            die "unknown argument: $1 (use --help for usage)"
            ;;
    esac
done

# Interactive menu: only when no paths were given AND stdin is a TTY.
if [ -z "$LIGHT_SRC" ] && [ -z "$DARK_SRC" ]; then
    if [ -t 0 ]; then
        say ""
        say "What do you want to change?"
        say "  1) Light-theme wallpaper"
        say "  2) Dark-theme wallpaper"
        say "  3) Both"
        say "  q) Quit"
        printf 'Choice [1/2/3/q]: '
        _choice=
        read -r _choice || true
        case "$_choice" in
            1|light|Light)
                printf 'Path to the light-theme wallpaper image: '
                read -r LIGHT_SRC || true
                ;;
            2|dark|Dark)
                printf 'Path to the dark-theme wallpaper image: '
                read -r DARK_SRC || true
                ;;
            3|both|Both)
                printf 'Path to the light-theme wallpaper image: '
                read -r LIGHT_SRC || true
                printf 'Path to the dark-theme wallpaper image: '
                read -r DARK_SRC || true
                ;;
            q|Q|quit|Quit|"")
                exit 0
                ;;
            *)
                warn "invalid choice: $_choice"
                exit 1
                ;;
        esac
    else
        # Not a TTY and no arguments: nothing to act on.
        usage
        exit 1
    fi
fi

# Reached only in interactive mode with all-blank answers.
if [ -z "$LIGHT_SRC" ] && [ -z "$DARK_SRC" ]; then
    say "Nothing to do."
    exit 0
fi

if [ -n "$LIGHT_SRC" ]; then install_one light "$LIGHT_SRC"; fi
if [ -n "$DARK_SRC" ]; then install_one dark "$DARK_SRC"; fi

# Register whatever actually landed in $WP_DIR, then repaint the active
# theme's wallpaper live if applicable.
register "$WP_LIGHT" "$WP_DARK"
apply_current

exit 0