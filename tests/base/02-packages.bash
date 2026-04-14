#!/usr/bin/env bash
# Verifies that 02-packages.bash installed every package listed in
# packages.txt. Reads the same file the script uses and checks each
# package via dpkg -s.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

PACKAGES_FILE="${PACKAGES_FILE:-${CONFIG_DIR}/packages.txt}"

mapfile -t packages < <(grep -v '^\s*#' "${PACKAGES_FILE}" | grep -v '^\s*$')

echo "  Checking ${#packages[@]} packages from packages.txt..."
for pkg in "${packages[@]}"; do
    dpkg -s "${pkg}" > /dev/null 2>&1 || { echo "FAIL: ${pkg} is not installed" >&2; exit 1; }
done

echo "  All checks passed."
