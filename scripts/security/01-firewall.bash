#!/usr/bin/env bash
# Configures ufw with a secure default policy: deny all incoming traffic,
# allow all outgoing, and rate-limit SSH to prevent brute-force attempts.
# Safe to re-run — ufw skips duplicate rules automatically.
#
# Usage: bash scripts/security/01-firewall.bash

set -euo pipefail

echo "==> Installing ufw..."
sudo -E apt-get install -y ufw

echo "==> Setting default policies..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "==> Allowing and rate-limiting SSH..."
sudo ufw limit 22/tcp

echo "==> Enabling ufw..."
sudo ufw --force enable

echo "==> Firewall configuration complete."
