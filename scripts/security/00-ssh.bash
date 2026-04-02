#!/usr/bin/env bash
# Creates the SSH directory and generates two ed25519 key pairs: a default key
# for general use and a GitHub-specific key. Both keys use the configured email
# as the comment. Existing keys are left untouched so the script is safe to
# re-run.
#
# Usage: bash scripts/security/00-ssh.bash

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

SSH_DIR="${HOME}/.ssh"

echo "==> Ensuring ${SSH_DIR} exists..."
mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

generate_key() {
    local key_path="$1"
    local comment="$2"

    if [[ -f "${key_path}" ]]; then
        echo "==> Key ${key_path} already exists, skipping."
        return
    fi

    echo "==> Generating ${key_path}..."
    ssh-keygen -t ed25519 -C "${comment}" -f "${key_path}" -N ""
}

generate_key "${SSH_DIR}/id_ed25519" "${GIT_USER_EMAIL}"
generate_key "${SSH_DIR}/github_ed25519" "${GIT_USER_EMAIL}"

echo "==> SSH key setup complete."
