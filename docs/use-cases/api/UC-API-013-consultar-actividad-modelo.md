# UC-API-013: Consultar actividad del modelo

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-013
**Versión:** 1.0
**Fecha:** 2025-10-29

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-013|
|**Nombre**|Consultar actividad del modelo|
|**Actor primario**|ORQUESTADOR DE MODELOS|
|**Actores de soporte**|BASE DE DATOS, SERVICIO DE AUDITORÍA|
|**Frecuencia estimada**|Media|
|**Prioridad**|Media — brinda trazabilidad operativa y cumplimiento

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Proveer a la UI un feed cronológico de eventos relevantes sobre un modelo (guardados, análisis, comentarios, descargas) para facilitar auditoría y colaboración.
- **Resultado esperado:** La API retorna un listado ordenado por fecha con la información necesaria para visualizar el contexto en la interfaz.
- **Alcance incluye:**
  - ✅ Consultar eventos de auditoría asociados al modelo con límites de paginación.
  - ✅ Enriquecer cada evento con el nombre del usuario y la acción realizada.
  - ✅ Indicar metadatos adicionales (tipo de entidad, identificadores relacionados).
- **Fuera de alcance:**
  - ❌ Modificar o eliminar eventos del feed (solo lectura).
  - ❌ Enviar notificaciones en tiempo real (cubierto por el servicio de notificaciones).

---

## 3. PRECONDICIONES

- El modelo existe y tiene eventos registrados en la auditoría.
- El usuario autenticado posee permisos de lectura sobre el modelo.
- La tabla `audit_log` almacena los campos `action`, `entity_type`, `created_at`, `user_id` y referencias asociadas.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|ORQUESTADOR DE MODELOS|Envía `GET /api/models/{model_id}/activity?limit=50&cursor=<opcional>`.|
|2|API|Valida permisos y parámetros (`limit` máximo, cursor vigente).|
|3|API|Consulta `audit_log` filtrando por `model_id`, ordenando por `created_at DESC` y aplicando el límite solicitado.|
|4|API|Enriquece cada evento con datos del usuario (nombre, correo) y mensajes legibles.|
|5|API|Responde `200 OK` con la lista de eventos, cursor para paginación y totales disponibles.|
|6|ORQUESTADOR DE MODELOS|Renderiza la línea de tiempo en la UI y permite cargar más eventos cuando el usuario lo solicite.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Se proporciona `cursor` para paginación infinita|La API aplica el cursor, devuelve la siguiente página y recalcula el nuevo cursor.|
|FA-02|Se solicita filtrar por `action` específico (p. ej. `generated_dfd`)|La API aplica el filtro adicional y ajusta el total devuelto.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El usuario no tiene acceso al modelo|La API responde `403 Forbidden` e indica que no existe feed disponible.|
|FE-02|No hay eventos registrados|La API responde `200 OK` con lista vacía y totales en cero.|
|FE-03|Error al consultar la auditoría|La API responde `503 Service Unavailable` y registra el incidente para soporte.|

---

## 7. POSTCONDICIONES

- **Éxito:** La UI muestra la actividad reciente con información suficiente para seguimiento y cumplimiento.
- **Fallo:** No se devuelve información sensible; la UI mantiene el feed anterior y comunica el error.

---

## 8. REQUISITOS ESPECIALES

- Limitar `limit` máximo a 100 eventos por solicitud para proteger el rendimiento.
- Exponer campo `highlight` para marcar acciones críticas (eliminaciones, merges, cambios de estado críticos).
- Registrar métricas de uso del feed para ajustar estrategias de retención y archivado.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-003, UC-UI-005, UC-API-004, UC-API-009.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Coordinar con políticas de retención para anonimizar datos sensibles después del periodo definido por cumplimiento.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-013-01|Definir mensajes estándar por tipo de acción para mantener consistencia en la UI.|Pendiente|Producto|
|TD-API-013-02|Documentar políticas de retención y anonimización del feed en el manual de cumplimiento.|Pendiente|Seguridad|
