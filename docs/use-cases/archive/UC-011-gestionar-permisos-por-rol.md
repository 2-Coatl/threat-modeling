# UC-011: Gestionar permisos por rol (Archivado)

> **Estado:** Caso de uso histórico perteneciente a la plataforma IACT. Se conserva
> únicamente como referencia y no forma parte del alcance vigente.

**Sistema:** IACT - IVR Analytics & Customer Tracking
**Caso de Uso:** UC-011
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-011|
|**Nombre**|Gestionar permisos por rol|
|**Actor primario**|ADMINISTRADOR DE USUARIOS|
|**Actores de soporte**|ADMINISTRADOR DE SISTEMA|
|**Frecuencia estimada**|Baja|
|**Prioridad**|Media — relevante solo para auditorías de la solución heredada|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Consultar la matriz de permisos estáticos definida para los 18 roles de la solución IACT.
- **Resultado esperado:** El actor visualiza roles, permisos y usuarios asociados sin modificar la configuración.
- **Alcance incluye:**
  - ✅ Listar roles disponibles y sus descripciones.
  - ✅ Revisar permisos asignados a cada rol.
  - ✅ Exportar la matriz de referencia para auditoría.
- **Fuera de alcance:**
  - ❌ Crear o eliminar roles.
  - ❌ Alterar los permisos asociados.

---

## 3. PRECONDICIONES

- El actor posee credenciales activas en la plataforma IACT.
- La base de datos histórica se encuentra accesible en modo consulta.
- La sesión del actor mantiene privilegios de administrador.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|ADMINISTRADOR DE USUARIOS|Accede al módulo histórico de roles.
|2|SISTEMA|Muestra la lista de roles con datos esenciales.
|3|ADMINISTRADOR DE USUARIOS|Selecciona un rol para revisar sus permisos.
|4|SISTEMA|Presenta la matriz de permisos y usuarios asociados.
|5|ADMINISTRADOR DE USUARIOS|Descarga la matriz o registra observaciones para auditoría.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El actor requiere comparar roles|El SISTEMA permite seleccionar múltiples roles y muestra permisos compartidos y diferenciales.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El repositorio histórico no está disponible|El SISTEMA informa la indisponibilidad y solicita contactar a soporte legado.

---

## 7. POSTCONDICIONES

- **Éxito:** El actor obtiene la información necesaria para auditoría sin modificar configuraciones.
- **Fallo:** No se muestra información y se documenta la razón para futuras consultas.

---

## 8. REQUISITOS ESPECIALES

- Toda consulta debe quedar registrada para fines de auditoría.
- Los datos exportados deben incluir sellos de tiempo y usuario responsable.

