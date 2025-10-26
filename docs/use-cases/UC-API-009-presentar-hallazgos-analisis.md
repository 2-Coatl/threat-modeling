# UC-API-009: PRESENTAR HALLAZGOS Y ARTEFACTOS DEL ANÁLISIS

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-009
**Versión:** 1.0
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-009|
|**Nombre**|Presentar hallazgos y artefactos del análisis|
|**Prioridad**|🟡 Alta|
|**Actores**|• Autor del modelo  
• Stakeholders de seguridad  
• UI de reportes/diagrama (`api/templates/diagrams.html`, `history.html`)|
|**Tipo**|Comunicación de resultados|
|**Frecuencia de Uso**|Media (tras cada ejecución de UC-API-003)|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Exponer de manera clara los resultados del análisis pytm al equipo, incluyendo reportes HTML, diagramas derivados y metadatos de versiones para facilitar la toma de decisiones. Este caso de uso completa el ciclo iniciado en UC-API-001/003 y alimenta la iteración documentada en UC-API-008.【F:api/output/README.md†L1-L23】【F:api/templates/diagrams.html†L1-L120】

### 2.2 Objetivo

- Publicar reportes HTML y diagramas generados en rutas accesibles vía Tomcat (`/outputs/`).
- Mostrar en la UI un resumen de amenazas (críticas/altas) y enlaces directos al reporte completo.
- Facilitar la descarga de diagramas y archivos PlantUML para revisiones externas.

### 2.3 Alcance

**Incluye:**

- ✅ Enumerar reportes disponibles en `api/output/reports/` y mostrarlos como enlaces desde la UI.【F:api/output/README.md†L3-L22】
- ✅ Mostrar tarjetas de diagramas con autor, timestamp y descripción recientes.【F:api/templates/index.html†L1-L120】
- ✅ Permitir que la UI consuma `outputs-url` configurado por infraestructura para compartir enlaces a stakeholders.
- ✅ Integrar el resumen de hallazgos con el historial para que los equipos sepan qué versión generó cada reporte.【F:api/templates/history.html†L1-L160】

**NO Incluye:**

- ❌ Generar reportes nuevos (eso ocurre en UC-API-003).
- ❌ Modificar archivos ya publicados; cualquier cambio implica una nueva ejecución del análisis.
- ❌ Controlar autenticación de Tomcat (configurado a nivel de despliegue).

### 2.4 Restricciones Especiales

1. Los reportes se sirven desde `/outputs/reports/` y deben mantenerse sincronizados con las versiones generadas por UC-API-003.【F:api/output/README.md†L3-L22】
2. Las vistas HTML emplean estilos estáticos; cualquier cambio visual debe preserva la legibilidad de hallazgos críticos.【F:api/templates/diagrams.html†L1-L120】
  3. El catálogo de diagramas debe reflejar la información de `metadata.json`; inconsistencias indican errores en UC-API-001/008.

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Reportes y diagramas generados por UC-API-003 existen en `api/output/`.
PRECOND-02: Tomcat o servidor equivalente expone `/outputs/` al equipo de seguridad.
PRECOND-03: UI sincroniza datos llamando a los endpoints de historial cuando se carga la vista.
```

### 3.2 Precondiciones del Usuario

```
PRECOND-04: Hallazgos listos para revisión (al menos un análisis completado).
PRECOND-05: Usuario autenticado en la UI o con acceso controlado al endpoint público.
PRECOND-06: Conocimiento del diagrama o reporte que desea inspeccionar.
```

### 3.3 Validación de Precondiciones

```
FUNCION validar_precondiciones_uc_api_009(diagrama):
    SI not existe_reporte(diagrama):
        RETORNAR error('No hay reportes generados')
    SI not existe_historial(diagrama):
        RETORNAR error('No hay versiones registradas')
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: Tras completar UC-API-003, la UI recarga la vista de diagramas.
PASO 2: Se muestran tarjetas con última versión, autor y resumen de hallazgos.
PASO 3: El usuario abre el detalle del diagrama y revisa enlaces a reportes HTML y diagramas SVG.
PASO 4: El equipo comparte la URL pública `/outputs/reports/<nombre>_report.html` con stakeholders externos.
PASO 5: Si se requieren cambios, se inicia UC-API-008 para registrar correcciones.
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION presentar_hallazgos(diagrama):
    historial = GET(f'/api/diagram/{diagrama}/history')
    reporte = construir_url_reporte(diagrama)
    diagramas = listar_archivos('api/output/diagrams', diagrama)
    renderizar_tarjeta(historial.latest, reporte, diagramas)
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Compartir reporte sin acceso a la UI

- Se entrega directamente la URL de Tomcat (`http://localhost:8080/outputs/reports/...`).

### FA-02: Descargar diagramas para documentación externa

- Los usuarios descargan archivos desde `api/output/diagrams/` para integrarlos en otros reportes corporativos.

### FA-03: Integración con notificaciones

- Un proceso adicional puede leer los metadatos y enviar alertas cuando existan hallazgos críticos.

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Reporte faltante

- Si el archivo HTML no existe, la UI indica que el análisis debe volver a ejecutarse.

### FE-02: Enlace roto

- Si Tomcat no expone `/outputs/`, se notifica a infraestructura; mientras tanto, se entrega el archivo local manualmente.

### FE-03: Metadatos inconsistentes

- Si la tarjeta muestra datos desactualizados, se re-sincroniza el historial desde UC-API-001/004 antes de compartir hallazgos.

---

## 7. POSTCONDICIONES

```
POST-01: Stakeholders acceden a reportes y diagramas actualizados.
POST-02: El equipo mantiene trazabilidad entre hallazgos, versiones y acciones correctivas.
POST-03: Se documenta qué artefactos se compartieron con qué audiencias.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: Solo se comparten reportes marcados como finales (post revisión de hallazgos críticos).
RN-002: Los enlaces públicos deben expirar o revocarse cuando el modelo cambie significativamente.
RN-003: Cualquier modificación visual en la UI debe preservar la visibilidad de la severidad del hallazgo.
```

---

## 9. MATRIZ DE TRAZABILIDAD

|Elemento|Fuente|Referencia|
|---|---|---|
|Publicación de reportes|Guía de salida|`api/output/README.md`|
|Listados UI|Plantillas HTML|`api/templates/index.html`, `api/templates/diagrams.html`, `api/templates/history.html`|
|Enlaces externos|Configuración de Tomcat|`infrastructure/bin/generate` (sección outputs) |

---

**Fin del Caso de Uso UC-API-009**
