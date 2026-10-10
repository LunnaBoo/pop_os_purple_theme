#!/bin/sh
# install-shortcut.sh
# Wires Alt+Shift+P to cosmic-purple-toggle.sh on this COSMIC session.
# Idempotent and portable across machines / users:
#   - Always resolves $HOME at install time, so the absolute path baked
#     into the shortcuts RON matches the user running it.
#   - Re-running rewrites any prior Spawn entry that pointed at a stale
#     $HOME (e.g. when ~/.config is synced across machines).
#
# Run this from install.sh, or standalone after a fresh install:
#     sh install-shortcut.sh
#
# Revert: delete ~/.local/bin/cosmic-purple-toggle.sh and restore the
#         shortcuts file from the backup left at .bak.<timestamp>.

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

# 3) Add the Alt+Shift+P binding.
SC=~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom
if [ ! -f "$SC" ]; then
    die "shortcuts file not found: $SC\nIs this Pop!_OS COSMIC 24.04?"
fi

TS=$(date +%s)
BAK="$SC.bak.$TS"
cp -a "$SC" "$BAK"
say "Backup: $BAK"

# The toggle lives at $HOME/.local/bin/cosmic-purple-toggle.sh. Resolve
# it now so the RON file holds THIS user's absolute home (not a copy from
# another machine).
TOGGLE_PATH="$HOME/.local/bin/cosmic-purple-toggle.sh"

# Look for an existing binding for cosmic-purple-toggle.sh - any home path.
EXISTING_PATH=$(awk '
    /\(\s*$/                              { depth++; next }
    /\)\s*,?\s*$/                         { if (depth > 0) depth--; next }
    depth == 1 && /Spawn\(".*cosmic-purple-toggle\.sh"/ {
        match($0, /Spawn\("[^"]+"/); print substr($0, RSTART+7, RLENGTH-8); exit
    }
' "$SC" 2>/dev/null || true)

if [ -n "$EXISTING_PATH" ] && [ "$EXISTING_PATH" = "$TOGGLE_PATH" ]; then
    say "Alt+Shift+P binding already points at $TOGGLE_PATH - nothing to do."
    exit 0
fi

if [ -n "$EXISTING_PATH" ]; then
    say "Alt+Shift+P binding points at $EXISTING_PATH, rewriting to $TOGGLE_PATH."
    # Drop the existing entry (delete the entire tuple block) using Python.
    python3 - "$SC" <<'PYEOF'
import re, sys
path = sys.argv[1]
src = open(path).read()
# Match the tuple block whose body contains Spawn(...) for our toggle.
# Greedy across depth-1 entry, non-greedy internal, single replacement.
pattern = re.compile(
    r'\n[ \t]*\(\n[ \t]*modifiers:[ \t]*\[[^\]]*\],[ \t]*\n'
    r'[ \t]*key:[ \t]*"p",[ \t]*\n[ \t]*\)[ \t]*:[ \t]*Spawn\("[^"]*cosmic-purple-toggle\.sh"[ \t]*\),?[ \t]*\n',
    re.MULTILINE,
)
new, n = pattern.subn('\n', src, count=1)
if n != 1:
    die('failed to remove previous binding (matched ' + str(n) + ')')
assert new.endswith('}'), f'unexpected ending: {new[-30:]!r}'
open(path, 'w').write(new)
PYEOF
fi

# Append the fresh entry just before the closing '}' of the outermost block.
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

say "Added Alt+Shift+P -> Spawn binding at $TOGGLE_PATH"

say ""
say "==> Done."
say ""
say "If Alt+Shift+P doesn't trigger at first try, log out + log back in."
say "The daemon picks up new shortcuts on session restart."
say ""
say "Revert:"
say "    rm ~/.local/bin/cosmic-purple-toggle.sh"
say "    mv $BAK $SC   # restore the shortcuts file"
