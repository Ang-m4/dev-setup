#!/usr/bin/env bats
# Tests for scripts/base/02-packages.bash

setup() {
    export DOTFILES_ENV=test
}

@test "02-packages: script uses strict mode" {
    grep -q "set -euo pipefail" scripts/base/02-packages.bash
}

@test "02-packages: all packages are available via dry-run" {
    bash scripts/base/02-packages.bash
}

@test "02-packages: script fails if packages.txt is missing" {
    run bash -c 'DOTFILES_ENV=test PACKAGES_FILE=/nonexistent/packages.txt bash scripts/base/02-packages.bash'
    [[ "$status" -ne 0 ]]
}

@test "02-packages: comments and blank lines are filtered from packages.txt" {
    run bash scripts/base/02-packages.bash
    run ! grep -q "^#" <<< "$output"
}

@test "02-packages: uses dry-run in test mode" {
    run bash scripts/base/02-packages.bash
    [[ "$output" == *"Dry-run"* ]]
}
