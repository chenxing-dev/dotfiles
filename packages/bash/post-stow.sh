#!/usr/bin/env bash
set -euo pipefail

BASHRC="$HOME/.bashrc"

# Ensure .bashrc exists
if [[ ! -f "$BASHRC" ]]; then
  printf '# ~/.bashrc\n' >"$BASHRC"
fi

START_MARK="# chenxing-dev/dotfiles"
END_MARK="# chenxing-dev/dotfiles end"

# Remove any existing managed block (idempotent)
if grep -Fq "$START_MARK" "$BASHRC"; then
  # Delete from START_MARK to END_MARK (inclusive)
  # Use '|' as delimiter to avoid conflicts with '/' in the markers
  sed -i "\|$START_MARK|,\|$END_MARK|d" "$BASHRC"
fi

# Ensure there is exactly one blank line before our managed block:
# - If file is non-empty and last character is not a newline, add one.
if [[ -s "$BASHRC" ]] && [[ "$(tail -c 1 "$BASHRC" 2>/dev/null || echo)" != $'\n' ]]; then
  echo >>"$BASHRC"
fi

# Append our minimal PS1 block
cat >>"$BASHRC" <<'EOF'
# chenxing-dev/dotfiles
PS1='\w > ' # Minimal prompt: show only current directory like: "~ > "
# chenxing-dev/dotfiles end
EOF