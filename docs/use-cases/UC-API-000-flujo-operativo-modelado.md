# UC-API-000: OPERAR EL FLUJO DE MODELADO CON PLANTUML Y PYTM

**Sistema:** Threat Modeling Platform API + UI
**Caso de Uso:** UC-API-000
**Versión:** 1.0
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-API-000|
|**Nombre**|Operar el flujo de modelado con PlantUML y pytm|
|**Prioridad**|🟡 Alta|
|**Actores**|• Autor funcional desde la UI<br>• Servicio Flask (`api/app.py`)<br>• Motor pytm y Plantweb (`api/plantweb/`)<br>• Tomcat para outputs|
|**Tipo**|Proceso extremo a extremo|
|**Frecuencia de Uso**|Alta (cada iteración de diseño)|
|**Complejidad**|Alta|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Describir el recorrido completo que sigue un equipo desde que redacta un modelo en PlantUML dentro de la interfaz web hasta que analiza amenazas con pytm, revisa hallazgos y publica los artefactos para los interesados.

### 2.2 Objetivo

- Guiar la captura, validación y versionado del código PlantUML mediante la API de diagramas.【F:api/app.py†L44-L86】【F:api/diagram_service.py†L62-L120】
- Encadenar la ejecución del análisis pytm y la generación de reportes asociados al modelo aprobado.【F:api/plantweb/pytm_adapter.py†L16-L123】【F:api/models/README.md†L1-L32】
- Difundir los resultados en los canales de Tomcat y soportar iteraciones mediante historial, diff y rollback.【F:api/app.py†L88-L146】【F:api/diagram_service.py†L121-L188】【F:infrastructure/bin/generate†L374-L437】

### 2.3 Alcance

**Incluye:**

- ✅ Edición y previsualización de PlantUML en la UI antes de persistir cambios.
- ✅ Persistencia versionada de diagramas con metadatos de autoría y descripción.
- ✅ Análisis pytm sobre el modelo activo, con render de diagramas auxiliares y reporte HTML.
- ✅ Publicación de diagramas/reportes en Tomcat y seguimiento mediante historial, diffs y rollback.

**NO Incluye:**

- ❌ Definición del modelo pytm desde cero (cubierto por documentación de dominio en `api/models`).
- ❌ Automatización CI/CD para ejecutar análisis fuera de la plataforma manual.
- ❌ Gestión de infraestructura (instalación de pytm, Plantweb o Tomcat).

### 2.4 Restricciones Especiales

1. El editor debe respetar el tamaño máximo de 16 MB por carga y el formato de entrada PlantUML válido.【F:api/app.py†L20-L86】
2. El servicio de historia almacena datos en `/vagrant/api/history`; se requiere espacio en disco y permisos del usuario `threatmodel`.【F:api/diagram_service.py†L71-L94】
3. El análisis depende de dependencias instaladas (pytm, graphviz, pydot, Pillow) y del servidor PlantUML configurado en Tomcat.【F:api/plantweb/pytm_adapter.py†L16-L123】【F:infrastructure/bin/generate†L54-L111】

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: PlantUML server disponible en http://localhost:8080/plantuml.
PRECOND-02: Directorios `api/history/`, `api/output/diagrams/` y `api/output/reports/` con permisos de escritura.
PRECOND-03: Dependencias Python instaladas (pytm, graphviz, pydot, Pillow, plantweb).
PRECOND-04: Modelos pytm en `api/models` exportan un objeto `tm` listo para análisis.
```

### 3.2 Precondiciones del Usuario

```
PRECOND-05: Usuario autenticado en la UI con acceso al módulo de modelado.
PRECOND-06: Código PlantUML inicial disponible (creado en UI o importado desde pytm).
PRECOND-07: Tiempo de ejecución reservado para completar el análisis (hasta varios minutos en modelos grandes).
```

### 3.3 Validación de Precondiciones

**Pseudocódigo:**

```
FUNCION validar_precondiciones_uc_api_000(usuario):
    SI not plantuml_disponible():
        RETORNAR error("Servidor PlantUML no accesible")
    SI not directorios_con_permisos(["api/history", "api/output"]):
        RETORNAR error("Sin permisos de escritura")
    SI not dependencias_instaladas(["pytm", "graphviz", "plantweb"]):
        RETORNAR error("Dependencias incompletas")
    SI not usuario.autenticado:
        RETORNAR error("Sesión inválida")
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: Diseñar o ajustar el código PlantUML en la UI y solicitar previsualización (UC-API-002).
PASO 2: Si la previsualización es correcta, guardar versión mediante `/api/diagram/generate` con metadatos (UC-API-001).
PASO 3: Asociar la versión guardada a un modelo pytm y lanzar análisis desde la UI (UC-API-003).
PASO 4: Ejecutar pytm, renderizar diagramas auxiliares y generar reporte en `api/output` (UC-API-005).
PASO 5: Notificar resultados al usuario, incluyendo resumen de hallazgos críticos y enlaces a Tomcat (UC-API-005).
PASO 6: Revisar historial/diff y, de ser necesario, aplicar correcciones o rollback (UC-API-004) y repetir ciclo.
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION operar_flujo_modelado(diagrama, usuario):
    validar_precondiciones_uc_api_000(usuario)
    preview = diagram_service.generate_diagram(
        diagram_name="preview",
        code=diagrama.codigo,
        format="svg",
        save_history=False
    )
    SI preview.es_error:
        MOSTRAR preview.error
        RETORNAR
    confirmacion = usuario.confirma_guardado()
    SI confirmacion:
        commit = diagram_service.generate_diagram(
            diagram_name=diagrama.nombre,
            code=diagrama.codigo,
            format="svg",
            save_history=True,
            metadata={"author": usuario.email, "description": diagrama.descripcion}
        )
        reporte = ejecutar_analisis_pytm(commit, diagrama.modelo_pytm)
        publicar_en_tomcat(reporte, commit)
    MOSTRAR historial(diagrama.nombre)
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### 5.1 FA-01: Validación PlantUML fallida

```
TRIGGER: La previsualización devuelve error de sintaxis.
FLUJO:
    ↓
Sistema informa la excepción de PlantUML.
    ↓
Usuario corrige el código en el editor.
    ↓
Reintenta la previsualización hasta obtener resultado válido.
```

### 5.2 FA-02: Dependencias pytm incompletas

```
TRIGGER: Ejecución de pytm falla por dependencia faltante.
FLUJO:
    ↓
Sistema captura excepción de `pytm_adapter`.
    ↓
Se registra evento y se sugiere ejecutar `infrastructure/bin/generate --verify-deps`.
    ↓
Usuario reintenta análisis una vez restaurado el entorno.
```

### 5.3 FA-03: Rollback solicitado

```
TRIGGER: Los hallazgos requieren revertir cambios recientes.
FLUJO:
    ↓
Usuario selecciona commit previo en historial.
    ↓
Servicio invoca `diagram_service.rollback` para guardar versión "system".
    ↓
Se notifica al usuario y se vuelve al Paso 1 para corregir.
```

---

## 6. FLUJOS DE EXCEPCIÓN

### 6.1 FE-01: Persistencia no disponible

```
TRIGGER: No se puede escribir en `api/history`.
FLUJO:
    ↓
Servicio lanza `DiagramServiceError`.
    ↓
UI muestra mensaje y bloquea el guardado.
    ↓
Se solicita soporte para revisar permisos o espacio.
```

### 6.2 FE-02: PlantUML Server sin respuesta

```
TRIGGER: Plantweb o PlantUML no responden.
FLUJO:
    ↓
El render falla en `render_pytm_seq`.
    ↓
Sistema ofrece opción de reintento o exportación offline.
    ↓
Se registran logs y se notifica al administrador.
```

### 6.3 FE-03: Reporte HTML no generado

```
TRIGGER: Fallo en la transformación Markdown → HTML.
FLUJO:
    ↓
`infrastructure/bin/generate` retorna error de pandoc.
    ↓
Se marca el análisis como incompleto.
    ↓
Usuario puede descargar el Markdown o reintentar tras corregir dependencias.
```

---

## 7. POSTCONDICIONES

### 7.1 Postcondiciones de Éxito

```
POST-01: Se registra commit con metadatos y hash del diagrama.
POST-02: Reporte pytm publicado en `api/output/reports/` y accesible vía Tomcat.
POST-03: Diagramas auxiliares disponibles en `api/output/diagrams/`.
POST-04: Historial actualizado permitiendo diffs y rollback.
POST-05: Usuarios reciben resumen de hallazgos críticos.
```

### 7.2 Postcondiciones de Fallo

```
POST-FAIL-01: No se crean commits nuevos ni se alteran versiones previas.
POST-FAIL-02: Logs capturan detalles técnicos para diagnóstico.
POST-FAIL-03: UI mantiene estado previo del editor.
POST-FAIL-04: Se dispara alerta para soporte de infraestructura.
```

---

## 8. REGLAS DE NEGOCIO

### 8.1 Reglas Generales

```
RN-001: Toda versión guardada requiere autor y descripción.
RN-002: Los modelos deben residir bajo `api/models` y exponer `tm` válido.
RN-003: Los reportes oficiales se generan únicamente desde el flujo aprobado.
```

### 8.2 Reglas de Validación

```
RN-004: PlantUML debe compilar sin errores antes de persistir cambios.
RN-005: El commit debe registrar hash SHA-1 del código PlantUML.
RN-006: Solo usuarios autorizados pueden invocar análisis pytm.
```

### 8.3 Reglas Operativas

```
RN-007: Los artefactos se sirven desde Tomcat en `/outputs/`.
RN-008: Los análisis se registran en logs de auditoría con timestamp y autor.
RN-009: Rollback crea una versión "system" para trazabilidad.
```

---

## 9. TRAZABILIDAD

|Requisito|Fuente|Sección|
|---|---|---|
|Versionado de diagramas|`api/diagram_service.py`|Funciones `generate_diagram`, `rollback`|
|Integración pytm|`api/plantweb/pytm_adapter.py`|Extracción y render secuencia|
|Publicación Tomcat|`infrastructure/bin/generate`|Fase de generación de reportes|
|Historial y diffs|`api/app.py`|Endpoints `/api/diagram/*`|

---

## 10. NOTAS ADICIONALES

- La UI puede ofrecer accesos directos a `tm-generate` para validar dependencias cuando se detecta un fallo recurrente de pytm.【F:infrastructure/bin/generate†L54-L111】
- El repositorio mantiene modelos de referencia en `api/models/examples` para que los equipos practiquen el flujo completo antes de trabajar con sistemas reales.【F:api/models/README.md†L1-L32】
- El `diagram_service` produce imágenes determinísticas en modo preview, lo que simplifica pruebas automatizadas sin invocar el servidor PlantUML real.【F:api/diagram_service.py†L95-L120】

