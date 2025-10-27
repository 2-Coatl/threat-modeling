# UC-UI-004: Autenticar acceso a la plataforma

**Sistema:** Threat Modeling UI
**Caso de Uso:** UC-UI-004
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-UI-004|
|**Nombre**|Autenticar acceso a la plataforma|
|**Actor primario**|USUARIO FINAL|
|**Actores de soporte**|SERVICIO DE API|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Alta — garantiza que solo usuarios autorizados operen la plataforma|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que el USUARIO FINAL cree credenciales, inicie sesión y mantenga una sesión válida para operar la plataforma.
- **Resultado esperado:** El usuario queda autenticado con un token vigente y acceso directo al panel principal.
- **Alcance incluye:**
  - ✅ Registrar cuentas nuevas mediante un formulario guiado.
  - ✅ Iniciar sesión y almacenar el contexto de autenticación.
  - ✅ Detectar y comunicar el estado de la sesión en navegación posterior.
- **Fuera de alcance:**
  - ❌ Gestionar políticas de contraseñas avanzadas o MFA (se delega a la API y al área de seguridad).
  - ❌ Administrar roles y permisos avanzados (cubierto por casos de uso de colaboración).

---

## 3. PRECONDICIONES

- El USUARIO FINAL accede a la URL pública de la plataforma.
- Los servicios de autenticación del backend están operativos.
- El navegador soporta almacenamiento local (localStorage) para persistir el token.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|USUARIO FINAL|Selecciona "Registrarse" e ingresa nombre, correo y contraseña que cumple los requisitos.| 
|2|SISTEMA|Valida los campos, envía la solicitud a la API y confirma el registro mostrando mensaje de éxito.| 
|3|USUARIO FINAL|Pulsa "Iniciar sesión", ingresa credenciales y confirma el formulario.| 
|4|SISTEMA|Recibe el token JWT, lo almacena en Redux y localStorage, y redirige al panel de modelos.| 
|5|USUARIO FINAL|Navega por la aplicación; el token se adjunta automáticamente en solicitudes subsecuentes.| 
|6|SISTEMA|Verifica el estado del token en cada vista protegida y mantiene la sesión activa mientras sea válido.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El USUARIO FINAL ya posee cuenta|Selecciona "Iniciar sesión" desde el inicio y continúa desde el Paso 3.| 
|FA-02|El token expira durante la sesión|El SISTEMA informa que la sesión terminó, limpia el almacenamiento y redirige a la pantalla de login.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El correo ya está registrado|Se muestra alerta "El correo ya existe" y se sugiere iniciar sesión o recuperar contraseña.| 
|FE-02|Las credenciales son inválidas|Se despliega mensaje "Credenciales incorrectas" sin revelar cuál dato falló.| 
|FE-03|El backend no responde|Se presenta aviso "Servicio no disponible" y se permite reintentar sin borrar los datos capturados.|

---

## 7. POSTCONDICIONES

- **Éxito:** El usuario queda autenticado, el token vigente reside en el almacenamiento local y la navegación continúa sin interrupciones.
- **Fallo:** No se almacena ningún token; el usuario permanece en la pantalla de acceso con el mensaje correspondiente.

---

## 8. REQUISITOS ESPECIALES

- Las validaciones de contraseña deben ejecutarse en tiempo real para guiar al usuario antes de enviar el formulario.
- Los mensajes de error no deben exponer detalles técnicos (stacktrace, códigos internos).
- Se debe avisar con antelación (toast) cuando falten 2 minutos para el vencimiento de la sesión activa.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-API-000, UC-UI-001.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** La pantalla de onboarding debe alinear mensajes con el manual de seguridad corporativa.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-UI-004-01|Documentar mockups responsivos del formulario de registro.|Pendiente|UX|
|TD-UI-004-02|Agregar escenarios de recuperación de contraseña una vez que la API los exponga.|Pendiente|Producto|
