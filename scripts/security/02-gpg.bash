#!/usr/bin/env bash
# Generates an ed25519 GPG key pair for GitHub commit signing. Uses the name
# and email from config.env as the key identity. The key is created without a
# passphrase for non-interactive use over SSH. Skips generation if a key for
# the configured email already exists.
#
# Usage: bash scripts/security/02-gpg.bash

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

if gpg --list-secret-keys "${GIT_USER_EMAIL}" > /dev/null 2>&1; then
    echo "==> GPG key for ${GIT_USER_EMAIL} already exists, skipping."
    exit 0
fi

echo "==> Generating GPG key for ${GIT_USER_NAME} <${GIT_USER_EMAIL}>..."
gpg --batch --passphrase '' --pinentry-mode loopback --quick-gen-key \
    "${GIT_USER_NAME} <${GIT_USER_EMAIL}>" ed25519 sign 0

echo "==> GPG key generation complete."
