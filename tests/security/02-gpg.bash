#!/usr/bin/env bash
# Verifies that 02-gpg.bash generated a GPG key pair suitable for GitHub
# commit signing. Checks that a secret key exists for the configured identity
# and uses the expected algorithm.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
source "${CONFIG_DIR}/config.env"

echo "  Checking gpg is installed..."
command -v gpg

echo "  Checking a secret key exists for ${GIT_USER_EMAIL}..."
gpg --list-secret-keys "${GIT_USER_EMAIL}" > /dev/null 2>&1

GPG_OUTPUT="$(gpg --list-secret-keys --with-colons "${GIT_USER_EMAIL}")"

echo "  Checking key UID contains name and email..."
[[ "${GPG_OUTPUT}" == *"${GIT_USER_NAME}"* ]]
[[ "${GPG_OUTPUT}" == *"${GIT_USER_EMAIL}"* ]]

echo "  Checking key uses ed25519 algorithm..."
[[ "${GPG_OUTPUT}" == *"ed25519"* ]]

echo "  All checks passed."
