# UC-API-000: Operar flujo de modelado

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-000
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-000|
|**Nombre**|Operar flujo de modelado|
|**Actor primario**|AUTOR FUNCIONAL|
|**Actores de soporte**|SERVICIO DE UI, OPERACIONES DE PLATAFORMA|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Alta — habilita el ciclo completo de modelado colaborativo|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que el AUTOR FUNCIONAL capture, revise y publique un modelo de amenazas completo desde una sola experiencia.
- **Resultado esperado:** El modelo queda registrado con historial disponible y artefactos listos para revisión por seguridad.
- **Alcance incluye:**
  - ✅ Crear o actualizar el modelo base y solicitar confirmación visual.
  - ✅ Guardar versiones con metadatos de trazabilidad.
  - ✅ Desencadenar el análisis de amenazas y recibir los resultados para su revisión.
- **Fuera de alcance:**
  - ❌ Mantener dependencias de infraestructura (servidores, librerías).
  - ❌ Diseñar controles técnicos derivados del análisis.

---

## 3. PRECONDICIONES

- El AUTOR FUNCIONAL inició sesión en la UI y posee permisos de edición.
- El sistema cuenta con conectividad hacia los servicios de renderizado y análisis.
- Existe espacio disponible para almacenar historial y artefactos generados.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|AUTOR FUNCIONAL|Abre el editor y carga el modelo vigente o crea uno nuevo.
|2|SISTEMA|Muestra el contenido almacenado y confirma que la sesión está activa.
|3|AUTOR FUNCIONAL|Solicita una previsualización para validar que el modelo es consistente.
|4|SISTEMA|Genera la previsualización y notifica si existen problemas visibles.
|5|AUTOR FUNCIONAL|Confirma el guardado del modelo y proporciona una descripción del cambio.
|6|SISTEMA|Persiste la nueva versión con los metadatos de autoría y registra el evento en el historial.
|7|AUTOR FUNCIONAL|Lanza el análisis de amenazas sobre la versión recién guardada.
|8|SISTEMA|Ejecuta el análisis, prepara los artefactos asociados y comunica los hallazgos disponibles.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|La previsualización identifica errores de sintaxis|El SISTEMA informa el error; el AUTOR FUNCIONAL corrige el modelo y regresa al Paso 3.
|FA-02|El análisis genera observaciones de severidad alta|El SISTEMA entrega el listado de hallazgos y mantiene la versión activa para que el AUTOR FUNCIONAL evalúe ajustes antes de publicar.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|No es posible almacenar la versión|El SISTEMA informa la falla, conserva la versión previa activa y solicita contactar a OPERACIONES DE PLATAFORMA.
|FE-02|Los servicios de análisis no responden|El SISTEMA detiene el proceso, registra el incidente y advierte al AUTOR FUNCIONAL que el análisis deberá reintentarse.

---

## 7. POSTCONDICIONES

- **Éxito:** El historial refleja la nueva versión del modelo con sus metadatos y los artefactos de análisis quedan disponibles para su consulta.
- **Fallo:** Se mantiene la última versión consistente sin modificaciones y se documenta la causa del fallo para seguimiento.

---

## 8. REQUISITOS ESPECIALES

- Las notificaciones deben indicar con claridad qué pasos seguir cuando existan errores de modelado.
- Los registros de auditoría deben conservar quién ejecutó cada acción y cuándo se realizaron.
- La plataforma debe exponer el estado del análisis (en progreso, completo, fallido) sin requerir acceso a consola técnica.

