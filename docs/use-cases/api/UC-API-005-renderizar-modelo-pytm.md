# UC-API-005: Eliminar modelos

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-005
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-005|
|**Nombre**|Eliminar modelos|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|BASE DE DATOS, REPOSITORIO GIT|
|**Frecuencia estimada**|Media|
|**Prioridad**|Media — asegura limpieza de datos y repositorio|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la UI elimine modelos y sus artefactos asociados cuando ya no se requieren.
- **Resultado esperado:** La API remueve registros, archivos y compartidos relacionados garantizando consistencia.
- **Alcance incluye:**
  - ✅ Validar que el usuario sea propietario o administrador.
  - ✅ Eliminar registros dependientes (hallazgos, comentarios, diagramas, compartidos).
  - ✅ Remover el archivo de Git y confirmar el commit correspondiente.
- **Fuera de alcance:**
  - ❌ Retención de backups (gestionada por políticas externas).
  - ❌ Soft delete (no implementado en la versión actual).

---

## 3. PRECONDICIONES

- El modelo existe y se encuentra asociado al usuario solicitante o su rol permite la eliminación.
- El repositorio Git permite operaciones `git rm` y commits.
- No existen bloqueos de base de datos que impidan transacciones prolongadas.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía `DELETE /api/models/{model_id}` tras confirmación del usuario.| 
|2|API|Verifica permisos y prepara transacción en base de datos.| 
|3|API|Elimina registros de `threat_findings`, `diagrams`, `comments` y `model_shares` asociados.| 
|4|API|Elimina el registro principal de `pytm_models`.| 
|5|API|Ejecuta `git rm` sobre el archivo del modelo y crea commit "Deleted model".| 
|6|API|Confirma la transacción y registra evento `model_deleted` en auditoría.| 
|7|API|Responde `204 No Content`.| 
|8|SERVICIO DE UI|Actualiza el listado y muestra mensaje de confirmación.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El usuario no es propietario|La API responde `403 Forbidden` indicando que solo propietarios o administradores pueden eliminar.| 
|FA-02|Se solicita eliminación masiva|La API recomienda usar endpoint batch (pendiente) y devuelve `409 Conflict` si existe procesamiento en curso.| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Falla al eliminar archivo en Git|La API revierte la transacción y responde `500 Internal Server Error`.| 
|FE-02|Algún registro dependiente no puede eliminarse|La API aborta la operación, registra el incidente y devuelve `409 Conflict`.| 
|FE-03|La transacción excede el tiempo límite|La API cancela el proceso y responde `504 Gateway Timeout` sugiriendo reintento.| 

---

## 7. POSTCONDICIONES

- **Éxito:** El modelo y sus artefactos desaparecen de la plataforma y el repositorio.
- **Fallo:** No se eliminan registros; se mantiene el estado previo documentando la causa.

---

## 8. REQUISITOS ESPECIALES

- Registrar el identificador del commit de eliminación en la auditoría.
- Notificar a colaboradores previamente compartidos (evento `model.revoked`).
- Garantizar que las rutas de archivos eliminados no queden huérfanas en el repositorio.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-001, UC-API-001, UC-API-004.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Considerar futura implementación de papelera de reciclaje.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-005-01|Detallar proceso de notificación a colaboradores tras eliminación.|Pendiente|Producto|
|TD-API-005-02|Documentar estrategia de backup previo a eliminación para auditoría.|En curso|Operaciones|
