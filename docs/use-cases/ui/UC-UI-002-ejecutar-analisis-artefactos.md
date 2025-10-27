# UC-UI-002: Generar artefactos analíticos

**Sistema:** Threat Modeling UI
**Caso de Uso:** UC-UI-002
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-UI-002|
|**Nombre**|Generar artefactos analíticos|
|**Actor primario**|AUTOR FUNCIONAL|
|**Actores de soporte**|REVISOR DE SEGURIDAD, SERVICIO DE API|
|**Frecuencia estimada**|Semanal|
|**Prioridad**|Alta — habilita evidencia visual y técnica del modelo|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que el AUTOR FUNCIONAL obtenga diagramas, análisis de amenazas y reportes listos para revisión.
- **Resultado esperado:** La plataforma presenta diagramas vigentes, resultados del análisis y archivos descargables sin intervención manual adicional.
- **Alcance incluye:**
  - ✅ Solicitar generación de diagramas DFD y de secuencia.
  - ✅ Ejecutar el análisis de amenazas y revisar hallazgos resumidos.
  - ✅ Validar sintaxis del código y descargar artefactos.
- **Fuera de alcance:**
  - ❌ Ajustar manualmente los archivos generados (se gestiona fuera de la UI).
  - ❌ Definir mitigaciones finales (cubierto por UC-UI-003).

---

## 3. PRECONDICIONES

- Existe un modelo vigente guardado (UC-UI-001).
- El AUTOR FUNCIONAL está autenticado y posee permisos para ejecutar análisis.
- Los servicios externos (pytm, Graphviz, PlantUML) están disponibles.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|AUTOR FUNCIONAL|Accede al panel de un modelo y selecciona "Generar DFD".| 
|2|SISTEMA|Envía la solicitud a la API, muestra estado "Generando" y luego presenta el diagrama con opciones de zoom y descarga en PNG.|
|3|AUTOR FUNCIONAL|Solicita "Generar diagrama de secuencia" para el mismo modelo.| 
|4|SISTEMA|Renderiza el artefacto, indica si proviene de caché y habilita la descarga en SVG o PNG según la preferencia seleccionada.|
|5|AUTOR FUNCIONAL|Pulsa "Analizar amenazas" para obtener hallazgos actualizados.| 
|6|SISTEMA|Ejecuta pytm, muestra el resumen por severidad y lista los hallazgos detectados.|
|7|AUTOR FUNCIONAL|Valida la sintaxis del código Python antes de descargarlo.| 
|8|SISTEMA|Confirma la validez, ofrece la descarga del script con nombre normalizado (`<modelo>.py`) y notifica que los artefactos están listos.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El AUTOR FUNCIONAL solicita regenerar el diagrama ignorando caché|El SISTEMA fuerza nueva ejecución, reemplaza la versión previa y actualiza la marca temporal.| 
|FA-02|El AUTOR FUNCIONAL proporciona archivos personalizados de amenazas o plantillas|El SISTEMA permite adjuntarlos, ejecuta el análisis con dichos insumos y etiqueta el resultado como "Personalizado".|
|FA-03|El AUTOR FUNCIONAL solicita descargar una versión previa del diagrama|El SISTEMA ofrece el historial de diagramas disponibles y permite seleccionar el artefacto a descargar.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|La validación de código falla|El SISTEMA indica la línea con error en el editor y bloquea la descarga hasta corregirlo.| 
|FE-02|La generación del diagrama excede el tiempo límite|El SISTEMA detiene el proceso, muestra un mensaje de expiración y sugiere reintentar o contactar soporte.| 
|FE-03|El análisis de amenazas arroja error|El SISTEMA conserva los hallazgos anteriores, marca el análisis como fallido y registra el evento en la actividad.|

---

## 7. POSTCONDICIONES

- **Éxito:** Los diagramas y reportes quedan disponibles en la vista, con enlaces de descarga y resumen actualizado de amenazas.
- **Fallo:** No se actualizan los artefactos; la UI conserva la última versión válida e informa el motivo del fallo.

---

## 8. REQUISITOS ESPECIALES

- Las vistas de diagramas deben incluir controles de zoom, rotación y descarga directa.
- El resumen de amenazas debe mostrar métricas clave (tiempo de ejecución, cantidad total, severidad) para acelerar la revisión.
- El sistema debe evidenciar si el resultado proviene de caché o de una ejecución reciente.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-API-006, UC-API-007, UC-API-009, UC-API-010, UC-API-014, UC-UI-003.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Alinear los mensajes con el procedimiento operativo estándar de revisión de seguridad.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-UI-002-01|Adjuntar capturas de los estados "Generando" y "Fallido" para el manual de usuario.|Pendiente|Documentación|
|TD-UI-002-02|Detallar el formato de exportación de reportes (PDF vs Markdown) cuando se estandarice.|En curso|Producto|
