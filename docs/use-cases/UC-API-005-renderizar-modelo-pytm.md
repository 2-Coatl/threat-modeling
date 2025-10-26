# UC-API-005: RENDERIZAR MODELOS PYTM CON PLANTWEB

**Sistema:** Threat Modeling Platform API  
**Caso de Uso:** UC-API-005  
**Versión:** 1.0  
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-005|
|**Nombre**|Renderizar modelos pytm con Plantweb|
|**Prioridad**|🟡 Alta|
|**Actores**|• Pipeline `tm-generate`<br>• Desarrolladores de modelos (`api/models`)|
|**Tipo**|Automatización / generación|
|**Frecuencia de Uso**|Alta (cada entrega de modelo)|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Transformar modelos escritos con la librería `pytm` en diagramas consumibles por la UI o por los endpoints REST, empleando las utilidades expuestas en `api.plantweb`.

### 2.2 Objetivo

- Cargar un modelo `pytm` desde `api/models`.
- Extraer el PlantUML de secuencia o DFD asociado.
- Renderizar los artefactos en formatos soportados (`svg`, `png`).
- Entregar rutas de salida listas para ser publicadas vía `/api/diagram/generate` o para distribución directa.

### 2.3 Alcance

**Incluye:**

- ✅ Uso de `render_pytm_model`/`render_pytm_seq` para generar diagramas con PlantUML Server.【F:api/plantweb/__init__.py†L18-L37】【F:api/plantweb/pytm_adapter.py†L66-L116】
- ✅ Persistir resultados en el árbol `api/output/diagrams/` siguiendo convenciones de nombre por modelo.【F:api/plantweb/pytm_adapter.py†L138-L205】
- ✅ Extraer únicamente el código PlantUML cuando se requiera una vista previa sin render (`get_pytm_plantuml_code`).【F:api/plantweb/pytm_adapter.py†L207-L245】

**NO Incluye:**

- ❌ Definir la estructura del modelo (se realiza en `api/models/*.py`).【F:api/models/README.md†L1-L31】
- ❌ Renderizar Data Flow Diagrams vía PlantUML; se mantiene el flujo nativo de `pytm` + Graphviz (`dot`).【F:api/plantweb/pytm_adapter.py†L43-L104】
- ❌ Gestionar publicación en Tomcat (cubierto por otros casos de uso de la API/UI).

### 2.4 Restricciones Especiales

1. `render_pytm_model` crea archivos por formato solicitado y reutiliza caché si se habilita `use_cache`.【F:api/plantweb/pytm_adapter.py†L150-L205】
2. La secuencia utiliza el servidor PlantUML configurado por Plantweb; el DFD se delega al pipeline nativo de `pytm` (error controlado si se intenta renderizarlo con Plantweb).【F:api/plantweb/pytm_adapter.py†L66-L116】【F:api/plantweb/pytm_adapter.py†L43-L104】
3. Las funciones requieren dependencias `requests` y `pytm` disponibles en el entorno.【F:api/plantweb/__init__.py†L1-L73】

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Plantweb configurado con URL de PlantUML (`configure()` o variables de entorno).
PRECOND-02: Paquetes `pytm`, `requests` y dependencias de Plantweb instalados.
PRECOND-03: Directorio de salida con permisos de escritura (`api/output/diagrams`).
```

### 3.2 Precondiciones del Usuario

```
PRECOND-04: Modelo `pytm` válido que implemente métodos `seq()` y/o `dfd()`.
PRECOND-05: Scripts o usuarios con permisos para ejecutar Python en el entorno `threatmodel`.
PRECOND-06: Definir formatos deseados (por defecto `['svg']`).
```

### 3.3 Validación de Precondiciones

**Pseudocódigo:**

```
FUNCION validar_precondiciones_uc_api_005(tm_model, output_dir):
    SI no hasattr(tm_model, 'seq') y no hasattr(tm_model, 'dfd'):
        RETORNAR error('Modelo pytm sin métodos seq/dfd')
    SI no output_dir.escribible():
        RETORNAR error('Directorio sin permisos de escritura')
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: Importar modelo pytm (ej. `from api.models.auth_model import tm`).
PASO 2: Configurar Plantweb con URL/formatos si se requiere.
PASO 3: Invocar `render_pytm_model(tm, output_dir, formats=['svg','png'])`.
PASO 4: Función genera secuencias (y otros formatos) usando PlantUML Server.
PASO 5: Retorna diccionario con rutas; pipeline continúa con publicación o versionado.
```

### 4.2 Pseudocódigo del Flujo Principal

```
from api.plantweb import configure, render_pytm_model
from api.models.auth_model import tm

configure(server_url='http://localhost:8080/plantuml/', format='svg')
resultados = render_pytm_model(
    tm_model=tm,
    output_dir='/vagrant/api/output/diagrams',
    formats=['svg', 'png']
)
for tipo, ruta in resultados.items():
    registrar_salida(tipo, ruta)
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Solo se requiere código PlantUML

```
1. Invocar `get_pytm_plantuml_code(tm)`.
2. Retornar diccionario con `seq`/`dfd` sin renderizar.
3. Entregar a `/api/diagram/preview` para validación temporal.
```

### FA-02: Render fallido por cache/servidor

```
1. `render()` lanza `RenderError` o `PytmError`.
2. Registro de error e interrupción del pipeline.
3. Solicitar reintento tras validar PlantUML Server.
```

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Modelo sin métodos requeridos

```
TRIGGER: tm_model carece de `seq()` y `dfd()`.
FLUJO:
    - `extract_plantuml_from_pytm` lanza `PytmError`.
    - Se registra el error y se notifica al autor del modelo.
    - Pipeline termina sin generar artefactos.
```

### FE-02: Permisos insuficientes en directorio

```
TRIGGER: No se puede escribir en output_dir.
FLUJO:
    - `Path.mkdir` falla o `render()` no puede crear archivo.
    - Se genera alerta para ajustar permisos antes de reintentar.
```

---

## 7. POSTCONDICIONES

### 7.1 Postcondiciones de Éxito

```
POST-01: Diagramas de secuencia generados en formatos solicitados.
POST-02: Diccionario de resultados disponible para procesos posteriores.
POST-03: Modelos pytm permanecen sin modificación.
```

### 7.2 Postcondiciones de Fallo

```
POST-FAIL-01: No se crean archivos de salida.
POST-FAIL-02: Se registran errores detallados para diagnóstico.
POST-FAIL-03: El pipeline de publicación se detiene hasta resolver el incidente.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: Los modelos pytm deben residir en `api/models` siguiendo convención `_model.py`.
RN-002: Los formatos solicitados deben ser compatibles con PlantUML Server (svg/png).
RN-003: DFD continúa utilizando Graphviz y no PlantUML (mantener scripts existentes).
RN-004: Los resultados deben conservarse bajo control de cambios junto con metadatos.
```

---

## 9. TRAZABILIDAD

|Requisito|Fuente|Sección|
|---|---|---|
|Integración Plantweb-pytm|Plantweb module|`api/plantweb/__init__.py`, `pytm_adapter.py`|
|Convención de modelos|Documentación de modelos|`api/models/README.md`|
|Persistencia de salidas|Implementación render|`api/plantweb/pytm_adapter.py`|

---

**FIN DEL CASO DE USO UC-API-005**
