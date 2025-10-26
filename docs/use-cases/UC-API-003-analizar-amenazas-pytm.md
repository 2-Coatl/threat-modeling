# UC-API-003: ANALIZAR AMENAZAS CON PYTM Y GENERAR REPORTE

**Sistema:** Threat Modeling Platform API  
**Caso de Uso:** UC-API-003  
**Versión:** 1.0  
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-003|
|**Nombre**|Analizar amenazas con pytm y generar reporte|
|**Prioridad**|🟡 Alta|
|**Actores**|• Autor del modelo desde la UI  
• Servicio Python que ejecuta pytm (`api/plantweb` + `api/models`)  
• Motor de reportes HTML|
|**Tipo**|Evaluación / diagnóstico|
|**Frecuencia de Uso**|Media (por análisis completo)|
|**Complejidad**|Alta|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Validar un modelo PlantUML contra la lógica de seguridad definida en pytm, generar un conjunto de hallazgos STRIDE y producir un reporte HTML que sirva como evidencia para correcciones posteriores.【F:api/plantweb/__init__.py†L18-L73】【F:api/plantweb/pytm_adapter.py†L17-L245】

### 2.2 Objetivo

- Convertir el modelo de alto nivel (PlantUML o Python) en una instancia `TM` de pytm.
- Ejecutar `tm.process()` para enumerar amenazas y obtener resultados estructurados.【F:api/models/auth_model.py†L1-L221】
- Renderizar diagramas auxiliares (sequence/dfd) para acompañar el reporte.【F:api/plantweb/pytm_adapter.py†L134-L205】
- Generar un documento HTML con hallazgos y recomendaciones usando la plantilla oficial.【F:api/templates/report_template.md†L1-L92】

### 2.3 Alcance

**Incluye:**

- ✅ Extraer PlantUML desde un modelo pytm vía `get_pytm_plantuml_code` cuando el analista parte de Python.【F:api/plantweb/pytm_adapter.py†L219-L245】
- ✅ Ejecución de `tm.process()` para poblar amenazas y métricas del modelo.【F:api/models/auth_model.py†L212-L218】
- ✅ Elaboración del reporte HTML que se publica en `api/output/reports/` y se expone desde Tomcat.【F:api/output/README.md†L3-L22】
- ✅ Sincronización con UC-API-001 para almacenar la versión del diagrama utilizada como base del análisis.

**NO Incluye:**

- ❌ Autocorrección de hallazgos; el autor debe iterar manualmente en PlantUML (cubierto por UC-API-004).
- ❌ Gestión de credenciales o permisos del motor pytm (preconfigurados por infraestructura).
- ❌ Ejecución de pipelines CI/CD (documentado fuera de este caso de uso).

### 2.4 Restricciones Especiales

1. Los modelos deben residir en `api/models` y exponer un objeto `tm` válido.【F:api/models/README.md†L1-L32】
2. El análisis se ejecuta con los paquetes `pytm`, `graphviz`, `pydot` y `Pillow` instalados (ver registro de bootstrap compartido por infraestructura).
3. El reporte aprovecha `pandoc` para transformar Markdown en HTML; si el comando falla, se debe notificar al usuario para reintentar.【F:infrastructure/bin/generate†L374-L437】

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Entorno Python con pytm operativo (bibliotecas instaladas y verificadas).
PRECOND-02: Plantweb configurado para renderizar diagramas auxiliares si se solicitan.
PRECOND-03: Plantilla Markdown disponible (`api/templates/report_template.md`).
PRECOND-04: Directorios `api/output/diagrams/` y `api/output/reports/` con permisos de escritura.
```

### 3.2 Precondiciones del Usuario

```
PRECOND-05: Diagrama PlantUML guardado (UC-API-001) o modelo pytm actualizado en `api/models`.
PRECOND-06: Selección del modelo a analizar y formato deseado (HTML principal, SVG complementario).
PRECOND-07: Autorización para ejecutar análisis que pueden tardar varios segundos.
```

### 3.3 Validación de Precondiciones

```
FUNCION validar_precondiciones_uc_api_003(modelo):
    SI not existe(modelo):
        RETORNAR error('Modelo inexistente')
    SI not dependencia_instalada('pytm'):
        RETORNAR error('pytm no disponible')
    SI not directorios_permisos_correctos():
        RETORNAR error('No se puede escribir en output/')
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: La UI solicita "Analizar amenazas" sobre la versión aprobada del diagrama.
PASO 2: El backend identifica el modelo pytm relacionado (ej. `auth_model.py`).
PASO 3: Se ejecuta `tm.process()` para recolectar amenazas y métricas STRIDE.
PASO 4: Se generan diagramas de secuencia/DFD usando Plantweb cuando aplica.
PASO 5: Se construye un Markdown con hallazgos y se transforma a HTML mediante la plantilla.
PASO 6: El reporte y los diagramas se guardan en `api/output/` y se publican vía Tomcat.
PASO 7: La UI muestra un resumen de hallazgos críticos y enlace al reporte completo.
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION analizar_modelo(modelo):
    tm = importar_modelo(modelo)
    tm.process()
    hallazgos = tm.threats
    diagramas = render_pytm_model(tm, output_dir='api/output/diagrams')
    reporte = generar_reporte(tm, hallazgos, plantilla='api/templates/report_template.md')
    publicar_resultados(reporte, diagramas)
    RETORNAR resumen(hallazgos)
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Análisis solo para previsualización

- El usuario ejecuta `extract_plantuml_from_pytm` sin generar reporte completo para inspeccionar el PlantUML resultante.【F:api/plantweb/pytm_adapter.py†L17-L66】

### FA-02: Generación de secuencia únicamente

- Se invoca `render_pytm_seq` para obtener diagramas de secuencia específicos antes de ejecutar el análisis total.【F:api/plantweb/pytm_adapter.py†L106-L205】

### FA-03: Reintento tras fallas de dependencias

- Si `pandoc` o `graphviz` no están disponibles, se notifica al usuario y se ofrece un reintento una vez restauradas las herramientas.

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Modelo inválido

- Trigger: el objeto `tm` carece de métodos `seq()` o `dfd`.  
- Acción: se lanza `PytmError` y el usuario recibe una guía para completar la definición del modelo.【F:api/plantweb/pytm_adapter.py†L19-L117】

### FE-02: Reporte no generado

- Trigger: fallos al transformar Markdown a HTML.  
- Acción: se conserva el Markdown generado como respaldo y se solicita intervención manual.【F:infrastructure/bin/generate†L382-L437】

### FE-03: Amenazas inexistentes

- Trigger: `tm.process()` no produce hallazgos.  
- Acción: se marca el análisis como exitoso sin findings críticos y se documenta en el resumen.

---

## 7. POSTCONDICIONES

```
POST-01: Reporte HTML actualizado disponible en `api/output/reports/`.
POST-02: Diagramas complementarios generados en `api/output/diagrams/`.
POST-03: Hallazgos listos para mostrarse en la UI y para guiar correcciones.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: Cada análisis debe referenciar la versión de diagrama evaluada (commit de UC-API-001).
RN-002: Los hallazgos críticos requieren confirmación explícita antes de aprobar el modelo.
RN-003: Se deben conservar los reportes históricos para auditoría.
RN-004: Solo personal autorizado puede ejecutar análisis que generen reportes oficiales.
```

---

## 9. MATRIZ DE TRAZABILIDAD

|Elemento|Fuente|Referencia|
|---|---|---|
|Funciones pytm/Plantweb|Módulo Python|`api/plantweb/__init__.py`, `api/plantweb/pytm_adapter.py`|
|Modelos de referencia|Ejemplo pytm|`api/models/*.py`|
|Plantilla de reporte|Markdown base|`api/templates/report_template.md`|
|Pipeline de reporte|Script de apoyo|`infrastructure/bin/generate`|

---

**Fin del Caso de Uso UC-API-003**
