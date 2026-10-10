#!/bin/sh
# cosmic-purple-toggle.sh
#
# Toggles between Cosmic-Purple (light) and Cosmic-Purple-Dark (dark).
# Bound to Alt+Shift+P via ~/.config/cosmic/com.system76.CosmicSettings.Shortcuts
#
# Flips:
#   - gsettings org.gnome.desktop.interface gtk-theme (Cosmic-Purple <-> Cosmic-Purple-Dark)
#   - gsettings org.gnome.desktop.interface color-scheme (prefer-light <-> prefer-dark)
#   - ~/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark
#     (which libcosmic theme COSMIC native UI reads; Dark or Light)
#   - The COSMIC wallpaper (light.jpg <-> dark.jpg), written into
#     ~/.config/cosmic/com.system76.CosmicBackground/v1/all and applied live
#     by the cosmic-bg daemon.
#
# The libcosmic themes themselves don't move - they're already cosmic-purple
# from cosmic-native-recolor.sh. We just tell the system which one to use.

set -eu

MODE_FILE="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"

WP_DIR="$HOME/.local/share/backgrounds/cosmic-purple"
WP_LIGHT="$WP_DIR/light.jpg"
WP_DARK="$WP_DIR/dark.jpg"
BG_CONF="$HOME/.config/cosmic/com.system76.CosmicBackground/v1/all"

# set_wallpaper PATH
# Rewrites only the `source: Path("...")` value in the COSMIC background
# config, preserving every other field and the surrounding formatting.
# Non-fatal: a missing image/config or a rewrite failure only warns.
set_wallpaper() {
    _wp=$1
    [ -f "$_wp" ] || return 0
    [ -f "$BG_CONF" ] || return 0
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$BG_CONF" "$_wp" <<'PYEOF' || printf 'Warning: failed to update wallpaper\n' >&2
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
            || printf 'Warning: failed to update wallpaper\n' >&2
    fi
}

# Read current mode. Values can be "true\n" / "false\n" / "true" / "false".
CUR=$(tr -d '[:space:]' < "$MODE_FILE" 2>/dev/null || printf 'true')

case "$CUR" in
    true|1)
        # We are in dark mode. Switch to light.
        printf 'false' > "$MODE_FILE"
        if command -v gsettings >/dev/null 2>&1; then
            gsettings set org.gnome.desktop.interface gtk-theme    'Cosmic-Purple'
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        fi
        printf '%s\n' "Cosmic Purple: switched to LIGHT"
        set_wallpaper "$WP_LIGHT"
        ;;
    *)
        # We are in light mode. Switch to dark.
        printf 'true' > "$MODE_FILE"
        if command -v gsettings >/dev/null 2>&1; then
            gsettings set org.gnome.desktop.interface gtk-theme    'Cosmic-Purple-Dark'
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        fi
        printf '%s\n' "Cosmic Purple: switched to DARK"
        set_wallpaper "$WP_DARK"
        ;;
esac

exit 0
