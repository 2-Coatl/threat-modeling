# UC-API-014: Descargar diagramas generados

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-014
**Versión:** 1.0
**Fecha:** 2025-10-29

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-014|
|**Nombre**|Descargar diagramas generados|
|**Actor primario**|ORQUESTADOR DE MODELOS|
|**Actores de soporte**|ALMACENAMIENTO DE DIAGRAMAS|
|**Frecuencia estimada**|Media|
|**Prioridad**|Media — asegura entrega de artefactos oficiales para documentación

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la UI descargue diagramas previamente generados (DFD, secuencia) en distintos formatos para su uso en reportes y presentaciones.
- **Resultado esperado:** La API entrega el archivo solicitado con encabezados adecuados y registra la descarga para auditoría.
- **Alcance incluye:**
  - ✅ Recuperar diagramas desde base de datos o almacenamiento de archivos por `diagram_id`.
  - ✅ Ofrecer formatos soportados (PNG, SVG) según disponibilidad del artefacto.
  - ✅ Registrar el evento de descarga con usuario, tipo y timestamp.
- **Fuera de alcance:**
  - ❌ Regenerar diagramas (cubierto en UC-API-006).
  - ❌ Distribuir diagramas a terceros vía correo (gestión externa).

---

## 3. PRECONDICIONES

- El diagrama solicitado existe y pertenece a un modelo accesible para el usuario.
- El usuario está autenticado con permisos de lectura.
- El almacenamiento de diagramas responde en el tiempo esperado.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|ORQUESTADOR DE MODELOS|Envía `GET /api/diagrams/{diagram_id}/download?format=png` con token válido.|
|2|API|Verifica que el diagrama exista, pertenezca al usuario y soporte el formato solicitado.|
|3|API|Recupera el binario desde base de datos o filesystem y determina `Content-Type` y `Content-Disposition`.|
|4|API|Registra en auditoría el evento `diagram_downloaded` con usuario y formato.|
|5|API|Responde `200 OK` con el archivo binario y encabezados adecuados para descarga.|
|6|ORQUESTADOR DE MODELOS|Inicia la descarga en el navegador y notifica al usuario que el archivo está disponible.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Se solicita `format=svg` y el diagrama está almacenado en PNG|La API convierte el archivo usando Graphviz/PlantUML si es posible y devuelve el resultado en SVG.|
|FA-02|Se requiere descarga firmada|La API genera enlace temporal firmado (`?signature=...`) y redirige al almacenamiento seguro.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El diagrama no existe o no pertenece al usuario|La API responde `404 Not Found` o `403 Forbidden`.|
|FE-02|El formato solicitado no está disponible|La API responde `400 Bad Request` indicando formatos soportados.|
|FE-03|Falla el acceso al almacenamiento|La API responde `503 Service Unavailable` y registra el incidente.|

---

## 7. POSTCONDICIONES

- **Éxito:** El usuario descarga el diagrama en el formato solicitado y el evento queda registrado.
- **Fallo:** No se entrega el archivo; el sistema informa el motivo y sugiere reintentar o contactar soporte.

---

## 8. REQUISITOS ESPECIALES

- Incluir encabezado `ETag` o `Last-Modified` para permitir caching controlado en la UI.
- Limitar el tamaño máximo descargable por solicitud a 25 MB.
- Cifrar en reposo los diagramas almacenados y validar permisos antes de cada descarga.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-002, UC-API-006, UC-API-013.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Documentar proceso para revocar enlaces firmados caducados en escenarios de auditoría.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-014-01|Agregar ejemplos de descarga firmada en la guía de integraciones.|Pendiente|Producto|
|TD-API-014-02|Documentar límites de tamaño y estrategias de compresión opcional.|Pendiente|Operaciones|
