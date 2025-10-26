# UC-API-006: GENERAR ARTEFACTOS CON PLANTUML

**Sistema:** Threat Modeling Platform CLI / API Outputs  
**Caso de Uso:** UC-API-006  
**Versión:** 1.0  
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-006|
|**Nombre**|Generar artefactos con PlantUML|
|**Prioridad**|🟡 Alta|
|**Actores**|• Usuario "threatmodel" (o alias `tm-generate`)
• Script `infrastructure/bin/generate`
• Servicios auxiliares: Graphviz, PlantUML Server, Pandoc|
|**Tipo**|Procesamiento batch / publicación|
|**Frecuencia de Uso**|Alta (tras cada iteración relevante)|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Automatizar la creación de diagramas y reportes finales a partir de los modelos pytm, renderizando Diagramas de Flujo de Datos, Diagramas de Secuencia y reportes HTML listos para consumo en Tomcat usando la tubería oficial del proyecto.【F:infrastructure/bin/generate†L1-L193】【F:infrastructure/bin/generate†L259-L420】

### 2.2 Objetivo

- Ejecutar el script `tm-generate` que fuerza el contexto del usuario `threatmodel` y carga la configuración del proyecto antes de procesar modelos.【F:infrastructure/bin/generate†L22-L93】
- Validar dependencias críticas (`python3`, `dot`, `curl`, `pandoc`, `pytm`) y conectividad con PlantUML Server.【F:infrastructure/bin/generate†L154-L193】
- Descubrir modelos `*_model.py`, invocar pytm y producir salidas en `api/output/`.【F:infrastructure/bin/generate†L199-L339】【F:api/models/README.md†L9-L20】
- Dejar los artefactos servibles vía Tomcat bajo `/outputs/diagrams/` y `/outputs/reports/`.【F:infrastructure/bin/generate†L568-L618】【F:api/output/README.md†L5-L22】

### 2.3 Alcance

**Incluye:**

- ✅ Generar DFDs mediante Graphviz consumiendo la salida de `python3 <modelo> --dfd`.【F:infrastructure/bin/generate†L263-L314】
- ✅ Renderizar diagramas de secuencia enviando PlantUML comprimido al servidor configurado.【F:infrastructure/bin/generate†L320-L385】
- ✅ Construir reportes HTML usando pytm + Pandoc con plantilla opcional.【F:infrastructure/bin/generate†L392-L456】
- ✅ Publicar un resumen de outputs al finalizar la corrida con rutas HTTP sugeridas.【F:infrastructure/bin/generate†L568-L618】

**NO Incluye:**

- ❌ Validar o editar el código PlantUML en la UI (cubierto por UC-API-001/002).
- ❌ Ejecutar análisis pytm sin generar artefactos (cubierto por UC-API-003).
- ❌ Operaciones de infraestructura como instalación de dependencias (cubiertas por bootstrap).

### 2.4 Restricciones Especiales

1. El script debe ejecutarse como `threatmodel`; si se lanza como `root` o `vagrant`, re-ejecuta automáticamente cambiando de usuario.【F:infrastructure/bin/generate†L22-L59】
2. Los directorios `api/output/diagrams` y `api/output/reports` deben ser escribibles para almacenar resultados.【F:infrastructure/bin/generate†L259-L339】【F:api/output/README.md†L5-L22】
3. La generación de secuencias depende de la disponibilidad del PlantUML Server; fallos de red causan errores explícitos en la descarga.【F:infrastructure/bin/generate†L320-L385】

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Dependencias instaladas (`python3`, `dot`, `curl`, `pandoc`, módulo pytm).
PRECOND-02: PlantUML Server accesible en `PLANTUML_SERVER` (por defecto http://localhost:8080/plantuml).
PRECOND-03: Directorios `api/models/` y `api/output/` disponibles y con permisos para `threatmodel`.
PRECOND-04: Plantillas opcionales (`api/templates/report_template.md`) listas si se quieren reportes personalizados.
```

### 3.2 Precondiciones del Usuario

```
PRECOND-05: Usuario autenticado en la VM con permisos para ejecutar `tm-generate`.
PRECOND-06: Modelos pytm actualizados (al menos un archivo *_model.py válido).
PRECOND-07: Definición de variables de entorno opcionales (ej. PLANTUML_SERVER) cuando se requiera un endpoint distinto.
```

### 3.3 Validación de Precondiciones

```
FUNCION validar_precondiciones_uc_api_006():
    SI check_dependencies() falla:
        RETORNAR error("Faltan binarios base o pytm")
    SI not existe_modelo():
        RETORNAR error("Sin archivos *_model.py")
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: El analista ejecuta `tm-generate` desde la raíz del proyecto.【F:README.md†L7-L19】
PASO 2: El script fuerza el contexto del usuario `threatmodel` y carga variables del proyecto.【F:infrastructure/bin/generate†L22-L93】
PASO 3: `check_dependencies` verifica binarios, módulo pytm y PlantUML Server.【F:infrastructure/bin/generate†L154-L193】
PASO 4: `discover_models` ubica archivos *_model.py y los procesa uno a uno.【F:infrastructure/bin/generate†L199-L339】
PASO 5: Para cada modelo se generan DFD, secuencia y reporte HTML, validando tamaño y existencia de archivos.【F:infrastructure/bin/generate†L263-L456】
PASO 6: Al finalizar, se imprime un resumen con conteo de artefactos y URLs de Tomcat para ver resultados.【F:infrastructure/bin/generate†L568-L618】
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION tm_generate():
    check_execution_context()
    load_environment()
    check_dependencies()
    modelos = discover_models()
    PARA cada modelo EN modelos:
        generate_dfd(modelo)
        generate_sequence(modelo)
        generate_report(modelo)
    mostrar_resumen_outputs()
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Generar un modelo específico

1. El usuario ejecuta `tm-generate api/models/<modelo>_model.py` para acelerar ciclos puntuales.【F:infrastructure/bin/generate†L604-L646】【F:api/models/README.md†L15-L20】
2. El flujo principal se ejecuta solo para ese archivo y el resumen refleja un único conjunto de outputs.

### FA-02: Personalizar el PlantUML Server

1. Se define `PLANTUML_SERVER` apuntando a otro host antes de invocar `tm-generate`.
2. `generate_sequence` utiliza la nueva URL para descargar los PNG generados.【F:infrastructure/bin/generate†L320-L367】【F:infrastructure/bin/generate†L608-L618】

### FA-03: Listar modelos disponibles

1. El usuario ejecuta `tm-generate --list`.
2. `show_usage` delega a `list_models`, mostrando rutas candidatas sin producir outputs.【F:infrastructure/bin/generate†L604-L646】

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Dependencias faltantes

- `check_dependencies` falla y sugiere ejecutar el script de setup; no se procesan modelos hasta resolver la instalación.【F:infrastructure/bin/generate†L154-L193】

### FE-02: PlantUML Server inaccesible

- `generate_sequence` registra el error de descarga e interrumpe la creación del diagrama de secuencia, dejando constancia en consola.【F:infrastructure/bin/generate†L320-L385】

### FE-03: Error en el modelo pytm

- Si `python3 <modelo>` devuelve un código distinto de cero, la generación del artefacto correspondiente se marca como fallo y el resumen final indicará outputs parciales.【F:infrastructure/bin/generate†L263-L339】【F:infrastructure/bin/generate†L520-L618】

---

## 7. POSTCONDICIONES

```
POST-01: DFD, secuencia y reporte disponibles en `api/output/`.
POST-02: Tomcat sirve los artefactos en `/outputs/diagrams/` y `/outputs/reports/`.
POST-03: Se actualizan logs en `/var/log/api/threatmodel.log` según ejecución.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: Solo archivos que terminan en *_model.py son candidatos a generación automática.【F:api/models/README.md†L5-L20】
RN-002: Cada corrida genera archivos nuevos; no se editan outputs manualmente.【F:api/output/README.md†L5-L22】
RN-003: El PlantUML Server debe aceptar contenido comprimido siguiendo el algoritmo estándar (deflate + alfabeto personalizado).【F:infrastructure/bin/generate†L105-L148】【F:infrastructure/bin/generate†L320-L367】
RN-004: La ejecución siempre se realiza bajo el usuario `threatmodel` para mantener permisos consistentes.【F:infrastructure/bin/generate†L22-L59】
```

---

## 9. REFERENCIAS

- `README.md` sección "Inicio Rápido" para comandos básicos.【F:README.md†L7-L19】
- Documentación de outputs en `api/output/README.md`.【F:api/output/README.md†L5-L22】
- Caso de uso UC-API-000 para el flujo extremo a extremo.
