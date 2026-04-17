#!/usr/bin/env bash
# Customizes the bash shell by installing Oh My Posh as the prompt engine and
# copying the aliases defined in config/bash_aliases to ~/.bash_aliases. Oh My
# Posh is installed to ~/.local/bin (no sudo required), the Cousine Nerd Font
# is installed to the user font directory, the theme named by OMP_THEME in
# config.env is downloaded to ~/.poshthemes, and ~/.bashrc is updated to init
# the prompt and source the aliases file.
#
# Note: when accessing this machine remotely (VS Code Remote SSH, Tailscale SSH,
# etc.), the Nerd Font must also be installed on the local terminal for glyphs
# to render correctly.
#
# Usage: bash scripts/dev/06-shell.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

if [[ -z "${OMP_THEME:-}" ]]; then
    echo "ERROR: OMP_THEME is not set in config.env" >&2
    exit 1
fi

ALIASES_SRC="${CONFIG_DIR}/bash_aliases"

if [[ ! -f "${ALIASES_SRC}" ]]; then
    echo "ERROR: aliases file not found at ${ALIASES_SRC}" >&2
    exit 1
fi

# --- Install Oh My Posh ---

OMP_BIN_DIR="${HOME}/.local/bin"
OMP_BIN="${OMP_BIN_DIR}/oh-my-posh"

if [[ -x "${OMP_BIN}" ]]; then
    echo "==> Oh My Posh is already installed, skipping."
else
    echo "==> Installing Oh My Posh..."
    mkdir -p "${OMP_BIN_DIR}"
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "${OMP_BIN_DIR}"
fi

# --- Install theme ---

OMP_THEMES_DIR="${HOME}/.poshthemes"
OMP_THEME_FILE="${OMP_THEMES_DIR}/${OMP_THEME}.omp.json"

if [[ -f "${OMP_THEME_FILE}" ]]; then
    echo "==> Oh My Posh theme ${OMP_THEME} already present, skipping."
else
    echo "==> Downloading Oh My Posh ${OMP_THEME} theme..."
    mkdir -p "${OMP_THEMES_DIR}"
    curl -fsSL "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${OMP_THEME}.omp.json" \
        -o "${OMP_THEME_FILE}"
fi

# --- Install Cousine Nerd Font ---

FONTS_DIR="${HOME}/.local/share/fonts"
COUSINE_DIR="${FONTS_DIR}/CousineNerdFont"

if fc-list 2>/dev/null | grep -qi "cousine.*nerd font"; then
    echo "==> Cousine Nerd Font already installed, skipping."
else
    echo "==> Downloading Cousine Nerd Font..."
    mkdir -p "${COUSINE_DIR}"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Cousine.zip \
        -o /tmp/Cousine.zip
    unzip -qo /tmp/Cousine.zip -d "${COUSINE_DIR}"
    rm -f /tmp/Cousine.zip
    fc-cache -f "${FONTS_DIR}" > /dev/null 2>&1 || true
fi

# --- Configure .bashrc ---

BASHRC="${HOME}/.bashrc"
touch "${BASHRC}"

OMP_MARKER="# oh-my-posh setup"

if grep -q "${OMP_MARKER}" "${BASHRC}"; then
    echo "==> Oh My Posh already in .bashrc, skipping."
else
    echo "==> Adding Oh My Posh to .bashrc..."
    cat >> "${BASHRC}" << EOF

# oh-my-posh setup
export PATH="\${HOME}/.local/bin:\${PATH}"
if command -v oh-my-posh > /dev/null 2>&1; then
    eval "\$(oh-my-posh init bash --config \${HOME}/.poshthemes/${OMP_THEME}.omp.json)"
fi
EOF
fi

ALIASES_MARKER="# bash aliases"

if grep -q "${ALIASES_MARKER}" "${BASHRC}"; then
    echo "==> .bashrc already sources .bash_aliases, skipping."
else
    echo "==> Adding .bash_aliases source to .bashrc..."
    cat >> "${BASHRC}" << 'EOF'

# bash aliases
if [[ -f "${HOME}/.bash_aliases" ]]; then
    source "${HOME}/.bash_aliases"
fi
EOF
fi

# --- Install aliases ---

ALIASES_DST="${HOME}/.bash_aliases"

echo "==> Copying ${ALIASES_SRC} to ${ALIASES_DST}..."
cp "${ALIASES_SRC}" "${ALIASES_DST}"

echo "==> Shell customization complete."
