#!/usr/bin/env bash
# Verifies that 03-node.bash installed nvm, the configured Node.js version,
# npm, and yarn. Checks that nvm is sourced, the correct Node version is
# active, and yarn is globally available.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
source "${CONFIG_DIR}/config.env"

export NVM_DIR="${HOME}/.nvm"
# shellcheck source=/dev/null
source "${NVM_DIR}/nvm.sh"

echo "  Checking ~/.nvm directory exists..."
[[ -d "${HOME}/.nvm" ]]

echo "  Checking nvm is available..."
command -v nvm > /dev/null 2>&1

echo "  Checking Node ${NODE_VERSION} is installed..."
nvm ls "${NODE_VERSION}" > /dev/null 2>&1

echo "  Checking Node ${NODE_VERSION} is the default..."
[[ "$(nvm alias default)" == *"${NODE_VERSION}"* ]]

echo "  Checking node binary is available..."
command -v node > /dev/null 2>&1

echo "  Checking npm is available..."
command -v npm > /dev/null 2>&1

echo "  Checking yarn is available..."
command -v yarn > /dev/null 2>&1

echo "  All checks passed."
