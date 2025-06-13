#!/usr/bin/env bash

# Dotfiles Setup Script
# Usage: ./setup.sh [--all] [package1 package2 ...]

# "strict mode"
set -euo pipefail

# Configuration
# Get repository root directory
HOME_DIR=${HOME}
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${HOME_DIR}/dotfiles_backup"
STOW_DIR="${REPO_ROOT}/packages"
STOW_CMD="stow --verbose=1 --dir=${STOW_DIR} --target=${HOME_DIR}"
SCRIPT_DIR="${REPO_ROOT}/scripts"
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
    info "Checking for existing ${package} files to backup..."

    local backup_path
    backup_path="${BACKUP_DIR}/${package}_$(date +%Y%m%d_%H%M%S)"
    local backup_created=false
    mkdir -p "${backup_path}" || error "Failed to create backup directory"

    # Find and backup existing files
    while IFS= read -r -d $'\0' file; do
        local target_file="${HOME_DIR}/${file}"
        if [[ -e "${target_file}" ]]; then
            local backup_file="${backup_path}/${file}"
            mkdir -p "$(dirname "${backup_file}")"
            cp -a -- "${target_file}" "${backup_file}" || warn "Failed to backup ${target_file}"
            backup_created=true
        fi
    done < <(cd "${STOW_DIR}/${package}" && find . -type f -print0)

    # Remove backup directory if no files were backed up
    if ! $backup_created; then
        rmdir "${backup_path}" 2>/dev/null
        info "No existing ${package} files found - no backup created"
    else
        info "Backup of ${package} completed to ${backup_path}"
    fi
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
    --home-dir)
        HOME_DIR="$2"
        BACKUP_DIR="${HOME_DIR}/dotfiles_backup"
        STOW_CMD="stow --verbose=1 --dir=${STOW_DIR} --target=${HOME_DIR}"
        shift 2
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
