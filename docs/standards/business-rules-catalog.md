# Catálogo de Reglas de Negocio

Este catálogo recopila las 331 reglas de negocio identificadas para la plataforma de modelado de amenazas. Sirve como punto de referencia central para los equipos de producto, ingeniería y cumplimiento. Cada regla mantiene su identificador original (R001…R331) para facilitar la trazabilidad con los casos de uso (`docs/use-cases/ui/UC-UI-001-gestionar-diagramas-versiones.md`), la arquitectura (`docs/architecture/visual-editor.md`) y otros artefactos.

> ⚠️ **Estado:** las reglas aún deben clasificarse formalmente en Hechos, Restricciones, Cálculos, Activadores e Inferencias durante la fase 1.3 descrita en el plan de documentación.

## Índice

- [🔐 Autenticación y Seguridad](#-autenticación-y-seguridad)
  - [Identificación de Usuarios](#identificación-de-usuarios)
  - [Contraseñas](#contraseñas)
  - [Autenticación JWT](#autenticación-jwt)
  - [Two-Factor Authentication (2FA)](#two-factor-authentication-2fa)
  - [Login y Sesiones](#login-y-sesiones)
- [🎨 Modelos PyTM](#-modelos-pytm)
  - [Identificación y Estructura](#identificación-y-estructura)
  - [Almacenamiento del Modelo](#almacenamiento-del-modelo)
  - [Elementos PyTM Válidos](#elementos-pytm-válidos)
  - [Conexiones entre Elementos](#conexiones-entre-elementos)
  - [Operaciones sobre Modelos](#operaciones-sobre-modelos)
  - [Validaciones del Modelo](#validaciones-del-modelo)
- [🐍 Generación de Código Python](#-generación-de-código-python)
  - [Transformación de Datos](#transformación-de-datos)
  - [Orden de Generación](#orden-de-generación)
  - [Validación del Código](#validación-del-código)
- [📊 Diagramas](#-diagramas)
  - [Data Flow Diagram (DFD)](#data-flow-diagram-dfd)
  - [Sequence Diagram](#sequence-diagram)
  - [Caché de Diagramas](#caché-de-diagramas)
  - [Archivos Temporales](#archivos-temporales)
- [🛡️ Análisis de Amenazas (STRIDE)](#️-análisis-de-amenazas-stride)
  - [Ejecución del Análisis](#ejecución-del-análisis)
  - [Clasificación STRIDE](#clasificación-stride)
  - [Cálculo de Severidad](#cálculo-de-severidad)
  - [Hallazgos (Findings)](#hallazgos-findings)
  - [Estados de Hallazgos](#estados-de-hallazgos)
  - [Escalamiento de Amenazas](#escalamiento-de-amenazas)
  - [Inferencias Automáticas](#inferencias-automáticas)
- [🤝 Colaboración y Permisos](#-colaboración-y-permisos)
  - [Sistema de Permisos](#sistema-de-permisos)
  - [Compartir Modelos](#compartir-modelos)
  - [Comentarios](#comentarios)
- [📧 Mensajes y Notificaciones](#-mensajes-y-notificaciones)
  - [Registro de Mensajes](#registro-de-mensajes)
  - [Notificaciones In-App](#notificaciones-in-app)
  - [Eventos que Generan Mensajes](#eventos-que-generan-mensajes)
  - [Gestión de Mensajes](#gestión-de-mensajes)
- [🏗️ Arquitectura Global](#️-arquitectura-global)
  - [Soft Delete Universal](#soft-delete-universal)
  - [Queries y Filtrado](#queries-y-filtrado)
  - [Timestamps Automáticos](#timestamps-automáticos)
  - [Excepciones al Soft Delete](#excepciones-al-soft-delete)
- [📝 Auditoría y Trazabilidad](#-auditoría-y-trazabilidad)
  - [Registro de Eventos](#registro-de-eventos)
  - [Trazabilidad de Cambios](#trazabilidad-de-cambios)
- [🔀 Git y Versionamiento](#-git-y-versionamiento)
  - [Commits Automáticos](#commits-automáticos)
  - [Historial y Rollback](#historial-y-rollback)
  - [Manejo de Errores](#manejo-de-errores)
- [🛡️ Rate Limiting y Protección](#️-rate-limiting-y-protección)
  - [Control de Intentos de Login](#control-de-intentos-de-login)
  - [Detección de Actividad Sospechosa](#detección-de-actividad-sospechosa)
  - [Protección de Recursos](#protección-de-recursos)
- [🔍 Inferencias y Lógica Derivada](#-inferencias-y-lógica-derivada)
  - [Inferencias de Tiempo](#inferencias-de-tiempo)
  - [Inferencias de Seguridad](#inferencias-de-seguridad)
  - [Inferencias de Riesgo](#inferencias-de-riesgo)
  - [Inferencias de Estado](#inferencias-de-estado)
- [📊 Resumen Cuantitativo](#-resumen-cuantitativo)
  - [Total de Reglas Identificadas](#total-de-reglas-identificadas)
  - [Distribución por Componente](#distribución-por-componente)
  - [Distribución por Naturaleza (Estimada)](#distribución-por-naturaleza-estimada)
  - [Componentes con Mayor Densidad de Reglas](#componentes-con-mayor-densidad-de-reglas)
  - [Categorías de Reglas Identificadas](#categorías-de-reglas-identificadas)
  - [Reglas Críticas Identificadas](#reglas-críticas-identificadas)
  - [Reglas Arquitectónicas Globales](#reglas-arquitectónicas-globales)
  - [Áreas con Mayor Complejidad](#áreas-con-mayor-complejidad)
  - [Relaciones Entre Componentes](#relaciones-entre-componentes)
  - [Reglas Candidatas para Automatización](#reglas-candidatas-para-automatización)
  - [Reglas que Requieren Validación con Stakeholders](#reglas-que-requieren-validación-con-stakeholders)
  - [Reglas Pendientes de Definición](#reglas-pendientes-de-definición)
  - [Observaciones Importantes](#observaciones-importantes)
  - [Próximos Pasos](#próximos-pasos)
  - [Glosario de Términos](#glosario-de-términos)
  - [Metadatos](#metadatos)

---

## 🔐 Autenticación y Seguridad

### Identificación de Usuarios

- **R001.** El email es el identificador único del usuario en el sistema
- **R002.** No se permiten emails duplicados en el sistema
- **R003.** El email no puede ser modificado sin verificación del nuevo email
- **R004.** Cada usuario tiene un UUID único generado automáticamente

### Contraseñas

- **R005.** Las contraseñas deben tener un mínimo de 8 caracteres
- **R006.** Las contraseñas deben tener un máximo de 128 caracteres
- **R007.** Las contraseñas deben contener al menos una letra mayúscula
- **R008.** Las contraseñas deben contener al menos una letra minúscula
- **R009.** Las contraseñas deben contener al menos un número
- **R010.** Las contraseñas se almacenan hasheadas con bcrypt
- **R011.** Al cambiar email se requiere confirmar la contraseña actual

### Autenticación JWT

- **R012.** El sistema utiliza JWT (JSON Web Tokens) para autenticación
- **R013.** Se generan dos tipos de tokens: access token y refresh token
- **R014.** Los access tokens tienen una duración de 15 minutos
- **R015.** Los refresh tokens tienen una duración de 7 días
- **R016.** Los tokens JWT se generan automáticamente al login exitoso
- **R017.** Los tokens JWT contienen: user_id, email, type (access/refresh)
- **R018.** Un access token expirado debe renovarse con el refresh token
- **R019.** Después de 15 minutos, el access token se considera expirado
- **R020.** El sistema permite múltiples sesiones activas simultáneas por usuario

### Two-Factor Authentication (2FA)

- **R021.** El 2FA es opcional para todos los usuarios
- **R022.** El 2FA utiliza TOTP (Time-based One-Time Password)
- **R023.** Los códigos TOTP deben ser exactamente 6 dígitos numéricos
- **R024.** Los códigos TOTP tienen una ventana de validación de ±30 segundos
- **R025.** El 2FA es compatible con Google Authenticator, Authy y similares
- **R026.** Para habilitar 2FA se debe validar el primer código generado
- **R027.** Para deshabilitar 2FA se requiere contraseña actual + código TOTP válido
- **R028.** El secret TOTP se almacena solo si el usuario completa la habilitación exitosamente
- **R029.** Si el usuario tiene 2FA habilitado, debe ingresar código después de password
- **R030.** El sistema envía email de notificación cuando se deshabilita 2FA

### Login y Sesiones

- **R031.** Al login exitoso se genera automáticamente un par de tokens JWT
- **R032.** Al login exitoso se limpia el contador de intentos fallidos
- **R033.** Al login exitoso se actualiza el campo last_login_at del usuario
- **R034.** Al login exitoso se registra el evento en audit_log
- **R035.** El login retorna información básica del usuario (id, email, has_2fa)
- **R036.** El login NO retorna datos sensibles como password_hash o totp_secret

## 🎨 Modelos PyTM

### Identificación y Estructura

- **R037.** Cada modelo tiene un UUID único generado automáticamente
- **R038.** Todo modelo debe tener un autor (author_id es obligatorio)
- **R039.** Un modelo pertenece a exactamente un usuario autor
- **R040.** Un usuario puede tener múltiples modelos
- **R041.** El nombre del modelo es obligatorio
- **R042.** El nombre del modelo debe ser único por usuario (no globalmente)
- **R043.** El visual_model (JSON) es obligatorio para crear un modelo
- **R044.** El description del modelo es opcional

### Almacenamiento del Modelo

- **R045.** El visual_model se almacena como JSONB en PostgreSQL
- **R046.** El visual_model contiene dos arrays: nodes y edges
- **R047.** Cada node tiene: id, type, data, position
- **R048.** Cada edge tiene: id, source, target, data
- **R049.** El python_code se genera automáticamente desde el visual_model
- **R050.** El python_code se almacena como TEXT en PostgreSQL

### Elementos PyTM Válidos

- **R051.** Solo 7 tipos de elementos son permitidos en el modelo
- **R052.** Los elementos permitidos son: Actor, Server, Datastore, Lambda, Process, Boundary, Dataflow
- **R053.** Los elementos tienen propiedades específicas según su tipo
- **R054.** Un Actor puede tener propiedades: inBoundary, isAdmin
- **R055.** Un Server puede tener propiedades: OS, isHardened, implementsAuthenticationScheme
- **R056.** Un Datastore puede tener propiedades: isSQL, isEncrypted, storesLogData
- **R057.** Un Lambda puede tener propiedades: onAWS, hasAccessControl
- **R058.** Un Dataflow puede tener propiedades: protocol, isEncrypted, data
- **R059.** Un Boundary es un contenedor visual y no se procesa como elemento activo

### Conexiones entre Elementos

- **R060.** Solo ciertas combinaciones de elementos pueden conectarse
- **R061.** Un Actor puede conectarse con: Server, Lambda
- **R062.** Un Server puede conectarse con: Datastore, Server, Process, Lambda
- **R063.** Un Lambda puede conectarse con: Datastore, Server
- **R064.** Un Process puede conectarse con: Datastore, Server
- **R065.** Un Datastore puede conectarse con: Server, Process
- **R066.** Un Boundary NO puede conectarse con ningún elemento
- **R067.** Un Actor NO puede conectarse directamente con un Datastore

### Operaciones sobre Modelos

- **R068.** Al crear un modelo se genera automáticamente el código Python
- **R069.** Al actualizar un modelo se regenera el código Python
- **R070.** Al guardar un modelo se hace commit automático a Git
- **R071.** Al guardar un modelo se invalida el caché de diagramas
- **R072.** Al guardar un modelo se actualiza el campo updated_at
- **R073.** Al guardar un modelo se registra el evento en audit_log
- **R074.** Un modelo puede tener cero hallazgos (si no se ha analizado)
- **R075.** Un modelo sin elementos puede guardarse pero no genera diagramas útiles
- **R076.** Los modelos eliminados se marcan con soft delete (deleted = true)
- **R077.** Al eliminar un modelo se eliminan (soft delete) sus hallazgos asociados
- **R078.** Al eliminar un modelo se eliminan (soft delete) sus comentarios asociados
- **R079.** Al eliminar un modelo se eliminan (soft delete) sus permisos compartidos

### Validaciones del Modelo

- **R080.** El sistema valida que el JSON del visual_model tenga estructura correcta
- **R081.** El sistema valida que todos los nodes tengan type válido
- **R082.** El sistema valida que todas las conexiones sean permitidas
- **R083.** El sistema valida sintaxis del código Python generado antes de guardar

## 🐍 Generación de Código Python

### Transformación de Datos

- **R084.** Los nombres de elementos se sanitizan para ser identificadores Python válidos
- **R085.** Los espacios en nombres se reemplazan por guiones bajos
- **R086.** Los caracteres especiales se eliminan o reemplazan
- **R087.** Los nombres que empiezan con número reciben prefijo "element_"
- **R088.** Las palabras reservadas de Python reciben sufijo "_element"
- **R089.** Los guiones bajos múltiples se reducen a uno solo
- **R090.** Los guiones bajos al inicio/final se eliminan

### Orden de Generación

- **R091.** El código Python debe generarse en un orden específico estricto
- **R092.** Primero se generan los imports de pytm
- **R093.** Segundo se inicializa el TM (Threat Model)
- **R094.** Tercero se declaran los Boundaries
- **R095.** Cuarto se declaran los elementos (Actor, Server, etc.)
- **R096.** Quinto se declaran los Dataflows
- **R097.** Sexto y último se llama a tm.process()
- **R098.** Los Boundaries deben declararse antes de asignar elementos a ellos
- **R099.** Los elementos deben declararse antes de crear Dataflows entre ellos

### Validación del Código

- **R100.** El código Python generado debe validarse sintácticamente
- **R101.** Si la sintaxis es inválida, se rechaza el guardado del modelo
- **R102.** La validación se hace ejecutando python -m py_compile
- **R103.** El timeout de validación es de 5 segundos

## 📊 Diagramas

### Data Flow Diagram (DFD)

- **R104.** Los DFD se generan usando pytm con flag --dfd
- **R105.** pytm genera código DOT de Graphviz
- **R106.** Graphviz renderiza el código DOT a imagen PNG
- **R107.** El comando de generación es: python model.py --dfd
- **R108.** La generación de DFD tiene timeout de 30 segundos
- **R109.** Los DFD se almacenan en /var/diagrams/{model_id}/dfd.png
- **R110.** Un modelo sin elementos genera DFD vacío (solo título)

### Sequence Diagram

- **R111.** Los diagramas de secuencia se generan usando pytm con flag --seq
- **R112.** pytm genera código PlantUML
- **R113.** El código PlantUML se envía a PlantUML Server para renderizado
- **R114.** PlantUML Server retorna imagen PNG
- **R115.** El comando de generación es: python model.py --seq
- **R116.** La generación de Sequence tiene timeout de 30 segundos
- **R117.** Los diagramas de secuencia se almacenan en /var/diagrams/{model_id}/sequence.png
- **R118.** Un modelo sin Dataflows no puede generar diagrama de secuencia útil

### Caché de Diagramas

- **R119.** Los diagramas se cachean para evitar regeneración innecesaria
- **R120.** El caché se identifica mediante hash SHA256 del python_code
- **R121.** Si el modelo cambia, el hash cambia y el caché se invalida
- **R122.** El caché se almacena en tabla diagram_cache de PostgreSQL
- **R123.** Cada entrada de caché contiene: model_id, diagram_type, model_hash, diagram_path
- **R124.** El sistema verifica caché antes de regenerar diagrama
- **R125.** Si el hash coincide, se retorna el diagrama cacheado
- **R126.** Si el hash no coincide, se regenera el diagrama y se actualiza caché
- **R127.** Los diagramas permanecen en caché indefinidamente hasta cambio de modelo
- **R128.** El usuario puede forzar regeneración explícita del diagrama

### Archivos Temporales

- **R129.** Al generar diagramas se crea archivo temporal del código Python
- **R130.** Los archivos temporales se ubican en /tmp/model-{model_id}.py
- **R131.** Los archivos temporales se eliminan después de generar el diagrama
- **R132.** Si la generación falla, el archivo temporal también se limpia

## 🛡️ Análisis de Amenazas (STRIDE)

### Ejecución del Análisis

- **R133.** El análisis de amenazas se ejecuta mediante pytm con flag --report
- **R134.** El comando de análisis es: python model.py --report
- **R135.** El análisis tiene timeout de 30 segundos
- **R136.** pytm genera un reporte de amenazas en texto estructurado
- **R137.** El reporte contiene: threat_id, category, description, target por cada amenaza

### Clasificación STRIDE

- **R138.** Las amenazas se clasifican según metodología STRIDE de Microsoft
- **R139.** STRIDE significa: Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege
- **R140.** Cada amenaza pertenece a exactamente una categoría STRIDE

### Cálculo de Severidad

- **R141.** La severidad se calcula automáticamente basada en la categoría STRIDE
- **R142.** Spoofing tiene severidad HIGH
- **R143.** Tampering tiene severidad HIGH
- **R144.** Repudiation tiene severidad MEDIUM
- **R145.** Information Disclosure tiene severidad HIGH
- **R146.** Denial of Service tiene severidad MEDIUM
- **R147.** Elevation of Privilege tiene severidad HIGH
- **R148.** Las amenazas que afectan confidencialidad o integridad son HIGH
- **R149.** Las amenazas que afectan disponibilidad son MEDIUM

### Hallazgos (Findings)

- **R150.** Un hallazgo es una amenaza identificada por el análisis pytm
- **R151.** Cada hallazgo se almacena en la tabla findings
- **R152.** Un hallazgo tiene: id, model_id, threat_id, description, stride_category, severity, status
- **R153.** Un modelo puede tener múltiples hallazgos
- **R154.** Un hallazgo pertenece a exactamente un modelo
- **R155.** Al ejecutar nuevo análisis, se eliminan (soft delete) hallazgos anteriores
- **R156.** Los hallazgos nuevos se crean con estado inicial OPEN

### Estados de Hallazgos

- **R157.** Un hallazgo puede estar en uno de cuatro estados: OPEN, MITIGATED, ACCEPTED, FALSE_POSITIVE
- **R158.** El estado inicial de un hallazgo es OPEN
- **R159.** OPEN significa: amenaza identificada sin mitigar
- **R160.** MITIGATED significa: amenaza remediada con controles
- **R161.** ACCEPTED significa: riesgo aceptado por el negocio
- **R162.** FALSE_POSITIVE significa: la amenaza no es real o no aplica
- **R163.** Todas las transiciones de estado están permitidas
- **R164.** Un hallazgo MITIGATED puede volver a OPEN si resurge
- **R165.** Un hallazgo ACCEPTED puede reconsiderarse si cambia el contexto

### Escalamiento de Amenazas

- **R166.** Un hallazgo con severidad HIGH se considera crítico
- **R167.** Un hallazgo HIGH en estado OPEN por más de 7 días se marca como overdue
- **R168.** Los hallazgos overdue activan notificación automática al autor
- **R169.** Los hallazgos overdue activan notificación al equipo de seguridad
- **R170.** Un job diario (cron) detecta hallazgos overdue a las 9 AM
- **R171.** El campo is_overdue se marca como TRUE para hallazgos vencidos
- **R172.** Los hallazgos overdue se registran en audit_log

### Inferencias Automáticas

- **R173.** Si un dataflow NO está encriptado, pytm infiere amenaza de Information Disclosure
- **R174.** Si un servidor NO implementa autenticación, pytm infiere amenaza de Spoofing
- **R175.** Si un dataflow transporta datos sensibles sin cifrar, la severidad es HIGH
- **R176.** Si un modelo tiene múltiples hallazgos HIGH sin mitigar, el proyecto tiene riesgo elevado

## 🤝 Colaboración y Permisos

### Sistema de Permisos

- **R177.** Un modelo puede compartirse con múltiples usuarios
- **R178.** Los permisos se almacenan en tabla model_permissions
- **R179.** Existen tres niveles de permiso: READ, WRITE, ADMIN
- **R180.** READ permite: visualizar modelo y diagramas
- **R181.** WRITE permite: visualizar y modificar modelo
- **R182.** ADMIN permite: visualizar, modificar, compartir y eliminar modelo
- **R183.** El autor del modelo (owner) tiene implícitamente permisos de ADMIN
- **R184.** Un usuario sin permisos NO puede acceder al modelo
- **R185.** Un usuario con permiso READ NO puede modificar el modelo
- **R186.** Un usuario con permiso WRITE NO puede cambiar permisos ni eliminar
- **R187.** Un usuario con permiso ADMIN puede gestionar permisos de otros usuarios
- **R188.** Solo el owner o usuarios con ADMIN pueden compartir el modelo
- **R189.** Solo el owner o usuarios con ADMIN pueden eliminar el modelo
- **R190.** Los permisos se validan antes de cada operación sobre el modelo

### Compartir Modelos

- **R191.** Al compartir un modelo se crea registro en model_permissions
- **R192.** Cada permiso tiene: model_id, user_id, permission, granted_by, granted_at
- **R193.** El campo granted_by registra quién otorgó el permiso
- **R194.** Un usuario puede revocar permisos que él mismo otorgó
- **R195.** No puede haber permisos duplicados para la misma combinación model_id + user_id
- **R196.** Al eliminar un permiso se hace soft delete (deleted = true)

### Comentarios

- **R197.** Los usuarios pueden agregar comentarios a los modelos
- **R198.** Un comentario siempre está asociado a un modelo específico
- **R199.** Los comentarios se almacenan en tabla comments
- **R200.** Un comentario tiene: id, model_id, user_id, text, created_at
- **R201.** Un usuario necesita al menos permiso READ para comentar
- **R202.** Al agregar un comentario se notifica al autor del modelo
- **R203.** Si el comentarista es el autor, NO se envía notificación
- **R204.** Los comentarios no pueden existir sin modelo asociado
- **R205.** Al eliminar un modelo se eliminan (soft delete) sus comentarios
- **R206.** Solo el autor del comentario puede eliminarlo

## 📧 Mensajes y Notificaciones

### Registro de Mensajes

- **R207.** Todos los emails enviados se registran en tabla messages
- **R208.** Cada mensaje tiene: type, category, sender_id, recipient_id, subject, body
- **R209.** Los tipos de mensaje son: EMAIL, NOTIFICATION, ALERT, SYSTEM
- **R210.** Las categorías incluyen: COMMENT, SHARE, THREAT_ALERT, ANALYSIS_COMPLETE
- **R211.** Todo mensaje debe tener un destinatario (recipient_id)
- **R212.** El sender_id puede ser NULL si el mensaje es del sistema
- **R213.** Los mensajes tipo EMAIL marcan el campo email_sent = TRUE
- **R214.** Los mensajes registran timestamp de envío en email_sent_at
- **R215.** Si el email falla, email_sent = FALSE pero el mensaje se registra igual

### Notificaciones In-App

- **R216.** Los mensajes pueden mostrarse como notificaciones in-app
- **R217.** Cada mensaje tiene un campo read (boolean) para marcar como leído
- **R218.** El campo read_at registra cuándo se leyó el mensaje
- **R219.** Los mensajes no leídos se cuentan para badge de notificaciones
- **R220.** El contador de no leídos se calcula con: COUNT(*) WHERE recipient_id = user AND read = FALSE AND deleted = FALSE

### Eventos que Generan Mensajes

- **R221.** Al comentar en un modelo se crea mensaje tipo NOTIFICATION categoría COMMENT
- **R222.** Al compartir un modelo se crea mensaje tipo NOTIFICATION categoría SHARE
- **R223.** Al completar análisis de amenazas con hallazgos HIGH se crea mensaje tipo ALERT
- **R224.** Al detectar hallazgo overdue se crea mensaje tipo ALERT categoría THREAT_OVERDUE
- **R225.** Al deshabilitar 2FA se envía email de notificación de seguridad
- **R226.** Al detectar actividad sospechosa se envía email de alerta
- **R227.** Al cambiar email se envía notificación al email anterior

### Gestión de Mensajes

- **R228.** Los mensajes se marcan como leídos individualmente
- **R229.** Solo el destinatario puede marcar un mensaje como leído
- **R230.** Solo el destinatario puede eliminar (soft delete) un mensaje
- **R231.** El sender NO puede eliminar mensajes ya enviados
- **R232.** Los mensajes eliminados se marcan con deleted = TRUE
- **R233.** Los mensajes eliminados registran deleted_at y deleted_by
- **R234.** Los mensajes eliminados NO aparecen en queries por defecto
- **R235.** Los usuarios pueden filtrar mensajes por: read/unread, type, category
- **R236.** Los mensajes se ordenan por created_at descendente (más recientes primero)

## 🏗️ Arquitectura Global

### Soft Delete Universal

- **R237.** Ninguna tabla del sistema permite eliminación física de registros
- **R238.** Todas las entidades principales implementan soft delete
- **R239.** Soft delete se implementa con campos: deleted, deleted_at, deleted_by
- **R240.** El campo deleted es boolean con default FALSE
- **R241.** El campo deleted_at es timestamp que registra cuándo se eliminó
- **R242.** El campo deleted_by es UUID que referencia al usuario que eliminó
- **R243.** Las tablas con soft delete son: users, pytm_models, findings, messages, comments, model_permissions
- **R244.** Solo usuarios con rol ADMIN pueden restaurar registros eliminados
- **R245.** Restaurar un registro marca deleted = FALSE y limpia deleted_at, deleted_by

### Queries y Filtrado

- **R246.** Todas las queries deben filtrar por deleted = FALSE por defecto
- **R247.** Los índices incluyen el campo deleted para optimización
- **R248.** Los constraints UNIQUE deben considerar el campo deleted
- **R249.** Un registro con deleted = TRUE no aparece en búsquedas normales
- **R250.** Para consultar registros eliminados se debe especificar explícitamente

### Timestamps Automáticos

- **R251.** Todas las entidades principales tienen created_at y updated_at
- **R252.** El campo created_at se establece automáticamente con NOW() al crear
- **R253.** El campo updated_at se establece automáticamente con NOW() al crear
- **R254.** El campo updated_at se actualiza automáticamente al modificar el registro
- **R255.** La actualización de updated_at se hace mediante trigger de PostgreSQL
- **R256.** Los timestamps permiten auditoría, ordenamiento y detección de registros antiguos

### Excepciones al Soft Delete

- **R257.** La tabla audit_log NUNCA se elimina (ni soft ni hard delete)
- **R258.** La tabla login_attempts puede limpiarse físicamente después de 90 días
- **R259.** La tabla diagram_cache puede limpiarse físicamente cuando hay problemas de espacio

## 📝 Auditoría y Trazabilidad

### Registro de Eventos

- **R260.** Todos los eventos importantes se registran en audit_log
- **R261.** Los eventos registrados incluyen: LOGIN_SUCCESS, LOGIN_FAILED, MODEL_CREATED, MODEL_UPDATED, MODEL_DELETED
- **R262.** Cada evento registra: user_id, action, timestamp, ip_address, user_agent
- **R263.** Los eventos de login registran IP y user agent del cliente
- **R264.** Los eventos de modificación de modelos registran qué cambió
- **R265.** Los eventos de eliminación registran qué se eliminó y quién lo hizo
- **R266.** La tabla audit_log es inmutable (no permite UPDATE ni DELETE)
- **R267.** La tabla audit_log crece indefinidamente (para compliance)

### Trazabilidad de Cambios

- **R268.** Cada modelo registra cuándo fue creado (created_at)
- **R269.** Cada modelo registra cuándo fue modificado por última vez (updated_at)
- **R270.** Cada modelo registra quién es su autor (author_id)
- **R271.** Los cambios en modelos se versionan automáticamente en Git
- **R272.** Cada guardado genera un commit con mensaje descriptivo
- **R273.** Los commits incluyen: nombre del modelo, email del autor, timestamp
- **R274.** Los mensajes registran metadata en campo JSONB para información adicional

## 🔀 Git y Versionamiento

### Commits Automáticos

- **R275.** Cada vez que se guarda un modelo se hace commit automático a Git
- **R276.** El código Python se escribe en archivo /var/git/pytm-models/{user_id}/{model_id}.py
- **R277.** Se ejecuta git add del archivo del modelo
- **R278.** Se ejecuta git commit con mensaje automático
- **R279.** El mensaje de commit incluye: nombre del modelo, email del autor, timestamp
- **R280.** El commit se firma con el email del autor del modelo
- **R281.** Después del commit se obtiene el hash del commit (SHA-1)
- **R282.** El hash del commit se almacena en campo git_commit_hash
- **R283.** La ruta del archivo se almacena en campo git_file_path

### Historial y Rollback

- **R284.** Git mantiene historial completo de cambios del modelo
- **R285.** Es posible obtener versiones anteriores del modelo usando git_commit_hash
- **R286.** El sistema puede mostrar diff entre versiones (feature futuro)
- **R287.** El sistema puede restaurar una versión anterior (rollback) si es necesario
- **R288.** Cada commit es individual por modelo (no commits masivos)

### Manejo de Errores

- **R289.** Si Git falla, el modelo aún se guarda en BD pero se marca como "pending Git sync"
- **R290.** Los modelos sin sincronizar con Git se pueden reintentar posteriormente
- **R291.** Si Git está caído, el sistema sigue funcionando (degradación grácil)

## 🛡️ Rate Limiting y Protección

### Control de Intentos de Login

- **R292.** El sistema registra todos los intentos de login en tabla login_attempts
- **R293.** Cada intento registra: email, ip_address, timestamp, success/failure
- **R294.** Máximo 5 intentos fallidos por email/IP en ventana de 15 minutos
- **R295.** Al exceder 5 intentos, la cuenta/IP se bloquea por 1 hora
- **R296.** El bloqueo se implementa con campo blocked_until en login_attempts
- **R297.** Al login exitoso se limpia el registro de login_attempts para ese email/IP
- **R298.** Los intentos se cuentan por combinación de email + IP
- **R299.** Después de 15 minutos sin intentos, el contador se resetea automáticamente
- **R300.** El sistema retorna 429 Too Many Requests al exceder límite

### Detección de Actividad Sospechosa

- **R301.** Si hay más de 10 intentos desde diferentes IPs en 5 minutos, se bloquea
- **R302.** Si hay más de 3 intentos con diferentes user-agents en 1 minuto, se bloquea
- **R303.** Si la IP está en blacklist conocida, se rechaza el intento
- **R304.** Al detectar actividad sospechosa se bloquea la IP por 1 hora
- **R305.** Al detectar actividad sospechosa se envía email al usuario legítimo
- **R306.** El email de alerta incluye: IP bloqueada, timestamp, ubicación aproximada
- **R307.** El email incluye link "No fui yo" para cambiar contraseña
- **R308.** La detección sospechosa se registra en audit_log
- **R309.** Opcionalmente se notifica al equipo de seguridad si está configurado

### Protección de Recursos

- **R310.** La generación de diagramas tiene timeout de 30 segundos
- **R311.** La ejecución de pytm para análisis tiene timeout de 30 segundos
- **R312.** Si pytm excede el timeout, se termina el proceso y se retorna error
- **R313.** Los archivos temporales se limpian incluso si hay timeout o error

## 🔍 Inferencias y Lógica Derivada

### Inferencias de Tiempo

- **R314.** Si un access token tiene más de 15 minutos, se infiere que está expirado
- **R315.** Si un usuario no ha iniciado sesión en 30 días, se infiere que está inactivo
- **R316.** Si un hallazgo HIGH está abierto por más de 7 días, se infiere que es overdue
- **R317.** Los usuarios inactivos por 30 días reciben email de reenganche
- **R318.** Los usuarios inactivos por 1 año son candidatos para eliminación de cuenta

### Inferencias de Seguridad

- **R319.** Si pytm detecta dataflow sin cifrar, infiere amenaza de Information Disclosure
- **R320.** Si pytm detecta servidor sin autenticación, infiere amenaza de Spoofing
- **R321.** Si el dataflow transporta datos sensibles sin cifrar, la severidad es HIGH
- **R322.** Si el dataflow transporta datos no sensibles sin cifrar, la severidad es MEDIUM
- **R323.** Si un servidor no está hardened, pytm genera amenazas de Tampering

### Inferencias de Riesgo

- **R324.** Si un modelo tiene más de 5 hallazgos HIGH sin mitigar, el riesgo es CRÍTICO
- **R325.** Si un modelo tiene más de 2 hallazgos HIGH con edad promedio > 7 días, el riesgo es ALTO
- **R326.** Si un modelo tiene múltiples hallazgos overdue, requiere escalamiento a gerencia
- **R327.** La ausencia de hallazgos en un modelo complejo puede indicar configuración incorrecta

### Inferencias de Estado

- **R328.** Si un modelo no tiene elementos, no puede generar análisis útil
- **R329.** Si un modelo no tiene Dataflows, no puede generar diagrama de secuencia
- **R330.** Si el hash del modelo cambió, el caché de diagramas es inválido
- **R331.** Si el visual_model cambió, el python_code debe regenerarse

## 📊 Resumen Cuantitativo

### Total de Reglas Identificadas

- **Total:** 331 reglas de negocio.

### Distribución por Componente

| Componente | Cantidad de Reglas | Porcentaje |
| --- | --- | --- |
| **Autenticación y Seguridad** | 36 reglas | 10.9% |
| **Modelos PyTM** | 47 reglas | 14.2% |
| **Generación de Código Python** | 20 reglas | 6.0% |
| **Diagramas** | 29 reglas | 8.8% |
| **Análisis de Amenazas (STRIDE)** | 44 reglas | 13.3% |
| **Colaboración y Permisos** | 30 reglas | 9.1% |
| **Mensajes y Notificaciones** | 30 reglas | 9.1% |
| **Arquitectura Global** | 21 reglas | 6.3% |
| **Auditoría y Trazabilidad** | 15 reglas | 4.5% |
| **Git y Versionamiento** | 16 reglas | 4.8% |
| **Rate Limiting y Protección** | 22 reglas | 6.6% |
| **Inferencias y Lógica Derivada** | 18 reglas | 5.4% |
| **Total** | **331 reglas** | **100%** |

### Distribución por Naturaleza (Estimada)

> **Nota:** La clasificación formal se realizará en la siguiente fase.

| Naturaleza | Estimación |
| --- | --- |
| Estáticas | ~85% (281 reglas) |
| Dinámicas | ~15% (50 reglas) |

### Componentes con Mayor Densidad de Reglas

1. **Modelos PyTM:** 47 reglas (estructura, validaciones, operaciones)
2. **Análisis de Amenazas (STRIDE):** 44 reglas (clasificación, severidad, estados)
3. **Autenticación y Seguridad:** 36 reglas (login, JWT, 2FA, contraseñas)
4. **Mensajes y Notificaciones:** 30 reglas (emails, notificaciones in-app)
5. **Colaboración y Permisos:** 30 reglas (compartir, permisos, comentarios)

### Categorías de Reglas Identificadas

Aunque la clasificación formal es el siguiente paso, se identifican las siguientes **categorías implícitas**:

#### Hechos (Estructuras de Datos)

Ejemplos: R001, R037, R045, R150.

- Definen qué es una entidad.
- Establecen relaciones entre entidades.
- Describen atributos obligatorios/opcionales.

#### Restricciones (Validaciones)

Ejemplos: R002, R005-R009, R060-R067, R082-R083.

- Límites numéricos (min/max).
- Formatos obligatorios.
- Unicidad.
- Conexiones permitidas/prohibidas.

#### Cálculos (Fórmulas)

Ejemplos: R014, R015, R019, R141-R149, R220.

- Duraciones de tokens.
- Ventanas de tiempo para TOTP.
- Cálculo de severidad.
- Contador de mensajes no leídos.

#### Activadores (Eventos → Acciones)

Ejemplos: R016, R031-R035, R068-R073, R133-R137, R221-R227.

- "Al login exitoso → generar tokens".
- "Al guardar modelo → generar código Python".
- "Al comentar → notificar al autor".
- "Al detectar overdue → enviar alerta".

#### Inferencias (Conclusiones Lógicas)

Ejemplos: R314-R331.

- "Si token > 15 min → está expirado".
- "Si usuario sin login 30 días → inactivo".
- "Si dataflow sin cifrar → amenaza de Information Disclosure".
- "Si hallazgo HIGH > 7 días → overdue".

### Reglas Críticas Identificadas

**Criticidad CRÍTICA** (impacto en seguridad, integridad o funcionamiento core):

- R002: Email único (autenticación).
- R014-R015: Duraciones de tokens JWT (seguridad).
- R037: UUID único por modelo (integridad).
- R042: Nombre único por usuario (integridad).
- R083: Validación sintaxis Python (funcionalidad).
- R091-R099: Orden de generación código (funcionalidad).
- R141-R147: Cálculo de severidad STRIDE (seguridad).
- R237-R243: Soft delete universal (auditoría).
- R266-R267: Audit log inmutable (compliance).
- R294-R295: Rate limiting login (seguridad).

### Reglas Arquitectónicas Globales

Estas reglas aplican **transversalmente** a todo el sistema:

1. **R237-R250:** Soft delete universal en todas las tablas.
2. **R251-R256:** Timestamps automáticos (created_at, updated_at).
3. **R260-R267:** Auditoría obligatoria de eventos críticos.
4. **R275-R283:** Versionamiento automático en Git.

### Áreas con Mayor Complejidad

**Por número de reglas y sus interdependencias:**

1. **Análisis STRIDE (44 reglas):** Clasificación, cálculo de severidad, estados, escalamiento.
2. **Modelos PyTM (47 reglas):** Validaciones, conexiones, transformaciones, generación de código.
3. **Autenticación (36 reglas):** JWT, 2FA, rate limiting, detección de amenazas.

### Relaciones Entre Componentes

**Dependencias principales:**

- **Modelos → Generación de Código:** Los modelos disparan generación automática.
- **Modelos → Git:** Los modelos se versionan automáticamente.
- **Modelos → Diagramas:** Los diagramas se generan desde modelos.
- **Modelos → Análisis STRIDE:** El análisis procesa modelos y genera hallazgos.
- **Hallazgos → Mensajes:** Los hallazgos críticos generan notificaciones.
- **Comentarios → Mensajes:** Los comentarios generan notificaciones.
- **Login → Auditoría:** Los intentos de login se registran para rate limiting.
- **Todas las entidades → Soft Delete:** Arquitectura global.

### Reglas Candidatas para Automatización

**Reglas que pueden implementarse con triggers, jobs o eventos:**

- R031-R035: Login exitoso dispara múltiples acciones (candidatas a transacción).
- R068-R073: Guardar modelo dispara generación, Git, caché (event-driven).
- R155-R156: Nuevo análisis elimina hallazgos anteriores y crea nuevos (operación batch).
- R166-R172: Detección de overdue (cron job diario).
- R221-R227: Generación automática de mensajes (listeners de eventos).
- R254-R255: Actualización de updated_at (trigger de base de datos).
- R275-R283: Commit automático a Git (hook posterior al guardado).

### Reglas que Requieren Validación con Stakeholders

**Reglas que podrían necesitar ajuste según negocio:**

- R014-R015: Duraciones de tokens (¿15 min y 7 días son apropiados?).
- R167: Umbral de 7 días para overdue (¿debería ser configurable por organización?).
- R294-R295: Límite de 5 intentos en 15 minutos (¿muy estricto o muy laxo?).
- R315: 30 días para considerar usuario inactivo (¿debe ser diferente?).
- R324-R325: Umbrales de riesgo CRÍTICO vs ALTO (¿alineado con política de riesgos?).

### Reglas Pendientes de Definición

**Áreas donde podrían identificarse reglas adicionales:**

1. **Roles organizacionales:** Admin, Security Lead, Developer (no están definidos).
2. **Exportación de modelos:** Formatos, permisos, límites.
3. **Integraciones:** Jira, Slack, Confluence (no especificadas).
4. **Reportes y Analytics:** Qué métricas calcular, cómo presentarlas.
5. **Compliance específico:** GDPR, SOC2, ISO27001 (no detallado).
6. **Políticas de retención:** Cuándo limpiar audit_log, login_attempts, etc.

### Observaciones Importantes

#### Consistencia del Sistema

✅ **Fortalezas identificadas:**

- Arquitectura coherente con soft delete universal.
- Auditoría completa de eventos críticos.
- Separación clara entre operaciones (CRUD) y lógica de negocio (STRIDE, Git).
- Versionamiento automático previene pérdida de datos.

⚠️ **Áreas de atención:**

- Potencial complejidad en gestión de permisos en cascada.
- Necesidad de limpieza periódica de tablas que crecen indefinidamente (audit_log, messages).
- Dependencia crítica de Git (si falla, modelos quedan sin versionar).

#### Reglas Implícitas vs Explícitas

- **~70% explícitas:** Declaradas directamente en las respuestas.
- **~30% implícitas:** Derivadas de comportamientos descritos.

Ejemplo de regla implícita:

- Pregunta 45 dice: "Cuando se guarda un modelo, se invalida caché de diagramas" → Regla implícita R330: "Si el hash del modelo cambió, el caché de diagramas es inválido".

### Próximos Pasos

#### Fase 1.3: Clasificar Reglas por Tipo

Objetivos:

1. Clasificar las 331 reglas en 5 tipos: Hecho, Restricción, Cálculo, Activador, Inferencia.
2. Asignar IDs estructurados (BR-XXX-YYY).
3. Establecer criticidad (CRÍTICA, ALTA, MEDIA, BAJA).
4. Identificar naturaleza (Estática vs Dinámica).

#### Fase 2: Análisis (Transformación a Casos de Uso)

Objetivos:

1. Agrupar reglas relacionadas en casos de uso.
2. Definir flujos principales y alternativos.
3. Especificar precondiciones y postcondiciones.
4. Generar diagramas de secuencia.

#### Fase 3: Documentación (Catálogo Centralizado)

Objetivos:

1. Crear plantilla estándar para cada regla.
2. Documentar implementación técnica.
3. Establecer trazabilidad (Regla → UC → RF → Test).
4. Implementar sistema de versionamiento de reglas.

## Glosario de Términos

| Término | Definición |
| --- | --- |
| **Regla de Negocio** | Política, restricción, cálculo o comportamiento que gobierna el sistema. |
| **Soft Delete** | Marcado lógico de registros como eliminados sin borrarlos físicamente. |
| **STRIDE** | Metodología de clasificación de amenazas (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege). |
| **PyTM** | Framework OWASP para threat modeling como código en Python. |
| **JWT** | JSON Web Token: estándar de autenticación basado en tokens. |
| **TOTP** | Time-based One-Time Password: código 2FA de 6 dígitos. |
| **Overdue** | Hallazgo crítico sin atender por más tiempo del permitido. |
| **Rate Limiting** | Limitación de intentos/requests para prevenir abuso. |

## Metadatos

- **Versión:** 1.0
- **Estado:** ✅ Completo
- **Próximo Artefacto:** Fase 1.3 - Clasificación de Reglas por Tipo

