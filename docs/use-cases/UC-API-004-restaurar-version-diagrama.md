# UC-API-004: Restaurar versión de diagrama

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-004
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-004|
|**Nombre**|Restaurar versión de diagrama|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|AUTOR FUNCIONAL, REVISOR DE SEGURIDAD|
|**Frecuencia estimada**|Baja|
|**Prioridad**|Media — garantiza la posibilidad de revertir cambios dañinos|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Recuperar una versión previa del diagrama cuando la actual presenta errores o necesita revisión posterior.
- **Resultado esperado:** El historial registra la restauración y deja activa la versión seleccionada para continuar el análisis.
- **Alcance incluye:**
  - ✅ Seleccionar la versión objetivo a restaurar.
  - ✅ Guardar la versión restaurada como la más reciente con anotaciones de auditoría.
  - ✅ Confirmar al actor que el contenido se revirtió exitosamente.
- **Fuera de alcance:**
  - ❌ Resolver conflictos de contenido cuando hay ediciones simultáneas (gestionados por gobernanza de equipo).
  - ❌ Eliminar versiones del historial.

---

## 3. PRECONDICIONES

- Existe un historial con al menos una versión anterior disponible.
- El actor cuenta con permisos de edición sobre el diagrama.
- El repositorio histórico acepta nuevas escrituras para registrar la restauración.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Solicita restaurar una versión específica identificada por el actor.
|2|SISTEMA|Confirma permisos y existencia de la versión seleccionada.
|3|SISTEMA|Recupera el contenido asociado y lo copia como la versión más reciente.
|4|SISTEMA|Anota en el historial que la acción corresponde a una restauración, incluyendo quién la solicitó y por qué.
|5|SISTEMA|Responde con el identificador de la nueva versión restaurada.
|6|SERVICIO DE UI|Informa al AUTOR FUNCIONAL que el diagrama volvió al estado solicitado.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|La versión actual ya coincide con la solicitada|El SISTEMA avisa que no se requieren cambios y mantiene el estado.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|La versión solicitada no existe|El SISTEMA rechaza la restauración y orienta al actor para seleccionar una versión válida.
|FE-02|Falla el guardado de la versión restaurada|El SISTEMA informa la falla, conserva la versión previa y sugiere reintentar tras soporte técnico.

---

## 7. POSTCONDICIONES

- **Éxito:** El historial incorpora una entrada que marca la restauración y el diagrama activo refleja el contenido elegido.
- **Fallo:** El diagrama permanece sin cambios y se registra la razón del fallo para seguimiento.

---

## 8. REQUISITOS ESPECIALES

- Las restauraciones deben quedar claramente identificadas para auditoría futura.
- Los mensajes al actor deben explicar el impacto de la restauración en versiones posteriores.

