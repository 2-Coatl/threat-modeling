# UC-UI-005: Administrar versiones desde la UI

**Sistema:** Threat Modeling UI
**Caso de Uso:** UC-UI-005
**Versión:** 1.0
**Fecha:** 2025-10-29

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-UI-005|
|**Nombre**|Administrar versiones desde la UI|
|**Actor primario**|AUTOR FUNCIONAL|
|**Actores de soporte**|SERVICIO DE API, REPOSITORIO GIT|
|**Frecuencia estimada**|Semanal|
|**Prioridad**|Media — habilita trazabilidad y control de cambios|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que el AUTOR FUNCIONAL revise el historial del modelo, compare versiones y ejecute acciones de restauración o branching sin abandonar la UI.
- **Resultado esperado:** El autor identifica diferencias entre commits, aplica la versión deseada y mantiene el modelo actualizado conforme al flujo de trabajo colaborativo.
- **Alcance incluye:**
  - ✅ Consultar la línea de tiempo de commits y metadatos relevantes.
  - ✅ Comparar versiones lado a lado con resaltado de cambios y diagramas derivados.
  - ✅ Restaurar, crear ramas y fusionar cambios controlados desde la UI.
- **Fuera de alcance:**
  - ❌ Resolver manualmente conflictos complejos (se delega a herramientas especializadas).
  - ❌ Aprobar despliegues o integraciones externas (cubierto en procesos DevOps).

---

## 3. PRECONDICIONES

- El modelo cuenta con al menos un commit previo en el repositorio Git.
- El AUTOR FUNCIONAL posee permisos de edición sobre el modelo.
- La API expone endpoints de historial, comparación, rollback, branching y merge operativos.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|AUTOR FUNCIONAL|Abre el modelo y selecciona la pestaña "Historial".| 
|2|SISTEMA|Solicita el historial a la API y presenta la línea de tiempo con commits, autor, fecha y mensaje.| 
|3|AUTOR FUNCIONAL|Elige dos commits y pulsa "Comparar".| 
|4|SISTEMA|Muestra diff de código resaltado, lista de elementos agregados/modificados/eliminados y miniaturas de diagramas generados.| 
|5|AUTOR FUNCIONAL|Decide restaurar una versión anterior mediante el botón "Restaurar".| 
|6|SISTEMA|Solicita rollback a la API, actualiza el lienzo y confirma la creación de un nuevo commit con la restauración.| 
|7|AUTOR FUNCIONAL|Crea una rama "experimental" desde el commit seleccionado y cambia el selector de rama en la UI.| 
|8|SISTEMA|Actualiza el contexto del editor, muestra la rama activa y sincroniza el guardado en la nueva rama.| 
|9|AUTOR FUNCIONAL|Desde la rama secundaria, solicita "Fusionar en principal".| 
|10|SISTEMA|Invoca el merge, valida que no existan conflictos y confirma el nuevo commit resultante en la rama principal.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El AUTOR FUNCIONAL solo requiere visualizar el diff sin diagramas|El SISTEMA permite ocultar la sección gráfica para enfocarse en el código.| 
|FA-02|Durante el merge se detectan conflictos menores|El SISTEMA informa los archivos afectados y ofrece descargar el diff para resolución manual.| 
|FA-03|Se desea exportar el resultado de la comparación|El SISTEMA genera un archivo Markdown con el resumen de cambios y enlaces a los commits.| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El historial no puede cargarse|El SISTEMA muestra mensaje de error, registra el evento y ofrece reintentar la consulta.| 
|FE-02|El rollback falla por indisponibilidad de Git|El SISTEMA mantiene la versión actual, alerta al usuario y registra la incidencia en la actividad.| 
|FE-03|El merge genera conflictos irreconciliables|El SISTEMA cancela la operación, indica que se requiere intervención de DevOps y mantiene las ramas intactas.| 

---

## 7. POSTCONDICIONES

- **Éxito:** El modelo queda en la versión o rama seleccionada, la UI refleja el commit resultante y el historial registra la acción realizada.
- **Fallo:** No se aplican cambios; el usuario continúa en la versión previa con notificación del motivo.

---

## 8. REQUISITOS ESPECIALES

- Mostrar indicadores visuales de la rama activa en el encabezado del editor.
- Permitir copiar el hash del commit y el nombre de la rama desde la interfaz sin acciones adicionales.
- Registrar en la actividad del modelo cada comparación, rollback, creación de rama y merge ejecutados.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-API-004, UC-API-008, UC-API-013, UC-UI-001.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Coordinar mensajes de confirmación con el manual de operación para rollbacks y merges.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-UI-005-01|Agregar capturas de la vista de comparación y del selector de ramas al manual de usuario.|Pendiente|Documentación|
|TD-UI-005-02|Documentar la política de nomenclatura de ramas sugerida por el equipo de arquitectura.|Pendiente|Producto|
