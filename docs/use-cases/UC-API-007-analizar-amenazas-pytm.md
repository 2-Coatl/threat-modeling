# UC-API-007: Analizar amenazas con pytm

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-007
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-007|
|**Nombre**|Analizar amenazas con pytm|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|AUTOR FUNCIONAL, REVISOR DE SEGURIDAD|
|**Frecuencia estimada**|Media|
|**Prioridad**|Alta — revela hallazgos críticos del modelo|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Ejecutar el análisis automático de amenazas sobre el modelo pytm vinculado y entregar resultados comprensibles.
- **Resultado esperado:** El actor obtiene un resumen de hallazgos categorizados y los artefactos necesarios para su evaluación.
- **Alcance incluye:**
  - ✅ Validar que el modelo pytm es analizable.
  - ✅ Procesar el modelo y obtener hallazgos clasificados.
  - ✅ Notificar al actor sobre el resultado y su impacto.
- **Fuera de alcance:**
  - ❌ Mitigar hallazgos detectados (requiere acciones posteriores).
  - ❌ Editar el modelo pytm en nombre del actor.

---

## 3. PRECONDICIONES

- El modelo pytm está actualizado y vinculado a la versión del diagrama.
- El entorno de análisis dispone de dependencias y permisos necesarios.
- El actor cuenta con permisos para iniciar el análisis.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Solicita ejecutar el análisis para el modelo activo.
|2|SISTEMA|Valida las precondiciones y agenda el procesamiento.
|3|SISTEMA|Ejecuta el análisis y recopila hallazgos con su clasificación.
|4|SISTEMA|Genera los reportes asociados y los vincula a la versión actual.
|5|SISTEMA|Entrega un resumen de resultados al SERVICIO DE UI.
|6|SERVICIO DE UI|Muestra el resumen y provee acceso a los reportes completos para el AUTOR FUNCIONAL y el REVISOR DE SEGURIDAD.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El análisis produce recomendaciones sin hallazgos críticos|El SISTEMA comunica que el modelo cumple y ofrece descargar el reporte para referencia.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Se detectan errores en el modelo pytm|El SISTEMA detiene el análisis y notifica qué elemento debe revisarse.
|FE-02|Una dependencia del análisis falla|El SISTEMA registra el incidente, no marca el análisis como exitoso y solicita reintento cuando el entorno se estabilice.

---

## 7. POSTCONDICIONES

- **Éxito:** Los hallazgos quedan registrados y disponibles para seguimiento.
- **Fallo:** No se generan resultados nuevos y la plataforma conserva la última ejecución válida indicando el error actual.

---

## 8. REQUISITOS ESPECIALES

- Los mensajes al actor deben diferenciar entre hallazgos críticos, altos, medios y bajos.
- El sistema debe mantener un registro de la fecha de ejecución y del responsable que inició el análisis.

