#!/usr/bin/env bash
# Installs all apt packages listed in config/packages.txt. Lines starting
# with # and blank lines are ignored. Reads the package list, filters out
# comments and empty lines, and installs everything in a single apt call.
#
# Usage: bash scripts/base/02-packages.bash
#        PACKAGES_FILE=/custom/path.txt bash scripts/base/02-packages.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

PACKAGES_FILE="${PACKAGES_FILE:-${CONFIG_DIR}/packages.txt}"

if [[ ! -f "${PACKAGES_FILE}" ]]; then
    echo "ERROR: packages file not found: ${PACKAGES_FILE}" >&2
    exit 1
fi

# Read packages, strip comments and blank lines
mapfile -t packages < <(grep -v '^\s*#' "${PACKAGES_FILE}" | grep -v '^\s*$')

if [[ ${#packages[@]} -eq 0 ]]; then
    echo "==> No packages to install."
    exit 0
fi

echo "==> Installing ${#packages[@]} packages..."
sudo -E apt-get install -y -qq "${packages[@]}"

echo "==> Package installation complete."
