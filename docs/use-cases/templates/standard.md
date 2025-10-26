# UC-XXX: <TÍTULO DEL CASO DE USO>

> ⚠️ Los casos de uso se documentan como narrativas textuales. Los diagramas UML
> y otros artefactos visuales deben mantenerse aparte y referenciarse desde la
> sección de trazabilidad.

**Sistema:** <Nombre del sistema>
**Caso de Uso:** UC-XXX
**Versión:** <versión>
**Fecha:** <AAAA-MM-DD>

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-XXX|
|**Nombre**|<Verbo + Objeto>|
|**Actor primario**|<ACTOR PRINCIPAL EN MAYÚSCULAS>|
|**Actores de soporte**|<ACTORES SECUNDARIOS EN MAYÚSCULAS (si aplican)>|
|**Frecuencia estimada**|<Alta/Media/Baja>|
|**Prioridad**|<Alta/Media/Baja + justificación breve>|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** <Explica el valor que obtiene el actor.>
- **Resultado esperado:** <Describe el estado observable tras completar el caso de uso.>
- **Alcance incluye:**
  - ✅ <Actividad cubierta>
- **Fuera de alcance:**
  - ❌ <Actividad excluida>

---

## 3. PRECONDICIONES

- <Precondición 1>
- <Precondición 2>

Si alguna precondición no aplica, indícalo explícitamente.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|<ACTOR>|<Acción o intención del actor>|
|2|<SISTEMA>|<Respuesta observable del sistema>|
|...|...|...|

Describe únicamente lo que se percibe externamente: mensajes, validaciones visibles,
cambios de estado consultables, etc.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|<Condición detectable>|<Secuencia resumida desde la perspectiva del actor>|

Agrega filas adicionales para cada variación relevante. Si no existen, consigna "No
se identifican flujos alternos".

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|<Evento>|<Cómo se notifica al actor y qué ocurre con el caso de uso>|

---

## 7. POSTCONDICIONES

- **Éxito:** <Estado del sistema y del actor tras completar el flujo principal.>
- **Fallo:** <Estado cuando el caso de uso termina sin éxito.>

---

## 8. REQUISITOS ESPECIALES

Registra atributos de calidad, reglas de negocio o restricciones que afectan la
interacción desde la perspectiva del actor.

- <Requisito especial 1>
- <Regla de negocio relevante>

Si no existen, indicar "No aplica".

---

## 9. REFERENCIAS Y TRAZABILIDAD

Añade la información que vincula este caso de uso con otros artefactos.

- **Casos de uso relacionados:** <UC-XXX-... o "No aplica">.
- **Artefactos complementarios:** <Diagramas, mockups, etc., con enlace relativo o "No aplica">.
- **Notas adicionales:** <Observaciones de trazabilidad o estado>.
