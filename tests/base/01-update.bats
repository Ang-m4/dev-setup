#!/usr/bin/env bats
# Tests for scripts/base/01-update.bash

setup() {
    export DOTFILES_ENV=test
}

@test "01-update: script uses strict mode" {
    grep -q "set -euo pipefail" scripts/base/01-update.bash
}

@test "01-update: script runs successfully in test mode" {
    bash scripts/base/01-update.bash
}

@test "01-update: skips update and upgrade in test mode" {
    run bash scripts/base/01-update.bash
    [[ "$output" == *"skipping system update and upgrade"* ]]
}

@test "01-update: uses dry-run for unattended-upgrades in test mode" {
    run bash scripts/base/01-update.bash
    [[ "$output" == *"Dry-run"* ]]
}
