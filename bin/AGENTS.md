# Agent Instructions for `bin/`

> These rules build on the repository-wide guidance in `/AGENTS.md` and apply
> only to scripts within this directory.

- Shell entrypoints in this directory must be POSIX-compatible Bash scripts with
  a shebang of `#!/usr/bin/env bash` and `set -euo pipefail`.
- `bin/generate` is the canonical threat modeling entrypoint. Keep the full
  implementation here so that documentation references `/vagrant/bin/generate`
  remain correct. Any infrastructure-specific wrappers must simply delegate to
  this script.
- Wrapper scripts (for example `bin/setup`) should stay minimal—resolve the
  repository root using `${BASH_SOURCE[0]}` and `exec` the matching script under
  `infrastructure/bin/`.
- Use the logging helpers from `infrastructure/utils/core.sh` when writing new
  logic; prefer `[INFO]`, `[WARN]`, `[ERROR]`, `[SUCCESS]` messages.
- Validate changes with `bash -n bin/*` and include relevant checks (such as
  `infrastructure/scripts/ci/run-policy-checks.sh`) in testing notes.
