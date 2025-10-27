# UC-UI-006: Orquestar revisión de arquitectura

**Sistema:** Threat Modeling Platform UI
**Caso de Uso:** UC-UI-006
**Versión:** 1.0
**Fecha:** 2025-10-29

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-UI-006|
|**Nombre**|Orquestar revisión de arquitectura|
|**Actor primario**|ARQUITECTA DE SEGURIDAD|
|**Actores de soporte**|SERVICIO DE UI, ORQUESTADOR DE MODELOS|
|**Frecuencia estimada**|Media|
|**Prioridad**|Alta — habilita la validación transversal de arquitectura y riesgos|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la ARQUITECTA DE SEGURIDAD consolide evidencia visual y analítica antes de aprobar la arquitectura de un modelo de amenazas.
- **Resultado esperado:** La UI presenta diagramas actualizados, hallazgos y actividad histórica para documentar la revisión.
- **Alcance incluye:**
  - ✅ Consultar diagramas DFD y de secuencia vigentes.
  - ✅ Ejecutar análisis de amenazas y revisar su resumen.
  - ✅ Auditar historial de cambios y descargas vinculadas.
  - ✅ Exportar artefactos para expediente de arquitectura.
- **Fuera de alcance:**
  - ❌ Editar directamente el modelo (cubierto por UC-UI-001 y UC-UI-005).
  - ❌ Aprobar implementaciones en herramientas externas.

---

## 3. PRECONDICIONES

- El modelo de amenazas fue compartido con permisos de lectura para la ARQUITECTA DE SEGURIDAD.
- Existen al menos versiones previas o artefactos generados para consulta.
- La sesión de la usuaria está autenticada (UC-UI-004).

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|ARQUITECTA DE SEGURIDAD|Accede al tablero de modelos y selecciona el modelo a revisar desde la lista filtrada por su nombre.|
|2|UI|Carga la vista del modelo mostrando metadatos, resumen de hallazgos recientes y accesos directos a diagramas y reportes.|
|3|ARQUITECTA DE SEGURIDAD|Solicita visualizar el DFD pulsando "Generar DFD" cuando detecta que no hay artefacto vigente.|
|4|UI|Invoca la API, muestra el estado "Generando" y luego presenta el DFD más reciente con controles de zoom y descarga.|
|5|ARQUITECTA DE SEGURIDAD|Cambia a la pestaña "Secuencia" para validar interacciones críticas.|
|6|UI|Recupera el diagrama de secuencia y lo renderiza en visor SVG con indicadores de última actualización.|
|7|ARQUITECTA DE SEGURIDAD|Ejecuta "Analizar amenazas" para obtener un reporte fresco y revisa las tarjetas de severidad.|
|8|UI|Muestra progreso de ejecución, refresca el resumen por severidad y despliega la lista de hallazgos ordenada.|
|9|ARQUITECTA DE SEGURIDAD|Abre el historial "Actividad" para confirmar los commits y acciones auditadas relevantes.|
|10|UI|Lista los eventos más recientes con autor, acción y timestamp, permitiendo navegación al detalle.|
|11|ARQUITECTA DE SEGURIDAD|Descarga el paquete de evidencia seleccionando "Exportar" → "PDF" para adjuntarlo al expediente.|
|12|UI|Genera el archivo solicitado, muestra la notificación de descarga y registra la acción en la bitácora.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Existe un DFD generado con el mismo hash de contenido|La UI omite el estado "Generando" y abre de inmediato el artefacto almacenado, indicando que proviene de caché.|
|FA-02|La ARQUITECTA solo requiere validar amenazas previas|Salta los pasos 3–6; inicia directamente el análisis (paso 7) y continúa el flujo sin revisar diagramas.|
|FA-03|El historial supera los 50 eventos recientes|La usuaria utiliza el filtro de fechas; la UI paginada muestra resultados por lote respetando el criterio aplicado.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|La usuaria no tiene permiso de lectura sobre el modelo|La UI muestra mensaje "Acceso denegado" y ofrece regresar al tablero sin exponer metadatos.|
|FE-02|Falla la generación del DFD o secuencia|Se presenta alerta con el detalle del error y enlace para reintentar; el flujo continúa disponible tras la corrección.|
|FE-03|El análisis de amenazas excede el tiempo límite|La UI muestra estado "Expirado" y mantiene el último resultado válido sin actualizar métricas.|

---

## 7. POSTCONDICIONES

- **Éxito:** El expediente de arquitectura queda respaldado con diagramas vigentes, reporte de amenazas y registro de actividad descargados desde la UI.
- **Fallo:** La usuaria identifica el incidente (permiso insuficiente o error de generación) y ningún artefacto se actualiza.

---

## 8. REQUISITOS ESPECIALES

- La UI debe resaltar la fecha de última generación en cada diagrama para facilitar decisiones de vigencia.
- Los reportes descargados deben incluir metadatos del modelo (nombre, autor, commit más reciente) visibles en la primera página.
- Los mensajes de error deben sugerir contacto con la mesa de arquitectura cuando la causa sea permisos insuficientes.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-002, UC-UI-003, UC-UI-005, UC-API-006, UC-API-007, UC-API-013, UC-API-014, UC-API-015.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Esta revisión alimenta el checklist de aprobación arquitectónica corporativa.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-UI-006-01|Agregar capturas de la vista combinada de diagramas y resumen de amenazas.|Pendiente|Equipo de producto|
|TD-UI-006-02|Definir plantilla estándar de reporte exportado para revisiones arquitectónicas.|Pendiente|Arquitectura empresarial|
