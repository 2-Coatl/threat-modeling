# UC-UI-001: Diseñar modelos visuales

**Sistema:** Threat Modeling UI
**Caso de Uso:** UC-UI-001
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-UI-001|
|**Nombre**|Diseñar modelos visuales|
|**Actor primario**|AUTOR FUNCIONAL|
|**Actores de soporte**|SERVICIO DE API, EDITOR VISUAL|
|**Frecuencia estimada**|Diaria|
|**Prioridad**|Alta — habilita la captura colaborativa de modelos|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que el AUTOR FUNCIONAL cree y edite modelos de amenazas mediante el editor visual con sincronización de código Python.
- **Resultado esperado:** El autor guarda un modelo actualizado con nodos, flujos y código consistente listo para su análisis posterior.
- **Alcance incluye:**
  - ✅ Crear un modelo vacío y definir metadatos iniciales.
  - ✅ Manipular elementos (nodos, flujos) en el lienzo y mantener historial de cambios.
  - ✅ Generar y revisar el código Python asociado.
- **Fuera de alcance:**
  - ❌ Ejecutar análisis de amenazas (cubierto por UC-UI-002).
  - ❌ Gestionar permisos de acceso (cubierto por UC-UI-003).

---

## 3. PRECONDICIONES

- El AUTOR FUNCIONAL está autenticado (UC-UI-004) y posee permisos de edición.
- Existen plantillas y catálogos de elementos configurados en el editor visual.
- El servicio de generación de código se encuentra disponible.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|AUTOR FUNCIONAL|Selecciona "Nuevo modelo" e ingresa nombre, descripción y etiquetas.|
|2|SISTEMA|Crea el modelo vacío, muestra el lienzo y confirma el guardado inicial.|
|3|AUTOR FUNCIONAL|Arrastra elementos desde la paleta al lienzo, posicionándolos según el proceso.|
|4|SISTEMA|Añade los nodos, abre el panel de propiedades y refleja cambios en el código generado.|
|5|AUTOR FUNCIONAL|Edita propiedades en el panel lateral (por ejemplo nombre, atributos de seguridad) y observa la actualización inmediata del código.|
|6|SISTEMA|Propaga los cambios al nodo seleccionado, recalcula el script Python y mantiene la vista sincronizada.|
|7|AUTOR FUNCIONAL|Conecta nodos para definir flujos de datos y describe el canal (protocolo, puertos, cifrado).|
|8|SISTEMA|Dibuja las conexiones, actualiza el Python asociado y muestra la relación en el panel de detalles.|
|9|AUTOR FUNCIONAL|Selecciona elementos obsoletos y los elimina confirmando la acción para limpiar el modelo.|
|10|SISTEMA|Retira el nodo y aristas relacionadas, recalcula el código y muestra un mensaje de confirmación.|
|11|AUTOR FUNCIONAL|Solicita guardar el progreso proporcionando un resumen del cambio.|
|12|SISTEMA|Valida el modelo, persiste la versión y notifica que el guardado fue exitoso.|
|13|AUTOR FUNCIONAL|Utiliza los controles de deshacer/rehacer para revisar modificaciones recientes.|
|14|SISTEMA|Restaura el estado solicitado y recalcula el código antes de regresar al lienzo actual.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El AUTOR FUNCIONAL importa un archivo JSON existente|El SISTEMA carga el contenido, reconstruye el lienzo y continúa desde el Paso 4.| 
|FA-02|El AUTOR FUNCIONAL edita directamente el código|El SISTEMA advierte que la sincronización es unidireccional, mantiene la advertencia visible y solo actualiza el panel de código.|
|FA-03|El AUTOR FUNCIONAL intenta eliminar un nodo con dependencias críticas|El SISTEMA muestra advertencia, lista los flujos relacionados y permite cancelar la eliminación.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|La validación del modelo falla|El SISTEMA resalta los elementos con errores y mantiene el modo edición hasta corregirlos.| 
|FE-02|Se pierde conexión con la API|El SISTEMA guarda un borrador local, muestra mensaje de desconexión y ofrece reintentar el guardado.| 
|FE-03|El guardado genera un error en Git|El SISTEMA notifica la falla, sugiere reintentar y registra el incidente en la actividad del modelo.|

---

## 7. POSTCONDICIONES

- **Éxito:** El modelo queda guardado con su visualización y código sincronizados; el historial registra la versión creada.
- **Fallo:** Se conserva la última versión válida y el sistema deja constancia del motivo de la interrupción.

---

## 8. REQUISITOS ESPECIALES

- El lienzo debe soportar teclado y mouse, con accesos directos configurables.
- Las operaciones de arrastrar y soltar deben incluir ayudas visuales (snaplines, resaltado de objetivos).
- El código generado debe incluir cabecera con fecha y nombre del modelo para trazabilidad.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-004, UC-API-001, UC-API-004, UC-API-008, UC-API-010, UC-API-015.
- **Artefactos complementarios:** [`docs/architecture/visual-editor.md`](../../architecture/visual-editor.md).
- **Notas adicionales:** Mantener consistencia con los lineamientos del componente `ThreatModelCanvas` documentados en la guía de UI.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-UI-001-01|Describir atajos de teclado y gestos táctiles admitidos por el editor.|Pendiente|UX|
|TD-UI-001-02|Agregar referencia visual de los estados de nodos (seleccionado, con error).|Pendiente|Producto|
