# UC-API-002: Previsualizar diagrama

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-002
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-002|
|**Nombre**|Previsualizar diagrama|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|AUTOR FUNCIONAL|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Media — previene guardados con errores de formato|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Ofrecer al AUTOR FUNCIONAL una vista previa del diagrama antes de confirmarlo en el historial.
- **Resultado esperado:** El actor conoce si el modelo es válido y visualiza el render resultante sin alterar versiones existentes.
- **Alcance incluye:**
  - ✅ Validar sintaxis del modelo recibido.
  - ✅ Generar una imagen temporal para revisión.
  - ✅ Informar cualquier inconsistencia detectable.
- **Fuera de alcance:**
  - ❌ Guardar cambios permanentes o generar historial.
  - ❌ Lanzar análisis de amenazas.

---

## 3. PRECONDICIONES

- El SERVICIO DE UI mantiene una sesión válida.
- El AUTOR FUNCIONAL dispone del contenido actualizado que desea validar.
- Los servicios de renderizado se encuentran disponibles.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía el modelo propuesto solicitando una vista previa.
|2|SISTEMA|Evalúa la solicitud y confirma que la sesión es válida.
|3|SISTEMA|Procesa el modelo y produce una imagen temporal del diagrama.
|4|SISTEMA|Devuelve la previsualización indicando que no se realizaron cambios persistentes.
|5|SERVICIO DE UI|Muestra el resultado al AUTOR FUNCIONAL para su revisión.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Se detectan advertencias no bloqueantes|El SISTEMA entrega la imagen junto con las advertencias para que el AUTOR FUNCIONAL valore ajustes.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El modelo es inválido|El SISTEMA rechaza la solicitud, describe el error y no genera la imagen.
|FE-02|El servicio de renderizado no responde|El SISTEMA informa indisponibilidad temporal y sugiere reintentar luego.

---

## 7. POSTCONDICIONES

- **Éxito:** El AUTOR FUNCIONAL dispone de la imagen previa y puede decidir si guarda la versión.
- **Fallo:** No se crea contenido nuevo; se conserva el estado previo y se registra el motivo del error.

---

## 8. REQUISITOS ESPECIALES

- La respuesta debe expirar automáticamente; no puede reutilizarse como versión oficial.
- Los mensajes deben ser comprensibles para perfiles no técnicos.

