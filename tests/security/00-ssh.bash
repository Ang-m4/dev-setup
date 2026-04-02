#!/usr/bin/env bash
# Verifies that 00-ssh.bash created the SSH directory and key pairs
# correctly. Checks for the default key and a GitHub-specific key,
# proper permissions, and expected key comments.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
source "${CONFIG_DIR}/config.env"

SSH_DIR="${HOME}/.ssh"

echo "  Checking ~/.ssh directory exists with correct permissions..."
[[ -d "${SSH_DIR}" ]]
[[ "$(stat -c '%a' "${SSH_DIR}")" == "700" ]]

echo "  Checking default SSH key pair exists..."
[[ -f "${SSH_DIR}/id_ed25519" ]]
[[ -f "${SSH_DIR}/id_ed25519.pub" ]]

echo "  Checking default key has correct permissions..."
[[ "$(stat -c '%a' "${SSH_DIR}/id_ed25519")" == "600" ]]
[[ "$(stat -c '%a' "${SSH_DIR}/id_ed25519.pub")" == "644" ]]

echo "  Checking default key comment contains email..."
grep -q "${GIT_USER_EMAIL}" "${SSH_DIR}/id_ed25519.pub"

echo "  Checking GitHub SSH key pair exists..."
[[ -f "${SSH_DIR}/github_ed25519" ]]
[[ -f "${SSH_DIR}/github_ed25519.pub" ]]

echo "  Checking GitHub key has correct permissions..."
[[ "$(stat -c '%a' "${SSH_DIR}/github_ed25519")" == "600" ]]
[[ "$(stat -c '%a' "${SSH_DIR}/github_ed25519.pub")" == "644" ]]

echo "  Checking GitHub key comment contains email..."
grep -q "${GIT_USER_EMAIL}" "${SSH_DIR}/github_ed25519.pub"

echo "  All checks passed."
