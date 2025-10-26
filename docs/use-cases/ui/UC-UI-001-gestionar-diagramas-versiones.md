# UC-UI-001: Gestionar diagramas y versiones

**Sistema:** Threat Modeling UI
**Caso de Uso:** UC-UI-001
**Versión:** 0.2
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-UI-001|
|**Nombre**|Gestionar diagramas y versiones|
|**Actor primario**|AUTOR FUNCIONAL|
|**Actores de soporte**|REVISOR DE SEGURIDAD|
|**Frecuencia estimada**|Diaria|
|**Prioridad**|Alta — habilita el ciclo de edición y publicación|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Brindar al AUTOR FUNCIONAL un entorno web para crear, revisar y mantener diagramas de threat modeling con control de versiones.
- **Resultado esperado:** El autor mantiene el diagrama actualizado, conoce su historial y puede preparar el análisis correspondiente.
- **Alcance incluye:**
  - ✅ Editar el diagrama activo con soporte de historial y comentarios.
  - ✅ Solicitar previsualizaciones y guardados de forma integrada.
  - ✅ Iniciar acciones de análisis o restauración apoyándose en la API.
- **Fuera de alcance:**
  - ❌ Aprobar hallazgos de seguridad.
  - ❌ Administrar permisos de acceso (gestionados por la plataforma).

---

## 3. PRECONDICIONES

- El AUTOR FUNCIONAL cuenta con credenciales válidas y acceso al proyecto.
- La API se encuentra disponible para atender solicitudes.
- Existen diagramas previos o el autor tiene permiso para crear uno nuevo.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|AUTOR FUNCIONAL|Accede a la UI y selecciona el proyecto a editar.
|2|SISTEMA|Muestra el editor con el diagrama vigente y su historial reciente.
|3|AUTOR FUNCIONAL|Realiza ajustes en el contenido y solicita previsualizar los cambios.
|4|SISTEMA|Muestra la vista previa y resalta posibles advertencias.
|5|AUTOR FUNCIONAL|Confirma el guardado registrando la descripción del cambio.
|6|SISTEMA|Informa que la versión quedó registrada y actualiza el historial visible.
|7|AUTOR FUNCIONAL|Opcionalmente inicia el análisis o navega a los hallazgos recientes.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Se detectan errores durante la previsualización|El SISTEMA comunica los errores y permanece en modo edición para que el AUTOR FUNCIONAL corrija.
|FA-02|El autor decide descartar cambios|El SISTEMA restaura la última versión confirmada sin registrar nueva actividad.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|La sesión expira mientras se edita|El SISTEMA guarda temporalmente el contenido local y solicita volver a autenticarse.
|FE-02|La API no está disponible|El SISTEMA bloquea acciones de guardado, informa la falla y sugiere reintentar más tarde.

---

## 7. POSTCONDICIONES

- **Éxito:** El diagrama se actualiza con la nueva versión y el historial refleja la actividad.
- **Fallo:** No se guardan cambios y se mantiene la última versión válida con el motivo del fallo comunicado.

---

## 8. REQUISITOS ESPECIALES

- El editor debe preservar borradores locales para prevenir pérdida de trabajo.
- Las notificaciones deben indicar claramente qué caso de uso API soportó cada acción para facilitar la trazabilidad.

