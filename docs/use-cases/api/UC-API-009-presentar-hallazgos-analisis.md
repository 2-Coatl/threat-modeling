# UC-API-009: Presentar hallazgos del análisis

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-009
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-009|
|**Nombre**|Presentar hallazgos del análisis|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|AUTOR FUNCIONAL, REVISOR DE SEGURIDAD|
|**Frecuencia estimada**|Media|
|**Prioridad**|Alta — entrega insumos clave para decisiones de mitigación|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Exponer al actor los resultados del análisis de amenazas realizado para que pueda priorizar acciones.
- **Resultado esperado:** Los hallazgos se muestran categorizados y con información suficiente para decidir medidas siguientes.
- **Alcance incluye:**
  - ✅ Recuperar los resultados de la última ejecución del análisis.
  - ✅ Organizar hallazgos por severidad y categoría.
  - ✅ Permitir descargar reportes completos cuando sea necesario.
- **Fuera de alcance:**
  - ❌ Aprobar o rechazar hallazgos (competencia de gobernanza de seguridad).
  - ❌ Registrar correcciones (cubre UC-API-008).

---

## 3. PRECONDICIONES

- Existe una ejecución de análisis completada y vigente.
- El actor cuenta con permisos para consultar hallazgos.
- Los artefactos del análisis están disponibles para lectura.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Solicita los resultados del análisis asociado al modelo activo.
|2|SISTEMA|Valida que existe un análisis reciente y accesible.
|3|SISTEMA|Recupera los hallazgos y los agrupa por severidad.
|4|SISTEMA|Entrega el resumen junto con enlaces a los reportes completos.
|5|SERVICIO DE UI|Muestra el resumen al AUTOR FUNCIONAL y ofrece descargar o compartir los artefactos.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|No hay análisis previos|El SISTEMA informa que se requiere ejecutar UC-API-007 antes de consultar resultados.
|FA-02|Existen múltiples análisis recientes|El SISTEMA solicita al actor elegir cuál desea consultar y luego continúa con el flujo.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Los artefactos del análisis están incompletos|El SISTEMA reporta la inconsistencia y sugiere regenerar el análisis.
|FE-02|El actor pierde permisos durante la consulta|El SISTEMA interrumpe la entrega y solicita autenticación válida.

---

## 7. POSTCONDICIONES

- **Éxito:** El actor cuenta con un resumen actualizado de hallazgos y acceso a los reportes de soporte.
- **Fallo:** No se presenta información y se mantiene el estado previo documentando la causa.

---

## 8. REQUISITOS ESPECIALES

- El resumen debe resaltar hallazgos críticos y su impacto estimado.
- Los reportes descargables deben conservar la versión y fecha del análisis para trazabilidad.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-003, UC-API-007.
- **Artefactos complementarios:** No aplica (tableros de visualización se documentarán como anexos UI).
- **Notas adicionales:** Sirve como punto de partida para las correcciones registradas en UC-API-008.

