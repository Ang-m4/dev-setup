#!/usr/bin/env bats
# Tests for scripts/base/01-update.bash

setup() {
    export DOTFILES_ENV=test
}

@test "01-update: script runs successfully" {
    bash scripts/base/01-update.bash
}

@test "01-update: unattended-upgrades is installed" {
    dpkg -s unattended-upgrades | grep -q "Status: install ok installed"
}

@test "01-update: script is idempotent" {
    bash scripts/base/01-update.bash
    bash scripts/base/01-update.bash
}

@test "01-update: script uses strict mode" {
    # Verify set -euo pipefail is present in the script
    grep -q "set -euo pipefail" scripts/base/01-update.bash
}
