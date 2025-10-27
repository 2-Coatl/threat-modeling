# UC-API-008: Gestionar historial y versiones

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-008
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-008|
|**Nombre**|Gestionar historial y versiones|
|**Actor primario**|ORQUESTADOR DE MODELOS|
|**Actores de soporte**|REPOSITORIO GIT, BASE DE DATOS|
|**Frecuencia estimada**|Media|
|**Prioridad**|Media — habilita trazabilidad y recuperación|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Proveer mecanismos para consultar, comparar, restaurar y ramificar modelos a partir del historial en Git.
- **Resultado esperado:** La API entrega datos de commits, diffs y estados restaurados manteniendo la consistencia del repositorio y la base de datos.
- **Alcance incluye:**
  - ✅ Consultar historial de commits (`GET /history`).
  - ✅ Comparar versiones (`POST /compare`).
  - ✅ Restaurar a un commit previo (`POST /rollback`).
  - ✅ Gestionar ramas (`POST /branch`, `POST /merge`).
- **Fuera de alcance:**
  - ❌ Resolución manual de conflictos complejos (requiere intervención de DevOps).
  - ❌ Automatización de despliegues (fuera del dominio del modelo).

---

## 3. PRECONDICIONES

- El modelo tiene un archivo rastreado en Git.
- El repositorio permite ejecución de comandos `git log`, `git diff`, `git checkout`.
- El usuario posee permisos para realizar operaciones solicitadas (lectura o edición según corresponda).

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|ORQUESTADOR DE MODELOS|Solicita `GET /api/models/{model_id}/history?limit=20`.| 
|2|API|Ejecuta `git log --pretty` sobre el archivo del modelo y devuelve lista de commits con metadatos.| 
|3|ORQUESTADOR DE MODELOS|Envía `POST /api/models/{model_id}/compare` con dos hashes de commit.| 
|4|API|Extrae versiones temporales, ejecuta `git diff` y calcula cambios (elementos agregados, modificados, eliminados).| 
|5|ORQUESTADOR DE MODELOS|Decide restaurar versión previa con `POST /api/models/{model_id}/rollback`.| 
|6|API|Obtiene contenido del commit objetivo, actualiza base de datos, genera nuevo commit "Rollback" y limpia cachés.| 
|7|ORQUESTADOR DE MODELOS|Crea nueva rama con `POST /api/models/{model_id}/branch` y eventualmente fusiona mediante `POST /merge`.| 
|8|API|Ejecuta comandos Git correspondientes, maneja errores de conflictos y registra auditorías.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Comparación solicita solo resumen|La API devuelve métricas de cambios sin detallar diff textual.| 
|FA-02|Rollback requiere reconstruir modelo visual|La API intenta parsear el código para regenerar `visual_model`; si falla, marca el modelo como "solo código".| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El commit solicitado no existe|La API responde `404 Not Found`.| 
|FE-02|`git merge` produce conflictos|La API devuelve `409 Conflict` con lista de archivos problemáticos y sin aplicar cambios.| 
|FE-03|El repositorio no está disponible|La API responde `503 Service Unavailable` y registra alerta para DevOps.| 

---

## 7. POSTCONDICIONES

- **Éxito:** El historial permanece consistente y las operaciones solicitadas se reflejan en base de datos y Git.
- **Fallo:** No se altera el modelo; se registran los motivos y se notifica al usuario.

---

## 8. REQUISITOS ESPECIALES

- Registrar cada operación con `action`, `commit_hash` y `branch` en la auditoría.
- Las respuestas de comparación deben incluir rutas de diagramas generados para visualización.
- Implementar límites de tasa para evitar abusos en consultas de historial.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-001, UC-API-004, UC-API-006.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Preparar guía para recuperación manual en caso de conflicto irreconciliable.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-008-01|Describir proceso para restaurar visual model cuando falla el parser.|Pendiente|Producto|
|TD-API-008-02|Agregar ejemplos de respuestas `git diff` en la guía técnica.|Pendiente|Documentación|
