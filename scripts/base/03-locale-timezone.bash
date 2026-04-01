#!/usr/bin/env bash
# Sets the system locale and timezone from values defined in config.env.
# On a fresh Ubuntu install these are usually configured by the installer,
# but cloud images and minimal installs often default to C.UTF-8 / Etc/UTC.
#
# Usage: bash scripts/base/03-locale-timezone.bash
#        DOTFILES_ENV=test bash scripts/base/03-locale-timezone.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

DOTFILES_ENV="${DOTFILES_ENV:-production}"

if [[ -z "${LOCALE:-}" ]]; then
    echo "ERROR: LOCALE is not set in config.env" >&2
    exit 1
fi

if [[ -z "${TIMEZONE:-}" ]]; then
    echo "ERROR: TIMEZONE is not set in config.env" >&2
    exit 1
fi

if [[ ! -f "/usr/share/zoneinfo/${TIMEZONE}" ]]; then
    echo "ERROR: Invalid timezone '${TIMEZONE}' — not found in /usr/share/zoneinfo" >&2
    exit 1
fi

echo "==> Setting locale to ${LOCALE}..."
if [[ "${DOTFILES_ENV}" == "test" ]]; then
    sudo apt-get install --dry-run locales
else
    sudo locale-gen "${LOCALE}"
    sudo update-locale LANG="${LOCALE}"
fi

echo "==> Setting timezone to ${TIMEZONE}..."
if [[ "${DOTFILES_ENV}" == "test" ]]; then
    echo "==> Dry-run: /etc/localtime -> /usr/share/zoneinfo/${TIMEZONE}"
else
    sudo timedatectl set-timezone "${TIMEZONE}"
fi

echo "==> Locale and timezone configured."
