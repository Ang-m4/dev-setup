#!/usr/bin/env bash
# Verifies that 01-update.bash ran successfully:
# - unattended-upgrades is installed and configured.

set -euo pipefail

echo "  Checking unattended-upgrades is installed..."
dpkg -s unattended-upgrades > /dev/null 2>&1

echo "  Checking auto-upgrades is enabled..."
grep -q 'APT::Periodic::Update-Package-Lists "1"' /etc/apt/apt.conf.d/20auto-upgrades
grep -q 'APT::Periodic::Unattended-Upgrade "1"' /etc/apt/apt.conf.d/20auto-upgrades

echo "  All checks passed."
