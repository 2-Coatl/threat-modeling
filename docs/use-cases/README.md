# Use Case Catalog

The `docs/use-cases/` directory centralizes the operational scenarios that describe
how teams interact with the threat-modeling platform. Each entry follows a
standardized format so stakeholders can quickly understand the context,
prerequisites, expected flows, and auditing requirements.

## Structure

- `README.md` (this file) — overview and navigation.
- `templates/` — reusable Markdown scaffolding for new use cases.
- `UC-XXX-<slug>.md` — individual, versioned use case descriptions.

## How to add a new use case

1. Copy the template from `templates/standard.md` into a new file that follows the
   naming convention `UC-<id>-<short-title>.md`.
2. Fill in every section with project-specific information. Keep the section order
   intact to maintain consistency across the catalog.
3. Cross-reference related documents (requirements, standards, scripts) when
   relevant so readers can trace responsibilities end to end.
4. Submit the change through the normal review process.

## Current inventory

| Código       | Nombre                                           | Versión | Última actualización |
|--------------|--------------------------------------------------|---------|----------------------|
| UC-011       | Gestionar permisos por rol                        | 1.0     | 2025-10-19           |
| UC-API-000   | Operar el flujo de modelado con PlantUML y pytm   | 1.0     | 2025-10-26           |
| UC-API-001   | Generar diagramas versionados                     | 1.1     | 2025-10-26           |
| UC-API-002   | Previsualizar diagrama sin historial              | 1.1     | 2025-10-26           |
| UC-API-003   | Consultar historial y versiones de diagramas      | 1.1     | 2025-10-26           |
| UC-API-004   | Restaurar una versión previa del diagrama         | 1.1     | 2025-10-26           |
| UC-API-005   | Renderizar modelos pytm con Plantweb              | 1.0     | 2025-10-26           |
| UC-API-006   | Generar artefactos con PlantUML                   | 1.0     | 2025-10-26           |
| UC-API-007   | Analizar amenazas con pytm y generar reporte      | 1.0     | 2025-10-26           |
| UC-API-008   | Gestionar correcciones con historial y rollback   | 1.0     | 2025-10-26           |
| UC-API-009   | Presentar hallazgos y artefactos del análisis     | 1.0     | 2025-10-26           |

