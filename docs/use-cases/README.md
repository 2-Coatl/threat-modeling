# Use Case Catalog

The `docs/use-cases/` directory centralizes the specifications that describen las
interacciones entre actores y el sistema de threat modeling. Cada documento debe
explicar **qué** hace observablemente la plataforma sin profundizar en el
diseño técnico ni en detalles de implementación.

## Conceptos clave

- **Caso de uso:** Documento textual que describe cómo un actor logra un objetivo
  concreto interactuando con el sistema. Sigue la regla de nombre `verbo +
  objeto` (p. ej. "Generar reporte").
- **Escenario (o flujo):** Historia particular dentro del caso de uso. Incluye el
  flujo principal (happy path) y variaciones alternativas o de excepción.
- **Actores:** Personas u otros sistemas que participan en el flujo. Los actores
  principales disparan el caso de uso; los secundarios brindan soporte.

> 💡 **Principio rector:** los casos de uso describen comportamientos visibles
> para el actor. Cualquier aspecto técnico (por ejemplo endpoints, estructuras
> de datos o pseudocódigo) pertenece a otros artefactos.

## Estructura del directorio

- `README.md` (este archivo) — orientación general e inventario.
- `templates/` — plantillas para nuevos casos de uso.
- `UC-XXX-<slug>.md` — especificaciones activas.
- `archive/` — casos de uso fuera de alcance pero preservados para trazabilidad.
- `ui/` — catálogo específico de experiencias de interfaz.

## Convenciones al crear o actualizar casos de uso

1. **Usa la plantilla estándar.** Copia `templates/standard.md` y reemplaza cada
   campo. No elimines secciones; si no aplican, justifícalo con "No aplica".
2. **Describe interacciones, no APIs.** Cada paso debe indicar la acción del actor
   y la respuesta observable del sistema. Referencias técnicas viven en anexos o
   documentación de desarrollo.
3. **Declara actores en mayúsculas.** Diferencia claramente entre actores
   primarios y secundarios.
4. **Incluye pre y postcondiciones.** Explica el estado esperado antes y después
   del flujo principal.
5. **Registra cursos alternos.** Para cada condición detectable, especifica cómo
   cambia la interacción desde la perspectiva del actor.
6. **Documenta referencias y trazabilidad.** Completa la sección 9 para enlazar
   casos de uso relacionados, diagramas o artefactos complementarios.
7. **Versiona los documentos.** Actualiza la sección de metadatos con la fecha y
   versión cuando cambien reglas o comportamientos.

## Inventario vigente

| Código       | Nombre                                           | Versión | Última actualización |
|--------------|--------------------------------------------------|---------|----------------------|
| UC-API-000   | Operar el flujo de modelado con PlantUML y pytm   | 1.1     | 2025-10-27           |
| UC-API-001   | Generar diagramas versionados                     | 1.1     | 2025-10-27           |
| UC-API-002   | Previsualizar diagrama sin historial              | 1.1     | 2025-10-27           |
| UC-API-003   | Consultar historial y versiones de diagramas      | 1.1     | 2025-10-27           |
| UC-API-004   | Restaurar una versión previa del diagrama         | 1.1     | 2025-10-27           |
| UC-API-005   | Renderizar modelos pytm con Plantweb              | 1.1     | 2025-10-27           |
| UC-API-006   | Generar artefactos con PlantUML                   | 1.1     | 2025-10-27           |
| UC-API-007   | Analizar amenazas con pytm y generar reporte      | 1.1     | 2025-10-27           |
| UC-API-008   | Gestionar correcciones con historial y rollback   | 1.1     | 2025-10-27           |
| UC-API-009   | Presentar hallazgos y artefactos del análisis     | 1.1     | 2025-10-27           |

## Archived use cases

Los casos de uso que pertenecen a plataformas heredadas se trasladan al
subdirectorio `archive/` para mantener la trazabilidad sin mezclarlos con el
alcance vigente de la plataforma.

| Código  | Nombre                       | Motivo de archivo                 |
|---------|------------------------------|-----------------------------------|
| UC-011  | Gestionar permisos por rol   | Caso de uso de IACT (fuera scope) |

## UI use cases and API mapping

La UI comparte el mismo identificador base `UC-UI-XXX` y se documenta bajo
`docs/use-cases/ui/`. Cada flujo indica explícitamente qué endpoints de la API
lo soportan para asegurar la trazabilidad end to end.

| Código UI   | Nombre                                         | Casos de uso API asociados                                | Estado |
|-------------|------------------------------------------------|-----------------------------------------------------------|--------|
| UC-UI-001   | Gestionar diagramas y versiones                | UC-API-000, UC-API-001, UC-API-002, UC-API-003, UC-API-004, UC-API-008 | Diseño detallado documentado |
| UC-UI-002   | Ejecutar análisis y generar artefactos         | UC-API-005, UC-API-006, UC-API-007                        | Diseño detallado documentado |
| UC-UI-003   | Visualizar hallazgos y compartir resultados    | UC-API-009                                              | Diseño detallado documentado |

Consulta `docs/use-cases/ui/README.md` para obtener el detalle de cada flujo.

