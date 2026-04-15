#!/usr/bin/env bash
# Verifies that 01-systemd.bash enabled the expected systemd services.
# Checks that each service is enabled (will start on boot). Active state
# is not checked because some services cannot fully start inside Docker.

set -euo pipefail

SERVICES=(
    ssh
    docker
    ufw
    unattended-upgrades
    systemd-timesyncd
)

for service in "${SERVICES[@]}"; do
    echo "  Checking ${service} is enabled..."
    systemctl is-enabled "${service}" > /dev/null 2>&1 \
        || { echo "FAIL: ${service} is not enabled" >&2; exit 1; }
done

echo "  All checks passed."
