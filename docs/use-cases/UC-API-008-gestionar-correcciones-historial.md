# UC-API-008: GESTIONAR CORRECCIONES CON HISTORIAL Y ROLLBACK

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-008
**Versión:** 1.0
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-008|
|**Nombre**|Gestionar correcciones con historial y rollback|
|**Prioridad**|🔴 Alta|
|**Actores**|• Autor del modelo  
• Equipo de seguridad que valida hallazgos pytm  
• Endpoints `/api/diagram/<name>/history`, `/diff`, `/rollback`|
|**Tipo**|Control de cambios|
|**Frecuencia de Uso**|Media (tras cada análisis completo)|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Coordinar la revisión de hallazgos detectados en UC-API-003 mediante herramientas de historial, comparación y restauración disponibles en la API. El objetivo es que el autor pueda aplicar correcciones en PlantUML, contrastar versiones y, si es necesario, regresar a una versión estable sin perder trazabilidad.【F:api/app.py†L139-L204】【F:api/diagram_service.py†L87-L156】

### 2.2 Objetivo

- Exponer la lista de versiones con metadatos relevantes (autor, timestamp, descripción).
- Permitir la descarga del código PlantUML para cualquier commit previo.
- Generar diffs entre versiones con el mismo motor que respalda las revisiones de seguridad.
- Facilitar un rollback controlado cuando una corrección introduce errores.

### 2.3 Alcance

**Incluye:**

- ✅ Obtener historial mediante `/api/diagram/<name>/history` y mostrarlo en la UI de auditoría.【F:api/app.py†L139-L157】
- ✅ Descargar código con `/api/diagram/<name>/version/<commit_hash>` para editar sobre bases previas.【F:api/app.py†L159-L175】
- ✅ Comparar cambios con `/api/diagram/<name>/diff?commit1=&commit2=` reutilizando `difflib` del servicio.【F:api/app.py†L177-L199】【F:api/diagram_service.py†L88-L109】
- ✅ Ejecutar rollback generando un nuevo commit marcado como `system` para evidenciar la restauración.【F:api/app.py†L201-L233】【F:api/diagram_service.py†L110-L139】

**NO Incluye:**

- ❌ Edición directa del historial (los commits permanecen inmutables).
- ❌ Modificación automática del reporte pytm; debe regenerarse tras cualquier cambio.
- ❌ Gestión de permisos a nivel servidor (definido en despliegue).

### 2.4 Restricciones Especiales

1. Los commits se almacenan en orden inverso en `metadata.json`; la UI debe ordenar según timestamp.【F:api/diagram_service.py†L118-L156】
2. Los rollbacks siempre crean un nuevo commit; nunca se eliminan entradas previas.
3. Las comparaciones se basan en el código textual PlantUML; diferencias en renderizado visual deben validarse con UC-API-002.

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Historial del diagrama disponible en `/vagrant/api/history/<name>/`.
PRECOND-02: Servicio Flask con rutas de historial, diff y rollback activas.
PRECOND-03: Permisos de escritura en el directorio para crear nuevas versiones durante el rollback.
```

### 3.2 Precondiciones del Usuario

```
PRECOND-04: Versión con hallazgos aprobada para revisión.
PRECOND-05: Usuario con rol autorizado para aplicar o revertir cambios.
PRECOND-06: Identificación de commits relevantes (ej. versión previa al fallo).
```

### 3.3 Validación de Precondiciones

```
FUNCION validar_precondiciones_uc_api_004(diagrama, commit):
    SI not existe_historial(diagrama):
        RETORNAR error('Historial inexistente')
    SI commit Y not existe_commit(diagrama, commit):
        RETORNAR error('Commit desconocido')
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: Tras revisar el reporte pytm, el autor abre el historial del diagrama desde la UI.
PASO 2: La UI consulta `/history` para listar versiones y resalta descripciones ligadas a hallazgos.
PASO 3: El autor selecciona dos commits y solicita `/diff` para entender los cambios.
PASO 4: Si la corrección requiere ajustes adicionales, descarga el código con `/version/<commit>`.
PASO 5: El autor edita PlantUML y guarda una nueva versión (UC-API-001).
PASO 6: Si la nueva versión genera problemas, ejecuta `/rollback` hacia el commit estable.
PASO 7: La UI registra el nuevo commit de rollback y su descripción automática.
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION revisar_historial(diagrama):
    historial = GET(f'/api/diagram/{diagrama}/history')
    mostrar(historial)
    seleccionar_commits()
    diff = GET(f'/api/diagram/{diagrama}/diff', params)
    mostrar(diff)
    SI requiere_rollback:
        POST('/api/diagram/rollback', {name: diagrama, commit_hash: commit_estable})
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Comparación de más de dos versiones

- La UI permite revisar diffs consecutivos y acumular notas internas sin ejecutar rollback inmediatamente.

### FA-02: Rollback parcial

- Se puede restaurar solo el código (descargándolo) y reenviar una nueva versión con metadatos ajustados en lugar de usar `/rollback`.

### FA-03: Auditoría externa

- Los auditores consultan `/history` en modo lectura para verificar trazabilidad sin permisos de escritura.

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Commit inexistente

- El servicio responde HTTP 404; la UI solicita una nueva selección.

### FE-02: Historial corrupto

- `_load_metadata` arroja `DiagramServiceError`. Se bloquean operaciones y se coordina restauración desde copias de seguridad.【F:api/diagram_service.py†L123-L147】

### FE-03: Rollback fallido por permisos

- El servicio no puede escribir en `versions/`; se notifica a infraestructura para corregir permisos antes de reintentar.

---

## 7. POSTCONDICIONES

```
POST-01: La plataforma conserva un historial completo de modificaciones.
POST-02: Los rollbacks quedan documentados como commits nuevos con autor `system`.
POST-03: El equipo dispone de diffs y referencias para justificar decisiones de seguridad.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: Cada corrección derivada de hallazgos pytm debe acompañarse de una descripción explicativa.
RN-002: Los rollbacks requieren confirmación de al menos un miembro del equipo de seguridad.
RN-003: No se eliminan commits; las rectificaciones se registran como nuevas versiones.
```

---

## 9. MATRIZ DE TRAZABILIDAD

|Elemento|Fuente|Referencia|
|---|---|---|
|Historial y versiones|Endpoints Flask|`api/app.py`|
|Differences/rollback|Servicio Python|`api/diagram_service.py`|
|Interacción de UI|Plantillas HTML|`api/templates/index.html`, `api/templates/history.html`|

---

**Fin del Caso de Uso UC-API-008**
