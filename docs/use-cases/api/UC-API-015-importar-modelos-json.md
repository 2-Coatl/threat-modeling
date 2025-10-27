# UC-API-015: Importar modelos desde JSON

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-015
**Versión:** 1.0
**Fecha:** 2025-10-29

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-015|
|**Nombre**|Importar modelos desde JSON|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|BASE DE DATOS, REPOSITORIO GIT|
|**Frecuencia estimada**|Ocasional|
|**Prioridad**|Media — agiliza migración y reutilización de modelos existentes

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la UI cargue archivos JSON exportados previamente (u obtenidos de otra instancia) para crear un modelo completo sin reconstruirlo manualmente.
- **Resultado esperado:** La API valida la estructura, crea el modelo en base de datos, sincroniza el código en Git y devuelve el identificador para edición inmediata.
- **Alcance incluye:**
  - ✅ Validar el esquema JSON (metadatos, visualModel, pythonCode, amenazas opcionales).
  - ✅ Persistir el modelo y su código en las mismas estructuras que una creación manual.
  - ✅ Registrar auditoría de importación con detalle del origen.
- **Fuera de alcance:**
  - ❌ Resolver conflictos de identificadores con modelos existentes (se asume nuevo modelo).
  - ❌ Importar archivos en formatos distintos a JSON.

---

## 3. PRECONDICIONES

- El usuario está autenticado y cuenta con permisos de creación.
- El archivo JSON cumple con la versión de esquema soportada por la plataforma.
- El repositorio Git está disponible para registrar el nuevo archivo.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía `POST /api/models/import` con el JSON en el cuerpo y metadatos opcionales (origen, notas).|
|2|API|Valida el esquema: presencia de `name`, `description`, `visualModel`, `pythonCode`.|
|3|API|Normaliza identificadores, etiquetas y genera nuevo `model_id`.|
|4|API|Inserta el registro en `pytm_models`, guarda visualModel y pythonCode, asociando autor y timestamps.|
|5|API|Crea archivo Python en el repositorio Git, añade commit "Imported model" y almacena hash.|
|6|API|Registra evento `model_imported` en auditoría e incluye origen si fue proporcionado.|
|7|API|Responde `201 Created` con identificador, metadatos y referencias a Git para que la UI abra el editor.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El JSON incluye hallazgos históricos|La API importa el modelo pero ignora hallazgos, notificando a la UI que deberán regenerarse.|
|FA-02|Se solicita importación como borrador (`?draft=true`)|La API crea el modelo marcándolo como borrador y omite crear commit hasta que se confirme.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El archivo no cumple el esquema esperado|La API responde `422 Unprocessable Entity` con detalle de los campos faltantes o inválidos.|
|FE-02|Falla la inserción en base de datos|La API responde `500 Internal Server Error` y no genera commit.|
|FE-03|Error al escribir en Git|La API revierte cambios en base de datos y responde `500 Internal Server Error`.|

---

## 7. POSTCONDICIONES

- **Éxito:** El modelo importado queda disponible para edición, con código sincronizado y auditoría registrada.
- **Fallo:** No se crea ningún modelo; la UI muestra el error y sugiere revisar el archivo.

---

## 8. REQUISITOS ESPECIALES

- Validar versión del esquema (`schemaVersion`) para garantizar compatibilidad.
- Limitar el tamaño máximo del archivo importado a 5 MB y registrar el tamaño real.
- Sanitizar textos de descripción y notas para evitar inyección de HTML.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-001, UC-API-001, UC-API-004.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Coordinar con el equipo de soporte la publicación de plantillas de importación validadas.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-015-01|Crear validador CLI del esquema JSON para equipos externos.|Pendiente|Plataforma|
|TD-API-015-02|Agregar ejemplo completo de archivo importable en la guía pública.|Pendiente|Documentación|
