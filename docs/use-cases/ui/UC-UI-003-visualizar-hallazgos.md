# UC-UI-003: Visualizar hallazgos y compartir resultados

**Sistema:** Threat Modeling UI
**Caso de Uso:** UC-UI-003
**Versión:** 0.2
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-UI-003|
|**Nombre**|Visualizar hallazgos y compartir resultados|
|**Actor primario**|AUTOR FUNCIONAL|
|**Actores de soporte**|REVISOR DE SEGURIDAD, STAKEHOLDER DE NEGOCIO|
|**Frecuencia estimada**|Semanal|
|**Prioridad**|Media — permite comunicar riesgos detectados|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Facilitar que el AUTOR FUNCIONAL y los interesados revisen los hallazgos del análisis y los compartan con su equipo.
- **Resultado esperado:** Los hallazgos se presentan en la UI con filtros útiles y opciones para exportar o distribuir la información.
- **Alcance incluye:**
  - ✅ Mostrar el resumen del análisis con clasificación por severidad.
  - ✅ Permitir filtrar y buscar hallazgos relevantes.
  - ✅ Compartir resultados mediante descarga o enlace controlado.
- **Fuera de alcance:**
  - ❌ Registrar correcciones (cubre UC-API-008).
  - ❌ Capturar compromisos de mitigación (se gestiona en herramientas externas).

---

## 3. PRECONDICIONES

- Existe un análisis completado con resultados disponibles.
- El AUTOR FUNCIONAL o el REVISOR DE SEGURIDAD tienen permisos para consultar hallazgos.
- El navegador cuenta con conectividad hacia la API.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|AUTOR FUNCIONAL|Accede a la sección de hallazgos desde la UI.
|2|SISTEMA|Recupera los resultados del análisis vigente y muestra el resumen.
|3|AUTOR FUNCIONAL|Filtra hallazgos por severidad o palabra clave.
|4|SISTEMA|Actualiza la vista con el subconjunto filtrado e indica el total afectado.
|5|AUTOR FUNCIONAL|Selecciona hallazgos y genera un enlace o archivo para compartir.
|6|SISTEMA|Prepara la exportación elegida y confirma que el recurso está disponible para los destinatarios permitidos.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Se requiere comparar con un análisis anterior|El SISTEMA ofrece seleccionar otra ejecución y muestra las diferencias relevantes.
|FA-02|El AUTOR FUNCIONAL delega la revisión|El SISTEMA permite notificar al REVISOR DE SEGURIDAD con un enlace directo y permisos temporales.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|No existen análisis recientes|El SISTEMA indica que se debe ejecutar UC-UI-002 antes de visualizar hallazgos.
|FE-02|La exportación falla|El SISTEMA informa la causa y mantiene visible el resumen para reintentar.

---

## 7. POSTCONDICIONES

- **Éxito:** Los hallazgos quedan visibles, filtrados según necesidad y, si aplica, compartidos con los interesados.
- **Fallo:** No se generan nuevas exportaciones y la UI mantiene el estado previo indicando la incidencia.

---

## 8. REQUISITOS ESPECIALES

- La UI debe resaltar hallazgos críticos por defecto.
- Las exportaciones deben incluir fecha y autor de la operación para trazabilidad.

