#!/bin/sh
# textfox.sh
#
# Installs the "textfox" browser chrome rice into every detected LibreWolf
# and Firefox profile: the purple userChrome/userContent theme, the Cosmic
# Purple theme XPI (sideloaded), and the matching prefs merged into each
# profile's user.js.
#
# Usage:
#     sh themes/textfox.sh                 apply to every profile
#     sh themes/textfox.sh --profile DIR   apply to just DIR
#     sh themes/textfox.sh --check         exit 0 if any profile exists,
#                                          else 1 (prints nothing)
#     sh themes/textfox.sh --help|-h       this help
#
# Profiles are discovered under the LibreWolf roots
# ~/.config/librewolf/librewolf (157+), ~/.librewolf, the flatpak and snap
# locations, and the Firefox roots ~/.mozilla/firefox, the flatpak and snap
# locations. Only real profile dirs are touched (basename matches
# *.default* or contains prefs.js / times.json).
#
# For each profile: the vendored themes/textfox/chrome/ is installed. An
# identical existing chrome/ is left untouched (no backup); a differing or
# missing one is backed up to chrome.bak.<ts> first. The Cosmic Purple XPI
# is dropped into extensions/, and the five prefs from themes/textfox/user.js
# are merged into user.js (timestamped .bak.<ts> backup first). This is
# idempotent and preserves every other pref already in user.js - the three
# written by themes/librewolf-color-scheme.sh are untouched, and running the
# two scripts in either order leaves all eight prefs present exactly once.
#
# Detection is entirely local (profile directories on disk): no network
# access, no reading of browsing databases.
#
# No sudo needed; $HOME is resolved at run time.

set -eu

say()   { printf '%s\n' "$*"; }
die()   { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
usage() { sed -n '2,34p' "$0"; }

MARKER='# pop_os_purple_theme: textfox browser chrome rice (managed by themes/textfox.sh)'

# Locations of the vendored rice, relative to this script.
SELF=$0
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$SELF")" && pwd)
TEXTFOX_DIR=$SCRIPT_DIR/textfox
TEXTFOX_UJ=$TEXTFOX_DIR/user.js

# is_profile DIR - returns 0 if DIR looks like a browser profile dir.
# A dir qualifies when its basename matches *.default* OR it directly
# contains prefs.js or times.json. Anything else is not a profile.
is_profile() {
    _d=$1
    case "$(basename "$_d")" in
        *.default*) return 0 ;;
    esac
    [ -f "$_d/prefs.js" ] || [ -f "$_d/times.json" ] || return 1
    return 0
}

# list_profiles - prints one profile dir per line (trailing slash trimmed).
list_profiles() {
    for _root in \
        "${XDG_CONFIG_HOME:-$HOME/.config}/librewolf/librewolf" \
        "$HOME/.librewolf" \
        "$HOME/.var/app/io.gitlab.librewolf-community/.librewolf" \
        "$HOME/snap/librewolf/common/.librewolf" \
        "$HOME/.mozilla/firefox" \
        "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox" \
        "$HOME/snap/firefox/common/.mozilla/firefox"
    do
        [ -d "$_root" ] || continue
        for _d in "$_root"/*/; do
            [ -d "$_d" ] || continue
            if is_profile "$_d"; then
                printf '%s\n' "${_d%/}"
            fi
        done
    done
}

# pref_names - the pref names managed by the rice, derived at runtime from
# themes/textfox/user.js (every line starting with user_pref).
pref_names() {
    sed -n "s/^user_pref([\"']\([^\"']*\)[\"'].*/\1/p" "$TEXTFOX_UJ"
}

# pref_lines - the pref lines to (re)write, straight from the vendored file.
pref_lines() {
    grep '^user_pref' "$TEXTFOX_UJ"
}

# write_profile PROFILE_DIR - install chrome/, the XPI and the prefs.
write_profile() {
    _p=$1

    # 1. install the vendored chrome/: identical content is left untouched;
    #    only a differing (or absent) chrome gets backed up and replaced.
    _chrome=$_p/chrome
    if [ -d "$_chrome" ] && diff -rq "$TEXTFOX_DIR/chrome" "$_chrome" >/dev/null 2>&1; then
        say "  chrome/ already up to date"
    else
        if [ -e "$_chrome" ]; then
            TS=$(date +%Y%m%d-%H%M%S)
            _cbak="$_chrome.bak.$TS"
            _n=1
            while [ -e "$_cbak" ]; do
                _cbak="$_chrome.bak.$TS.$_n"
                _n=$((_n + 1))
            done
            mv "$_chrome" "$_cbak"
            say "  backed up existing chrome/ -> $_cbak"
        fi
        cp -a "$TEXTFOX_DIR/chrome" "$_chrome"
    fi

    # 2. sideload the Cosmic Purple theme XPI.
    mkdir -p "$_p/extensions"
    cp -a "$TEXTFOX_DIR/cosmic-purple@lainos.local.xpi" "$_p/extensions/"

    # 3. merge the prefs into user.js (backup first, strip prior copies).
    UJ=$_p/user.js
    BAK=
    if [ -f "$UJ" ]; then
        TS=$(date +%Y%m%d-%H%M%S)
        BAK="$UJ.bak.$TS"
        _n=1
        while [ -e "$BAK" ]; do
            BAK="$UJ.bak.$TS.$_n"
            _n=$((_n + 1))
        done
        cp -a "$UJ" "$BAK"
        # remember whether the file ends with a newline, for clean appends
        _last=$(tail -c 1 "$UJ" 2>/dev/null || true)
    else
        _last=
    fi

    # Build the list of lines to strip: our marker plus any definition (in
    # either quote style) of a pref name we manage.
    _pf="$UJ.patterns.$$"
    {
        printf '%s\n' "$MARKER"
        for _pn in $(pref_names); do
            printf 'user_pref("%s",\n' "$_pn"
            printf "user_pref('%s',\n" "$_pn"
        done
    } > "$_pf"

    _tmp="$UJ.tmp.$$"
    {
        if [ -f "$UJ" ]; then
            grep -v -F -f "$_pf" "$UJ" || true
        fi
        if [ -n "$_last" ]; then
            printf '\n'
        fi
        printf '%s\n' "$MARKER"
        pref_lines
    } > "$_tmp"

    cat "$_tmp" > "$UJ"
    [ -n "$BAK" ] || chmod 600 "$UJ"
    rm -f "$_tmp" "$_pf"

    if [ -n "$BAK" ]; then
        say "  updated $UJ  (5 prefs, backup: $BAK)"
    else
        say "  created $UJ  (5 prefs)"
    fi
}

CHECK=
PROFILE=
while [ "$#" -gt 0 ]; do
    case "$1" in
        --help|-h)
            usage
            exit 0
            ;;
        --check)
            CHECK=1
            shift
            ;;
        --profile)
            [ "$#" -ge 2 ] || die "--profile requires a directory argument"
            PROFILE=$2
            shift 2
            ;;
        *)
            die "unknown argument: $1" ;;
    esac
done

if [ -n "$CHECK" ]; then
    if [ -n "$(list_profiles)" ]; then exit 0; else exit 1; fi
fi

[ -f "$TEXTFOX_UJ" ] || die "missing $TEXTFOX_UJ"
[ -d "$TEXTFOX_DIR/chrome" ] || die "missing $TEXTFOX_DIR/chrome"

if [ -n "$PROFILE" ]; then
    _p=${PROFILE%/}
    if [ -d "$_p" ] && is_profile "$_p"; then
        set -- "$_p"
    else
        die "not a LibreWolf/Firefox profile: $PROFILE"
    fi
else
    IFS_OLD=$IFS
    IFS='
'
    set -- $(list_profiles)
    IFS=$IFS_OLD
fi

[ "$#" -gt 0 ] || {
    say "No LibreWolf/Firefox profiles found - nothing to do."
    exit 0
}

N=0
for _p in "$@"; do
    write_profile "$_p"
    N=$((N + 1))
done
say "Done: updated $N profile(s)."
say ""
say "Manual follow-ups:"
say "  1. Restart the browser so the new chrome loads."
say "  2. Sidebery cannot be scripted: paste"
say "     themes/textfox/sidebery/styles-editor.txt"
say "     into Sidebery -> Appearance -> Styles editor."
