#!/usr/bin/env bats
# Tests for scripts/base/03-locale-timezone.bash

setup() {
    export DOTFILES_ENV=test
    export LOCALE="en_US.UTF-8"
    export TIMEZONE="America/New_York"
}

@test "03-locale-timezone: script uses strict mode" {
    grep -q "set -euo pipefail" scripts/base/03-locale-timezone.bash
}

@test "03-locale-timezone: script runs successfully in test mode" {
    bash scripts/base/03-locale-timezone.bash
}

@test "03-locale-timezone: fails if LOCALE is not set" {
    unset LOCALE
    run bash scripts/base/03-locale-timezone.bash
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"LOCALE"* ]]
}

@test "03-locale-timezone: fails if TIMEZONE is not set" {
    unset TIMEZONE
    run bash scripts/base/03-locale-timezone.bash
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"TIMEZONE"* ]]
}

@test "03-locale-timezone: validates timezone exists in zoneinfo" {
    export TIMEZONE="Invalid/Nowhere"
    run bash scripts/base/03-locale-timezone.bash
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"Invalid timezone"* ]]
}

@test "03-locale-timezone: dry-run locale install in test mode" {
    run bash scripts/base/03-locale-timezone.bash
    [[ "$output" == *"Dry-run"* ]] || [[ "$output" == *"dry-run"* ]] || [[ "$output" == *"locales"* ]]
}

@test "03-locale-timezone: dry-run timezone symlink in test mode" {
    run bash scripts/base/03-locale-timezone.bash
    [[ "$output" == *"Dry-run: /etc/localtime -> /usr/share/zoneinfo/${TIMEZONE}"* ]]
}
