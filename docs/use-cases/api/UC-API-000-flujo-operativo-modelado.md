# UC-API-000: Gestionar autenticación y tokens

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-000
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-000|
|**Nombre**|Gestionar autenticación y tokens|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|BASE DE DATOS, SERVICIO DE AUDITORÍA|
|**Frecuencia estimada**|Alta|
|**Prioridad**|Alta — controla el acceso seguro a todos los recursos|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que la UI registre usuarios, autentique credenciales y valide tokens JWT para proteger los endpoints.
- **Resultado esperado:** La API entrega credenciales válidas y bloquea solicitudes con tokens expirados o inválidos.
- **Alcance incluye:**
  - ✅ Registrar cuentas nuevas verificando unicidad del correo.
  - ✅ Iniciar sesión validando contraseña y generando JWT.
  - ✅ Validar tokens en middleware antes de acceder a rutas protegidas.
- **Fuera de alcance:**
  - ❌ Gestión de roles avanzados o MFA (se abordará en otro caso de uso).
  - ❌ Recuperación de contraseñas (pendiente de definición).

---

## 3. PRECONDICIONES

- La base de datos de usuarios está disponible.
- Existe una clave secreta configurada para firmar JWT.
- El servicio de auditoría puede registrar eventos de autenticación.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Envía `POST /api/auth/register` con correo, nombre y contraseña.| 
|2|API|Verifica unicidad del correo, encripta la contraseña y registra al usuario.| 
|3|SERVICIO DE UI|Envía `POST /api/auth/login` con credenciales válidas.| 
|4|API|Valida la contraseña, genera token JWT con expiración de 7 días y responde con datos de usuario.| 
|5|SERVICIO DE UI|Incluye el token en el encabezado `Authorization` al consumir endpoints protegidos.| 
|6|MIDDLEWARE DE API|Decodifica el token, verifica vigencia y recupera el usuario activo antes de invocar la ruta solicitada.| 
|7|API|Registra los eventos de registro, inicio de sesión y validación en la bitácora de auditoría.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El usuario intenta iniciar sesión con credenciales incorrectas|La API responde `401 Unauthorized` con mensaje "Credenciales inválidas" sin detallar cuál campo falló.| 
|FA-02|El token expira|El middleware devuelve `401 Unauthorized` con mensaje "Token expirado" y solicita renovar sesión.| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Se detecta un token malformado|La API responde `401 Unauthorized` con mensaje "Token inválido" y registra el incidente.| 
|FE-02|El usuario se encuentra inactivo en la base de datos|La API devuelve `401 Unauthorized` indicando "Cuenta deshabilitada" y no permite avanzar.| 
|FE-03|Falla la inserción en base de datos|La API responde `500 Internal Server Error` y registra el error para seguimiento de operaciones.| 

---

## 7. POSTCONDICIONES

- **Éxito:** Se crea o autentica el usuario y la sesión queda representada por un token válido adjunto a futuras solicitudes.
- **Fallo:** No se actualiza la información; las solicitudes subsecuentes requieren autenticación válida.

---

## 8. REQUISITOS ESPECIALES

- Los tokens deben firmarse con algoritmo HS256 e incluir `user_id`, `email`, `role` y `exp`.
- Las contraseñas se almacenan utilizando bcrypt con factor de costo 12 como mínimo.
- Cada operación debe registrar un evento de auditoría con timestamp y dirección IP de la petición.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-004, UC-API-001.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** El endpoint de refresh tokens quedará documentado cuando se implemente la rotación.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-000-01|Incluir ejemplos de payload de auditoría en el manual de operaciones.|Pendiente|Operaciones|
|TD-API-000-02|Documentar política de expiración configurable del token.|En curso|Seguridad|
