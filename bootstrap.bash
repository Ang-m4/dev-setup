#!/usr/bin/env bash
# Orchestrates the full machine setup by running scripts in a defined order.
# Each entry in SCRIPTS can be a single file or a directory. Directories are
# expanded to all *.bash files sorted by name (numbered prefixes control order).
# After each script runs, the matching test file under tests/ is executed to
# verify the result.
#
# Usage: bash bootstrap.bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPTS=(
    scripts/base
)

PASS=0
FAIL=0
RESULTS=()

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
DIM='\033[2m'
RESET='\033[0m'

header()  { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════${RESET}\n${BOLD}  $1${RESET}\n${BOLD}${CYAN}══════════════════════════════════════${RESET}\n"; }
section() { echo -e "\n${CYAN}┌──${RESET} ${BOLD}$1${RESET}"; }
ok()      { echo -e "${CYAN}│${RESET} ${GREEN}✓${RESET} $1"; }
err()     { echo -e "${CYAN}│${RESET} ${RED}✗${RESET} $1"; }
end_ok()  { echo -e "${CYAN}└──${RESET} ${GREEN}done${RESET}"; }
end_err() { echo -e "${CYAN}└──${RESET} ${RED}failed${RESET}"; }

colorize_output() {
    while IFS= read -r line; do
        if [[ "${line}" == "==>"* ]]; then
            echo -e "${CYAN}│${RESET}   ${BOLD}${line}${RESET}"
        else
            echo -e "${CYAN}│${RESET}   ${DIM}${line}${RESET}"
        fi
    done
}

test_for() {
    echo "${1/scripts\//tests/}"
}

run_script() {
    local script="$1"

    section "${script}"
    bash "${REPO_DIR}/${script}" 2>&1 | colorize_output || true
}

verify_script() {
    local script="$1"
    local test_file
    test_file="$(test_for "${script}")"

    if [[ -f "${REPO_DIR}/${test_file}" ]]; then
        echo -e "${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET} ${BOLD}Verifying...${RESET}"
        if bash "${REPO_DIR}/${test_file}" 2>&1 | colorize_output; then
            ok "verified"
            RESULTS+=("${GREEN}  ✓ ${script}${RESET}")
            (( ++PASS ))
            end_ok
        else
            err "verification failed"
            RESULTS+=("${RED}  ✗ ${script}${RESET}")
            (( ++FAIL ))
            end_err
            return 1
        fi
    else
        ok "no test"
        RESULTS+=("${GREEN}  ✓ ${script} ${DIM}(no test)${RESET}")
        (( ++PASS ))
        end_ok
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
        err "Not found: ${entry}"
        exit 1
    fi
}

header "Dev Setup Bootstrap"

for entry in "${SCRIPTS[@]}"; do
    while IFS= read -r script; do
        run_script "${script}"
        verify_script "${script}"
    done < <(collect_scripts "${entry}")
done

echo ""
echo -e "${BOLD}${CYAN}══════════════════════════════════════${RESET}"
echo -e "${BOLD}  Summary${RESET}"
echo -e "${CYAN}──────────────────────────────────────${RESET}"
for result in "${RESULTS[@]}"; do
    echo -e "${result}"
done
echo -e "${CYAN}──────────────────────────────────────${RESET}"
echo -e "  ${GREEN}${PASS} passed${RESET}  ${RED}${FAIL} failed${RESET}"
echo -e "${BOLD}${CYAN}══════════════════════════════════════${RESET}"

[[ "${FAIL}" -eq 0 ]]
