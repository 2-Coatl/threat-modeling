# UC-UI-004: Autenticar acceso a la plataforma

**Sistema:** Threat Modeling UI
**Caso de Uso:** UC-UI-004
**Versión:** 1.1
**Fecha:** 2025-11-02

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-UI-004|
|**Nombre**|Autenticar acceso a la plataforma|
|**Actor primario**|USUARIO FINAL|
|**Actores de soporte**|SERVICIO DE API, SERVICIO DE MENSAJERÍA|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Alta — garantiza que solo usuarios autorizados operen la plataforma|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que el USUARIO FINAL cree credenciales, inicie sesión y mantenga una sesión válida para operar la plataforma.
- **Resultado esperado:** El usuario queda autenticado con un token vigente y acceso directo al panel principal.
- **Alcance incluye:**
  - ✅ Registrar cuentas nuevas mediante un formulario guiado que valida la contraseña en vivo.
  - ✅ Iniciar sesión, validar tokens y completar desafíos de segundo factor cuando aplique.
  - ✅ Detectar y comunicar el estado de la sesión en navegación posterior, incluyendo alertas de expiración.
  - ✅ Administrar la activación y revocación del 2FA basado en TOTP desde la pantalla de seguridad.
- **Fuera de alcance:**
  - ❌ Administrar roles y permisos avanzados (cubierto por casos de uso de colaboración).

---

## 3. PRECONDICIONES

- El USUARIO FINAL accede a la URL pública de la plataforma.
- Los servicios de autenticación del backend están operativos.
- El navegador soporta almacenamiento local (localStorage) para persistir el token.
- Cuando el usuario tiene 2FA habilitado, dispone de una aplicación TOTP sincronizada.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|USUARIO FINAL|Selecciona "Registrarse" e ingresa nombre, correo y contraseña que cumple los requisitos.| 
|2|SISTEMA|Valida los campos, envía la solicitud a la API y confirma el registro mostrando mensaje de éxito.| 
|3|USUARIO FINAL|Pulsa "Iniciar sesión", ingresa credenciales y confirma el formulario.| 
|4|SISTEMA|Recibe el token JWT, lo almacena en Redux y localStorage, y redirige al flujo de segundo factor cuando es requerido.|
|5|USUARIO FINAL|Ingresa el código TOTP desde su aplicación de autenticación y confirma.|
|6|SISTEMA|Valida el TOTP, finaliza el proceso de login y dirige al panel de modelos.|
|7|USUARIO FINAL|Navega por la aplicación; el token se adjunta automáticamente en solicitudes subsecuentes.|
|8|SISTEMA|Verifica el estado del token en cada vista protegida, renueva la sesión silenciosamente y alerta cuando restan 2 minutos para expirar.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El USUARIO FINAL ya posee cuenta|Selecciona "Iniciar sesión" desde el inicio y continúa desde el Paso 3.| 
|FA-02|El token expira durante la sesión|El SISTEMA informa que la sesión terminó, limpia el almacenamiento y redirige a la pantalla de login.|
|FA-03|El usuario decide habilitar 2FA|El SISTEMA muestra un código QR TOTP, solicita ingresar el primer código y confirma la activación mediante mensaje y correo de seguridad.|
|FA-04|El usuario deshabilita 2FA|El SISTEMA solicita contraseña vigente más código TOTP, confirma la acción y envía correo de alerta informando la desactivación.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El correo ya está registrado|Se muestra alerta "El correo ya existe" y se sugiere iniciar sesión o recuperar contraseña.| 
|FE-02|Las credenciales son inválidas|Se despliega mensaje "Credenciales incorrectas" sin revelar cuál dato falló y registra el intento en la bitácora de seguridad.|
|FE-03|Se excede el límite de intentos por minuto|El SISTEMA bloquea temporalmente la acción, inicia temporizador de reintento y envía notificación de actividad sospechosa.|
|FE-04|El backend no responde|Se presenta aviso "Servicio no disponible" y se permite reintentar sin borrar los datos capturados.|

---

## 7. POSTCONDICIONES

- **Éxito:** El usuario queda autenticado, el token vigente reside en el almacenamiento local y la navegación continúa sin interrupciones.
- **Fallo:** No se almacena ningún token; el usuario permanece en la pantalla de acceso con el mensaje correspondiente.

---

## 8. REQUISITOS ESPECIALES

- Las validaciones de contraseña deben ejecutarse en tiempo real para guiar al usuario antes de enviar el formulario, aplicando los criterios de longitud y complejidad.
- Los mensajes de error no deben exponer detalles técnicos (stacktrace, códigos internos) y siempre registran actividad en audit_log.
- Se debe avisar con antelación (toast) cuando falten 2 minutos para el vencimiento de la sesión activa y ofrecer renovación inmediata.
- Las alertas por activación/desactivación de 2FA se muestran en pantalla, se envían por email y quedan en la bandeja de mensajes.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-API-000, UC-API-009, UC-UI-001, UC-UI-003.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** La pantalla de onboarding debe alinear mensajes con el manual de seguridad corporativa.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-UI-004-01|Documentar mockups responsivos del formulario de registro.|Pendiente|UX|
|TD-UI-004-02|Agregar escenarios de recuperación de contraseña una vez que la API los exponga.|Pendiente|Producto|
