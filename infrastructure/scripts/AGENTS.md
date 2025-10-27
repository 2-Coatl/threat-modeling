# Instrucciones para `infrastructure/scripts/`

- Mantén los scripts en Bash compatibles con `set -euo pipefail` y sin depender
  de rutas relativas distintas a las calculadas mediante `SCRIPT_DIR`.
- Cuando el `commit-msg` hook cambie, actualiza simultáneamente
  `test-commit-hooks.sh` para reflejar los casos válidos e inválidos y asegúrate
  de que lo invoquen los flujos de CI pertinentes (`ci/run-policy-checks.sh`).
- Incluye mensajes de registro consistentes que inicien con `[INFO]`, `[WARN]`,
  `[ERROR]` o `[SUCCESS]` según corresponda.
