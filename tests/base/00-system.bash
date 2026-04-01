#!/usr/bin/env bash
# Verifies that 00-system.bash configured the hostname and passwordless sudo
# correctly. Reads expected values from config.env and checks system state.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
source "${CONFIG_DIR}/config.env"

CURRENT_USER="$(whoami)"

echo "  Checking hostname is set to ${HOSTNAME}..."
[[ "$(hostname)" == "${HOSTNAME}" ]]
grep -q "${HOSTNAME}" /etc/hostname

echo "  Checking NOPASSWD sudoers entry for ${CURRENT_USER}..."
sudo visudo -cf "/etc/sudoers.d/${CURRENT_USER}" > /dev/null 2>&1
sudo grep -q "NOPASSWD" "/etc/sudoers.d/${CURRENT_USER}"

echo "  All checks passed."
