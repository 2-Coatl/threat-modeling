# UC-API-005: Renderizar modelo pytm

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-005
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-005|
|**Nombre**|Renderizar modelo pytm|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|AUTOR FUNCIONAL, OPERACIONES DE PLATAFORMA|
|**Frecuencia estimada**|Media|
|**Prioridad**|Media — entrega visualizaciones auxiliares para el análisis|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Generar representaciones gráficas del modelo pytm asociado para apoyar la revisión del AUTOR FUNCIONAL y del REVISOR DE SEGURIDAD.
- **Resultado esperado:** Se producen los diagramas auxiliares (por ejemplo, DFD) y quedan disponibles para consulta.
- **Alcance incluye:**
  - ✅ Seleccionar el modelo pytm vigente.
  - ✅ Generar las imágenes necesarias para contextualizar el análisis.
  - ✅ Informar la ubicación donde pueden consultarse las salidas.
- **Fuera de alcance:**
  - ❌ Modificar el código pytm.
  - ❌ Ejecutar validaciones de amenazas (cubiertas por UC-API-007).

---

## 3. PRECONDICIONES

- El modelo pytm está vinculado al diagrama activo y se encuentra accesible.
- El entorno dispone de las herramientas requeridas para producir las visualizaciones.
- El actor cuenta con permisos para solicitar la generación.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Solicita la generación de visualizaciones para el modelo pytm asociado.
|2|SISTEMA|Verifica que el modelo existe y que puede procesarse.
|3|SISTEMA|Ejecuta la generación de diagramas auxiliares.
|4|SISTEMA|Guarda las salidas en la ubicación configurada para consultas posteriores.
|5|SISTEMA|Notifica que los artefactos están listos y dónde puede accederse a ellos.
|6|SERVICIO DE UI|Presenta los enlaces o previsualizaciones al AUTOR FUNCIONAL.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El modelo pytm tiene advertencias menores|El SISTEMA completa la generación e incluye las advertencias en la notificación.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|No se encuentra el modelo pytm|El SISTEMA detiene la operación e informa al actor que debe vincular un modelo válido.
|FE-02|Una dependencia de renderizado falla|El SISTEMA registra el incidente, cancela la generación y solicita soporte técnico.

---

## 7. POSTCONDICIONES

- **Éxito:** Los diagramas auxiliares quedan disponibles y asociados a la versión del modelo.
- **Fallo:** No se generan archivos nuevos y se mantienen las últimas salidas válidas documentando la causa del fallo.

---

## 8. REQUISITOS ESPECIALES

- Las salidas deben identificarse con la versión del modelo para evitar confusiones.
- Se debe informar el tiempo estimado de generación cuando exceda unos segundos.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-002, UC-API-007.
- **Artefactos complementarios:** No aplica (diagramas auxiliares se compartirán en anexos dedicados).
- **Notas adicionales:** Los artefactos producidos sirven de insumo para la revisión en UC-API-009.

