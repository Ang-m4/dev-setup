#!/usr/bin/env bash
# Verifies that 06-shell.bash installed Oh My Posh, the Cousine Nerd Font, and
# the theme named by OMP_THEME in config.env; wired up ~/.bashrc with the
# prompt init and alias sourcing; and copied config/bash_aliases to
# ~/.bash_aliases.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
source "${CONFIG_DIR}/config.env"

echo "  Checking oh-my-posh binary exists and is executable..."
[[ -x "${HOME}/.local/bin/oh-my-posh" ]]

echo "  Checking oh-my-posh runs..."
"${HOME}/.local/bin/oh-my-posh" --version > /dev/null 2>&1

echo "  Checking ${OMP_THEME} theme file exists..."
[[ -f "${HOME}/.poshthemes/${OMP_THEME}.omp.json" ]]

echo "  Checking Cousine Nerd Font is installed..."
fc-list | grep -qi "cousine.*nerd font"

echo "  Checking .bashrc initializes oh-my-posh..."
grep -q "oh-my-posh init bash" "${HOME}/.bashrc"

echo "  Checking .bashrc references the ${OMP_THEME} theme..."
grep -q "${OMP_THEME}.omp.json" "${HOME}/.bashrc"

echo "  Checking .bashrc sources .bash_aliases..."
grep -q "bash_aliases" "${HOME}/.bashrc"

echo "  Checking .bash_aliases exists..."
[[ -f "${HOME}/.bash_aliases" ]]

echo "  Checking .bash_aliases matches config/bash_aliases..."
cmp -s "${CONFIG_DIR}/bash_aliases" "${HOME}/.bash_aliases"

echo "  All checks passed."
