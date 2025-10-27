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
- `api/` — catálogo de interacciones expuestas por la plataforma (casos `UC-API-XXX`).
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
7. **Gestiona tareas de documentación.** Usa la sección 10 de la plantilla para
   registrar acciones pendientes y sincronizarlas con los catálogos (`api/`,
   `ui/`, etc.).
8. **Versiona los documentos.** Actualiza la sección de metadatos con la fecha y
   versión cuando cambien reglas o comportamientos.

## Inventario vigente

Para obtener el inventario actualizado de casos de uso de API consulta el
catálogo dedicado en `docs/use-cases/api/README.md`. El inventario de casos de
uso de UI y su mapeo con la API permanece en `docs/use-cases/ui/README.md`.
El seguimiento de tareas pendientes de documentación para la API se registra en
la sección "Próximas tareas de documentación" del mismo catálogo.

## Archived use cases

Los casos de uso que pertenecen a plataformas heredadas se trasladan al
subdirectorio `archive/` para mantener la trazabilidad sin mezclarlos con el
alcance vigente de la plataforma.

Consulta `docs/use-cases/api/README.md` para conocer los detalles y estados de
cada especificación activa expuesta por la API.

| Código  | Nombre                       | Motivo de archivo                 |
|---------|------------------------------|-----------------------------------|
| UC-011  | Gestionar permisos por rol   | Caso de uso de IACT (fuera scope) |

## UI use cases and API mapping

La UI comparte el mismo identificador base `UC-UI-XXX` y se documenta bajo
`docs/use-cases/ui/`. Cada flujo indica explícitamente qué endpoints de la API
lo soportan para asegurar la trazabilidad end to end.

| Código UI   | Nombre                                     | Casos de uso API asociados                                                            | Estado |
|-------------|--------------------------------------------|---------------------------------------------------------------------------------------|--------|
| UC-UI-001   | Diseñar modelos visuales                   | UC-API-001, UC-API-003, UC-API-004, UC-API-008, UC-API-010, UC-API-015               | Diseño detallado documentado |
| UC-UI-002   | Generar artefactos analíticos              | UC-API-006, UC-API-007, UC-API-009, UC-API-010, UC-API-014                           | Diseño detallado documentado |
| UC-UI-003   | Compartir hallazgos con el equipo          | UC-API-003, UC-API-007, UC-API-009, UC-API-011, UC-API-012, UC-API-013, UC-API-014   | Diseño detallado documentado |
| UC-UI-004   | Autenticar acceso a la plataforma          | UC-API-000                                                                         | Diseño detallado documentado |
| UC-UI-005   | Administrar versiones desde la UI          | UC-API-004, UC-API-008, UC-API-013                                                 | Diseño detallado documentado |
| UC-UI-006   | Orquestar revisión de arquitectura         | UC-API-006, UC-API-007, UC-API-013, UC-API-014, UC-API-015                          | Diseño detallado documentado |

El desglose técnico del editor visual y su integración con pytm está documentado en [`docs/architecture/visual-editor.md`](../architecture/visual-editor.md), referencia obligatoria para mantener la trazabilidad entre comportamiento descrito y componentes implementados.

Consulta `docs/use-cases/ui/README.md` para obtener el detalle de cada flujo.

