# UC-API-002: PREVISUALIZAR DIAGRAMA SIN HISTORIAL

**Sistema:** Threat Modeling Platform API  
**Caso de Uso:** UC-API-002  
**Versión:** 1.0  
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-002|
|**Nombre**|Previsualizar diagrama sin historial|
|**Prioridad**|🟢 Media|
|**Actores**|• Servicio de UI (`ui`)
• Analistas que validan código antes de guardar|
|**Tipo**|Consulta (render sin persistencia)|
|**Frecuencia de Uso**|Alta durante edición|
|**Complejidad**|Baja|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Brindar una vista previa rápida del diagrama renderizado sin crear commits ni afectar el historial persistente.

### 2.2 Objetivo

- Aceptar código PlantUML temporal.
- Renderizar bytes del diagrama con el formato solicitado.
- Devolver la imagen codificada en base64 al cliente.

### 2.3 Alcance

**Incluye:**

- ✅ Validar campo obligatorio `code`.
- ✅ Generar imagen placeholder utilizando el motor existente.
- ✅ Entregar respuesta JSON con datos base64 y formato indicado.

**NO Incluye:**

- ❌ Guardar historial ni metadatos.
- ❌ Validar nombre de diagrama.
- ❌ Aplicar restricciones de versionado.

### 2.4 Restricciones Especiales

1. El tamaño del payload está limitado por `MAX_CONTENT_LENGTH` de Flask (16 MB).
2. El endpoint responde siempre con base64 (`data:image/...`).
3. El nombre lógico del diagrama se fuerza a `preview` en el servicio interno.

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Endpoint `/api/diagram/preview` habilitado y autenticado según despliegue.
PRECOND-02: Servicio de render configurado en la API.
PRECOND-03: Dependencias de Python instaladas (Flask, etc.).
```

### 3.2 Precondiciones del Usuario

```
PRECOND-04: Solicitud JSON con el campo `code` válido.
PRECOND-05: Opcional `format` (default `svg`).
PRECOND-06: Usuario con acceso a funcionalidades de edición.
```

### 3.3 Validación de Precondiciones

**Pseudocódigo:**

```
FUNCION validar_precondiciones_uc_api_002(request):
    SI request.json NO existe O 'code' NO EN request.json:
        RETORNAR error('code es obligatorio')
    SI tamaño_payload > 16MB:
        RETORNAR error('Payload excede el límite permitido')
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: Cliente POST → /api/diagram/preview.
PASO 2: API valida presencia de `code`.
PASO 3: Servicio genera imagen sin guardar historial.
PASO 4: API codifica la imagen en base64.
PASO 5: API responde con JSON (`success`, `image`, `format`).
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION previsualizar_diagrama(request):
    validar_precondiciones_uc_api_002(request)
    resultado = diagram_service.generate_diagram(
        diagram_name='preview',
        code=request.json['code'],
        format=request.json.get('format', 'svg'),
        save_history=FALSO
    )
    imagen = base64_encode(resultado['image'])
    RETORNAR respuesta_json({
        success: VERDADERO,
        image: 'data:image/' + formato + ';base64,' + imagen,
        format: formato
    })
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Formato no soportado

**Descripción:** El cliente envía un formato que la UI no puede mostrar.

**Trigger:** `format` desconocido.

**Flujo:**

```
1. Servicio genera bytes igualmente (no hay validación interna).
2. UI decide si mostrar o advertir al usuario.
```

### FA-02: Código PlantUML inválido

**Descripción:** El código no puede ser renderizado por PlantUML real.

**Trigger:** Error posterior al despliegue con motor real.

**Flujo:**

```
1. PlantUML devolvería error.
2. API debe capturar excepción y responder HTTP 500.
```

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Payload mal formado

```
TRIGGER: JSON inválido o sin `code`.
FLUJO:
    API retorna HTTP 400.
    Cliente muestra mensaje de error en editor.
```

### FE-02: Timeout del servicio

```
TRIGGER: PlantUML o render tardan demasiado.
FLUJO:
    API retorna HTTP 500.
    UI ofrece reintento o reporte.
```

---

## 7. POSTCONDICIONES

### 7.1 Postcondiciones de Éxito

```
POST-01: Cliente recibe imagen base64 lista para incrustar.
POST-02: No se crea ningún archivo ni metadata en disco.
```

### 7.2 Postcondiciones de Fallo

```
POST-FAIL-01: Cliente recibe descripción del error.
POST-FAIL-02: No se realizan cambios en el sistema.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: El endpoint es sólo para previsualización; está prohibido persistir.
RN-002: El tamaño máximo del payload está limitado a 16 MB.
RN-003: Se debe devolver siempre un `success` booleano en la respuesta JSON.
```

---

## 9. TABLA DE BASE DE DATOS

_No aplica. No se generan registros._

---

## 10. VALIDACIONES

```
VAL-01: Validar presencia de `code`.
VAL-02: Validar límite de tamaño.
VAL-03: Asegurar respuesta en formato JSON consistente.
```

---

## 11. EJEMPLOS DE USO

- **Editor UI:** El usuario escribe PlantUML y solicita vista previa inmediata antes de guardar.
- **Integración externa:** Servicio automatizado prueba un snippet de PlantUML y verifica que el render sea válido.

---

## 12. REQUISITOS NO FUNCIONALES

```
RNF-01: Respuesta inferior a 500 ms para diagramas simples.
RNF-02: Endpoint disponible durante sesiones de edición concurrentes.
```

---

## 13. NOTAS ADICIONALES

- El resultado base64 permite incrustar la imagen sin almacenarla temporalmente.
- El commit hash devuelto es `None` al no persistir historial.

---

## 14. MATRIZ DE TRAZABILIDAD

|Requisito|Fuente|Sección|
|---|---|---|
|Validación de `code` obligatorio|`api/app.py`|`api_preview_diagram`|
|Render sin historial|`api/app.py`|`save_history=False`|
|Codificación base64|`api/app.py`|`api_preview_diagram`|

