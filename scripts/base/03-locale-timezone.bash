#!/usr/bin/env bash
# Sets the system locale and timezone from values defined in config.env.
# On a fresh Ubuntu install these are usually configured by the installer,
# but cloud images and minimal installs often default to C.UTF-8 / Etc/UTC.
#
# Usage: bash scripts/base/03-locale-timezone.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

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
sudo -E apt-get install -y -qq locales
sudo locale-gen "${LOCALE}"
sudo update-locale LANG="${LOCALE}"

echo "==> Setting timezone to ${TIMEZONE}..."
sudo ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
echo "${TIMEZONE}" | sudo tee /etc/timezone > /dev/null

echo "==> Locale and timezone configured."
