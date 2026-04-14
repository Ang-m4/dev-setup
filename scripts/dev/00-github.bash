#!/usr/bin/env bash
# Installs the GitHub CLI (gh), authenticates with GitHub, and uploads the
# machine's SSH and GPG keys. Authentication uses GH_TOKEN from config.env when
# available (Docker/CI), otherwise falls back to interactive browser device flow.
# Existing keys on GitHub are detected by fingerprint/ID so the script is safe
# to re-run.
#
# Prerequisites: scripts/security must have run first (SSH + GPG keys exist).
#
# Usage: bash scripts/dev/00-github.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

if [[ -z "${GIT_USER_EMAIL:-}" ]]; then
    echo "ERROR: GIT_USER_EMAIL is not set in config.env" >&2
    exit 1
fi

# --- Install gh CLI ---

if command -v gh > /dev/null 2>&1; then
    echo "==> gh is already installed, skipping."
else
    echo "==> Installing GitHub CLI..."

    sudo -E mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo -E tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo -E chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo -E tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    sudo -E apt-get update -qq
    sudo -E apt-get install -y -qq gh
fi

# --- Authenticate ---

if gh auth status > /dev/null 2>&1; then
    echo "==> Already authenticated with GitHub, skipping."
elif [[ -n "${GH_TOKEN:-}" ]]; then
    echo "==> Authenticating with GitHub via token..."
    echo "${GH_TOKEN}" | gh auth login --with-token
else
    echo "==> Authenticating with GitHub via browser..."
    gh auth login --web --git-protocol ssh --scopes admin:public_key,admin:gpg_key,admin:ssh_signing_key
fi

# --- Upload SSH key ---

SSH_KEY="${HOME}/.ssh/github_ed25519.pub"

if [[ ! -f "${SSH_KEY}" ]]; then
    echo "ERROR: SSH key not found at ${SSH_KEY}. Run scripts/security first." >&2
    exit 1
fi

SSH_PUB_KEY="$(awk '{print $2}' "${SSH_KEY}")"

if gh ssh-key list | grep -q "${SSH_PUB_KEY}"; then
    echo "==> SSH key already on GitHub, skipping."
else
    echo "==> Uploading SSH key to GitHub..."
    gh ssh-key add "${SSH_KEY}" --title "dev-machine" --type authentication
fi

# --- Upload GPG key ---

GPG_KEY_ID="$(gpg --list-secret-keys --keyid-format long --with-colons "${GIT_USER_EMAIL}" 2>/dev/null \
    | awk -F: '/^sec:/ {print $5; exit}')"

if [[ -z "${GPG_KEY_ID}" ]]; then
    echo "ERROR: No GPG key found for ${GIT_USER_EMAIL}. Run scripts/security first." >&2
    exit 1
fi

if gh gpg-key list | grep -q "${GPG_KEY_ID}"; then
    echo "==> GPG key already on GitHub, skipping."
else
    echo "==> Uploading GPG key to GitHub..."
    gpg --armor --export "${GPG_KEY_ID}" | gh gpg-key add -
fi

echo "==> GitHub setup complete."
