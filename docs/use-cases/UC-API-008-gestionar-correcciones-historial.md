# UC-API-008: Gestionar correcciones con historial

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-008
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-008|
|**Nombre**|Gestionar correcciones con historial|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|AUTOR FUNCIONAL|
|**Frecuencia estimada**|Media|
|**Prioridad**|Media — mantiene trazabilidad de ajustes sobre modelos existentes|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Registrar correcciones sobre versiones existentes del diagrama sin perder contexto histórico.
- **Resultado esperado:** Cada corrección queda asociada a comentarios y metadatos que permiten seguir la evolución del modelo.
- **Alcance incluye:**
  - ✅ Permitir comentarios y anotaciones sobre versiones específicas.
  - ✅ Marcar correcciones como pendientes o resueltas.
  - ✅ Actualizar el historial con referencias cruzadas.
- **Fuera de alcance:**
  - ❌ Definir políticas de aprobación (manejadas por gobernanza externa).
  - ❌ Modificar directamente el contenido del diagrama (cubre UC-API-001).

---

## 3. PRECONDICIONES

- Existe una versión del diagrama sobre la cual registrar la corrección.
- El AUTOR FUNCIONAL o el revisor correspondiente posee permisos para anotar cambios.
- El historial acepta registros adicionales.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Recibe la instrucción del AUTOR FUNCIONAL para registrar una corrección sobre una versión.
|2|SISTEMA|Valida que la versión y la corrección estén asociadas correctamente.
|3|SISTEMA|Registra la corrección con su estado inicial y la vincula a la versión correspondiente.
|4|SISTEMA|Notifica al actor que la corrección quedó registrada.
|5|SERVICIO DE UI|Permite actualizar el estado de la corrección a medida que el AUTOR FUNCIONAL incorpora ajustes.
|6|SISTEMA|Actualiza el historial reflejando el estado final (pendiente/resuelto) y quién realizó la acción.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|La corrección se marca como duplicada|El SISTEMA enlaza la corrección duplicada con la original y notifica que no requiere acciones nuevas.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Se intenta registrar una corrección sin contexto|El SISTEMA rechaza la solicitud e indica que debe seleccionarse una versión válida.
|FE-02|El historial no puede actualizarse|El SISTEMA informa la falla, no crea la corrección y sugiere reintentar tras soporte técnico.

---

## 7. POSTCONDICIONES

- **Éxito:** Las correcciones quedan documentadas con su estado y responsables.
- **Fallo:** No se crean registros nuevos y se preserva el historial sin cambios.

---

## 8. REQUISITOS ESPECIALES

- Las correcciones deben conservar la fecha y hora de cada actualización de estado.
- El sistema debe permitir filtrar correcciones por estado para facilitar su seguimiento.

