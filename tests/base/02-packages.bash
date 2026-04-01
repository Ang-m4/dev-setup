#!/usr/bin/env bash
# Verifies that 02-packages.bash installed the expected packages.
# Checks a representative sample from each category in packages.txt.

set -euo pipefail

echo "  Checking core packages..."
command -v curl > /dev/null
command -v git > /dev/null
command -v jq > /dev/null
command -v vim > /dev/null
command -v tmux > /dev/null

echo "  Checking networking packages..."
command -v dig > /dev/null

echo "  Checking build packages..."
command -v make > /dev/null
command -v gcc > /dev/null

echo "  Checking monitoring packages..."
command -v ncdu > /dev/null

echo "  All checks passed."
