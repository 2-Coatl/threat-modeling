# UC-011: Gestionar permisos por rol

> **Estado:** Archivado. Este caso de uso pertenece al sistema heredado IACT y
> se conserva únicamente como referencia histórica; no forma parte del alcance
> vigente de la plataforma de threat modeling.

**Sistema:** IACT - IVR Analytics & Customer Tracking  
**Caso de Uso:** UC-011  
**Versión:** 1.0  
**Fecha:** 2025-10-19

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-011|
|**Nombre**|Gestionar Permisos por Rol|
|**Prioridad**|🟡 ALTA|
|**Actores**|• Administrador de Usuarios (R001)<br>• Administrador de Sistema (R016)|
|**Tipo**|Lectura y Consulta (NO modificación de permisos predefinidos)|
|**Frecuencia de Uso**|Baja (consulta ocasional)|
|**Complejidad**|Media|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

Permite a los administradores **consultar y visualizar** la matriz de permisos asignados a cada uno de los 18 roles funcionales del sistema.

**IMPORTANTE:** Los permisos de los roles predefinidos **NO se pueden modificar** desde la aplicación. Son fijos y definidos en el diseño del sistema.

### 2.2 Objetivo

- Visualizar permisos asignados a cada rol
- Comparar permisos entre roles
- Entender capacidades de cada rol
- Documentar matriz de permisos
- Identificar usuarios con roles específicos

### 2.3 Alcance

**Incluye:**

- ✅ Listar 18 roles del sistema
- ✅ Ver permisos de cada rol
- ✅ Ver matriz de permisos (roles x funciones)
- ✅ Listar usuarios por rol
- ✅ Exportar matriz de permisos
- ✅ Editar descripción del rol (solo texto)

**NO Incluye:**

- ❌ Modificar permisos de roles predefinidos
- ❌ Crear nuevos roles
- ❌ Eliminar roles del sistema
- ❌ Cambiar código del rol

### 2.4 Restricciones Especiales

1. **Roles Predefinidos:** Los 18 roles son fijos con permisos inmutables
2. **Matriz Fija:** La matriz de permisos está definida en el diseño
3. **Solo Descripción:** Únicamente se puede editar el texto descriptivo
4. **Auditoría:** Todos los accesos se registran

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: Sistema operativo y accesible
PRECOND-02: BD disponible con conectividad
PRECOND-03: Tabla 'roles' poblada con 18 roles
PRECOND-04: Tabla 'permissions' poblada con permisos
PRECOND-05: Tabla 'role_permissions' con relaciones definidas
```

### 3.2 Precondiciones del Usuario

```
PRECOND-06: Usuario autenticado en el sistema
PRECOND-07: Usuario con rol R001 o R016
PRECOND-08: Sesión activa (is_active = TRUE)
PRECOND-09: Usuario NO bloqueado
```

### 3.3 Validación de Precondiciones

**Pseudocódigo:**

```
FUNCION validar_precondiciones_uc011(usuario_id):
    // Validar autenticación
    sesion = obtener_sesion_activa(usuario_id)
    SI sesion ES NULO O sesion.is_active = FALSO:
        RETORNAR error("Sesión no válida. Inicie sesión nuevamente")
    FIN SI
    
    // Validar timeout
    SI sesion.last_activity < (AHORA - 15 MINUTOS):
        RETORNAR error("Sesión expirada por inactividad")
    FIN SI
    
    // Validar permisos
    roles_usuario = obtener_roles(usuario_id)
    SI NO (R001 EN roles_usuario O R016 EN roles_usuario):
        RETORNAR error("Acceso denegado: Requiere rol R001 o R016")
    FIN SI
    
    // Validar estado del usuario
    usuario = obtener_usuario(usuario_id)
    SI usuario.status != 'ACTIVO':
        RETORNAR error("Usuario no activo")
    FIN SI
    
    // Todas las validaciones pasadas
    RETORNAR exito()
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
PASO 1: Acceso al Módulo
┌─────────────────────────────────────────────────┐
│ Usuario hace clic en:                           │
│ "Administración" → "Gestión de Roles"          │
└─────────────────────────────────────────────────┘
        ↓
VALIDAR: precondiciones_uc011()
        ↓ [OK]

PASO 2: Cargar Lista de Roles
┌─────────────────────────────────────────────────┐
│ Sistema ejecuta query:                          │
│                                                 │
│ SELECT role_id, code, name, description,        │
│        category, created_at                     │
│ FROM roles                                      │
│ ORDER BY category, code                         │
└─────────────────────────────────────────────────┘
        ↓
Resultado: 18 registros
        ↓

PASO 3: Mostrar Lista de Roles
┌─────────────────────────────────────────────────┐
│ Tabla con columnas:                             │
│ • Código (R001-R018)                            │
│ • Nombre del Rol                                │
│ • Categoría                                     │
│ • Cantidad de Usuarios                          │
│ • Acciones [Ver Detalle] [Ver Permisos]        │
└─────────────────────────────────────────────────┘
        ↓
Usuario selecciona un rol
        ↓

PASO 4: Ver Detalle del Rol
┌─────────────────────────────────────────────────┐
│ Modal/Panel con información:                    │
│                                                 │
│ [Código]: R004                                  │
│ [Nombre]: REPORTS_VIEWER                        │
│ [Categoría]: Reportes                           │
│ [Descripción]: Consulta reportes básicos con... │
│ [Usuarios con este rol]: 87                     │
│                                                 │
│ Opciones:                                       │
│ [Ver Matriz de Permisos]                        │
│ [Ver Usuarios con este Rol]                     │
│ [Editar Descripción]                            │
│ [Exportar Info del Rol]                         │
└─────────────────────────────────────────────────┘
        ↓
Usuario selecciona opción
        ↓

PASO 5: Acción Seleccionada
┌──────────────────┬──────────────────┬───────────────┐
│ Ver Matriz       │ Ver Usuarios     │ Editar Desc   │
│ (ir a FA-01)     │ (ir a FA-02)     │ (ir a FA-03)  │
└──────────────────┴──────────────────┴───────────────┘
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION gestionar_permisos_por_rol(usuario_id):
    
    // PASO 1: Validar acceso
    resultado_validacion = validar_precondiciones_uc011(usuario_id)
    SI resultado_validacion.es_error():
        MOSTRAR error(resultado_validacion.mensaje)
        RETORNAR
    FIN SI
    
    // Registrar acceso en auditoría
    registrar_auditoria(
        usuario_id = usuario_id,
        accion = "ACCESS_ROLE_MANAGEMENT",
        nivel = "INFO",
        detalles = "Acceso a gestión de roles"
    )
    
    // PASO 2: Cargar roles del sistema
    INTENTAR:
        roles = EJECUTAR_QUERY("
            SELECT 
                r.role_id,
                r.code,
                r.name,
                r.description,
                r.category,
                r.created_at,
                COUNT(ur.user_id) as user_count
            FROM roles r
            LEFT JOIN user_roles ur ON r.role_id = ur.role_id
            WHERE r.is_active = TRUE
            GROUP BY r.role_id
            ORDER BY r.category, r.code
        ")
        
        SI roles.count() = 0:
            LANZAR excepcion("No se encontraron roles en el sistema")
        FIN SI
        
    CAPTURAR error_bd:
        registrar_log_error("Error al cargar roles", error_bd)
        MOSTRAR error("Error al cargar información de roles")
        RETORNAR
    FIN INTENTAR
    
    // PASO 3: Mostrar lista de roles
    vista_roles = construir_tabla_roles(roles)
    MOSTRAR vista_roles
    
    // PASO 4: Esperar selección del usuario
    rol_seleccionado = ESPERAR accion_usuario()
    
    // PASO 5: Procesar acción según selección
    SEGUN rol_seleccionado.accion:
        CASO "ver_detalle":
            mostrar_detalle_rol(rol_seleccionado.role_id)
        CASO "ver_matriz":
            mostrar_matriz_permisos(rol_seleccionado.role_id)
        CASO "ver_usuarios":
            mostrar_usuarios_del_rol(rol_seleccionado.role_id)
        CASO "editar_descripcion":
            editar_descripcion_rol(rol_seleccionado.role_id, usuario_id)
        CASO "exportar":
            exportar_info_rol(rol_seleccionado.role_id)
        POR DEFECTO:
            // No hacer nada, esperar nueva acción
    FIN SEGUN
    
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### 5.1 FA-01: Ver Matriz de Permisos

**Descripción:** Usuario visualiza matriz completa de permisos (roles x funciones)

**Trigger:** Usuario hace clic en "Ver Matriz de Permisos"

**Flujo:**

```
FA-01: Ver Matriz de Permisos
        ↓
┌─────────────────────────────────────────────────┐
│ Sistema consulta:                               │
│ • Todos los roles (18 roles)                    │
│ • Todas las funciones/módulos                   │
│ • Relación role_permissions                     │
└─────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────┐
│ Sistema genera matriz:                          │
│                                                 │
│        │Users│Reports│Dashboard│Alerts│Admin│  │
│ ───────┼─────┼───────┼─────────┼──────┼─────┤  │
│ R001   │ ✓✓✓ │   ✓   │    ✓    │  ✓   │ ✓✓✓ │  │
│ R002   │  ✓  │   -   │    -    │  -   │  -  │  │
│ R003   │  ✓  │   -   │    -    │  -   │  -  │  │
│ R004   │  -  │   ✓   │    ✓    │  -   │  -  │  │
│ ...    │ ... │  ...  │   ...   │ ...  │ ... │  │
│                                                 │
│ Leyenda:                                        │
│ ✓✓✓ = Permisos completos (read/write/delete)   │
│ ✓✓  = Permisos parciales (read/write)          │
│ ✓   = Solo lectura (read)                      │
│ -   = Sin acceso                                │
└─────────────────────────────────────────────────┘
        ↓
Usuario puede:
• Filtrar por categoría de rol
• Filtrar por módulo
• Exportar matriz a Excel
• Hacer zoom en intersección específica
        ↓
RETORNAR a Paso 3 (lista de roles)
```

**Pseudocódigo:**

```
FUNCION mostrar_matriz_permisos(role_id = NULO):
    
    // Si role_id es específico, resaltar ese rol
    rol_enfocado = role_id
    
    // Obtener todos los roles
    roles = EJECUTAR_QUERY("
        SELECT role_id, code, name, category
        FROM roles
        WHERE is_active = TRUE
        ORDER BY category, code
    ")
    
    // Obtener todos los módulos/funciones
    modulos = EJECUTAR_QUERY("
        SELECT module_id, module_name, category
        FROM system_modules
        WHERE is_active = TRUE
        ORDER BY category, module_name
    ")
    
    // Obtener matriz de permisos
    permisos = EJECUTAR_QUERY("
        SELECT 
            rp.role_id,
            rp.permission_id,
            p.module_id,
            p.permission_type,
            p.permission_level
        FROM role_permissions rp
        INNER JOIN permissions p ON rp.permission_id = p.permission_id
        WHERE rp.is_active = TRUE
    ")
    
    // Construir matriz bidimensional
    matriz = {}
    
    PARA CADA rol EN roles:
        matriz[rol.role_id] = {}
        
        PARA CADA modulo EN modulos:
            // Buscar permisos de este rol en este módulo
            perms_rol_modulo = FILTRAR permisos DONDE:
                role_id = rol.role_id Y
                module_id = modulo.module_id
            
            SI perms_rol_modulo.count() = 0:
                matriz[rol.role_id][modulo.module_id] = "SIN_ACCESO"
            SINO:
                // Calcular nivel de acceso
                nivel = calcular_nivel_acceso(perms_rol_modulo)
                matriz[rol.role_id][modulo.module_id] = nivel
            FIN SI
        FIN PARA
    FIN PARA
    
    // Generar vista HTML de la matriz
    html_matriz = generar_tabla_html_matriz(matriz, roles, modulos, rol_enfocado)
    
    // Mostrar en modal o página completa
    MOSTRAR html_matriz
    
    // Registrar en auditoría
    registrar_auditoria(
        usuario_id = usuario_actual,
        accion = "VIEW_PERMISSIONS_MATRIX",
        nivel = "INFO",
        detalles = "Visualización de matriz de permisos"
    )
    
FIN FUNCION

FUNCION calcular_nivel_acceso(lista_permisos):
    tiene_read = FALSO
    tiene_write = FALSO
    tiene_delete = FALSO
    
    PARA CADA permiso EN lista_permisos:
        SEGUN permiso.permission_type:
            CASO "READ":
                tiene_read = VERDADERO
            CASO "WRITE":
                tiene_write = VERDADERO
            CASO "DELETE":
                tiene_delete = VERDADERO
        FIN SEGUN
    FIN PARA
    
    SI tiene_read Y tiene_write Y tiene_delete:
        RETORNAR "COMPLETO"  // ✓✓✓
    SINO SI tiene_read Y tiene_write:
        RETORNAR "PARCIAL"   // ✓✓
    SINO SI tiene_read:
        RETORNAR "SOLO_LECTURA"  // ✓
    SINO:
        RETORNAR "SIN_ACCESO"  // -
    FIN SI
FIN FUNCION
```

---

### 5.2 FA-02: Ver Usuarios con el Rol

**Descripción:** Usuario visualiza lista de usuarios que tienen un rol específico

**Trigger:** Usuario hace clic en "Ver Usuarios con este Rol"

**Flujo:**

```
FA-02: Ver Usuarios con el Rol
        ↓
┌─────────────────────────────────────────────────┐
│ Sistema consulta usuarios con rol seleccionado  │
│                                                 │
│ SELECT u.user_id, u.username, u.first_name,     │
│        u.last_name, u.email, u.status,          │
│        s.name as segment_name                   │
│ FROM users u                                    │
│ INNER JOIN user_roles ur                        │
│     ON u.user_id = ur.user_id                   │
│ INNER JOIN data_segments s                      │
│     ON u.segment_id = s.segment_id              │
│ WHERE ur.role_id = @role_id                     │
│   AND ur.is_active = TRUE                       │
│ ORDER BY u.username                             │
└─────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────┐
│ Tabla de resultados:                            │
│                                                 │
│ Username    │ Nombre      │ Segmento │ Estado  │
│─────────────┼─────────────┼──────────┼─────────│
│ juan.perez  │ Juan Pérez  │ OP       │ ACTIVO  │
│ maria.gomez │ María Gómez │ FI       │ ACTIVO  │
│ ...         │ ...         │ ...      │ ...     │
│                                                 │
│ Total: 87 usuarios                              │
└─────────────────────────────────────────────────┘
        ↓
Opciones disponibles:
• Filtrar por segmento
• Filtrar por estado
• Exportar lista a CSV
• Ver perfil de usuario (link)
        ↓
RETORNAR a Paso 4 (detalle del rol)
```

**Pseudocódigo:**

```
FUNCION mostrar_usuarios_del_rol(role_id):
    
    // Obtener información del rol
    rol = EJECUTAR_QUERY("
        SELECT code, name, description
        FROM roles
        WHERE role_id = @role_id
    ", {role_id: role_id})
    
    SI rol ES NULO:
        MOSTRAR error("Rol no encontrado")
        RETORNAR
    FIN SI
    
    // Obtener usuarios con este rol
    usuarios = EJECUTAR_QUERY("
        SELECT 
            u.user_id,
            u.username,
            u.first_name,
            u.last_name,
            u.email,
            u.status,
            s.code as segment_code,
            s.name as segment_name,
            ur.assigned_at,
            ur.assigned_by
        FROM users u
        INNER JOIN user_roles ur ON u.user_id = ur.user_id
        INNER JOIN data_segments s ON u.segment_id = s.segment_id
        WHERE ur.role_id = @role_id
          AND ur.is_active = TRUE
        ORDER BY u.username
    ", {role_id: role_id})
    
    // Mostrar información del rol
    MOSTRAR "Usuarios con rol: " + rol.code + " - " + rol.name
    MOSTRAR "Total de usuarios: " + usuarios.count()
    
    // Generar tabla
    tabla = construir_tabla_usuarios(usuarios)
    
    // Agregar opciones de filtro
    tabla.agregar_filtro("segmento")
    tabla.agregar_filtro("estado")
    tabla.agregar_opcion_exportar()
    
    // Mostrar tabla
    MOSTRAR tabla
    
    // Registrar en auditoría
    registrar_auditoria(
        usuario_id = usuario_actual,
        accion = "VIEW_ROLE_USERS",
        nivel = "INFO",
        detalles = "Consulta usuarios con rol " + rol.code,
        metadata = {
            role_id: role_id,
            user_count: usuarios.count()
        }
    )
    
FIN FUNCION
```

---

### 5.3 FA-03: Editar Descripción del Rol

**Descripción:** Usuario edita únicamente la descripción textual del rol (NO los permisos)

**Trigger:** Usuario hace clic en "Editar Descripción"

**Flujo:**

```
FA-03: Editar Descripción del Rol
        ↓
┌─────────────────────────────────────────────────┐
│ Sistema muestra formulario:                     │
│                                                 │
│ Código: R004 (NO EDITABLE)                      │
│ Nombre: REPORTS_VIEWER (NO EDITABLE)            │
│                                                 │
│ Descripción:                                    │
│ ┌──────────────────────────────────────────┐   │
│ │ Consulta reportes básicos con filtros    │   │
│ │ estándar. Ve datos de su segmento.       │   │
│ │                                          │   │
│ │ [Campo de texto - Editable]              │   │
│ │ Máximo 500 caracteres                    │   │
│ └──────────────────────────────────────────┘   │
│                                                 │
│ [Cancelar]  [Guardar Cambios]                  │
└─────────────────────────────────────────────────┘
        ↓
Usuario modifica descripción
        ↓
Usuario hace clic en "Guardar"
        ↓
┌─────────────────────────────────────────────────┐
│ Sistema valida:                                 │
│ • Longitud: mínimo 10, máximo 500 caracteres   │
│ • Descripción no vacía                          │
│ • Descripción diferente a la original          │
└─────────────────────────────────────────────────┘
        ↓ [VÁLIDO]
┌─────────────────────────────────────────────────┐
│ UPDATE roles                                    │
│ SET description = @nueva_descripcion,           │
│     updated_at = NOW(),                         │
│     updated_by = @usuario_id                    │
│ WHERE role_id = @role_id                        │
└─────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────┐
│ Registrar en auditoría:                         │
│ • Descripción anterior                          │
│ • Descripción nueva                             │
│ • Usuario que modificó                          │
│ • Timestamp                                     │
└─────────────────────────────────────────────────┘
        ↓
MOSTRAR mensaje: "Descripción actualizada exitosamente"
        ↓
RETORNAR a Paso 4 (detalle del rol)
```

**Pseudocódigo:**

```
FUNCION editar_descripcion_rol(role_id, usuario_id):
    
    // Obtener rol actual
    rol = EJECUTAR_QUERY("
        SELECT role_id, code, name, description
        FROM roles
        WHERE role_id = @role_id
    ", {role_id: role_id})
    
    SI rol ES NULO:
        MOSTRAR error("Rol no encontrado")
        RETORNAR
    FIN SI
    
    // Mostrar formulario
    formulario = crear_formulario()
    formulario.agregar_campo("codigo", rol.code, editable=FALSO)
    formulario.agregar_campo("nombre", rol.name, editable=FALSO)
    formulario.agregar_campo("descripcion", rol.description, 
                            tipo="textarea",
                            min_length=10,
                            max_length=500,
                            editable=VERDADERO)
    
    MOSTRAR formulario
    
    // Esperar acción del usuario
    accion = ESPERAR envio_formulario()
    
    SI accion = "cancelar":
        RETORNAR
    FIN SI
    
    // Validar entrada
    nueva_descripcion = accion.datos.descripcion
    
    errores = []
    
    SI LONGITUD(nueva_descripcion) < 10:
        errores.agregar("La descripción debe tener al menos 10 caracteres")
    FIN SI
    
    SI LONGITUD(nueva_descripcion) > 500:
        errores.agregar("La descripción no puede exceder 500 caracteres")
    FIN SI
    
    SI TRIM(nueva_descripcion) = "":
        errores.agregar("La descripción no puede estar vacía")
    FIN SI
    
    SI nueva_descripcion = rol.description:
        errores.agregar("La descripción no ha cambiado")
    FIN SI
    
    SI errores.count() > 0:
        MOSTRAR errores
        RETORNAR editar_descripcion_rol(role_id, usuario_id)  // Reintentar
    FIN SI
    
    // Guardar descripción anterior para auditoría
    descripcion_anterior = rol.description
    
    // Actualizar base de datos
    INICIAR TRANSACCION
    
    INTENTAR:
        EJECUTAR_QUERY("
            UPDATE roles
            SET description = @nueva_descripcion,
                updated_at = NOW(),
                updated_by = @usuario_id
            WHERE role_id = @role_id
        ", {
            nueva_descripcion: nueva_descripcion,
            usuario_id: usuario_id,
            role_id: role_id
        })
        
        // Registrar en auditoría
        registrar_auditoria(
            usuario_id = usuario_id,
            accion = "UPDATE_ROLE_DESCRIPTION",
            nivel = "INFO",
            detalles = "Descripción de rol actualizada",
            metadata = {
                role_id: role_id,
                role_code: rol.code,
                descripcion_anterior: descripcion_anterior,
                descripcion_nueva: nueva_descripcion
            }
        )
        
        // Enviar notificación a buzón interno de admins
        notificar_administradores(
            asunto = "Descripción de rol actualizada",
            mensaje = "El usuario " + obtener_username(usuario_id) + 
                     " actualizó la descripción del rol " + rol.code,
            tipo = "info"
        )
        
        CONFIRMAR TRANSACCION
        
        MOSTRAR exito("Descripción actualizada exitosamente")
        
    CAPTURAR error:
        REVERTIR TRANSACCION
        registrar_log_error("Error al actualizar descripción de rol", error)
        MOSTRAR error("Error al guardar cambios. Intente nuevamente")
    FIN INTENTAR
    
FIN FUNCION
```

---

### 5.4 FA-04: Exportar Información del Rol

**Descripción:** Usuario exporta información completa del rol a PDF o Excel

**Trigger:** Usuario hace clic en "Exportar Info del Rol"

**Flujo:**

```
FA-04: Exportar Información del Rol
        ↓
┌─────────────────────────────────────────────────┐
│ Seleccionar formato:                            │
│ ( ) PDF                                         │
│ ( ) Excel                                       │
│                                                 │
│ Incluir:                                        │
│ [✓] Información básica del rol                  │
│ [✓] Lista de permisos                           │
│ [✓] Lista de usuarios con el rol                │
│ [✓] Historial de cambios                        │
│                                                 │
│ [Cancelar]  [Exportar]                          │
└─────────────────────────────────────────────────┘
        ↓
Usuario selecciona opciones y formato
        ↓
Sistema genera archivo
        ↓
┌─────────────────────────────────────────────────┐
│ Contenido del archivo:                          │
│                                                 │
│ 1. INFORMACIÓN DEL ROL                          │
│    • Código                                     │
│    • Nombre                                     │
│    • Descripción                                │
│    • Categoría                                  │
│    • Fecha de creación                          │
│                                                 │
│ 2. PERMISOS ASIGNADOS                           │
│    • Tabla con módulos y niveles de acceso     │
│                                                 │
│ 3. USUARIOS CON ESTE ROL (87 usuarios)         │
│    • Tabla con username, nombre, segmento      │
│                                                 │
│ 4. HISTORIAL DE CAMBIOS                        │
│    • Cambios en descripción                    │
│    • Fecha y usuario que modificó              │
└─────────────────────────────────────────────────┘
        ↓
Sistema descarga archivo
        ↓
Registrar exportación en auditoría
        ↓
MOSTRAR mensaje: "Archivo exportado: rol_R004_20251019.pdf"
        ↓
RETORNAR a Paso 4
```

**Pseudocódigo:**

```
FUNCION exportar_info_rol(role_id, formato, opciones, usuario_id):
    
    // Obtener información completa del rol
    rol = obtener_rol_completo(role_id)
    
    SI rol ES NULO:
        MOSTRAR error("Rol no encontrado")
        RETORNAR
    FIN SI
    
    // Construir contenido del reporte
    contenido = {}
    
    SI opciones.incluir_info_basica:
        contenido.info_basica = {
            codigo: rol.code,
            nombre: rol.name,
            descripcion: rol.description,
            categoria: rol.category,
            fecha_creacion: rol.created_at,
            usuarios_activos: contar_usuarios_con_rol(role_id)
        }
    FIN SI
    
    SI opciones.incluir_permisos:
        contenido.permisos = obtener_permisos_rol(role_id)
    FIN SI
    
    SI opciones.incluir_usuarios:
        contenido.usuarios = obtener_usuarios_con_rol(role_id)
    FIN SI
    
    SI opciones.incluir_historial:
        contenido.historial = obtener_historial_cambios_rol(role_id)
    FIN SI
    
    // Generar archivo según formato
    nombre_archivo = "rol_" + rol.code + "_" + fecha_hoy_formato("YYYYMMDD")
    
    SEGUN formato:
        CASO "PDF":
            archivo = generar_pdf_rol(contenido, nombre_archivo)
            tipo_mime = "application/pdf"
            
        CASO "EXCEL":
            archivo = generar_excel_rol(contenido, nombre_archivo)
            tipo_mime = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            
        POR DEFECTO:
            MOSTRAR error("Formato no soportado")
            RETORNAR
    FIN SEGUN
    
    // Registrar exportación
    registrar_auditoria(
        usuario_id = usuario_id,
        accion = "EXPORT_ROLE_INFO",
        nivel = "INFO",
        detalles = "Exportación de información de rol a " + formato,
        metadata = {
            role_id: role_id,
            role_code: rol.code,
            formato: formato,
            nombre_archivo: nombre_archivo + "." + formato.minusculas()
        }
    )
    
    // Enviar archivo al navegador
    descargar_archivo(
        contenido: archivo,
        nombre: nombre_archivo + "." + formato.minusculas(),
        tipo_mime: tipo_mime
    )
    
    MOSTRAR exito("Archivo exportado: " + nombre_archivo + "." + formato.minusculas())
    
FIN FUNCION
```

---

## 6. FLUJOS DE EXCEPCIÓN

### 6.1 FE-01: Rol No Encontrado

```
TRIGGER: Sistema no encuentra el rol solicitado

FLUJO:
    ↓
Sistema detecta role_id inválido
    ↓
MOSTRAR error: "Rol no encontrado en el sistema"
    ↓
Registrar en logs (nivel WARNING)
    ↓
RETORNAR a Paso 3 (lista de roles)
```

### 6.2 FE-02: Error de Base de Datos

```
TRIGGER: Fallo en consulta a BD

FLUJO:
    ↓
Sistema detecta error de BD (timeout, conexión, etc.)
    ↓
Registrar error completo en logs
    ↓
REVERTIR transacción (si aplica)
    ↓
MOSTRAR error: "Error al cargar información. Intente nuevamente"
    ↓
Notificar a administradores vía buzón interno
    ↓
RETORNAR a paso anterior
```

### 6.3 FE-03: Usuario Sin Permisos

```
TRIGGER: Usuario intenta acceder sin rol R001 o R016

FLUJO:
    ↓
Sistema detecta falta de permisos
    ↓
Registrar intento en auditoría (nivel WARNING)
    ↓
MOSTRAR error: "Acceso denegado: Requiere permisos de administrador"
    ↓
NO permitir acceso al módulo
    ↓
REDIRECCIONAR a dashboard principal
```

---

## 7. POSTCONDICIONES

### 7.1 Postcondiciones de Éxito

```
POST-01: Información de rol visualizada correctamente
POST-02: Acceso registrado en audit_logs
POST-03: Sistema permanece en estado consistente
POST-04: (Si edición) Descripción actualizada en BD
POST-05: (Si edición) Cambio registrado en auditoría
POST-06: (Si exportación) Archivo generado y descargado
POST-07: Usuario puede continuar trabajando
```

### 7.2 Postcondiciones de Fallo

```
POST-FAIL-01: Sistema NO modifica BD (ROLLBACK si aplica)
POST-FAIL-02: Error registrado en logs
POST-FAIL-03: Usuario notificado del error
POST-FAIL-04: Sistema retorna a estado anterior
POST-FAIL-05: Sesión del usuario permanece activa
```

---

## 8. REGLAS DE NEGOCIO

### 8.1 Reglas Generales

```
RN-001: Los 18 roles del sistema son predefinidos e inmutables
RN-002: Solo se puede editar la descripción textual del rol
RN-003: NO se pueden crear nuevos roles desde la aplicación
RN-004: NO se pueden eliminar roles del sistema
RN-005: NO se pueden modificar permisos de roles predefinidos
RN-006: Código del rol (R001-R018) es inmutable
RN-007: Nombre del rol es inmutable
```

### 8.2 Reglas de Permisos

```
RN-008: Solo R001 y R016 pueden acceder a este caso de uso
RN-009: Matriz de permisos es de solo lectura
RN-010: Permisos de roles están definidos en role_permissions
RN-011: Relación many-to-many: 1 rol → N permisos
```

### 8.3 Reglas de Edición

```
RN-012: Descripción debe tener entre 10 y 500 caracteres
RN-013: Descripción no puede estar vacía
RN-014: Cambios en descripción se auditan completamente
RN-015: Descripción debe ser diferente a la anterior
```

### 8.4 Reglas de Exportación

```
RN-016: Exportación disponible en PDF y Excel
RN-017: Exportaciones se registran en auditoría
RN-018: Archivo incluye timestamp en nombre
RN-019: Usuario puede seleccionar qué secciones exportar
```

---

## 9. TABLA DE BASE DE DATOS

### 9.1 Tabla: roles

```sql
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE COMMENT 'Código del rol: R001-R018',
    name VARCHAR(100) NOT NULL COMMENT 'Nombre del rol en inglés',
    description TEXT NOT NULL COMMENT 'Descripción funcional (editable)',
    category ENUM('USERS', 'REPORTS', 'DASHBOARD', 'ANALYSIS', 'ALERTS', 'ADMIN') NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_system_role BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'TRUE = rol predefinido',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL,
    updated_by INT NULL COMMENT 'Usuario que editó descripción',
    
    INDEX idx_code (code),
    INDEX idx_category (category),
    INDEX idx_active (is_active),
    
    FOREIGN KEY (updated_by) REFERENCES users(user_id)
) ENGINE=InnoDB COMMENT='Roles funcionales del sistema';

-- Insertar 18 roles predefinidos
INSERT INTO roles (code, name, category, description) VALUES
('R001', 'USERS_FULL_MANAGER', 'USERS', 'Administra usuarios, roles, permisos y segmentos de datos'),
('R002', 'USERS_VIEWER', 'USERS', 'Ve información de usuarios sin capacidad de modificación'),
('R003', 'USERS_TEAM_MANAGER', 'USERS', 'Administra usuarios del mismo segmento de datos'),
('R004', 'REPORTS_VIEWER', 'REPORTS', 'Consulta reportes básicos con filtros estándar'),
('R005', 'REPORTS_EXPORTER', 'REPORTS', 'Exporta reportes en múltiples formatos'),
('R006', 'REPORTS_ADVANCED_VIEWER', 'REPORTS', 'Accede a reportes avanzados y múltiples segmentos'),
('R007', 'REPORTS_CREATOR', 'REPORTS', 'Crea y modifica reportes personalizados'),
('R008', 'DASHBOARD_VIEWER', 'DASHBOARD', 'Ve dashboards estándar sin personalización'),
('R009', 'DASHBOARD_CUSTOMIZER', 'DASHBOARD', 'Personaliza dashboards y guarda vistas'),
('R010', 'DATA_ANALYST', 'ANALYSIS', 'Ejecuta análisis exploratorio y detecta patrones'),
('R011', 'ALERTS_VIEWER', 'ALERTS', 'Recibe y visualiza alertas sin configuración'),
('R012', 'ALERTS_CONFIGURATOR', 'ALERTS', 'Configura alertas personales y umbrales propios'),
('R013', 'ALERTS_TEAM_MANAGER', 'ALERTS', 'Configura alertas para usuarios del segmento'),
('R014', 'ALERTS_GLOBAL_ADMIN', 'ALERTS', 'Configura alertas globales del sistema'),
('R015', 'MODULES_ADMIN', 'ADMIN', 'Administra módulos dinámicos y perfiles'),
('R016', 'SYSTEM_ADMIN', 'ADMIN', 'Administra sistema completo e infraestructura'),
('R017', 'AUDIT_VIEWER', 'ADMIN', 'Ve logs de auditoría y compliance'),
('R018', 'SECURITY_ADMIN', 'ADMIN', 'Administra seguridad, políticas y accesos');
```

### 9.2 Tabla: permissions

```sql
CREATE TABLE permissions (
    permission_id INT AUTO_INCREMENT PRIMARY KEY,
    module_id INT NOT NULL COMMENT 'Módulo del sistema',
    permission_code VARCHAR(100) NOT NULL UNIQUE COMMENT 'Ej: users.create, reports.view',
    permission_type ENUM('READ', 'WRITE', 'DELETE', 'EXECUTE') NOT NULL,
    permission_level ENUM('BASIC', 'ADVANCED', 'FULL') NOT NULL DEFAULT 'BASIC',
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_module (module_id),
    INDEX idx_code (permission_code),
    INDEX idx_type (permission_type),
    
    FOREIGN KEY (module_id) REFERENCES system_modules(module_id)
) ENGINE=InnoDB COMMENT='Permisos del sistema';
```

### 9.3 Tabla: role_permissions

```sql
CREATE TABLE role_permissions (
    role_permission_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_role_permission (role_id, permission_id),
    INDEX idx_role (role_id),
    INDEX idx_permission (permission_id),
    
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id)
) ENGINE=InnoDB COMMENT='Relación roles-permisos';
```

---

## 10. VALIDACIONES

### 10.1 Validaciones de Entrada

```
VAL-01: Usuario autenticado
VAL-02: Usuario con rol R001 o R016
VAL-03: Sesión activa (no expirada)
VAL-04: Usuario en estado ACTIVO
VAL-05: role_id debe existir en tabla roles
VAL-06: Descripción entre 10 y 500 caracteres
VAL-07: Descripción no vacía ni solo espacios
```

### 10.2 Validaciones de Negocio

```
VAL-08: Solo edición de descripción permitida
VAL-09: Código de rol NO editable
VAL-10: Nombre de rol NO editable
VAL-11: Permisos de rol NO editables
VAL-12: Rol debe ser is_system_role = TRUE
```

### 10.3 Validaciones de Seguridad

```
VAL-13: Todas las acciones auditadas
VAL-14: Ediciones requieren confirmación
VAL-15: Accesos registrados con IP y user_agent
VAL-16: Exportaciones tienen límite de tamaño
```

---

## 11. EJEMPLOS DE USO

### 11.1 Ejemplo 1: Ver Permisos de R004

**Contexto:** Administrador quiere ver qué puede hacer un REPORTS_VIEWER

**Flujo:**

1. Admin accede a "Administración > Gestión de Roles"
2. Sistema muestra tabla con 18 roles
3. Admin busca R004 en la tabla
4. Admin hace clic en "Ver Detalle" de R004
5. Sistema muestra:
    - Código: R004
    - Nombre: REPORTS_VIEWER
    - Descripción: "Consulta reportes básicos..."
    - Usuarios: 87
6. Admin hace clic en "Ver Matriz de Permisos"
7. Sistema muestra matriz completa con R004 resaltado
8. Admin ve que R004 tiene:
    - ✓ reports.view.basic
    - ✓ reports.filter.date
    - ✓ reports.filter.center
    - - reports.export.* (sin acceso)

### 11.2 Ejemplo 2: Editar Descripción de R010

**Contexto:** Descripción de DATA_ANALYST necesita actualizarse

**Flujo:**

1. Admin selecciona R010 en la lista
2. Admin hace clic en "Editar Descripción"
3. Sistema muestra formulario con descripción actual
4. Admin modifica texto:
    - Antes: "Análisis exploratorio..."
    - Después: "Ejecuta análisis exploratorio, compara períodos y detecta patrones en los datos del IVR"
5. Admin hace clic en "Guardar"
6. Sistema valida (105 caracteres, válido)
7. Sistema actualiza BD
8. Sistema registra en auditoría
9. Sistema muestra: "Descripción actualizada exitosamente"

---

## 12. REQUISITOS NO FUNCIONALES

### 12.1 Rendimiento

```
RNF-01: Cargar lista de 18 roles en < 1 segundo
RNF-02: Mostrar detalle de rol en < 0.5 segundos
RNF-03: Generar matriz de permisos en < 2 segundos
RNF-04: Actualizar descripción en < 1 segundo
RNF-05: Exportar PDF en < 5 segundos
```

### 12.2 Usabilidad

```
RNF-06: Interfaz intuitiva (sin manual)
RNF-07: Mensajes de error claros
RNF-08: Campos editables claramente identificados
RNF-09: Confirmación antes de guardar cambios
RNF-10: Indicador visual de campos obligatorios
```

### 12.3 Seguridad

```
RNF-11: Todas las acciones auditadas
RNF-12: Acceso solo con roles autorizados
RNF-13: Sesión debe estar activa
RNF-14: Validación en cliente y servidor
RNF-15: Protección contra SQL injection
```

---

## 13. NOTAS ADICIONALES

### 13.1 Restricción Importante

**Los 18 roles son predefinidos e inmutables:**

- NO se pueden crear nuevos roles desde la aplicación
- NO se pueden eliminar roles del sistema
- NO se pueden modificar permisos de roles predefinidos
- SOLO se puede editar la descripción textual

### 13.2 Para Permisos Especiales

Si un usuario necesita permisos que no corresponden a ningún rol predefinido:

- Usar UC-042: Gestionar Permisos Directos
- Asignar permiso directo temporal (máx 6 meses)
- Requiere justificación obligatoria

### 13.3 Roles vs Permisos Directos

**Precedencia:**

1. Permisos Directos (máxima precedencia)
2. Permisos por Rol
3. Permisos por Segmento

---

## 14. MATRIZ DE TRAZABILIDAD

|Requisito|Documento Origen|Sección|
|---|---|---|
|18 roles RBAC|SRS v0.2.1|3.2.1|
|Flat RBAC (NIST)|SRS v0.2.1|3.2.2|
|Solo editar descripción|Decisión de diseño|-|
|Auditoría completa|SRS v0.2.1|1.4.4|
|Matriz de permisos|SRS v0.2.1|Anexo C|

---

**FIN DEL CASO DE USO UC-011**

**Próximo:** UC-041 - Gestionar Segmentos de Datos
