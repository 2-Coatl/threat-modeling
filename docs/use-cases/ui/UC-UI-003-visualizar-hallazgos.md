# UC-UI-003: Visualizar hallazgos y compartir resultados

**Sistema:** Threat Modeling UI (React shell)
**Caso de Uso:** UC-UI-003
**Versión:** 0.1
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-UI-003|
|**Nombre**|Visualizar hallazgos y compartir resultados|
|**Prioridad**|🟡 Media|
|**Actores**|• Auditor<br>• Stakeholder de negocio|
|**Tipo**|Consumo de información|
|**Frecuencia de Uso**|Variable|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Presentar los hallazgos de amenazas y los artefactos generados por la API en una
experiencia navegable que facilite el seguimiento y la comunicación.

### 2.2 Objetivo

- Destacar hallazgos críticos y altos con indicadores visuales.
- Permitir la descarga y el uso compartido de reportes renderizados.
- Mantener la sincronización con el historial de versiones analizadas.

### 2.3 Alcance

Comprende las vistas de reportes y tableros proyectadas para `ui/src/modules/reports/`
y su integración con plantillas bajo `api/templates/` cuando corresponda.

---

## 3. PRECONDICIONES

1. Existen resultados disponibles generados por `UC-API-009`.
2. El usuario dispone de permisos de lectura para el proyecto.
3. La configuración de rutas públicas (`outputs-url`) está sincronizada con la UI.

---

## 4. FLUJO PRINCIPAL

1. La UI muestra la lista de hallazgos recientes con filtros por severidad.
2. El usuario selecciona un hallazgo y revisa el resumen en la misma vista.
3. Desde la UI se abre el reporte detallado hospedado por la API (`UC-API-009`).
4. El usuario copia o comparte enlaces públicos habilitados por infraestructura.

---

## 5. EXCEPCIONES RELEVANTES

- **FE-01:** Reporte no disponible → Mostrar mensaje y ofrecer regenerar análisis.
- **FE-02:** Enlace público inhabilitado → Notificar configuración faltante en infraestructura.
- **FE-03:** Hallazgos sin contexto → Sugerir ejecutar nuevamente el análisis para refrescar datos.

---

## 6. REQUISITOS FUNCIONALES DESTACADOS

|ID|Descripción|
|--|-----------|
|RF-01|Permitir filtrar hallazgos por severidad, módulo y fecha de ejecución.|
|RF-02|Ofrecer exportación en CSV/JSON de la lista de hallazgos visible.|
|RF-03|Resaltar enlaces caducados o inválidos con mensajes accionables.|

---

## 7. REQUISITOS NO FUNCIONALES

- Cargar la vista de hallazgos en < 2 segundos considerando datasets de 200 filas.
- Garantizar accesibilidad AA (contrastes, uso de teclado, lector de pantalla).
- Proveer fallback cuando el navegador bloquea ventanas emergentes para reportes.

---

## 8. RELACIONES

|Relación|Documento|
|---|---|
|Depende de|`docs/use-cases/UC-API-009-presentar-hallazgos-analisis.md`|
|Relacionado con|`docs/use-cases/UC-API-003-consultar-historial-diagrama.md`|

---

## 9. PENDIENTES

- Diseñar componentes en `ui/src/modules/reports/` para tarjetas de hallazgos.
- Coordinar con equipo de infraestructura la publicación segura de reportes estáticos.
