#!/usr/bin/env bash
# Verifies that 05-aws.bash installed the AWS CLI v2, the Session Manager
# plugin, and configured the AWS SSO profile in ~/.aws/config.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
source "${CONFIG_DIR}/config.env"

echo "  Checking aws cli is installed..."
command -v aws > /dev/null 2>&1

echo "  Checking aws cli is version 2..."
aws --version 2>&1 | grep -q "aws-cli/2"

echo "  Checking session-manager-plugin is installed..."
command -v session-manager-plugin > /dev/null 2>&1

echo "  Checking AWS profile ${AWS_SSO_PROFILE} is configured..."
grep -q "^\[profile ${AWS_SSO_PROFILE}\]" "${HOME}/.aws/config"

echo "  Checking sso-session ${AWS_SSO_SESSION} is configured..."
grep -q "^\[sso-session ${AWS_SSO_SESSION}\]" "${HOME}/.aws/config"

echo "  All checks passed."
