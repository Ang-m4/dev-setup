#!/usr/bin/env bash
# Verifies that 02-python.bash installed pyenv, the required build
# dependencies, and the configured Python version. Checks that pyenv
# is on the PATH and the global Python version matches config.env.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
source "${CONFIG_DIR}/config.env"

echo "  Checking pyenv build dependencies..."
DEPS=(
    zlib1g-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    libncurses-dev
    xz-utils
    liblzma-dev
)
for dep in "${DEPS[@]}"; do
    dpkg -s "${dep}" > /dev/null 2>&1 || { echo "FAIL: ${dep} is not installed" >&2; exit 1; }
done

echo "  Checking ~/.pyenv directory exists..."
[[ -d "${HOME}/.pyenv" ]]

echo "  Checking pyenv is on the PATH..."
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"
command -v pyenv > /dev/null 2>&1

echo "  Checking Python ${PYTHON_VERSION} is installed..."
pyenv versions --bare | grep -q "^${PYTHON_VERSION}$"

echo "  Checking global Python version is ${PYTHON_VERSION}..."
eval "$(pyenv init -)"
[[ "$(python --version 2>&1)" == "Python ${PYTHON_VERSION}" ]]

echo "  All checks passed."
