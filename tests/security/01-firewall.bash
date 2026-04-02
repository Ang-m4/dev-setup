#!/usr/bin/env bash
# Verifies that 01-firewall.bash configured ufw with the expected rules:
# default deny incoming, allow outgoing, and SSH rate-limited.

set -euo pipefail

UFW_STATUS="$(sudo ufw status verbose)"

echo "  Checking ufw is installed..."
command -v ufw

echo "  Checking ufw is active..."
[[ "${UFW_STATUS}" == *"Status: active"* ]]

echo "  Checking default deny incoming..."
[[ "${UFW_STATUS}" == *"deny (incoming)"* ]]

echo "  Checking default allow outgoing..."
[[ "${UFW_STATUS}" == *"allow (outgoing)"* ]]

echo "  Checking SSH is allowed with rate limiting..."
[[ "${UFW_STATUS}" == *"22/tcp"*"LIMIT"* ]]

echo "  All checks passed."
