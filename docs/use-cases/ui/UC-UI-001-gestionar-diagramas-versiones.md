# UC-UI-001: Gestionar diagramas y versiones

**Sistema:** Threat Modeling UI (React shell)
**Caso de Uso:** UC-UI-001
**Versión:** 0.1
**Fecha:** 2025-10-26

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-UI-001|
|**Nombre**|Gestionar diagramas y versiones|
|**Prioridad**|🟢 Alta|
|**Actores**|• Autor funcional<br>• Revisor de seguridad|
|**Tipo**|Gestión operativa|
|**Frecuencia de Uso**|Diaria|
|**Complejidad**|Alta|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Ofrecer a los usuarios un editor web integrado para crear, versionar y restaurar
diagramas de threat modeling consumiendo los endpoints documentados en
`UC-API-000`, `UC-API-001`, `UC-API-002`, `UC-API-003`, `UC-API-004` y
`UC-API-008`.

### 2.2 Objetivo

- Crear nuevas versiones de diagramas PlantUML.
- Previsualizar cambios antes de persistirlos.
- Consultar historial y metadata sin abandonar la UI.
- Ejecutar rollback controlado a versiones anteriores.

### 2.3 Alcance

Incluye interacciones del editor (`ui/src/pages/HomePage.jsx`) y los módulos
especializados planificados bajo `ui/src/modules/modeling/` y
`ui/src/modules/history/`.

---

## 3. PRECONDICIONES

1. Usuario autenticado con permisos de edición.
2. API disponible y accesible en el entorno configurado en `ui/src/state/appConfig`.
3. Directorios de historial y artefactos con permisos adecuados.

---

## 4. FLUJO PRINCIPAL

1. El usuario abre el editor y carga el proyecto activo.
2. Solicita previsualización del diagrama (consume `UC-API-002`).
3. Guarda una nueva versión (consume `UC-API-001`).
4. Consulta historial y selecciona versión para inspección (`UC-API-003`).
5. Ejecuta rollback si es necesario (`UC-API-004` y `UC-API-008`).

---

## 5. EXCEPCIONES RELEVANTES

- **FE-01:** Error de renderizado → Mostrar alerta, permitir reintento (`UC-API-002`).
- **FE-02:** Falta de permisos → Bloquear acciones mutables y mostrar contacto de soporte.
- **FE-03:** Rollback no disponible → Advertir causas (versionado bloqueado u operaciones pendientes).

---

## 6. REQUISITOS FUNCIONALES DESTACADOS

|ID|Descripción|
|--|-----------|
|RF-01|Mantener autosave del contenido del editor mientras se esperan respuestas de la API.|
|RF-02|Mostrar cronología de commits con diff resumido y etiquetas de severidad.|
|RF-03|Permitir recuperar versiones seleccionadas en modo sólo lectura antes de confirmar rollback.|

---

## 7. REQUISITOS NO FUNCIONALES

- La UI debe conservar estado del editor durante actualizaciones en caliente.
- Las llamadas a la API deben contener trazas (`X-Request-ID`) para auditoría.
- Responder en < 1 segundo para operaciones de navegación local (sin contar roundtrip API).

---

## 8. RELACIONES

|Relación|Documento|
|---|---|
|Depende de|`docs/use-cases/UC-API-000-flujo-operativo-modelado.md`|
|Depende de|`docs/use-cases/UC-API-001-generar-diagrama-versionado.md`|
|Depende de|`docs/use-cases/UC-API-002-previsualizar-diagrama.md`|
|Depende de|`docs/use-cases/UC-API-003-consultar-historial-diagrama.md`|
|Depende de|`docs/use-cases/UC-API-004-restaurar-version-diagrama.md`|
|Depende de|`docs/use-cases/UC-API-008-gestionar-correcciones-historial.md`|

---

## 9. PENDIENTES

- Definir componentes concretos en `ui/src/modules/modeling/` para editor y vista de historial.
- Sincronizar diseño UI con equipo UX antes del primer incremento funcional.
