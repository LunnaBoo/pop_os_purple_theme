#!/bin/sh
# cosmic-purple-toggle.sh
#
# Toggles between Cosmic-Purple (light) and Cosmic-Purple-Dark (dark).
# Bound to Ctrl+Shift+P via ~/.config/cosmic/com.system76.CosmicSettings.Shortcuts
#
# Flips:
#   - gsettings org.gnome.desktop.interface gtk-theme (Cosmic-Purple <-> Cosmic-Purple-Dark)
#   - gsettings org.gnome.desktop.interface color-scheme (prefer-light <-> prefer-dark)
#   - ~/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark
#     (which libcosmic theme COSMIC native UI reads; Dark or Light)
#
# The libcosmic themes themselves don't move - they're already cosmic-purple
# from cosmic-native-recolor.sh. We just tell the system which one to use.

set -eu

MODE_FILE="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"

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
        ;;
    *)
        # We are in light mode. Switch to dark.
        printf 'true' > "$MODE_FILE"
        if command -v gsettings >/dev/null 2>&1; then
            gsettings set org.gnome.desktop.interface gtk-theme    'Cosmic-Purple-Dark'
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        fi
        printf '%s\n' "Cosmic Purple: switched to DARK"
        ;;
esac

exit 0
