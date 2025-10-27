# UC-API-012: Filtrar hallazgos registrados

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-012
**Versión:** 1.0
**Fecha:** 2025-10-29

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-012|
|**Nombre**|Filtrar hallazgos registrados|
|**Actor primario**|ORQUESTADOR DE MODELOS|
|**Actores de soporte**|BASE DE DATOS|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Media — agiliza revisión focalizada de resultados

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la UI recupere hallazgos aplicando filtros de severidad, estado y elemento afectado para priorizar el trabajo del equipo.
- **Resultado esperado:** La API entrega una lista paginada que respeta los filtros solicitados y conserva el orden establecido.
- **Alcance incluye:**
  - ✅ Procesar filtros de severidad, estado, elemento y texto libre.
  - ✅ Paginación y ordenamiento configurables por la UI.
  - ✅ Indicadores de totales por severidad para actualizar dashboards.
- **Fuera de alcance:**
  - ❌ Modificar estados de hallazgos (cubre UC-API-011).
  - ❌ Exportar resultados a PDF/JSON (cubre UC-API-009).

---

## 3. PRECONDICIONES

- El modelo cuenta con hallazgos almacenados (UC-API-007).
- El usuario autenticado posee permisos de lectura sobre el modelo.
- Existen índices en las columnas `severity`, `status`, `element_name` para optimizar consultas.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|ORQUESTADOR DE MODELOS|Envía `GET /api/models/{model_id}/threats` con parámetros `severity`, `status`, `element_name`, `page`, `limit`.|
|2|API|Valida y normaliza parámetros, estableciendo límites máximos y valores por defecto.|
|3|API|Construye consulta SQL con filtros solicitados y ordenamiento por severidad descendente y fecha reciente.|
|4|API|Ejecuta consulta paginada y recupera total de hallazgos que cumplen la condición.|
|5|API|Responde `200 OK` con lista de hallazgos, metadatos de paginación y agregados por severidad.|
|6|ORQUESTADOR DE MODELOS|Actualiza la vista filtrada en la UI y muestra los totales en tarjetas de resumen.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Se solicita `element_name` vacío|La API ignora el filtro de elemento y aplica solo severidad y estado.|
|FA-02|El cliente envía `sort=created_at`|La API ordena por fecha ascendente o descendente según `sortOrder`.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El modelo no existe o no pertenece al usuario|La API responde `404 Not Found` o `403 Forbidden` según corresponda.|
|FE-02|Se excede el límite máximo de `limit` (p. ej. >200)|La API responde `400 Bad Request` indicando el máximo permitido.|
|FE-03|Error en la consulta de base de datos|La API responde `503 Service Unavailable` y registra el incidente.|

---

## 7. POSTCONDICIONES

- **Éxito:** La UI dispone de la lista filtrada y los totales asociados para continuar con la revisión.
- **Fallo:** No se entrega información filtrada; la UI mantiene el estado previo e informa la causa.

---

## 8. REQUISITOS ESPECIALES

- Permitir filtros combinados (p. ej. múltiples severidades) usando formato CSV en los parámetros.
- Incluir `last_updated_by` y `last_updated_at` en cada hallazgo para trazabilidad rápida.
- Registrar en auditoría los criterios utilizados cuando se apliquen filtros con severidad `High`.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-003, UC-API-007, UC-API-011.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Considerar cachear respuestas comunes para dashboards cuando el número de hallazgos sea elevado.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-012-01|Agregar ejemplos de combinaciones de filtros en la guía de integraciones.|Pendiente|Documentación|
|TD-API-012-02|Definir límites por defecto para `limit` y `page` y documentarlos en el manual técnico.|Pendiente|Plataforma|
