# UC-API-001: Generar diagrama versionado

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-001
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-001|
|**Nombre**|Generar diagrama versionado|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|AUTOR FUNCIONAL, OPERACIONES DE PLATAFORMA|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Alta — asegura trazabilidad de cambios sobre el modelo|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Registrar una nueva versión del diagrama de amenazas solicitado por el AUTOR FUNCIONAL desde la interfaz.
- **Resultado esperado:** La versión queda almacenada con metadatos de autoría y un identificador único que permite auditoría y rollback.
- **Alcance incluye:**
  - ✅ Validar que el contenido recibido es apto para persistirse.
  - ✅ Guardar el diagrama y sus artefactos relacionados en el repositorio histórico.
  - ✅ Confirmar al actor que la versión fue creada exitosamente.
- **Fuera de alcance:**
  - ❌ Resolver errores de sintaxis del modelo (trazados en UC-API-002).
  - ❌ Ejecutar análisis de amenazas posteriores (cubierto por UC-API-006 y UC-API-007).

---

## 3. PRECONDICIONES

- El SERVICIO DE UI cuenta con un token o sesión válida para invocar la API.
- Existe al menos una versión previa o un espacio inicial reservado para el diagrama.
- El repositorio de historial tiene permisos de escritura disponibles.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía la solicitud de guardado con el código del diagrama y la descripción del cambio.
|2|SISTEMA|Valida que la sesión es válida y que el diagrama identificado puede versionarse.
|3|SISTEMA|Persiste el contenido junto con autor, descripción y marca temporal.
|4|SISTEMA|Actualiza el historial vinculando la nueva versión con la previa.
|5|SISTEMA|Responde al SERVICIO DE UI con el identificador de versión confirmando el éxito.
|6|SERVICIO DE UI|Informa al AUTOR FUNCIONAL que la versión está lista para usarse.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El diagrama solicitado no existe|El SISTEMA comunica la inexistencia del recurso; el SERVICIO DE UI notifica y ofrece crear un nuevo diagrama.
|FA-02|La versión supera el tamaño máximo permitido|El SISTEMA rechaza el guardado indicando el límite y conserva la versión anterior activa.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Se interrumpe la escritura en el repositorio histórico|El SISTEMA detiene la operación, registra el error y solicita intervención de OPERACIONES DE PLATAFORMA.
|FE-02|La sesión del SERVICIO DE UI caduca durante el proceso|El SISTEMA invalida la solicitud, no guarda cambios y pide autenticarse nuevamente.

---

## 7. POSTCONDICIONES

- **Éxito:** El historial del diagrama incluye la nueva versión con su identificador y metadatos completos.
- **Fallo:** No se crean nuevas versiones y el sistema mantiene el estado previo documentando la causa del fallo.

---

## 8. REQUISITOS ESPECIALES

- Debe conservarse la integridad de las versiones anteriores; ningún guardado puede sobrescribirlas.
- La respuesta debe incluir referencias que permitan iniciar consultas o diffs posteriores.
- Los mensajes de error tienen que indicar el motivo y sugerir acciones para corregirlo.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-001.
- **Artefactos complementarios:** No aplica (diagramas se documentarán por separado).
- **Notas adicionales:** Comparte trazabilidad con las operaciones de historial descritas en UC-API-003 y UC-API-004.

