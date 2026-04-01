#!/usr/bin/env bash
# Configures core system settings: sets the machine hostname and grants the
# primary user passwordless sudo. This runs first so that all subsequent
# scripts can use sudo without a password prompt.
#
# Usage: bash scripts/base/00-system.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

if [[ -z "${HOSTNAME:-}" ]]; then
    echo "ERROR: HOSTNAME is not set in config.env" >&2
    exit 1
fi

CURRENT_USER="$(whoami)"

echo "==> Configuring passwordless sudo for ${CURRENT_USER}..."
echo "${CURRENT_USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/${CURRENT_USER}" > /dev/null
sudo chmod 0440 "/etc/sudoers.d/${CURRENT_USER}"

echo "==> Setting hostname to ${HOSTNAME}..."
if ! grep -q "${HOSTNAME}" /etc/hosts; then
    echo "127.0.0.1 ${HOSTNAME}" | sudo tee -a /etc/hosts > /dev/null
fi
echo "${HOSTNAME}" | sudo tee /etc/hostname > /dev/null
sudo hostname "${HOSTNAME}"

echo "==> System configuration complete."
