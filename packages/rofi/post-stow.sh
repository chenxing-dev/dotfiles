#!/usr/bin/env bash

ROFI_BIN_DIR=$(dirname "$0")/.config/rofi/bin

if [[ -d "$ROFI_BIN_DIR" ]]; then
    # Make all scripts executable
    echo "Making rofi scripts executable"
    find "$ROFI_BIN_DIR" -type f -exec chmod +x {} \;

    # Create symlinks in ~/.local/bin
    mkdir -p "$HOME/.local/bin"

    # Process each script individually
    # Use find with null termination
    while IFS= read -r -d $'\0' script; do
        script_name=$(basename "$script")
        target_path="$HOME/.local/bin/$script_name"

        # Create/update symlink if needed
        if [[ ! -e "$target_path" ||
            "$(readlink -f "$target_path")" != "$(readlink -f "$script")" ]]; then
            echo "Creating symlink for $script_name"
            ln -sf "$script" "$target_path"
        fi
    done < <(find "$ROFI_BIN_DIR" -maxdepth 1 -type f -print0)

    echo "Rofi scripts installed to ~/.local/bin"
fi
