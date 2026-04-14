#!/usr/bin/env bash
# Installs Docker Engine (docker-ce), the Docker CLI, containerd, and the
# Compose plugin from Docker's official apt repository. Adds the current
# user to the docker group so Docker commands can run without sudo.
#
# Usage: bash scripts/base/04-docker.bash

set -euo pipefail

# --- Install Docker ---
if command -v docker > /dev/null 2>&1; then
    echo "==> Docker is already installed, skipping."
else
    echo "==> Adding Docker's official GPG key and repository..."
    sudo -E apt-get install -y -qq ca-certificates curl

    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo -E apt-get update -qq

    echo "==> Installing Docker Engine and Compose plugin..."
    sudo -E apt-get install -y -qq \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
fi

# --- Configure docker group ---
CURRENT_USER="$(whoami)"
if id -nG "${CURRENT_USER}" | grep -qw docker; then
    echo "==> ${CURRENT_USER} is already in the docker group, skipping."
else
    echo "==> Adding ${CURRENT_USER} to the docker group..."
    sudo usermod -aG docker "${CURRENT_USER}"
fi

echo "==> Docker setup complete."
