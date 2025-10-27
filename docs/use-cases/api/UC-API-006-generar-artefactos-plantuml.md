# UC-API-006: Generar diagramas automáticos

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-006
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-006|
|**Nombre**|Generar diagramas automáticos|
|**Actor primario**|ORQUESTADOR DE MODELOS|
|**Actores de soporte**|SERVICIO PYTM, GRAPHVIZ, PLANTUML, BASE DE DATOS|
|**Frecuencia estimada**|Media|
|**Prioridad**|Alta — provee representación visual actualizada|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la plataforma genere diagramas DFD y de secuencia basados en el código pytm del modelo.
- **Resultado esperado:** La API crea los artefactos solicitados, los almacena y devuelve ubicaciones para su consulta.
- **Alcance incluye:**
  - ✅ Ejecutar pytm para obtener salidas DOT o PlantUML.
  - ✅ Transformar las salidas en formatos gráficos (PNG, SVG).
  - ✅ Cachear resultados y registrar metadatos de generación.
- **Fuera de alcance:**
  - ❌ Regeneración forzada de amenazas (cubierto en UC-API-007).
  - ❌ Generación de diagramas personalizados no soportados por pytm.

---

## 3. PRECONDICIONES

- El modelo cuenta con código pytm vigente.
- Los servicios externos (pytm, Graphviz, PlantUML) están disponibles.
- Existe almacenamiento para guardar archivos generados.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|ORQUESTADOR DE MODELOS|Envía `POST /api/models/{model_id}/generate-dfd` o `generate-sequence` con token válido.| 
|2|API|Recupera el código del modelo y calcula hash de contenido.| 
|3|API|Verifica si existe cache con el mismo hash y tipo de diagrama.| 
|4|API|Si hay cache, responde `200 OK` indicando `cached=true` y retorna identificador existente.| 
|5|API|Si no hay cache, ejecuta pytm con flag correspondiente y obtiene DOT o PlantUML.| 
|6|API|Convierte la salida a PNG o SVG usando Graphviz/PlantUML.| 
|7|API|Guarda resultado en base de datos y filesystem, registra tiempo de generación.| 
|8|API|Responde `201 Created` con `diagram_id`, URL de descarga y metadatos de caché.| 
|9|ORQUESTADOR DE MODELOS|Actualiza la UI con la información del nuevo diagrama.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El cliente solicita regeneración forzada (`force=true`)|La API omite cache, ejecuta el proceso completo y reemplaza registros previos.| 
|FA-02|El cliente solicita formato SVG para DFD|La API genera PNG por defecto y además ofrece conversión a SVG cuando sea viable.| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|pytm retorna error|La API responde `422 Unprocessable Entity` con el log correspondiente.| 
|FE-02|Graphviz falla en la conversión|La API responde `502 Bad Gateway` indicando error externo y registra el incidente.| 
|FE-03|El tiempo de ejecución excede el límite|La API responde `504 Gateway Timeout` y sugiere reintentar más tarde.| 

---

## 7. POSTCONDICIONES

- **Éxito:** El diagrama queda almacenado, listo para ser visualizado o descargado por la UI.
- **Fallo:** No se generan nuevos artefactos y se mantiene el último resultado válido si existía.

---

## 8. REQUISITOS ESPECIALES

- Registrar `generated_in_ms` en la base de datos para monitoreo.
- Asociar cada diagrama con `content_hash` para controlar el cache.
- Emitir evento `diagram.generated` con información de tipo y timestamp.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-002, UC-API-004, UC-API-007.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Coordinar con almacenamiento externo para respaldar archivos en frío.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-006-01|Documentar parámetros `force` y formatos disponibles en la guía de integraciones.|Pendiente|Documentación|
|TD-API-006-02|Añadir matriz de tiempos promedio por tipo de diagrama en el runbook operativo.|En curso|Operaciones|
