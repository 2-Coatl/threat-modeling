# Threat Modeling Engineering Ruleset

This ruleset consolidates the conventions that guide our monolithic-but-modular
stack.  It adapts our legacy standards to the technologies we use today:
Bash-based automation, Python (Flask + PyTM), PlantUML generation, and the
React/SCSS/Webpack UI.  Treat this as a living document – prefer
pragmatism and clarity over dogmatism.

## 1. Core Principles

1. **Language conventions first.**  Follow PEP 8 for Python, Bash best
   practices (POSIX + Bashism awareness), and the official React/TypeScript
   style guides before applying personal preferences.
2. **Single responsibility.**  Each script, module, or component should do one
   thing well.  Reuse helpers from `infrastructure/utils` or create a new helper
   rather than overloading an existing file.
3. **Clarity over cleverness.**  Prefer descriptive names and explicit control
   flow.  Optimize only after measuring.
4. **Monolith, modularized.**  Keep backend, UI, and infrastructure in
   this repository, but respect clear boundaries between modules.

## 2. Repository Structure Expectations

```
/                    # Monorepo root
├── infrastructure/  # Shared shell utilities, policy tooling, system assets
│   ├── bootstrap.sh # Provisioning orchestrator (Bash)
│   ├── bin/         # CLI wrappers for installers and generators
│   ├── config/      # Environment defaults and template variables
│   ├── scripts/     # Installation, setup, test, and CI helpers (Bash)
│   └── utils/       # Shared shell helpers sourced by installers
├── config/          # Global variables, shell profiles, templates
├── dashboard/       # Python Flask + PyTM application (monolith core)
│   ├── plantweb/    # PlantUML helpers and CLI
│   ├── templates/   # Flask Jinja templates
│   ├── static/
│   │   ├── js/      # React bundles (Webpack output)
│   │   └── css/     # Compiled SCSS
│   └── models/      # Threat modeling domain modules
└── frontend/        # Source for React + SCSS (Webpack build input)
    ├── src/
    │   ├── components/
    │   ├── hooks/
    │   ├── pages/
    │   └── styles/
    └── webpack/    # Build configuration and tooling
```

*Create `frontend/` directories as needed when the web client evolves.  Backend
Flask blueprints live inside `dashboard/` and should expose narrow interfaces to
frontend bundles via REST endpoints.*

## 3. Naming Conventions

| Layer            | Convention                                         |
|------------------|-----------------------------------------------------|
| Bash scripts     | `snake_case.sh`; functions use `snake_case`         |
| Python modules   | `snake_case.py`; functions & variables `snake_case` |
| Python classes   | `PascalCase`                                        |
| React components | `PascalCase.tsx` or `.jsx`; hooks `useCamelCase.ts` |
| SCSS             | `kebab-case.scss`; variables use `$kebab-case`       |
| Webpack configs  | `webpack.<target>.config.js`                        |
| PlantUML files   | `snake_case.puml`                                   |

Additional rules:

- Prefix private helpers with `_` in Python and `__` in SCSS (BEM modifiers).
- Constants use `UPPER_SNAKE_CASE` in Python/TypeScript and `readonly` exports
  when possible.
- Test modules mirror the file under test (`test_dashboard_api.py`,
  `App.spec.tsx`).

## 4. Layering Rules

1. **Presentation (React/Flask routes)** must depend only on application
   services defined in `dashboard/services/` or feature modules.  They never
   perform direct infrastructure work.
2. **Domain/Business logic** (`dashboard/models/`, `dashboard/services/`) should
   be framework-agnostic.  PlantUML or PyTM orchestration belongs here when it
   represents business rules.
3. **Infrastructure utilities** (shell installers, adapters, file IO) remain in
   `infrastructure/` (CLI wrappers under `infrastructure/bin/`, workflows under
   `infrastructure/scripts/`).  Python infrastructure adapters belong in
   `api/integrations/`.
4. **UI layer** consumes REST/JSON endpoints.  Shared DTOs live in
   `api/schema.py` and `ui/src/types/`.

## 5. Bash Standards

- Always start scripts with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Source `infrastructure/config/variables.sh` when global paths or user settings
  are needed.
- Avoid silent failures: validate inputs, exit with non-zero codes, and use
  `[INFO]/[WARN]/[ERROR]/[SUCCESS]` prefixes.
- Keep functions <= 40 lines.  Extract helpers to `infrastructure/utils/*.sh`
  when logic repeats across scripts.
- Parameterize commands with variables instead of hard-coding (e.g., reuse
  `OCI_RUNTIME_*` variables).

## 6. Python (Flask + PyTM) Standards

- Follow PEP 8 and use type hints for all public functions.  Run `python3 -m
  py_compile` (covered by
  `infrastructure/scripts/ci/run-policy-checks.sh`).
- Flask blueprints reside in `api/`.  Each blueprint file defines a
  `create_blueprint()` factory.
- Business logic for threat modeling lives in `api/models/` or
  `api/services/`.  PyTM integration functions should avoid Flask imports
  to remain testable.
- Use Google-style docstrings for modules, classes, and functions that form the
  public API.
- Raise descriptive exceptions rather than returning sentinel values.  Handle
  errors at the boundary (Flask route) using blueprint error handlers.

## 7. PlantUML and Diagram Automation

- Store canonical `.puml` templates under `api/plantweb/templates/`.
- Generated diagrams belong under `api/output/diagrams/` and must not be
  tracked in Git.
- Use `infrastructure/scripts/test-plantweb.sh` when adding templates or CLI
  options.
- Keep PlantUML include paths relative to `api/plantweb/` to avoid
  hard-coded absolute directories.

## 8. React + SCSS + Webpack Standards

- Source files live in `ui/src/`.  Use functional components with hooks.
- Prefer atomic components (`components/`) assembled by feature pages
  (`pages/`).
- Styling follows BEM via SCSS modules (`Component.module.scss`).  Shared design
  tokens live in `ui/src/styles/tokens.scss`.
- Webpack configuration files reside in `ui/webpack/`.  Provide separate
  configs for development and production; share common options via
  `webpack.common.js`.
- Lint via `npm run lint` (wrap ESLint + Stylelint) and `npm run test` (Jest).
  Integrate these commands into shell wrappers when the ui is introduced.

## 9. Logging and Output Policy

- No emojis or decorative Unicode in any script output.  Rely on bracketed log
  levels (`[INFO]`, `[WARN]`, `[ERROR]`, `[SUCCESS]`).
- Use `infrastructure/utils/core.sh` logging helpers when possible.
- Summaries use ASCII separators only (`-----`, `=====`).

## 10. Git Hygiene

- Conventional Commits enforced by `.githooks/commit-msg`.
- Hooks live in `.githooks/`; run `infrastructure/bin/setup` once to configure
  `core.hooksPath`.
- Run `infrastructure/scripts/ci/run-policy-checks.sh` locally before opening
  PRs.
- Binary artifacts, generated diagrams, build outputs, and environment-specific
  files stay out of Git.  Update `.gitignore` if new tools are introduced.

## 11. Testing Expectations

| Layer          | Tooling / Command                                     |
|----------------|-------------------------------------------------------|
| Bash           | `bash -n`, targeted integration tests per script      |
| Python backend | `pytest` (to be added) + `infrastructure/scripts/ci/run-policy-checks.sh` |
| React ui | `npm run test -- --watch=false` (Jest)                |
| Styling        | `npm run lint:styles` (Stylelint)                     |
| Diagrams       | `infrastructure/scripts/test-plantweb.sh`             |

- Add tests before or alongside new functionality.
- Keep integration tests under `infrastructure/scripts/test-*` or `api/tests/`.

## 12. Pull Request Checklist

- [ ] Code follows naming and layering rules.
- [ ] New scripts source `infrastructure/config/variables.sh` when needed and
      log professionally.
- [ ] `infrastructure/scripts/ci/run-policy-checks.sh` passes locally.
- [ ] Tests added/updated for backend (`pytest`) and ui (`npm run test`).
- [ ] Documentation updates accompany structural or workflow changes.
- [ ] No secrets, generated diagrams, or build artifacts committed.

---

**Remember:** if reviewers cannot infer what a change does by reading the code,
rename or refactor until the intent is obvious.  Document the *why*, not the
*what*, in comments and commit messages.
