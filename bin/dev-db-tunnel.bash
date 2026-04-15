#!/usr/bin/env bash
# Authenticates via AWS SSO and opens an SSM port-forwarding tunnel to the
# database. Reads connection parameters from config.env. The SSO login
# opens a browser for authentication, then the tunnel forwards the remote
# RDS port to localhost.
#
# Usage: bash bin/dev-db-tunnel.bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../config" && pwd)"

# shellcheck source=/dev/null
if [[ -f "${CONFIG_DIR}/config.env" ]]; then
    source "${CONFIG_DIR}/config.env"
fi

if [[ -z "${SSM_TARGET_INSTANCE:-}" || -z "${SSM_REMOTE_HOST:-}" ]]; then
    echo "ERROR: SSM_TARGET_INSTANCE and SSM_REMOTE_HOST must be set in config.env" >&2
    exit 1
fi

PROFILE="${AWS_SSO_PROFILE:-default}"
REGION="${AWS_REGION:-us-east-1}"
REMOTE_PORT="${SSM_REMOTE_PORT:-5432}"
LOCAL_PORT="${SSM_LOCAL_PORT:-5432}"

echo "==> Logging in via AWS SSO (profile: ${PROFILE})..."
aws sso login --profile "${PROFILE}" --use-device-code

echo "==> Starting SSM tunnel to ${SSM_REMOTE_HOST}:${REMOTE_PORT} on localhost:${LOCAL_PORT}..."
aws ssm start-session \
    --profile "${PROFILE}" \
    --region "${REGION}" \
    --target "${SSM_TARGET_INSTANCE}" \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "{\"host\":[\"${SSM_REMOTE_HOST}\"],\"portNumber\":[\"${REMOTE_PORT}\"],\"localPortNumber\":[\"${LOCAL_PORT}\"]}"
