#!/usr/bin/env bash
# Build Kids Mode (or take a release APK), install it on the TV, make it the home app and switch on its guard.
#   TV_HOST=<tv ip> ./install.sh
#   TV_HOST=<tv ip> APK=KidsMode-0.1.0.apk ./install.sh                  # a release APK instead of building
#   TV_HOST=<tv ip> ./install.sh --off <launcher package/activity>      # your launcher back as home, guard off
# While Kids Mode is off, Home hands straight over to your normal launcher, so nothing changes until you start it.
# Uses adb. Where macOS blocks the stock adb, set CLEANYOURTV to a clone of github.com/Gathin23/cleanyourtv with
# its tools set up (tools/venv), and its tools/tv.py is used instead.
set -euo pipefail
: "${TV_HOST:?set TV_HOST to the TV IP address}"
if [ -n "${APK:-}" ]; then
  [ -f "$APK" ] || { echo "no such file: $APK" >&2; exit 1; }
  APK="$(cd "$(dirname "$APK")" && pwd)/$(basename "$APK")"
fi
cd "$(dirname "$0")"
PKG=io.github.maxhayim.kidsmode
SVC=$PKG/.GuardService

if [ -n "${CLEANYOURTV:-}" ]; then
  TOOLS="$(cd "$CLEANYOURTV/tools" && pwd)"
  PY=$TOOLS/venv/bin/python
  [ -x "$PY" ] || PY=$TOOLS/venv/Scripts/python.exe
  export MSYS_NO_PATHCONV=1
  tv() { "$PY" -I "$TOOLS/tv.py" "$@"; }
  push() { "$PY" -I "$TOOLS/b64push.py" "$1" "$2" >/dev/null; }
else
  ADB="${ADB:-adb}"
  command -v "$ADB" >/dev/null || { echo "adb not found: install Android platform-tools, or set CLEANYOURTV" >&2; exit 1; }
  "$ADB" connect "$TV_HOST:5555" >/dev/null
  tv() { "$ADB" -s "$TV_HOST:5555" shell "$@"; }
  push() { "$ADB" -s "$TV_HOST:5555" push "$1" "$2" >/dev/null; }
fi

if [ "${1:-}" = "--off" ]; then
  HOME_APP="${2:?usage: $0 --off <launcher package/activity>, e.g. com.gathin.tvhome/.MainActivity}"
  tv "cmd package set-home-activity $HOME_APP; s=\$(settings get secure enabled_accessibility_services); s=\$(echo \"\$s\" | tr ':' '\n' | grep -v '^$SVC\$' | paste -sd: -); settings put secure enabled_accessibility_services \"\${s:-null}\"; echo home is $HOME_APP, guard off"
  exit 0
fi

if [ -z "${APK:-}" ]; then
  [ -f local.properties ] || { [ -n "${ANDROID_HOME:-}" ] && echo "sdk.dir=$ANDROID_HOME" > local.properties; } || true
  if [ -n "${JAVA_HOME:-}" ]; then export PATH="$JAVA_HOME/bin:$PATH"; fi
  ./gradlew assembleRelease -q --console=plain
  APK=app/build/outputs/apk/release/app-release.apk
fi

push "$APK" /data/local/tmp/kids-mode.apk
OUT=$(tv 'pm install -r /data/local/tmp/kids-mode.apk; rm -f /data/local/tmp/kids-mode.apk')
echo "$OUT"
case "$OUT" in *Success*) ;; *) echo "ERROR: pm install failed" >&2; exit 1 ;; esac

# Home: Kids Mode. It hands over to the launcher that was home before, while Kids Mode is off.
tv "cmd package set-home-activity $PKG/.KidsHomeActivity; echo home set"
# The guard, added to whatever accessibility services are already on (the launcher's, for one).
tv "s=\$(settings get secure enabled_accessibility_services); case \"\$s\" in *$SVC*) ;; null|'') settings put secure enabled_accessibility_services $SVC ;; *) settings put secure enabled_accessibility_services \"\$s:$SVC\" ;; esac; settings put secure accessibility_enabled 1; echo guard on"
tv "cmd appops set $PKG APP_AUTO_START allow 2>/dev/null; am start -n $PKG/.ParentActivity >/dev/null; echo opened"
echo "Installed. Kids Mode is open on the TV: choose a PIN, check the kids' apps, then Start Kids Mode."
