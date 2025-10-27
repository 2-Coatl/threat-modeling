# UC-API-000: Gestionar autenticación y tokens

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-000
**Versión:** 1.1
**Fecha:** 2025-11-02

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-000|
|**Nombre**|Gestionar autenticación y tokens|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|BASE DE DATOS, SERVICIO DE AUDITORÍA, SERVICIO DE MENSAJERÍA|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Alta — controla el acceso seguro a todos los recursos|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la UI registre usuarios, autentique credenciales y valide tokens JWT para proteger los endpoints.
- **Resultado esperado:** La API entrega credenciales válidas y bloquea solicitudes con tokens expirados o inválidos.
- **Alcance incluye:**
  - ✅ Registrar cuentas nuevas verificando unicidad del correo y políticas de contraseña.
  - ✅ Iniciar sesión validando contraseña, aplicando rate limiting e invocando MFA cuando aplique.
  - ✅ Validar tokens en middleware antes de acceder a rutas protegidas y renovar sesiones activas.
  - ✅ Administrar activación, validación y revocación del 2FA basado en TOTP.
- **Fuera de alcance:**
  - ❌ Recuperación de contraseñas (pendiente de definición).

---

## 3. PRECONDICIONES

- La base de datos de usuarios está disponible.
- Existe una clave secreta configurada para firmar JWT.
- El servicio de auditoría puede registrar eventos de autenticación.
- El servicio de mensajería tiene credenciales válidas para enviar correos de alerta.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía `POST /api/auth/register` con correo, nombre y contraseña que cumple la política.|
|2|API|Verifica unicidad del correo, encripta la contraseña, guarda auditoría y envía correo de bienvenida seguro.|
|3|SERVICIO DE UI|Envía `POST /api/auth/login` con credenciales válidas.|
|4|API|Valida contraseña, evalúa intentos previos para rate limiting y genera token JWT de 7 días.|
|5|API|Determina si el usuario tiene 2FA habilitado y devuelve challenge `pending_mfa` cuando corresponde.|
|6|SERVICIO DE UI|Invoca `POST /api/auth/mfa/verify` con el código TOTP recibido del usuario.|
|7|API|Valida el código TOTP, registra la verificación y emite respuesta final con datos de sesión.|
|8|SERVICIO DE UI|Incluye el token en `Authorization` al consumir endpoints protegidos.|
|9|MIDDLEWARE DE API|Decodifica el token, verifica vigencia, aplica comprobaciones de IP y recupera el usuario activo.|
|10|API|Renueva el token cuando está próximo a expirar, registra los eventos de autenticación y distribuye alertas según la política.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El usuario intenta iniciar sesión con credenciales incorrectas|La API responde `401 Unauthorized`, incrementa el contador de intentos y registra evento `LOGIN_FAILED`.|
|FA-02|El token expira|El middleware devuelve `401 Unauthorized` con mensaje "Token expirado" e invita a renovar la sesión mediante refresh.|
|FA-03|El usuario habilita 2FA|La API expone `POST /api/auth/mfa/enable`, devuelve el secreto en QR/base32, solicita verificación del primer código y confirma activación con mensaje y correo.|
|FA-04|El usuario deshabilita 2FA|La API requiere contraseña vigente y código TOTP en `POST /api/auth/mfa/disable`, revoca el secreto y envía correo de alerta.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Se detecta un token malformado|La API responde `401 Unauthorized` con mensaje "Token inválido", marca el intento como sospechoso y envía alerta.|
|FE-02|El usuario se encuentra inactivo en la base de datos|La API devuelve `401 Unauthorized` indicando "Cuenta deshabilitada" y no permite avanzar.|
|FE-03|Se excede el rate limiting de login (5 intentos/5min)|La API responde `429 Too Many Requests`, registra `LOGIN_RATE_LIMITED` y dispara correo de seguridad.|
|FE-04|La verificación TOTP falla 5 veces consecutivas|La API bloquea temporalmente el segundo factor, notifica por email y solicita regenerar códigos.|
|FE-05|Falla la inserción en base de datos|La API responde `500 Internal Server Error` y registra el error para seguimiento de operaciones.|

---

## 7. POSTCONDICIONES

- **Éxito:** Se crea o autentica el usuario y la sesión queda representada por un token válido adjunto a futuras solicitudes.
- **Fallo:** No se actualiza la información; las solicitudes subsecuentes requieren autenticación válida.

---

## 8. REQUISITOS ESPECIALES

- Los tokens deben firmarse con algoritmo HS256 e incluir `user_id`, `email`, `role`, `exp`, `mfa`. 
- Las contraseñas se almacenan utilizando bcrypt con factor de costo 12 como mínimo y se valida complejidad (longitud, mayúsculas, minúsculas, números).
- Cada operación debe registrar un evento de auditoría con timestamp, dirección IP y user agent de la petición.
- Los secretos TOTP se almacenan cifrados y los códigos de recuperación se muestran una sola vez.
- Las alertas de actividad sospechosa y cambios de 2FA se envían mediante el servicio de mensajería y se registran en la bandeja de mensajes.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-004, UC-API-001, UC-API-009, UC-API-013.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** El endpoint de refresh tokens quedará documentado cuando se implemente la rotación.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-000-01|Incluir ejemplos de payload de auditoría en el manual de operaciones.|Pendiente|Operaciones|
|TD-API-000-02|Documentar política de expiración configurable del token.|En curso|Seguridad|
