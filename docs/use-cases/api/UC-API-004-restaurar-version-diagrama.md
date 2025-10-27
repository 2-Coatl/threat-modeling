# UC-API-004: Actualizar modelos visuales

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-004
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-004|
|**Nombre**|Actualizar modelos visuales|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|BASE DE DATOS, REPOSITORIO GIT, CACHE DE DIAGRAMAS|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Alta — permite evolución continua del modelo|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Facilitar la actualización de modelos existentes, sincronizando cambios visuales y de código con la persistencia y el repositorio.
- **Resultado esperado:** La API valida y guarda las modificaciones, genera un nuevo commit y actualiza las referencias asociadas.
- **Alcance incluye:**
  - ✅ Validar la estructura del modelo y la sintaxis de código enviada en la actualización.
  - ✅ Persistir cambios y actualizar `updated_at` en base de datos.
  - ✅ Crear commit en Git y limpiar caches dependientes (diagramas, hallazgos).
- **Fuera de alcance:**
  - ❌ Gestión de conflictos de merge (cubierto en UC-API-008).
  - ❌ Modificación de permisos o compartidos (cubierto en UC-API-009).

---

## 3. PRECONDICIONES

- El modelo existe y el usuario cuenta con permisos de edición.
- El repositorio Git está disponible para escribir nuevos commits.
- Los caches de diagramas permiten invalidación mediante identificador de modelo.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía `PUT /api/models/{model_id}` con modelo visual actualizado y código Python generado.| 
|2|API|Valida el payload, compila el código y verifica consistencia de nodos y flujos.| 
|3|API|Actualiza el registro en `pytm_models` con el nuevo contenido y marca `updated_at=NOW()`.| 
|4|API|Escribe cambios en el archivo Python dentro del repositorio, crea commit y obtiene `new_commit_hash`.| 
|5|API|Limpia caches relacionados (`diagrams`, `threat_findings`) para que se regeneren con la nueva versión.| 
|6|API|Registra evento de auditoría `model_updated`.| 
|7|API|Responde `200 OK` con detalles del modelo actualizado y hash del commit.| 
|8|SERVICIO DE UI|Refresca la vista del modelo y notifica al usuario la confirmación del guardado.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El usuario solicita guardar sin cambios detectados|La API responde `200 OK` indicando "Sin cambios" y no crea un nuevo commit.| 
|FA-02|El payload incluye bandera `skip_git=true` para guardados temporales|La API guarda en base de datos, omite commit y marca el modelo como borrador pendiente.| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El código no compila|La API responde `400 Bad Request` señalando línea y error devuelto por el compilador.| 
|FE-02|El commit falla|La API revierte los cambios aplicados en base de datos y responde `500 Internal Server Error`.| 
|FE-03|El usuario no tiene permiso de edición|La API devuelve `403 Forbidden` y no altera la versión existente.| 

---

## 7. POSTCONDICIONES

- **Éxito:** El modelo queda actualizado, las cachés se invalidan y el historial Git refleja el nuevo commit.
- **Fallo:** No se aplica ningún cambio y se mantiene la versión anterior.

---

## 8. REQUISITOS ESPECIALES

- Incluir `new_commit_hash` y `previous_commit_hash` en la respuesta para trazabilidad.
- Registrar el tiempo que toma el guardado para indicadores de rendimiento.
- Emitir eventos de dominio (`model.updated`) para subsistemas interesados (p. ej. notificaciones).

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-001, UC-API-001, UC-API-008, UC-API-010.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Coordinado con el servicio de generación de diagramas para invalidar caches automáticamente.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-004-01|Documentar uso de bandera `skip_git` una vez que se defina el proceso de borradores.|Pendiente|Producto|
|TD-API-004-02|Agregar ejemplos de respuesta cuando se detecta "Sin cambios".|Pendiente|Documentación|
