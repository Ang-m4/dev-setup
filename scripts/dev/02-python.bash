#!/usr/bin/env bash
# Installs pyenv for Python version management and builds the Python version
# specified in config.env. Adds pyenv initialization to ~/.bashrc so it
# activates on login. Build dependencies are installed via apt since pyenv
# compiles Python from source.
#
# Usage: bash scripts/dev/02-python.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

if [[ -z "${PYTHON_VERSION:-}" ]]; then
    echo "ERROR: PYTHON_VERSION is not set in config.env" >&2
    exit 1
fi

# --- Install build dependencies ---

DEPS=(
    build-essential
    git
    curl
    libssl-dev
    zlib1g-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    libncurses-dev
    libffi-dev
    xz-utils
    liblzma-dev
)

echo "==> Installing pyenv build dependencies..."
sudo -E apt-get install -y -qq "${DEPS[@]}"

# --- Install pyenv ---

export PYENV_ROOT="${HOME}/.pyenv"

if [[ -d "${PYENV_ROOT}" ]]; then
    echo "==> pyenv is already installed, skipping."
else
    echo "==> Installing pyenv..."
    git clone https://github.com/pyenv/pyenv.git "${PYENV_ROOT}"
fi

export PATH="${PYENV_ROOT}/bin:${PATH}"
eval "$(pyenv init -)"

# --- Configure shell ---

BASHRC="${HOME}/.bashrc"
MARKER="# pyenv setup"

if grep -q "${MARKER}" "${BASHRC}" 2>/dev/null; then
    echo "==> pyenv already in .bashrc, skipping."
else
    echo "==> Adding pyenv to .bashrc..."
    cat >> "${BASHRC}" << 'EOF'

# pyenv setup
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"
eval "$(pyenv init -)"
EOF
fi

# --- Install Python version ---

if pyenv versions --bare | grep -q "^${PYTHON_VERSION}$"; then
    echo "==> Python ${PYTHON_VERSION} is already installed, skipping."
else
    echo "==> Installing Python ${PYTHON_VERSION} (this may take a few minutes)..."
    pyenv install "${PYTHON_VERSION}"
fi

echo "==> Setting Python ${PYTHON_VERSION} as global default..."
pyenv global "${PYTHON_VERSION}"

echo "==> Python setup complete."
