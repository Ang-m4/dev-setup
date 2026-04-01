#!/usr/bin/env bash
# Verifies that 03-locale-timezone.bash configured locale and timezone correctly.
# Reads expected values from config.env and checks system state.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
source "${CONFIG_DIR}/config.env"

echo "  Checking locale is set to ${LOCALE}..."
locale -a | grep -q "${LOCALE%%.*}"

echo "  Checking timezone is set to ${TIMEZONE}..."
readlink /etc/localtime | grep -q "${TIMEZONE}"

echo "  All checks passed."
