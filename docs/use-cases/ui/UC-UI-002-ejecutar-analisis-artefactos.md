# UC-UI-002: Ejecutar análisis y generar artefactos

**Sistema:** Threat Modeling UI (React shell)
**Caso de Uso:** UC-UI-002
**Versión:** 0.1
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-UI-002|
|**Nombre**|Ejecutar análisis y generar artefactos|
|**Prioridad**|🟢 Alta|
|**Actores**|• Autor funcional<br>• Analista de seguridad|
|**Tipo**|Ejecución asistida|
|**Frecuencia de Uso**|Semanal|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Permitir a los usuarios lanzar análisis pytm, generar renders PlantUML y
solicitar artefactos adicionales desde la UI, orquestando los casos de uso
`UC-API-005`, `UC-API-006` y `UC-API-007`.

### 2.2 Objetivo

- Ejecutar pipelines de análisis y visualizar progreso.
- Descargar diagramas y reportes generados.
- Registrar trazabilidad de ejecuciones (timestamp, autor, versión base).

### 2.3 Alcance

Cubre la futura sección de "Análisis" dentro del shell React (`ui/src/modules/analysis/`)
y la coordinación con el estado global (`ui/src/state/store.js`).

---

## 3. PRECONDICIONES

1. Existe una versión aprobada del diagrama.
2. La API expone los servicios de análisis y generación en el entorno activo.
3. El usuario posee permisos de ejecución configurados en la plataforma.

---

## 4. FLUJO PRINCIPAL

1. El usuario selecciona "Ejecutar análisis" desde la UI.
2. La UI invoca el endpoint de análisis (`UC-API-007`) y muestra progreso.
3. Una vez completado, la UI ofrece enlaces a diagramas renderizados (`UC-API-005`).
4. El usuario descarga artefactos adicionales (`UC-API-006`).
5. La UI registra el resultado en un panel de ejecuciones recientes.

---

## 5. EXCEPCIONES RELEVANTES

- **FE-01:** Error de ejecución → Mostrar resumen y permitir reintento.
- **FE-02:** Artefacto faltante → Marcar tarjeta en rojo y ofrecer acción de regenerar.
- **FE-03:** Tiempo de espera excedido → Notificar al usuario y dejar ejecución en cola para seguimiento manual.

---

## 6. REQUISITOS FUNCIONALES DESTACADOS

|ID|Descripción|
|--|-----------|
|RF-01|Mostrar estados intermedios (en progreso, completado, error) en tiempo real.|
|RF-02|Permitir descargas individuales y empaquetadas de los artefactos generados.|
|RF-03|Registrar bitácora de ejecuciones en `localStorage` para recuperar contexto tras refrescar la página.|

---

## 7. REQUISITOS NO FUNCIONALES

- El panel debe reaccionar en < 500 ms ante actualizaciones provenientes de WebSocket o pooling.
- Los enlaces de descarga deben validar integridad mediante hashes expuestos por la API.
- Debe funcionar con navegadores modernos (Chrome, Firefox, Edge) en sus últimas dos versiones.

---

## 8. RELACIONES

|Relación|Documento|
|---|---|
|Depende de|`docs/use-cases/UC-API-005-renderizar-modelo-pytm.md`|
|Depende de|`docs/use-cases/UC-API-006-generar-artefactos-plantuml.md`|
|Depende de|`docs/use-cases/UC-API-007-analizar-amenazas-pytm.md`|

---

## 9. PENDIENTES

- Definir componente `ui/src/modules/analysis/AnalysisPanel.jsx` y su contrato de datos.
- Alinear con infraestructura el mecanismo de notificación (WebSocket vs pooling).
