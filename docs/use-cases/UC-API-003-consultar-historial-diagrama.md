# UC-API-003: CONSULTAR HISTORIAL Y VERSIONES DE DIAGRAMAS

**Sistema:** Threat Modeling Platform API  
**Caso de Uso:** UC-API-003  
**Versión:** 1.0  
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-003|
|**Nombre**|Consultar historial y versiones de diagramas|
|**Prioridad**|🟡 Alta|
|**Actores**|• Servicio de UI (`ui`)
• Revisores de modelos|
|**Tipo**|Consulta y auditoría|
|**Frecuencia de Uso**|Media|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Exponer información histórica de cada diagrama para permitir revisiones, auditorías y análisis de cambios.

### 2.2 Objetivo

- Listar el historial completo (`/api/diagram/<name>/history`).
- Recuperar versiones individuales (`/api/diagram/<name>/version/<commit>`).
- Calcular diferencias entre versiones (`/api/diagram/<name>/diff`).
- Listar todos los diagramas registrados (`/api/diagrams`).

### 2.3 Alcance

**Incluye:**

- ✅ Entregar metadatos (`author`, `description`, `timestamp`, `diagram_hash`).
- ✅ Calcular diffs usando formato unified diff.
- ✅ Manejar errores cuando el historial no existe.

**NO Incluye:**

- ❌ Modificar versiones.
- ❌ Reprocesar imágenes almacenadas.
- ❌ Garantizar orden cronológico inverso fuera del servicio (la UI debe mostrarlo).

### 2.4 Restricciones Especiales

1. Los historiales se leen desde archivos JSON generados por `generate_diagram`.
2. Los diffs dependen de `difflib.unified_diff` y se entregan como texto plano.
3. Las rutas retornan HTTP 404 cuando el diagrama o commit no existen.

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Historial disponible en `history_dir`.
PRECOND-02: Archivos `metadata.json` íntegros.
PRECOND-03: Endpoint Flask activo.
```

### 3.2 Precondiciones del Usuario

```
PRECOND-04: Conocer el nombre del diagrama.
PRECOND-05: Contar con permisos de lectura según despliegue.
PRECOND-06: Proporcionar commits válidos al solicitar diffs.
```

### 3.3 Validación de Precondiciones

**Pseudocódigo:**

```
FUNCION validar_historial(diagrama, commit_opcional):
    SI diagrama NO existe en filesystem:
        RETORNAR error('Historial no disponible')
    SI commit_opcional definido Y archivo asociado NO existe:
        RETORNAR error('Versión inexistente')
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: Cliente GET → /api/diagram/<name>/history.
PASO 2: Servicio carga metadata y construye lista de versiones.
PASO 3: API responde con JSON (`versions`, `total`).
PASO 4: Cliente GET → /api/diagram/<name>/version/<commit> para recuperar código.
PASO 5: Cliente opcionalmente GET → /api/diagram/<name>/diff?commit1=A&commit2=B para comparar.
PASO 6: Cliente GET → /api/diagrams para obtener catálogo completo.
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION consultar_historial(nombre):
    versiones = diagram_service.get_history(nombre)
    RETORNAR respuesta_json({ versions, total=len(versiones) })

FUNCION obtener_version(nombre, commit):
    codigo = diagram_service.get_version(nombre, commit)
    RETORNAR respuesta_json({ code: codigo })

FUNCION comparar_versiones(nombre, commit1, commit2):
    diff = diagram_service.diff_versions(nombre, commit1, commit2)
    RETORNAR respuesta_json({ diff: diff })
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Historial vacío

**Descripción:** Se solicita historial de un diagrama sin versiones.

**Trigger:** `metadata.json` vacío.

**Flujo:**

```
1. Servicio retorna lista vacía.
2. API responde con `total = 0`.
3. UI muestra mensaje "Sin versiones".
```

### FA-02: Commits inválidos en diff

**Descripción:** Los commits no existen.

**Trigger:** Parámetros `commit1`/`commit2` incorrectos.

**Flujo:**

```
1. `get_version` lanza excepción.
2. API responde HTTP 500 (o 404 si se implementa).
3. UI informa que no se pudo generar diff.
```

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Metadata corrupta

```
TRIGGER: `_load_metadata` detecta JSON inválido.
FLUJO:
    Servicio lanza DiagramServiceError.
    API devuelve HTTP 404/500 con descripción.
    Se requiere limpieza manual del archivo.
```

### FE-02: Falta de permisos de lectura

```
TRIGGER: El proceso no puede leer archivos del historial.
FLUJO:
    Python lanza excepción de IO.
    API responde HTTP 500.
    Operaciones debe corregir permisos.
```

---

## 7. POSTCONDICIONES

### 7.1 Postcondiciones de Éxito

```
POST-01: El cliente posee información suficiente para auditar cambios.
POST-02: No se modifica ningún archivo durante la consulta.
```

### 7.2 Postcondiciones de Fallo

```
POST-FAIL-01: No se entregan datos al cliente.
POST-FAIL-02: Se registran los errores para corrección.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: El historial debe entregarse en orden descendente (último primero).
RN-002: Los commits son inmutables una vez generados.
RN-003: Los diffs deben identificar ambos commits consultados.
```

---

## 9. TABLA DE BASE DE DATOS

_No aplica. Las fuentes son archivos y JSON._

---

## 10. VALIDACIONES

```
VAL-01: Validar existencia del diagrama previo a cualquier lectura.
VAL-02: Validar que los commits existan antes de generar diff.
VAL-03: Manejar errores de I/O y JSON.
```

---

## 11. EJEMPLOS DE USO

- **Revisión semanal:** Equipo de seguridad revisa los últimos commits de diagramas críticos.
- **Auditoría de incidentes:** Analista descarga la versión exacta asociada a un incidente para reconstrucción.

---

## 12. REQUISITOS NO FUNCIONALES

```
RNF-01: Las operaciones de lectura deben completarse en menos de 200 ms para historiales pequeños.
RNF-02: Las respuestas deben ser cacheables por proxies autorizados.
```

---

## 13. NOTAS ADICIONALES

- La lista general `/api/diagrams` ayuda a construir listados en la UI.
- Los historiales residen en subcarpetas por diagrama dentro del `history_dir`.

---

## 14. MATRIZ DE TRAZABILIDAD

|Requisito|Fuente|Sección|
|---|---|---|
|Listado de versiones|`api/app.py`|`api_get_history`|
|Obtención de código|`api/app.py`|`api_get_version`|
|Differences|`api/app.py`|`api_diff_versions`|
|Gestión de metadata|`api/diagram_service.py`|`_load_metadata`|

