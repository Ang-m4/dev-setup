#!/usr/bin/env bash
# Verifies that 00-github.bash installed the GitHub CLI, authenticated
# successfully, and uploaded the SSH and GPG keys to GitHub.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
source "${CONFIG_DIR}/config.env"

echo "  Checking gh is installed..."
command -v gh

echo "  Checking gh is authenticated..."
gh auth status

SSH_KEY="${HOME}/.ssh/github_ed25519.pub"
SSH_PUB_KEY="$(awk '{print $2}' "${SSH_KEY}")"

echo "  Checking SSH key is on GitHub..."
gh ssh-key list | grep -q "${SSH_PUB_KEY}"

GPG_KEY_ID="$(gpg --list-secret-keys --keyid-format long --with-colons "${GIT_USER_EMAIL}" 2>/dev/null \
    | awk -F: '/^sec:/ {print $5; exit}')"

echo "  Checking GPG key is on GitHub..."
gh gpg-key list | grep -q "${GPG_KEY_ID}"

# --- Cleanup: remove uploaded keys from GitHub ---

SSH_ID="$(gh api /user/keys --jq ".[] | select(.key | contains(\"${SSH_PUB_KEY}\")) | .id")"
if [[ -n "${SSH_ID}" ]]; then
    echo "  Cleaning up SSH key from GitHub..."
    gh api -X DELETE "/user/keys/${SSH_ID}" --silent
fi

REMOTE_GPG_ID="$(gh api /user/gpg_keys --jq ".[] | select(.key_id == \"${GPG_KEY_ID}\") | .id")"
if [[ -n "${REMOTE_GPG_ID}" ]]; then
    echo "  Cleaning up GPG key from GitHub..."
    gh api -X DELETE "/user/gpg_keys/${REMOTE_GPG_ID}" --silent
fi

echo "  All checks passed."
