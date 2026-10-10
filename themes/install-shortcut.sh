#!/bin/sh
# install-shortcut.sh
# Wires Ctrl+Shift+P to cosmic-purple-toggle.sh on this COSMIC session.
# Idempotent: running twice does not duplicate the binding.
#
# Run this from install.sh, or standalone after a fresh install:
#     sh install-shortcut.sh
#
# Revert: delete the toggle binary and restore the shortcuts file
#         (a backup is left at .bak.<timestamp>).

set -eu

say()  { printf '%s\n' "$*"; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[ -d ~/.config/cosmic ] || die "no ~/.config/cosmic - not a COSMIC session"

BUNDLE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TOGGLE_SRC="$BUNDLE/themes/cosmic-purple-toggle.sh"
RECOLOR_SH="$BUNDLE/themes/cosmic-native-recolor.sh"

[ -f "$TOGGLE_SRC" ] || die "missing $TOGGLE_SRC"

# 1) Make sure both libcosmic themes are cosmic-purple.
if [ -f "$RECOLOR_SH" ]; then
    say "==> Recoloring COSMIC native themes (Dark + Light) ..."
    sh "$RECOLOR_SH" || say "  (recolor failed - GTK-only theme may still apply)"
fi

# 2) Install the toggle script.
mkdir -p ~/.local/bin
install -m 755 "$TOGGLE_SRC" ~/.local/bin/cosmic-purple-toggle.sh
say "Installed: ~/.local/bin/cosmic-purple-toggle.sh"

# 3) Add the Ctrl+Shift+P binding.
SC=~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom
if [ ! -f "$SC" ]; then
    die "shortcuts file not found: $SC\nIs this Pop!_OS COSMIC 24.04?"
fi

TS=$(date +%s)
BAK="$SC.bak.$TS"
cp -a "$SC" "$BAK"
say "Backup: $BAK"

# Use a path string suitable for inclusion in the RON file.
# We always install to ~/.local/bin/cosmic-purple-toggle.sh, which is a
# stable absolute path that survives git clones and moving the repo.
TOGGLE_PATH="$HOME/.local/bin/cosmic-purple-toggle.sh"

if grep -q "Spawn(\"$TOGGLE_PATH\")" "$SC"; then
    say "Alt+Shift+P binding already present - nothing to do."
else
    python3 - "$SC" "$TOGGLE_PATH" <<'PYEOF'
import sys
path, toggle = sys.argv[1], sys.argv[2]
src = open(path).read()
entry = (
    '    (\n'
    '        modifiers: [\n'
    '            Alt,\n'
    '            Shift,\n'
    '        ],\n'
    '        key: "p",\n'
    '    ): Spawn("' + toggle + '"),\n'
)
assert src.endswith('}'), f'unexpected file ending: {src[-30:]!r}'
open(path, 'w').write(src[:-1] + entry + '}')
PYEOF
    say "Added Ctrl+Shift+P -> Spawn binding."
fi

say ""
say "==> Done."
say ""
say "If Ctrl+Shift+P doesn't trigger at first try, the daemon may still"
say "have the old config cached. Reload it with:"
say "    killall -USR1 cosmic-comp   # signal-based reload (preferred)"
say "    killall cosmic-comp         # cosmic-session will respawn"
say ""
say "Revert:"
say "    rm ~/.local/bin/cosmic-purple-toggle.sh"
say "    mv $BAK $SC   # restore the shortcuts file"
