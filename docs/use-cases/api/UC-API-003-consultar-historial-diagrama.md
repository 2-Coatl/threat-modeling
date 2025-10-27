# UC-API-003: Consultar detalles de modelo

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-003
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-003|
|**Nombre**|Consultar detalles de modelo|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|BASE DE DATOS, REPOSITORIO GIT|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Alta — habilita edición, análisis y colaboración|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Proveer a la UI los datos completos del modelo, incluyendo visualización, código, autoría y permisos.
- **Resultado esperado:** La API entrega un payload detallado, validando que el usuario posea acceso legítimo.
- **Alcance incluye:**
  - ✅ Recuperar modelo por identificador incluyendo JSON visual y código Python.
  - ✅ Resolver metadatos de autor, commits y rutas asociadas.
  - ✅ Verificar permisos (público, propietario, compartido) antes de responder.
- **Fuera de alcance:**
  - ❌ Entregar historial de versiones (cubierto en UC-API-008).
  - ❌ Modificar datos del modelo (cubierto en UC-API-004).

---

## 3. PRECONDICIONES

- El modelo existe en la base de datos.
- El usuario autenticado tiene permiso de lectura.
- Los registros de Git asociados están accesibles.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía `GET /api/models/{model_id}`.| 
|2|API|Busca el registro en la base de datos, incluyendo relaciones de autor y compartidos.| 
|3|API|Valida si el modelo es público, pertenece al usuario o está compartido con él.| 
|4|API|Recupera `visual_model`, `python_code`, `git_file_path`, `git_commit_hash`, etiquetas y timestamps.| 
|5|API|Responde `200 OK` con el objeto completo, incluyendo información de autoría y permisos.| 
|6|SERVICIO DE UI|Carga el editor, pobla el lienzo y la vista de código con la información recibida.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El modelo está compartido con el usuario con permiso "ver"|La API incluye indicador de solo lectura para que la UI bloquee acciones de edición.| 
|FA-02|El modelo se encuentra archivado|La API marca el campo `is_archived` y la UI muestra banner de aviso pero permite visualización.| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El modelo no existe|La API responde `404 Not Found` y registra el intento en auditoría.| 
|FE-02|El usuario no posee permisos|La API responde `403 Forbidden` indicando "Acceso denegado".| 
|FE-03|Error al recuperar información de Git|La API responde `502 Bad Gateway` señalando indisponibilidad del repositorio y sugiere reintentar.| 

---

## 7. POSTCONDICIONES

- **Éxito:** La UI recibe todos los datos necesarios para editar o revisar el modelo.
- **Fallo:** No se entrega información sensible y se registra el evento para monitoreo.

---

## 8. REQUISITOS ESPECIALES

- La respuesta debe incluir `last_login` del autor si se requiere seguimiento de actividad.
- Incorporar bandera `can_edit` para que la UI adapte la experiencia.
- Registrar duración de la consulta para métricas de rendimiento.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-001, UC-UI-003, UC-API-004.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Mantener compatibilidad con clientes automatizados que consumen el mismo endpoint.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-003-01|Incluir ejemplo de respuesta con modelo compartido solo lectura.|Pendiente|Documentación|
|TD-API-003-02|Documentar mensajes de error estandarizados para acceso denegado.|Pendiente|Seguridad|
