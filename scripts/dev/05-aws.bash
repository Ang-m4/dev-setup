#!/usr/bin/env bash
# Installs the AWS CLI v2 and the Session Manager plugin, and writes the AWS
# SSO profile to ~/.aws/config using values from config.env. AWS CLI is
# installed from the official zip archive since it is not available in apt.
# The Session Manager plugin is required for aws ssm start-session commands.
#
# Usage: bash scripts/dev/05-aws.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

sudo -E apt-get install -y -qq curl unzip

# --- Install AWS CLI v2 ---

if command -v aws > /dev/null 2>&1 && aws --version 2>&1 | grep -q "aws-cli/2"; then
    echo "==> AWS CLI v2 is already installed, skipping."
else
    echo "==> Installing AWS CLI v2..."
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip -qo /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install --update
    rm -rf /tmp/awscliv2.zip /tmp/aws
fi

# --- Install Session Manager plugin ---

if command -v session-manager-plugin > /dev/null 2>&1; then
    echo "==> Session Manager plugin is already installed, skipping."
else
    echo "==> Installing Session Manager plugin..."
    curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
        -o /tmp/session-manager-plugin.deb
    sudo dpkg -i /tmp/session-manager-plugin.deb
    rm -f /tmp/session-manager-plugin.deb
fi

# --- Configure AWS SSO profile ---

if [[ -n "${AWS_SSO_PROFILE:-}" && -n "${AWS_SSO_SESSION:-}" && -n "${AWS_SSO_START_URL:-}" ]]; then
    AWS_CONFIG_FILE="${HOME}/.aws/config"
    mkdir -p "${HOME}/.aws"
    touch "${AWS_CONFIG_FILE}"
    chmod 600 "${AWS_CONFIG_FILE}"

    if grep -q "^\[profile ${AWS_SSO_PROFILE}\]" "${AWS_CONFIG_FILE}"; then
        echo "==> AWS profile ${AWS_SSO_PROFILE} already configured, skipping."
    else
        echo "==> Writing AWS SSO config to ${AWS_CONFIG_FILE}..."
        cat >> "${AWS_CONFIG_FILE}" << EOF

[sso-session ${AWS_SSO_SESSION}]
sso_start_url = ${AWS_SSO_START_URL}
sso_region = ${AWS_REGION}
sso_registration_scopes = sso:account:access

[profile ${AWS_SSO_PROFILE}]
sso_session = ${AWS_SSO_SESSION}
sso_account_id = ${AWS_SSO_ACCOUNT_ID}
sso_role_name = ${AWS_SSO_ROLE_NAME}
region = ${AWS_REGION}
EOF
    fi
else
    echo "==> AWS SSO config values not set in config.env, skipping profile setup."
fi

echo "==> AWS CLI setup complete."
