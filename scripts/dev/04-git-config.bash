#!/usr/bin/env bash
# Configures git global settings: user identity, GPG commit signing, SSH
# command for GitHub, and sensible defaults. Reads user name and email from
# config.env and auto-detects the GPG signing key.
#
# Prerequisites: scripts/security must have run first (SSH + GPG keys exist).
#
# Usage: bash scripts/dev/04-git-config.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

if [[ -z "${GIT_USER_NAME:-}" || -z "${GIT_USER_EMAIL:-}" ]]; then
    echo "ERROR: GIT_USER_NAME and GIT_USER_EMAIL must be set in config.env" >&2
    exit 1
fi

# --- Identity ---

echo "==> Setting git identity..."
git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"

# --- GPG commit signing ---

GPG_KEY_ID="$(gpg --list-secret-keys --keyid-format long --with-colons "${GIT_USER_EMAIL}" 2>/dev/null \
    | awk -F: '/^sec:/ {print $5; exit}')"

if [[ -z "${GPG_KEY_ID}" ]]; then
    echo "ERROR: No GPG key found for ${GIT_USER_EMAIL}. Run scripts/security first." >&2
    exit 1
fi

echo "==> Configuring GPG commit signing with key ${GPG_KEY_ID}..."
git config --global user.signingkey "${GPG_KEY_ID}"
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# --- SSH for GitHub ---

SSH_KEY="${HOME}/.ssh/github_ed25519"

if [[ ! -f "${SSH_KEY}" ]]; then
    echo "ERROR: SSH key not found at ${SSH_KEY}. Run scripts/security first." >&2
    exit 1
fi

echo "==> Configuring SSH command for GitHub..."
git config --global core.sshCommand "ssh -i ${SSH_KEY} -o IdentitiesOnly=yes"

# --- Defaults ---

echo "==> Setting git defaults..."
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global core.editor vim

echo "==> Git configuration complete."
