REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIREFOX_DIR="${REPO_ROOT}/firefox"

firefoxSetting() {
  local profile_dir="$1"
  local u="$profile_dir/user.js"
  touch "$u"
  sed -i '/user_pref("'"$2"',.*);/d' "$u"
  grep -q "$2" "$u" || echo "user_pref(\"$2\",$3);" >> "$u"
}

copyUserCSS() {
  local profile_dir="$1"
  mkdir -p "$profile_dir/chrome"
  cp -r "$FIREFOX_DIR/chrome" "$profile_dir"
}

for d in "$APPDATA/Mozilla/Firefox/Profiles/"*default-esr/; do
  [ -d "$d" ] || continue
  firefoxSetting "$d" toolkit.legacyUserProfileCustomizations.stylesheets true
  copyUserCSS "$d"
done
