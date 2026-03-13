#!/usr/bin/env bash
# Updates the system package index, upgrades all installed packages, and
# configures unattended-upgrades for automatic security patches.
#
# Usage: bash scripts/base/01-update.bash
#        DOTFILES_ENV=test bash scripts/base/01-update.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

DOTFILES_ENV="${DOTFILES_ENV:-production}"

if [[ "${DOTFILES_ENV}" == "test" ]]; then
    echo "==> Test environment detected, skipping system update and upgrade."
else
    echo "==> Updating package index..."
    sudo apt-get update -qq

    echo "==> Upgrading installed packages..."
    sudo apt-get upgrade -y -qq

    echo "==> Removing unused packages..."
    sudo apt-get autoremove -y -qq
fi

echo "==> Installing unattended-upgrades..."
sudo apt-get install -y -qq unattended-upgrades

if [[ "${DOTFILES_ENV}" != "test" ]]; then
    echo "==> Enabling unattended-upgrades..."
    sudo dpkg-reconfigure -f noninteractive unattended-upgrades
fi

echo "==> System update complete."
