#!/usr/bin/env bash
# infrastructure/scripts/test-commit-hooks.sh
# Validate the commit-msg hook accepts valid Conventional Commit examples
# and rejects invalid ones.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
HOOK_PATH="${REPO_ROOT}/.githooks/commit-msg"

if [[ ! -x "$HOOK_PATH" ]]; then
    printf '[ERROR] commit-msg hook not found or not executable at %s\n' "$HOOK_PATH" >&2
    exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

run_hook_expect() {
    local expectation="$1"
    local message="$2"
    local commit_msg_file="$TMP_DIR/message.txt"

    printf '%s\n' "$message" > "$commit_msg_file"

    if output=$("$HOOK_PATH" "$commit_msg_file" 2>&1); then
        if [[ "$expectation" == "fail" ]]; then
            printf '[ERROR] Hook unexpectedly accepted: %s\n' "$message" >&2
            exit 1
        fi
    else
        if [[ "$expectation" == "pass" ]]; then
            printf '[ERROR] Hook unexpectedly rejected: %s\n' "$message" >&2
            printf '%s\n' "$output" >&2
            exit 1
        fi
    fi

    return 0
}

printf '[INFO] Checking commit-msg hook with valid examples...\n'
valid_messages=(
    'feat: add threat modeling helper'
    'build(deploy-pipeline): include canary stage'
    'ci(release): enforce version tagging'
    'docs(API-Gateway): document authentication flow'
    'fix(api/v2-router): handle nil payloads'
    'perf: optimize caching layer'
    'refactor(core-service): extract validation logic'
    'revert: revert "feat: add threat modeling helper"'
    'style(ui-theme): standardize spacing'
    'test: add regression coverage for tm parser'
)

for message in "${valid_messages[@]}"; do
    run_hook_expect "pass" "$message"
    printf '  [OK] %s\n' "$message"
done

printf '[INFO] Checking commit-msg hook with invalid examples...\n'
invalid_messages=(
    'feature: add new module'
    'fix missing colon'
    'docs(scope with space): invalid scope format'
    'feat(Scope!): disallow punctuation in scope'
)

for message in "${invalid_messages[@]}"; do
    run_hook_expect "fail" "$message"
    printf '  [OK] Rejected %s\n' "$message"
done

printf '[SUCCESS] commit-msg hook validation completed.\n'
