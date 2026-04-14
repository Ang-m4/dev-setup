#!/usr/bin/env bash
# Verifies that 04-docker.bash installed Docker Engine, the Docker CLI,
# containerd, and the Compose plugin. Also checks that the current user
# belongs to the docker group.

set -euo pipefail

echo "  Checking docker-ce is installed..."
dpkg -s docker-ce > /dev/null 2>&1

echo "  Checking docker-ce-cli is installed..."
dpkg -s docker-ce-cli > /dev/null 2>&1

echo "  Checking containerd.io is installed..."
dpkg -s containerd.io > /dev/null 2>&1

echo "  Checking docker-compose-plugin is installed..."
dpkg -s docker-compose-plugin > /dev/null 2>&1

echo "  Checking docker binary is available..."
command -v docker > /dev/null 2>&1

echo "  Checking docker compose subcommand is available..."
docker compose version > /dev/null 2>&1

CURRENT_USER="$(whoami)"
echo "  Checking ${CURRENT_USER} is in the docker group..."
getent group docker | grep -q "${CURRENT_USER}"

echo "  All checks passed."
