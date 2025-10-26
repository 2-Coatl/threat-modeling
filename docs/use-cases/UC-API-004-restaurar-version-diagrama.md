# UC-API-004: RESTAURAR UNA VERSIÓN PREVIA DEL DIAGRAMA

**Sistema:** Threat Modeling Platform API  
**Caso de Uso:** UC-API-004  
**Versión:** 1.0  
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-004|
|**Nombre**|Restaurar una versión previa del diagrama|
|**Prioridad**|🔴 Alta|
|**Actores**|• Servicio de UI (`ui`)
• Equipo de seguridad|
|**Tipo**|Recuperación / mantenimiento|
|**Frecuencia de Uso**|Baja (solo ante incidentes)|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Permitir que la API reconstruya la versión actual de un diagrama a partir de un commit histórico, conservando trazabilidad de la restauración.

### 2.2 Objetivo

- Validar que el commit solicitado exista.
- Registrar un nuevo commit indicando que proviene de un rollback.
- Entregar identificadores del nuevo commit al cliente.

### 2.3 Alcance

**Incluye:**

- ✅ Recuperar código de la versión seleccionada.
- ✅ Crear una nueva entrada en metadata con descripción "Rollback to <commit>".
- ✅ Retornar el hash del nuevo commit generado.

**NO Incluye:**

- ❌ Modificar commits históricos.
- ❌ Cambiar descripciones previas.
- ❌ Reprocesar imágenes existentes.

### 2.4 Restricciones Especiales

1. Se utiliza el author `system` al registrar el rollback.
2. El formato se hereda de la versión más reciente disponible.
3. El nuevo commit se agrega al inicio del historial como versión más reciente.

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Historial del diagrama accesible.
PRECOND-02: Commit objetivo existente.
PRECOND-03: Servicio Flask operativo.
```

### 3.2 Precondiciones del Usuario

```
PRECOND-04: Usuario con permisos de mantenimiento.
PRECOND-05: Solicitud JSON con `name` y `commit_hash`.
```

### 3.3 Validación de Precondiciones

**Pseudocódigo:**

```
FUNCION validar_precondiciones_uc_api_004(request):
    SI 'name' NO EN request.json O 'commit_hash' NO EN request.json:
        RETORNAR error('Parámetros insuficientes')
    validar_historial(request.json['name'], request.json['commit_hash'])
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: Cliente POST → /api/diagram/rollback.
PASO 2: API valida parámetros y existencia del commit.
PASO 3: Servicio lee código de la versión solicitada.
PASO 4: Servicio crea nuevo commit con descripción "Rollback to <commit>" y autor `system`.
PASO 5: API responde con `new_commit` y `rolled_back_to`.
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION restaurar_version(request):
    validar_precondiciones_uc_api_004(request)
    nuevo_commit = diagram_service.rollback(
        diagram_name=request.json['name'],
        commit_hash=request.json['commit_hash']
    )
    RETORNAR respuesta_json({
        success: VERDADERO,
        diagram: request.json['name'],
        rolled_back_to: request.json['commit_hash'],
        new_commit: nuevo_commit
    })
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Commit objetivo inexistente

**Descripción:** El commit indicado no existe.

**Trigger:** Archivo de versión ausente.

**Flujo:**

```
1. `get_version` lanza `DiagramServiceError`.
2. API responde HTTP 500/404 con mensaje de error.
3. Cliente notifica que el commit no es válido.
```

### FA-02: Historial vacío

**Descripción:** Se intenta rollback en diagrama sin historial.

**Trigger:** `_load_metadata` retorna lista vacía.

**Flujo:**

```
1. Servicio detecta que no hay versiones.
2. Retorna excepción.
3. API responde HTTP 500 y registra incidente.
```

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Error de escritura

```
TRIGGER: No se puede escribir el nuevo commit.
FLUJO:
    Servicio lanza excepción de IO.
    API responde HTTP 500.
    Se revisan permisos de filesystem.
```

### FE-02: Bloqueo concurrente

```
TRIGGER: Otro proceso está escribiendo historial.
FLUJO:
    `threading.Lock` serializa la operación.
    Si falla, API debe reintentar o devolver error temporal.
```

---

## 7. POSTCONDICIONES

### 7.1 Postcondiciones de Éxito

```
POST-01: Nueva versión registrada como la más reciente.
POST-02: Metadata actualizada con descripción de rollback.
POST-03: Cliente obtiene identificador del nuevo commit.
```

### 7.2 Postcondiciones de Fallo

```
POST-FAIL-01: No se crean nuevas versiones.
POST-FAIL-02: Cliente recibe error detallado.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: Solo se permite rollback a commits existentes.
RN-002: Cada rollback genera un commit nuevo (no sobrescribe historial).
RN-003: El autor registrado debe ser `system` salvo configuraciones especiales.
```

---

## 9. TABLA DE BASE DE DATOS

_No aplica. Persistencia basada en archivos._

---

## 10. VALIDACIONES

```
VAL-01: Validar campos obligatorios en la solicitud.
VAL-02: Confirmar existencia del commit objetivo.
VAL-03: Asegurar que la escritura del nuevo commit sea exitosa.
```

---

## 11. EJEMPLOS DE USO

- **Recuperación ante error humano:** Se restaura la versión previa a un cambio erróneo.
- **Respuesta a incidente:** Se vuelve a la última versión conocida segura tras detectar actividad maliciosa.

---

## 12. REQUISITOS NO FUNCIONALES

```
RNF-01: El rollback debe ejecutarse en menos de 1 segundo para diagramas pequeños.
RNF-02: Debe quedar evidencia en logs de auditoría.
```

---

## 13. NOTAS ADICIONALES

- La UI debe confirmar con el usuario antes de ejecutar el rollback.
- Considerar notificar al canal de operaciones cuando se realice esta acción.

---

## 14. MATRIZ DE TRAZABILIDAD

|Requisito|Fuente|Sección|
|---|---|---|
|Rollback|`api/app.py`|`api_rollback`|
|Creación de commit `system`|`api/diagram_service.py`|`rollback`|
|Persistencia|`api/diagram_service.py`|`_store_version`|

