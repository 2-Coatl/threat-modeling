# UC-API-010: Validar código pytm

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-010
**Versión:** 1.0
**Fecha:** 2025-10-29

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-010|
|**Nombre**|Validar código pytm|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|SERVICIO PYTHON, BASE DE DATOS|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Alta — evita guardar modelos con errores de sintaxis|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la UI valide el script pytm generado o editado manualmente antes de guardar o descargar el modelo.
- **Resultado esperado:** La API confirma que el código es ejecutable o devuelve detalles del error con línea y mensaje para su corrección.
- **Alcance incluye:**
  - ✅ Recibir código Python en texto plano y ejecutar validación sintáctica segura.
  - ✅ Reportar la primera línea con error y mensaje amigable para la UI.
  - ✅ Registrar métricas de uso y tiempos de validación.
- **Fuera de alcance:**
  - ❌ Guardar el código validado (realizado en UC-API-004).
  - ❌ Ejecutar el análisis de amenazas completo (cubierto en UC-API-007).

---

## 3. PRECONDICIONES

- El usuario está autenticado y tiene permisos de edición sobre el modelo.
- El servicio de ejecución Python (intérprete/py_compile) está disponible en el entorno.
- La solicitud incluye código pytm completo y codificado en UTF-8.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía `POST /api/models/validate-code` con el código pytm en el cuerpo y token válido.|
|2|API|Normaliza el contenido, verifica que no exceda el tamaño permitido y crea archivo temporal seguro.|
|3|API|Invoca `py_compile` (modo doraise) para validar la sintaxis del script.|
|4|API|Registra la duración de la validación y destruye el archivo temporal.|
|5|API|Responde `200 OK` con `{ "valid": true }` indicando que el código es aceptable.|
|6|SERVICIO DE UI|Habilita los botones de guardado y descarga al recibir la confirmación.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El cliente solicita nivel de severidad extendido (`?includeWarnings=true`)|La API ejecuta linters configurados y devuelve advertencias no bloqueantes en la respuesta.|
|FA-02|Se valida código proveniente de importación JSON|La API marca el resultado con `source="import"` para trazabilidad y registro estadístico.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Se detecta error de sintaxis|La API responde `400 Bad Request` con `{ "valid": false, "line": <n>, "error": "SyntaxError: ..." }`.|
|FE-02|El payload excede el tamaño máximo permitido|La API responde `413 Payload Too Large` indicando el límite actual.|
|FE-03|Falla el intérprete Python o expira el tiempo límite|La API responde `503 Service Unavailable` con mensaje "Validador no disponible" y sugiere reintentar.|

---

## 7. POSTCONDICIONES

- **Éxito:** El código se considera válido y queda habilitado para guardarse o exportarse por casos de uso relacionados.
- **Fallo:** No se guardan cambios; la UI permanece en modo edición indicando el error detectado.

---

## 8. REQUISITOS ESPECIALES

- Limitar el tiempo de validación a 5 segundos para evitar bloqueos del backend.
- Registrar métricas (`validation_ms`, tamaño del script) para monitoreo de rendimiento.
- Sanitizar la respuesta de errores para evitar exposición de rutas internas del servidor.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-001, UC-UI-002, UC-API-004.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Integrar reglas personalizadas de estilo cuando el equipo de seguridad defina linters obligatorios.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-010-01|Agregar ejemplo de respuesta con advertencias (`includeWarnings=true`) en la guía de API.|Pendiente|Documentación|
|TD-API-010-02|Documentar límites de tamaño y tiempos máximos aceptados por el validador.|Pendiente|Operaciones|
