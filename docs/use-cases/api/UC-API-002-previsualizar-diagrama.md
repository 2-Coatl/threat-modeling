# UC-API-002: Listar modelos disponibles

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-002
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-002|
|**Nombre**|Listar modelos disponibles|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|BASE DE DATOS|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Media — facilita navegación y descubrimiento de modelos|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la UI recupere listados paginados de modelos considerando permisos y filtros.
- **Resultado esperado:** La API entrega páginas consistentes con metadatos y totales para construir la experiencia de dashboard.
- **Alcance incluye:**
  - ✅ Procesar parámetros de paginación, búsqueda y etiquetas.
  - ✅ Aplicar reglas de visibilidad (público, propio, compartido).
  - ✅ Devolver métricas de paginación (total, límite, página actual).
- **Fuera de alcance:**
  - ❌ Entregar detalles completos del modelo (cubierto en UC-API-003).
  - ❌ Gestionar favoritos o vistas personalizadas (no implementado).

---

## 3. PRECONDICIONES

- Existen modelos registrados en la base de datos.
- El usuario autenticado cuenta con permisos para consultar el listado.
- Están definidas las vistas o índices necesarios para filtros de texto.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía `GET /api/models?page=<n>&limit=<m>&search=<texto>&tags=<lista>`.| 
|2|API|Normaliza parámetros, establece límites máximos y calcula `offset`.| 
|3|API|Ejecuta consulta que filtra por visibilidad y términos de búsqueda, ordenando por `updated_at DESC`.| 
|4|API|Obtiene el total de resultados para la misma condición.| 
|5|API|Responde `200 OK` con colección de modelos (id, nombre, autor, etiquetas, fechas) y bloque de paginación.| 
|6|SERVICIO DE UI|Renderiza la cuadrícula de tarjetas con la información provista.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Se omiten parámetros de paginación|La API utiliza valores por defecto (`page=1`, `limit=20`).| 
|FA-02|El filtro de búsqueda está vacío pero se piden etiquetas|La API aplica únicamente filtrado por etiquetas respetando los permisos.| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El usuario no tiene acceso a ningún modelo|La API responde `200 OK` con lista vacía y totales en cero.| 
|FE-02|Se excede el límite máximo permitido (p. ej. `limit>100`)|La API responde `400 Bad Request` indicando el máximo aceptado.| 
|FE-03|Falla la consulta por indisponibilidad de la base|La API responde `503 Service Unavailable` y registra el incidente.| 

---

## 7. POSTCONDICIONES

- **Éxito:** Se entrega una página válida que la UI utiliza para poblar el dashboard.
- **Fallo:** No se entrega información; la UI muestra un mensaje de error y sugiere reintentar.

---

## 8. REQUISITOS ESPECIALES

- Deben existir índices en campos `name`, `description` y `tags` para búsquedas eficientes.
- El límite máximo configurable no debe superar 100 elementos por página.
- Incluir `author_name` y `author_id` en cada registro para trazabilidad inmediata.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-001, UC-API-003.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** El endpoint servirá como fuente para el widget de estadísticas agregadas (pendiente de diseño).

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-002-01|Documentar ejemplos de filtros combinados (búsqueda + etiquetas) en la guía de integraciones.|Pendiente|Documentación|
|TD-API-002-02|Incluir métricas de rendimiento esperadas tras la creación de índices dedicados.|En curso|Base de datos|
