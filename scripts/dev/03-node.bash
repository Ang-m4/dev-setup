#!/usr/bin/env bash
# Installs nvm (Node Version Manager), the Node.js version specified in
# config.env, and yarn. Adds nvm initialization to ~/.bashrc so it activates
# on login. npm is included with Node.js and verified after installation.
#
# Usage: bash scripts/dev/03-node.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

if [[ -z "${NODE_VERSION:-}" ]]; then
    echo "ERROR: NODE_VERSION is not set in config.env" >&2
    exit 1
fi

sudo -E apt-get install -y -qq curl

# --- Install nvm ---

export NVM_DIR="${HOME}/.nvm"

if [[ -d "${NVM_DIR}" ]]; then
    echo "==> nvm is already installed, skipping."
else
    echo "==> Installing nvm..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

# shellcheck source=/dev/null
source "${NVM_DIR}/nvm.sh"

# --- Configure shell ---

BASHRC="${HOME}/.bashrc"
MARKER="# nvm setup"

if grep -q "${MARKER}" "${BASHRC}" 2>/dev/null; then
    echo "==> nvm already in .bashrc, skipping."
else
    echo "==> Adding nvm to .bashrc..."
    cat >> "${BASHRC}" << 'EOF'

# nvm setup
export NVM_DIR="${HOME}/.nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && source "${NVM_DIR}/nvm.sh"
EOF
fi

# --- Install Node.js ---

if nvm ls "${NODE_VERSION}" > /dev/null 2>&1; then
    echo "==> Node ${NODE_VERSION} is already installed, skipping."
else
    echo "==> Installing Node ${NODE_VERSION}..."
    nvm install "${NODE_VERSION}"
fi

echo "==> Setting Node ${NODE_VERSION} as default..."
nvm alias default "${NODE_VERSION}"
nvm use "${NODE_VERSION}"

echo "==> npm $(npm --version) is available."

# --- Install yarn ---

if command -v yarn > /dev/null 2>&1; then
    echo "==> yarn is already installed, skipping."
else
    echo "==> Installing yarn..."
    npm install -g yarn
fi

echo "==> Node setup complete."
