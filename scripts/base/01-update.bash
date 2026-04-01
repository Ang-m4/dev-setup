#!/usr/bin/env bash
# Updates the system package index, upgrades all installed packages, and
# configures unattended-upgrades for automatic security patches.
#
# Usage: bash scripts/base/01-update.bash

set -euo pipefail

echo "==> Updating package index..."
sudo -E apt-get update -qq

echo "==> Upgrading installed packages..."
sudo -E apt-get upgrade -y -qq

echo "==> Removing unused packages..."
sudo -E apt-get autoremove -y -qq

echo "==> Installing unattended-upgrades..."
sudo -E apt-get install -y -qq unattended-upgrades

echo "==> Enabling unattended-upgrades..."
sudo -E dpkg-reconfigure -f noninteractive unattended-upgrades

echo "==> System update complete."
