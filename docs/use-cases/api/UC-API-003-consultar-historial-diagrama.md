# UC-API-003: Consultar historial de diagramas

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-003
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-003|
|**Nombre**|Consultar historial de diagramas|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|AUTOR FUNCIONAL, REVISOR DE SEGURIDAD|
|**Frecuencia estimada**|Media|
|**Prioridad**|Alta — habilita auditoría y trazabilidad de versiones|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Entregar al actor una vista cronológica de cambios y permitir acceder a versiones específicas para su revisión.
- **Resultado esperado:** El AUTOR FUNCIONAL o el REVISOR DE SEGURIDAD pueden consultar y comparar versiones sin manipular archivos directamente.
- **Alcance incluye:**
  - ✅ Listar versiones con metadatos relevantes (autor, fecha, descripción).
  - ✅ Proporcionar el contenido de una versión seleccionada.
  - ✅ Permitir comparar dos versiones desde la UI.
- **Fuera de alcance:**
  - ❌ Modificar o eliminar versiones existentes.
  - ❌ Definir criterios de aprobación (cubre gobernanza externa).

---

## 3. PRECONDICIONES

- El diagrama consultado existe en el repositorio histórico.
- El actor posee permisos de lectura sobre el proyecto.
- El sistema puede acceder al almacenamiento que contiene versiones y descripciones.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Solicita la lista de versiones asociadas a un diagrama.
|2|SISTEMA|Recupera el historial ordenado y adjunta metadatos visibles.
|3|SISTEMA|Devuelve la colección para que el actor seleccione una versión.
|4|SERVICIO DE UI|Solicita el contenido de la versión elegida.
|5|SISTEMA|Proporciona el contenido y confirma que no se altera el historial.
|6|SERVICIO DE UI|Opcionalmente solicita la comparación entre dos versiones.
|7|SISTEMA|Entrega el resultado comparativo resaltando diferencias observables.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El historial está vacío|El SISTEMA devuelve una colección vacía indicando que no existen registros aún.
|FA-02|La comparación se solicita con versiones idénticas|El SISTEMA notifica que no hay diferencias y evita procesar pasos adicionales.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|La versión seleccionada no existe|El SISTEMA informa la ausencia del recurso y mantiene el historial sin cambios.
|FE-02|Los metadatos están corruptos|El SISTEMA rechaza la entrega, registra el incidente y sugiere contactar a OPERACIONES DE PLATAFORMA.

---

## 7. POSTCONDICIONES

- **Éxito:** El actor obtiene la información necesaria para auditar cambios y preparar decisiones.
- **Fallo:** No se entrega información y se conserva el historial sin alteraciones, dejando evidencia del error.

---

## 8. REQUISITOS ESPECIALES

- Las respuestas deben estar ordenadas de la versión más reciente a la más antigua para facilitar el análisis.
- Cada versión debe incluir referencias únicas que permitan ejecutar rollback u otras acciones posteriores.
- La comparación debe enfocarse en diferencias visibles para el actor, evitando detalles internos de almacenamiento.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-001.
- **Artefactos complementarios:** No aplica (diagramas de historial pendientes de documentar).
- **Notas adicionales:** Complementa los flujos de versionado (UC-API-001) y restauración (UC-API-004).

