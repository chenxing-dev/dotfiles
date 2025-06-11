#!/usr/bin/env bash

# Dotfiles Setup Script
# Usage: ./setup.sh [--all] [package1 package2 ...]

# "strict mode"
set -euo pipefail

# Configuration
BACKUP_DIR="${HOME}/dotfiles_backup"
STOW_DIR="packages"
STOW_CMD="stow --verbose=1 --dir=${STOW_DIR} --target=${HOME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # the absolute path of the directory containing the script
declare -a PACKAGES=()
ALL=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

install_stow() {
    if ! command -v stow &>/dev/null; then
        info "Installing GNU Stow..."
        sudo pacman -Sy --noconfirm stow || error "Failed to install GNU Stow"
    fi
}

backup_files() {
    local package="$1"
    info "Backing up existing ${package} files..."

    local backup_path
    backup_path="${BACKUP_DIR}/${package}_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "${backup_path}"

    cd "${STOW_DIR}/${package}" || error "Package directory not found"

    find . -type f | while read -r file; do
        local target_file="${HOME}/${file}"
        if [[ -f "${target_file}" ]]; then
            local backup_file="${backup_path}/${file}"
            mkdir -p "$(dirname "${backup_file}")"
            cp -v "${target_file}" "${backup_file}" || warn "Failed to backup ${target_file}"
        fi
    done

    cd "${SCRIPT_DIR}" || return
}

stow_package() {
    local package="$1"

    if [[ ! -d "${STOW_DIR}/${package}" ]]; then
        warn "Package ${package} not found. Skipping."
        return
    fi

    backup_files "${package}"

    info "Deploying ${package}..."
    ${STOW_CMD} --restow "${package}" || error "Failed to deploy ${package}"
}

show_help() {
    cat <<EOF
Dotfiles Setup Script
Usage: $0 [OPTIONS] [PACKAGES...]

Options:
  --all      Deploy all available packages
  --help     Show this help message

Available packages:
$(find "${STOW_DIR}" -mindepth 1 -maxdepth 1 -type d -printf '  - %f\n')
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
    --all)
        ALL=true
        shift
        ;;
    --help)
        show_help
        exit 0
        ;;
    -*)
        error "Unknown option: $1"
        ;;
    *)
        PACKAGES+=("$1")
        shift
        ;;
    esac
done

# Main execution
cd "${SCRIPT_DIR}" || error "Failed to access script directory"

install_stow
mkdir -p "${BACKUP_DIR}"

if $ALL; then
    mapfile -t PACKAGES < <(
        find "${STOW_DIR}" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -printf '%f\n'
    )
fi

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    show_help
    error "No packages specified. Use --all or list packages."
fi

for package in "${PACKAGES[@]}"; do
    stow_package "${package}"
done

info "Dotfiles setup completed successfully!"
