# UC-API-001: GENERAR DIAGRAMAS VERSIONADOS

**Sistema:** Threat Modeling Platform API  
**Caso de Uso:** UC-API-001  
**Versión:** 1.1
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-001|
|**Nombre**|Generar diagramas versionados|
|**Prioridad**|🟡 Alta|
|**Actores**|• Servicio de UI (`ui`)
• Clientes externos autorizados|
|**Tipo**|Gestión (creación + persistencia)|
|**Frecuencia de Uso**|Alta|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Permitir que la API genere diagramas a partir de código PlantUML, renderice una imagen en el formato solicitado y persista el historial del diagrama con metadatos de auditoría. Esto aplica tanto para ediciones manuales desde la UI como para entregables generados a partir de modelos `pytm` procesados por las utilidades de Plantweb.

### 2.2 Objetivo

- Recibir código PlantUML y nombre lógico del diagrama.
- Renderizar la imagen solicitada en el backend Python.
- Registrar el commit y metadatos en la carpeta de historial.
- Responder al cliente con hashes y confirmación de persistencia.

### 2.3 Alcance

**Incluye:**

- ✅ Validar campos obligatorios `name` y `code` en la solicitud.
- ✅ Generar bytes determinísticos del diagrama según el formato.
- ✅ Guardar versión y metadatos en disco si `save_history=True`.
- ✅ Registrar metadatos `author` y `description`, permitiendo documentar en la descripción cuál modelo `pytm` originó el código.
- ✅ Devolver identificadores (`commit_hash`, `diagram_hash`) al consumidor.

**NO Incluye:**

- ❌ Renderizado con PlantUML remoto (se usa motor placeholder).
- ❌ Gestión de permisos de carpetas (delegado a infraestructura).
- ❌ Validación semántica avanzada del código PlantUML.

### 2.4 Restricciones Especiales

1. El historial se almacena bajo `DIAGRAM_SERVICE_HISTORY_DIR` (`/vagrant/api/history` por defecto).
2. El formato soportado por defecto es `svg`, pero se acepta cualquier valor que la UI soporte.
3. La operación debe ejecutarse de manera thread-safe para evitar corrupción del historial.
4. Cuando el código proviene de un modelo `pytm`, la extracción de PlantUML debe realizarse previamente mediante `api.plantweb.render_pytm_model` o funciones equivalentes.

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Directorio de historial existente y con permisos de escritura.
PRECOND-02: Variables de entorno de PlantUML opcionales configuradas si aplica.
PRECOND-03: Servicio Flask activo y escuchando el endpoint `/api/diagram/generate`.
PRECOND-04: (Cuando aplica) Entorno Python con `pytm` y Plantweb disponibles para generar el PlantUML base.
```

### 3.2 Precondiciones del Usuario

```
PRECOND-05: Cliente autenticado o confiable según políticas del despliegue.
PRECOND-06: Solicitud HTTP con `Content-Type: application/json`.
PRECOND-07: Payload con campos mínimos `name` y `code`.
```

### 3.3 Validación de Precondiciones

**Pseudocódigo:**

```
FUNCION validar_precondiciones_uc_api_001(request):
    SI request.content_type != 'application/json':
        RETORNAR error('Solicitud inválida')
    datos = request.json
    SI 'name' NO EN datos O 'code' NO EN datos:
        RETORNAR error('name y code son obligatorios')
    SI directorio_historial NO accesible:
        RETORNAR error('Historial no disponible')
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 0 (opcional): Orquestación obtiene PlantUML desde un modelo `pytm` usando `render_pytm_model()`.
PASO 1: Cliente POST → /api/diagram/generate con JSON válido.
PASO 2: API valida campos obligatorios.
PASO 3: Servicio calcula hash SHA1 del código.
PASO 4: Servicio genera bytes placeholder según formato solicitado.
PASO 5: Servicio guarda versión en disco con commit y metadatos.
PASO 6: API responde con éxito, commit_hash y diagram_hash.
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION generar_diagrama(request):
    validar_precondiciones_uc_api_001(request)
    metadata = construir_metadata(request)
    // Ejemplo: metadata['description'] = f"Modelo pytm: {request.json.get('model_name')}"
    resultado = diagram_service.generate_diagram(
        diagram_name=request.json['name'],
        code=request.json['code'],
        format=request.json.get('format', 'svg'),
        save_history=VERDADERO,
        metadata=metadata
    )
    RETORNAR respuesta_json(resultado)
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Campos obligatorios ausentes

**Descripción:** El cliente omite `name` o `code`.

**Trigger:** Solicitud incompleta.

**Flujo:**

```
1. API detecta ausencia de campos.
2. API retorna HTTP 400 con mensaje de error.
```

### FA-02: Error al persistir metadatos

**Descripción:** La metadata existente está corrupta o no se puede escribir.

**Trigger:** Excepción en `_write_metadata` o `_load_metadata`.

**Flujo:**

```
1. Servicio intenta leer metadata y falla.
2. Se lanza DiagramServiceError.
3. API retorna HTTP 500 con descripción del error.
4. Se registra el incidente para intervención manual.
```

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Ruta no disponible

```
TRIGGER: Servicio Flask apagado.
FLUJO:
    Cliente recibe error de conexión.
    Se debe escalar a equipo de operaciones.
```

### FE-02: Error inesperado en renderizado

```
TRIGGER: `generate_diagram` lanza excepción no controlada.
FLUJO:
    API captura excepción.
    API responde HTTP 500 con mensaje genérico.
    Se revisan logs del servicio para diagnóstico.
```

---

## 7. POSTCONDICIONES

### 7.1 Postcondiciones de Éxito

```
POST-01: Versión del diagrama almacenada en `/versions/<commit>.plantuml`.
POST-02: `metadata.json` actualizado con la nueva entrada.
POST-03: Cliente recibe `commit_hash` y `diagram_hash` para auditoría.
```

### 7.2 Postcondiciones de Fallo

```
POST-FAIL-01: No se crea commit ni archivos nuevos.
POST-FAIL-02: El cliente recibe información del fallo.
POST-FAIL-03: Se requiere intervención si hay corrupción de metadata.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: `diagram_name` y `code` son obligatorios.
RN-002: Se generan hashes determinísticos para cada payload.
RN-003: Cada versión crea un commit con timestamp UTC.
RN-004: El historial se preprende con la versión más reciente.
```

---

## 9. TABLA DE BASE DE DATOS

_No aplica. El almacenamiento es basado en archivos y JSON._

---

## 10. VALIDACIONES

```
VAL-01: Validación de presencia de campos obligatorios.
VAL-02: Validación de longitud máxima del payload (16 MB por configuración Flask).
VAL-03: Sincronización mediante `threading.Lock` durante persistencia.
```

---

## 11. EJEMPLOS DE USO

- **Generación estándar:** La UI envía diagrama principal del proyecto y recibe hash para mostrar confirmación de guardado.
- **Automatización CI:** Una pipeline publica diagramas derivados de modelos pytm y archiva los commits devueltos.

---

## 12. REQUISITOS NO FUNCIONALES

```
RNF-01: El tiempo de respuesta debe ser inferior a 1 segundo para diagramas pequeños.
RNF-02: Debe tolerar múltiples solicitudes concurrentes sin corrupción de archivos.
RNF-03: El servicio debe registrar cualquier excepción para auditoría.
```

---

## 13. NOTAS ADICIONALES

- En despliegues locales, los archivos se guardan bajo `/vagrant/api/history`.
- Los metadatos utilizan formato JSON con claves `versions` y `latest` para integrarse con la UI.

---

## 14. MATRIZ DE TRAZABILIDAD

|Requisito|Fuente|Sección|
|---|---|---|
|Validación de campos obligatorios|`api/app.py`|`api_generate_diagram`|
|Persistencia de versiones|`api/diagram_service.py`|`_store_version`|
|Bloqueo concurrente|`api/diagram_service.py`|`self._lock`|

