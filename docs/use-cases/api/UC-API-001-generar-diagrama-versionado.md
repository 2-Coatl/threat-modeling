# UC-API-001: Registrar modelos visuales

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-001
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-001|
|**Nombre**|Registrar modelos visuales|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|BASE DE DATOS, REPOSITORIO GIT|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Alta — inicia el ciclo de vida de cada modelo|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la UI cree modelos con metadatos, representación visual y código Python sincronizado.
- **Resultado esperado:** La API persiste el modelo en base de datos, registra el archivo en Git y devuelve los identificadores necesarios a la UI.
- **Alcance incluye:**
  - ✅ Validar que el esquema visual y el código Python recibidos sean consistentes.
  - ✅ Insertar registros en la base de datos con autoría, etiquetas y timestamps.
  - ✅ Crear el archivo Python en el repositorio Git y confirmar el commit.
- **Fuera de alcance:**
  - ❌ Generar diagramas derivados (cubierto en UC-API-006).
  - ❌ Compartir acceso con otros usuarios (cubierto en UC-API-009).

---

## 3. PRECONDICIONES

- El usuario está autenticado y cuenta con permisos de creación.
- El repositorio Git está accesible y tiene espacio disponible.
- Existen reglas de validación para el esquema de nodos y aristas.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía `POST /api/models` con nombre, descripción, etiquetas, modelo visual y código Python generado.| 
|2|API|Valida el payload, asegura que nodos y aristas sean arreglos y que el código compile correctamente.| 
|3|API|Registra el modelo en `pytm_models`, asociando autor, etiquetas y timestamps, y obtiene el `model_id`.| 
|4|API|Crea el archivo Python dentro del repositorio Git, añade el commit "Created model" y guarda el hash resultante.| 
|5|API|Actualiza el registro con la ruta del archivo y hash de commit, registra evento en auditoría.| 
|6|API|Responde `201 Created` con el identificador del modelo, metadatos y referencias a Git.| 
|7|SERVICIO DE UI|Redirige al editor usando el `model_id` retornado y almacena la confirmación del guardado inicial.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El código Python no compila|La API responde `400 Bad Request` con detalle de la línea afectada para que la UI solicite corrección.| 
|FA-02|Ya existe un modelo con el mismo nombre para el autor|La API permite la creación pero agrega sufijo sugerido y notifica a la UI la colisión para su tratamiento.| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Falla el commit en Git|La API revierte la transacción, elimina registros creados y responde `500 Internal Server Error`.| 
|FE-02|Se pierde conexión a la base de datos durante la inserción|La API aborta la transacción y responde `503 Service Unavailable` indicando reintento posterior.| 
|FE-03|El payload supera el tamaño permitido|La API responde `413 Payload Too Large` e informa el límite soportado.| 

---

## 7. POSTCONDICIONES

- **Éxito:** El modelo queda almacenado con referencias a Git y puede ser editado o listado por otros casos de uso.
- **Fallo:** No se guardan cambios y se mantienen los repositorios sin modificación.

---

## 8. REQUISITOS ESPECIALES

- El commit inicial debe seguir convención `Created model: <Nombre>`.
- Los modelos deben registrarse con etiquetas en minúsculas y sin espacios para facilitar búsquedas.
- Registrar en auditoría el tiempo total de creación para fines de métricas.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-001, UC-API-003, UC-API-004.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Mantener sincronizada la ruta del archivo con el árbol físico `/pytm-models/models/`.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-001-01|Agregar ejemplo completo del payload `POST /api/models` en la guía para desarrolladores.|Pendiente|Documentación técnica|
|TD-API-001-02|Incluir escenario de creación a partir de importación JSON cuando se libere el endpoint dedicado.|En curso|Producto|
