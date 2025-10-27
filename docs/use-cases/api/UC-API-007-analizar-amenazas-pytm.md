# UC-API-007: Ejecutar análisis de amenazas

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-007
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-007|
|**Nombre**|Ejecutar análisis de amenazas|
|**Actor primario**|ORQUESTADOR DE MODELOS|
|**Actores de soporte**|SERVICIO PYTM, BASE DE DATOS|
|**Frecuencia estimada**|Media|
|**Prioridad**|Alta — provee insumos críticos de seguridad|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Procesar el código pytm del modelo para identificar amenazas, clasificarlas y almacenarlas para revisión.
- **Resultado esperado:** La API devuelve un resumen por severidad y registra los hallazgos detallados en base de datos.
- **Alcance incluye:**
  - ✅ Ejecutar pytm con plantillas y archivos de amenazas por defecto o personalizados.
  - ✅ Parsear el reporte generado a estructura de datos normalizada.
  - ✅ Persistir hallazgos, actualizando estados previos y auditando el evento.
- **Fuera de alcance:**
  - ❌ Aprobar o rechazar mitigaciones (cubierto en UC-API-009).
  - ❌ Generar reportes en PDF (cubierto en UC-API-009).

---

## 3. PRECONDICIONES

- Existe un modelo válido con código pytm sincronizado.
- El servicio pytm está accesible y con permisos para ejecutar scripts.
- Hay espacio disponible en la tabla `threat_findings`.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|ORQUESTADOR DE MODELOS|Envía `POST /api/models/{model_id}/analyze-threats` con parámetros opcionales (`threatsFile`, `template`).| 
|2|API|Recupera el código Python del modelo y determina archivos de amenazas y plantilla a usar.| 
|3|API|Ejecuta pytm con `--report` y obtiene salida en Markdown.| 
|4|API|Parsea el Markdown para identificar hallazgos (id, severidad, elemento, descripción, mitigaciones).| 
|5|API|Inicia transacción: elimina hallazgos anteriores del modelo e inserta los nuevos con estado `open`.| 
|6|API|Calcula métricas de severidad (conteos por nivel) y registra evento `threats_analyzed`.| 
|7|API|Responde `200 OK` con total de hallazgos, resumen por severidad y listado completo.| 
|8|ORQUESTADOR DE MODELOS|Actualiza la UI de hallazgos con la información recibida.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Se proporciona archivo de amenazas personalizado|La API utiliza el archivo provisto y marca el resultado como "custom".| 
|FA-02|Se solicita solo resumen (`?summary=true`)|La API ejecuta pytm, calcula métricas y omite devolver la lista completa de hallazgos.| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|pytm finaliza con error|La API responde `500 Internal Server Error` con log y no altera hallazgos previos.| 
|FE-02|No se detectan hallazgos|La API responde `200 OK` con totales en cero y registro `threats_analyzed` indicando "sin hallazgos".| 
|FE-03|Falla la transacción al insertar hallazgos|La API revierte cambios y responde `500 Internal Server Error`.| 

---

## 7. POSTCONDICIONES

- **Éxito:** Los hallazgos quedan almacenados y disponibles para revisión y cambio de estado.
- **Fallo:** Se conserva el estado anterior y se registra el incidente.

---

## 8. REQUISITOS ESPECIALES

- Guardar las métricas de tiempos de ejecución (`execution_ms`) para cada análisis.
- Etiquetar hallazgos con `source` (default/custom) para identificar su procedencia.
- Registrar en auditoría el usuario que solicitó el análisis.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-002, UC-UI-003, UC-API-009, UC-API-011, UC-API-012.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Integrar con sistema de colas en futuras versiones para análisis asíncronos.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-007-01|Agregar ejemplos de respuesta con archivos personalizados en la documentación.|Pendiente|Documentación|
|TD-API-007-02|Definir SLA del análisis y documentarlo en el runbook.|En curso|Operaciones|
