#!/usr/bin/env bash
# Enables and starts systemd services installed by earlier scripts. This
# ensures that ssh, docker, ufw, unattended-upgrades, and time sync all
# persist across reboots. Safe to re-run — enabling an already-enabled
# service is a no-op.
#
# Prerequisites: scripts/base, scripts/security, and scripts/dev must
# have run first (packages and services are already installed).
#
# Usage: bash scripts/services/01-systemd.bash

set -euo pipefail

SERVICES=(
    ssh
    docker
    ufw
    unattended-upgrades
    systemd-timesyncd
)

for service in "${SERVICES[@]}"; do
    if systemctl is-enabled "${service}" > /dev/null 2>&1; then
        echo "==> ${service} is already enabled, skipping."
    else
        echo "==> Enabling ${service}..."
        sudo systemctl enable "${service}"
    fi

    if systemctl is-active "${service}" > /dev/null 2>&1; then
        echo "==> ${service} is already running."
    else
        echo "==> Starting ${service}..."
        sudo systemctl start "${service}" 2>/dev/null || echo "==> ${service} could not start (expected in containers)."
    fi
done

echo "==> Systemd services configuration complete."
