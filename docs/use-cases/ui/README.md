# UI Use Case Catalog

Los casos de uso de la interfaz gráfica describen cómo los equipos interactúan
con la experiencia web para operar la plataforma de threat modeling. Se
numeran con el prefijo `UC-UI-XXX` y mantienen una relación explícita con los
endpoints cubiertos por los casos de uso de la API.

## Inventario actual

| Código UI   | Nombre                                      | Descripción breve                                           | Casos de uso API asociados                                | Estado |
|-------------|---------------------------------------------|-------------------------------------------------------------|-----------------------------------------------------------|--------|
| UC-UI-001   | Gestionar diagramas y versiones             | Flujo completo del editor para crear, revisar y restaurar   | UC-API-000, UC-API-001, UC-API-002, UC-API-003, UC-API-004, UC-API-008 | Diseño detallado documentado |
| UC-UI-002   | Ejecutar análisis y generar artefactos      | Lanza análisis pytm, renderiza y distribuye artefactos      | UC-API-005, UC-API-006, UC-API-007                        | Diseño detallado documentado |
| UC-UI-003   | Visualizar hallazgos y compartir resultados | Presenta reportes, destaca severidades y comparte enlaces   | UC-API-009                                              | Diseño detallado documentado |

Cada documento UI sigue la plantilla estándar y referencia los componentes
React involucrados (`ui/src/pages/`, `ui/src/modules/`, `ui/src/state/`).
