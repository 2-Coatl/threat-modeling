# UC-API-001: DISEÑAR Y VERSIONAR DIAGRAMAS PLANTUML

**Sistema:** Threat Modeling Platform API  
**Caso de Uso:** UC-API-001  
**Versión:** 2.0  
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-001|
|**Nombre**|Diseñar y versionar diagramas PlantUML|
|**Prioridad**|🟡 Alta|
|**Actores**|• Autor del modelo desde la UI (`api/templates/index.html`)  
• Servicio Flask `/api/diagram/generate`|
|**Tipo**|Gestión de artefactos (creación + auditoría)|
|**Frecuencia de Uso**|Alta (en cada iteración del modelo)|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Permitir que un analista de amenazas capture código PlantUML en el editor visual, envíe el contenido al endpoint `/api/diagram/generate` y reciba una versión persistida con metadatos de auditoría. El flujo alimenta el ciclo "diseñar → analizar → corregir" descrito en los casos posteriores.【F:api/app.py†L49-L93】【F:api/diagram_service.py†L43-L117】

### 2.2 Objetivo

- Recibir nombre lógico, código PlantUML y metadatos opcionales desde la UI.
- Calcular hashes determinísticos para identificar el contenido generado.
- Guardar el código como versión inmutable y exponer `commit_hash` para rastreo.
- Preparar la base para ejecutar validaciones con pytm y mostrar hallazgos.

### 2.3 Alcance

**Incluye:**

- ✅ Validación mínima de payload (`name`, `code`) antes de procesar la solicitud.【F:api/app.py†L55-L75】
- ✅ Generación de bytes del diagrama y hash SHA-1 del código para detectar cambios.【F:api/diagram_service.py†L57-L79】
- ✅ Persistencia del código en `/vagrant/api/history/<diagram>/versions/` con metadata JSON accesible desde la UI.【F:api/diagram_service.py†L118-L162】
- ✅ Registro de autor y descripción para anotar qué modelo pytm originó el código enviado.

**NO Incluye:**

- ❌ Validaciones semánticas del PlantUML (se delega a la vista previa y a pytm).
- ❌ Generación de reportes de hallazgos (cubierto por UC-API-003).
- ❌ Gestión de permisos de archivos a nivel sistema (protegido por bootstrap).

### 2.4 Restricciones Especiales

1. El historial usa `DIAGRAM_SERVICE_HISTORY_DIR` (por defecto `/vagrant/api/history`) y debe existir antes de la operación.【F:api/diagram_service.py†L46-L55】
2. La operación se ejecuta bajo un `threading.Lock` para evitar condiciones de carrera entre autores concurrentes.【F:api/diagram_service.py†L50-L55】
3. El servicio retorna bytes placeholder; la representación final se consume desde la carpeta de salida o se re-renderiza al mostrar la vista previa.

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Aplicación Flask en ejecución con acceso al endpoint `/api/diagram/generate`.
PRECOND-02: Directorio de historial accesible y con permisos de escritura.
PRECOND-03: Dependencias Python cargadas (`Flask`, `diagram_service`).
PRECOND-04: (Opcional) Plantweb y pytm instalados si el código proviene de modelos programáticos.
```

### 3.2 Precondiciones del Usuario

```
PRECOND-05: Analista autenticado en la UI del editor.
PRECOND-06: Formulario con nombre del diagrama único y código PlantUML válido.
PRECOND-07: Elección de formato (`svg` por defecto) y descripción opcional para trazabilidad.
```

### 3.3 Validación de Precondiciones

**Pseudocódigo:**

```
FUNCION validar_precondiciones_uc_api_001(request):
    SI request.content_type != 'application/json':
        RETORNAR error('Formato inválido')
    datos = request.get_json()
    SI 'name' NO EN datos O 'code' NO EN datos:
        RETORNAR error('Faltan campos requeridos')
    SI NOT history_dir.existe():
        RETORNAR error('Historial no inicializado')
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: El autor captura o pega código PlantUML en el editor visual.
PASO 2: Opcionalmente ejecuta la vista previa (UC-API-002) para validar sintaxis.
PASO 3: El autor presiona "Guardar y analizar"; la UI envía POST a /api/diagram/generate.
PASO 4: Flask valida payload, calcula hashes y delega a `PytmDiagramService.generate_diagram`.
PASO 5: El servicio guarda archivo PlantUML y actualiza `metadata.json` con autor/descripcion/timestamp.
PASO 6: El endpoint responde con `commit_hash` y `diagram_hash`.
PASO 7: La UI notifica éxito y habilita botones para historial y análisis pytm.
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION submit_diagram(payload):
    respuesta = POST('/api/diagram/generate', payload)
    SI respuesta.success:
        actualizar_historial_local(respuesta.commit_hash)
        habilitar_boton_analisis()
    SINO:
        mostrar_error(respuesta.error)
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Payload incompleto

1. El servicio detecta ausencia de `name` o `code` y responde con HTTP 400.  
2. La UI muestra mensaje y mantiene el editor abierto para correcciones.

### FA-02: Reintento con contenido idéntico

1. El hash del código coincide con la versión anterior.  
2. Se almacena un nuevo commit, pero la UI puede advertir que no hubo cambios relevantes usando `diagram_hash` en la respuesta.

### FA-03: Error al escribir metadata

1. `_write_metadata` lanza `DiagramServiceError` por JSON corrupto.  
2. Se responde HTTP 500 y se guía al usuario a restaurar el historial (UC-API-004).

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Directorio inaccesible

- Trigger: el proceso no puede crear `/vagrant/api/history/<diagram>/`.  
- Acción: se lanza excepción y la UI bloquea nuevos envíos hasta que infraestructura restaure permisos.

### FE-02: Error inesperado del servicio

- Trigger: fallo interno en `generate_diagram`.  
- Acción: se registra el error y se notifica al equipo para revisión manual.

---

## 7. POSTCONDICIONES

```
POST-01: Existe un archivo `<commit>.plantuml` asociado al diagrama.
POST-02: `metadata.json` se actualiza con la versión más reciente.
POST-03: La UI dispone de identificadores para solicitar historial y análisis.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: Cada nombre de diagrama representa un repositorio lógico en `history/`.
RN-002: El autor debe registrar una descripción que referencie el modelo pytm cuando aplique.
RN-003: Solo formatos soportados por la UI (svg, png futuro) son válidos en `format`.
RN-004: Los commits almacenados son inmutables; cualquier corrección genera una nueva versión.
```

---

## 9. MATRIZ DE TRAZABILIDAD

|Elemento|Fuente|Referencia|
|---|---|---|
|Endpoint de generación|Implementación Flask|`api/app.py`|
|Persistencia e historial|Servicio de diagramas|`api/diagram_service.py`|
|UI - acción de guardado|Editor HTML|`api/templates/index.html`|

---

**Fin del Caso de Uso UC-API-001**
