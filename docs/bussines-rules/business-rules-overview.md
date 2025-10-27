# Reglas de Negocio en Ingeniería de Requerimientos

## Parte 1: Introducción y Conceptos Fundamentales

### ¿Qué es una Regla de Negocio?

> **Concepto clave:** Las reglas de negocio son las políticas, leyes y estándares de la industria bajo los cuales se rige cada organización para operar de manera efectiva y conforme a las regulaciones.

Cada organización opera de acuerdo con un extenso conjunto de políticas, leyes y estándares de la industria. En pocas palabras, decimos que las **reglas de negocio** son estas políticas, leyes y estándares bajo los que se rigen las organizaciones.

> **Nota contextual importante:** Industrias como la banca, la aviación y la fabricación de dispositivos médicos deben cumplir con un volumen significativo de regulaciones gubernamentales.

### Ejemplo Práctico: Gestión de Residuos en Emergencia Sanitaria

Durante situaciones de emergencia sanitaria, existen regulaciones específicas que todas las organizaciones deben atender:

- Tratamiento de residuos bacteriológicos
- Protocolos de movimiento y captación
- Procedimientos de eliminación segura

Estos constituyen estándares, políticas o reglas que se implementan para el manejo adecuado de residuos.

### Diagrama Conceptual: Ubicación de las Reglas de Negocio

```
┌─────────────────────────────────────────────────────────────┐
│                    JERARQUÍA DE REQUERIMIENTOS              │
├─────────────────────────────────────────────────────────────┤
│  Nivel 1: REGLAS DE NEGOCIO                                │
│  (Políticas, Leyes, Estándares)                            │
│                         │                                   │
│                         ▼                                   │
│  Nivel 2: REQUERIMIENTOS DE NEGOCIO                        │
│  (Objetivos organizacionales)                              │
│                         │                                   │
│                         ▼                                   │
│  Nivel 3: REQUERIMIENTOS DE USUARIO                        │
│  (Necesidades específicas del usuario)                     │
│                         │                                   │
│                         ▼                                   │
│  Nivel 4: REQUERIMIENTOS FUNCIONALES                       │
│  (Funcionalidades del sistema)                             │
│                         │                                   │
│                         ▼                                   │
│  Nivel 5: ATRIBUTOS DE CALIDAD                            │
│  (Características no funcionales)                          │
└─────────────────────────────────────────────────────────────┘
```

### Funciones de las Reglas de Negocio

> **Concepto clave:** Las reglas de negocio también se conocen colectivamente como "lógica de negocio" y tienen dos funciones principales:

1. **Restricción de acceso:** Restringen quién puede realizar ciertos casos de uso.
2. **Control de funcionalidad:** Dictan qué funcionalidad debe continuar el sistema para cumplir con las normas pertinentes.

### Influencia de las Reglas de Negocio en los Tipos de Requerimientos

Las **reglas de negocio** influyen de manera directa sobre varios tipos de requerimientos. A continuación se presenta cómo esta influencia se manifiesta:

---

#### Recuadro: Tabla de Influencia de Reglas de Negocio

| Tipo de Requerimiento | Cómo Influyen las Reglas de Negocio | Ejemplo Práctico |
| --- | --- | --- |
| **Requerimientos de Negocio** | Las regulaciones gubernamentales pueden conducir a objetivos de negocio necesarios para un proyecto | El sistema de seguimiento de químicos debe permitir el cumplimiento de todas las regulaciones federales y estatales sobre el uso de químicos y su eliminación en un período de 5 meses |
| **Requerimientos de Usuario** | Las políticas de privacidad dictan qué usuarios pueden y no pueden realizar ciertas tareas con el sistema | Los gerentes de laboratorio están autorizados a generar informes de exposición química para cualquier persona |
| **Requerimientos Funcionales** | Las políticas empresariales establecen procesos específicos que el sistema debe implementar | Política: todos los proveedores deben estar registrados y aprobados antes de que se pague una factura. Funcionalidad: cuando una factura es recibida por un proveedor no registrado, el sistema enviará un email al proveedor con un PDF editable para darse de alta |
| **Atributos de Calidad** | Las regulaciones de agencias gubernamentales pueden dictar ciertos requisitos de seguridad que deben aplicarse a través de la funcionalidad del sistema | El sistema debe mantener registros de entrenamiento de seguridad que se deben verificar para garantizar que los usuarios están debidamente capacitados antes de poder solicitar un producto químico peligroso |

---

### Ejemplos Detallados por Tipo de Requerimiento

#### 1. Requerimientos de Negocio

Las regulaciones gubernamentales nos dictan que nuestros productos químicos y su eliminación debe realizarse en un período específico de 5 meses. Este es un ejemplo claro de cómo una **regla de negocio** se convierte en un objetivo organizacional.

#### 2. Requerimientos de Usuario

La regla establece que **solo los gerentes pueden generar reportes**. Esto significa que la funcionalidad de generación de informes está restringida por rol de usuario, definiendo claramente qué puede hacer cada tipo de usuario.

#### 3. Requerimientos Funcionales

> **Concepto clave:** Para ser proveedor de alguna empresa, se debe estar previamente registrado y aprobado.

Cuando llega una factura de un proveedor no registrado, el sistema automáticamente envía un PDF editable para que el proveedor se dé de alta. La política organizacional se traduce directamente en funcionalidad del sistema.

#### 4. Atributos de Calidad

> **Nota contextual importante:** En Estados Unidos, agencias como OSHA o EPA, y en México la Secretaría de Salud, establecen requisitos de seguridad específicos.

El registro de entrenamiento de seguridad debe mantenerse como un atributo de calidad del sistema, asegurando que solo usuarios capacitados puedan acceder a productos químicos peligrosos.

---

### Conclusión de la Parte 1

Las reglas de negocio constituyen el nivel más alto en la jerarquía de requerimientos y ejercen una influencia directa y determinante sobre todos los demás tipos de requerimientos. Comprender esta influencia es fundamental para el análisis efectivo de requerimientos y el diseño de sistemas que cumplan con las normativas y políticas organizacionales.

---

## Parte 2: Tipos de Reglas de Negocio (Hechos y Restricciones)

### Clasificación de las Reglas de Negocio

Existen **cinco tipos principales** de reglas de negocio que debemos conocer y saber identificar.

> **Concepto clave:** Los cinco tipos de reglas de negocio son: Hechos, Restricciones, Desencadenadores de Acción, Inferencias y Cálculos Computacionales.

1. **Hechos:** Declaraciones que son ciertas acerca del negocio.
2. **Restricciones:** Restringen las acciones que los sistemas o usuarios pueden realizar.
3. **Desencadenadores de acción:** Desencadenan comportamientos bajo ciertas condiciones.
4. **Inferencias:** Establecen nuevos conocimientos basados en la verdad de ciertas condiciones.
5. **Cálculos computacionales:** Realizan cálculos utilizando fórmulas matemáticas o algoritmos.

---

## 1. Hechos

### Definición

> **Concepto clave:** Los hechos son declaraciones que son verdaderas sobre el negocio en un punto específico del tiempo.

Un hecho describe asociaciones o relaciones entre términos comerciales importantes. Los hechos son elementos inmutables que definen la realidad del negocio y no pueden ser cambiados arbitrariamente.

### Características de los Hechos

- Son **declaraciones verdaderas** sobre el negocio.
- Describen **relaciones entre términos comerciales**.
- Son **inmutables** por naturaleza.
- Establecen **asociaciones fundamentales**.

### Ejemplos de Hechos

#### Ejemplo 1: Sistema de Gestión de Químicos

- Cada contenedor de productos químicos tiene un identificador de código de barras único.
- Cada orden debe tener un costo de envío.
- Cada artículo en una orden presenta una combinación específica de producto químico, grado, tamaño del envase y número de contenedores.

#### Ejemplo 2: Sistema Universitario

> **Nota contextual importante:** En el contexto educativo mexicano, la matrícula es un elemento fundamental para la identificación estudiantil.

- Todos los alumnos deben tener una matrícula para ser estudiantes de la universidad.
- Para ser alumno de la universidad, se debe estar registrado oficialmente.

#### Ejemplo 3: Sistema de Almacenamiento

En órdenes que recibe nuestro sistema de almacenamiento de químicos, cada orden debe contener:

- El **producto químico** específico.
- El **grado** del producto.
- El **tamaño del envase**.
- El **número de contenedores**.

---

## 2. Restricciones

### Definición

> **Concepto clave:** Una restricción es una sentencia que restringe las acciones que el sistema o los usuarios pueden realizar, definiendo qué se puede hacer y qué no se puede hacer.

### Palabras Clave para Identificar Restricciones

Cuando encontramos estas frases o palabras en la documentación, prácticamente están describiendo una restricción.

#### Recuadro: Indicadores Lingüísticos de Restricciones

| Indicador | Función | Ejemplo de Uso |
| --- | --- | --- |
| **Debe** | Obligación | "El usuario **debe** proporcionar credenciales" |
| **No debe** | Prohibición | "El sistema **no debe** mostrar datos confidenciales" |
| **No puede** | Limitación | "Un usuario **no puede** tener más de 10 sesiones activas" |
| **Solo puede** | Restricción exclusiva | "Solo **puede** acceder el administrador" |

### Ejemplos de Restricciones

#### Ejemplo 1: Sistema Financiero

Un solicitante de préstamo que es menor de 18 años debe tener un padre o tutor legal como cosignatario en el préstamo.

#### Ejemplo 2: Sistema de Biblioteca

Un usuario de la biblioteca puede tener un máximo de 10 artículos en espera en cualquier momento.

#### Ejemplo 3: Seguridad de Datos Personales

> **Nota contextual importante:** Esta práctica es común en sistemas de comercio electrónico para proteger información sensible del usuario.

La correspondencia no puede mostrar más de cuatro dígitos del número de seguro social del asegurado. Cuando realizas un pago en una tienda en línea, solo ves los últimos cuatro dígitos de tu tarjeta de crédito. Esta es una **regla de negocio** o política organizacional que establece no mostrar el número completo de la tarjeta.

### Restricciones por Tipo de Usuario

> **Concepto clave:** Muchas restricciones definen qué tipos de usuarios pueden realizar cuáles funciones específicas.

Las restricciones frecuentemente establecen permisos basados en roles:

- **Usuario administrador:** Puede realizar funciones completas del sistema.
- **Usuario normal:** Puede realizar funciones básicas y específicas.
- **Usuario invitado:** Puede realizar funciones muy limitadas y de consulta.

### Matriz de Roles y Permisos

#### Recuadro: Ejemplo de Matriz de Roles y Permisos

```
┌─────────────────────────────────────────────────────────────┐
│           MATRIZ DE ROLES Y PERMISOS                       │
├─────────────────┬─────────────┬─────────────┬─────────────┤
│   OPERACIÓN     │ADMINISTRADOR│    STAFF    │   USUARIO   │
├─────────────────┼─────────────┼─────────────┼─────────────┤
│ Ver registro    │      ✓      │      ✓      │      ✓      │
├─────────────────┼─────────────┼─────────────┼─────────────┤
│ Editar registro │      ✓      │      ✓      │      ✗      │
├─────────────────┼─────────────┼─────────────┼─────────────┤
│ Eliminar        │      ✓      │      ✗      │      ✗      │
│ registro        │             │             │             │
├─────────────────┼─────────────┼─────────────┼─────────────┤
│ Buscar en       │      ✓      │      ✓      │      ✓      │
│ catálogo        │             │             │             │
├─────────────────┼─────────────┼─────────────┼─────────────┤
│ Generar         │      ✓      │      ✓      │      ✗      │
│ reportes        │             │             │             │
├─────────────────┼─────────────┼─────────────┼─────────────┤
│ Configurar      │      ✓      │      ✗      │      ✗      │
│ sistema         │             │             │             │
└─────────────────┴─────────────┴─────────────┴─────────────┘

Leyenda: ✓ = Permitido    ✗ = No permitido
```

### Cómo Utilizar la Matriz

En esta matriz simplemente marcamos qué operaciones puede realizar cierto perfil de nuestro sistema, cierto **stakeholder** o cierto **rol**.

**Ejemplo de interpretación:**

- Para ver un registro: el administrador, staff y usuario pueden hacerlo.
- Para editar un registro: solo el administrador y staff pueden hacerlo.
- Para buscar en el catálogo: prácticamente todos los roles pueden hacerlo.

### Ventajas de la Matriz de Roles y Permisos

1. **Claridad visual:** Permite ver de un vistazo qué puede hacer cada rol.
2. **Documentación concisa:** Evita descripciones largas en lenguaje natural.
3. **Fácil mantenimiento:** Cambios de permisos se reflejan fácilmente.
4. **Comunicación efectiva:** Stakeholders entienden rápidamente las restricciones.
5. **Base para desarrollo:** Los desarrolladores pueden implementar controles de acceso directamente.

---

### Resumen de Hechos y Restricciones

#### Hechos

- Son **verdades inmutables** del negocio.
- **Describen relaciones** entre elementos.
- **No se pueden cambiar** arbitrariamente.
- Establecen la **base de conocimiento** del sistema.

#### Restricciones

- **Limitan acciones** de usuarios y sistemas.
- Se identifican con palabras como **debe**, **no debe**, **no puede**, **solo puede**.
- Se documentan eficientemente con **matrices de roles y permisos**.
- Definen **qué está permitido y qué no** en el sistema.

> **Nota contextual importante:** La correcta identificación y documentación de hechos y restricciones es fundamental para el desarrollo de sistemas que cumplan con las expectativas del negocio y las regulaciones aplicables.

---

_Continúa en la Parte 3: Tipos de Reglas de Negocio (Activadores, Inferencias y Cálculos)_

> ℹ️ Consulta también el [`Catálogo de Reglas de Negocio`](./business-rules-catalog.md) para la lista completa de reglas identificadas en la plataforma.
