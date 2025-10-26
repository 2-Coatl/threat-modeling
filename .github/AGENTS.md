# Agent Instructions for `.github/`

This guidance applies to automation assets stored under `.github/`, including
workflows, reusable actions, rulesets, and configuration metadata.

- Keep workflow and configuration changes minimal and well-commented so they can
  be audited quickly.
- Prefer declarative GitHub Actions syntax; avoid embedding large shell scripts
  inline when a dedicated script under `infrastructure/` or `scripts/` can be
  referenced instead.
- When updating rulesets or workflow triggers, document the rationale in the PR
  summary so repository maintainers understand the impact.
- Validate YAML files with `yamllint` or the GitHub Actions workflow parser when
  possible before committing changes.
- Remember that instructions in the repository root `AGENTS.md` still apply; use
  this file to capture only `.github/`-specific conventions.
