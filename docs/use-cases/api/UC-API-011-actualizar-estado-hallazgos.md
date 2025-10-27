# UC-API-011: Actualizar estado de hallazgos

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-011
**Versión:** 1.0
**Fecha:** 2025-10-29

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-011|
|**Nombre**|Actualizar estado de hallazgos|
|**Actor primario**|ORQUESTADOR DE MODELOS|
|**Actores de soporte**|BASE DE DATOS, SERVICIO DE NOTIFICACIONES|
|**Frecuencia estimada**|Semanal|
|**Prioridad**|Alta — permite seguimiento de mitigaciones y decisiones de riesgo|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Habilitar a la UI para que los revisores cambien el estado de los hallazgos (mitigado, aceptado, falso positivo) y registren notas justificativas.
- **Resultado esperado:** La API actualiza el hallazgo, registra la decisión con timestamp y devuelve la representación actualizada para la UI.
- **Alcance incluye:**
  - ✅ Validar transiciones de estado permitidas y permisos del solicitante.
  - ✅ Persistir notas de mitigación y usuario responsable.
  - ✅ Notificar a colaboradores relevantes cuando cambie un estado crítico.
- **Fuera de alcance:**
  - ❌ Generar reportes exportables (tratado en UC-API-009).
  - ❌ Alterar la definición base de la amenaza (propia de los catálogos pytm).

---

## 3. PRECONDICIONES

- Existen hallazgos asociados al modelo (UC-API-007 ejecutado previamente).
- El usuario autenticado cuenta con permisos para modificar hallazgos.
- La tabla `threat_findings` admite actualización y registra `updated_at`.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|ORQUESTADOR DE MODELOS|Envía `PUT /api/threats/{finding_id}` con estado objetivo, notas y token válido.|
|2|API|Verifica la existencia del hallazgo y permisos del usuario.|
|3|API|Valida la transición (por ejemplo, de `open` a `mitigated`) según reglas establecidas.|
|4|API|Actualiza el registro con nuevo estado, notas, usuario responsable y `updated_at=NOW()`.|
|5|API|Registra evento `threat_status_updated` en la auditoría e inicia notificaciones si aplica.|
|6|API|Responde `200 OK` con el hallazgo actualizado y metadatos de la decisión.|
|7|ORQUESTADOR DE MODELOS|Actualiza la tarjeta del hallazgo en la UI y refleja el nuevo estado.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El usuario cambia el estado a `accepted` sin notas|La API exige nota obligatoria y responde `400 Bad Request` indicando el requisito.|
|FA-02|Se adjunta evidencia adicional|La API acepta un enlace o identificador de ticket y lo guarda en el campo `evidence_ref`.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El hallazgo no existe|La API responde `404 Not Found` y registra el intento en auditoría.|
|FE-02|Transición no permitida (p. ej. `mitigated` a `open` sin bandera)|La API responde `409 Conflict` con mensaje "Transición de estado no permitida".|
|FE-03|Error al persistir en base de datos|La API responde `500 Internal Server Error` y no altera el estado previo.|

---

## 7. POSTCONDICIONES

- **Éxito:** El hallazgo refleja el nuevo estado, notas y usuario responsable; la auditoría contiene el evento correspondiente.
- **Fallo:** No se realizan cambios y el hallazgo permanece en el estado anterior.

---

## 8. REQUISITOS ESPECIALES

- Aceptar solo estados definidos en el catálogo (`open`, `mitigated`, `accepted`, `false_positive`).
- Limitar el tamaño de notas a 1 000 caracteres y sanitizarlas para evitar XSS.
- Enviar notificación automática cuando un hallazgo `high` pasa a `accepted` o `false_positive`.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-003, UC-API-007, UC-API-012.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Documentar políticas de revisión cuando un hallazgo cambie de estado más de dos veces en menos de 24 horas.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-011-01|Publicar tabla de transiciones válidas en la guía de seguridad.|Pendiente|Seguridad|
|TD-API-011-02|Agregar ejemplos de payload con evidencias adjuntas en la documentación de API.|Pendiente|Documentación|
