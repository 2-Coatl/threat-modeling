# API Use Case Catalog

Los casos de uso de API documentan los comportamientos observables que la
plataforma expone mediante endpoints y procesos automatizados. Cada documento
se centra en cómo los actores consumen las capacidades del backend y qué
resultados verificables obtienen, manteniendo la narrativa descrita en la
plantilla estándar.

## Inventario actual

| Código API | Nombre                               | Versión | Última actualización | Descripción breve                                                          | Estado  |
|------------|--------------------------------------|---------|----------------------|----------------------------------------------------------------------------|---------|
| UC-API-000 | Gestionar autenticación y tokens     | 1.0     | 2025-10-28           | El SERVICIO DE UI registra usuarios, autentica credenciales y valida JWT   | Vigente |
| UC-API-001 | Registrar modelos visuales           | 1.0     | 2025-10-28           | El SERVICIO DE UI crea modelos con visualización y código sincronizado     | Vigente |
| UC-API-002 | Listar modelos disponibles           | 1.0     | 2025-10-28           | El SERVICIO DE UI consulta modelos con filtros, permisos y paginación      | Vigente |
| UC-API-003 | Consultar detalles de modelo         | 1.0     | 2025-10-28           | El SERVICIO DE UI recupera representación completa para edición o revisión | Vigente |
| UC-API-004 | Actualizar modelos visuales          | 1.0     | 2025-10-28           | El SERVICIO DE UI sincroniza cambios visuales y commits en Git             | Vigente |
| UC-API-005 | Eliminar modelos                     | 1.0     | 2025-10-28           | El SERVICIO DE UI borra modelos y artefactos asociados de forma consistente | Vigente |
| UC-API-006 | Generar diagramas automáticos        | 1.0     | 2025-10-28           | El ORQUESTADOR DE MODELOS produce DFD y secuencias con cache inteligente   | Vigente |
| UC-API-007 | Ejecutar análisis de amenazas        | 1.0     | 2025-10-28           | El ORQUESTADOR DE MODELOS corre pytm y persiste hallazgos clasificados     | Vigente |
| UC-API-008 | Gestionar historial y versiones      | 1.0     | 2025-10-28           | El ORQUESTADOR DE MODELOS consulta, compara, restaura y ramifica commits   | Vigente |
| UC-API-009 | Facilitar colaboración y exportaciones | 1.0   | 2025-10-28           | El ORQUESTADOR DE MODELOS administra comentarios, compartidos y exportes   | Vigente |
| UC-API-010 | Validar código pytm                     | 1.0     | 2025-10-29           | El SERVICIO DE UI verifica sintaxis del script antes de guardar o exportar | Vigente |
| UC-API-011 | Actualizar estado de hallazgos          | 1.0     | 2025-10-29           | El ORQUESTADOR DE MODELOS marca amenazas como mitigadas, aceptadas o FP    | Vigente |
| UC-API-012 | Filtrar hallazgos registrados           | 1.0     | 2025-10-29           | El ORQUESTADOR DE MODELOS consulta hallazgos aplicando criterios dinámicos | Vigente |
| UC-API-013 | Consultar actividad del modelo          | 1.0     | 2025-10-29           | El ORQUESTADOR DE MODELOS recupera el feed auditado para la UI             | Vigente |
| UC-API-014 | Descargar diagramas generados           | 1.0     | 2025-10-29           | El ORQUESTADOR DE MODELOS entrega artefactos gráficos listos para descarga | Vigente |
| UC-API-015 | Importar modelos desde JSON             | 1.0     | 2025-10-29           | El SERVICIO DE UI carga un archivo y crea un modelo completo en la plataforma | Vigente |

## Próximas tareas de documentación

| ID        | Tarea                                                                                                   | Responsable sugerido      | Prioridad | Vínculo                     |
|-----------|---------------------------------------------------------------------------------------------------------|---------------------------|-----------|-----------------------------|
| TD-API-01 | Verificar que cada caso de uso actualice su sección 9 con enlaces a endpoints reales tras publicar la especificación. | Equipo de arquitectura   | Alta      | Todos los UC-API vigentes   |
| TD-API-02 | Definir lineamientos de retención y backups antes de habilitar eliminaciones masivas.                   | Operaciones               | Media     | UC-API-005                  |
| TD-API-03 | Documentar políticas de caché y métricas de rendimiento para la generación de diagramas.               | Equipo de plataforma      | Media     | UC-API-006                  |
| TD-API-04 | Incorporar guías de exportación filtrada y formatos soportados en el manual de usuarios.               | Producto y documentación  | Media     | UC-API-009                  |
| TD-API-05 | Sincronizar ejemplos de validación de código con los linters corporativos.                            | Equipo de plataforma      | Media     | UC-API-010                  |
| TD-API-06 | Documentar matriz de transición de estados para hallazgos y reglas de negocio asociadas.              | Seguridad                 | Alta      | UC-API-011, UC-API-012      |
| TD-API-07 | Definir retención del feed de actividad y políticas de anonimización antes de exponerlo externamente. | Operaciones               | Media     | UC-API-013                  |
| TD-API-08 | Incorporar ejemplos de descargas firmadas y controladas en la guía de integraciones.                  | Producto y documentación  | Media     | UC-API-014                  |
| TD-API-09 | Establecer checklist de validación para archivos importados y actualizar la guía paso a paso.         | Producto                  | Alta      | UC-API-015                  |

Cada documento sigue `templates/standard.md`, define actores en mayúsculas y
mantiene trazabilidad hacia referencias técnicas desde la sección 9. Las tareas
listadas aquí deben reflejarse también en la sección 10 de cada caso de uso
para conservar el historial de mantenimiento.
