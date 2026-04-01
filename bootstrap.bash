#!/usr/bin/env bash
# Orchestrates the full machine setup by running scripts in a defined order.
# Each entry in SCRIPTS can be a single file or a directory. Directories are
# expanded to all *.bash files sorted by name (numbered prefixes control order).
# After each script runs, the matching test file under tests/ is executed to
# verify the result.
#
# Usage: bash bootstrap.sh

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPTS=(
    scripts/base
)

log()  { echo "==> $1"; }
ok()   { echo " ✓  $1"; }
fail() { echo " ✗  $1"; exit 1; }

test_for() {
    echo "${1/scripts\//tests/}"
}

run_script() {
    local script="$1"

    log "Running ${script}..."
    bash "${REPO_DIR}/${script}"
}

verify_script() {
    local script="$1"
    local test_file
    test_file="$(test_for "${script}")"

    if [[ -f "${REPO_DIR}/${test_file}" ]]; then
        log "Verifying ${script}..."
        bash "${REPO_DIR}/${test_file}"
        ok "${script}"
    else
        ok "${script} (no test)"
    fi
}

collect_scripts() {
    local entry="$1"

    if [[ -d "${REPO_DIR}/${entry}" ]]; then
        for file in "${REPO_DIR}/${entry}"/*.bash; do
            [[ -f "${file}" ]] && echo "${entry}/$(basename "${file}")"
        done
    elif [[ -f "${REPO_DIR}/${entry}" ]]; then
        echo "${entry}"
    else
        fail "Not found: ${entry}"
    fi
}

log "Starting bootstrap..."

for entry in "${SCRIPTS[@]}"; do
    while IFS= read -r script; do
        echo ""
        echo "──────────────────────────────────────"
        run_script "${script}"
        verify_script "${script}"
        echo "──────────────────────────────────────"
    done < <(collect_scripts "${entry}")
done

echo ""
echo "══════════════════════════════════════"
log "Bootstrap complete."
echo "══════════════════════════════════════"
