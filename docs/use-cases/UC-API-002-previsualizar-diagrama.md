# UC-API-002: PREVISUALIZAR CAMBIOS EN EL EDITOR

**Sistema:** Threat Modeling Platform API  
**Caso de Uso:** UC-API-002  
**Versión:** 2.0  
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-002|
|**Nombre**|Previsualizar cambios en el editor|
|**Prioridad**|🟢 Media|
|**Actores**|• Autor del modelo desde la UI  
• Endpoint `/api/diagram/preview`|
|**Tipo**|Consulta sin persistencia|
|**Frecuencia de Uso**|Muy alta durante iteraciones|
|**Complejidad**|Baja|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Entregar una vista previa inmediata del código PlantUML que el autor está ajustando antes de guardar una versión formal. El endpoint utiliza el mismo servicio que el guardado definitivo, pero ejecuta `generate_diagram` con `save_history=False`, evitando commits mientras la persona experimenta con el modelo.【F:api/app.py†L95-L137】【F:api/diagram_service.py†L57-L86】

### 2.2 Objetivo

- Validar sintaxis y estructura visual del diagrama sin modificar el historial.
- Permitir iteraciones rápidas sobre modelos basados en PlantUML o generados desde pytm.
- Retornar la imagen codificada en base64 para embebida directa en la UI.

### 2.3 Alcance

**Incluye:**

- ✅ Validar la presencia de `code` y usar `format` opcional (`svg` por defecto).【F:api/app.py†L107-L135】
- ✅ Producir bytes determinísticos que la UI transforma en imagen `<img src="data:image/...">`.
- ✅ Compartir mensajes de error si la sintaxis PlantUML es inválida o el payload supera límites.

**NO Incluye:**

- ❌ Generar commits ni actualizar `metadata.json`.
- ❌ Inferir nombre lógico del diagrama (se trabaja con alias `preview`).
- ❌ Ejecutar análisis pytm; el objetivo es evaluar la representación gráfica.

### 2.4 Restricciones Especiales

1. `MAX_CONTENT_LENGTH` fija un límite de 16 MB por solicitud.【F:api/app.py†L21-L24】
2. La UI debe asegurar que las previsualizaciones frecuentes no saturen el servidor.
3. El endpoint reutiliza la misma infraestructura de render usada posteriormente por UC-API-001 para evitar divergencias.

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Servicio Flask en ejecución con ruta `/api/diagram/preview` disponible.
PRECOND-02: Dependencias Python instaladas (Flask, base64, servicio interno).
PRECOND-03: Configuración opcional de Plantweb si la UI integra modelos pytm.
```

### 3.2 Precondiciones del Usuario

```
PRECOND-04: Acceso al editor con campo de código PlantUML.
PRECOND-05: Código válido o en proceso de edición (la respuesta de error guía correcciones).
PRECOND-06: (Opcional) Formato solicitado compatible con el visor local.
```

### 3.3 Validación de Precondiciones

```
FUNCION validar_precondiciones_uc_api_002(request):
    datos = request.get_json()
    SI datos ES NULO O 'code' NO EN datos:
        RETORNAR error('code es obligatorio')
    SI tamaño(datos['code']) > LIMITE_PERMITIDO:
        RETORNAR error('El modelo excede el tamaño máximo')
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: El autor modifica PlantUML en el editor y selecciona "Vista previa".
PASO 2: La UI envía POST a /api/diagram/preview con `code` (y `format` si aplica).
PASO 3: Flask valida entrada y delega al servicio en modo `save_history=False`.
PASO 4: El servicio devuelve bytes del diagrama, que se codifican en base64.
PASO 5: La UI renderiza la imagen para revisar estructura antes de guardar.
PASO 6: Si la vista previa es satisfactoria, el autor procede con UC-API-001.
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION preview_diagram(code, format='svg'):
    respuesta = POST('/api/diagram/preview', {code, format})
    SI respuesta.success:
        mostrar_imagen(respuesta.image)
    SINO:
        mostrar_error(respuesta.error)
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: Error de sintaxis PlantUML

- El servicio devuelve HTTP 500 con detalle textual.  
- La UI resalta el error y sugiere revisar la sección afectada.

### FA-02: Payload vacío

- El endpoint responde HTTP 400 inmediatamente.  
- El editor mantiene el estado anterior hasta que se introduzca código válido.

### FA-03: Formato no soportado

- Si el usuario solicita un formato desconocido, la UI recurre al valor por defecto (`svg`) o informa la incompatibilidad.

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: Servicio inalcanzable

- La llamada AJAX falla (timeout/red).  
- El editor muestra banner de indisponibilidad y propone reintentar.

### FE-02: Límite de tamaño superado

- Flask aborta la petición con HTTP 413; la UI sugiere dividir el modelo o simplificarlo.

---

## 7. POSTCONDICIONES

```
POST-01: El autor visualiza inmediatamente el impacto de sus cambios.
POST-02: No se crean archivos ni entradas en el historial.
POST-03: Se registran métricas de uso (cuando aplique) para evaluar la experiencia.
```

---

## 8. REGLAS DE NEGOCIO

```
RN-001: La vista previa debe ejecutarse antes de solicitar análisis pytm para evitar reportes con sintaxis inválida.
RN-002: Las imágenes retornadas se consideran temporales; la UI no debe almacenarlas en disco.
RN-003: Los clientes externos deben respetar límites de frecuencia definidos por la plataforma.
```

---

## 9. MATRIZ DE TRAZABILIDAD

|Elemento|Fuente|Referencia|
|---|---|---|
|Endpoint de preview|Implementación Flask|`api/app.py`|
|Servicio de render|Implementación Python|`api/diagram_service.py`|
|Interacción de UI|Plantilla de editor|`api/templates/index.html`|

---

**Fin del Caso de Uso UC-API-002**
