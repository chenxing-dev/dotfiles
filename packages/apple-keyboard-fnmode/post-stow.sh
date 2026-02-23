#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
modprobe_src="${script_dir}/.local/share/modprobe.d/hid_apple.conf"
modprobe_dst="/etc/modprobe.d/hid_apple.conf"

if [[ ! -f "${modprobe_src}" ]]; then
	echo "[ERROR] Missing modprobe source file: ${modprobe_src}" >&2
	exit 1
fi

echo "[INFO] Installing modprobe config to ${modprobe_dst} (requires sudo)..."
sudo install -D -m 0644 "${modprobe_src}" "${modprobe_dst}"

cat <<'EOF'
[INFO] Done.
[INFO] Apply the change by rebooting, or reloading the module:
  sudo modprobe -r hid_apple
  sudo modprobe hid_apple fnmode=2
EOF
