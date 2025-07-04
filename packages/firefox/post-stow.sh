REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIREFOX_DIR="${REPO_ROOT}/firefox"

# Determine platform and set paths
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  PROFILE_ROOT="$HOME/.mozilla/firefox"
  PROFILES_INI="$PROFILE_ROOT/profiles.ini"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  PROFILE_ROOT="$APPDATA/Mozilla/Firefox/Profiles"
  PROFILES_INI="$APPDATA/Mozilla/Firefox/profiles.ini"
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

# Find default profile
getProfile() {
  if [ -f "$PROFILES_INI" ]; then
    # Extract default profile from profiles.ini
    local default_profile
    default_profile=$(awk -F= '
            /^\[Profile/ { profile = "" }
            /^Default=1/ { default_profile = 1 }
            /^Name=/ { name = $2 }
            /^Path=/ { path = $2 }
            /^Default=1.*/ && profile && path {
                print path
                exit
            }
            /^\[.*\]/ { if (default_profile && profile) print profile }
        ' "$PROFILES_INI")

    if [ -n "$default_profile" ]; then
      echo "$PROFILE_ROOT/$default_profile"
      return
    fi
  fi

  # Fallback to directory search
  find "$PROFILE_ROOT" -maxdepth 1 -type d \
    \( -name "*.default-release" -o -name "*.default" \) |
    head -n1
}

# Main execution
PROFILE_DIR=$(getProfile)
echo "$PROFILE_DIR"

if [ -z "$PROFILE_DIR" ]; then
  # Create profile if none exists
  echo "Creating new Firefox profile..."
  firefox --headless &
  sleep 5
  killall firefox
  PROFILE_DIR=$(get_profile)

  if [ -z "$PROFILE_DIR" ]; then
    echo "❌ Failed to find/create Firefox profile"
    exit 1
  fi
fi

firefoxSetting() {
  local u="$PROFILE_DIR/user.js"
  touch "$u"
  sed -i '/user_pref("'"$1"',.*);/d' "$u"
  grep -q "$1" "$u" || echo "user_pref(\"$1\",$2);" >>"$u"
}

applyTheme() {
  echo "Installing theme to: $PROFILE_DIR"
  mkdir -p "$PROFILE_DIR/chrome"
  cp -r "$FIREFOX_DIR/chrome"/* "$PROFILE_DIR/chrome/"
}

# Enable userChrome.css
firefoxSetting toolkit.legacyUserProfileCustomizations.stylesheets true

firefoxSetting extensions.pocket.enabled false
firefoxSetting findbar.highlightAll true

applyTheme
echo "✅ Firefox theme installed successfully!"
echo "Credit to Kaskapa: https://github.com/Kaskapa/Monochrome-Neubrutalism-Firefox-Theme"
