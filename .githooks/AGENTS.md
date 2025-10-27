# Instrucciones para `.githooks/`

- Al modificar `commit-msg`, mantén sincronizados los tipos admitidos con la
  documentación del repositorio (`README.md`) y con las pruebas automáticas en
  `infrastructure/scripts/test-commit-hooks.sh`.
- Cubre cualquier nuevo comportamiento del hook con casos positivos y negativos
  en el script de pruebas anterior.
- Ejecuta `infrastructure/scripts/test-commit-hooks.sh` antes de crear el PR
  para asegurar que el gancho funciona como se espera.
