# API Use Case Catalog

Los casos de uso de API documentan los comportamientos observables que la
plataforma expone mediante endpoints y procesos automatizados. Cada documento
se centra en cómo los actores consumen las capacidades del backend y qué
resultados verificables obtienen, manteniendo la narrativa descrita en la
plantilla estándar.

## Inventario actual

| Código API | Nombre                                         | Versión | Última actualización | Descripción breve                                               | Estado  |
|------------|------------------------------------------------|---------|----------------------|-----------------------------------------------------------------|---------|
| UC-API-000 | Operar el flujo de modelado con PlantUML y pytm | 1.1     | 2025-10-27           | El ORQUESTADOR coordina diagramas, análisis y sincronización    | Vigente |
| UC-API-001 | Generar diagramas versionados                   | 1.1     | 2025-10-27           | El AUTOR FUNCIONAL solicita nuevas versiones persistentes       | Vigente |
| UC-API-002 | Previsualizar diagrama sin historial            | 1.1     | 2025-10-27           | El AUTOR FUNCIONAL consulta un render temporal                  | Vigente |
| UC-API-003 | Consultar historial y versiones de diagramas    | 1.1     | 2025-10-27           | El AUTOR FUNCIONAL revisa cambios y recupera metadatos          | Vigente |
| UC-API-004 | Restaurar una versión previa del diagrama       | 1.1     | 2025-10-27           | El AUTOR FUNCIONAL restaura diagramas previos mediante la API   | Vigente |
| UC-API-005 | Renderizar modelos pytm con Plantweb            | 1.1     | 2025-10-27           | El ORQUESTADOR invoca la renderización de componentes pytm      | Vigente |
| UC-API-006 | Generar artefactos con PlantUML                 | 1.1     | 2025-10-27           | El ORQUESTADOR produce archivos UML descargables                | Vigente |
| UC-API-007 | Analizar amenazas con pytm y generar reporte    | 1.1     | 2025-10-27           | El ORQUESTADOR corre pytm y agrega resultados                   | Vigente |
| UC-API-008 | Gestionar correcciones con historial y rollback | 1.1     | 2025-10-27           | El AUTOR FUNCIONAL coordina cambios y seguimiento               | Vigente |
| UC-API-009 | Presentar hallazgos y artefactos del análisis   | 1.1     | 2025-10-27           | El ORQUESTADOR publica resultados para consulta                 | Vigente |

## Próximas tareas de documentación

| ID       | Tarea                                                                                                                   | Responsable sugerido  | Prioridad | Vínculo                        |
|----------|-------------------------------------------------------------------------------------------------------------------------|-----------------------|-----------|-------------------------------|
| TD-API-01 | Incorporar referencias a endpoints concretos en cada sección 9 para reforzar la trazabilidad con la especificación técnica. | Equipo de arquitectura | Alta      | `docs/api` (pendiente de creación) |
| TD-API-02 | Actualizar las fechas y versiones a la 1.2 cuando se libere la automatización de Plantweb.                             | PO plataforma         | Media     | UC-API-005, UC-API-006        |
| TD-API-03 | Documentar escenarios de error extendidos para los flujos de rollback descritos en UC-API-008.                         | Equipo de QA          | Media     | UC-API-008                    |
| TD-API-04 | Agregar mockups o diagramas de secuencia como artefactos complementarios referenciados desde UC-API-009.               | UX y documentación    | Baja      | UC-API-009                    |


Cada documento sigue `templates/standard.md`, define actores en mayúsculas y
mantiene trazabilidad hacia referencias técnicas desde la sección 9. Las tareas
listadas aquí deben reflejarse también en la sección 10 de cada caso de uso
para conservar el historial de mantenimiento.
