# UC-UI-002: Ejecutar análisis y generar artefactos

**Sistema:** Threat Modeling UI
**Caso de Uso:** UC-UI-002
**Versión:** 0.2
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-UI-002|
|**Nombre**|Ejecutar análisis y generar artefactos|
|**Actor primario**|AUTOR FUNCIONAL|
|**Actores de soporte**|REVISOR DE SEGURIDAD|
|**Frecuencia estimada**|Semanal|
|**Prioridad**|Alta — conecta la fase de modelado con la de evaluación|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir al AUTOR FUNCIONAL solicitar desde la UI el análisis de amenazas y la generación de artefactos de soporte.
- **Resultado esperado:** El autor recibe confirmación del análisis, acceso a los hallazgos y a los artefactos necesarios para su revisión.
- **Alcance incluye:**
  - ✅ Seleccionar la versión del diagrama a analizar.
  - ✅ Lanzar el análisis y monitorear su progreso.
  - ✅ Descargar o consultar los artefactos generados.
- **Fuera de alcance:**
  - ❌ Modificar los hallazgos detectados.
  - ❌ Escalar automáticamente incidentes críticos (se maneja fuera de la UI).

---

## 3. PRECONDICIONES

- El AUTOR FUNCIONAL tiene acceso a una versión confirmada del diagrama.
- La API y los servicios de análisis se encuentran disponibles.
- El proyecto cuenta con un modelo pytm asociado y listo para procesarse.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|AUTOR FUNCIONAL|Desde la UI, selecciona la versión del diagrama para analizar.
|2|SISTEMA|Confirma la selección y muestra el resumen de la versión.
|3|AUTOR FUNCIONAL|Inicia el análisis y solicita generar artefactos relacionados.
|4|SISTEMA|Muestra el estado del análisis (en progreso, completado) y notifica al finalizar.
|5|SISTEMA|Pone a disposición los artefactos y enlaces a los hallazgos.
|6|AUTOR FUNCIONAL|Descarga o revisa los artefactos y comparte el resultado con el REVISOR DE SEGURIDAD.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El análisis tarda más de lo esperado|El SISTEMA informa tiempos estimados y permite que el AUTOR FUNCIONAL continúe trabajando mientras se completa.
|FA-02|El autor necesita cancelar el análisis|El SISTEMA solicita confirmación, detiene la ejecución y mantiene la última versión analizada.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Falla el análisis por un error técnico|El SISTEMA comunica la falla, conserva el último resultado válido y ofrece reintentar.
|FE-02|No se pueden generar artefactos|El SISTEMA detiene la operación, informa el motivo y sugiere reintento tras solucionar la causa.

---

## 7. POSTCONDICIONES

- **Éxito:** El análisis se completa, los hallazgos quedan accesibles y los artefactos pueden descargarse.
- **Fallo:** No se generan resultados nuevos y la UI mantiene el estado previo indicando la razón del fallo.

---

## 8. REQUISITOS ESPECIALES

- La UI debe notificar por canal visible (banner o panel) cuando el análisis finaliza.
- Debe registrarse qué usuario inició el análisis para trazabilidad.

