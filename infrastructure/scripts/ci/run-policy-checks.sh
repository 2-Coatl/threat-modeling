#!/usr/bin/env bash
# infrastructure/scripts/ci/run-policy-checks.sh
# Aggregate policy and static analysis checks used in CI workflows.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

cd "$REPO_ROOT"

printf '[INFO] Running unicode policy scan...\n'
mapfile -t tracked_paths < <(git ls-files)
if [[ ${#tracked_paths[@]} -eq 0 ]]; then
    printf '[INFO] No tracked files discovered; skipping unicode scan.\n'
else
    python3 infrastructure/git/policy/check_disallowed_unicode.py --workspace "${tracked_paths[@]}"
fi

printf '[INFO] Running shell syntax checks...\n'
mapfile -t shell_files < <(git ls-files '*.sh' 'infrastructure/bootstrap.sh' 'infrastructure/bin/*')
if [[ ${#shell_files[@]} -eq 0 ]]; then
    printf '[INFO] No shell scripts detected.\n'
else
    for file in "${shell_files[@]}"; do
        bash -n "$file"
    done
fi

printf '[INFO] Validating Vagrantfile syntax...\n'
if [[ -f "infrastructure/Vagrantfile" ]]; then
    ruby -c infrastructure/Vagrantfile >/dev/null
    printf '[SUCCESS] Vagrantfile syntax valid.\n'
else
    printf '[WARN] infrastructure/Vagrantfile not found; skipping Ruby syntax check.\n'
fi

printf '[INFO] Compiling Python modules...\n'
mapfile -t python_files < <(git ls-files '*.py')
if [[ ${#python_files[@]} -eq 0 ]]; then
    printf '[INFO] No Python modules detected.\n'
else
    python3 -m py_compile "${python_files[@]}"
fi

printf '[SUCCESS] Policy checks completed.\n'
