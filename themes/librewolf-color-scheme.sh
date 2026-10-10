#!/bin/sh
# librewolf-color-scheme.sh
#
# Makes LibreWolf websites follow the system dark/light theme.
#
# LibreWolf ships privacy.resistFingerprinting = true by default, which
# forces every website's prefers-color-scheme to "light" - sites never
# follow the system theme. This script disables RFP and enables the modern
# fingerprinting protection (FPP) with a CSSPrefersColorScheme exemption,
# by writing these three prefs into every LibreWolf profile's user.js:
#
#     user_pref("privacy.resistFingerprinting", false);
#     user_pref("privacy.fingerprintingProtection", true);
#     user_pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CSSPrefersColorScheme");
#
# The LibreWolf UI theme itself is a GTK app and is unaffected - this only
# touches how websites report their preferred color scheme.
#
# Usage:
#     sh themes/librewolf-color-scheme.sh       apply to every profile
#     sh themes/librewolf-color-scheme.sh --help|-h   this help
#     sh themes/librewolf-color-scheme.sh --check     exit 0 if any profile
#                                                     exists else 1 (no output)
#
# Profiles are discovered under ~/.config/librewolf/librewolf (157+),
# ~/.librewolf (legacy) and the flatpak location. Only real profile dirs
# are touched (basename matches *.default* or contains prefs.js /
# times.json); non-profile dirs like "Profile Groups" are skipped.
#
# Each profile's user.js gets a timestamped backup (user.js.bak.<ts>)
# first. Idempotent: re-running rewrites the same three prefs and never
# duplicates lines. No sudo needed; $HOME is resolved at run time.

set -eu

say()   { printf '%s\n' "$*"; }
die()   { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
usage() { sed -n '2,33p' "$0"; }

# is_profile DIR - returns 0 if DIR looks like a LibreWolf profile dir.
# A dir qualifies when its basename matches *.default* OR it directly
# contains prefs.js or times.json. Anything else (e.g. "Profile Groups",
# "firefox-mpris") is not a profile and is skipped.
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
        "$HOME/.config/librewolf/librewolf" \
        "$HOME/.librewolf" \
        "$HOME/.var/app/io.gitlab.librewolf-community/.librewolf"
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

# write_profile PROFILE_DIR - idempotently set the three prefs in user.js.
# Backs up an existing user.js to user.js.bak.<timestamp> first, strips any
# previous definitions of the three pref names (plus our own comment
# marker), then appends the comment + the three correct lines. All other
# content and ordering are preserved; re-running changes nothing.
write_profile() {
    _p=$1
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

    _tmp="$UJ.tmp.$$"
    {
        if [ -f "$UJ" ]; then
            grep -v -F \
                -e 'user_pref("privacy.resistFingerprinting",' \
                -e 'user_pref("privacy.fingerprintingProtection",' \
                -e 'user_pref("privacy.fingerprintingProtection.overrides",' \
                -e "user_pref('privacy.resistFingerprinting'," \
                -e "user_pref('privacy.fingerprintingProtection'," \
                -e "user_pref('privacy.fingerprintingProtection.overrides'," \
                -e '# pop_os_purple_theme: librewolf color-scheme' \
                "$UJ" || true
        fi
        if [ -n "$_last" ]; then
            printf '\n'
        fi
        cat <<'EOF'
# pop_os_purple_theme: librewolf color-scheme (managed by themes/librewolf-color-scheme.sh)
user_pref("privacy.resistFingerprinting", false);
user_pref("privacy.fingerprintingProtection", true);
user_pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CSSPrefersColorScheme");
EOF
    } > "$_tmp"

    cat "$_tmp" > "$UJ"
    [ -n "$BAK" ] || chmod 600 "$UJ"
    rm -f "$_tmp"

    if [ -n "$BAK" ]; then
        say "  updated $UJ  (3 prefs, backup: $BAK)"
    else
        say "  created $UJ  (3 prefs)"
    fi
}

for _a in "$@"; do
    case "$_a" in
        --help|-h)
            usage
            exit 0
            ;;
        --check)
            if [ -n "$(list_profiles)" ]; then exit 0; else exit 1; fi
            ;;
        *)
            die "unknown argument: $_a" ;;
    esac
done

IFS_OLD=$IFS
IFS='
'
set -- $(list_profiles)
IFS=$IFS_OLD

[ "$#" -gt 0 ] || {
    say "No LibreWolf profiles found - nothing to do."
    exit 0
}

N=0
for _p in "$@"; do
    write_profile "$_p"
    N=$((N + 1))
done
say "Done: updated $N LibreWolf profile(s)."