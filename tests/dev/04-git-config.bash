#!/usr/bin/env bash
# Verifies that 04-git-config.bash configured git identity, GPG commit
# signing, SSH for GitHub, and sensible defaults. Reads expected values
# from config.env and checks them against git config.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
source "${CONFIG_DIR}/config.env"

echo "  Checking user.name..."
[[ "$(git config --global user.name)" == "${GIT_USER_NAME}" ]]

echo "  Checking user.email..."
[[ "$(git config --global user.email)" == "${GIT_USER_EMAIL}" ]]

echo "  Checking commit.gpgsign is true..."
[[ "$(git config --global commit.gpgsign)" == "true" ]]

echo "  Checking tag.gpgsign is true..."
[[ "$(git config --global tag.gpgsign)" == "true" ]]

echo "  Checking user.signingkey is set..."
[[ -n "$(git config --global user.signingkey)" ]]

echo "  Checking core.sshCommand points to github key..."
git config --global core.sshCommand | grep -q "github_ed25519"

echo "  Checking init.defaultBranch is main..."
[[ "$(git config --global init.defaultBranch)" == "main" ]]

echo "  Checking pull.rebase is true..."
[[ "$(git config --global pull.rebase)" == "true" ]]

echo "  Checking push.autoSetupRemote is true..."
[[ "$(git config --global push.autoSetupRemote)" == "true" ]]

echo "  Checking core.editor is vim..."
[[ "$(git config --global core.editor)" == "vim" ]]

echo "  All checks passed."
