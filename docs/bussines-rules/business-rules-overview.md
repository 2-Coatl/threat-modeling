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

## Parte 3: Tipos de Reglas de Negocio (Activadores, Inferencias y Cálculos)

---

## 3. Desencadenadores de Acción (Activadores)

### Definición

> **Concepto clave:** Un desencadenador de acción es una regla que activa alguna actividad si las condiciones específicas son verdaderas.

Como alternativa, la regla puede conducir a especificar la funcionalidad del software que hace que una aplicación muestre un comportamiento correcto cuando el sistema detecta un evento.

### Características de los Activadores

- Siguen el patrón **"Si... entonces..."**.
- **Detectan eventos** específicos en el sistema.
- **Desencadenan comportamientos** o acciones.
- Son similares a las estructuras **if-then** en programación.

### Estructura Típica

#### Recuadro: Patrón de Desencadenadores de Acción

```
SI [alguna condición es verdadera] O [algún evento tiene lugar]
ENTONCES [va a suceder esto]
```

**Pista de identificación:** Estas declaraciones generalmente se presentan en la forma:

- "Si... entonces...".
- "Cuando... hacer...".
- "En caso de que... ejecutar...".

### Ejemplos de Desencadenadores de Acción

#### Ejemplo 1: Sistema de Almacén de Químicos

- Si el almacén de productos químicos tiene contenedores de un producto químico solicitado en stock, entonces ofrece los contenedores al solicitante.

**Análisis del ejemplo:**

- **Condición:** El almacén tiene contenedores del producto solicitado en stock.
- **Acción:** El sistema ofrece los contenedores al solicitante.
- **Comportamiento:** Mostrar disponibilidad y opciones al usuario.

#### Ejemplo 2: Control de Caducidad

- Si se ha alcanzado la fecha de vencimiento en un envase del producto químico, entonces se notifica a la persona que está a cargo de este producto.

**Análisis del ejemplo:**

- **Evento detectado:** Fecha de vencimiento alcanzada.
- **Acción desencadenada:** Notificación automática.
- **Comportamiento:** Envío de alerta o mensaje.

> **Nota contextual importante:** Este tipo de reglas son fundamentales en sistemas de gestión de inventarios, especialmente en industrias donde la caducidad de productos puede representar riesgos de seguridad.

---

## 4. Inferencias

### Definición

> **Concepto clave:** Las inferencias, también llamadas "conocimientos inferidos" o "hechos derivados", crean un hecho nuevo a partir de otros hechos existentes.

### Diferencia Clave: Activadores vs. Inferencias

#### Recuadro: Diferencias Fundamentales

| Aspecto | Activadores | Inferencias |
| --- | --- | --- |
| **Propósito** | Desencadenan **comportamientos** | Crean **nuevos hechos** |
| **Resultado** | Ejecutan **acciones** | Generan **conocimiento** |
| **Función** | Hacer que algo **suceda** | Establecer que algo **es** |
| **Ejemplo** | "Enviar notificación" | "Marcar como deudor" |

### Estructura de las Inferencias

Las inferencias frecuentemente se escriben con el patrón **"Si... entonces..."**, muy parecido a los activadores, pero la cláusula "entonces" de una inferencia simplemente proporciona una pieza de conocimiento, no una acción.

### Ejemplos de Inferencias

#### Ejemplo 1: Sistema de Cuentas por Cobrar

- Si un pago no se recibe dentro de los 30 días después de que se debe, entonces la cuenta es marcada como deudora.

**Análisis del ejemplo:**

- **Condición:** Pago no recibido en 30 días.
- **Nuevo hecho:** La cuenta tiene estatus de "deudora".
- **No hay acción:** No envía correo ni ejecuta procesos adicionales; solo establece un estado.

#### Ejemplo 2: Sistema de Órdenes

- Si un vendedor nuevo no puede enviar un artículo ordenado dentro de los cinco días al recibir la orden, entonces la orden es marcada como cancelada.

**Análisis del ejemplo:**

- **Hecho inicial:** El artículo no se envió en el tiempo establecido.
- **Nuevo hecho derivado:** La orden tiene estatus de "cancelada".
- **Conocimiento generado:** El sistema ahora "sabe" que la orden está cancelada.

> **Nota contextual importante:** Las inferencias son fundamentales en sistemas de inteligencia de negocios donde se requiere derivar conclusiones automáticamente a partir de datos existentes.

---

## 5. Cálculos Computacionales

### Definición

> **Concepto clave:** Los cálculos computacionales son reglas que transforman los datos existentes en nuevos datos utilizando fórmulas matemáticas o algoritmos específicos.

### Características de los Cálculos

- **Transforman datos** existentes en nuevos datos.
- Utilizan **fórmulas matemáticas** específicas.
- Aplican **algoritmos** predefinidos.
- Frecuentemente siguen **reglas externas** a la empresa.

### Fuentes de las Reglas de Cálculo

> **Nota contextual importante:** En México, ejemplos de reglas externas incluyen fórmulas de retención del ISR, cálculos del IVA y contribuciones al IMSS e INFONAVIT.

Muchos cálculos siguen reglas externas a la empresa, tales como:

- Fórmulas de **retención de impuestos sobre la renta**.
- Cálculos del **IVA** (Impuesto al Valor Agregado).
- Contribuciones de **seguridad social**.
- Estándares de la **industria**.

### Ejemplos de Cálculos Computacionales

#### Ejemplo 1: Cálculo de Envío Terrestre

- El cargo de envío terrestre nacional por una orden que pesa más de dos kilos es de $40.75 + $0.12 por gramo de fracción adicional.

**Ejemplo práctico:**

- Peso base: 2 kg = $40.75.
- Peso adicional: 500 g = 500 × $0.12 = $60.00.
- **Total:** $40.75 + $60.00 = $100.75.

#### Ejemplo 2: Precio Total de Orden Compleja

- El precio total de una orden es la suma del precio de los artículos ordenados, menos los descuentos de volumen, más los impuestos de ventas federales y del estado para la ubicación a la que se envía, más los gastos de envío, más un cargo de seguro opcional.

**Fórmula:**

```
Precio Total = (Precio Artículos - Descuentos) + Impuestos + Gastos Envío + Seguro Opcional
```

### Problema del Lenguaje Natural en Cálculos

> **Concepto clave:** Los cálculos expresados en lenguaje natural pueden ser difíciles de entender y de implementar, por lo que se recomienda usar representaciones tabulares.

Si expresamos cálculos complejos únicamente en lenguaje natural, pueden resultar confusos y difíciles de implementar. La solución es utilizar tablas para representar las reglas de negocio de tipo computacional.

### Representación Tabular de Cálculos

#### Recuadro: Ejemplo de Tabla de Descuentos por Volumen

```
┌─────────────────────────────────────────────────────────────┐
│              TABLA DE DESCUENTOS POR VOLUMEN               │
├─────────────┬─────────────────┬─────────────────────────────┤
│IDENTIFICADOR│ CANTIDAD COMPRA │    PORCENTAJE DESCUENTO     │
├─────────────┼─────────────────┼─────────────────────────────┤
│   DISC-1    │      1 - 5      │             0%              │
├─────────────┼─────────────────┼─────────────────────────────┤
│   DISC-2    │     6 - 10      │            10%              │
├─────────────┼─────────────────┼─────────────────────────────┤
│   DISC-3    │    11 - 20      │            20%              │
├─────────────┼─────────────────┼─────────────────────────────┤
│   DISC-4    │   21 o más      │            30%              │
└─────────────┴─────────────────┴─────────────────────────────┘
```

**Interpretación de la tabla:**

- Compra de 1-5 productos: Sin descuento (0 %).
- Compra de 6-10 productos: 10 % de descuento.
- Compra de 11-20 productos: 20 % de descuento.
- Compra de 21 o más productos: 30 % de descuento.

### Ventajas de la Representación Tabular

1. **Claridad visual:** Fácil de entender de un vistazo.
2. **Precisión:** Elimina ambigüedades del lenguaje natural.
3. **Facilidad de implementación:** Los desarrolladores pueden codificar directamente.
4. **Mantenimiento:** Cambios en las reglas se reflejan fácilmente.
5. **Comunicación:** Stakeholders comprenden rápidamente las reglas.

### Ejemplo Práctico: Proyecto de Cervecería

> **Nota contextual importante:** Este ejemplo ilustra cómo las reglas de cálculo se aplican en proyectos reales de comercio electrónico.

En un proyecto actual de tienda en línea para una cervecería, se maneja un precio por envío basado en el siguiente cálculo:

- **Menos de 2 botellas:** $190 pesos.
- **Más de 2 botellas:** $190 pesos + incremento por peso adicional.

El sistema debe calcular automáticamente el costo de envío basado en el peso total de las botellas.

---

### Resumen de los Tres Tipos Avanzados

#### Desencadenadores de Acción

- **Función:** Ejecutar comportamientos cuando se cumplan condiciones.
- **Patrón:** Si [condición] entonces [acción].
- **Resultado:** **Algo sucede** en el sistema.

#### Inferencias

- **Función:** Crear nuevos hechos a partir de hechos existentes.
- **Patrón:** Si [condición] entonces [nuevo conocimiento].
- **Resultado:** **Algo se establece** como verdad.

#### Cálculos Computacionales

- **Función:** Transformar datos usando fórmulas matemáticas.
- **Representación:** Tablas y fórmulas estructuradas.
- **Resultado:** **Nuevos datos** calculados.

> **Concepto clave:** La correcta identificación y documentación de estos tres tipos de reglas es esencial para desarrollar sistemas que reflejen con precisión la lógica de negocio de la organización.

---

_Continúa en la [Parte 4: Elicitación y Especificación de Reglas de Negocio](#parte-4-elicitación-y-especificación-de-reglas-de-negocio)_

> ℹ️ Consulta también el [`Catálogo de Reglas de Negocio`](./business-rules-catalog.md) para la lista completa de reglas identificadas en la plataforma.

---

## Parte 4: Elicitación y Especificación de Reglas de Negocio

---

## Elicitación de Reglas de Negocio Durante la Recolección de Requerimientos

### Estrategia de Elicitación

> **Concepto clave:** Como analistas, debemos hacer preguntas específicas para investigar las reglas de negocio que rigen las operaciones de la organización.

Durante la elicitación de requerimientos, los analistas deben formular preguntas estratégicas para descubrir las reglas de negocio subyacentes.

### Tipos de Preguntas para Elicitar Reglas de Negocio

#### Recuadro: Preguntas Estratégicas por Tipo de Regla

| Enfoque | Pregunta Clave | Tipo de Regla que Descubre | Ejemplo de Respuesta |
| --- | --- | --- | --- |
| **Políticas** | "¿Por qué lo tenemos que hacer de esta manera?" | Restricciones, Hechos | "Por la Ley Federal del Trabajo se debe hacer así" |
| **Modelos de datos** | "¿Cómo están relacionadas estas piezas de información?" | Hechos, Restricciones | "Por política empresarial, cada empleado debe tener RFC" |
| **Cálculos** | "¿Cómo es calculado este número?" | Cálculos computacionales | "Se calcula sumando días laborados menos retardos e incapacidades" |
| **Procesos** | "¿Qué sucede cuando...?" | Desencadenadores, Inferencias | "Cuando expira un contrato, se marca como vencido automáticamente" |

### Ejemplos Detallados de Elicitación

#### 1. Descubriendo Políticas Organizacionales

**Pregunta del analista:** "¿Por qué tenemos que hacer de esta manera el registro de empleados?"

**Posibles respuestas del stakeholder:**

- "Por la **Ley Federal del Trabajo** se debe registrar así".
- "La **Secretaría de Hacienda** nos exige retener el impuesto sobre la renta de cada trabajador".
- "Es **política de la empresa** que todos los empleados tengan seguro de vida".

> **Nota contextual importante:** En México, las regulaciones laborales y fiscales son especialmente estrictas, por lo que muchas reglas de negocio derivan directamente de estos marcos normativos.

#### 2. Identificando Relaciones de Datos

**Pregunta del analista:** "¿Cómo están relacionados estos datos?"

**Respuesta del stakeholder:** "Están relacionados porque la política de la empresa establece que cada empleado debe tener un RFC para poder ser contratado".

**Regla de negocio identificada:**

- **Tipo:** Hecho/Restricción.
- **Enunciado:** Para ser empleado de la organización, se debe contar con RFC válido.

#### 3. Descubriendo Cálculos Computacionales

**Pregunta del analista:** "¿Cómo se calcula el sueldo neto del empleado?"

**Respuesta del stakeholder:** "Se calcula sumando los días que laboró, restando los retardos, restando los días de incapacidad y aplicando las deducciones correspondientes".

**Regla de negocio identificada:**

- **Tipo:** Cálculo computacional.
- **Fórmula:** `Sueldo = (Días Laborados × Sueldo Diario) - Retardos - Incapacidades - Deducciones`.

---

## De Reglas de Negocio a Casos de Uso

### Transformación de Reglas en Requerimientos Funcionales

> **Concepto clave:** Algunas reglas de negocio conducen directamente a casos de uso, los cuales se convierten en requerimientos funcionales que hacen cumplir esa regla específica.

### Ejemplo Práctico: Sistema de Gestión de Químicos

#### Reglas de Negocio Identificadas

#### Recuadro: Tres Reglas de Negocio Ejemplo

**REGLA 1 - Desencadenador de Acción**

- **ID:** RN-001.
- **Enunciado:** Si se ha alcanzado la fecha de vencimiento de un producto químico, notificar a la persona que actualmente posee este producto.
- **Tipo:** Activador de acción.

**REGLA 2 - Inferencia**

- **ID:** RN-002.
- **Enunciado:** Un contenedor de químicos que contenga productos explosivos es considerado caduco después de un año de su fabricación.
- **Tipo:** Inferencia.

**REGLA 3 - Hecho**

- **ID:** RN-003.
- **Enunciado:** Los éteres pueden formar espontáneamente peróxidos explosivos.
- **Tipo:** Hecho.

#### Derivación del Caso de Uso

A partir de la **REGLA 1** (desencadenador de acción), podemos derivar el siguiente caso de uso.

#### Recuadro: Caso de Uso Derivado

**Caso de uso:** Notificar a propietario de químico por caducidad.

**Descripción:** Este caso de uso enviará por correo electrónico una notificación al propietario actual del contenedor de productos químicos en la fecha en que expiran los contenedores.

**Actor principal:** Sistema de gestión de químicos (automatizado).

**Flujo principal:**

1. El sistema detecta que se ha alcanzado la fecha de vencimiento.
2. El sistema identifica al propietario actual del contenedor.
3. El sistema genera una notificación de caducidad.
4. El sistema envía el correo electrónico al propietario.

**Regla de negocio asociada:** RN-001.

### Proceso de Transformación

> **Concepto clave:** Las reglas de negocio sirven como origen para características específicas del sistema, que se implementan a través de casos de uso y posteriormente como requerimientos funcionales.

**Flujo de transformación:**

1. **Regla de negocio** → Define qué debe suceder.
2. **Caso de uso** → Define cómo el sistema lo implementará.
3. **Requerimiento funcional** → Define la funcionalidad específica del software.

---

## Especificación de Reglas de Negocio

### Catálogo Simple de Reglas de Negocio

> **Concepto clave:** Un catálogo de reglas de negocio simple es suficiente al inicio del proyecto, pero organizaciones grandes requieren bases de datos especializadas para la gestión de reglas.

#### Enfoque Inicial

Simplemente crear una lista de cuáles son nuestras reglas es suficiente en un comienzo.

#### Enfoque Avanzado

Para grandes organizaciones o aquellas cuyas operaciones empresariales y sistemas de información están fuertemente impulsadas por reglas de negocio, se deben establecer **bases de datos de reglas de negocio**.

### Mejores Prácticas para la Gestión de Reglas

#### 1. Centralización de Reglas

- **Agregar nuevas reglas** al catálogo a medida que se identifiquen.
- **Evitar incrustar** las reglas en la documentación de aplicaciones específicas.
- **Nunca especificar** las reglas únicamente en el código fuente.

> **Nota contextual importante:** La especificación de reglas de negocio exclusivamente en código es una de las peores prácticas, ya que dificulta el mantenimiento y la comprensión del sistema.

#### 2. Documentación Estructurada

Lo peor que podemos hacer es simplemente establecer las reglas en el código sin documentarlas apropiadamente en documentos o bases de datos.

---

## Plantillas Estructuradas para Reglas de Negocio

### Evolución hacia Plantillas

> **Concepto clave:** A medida que ganamos experiencia con la identificación y documentación de reglas de negocio, podemos aplicar plantillas estructuradas para definir reglas de diferentes tipos.

### Ejemplo de Plantilla Estructurada

#### Recuadro: Plantilla para Documentación de Reglas de Negocio

```
┌─────────────────────────────────────────────────────────────┐
│              PLANTILLA DE REGLA DE NEGOCIO                 │
├─────────────────────────────────────────────────────────────┤
│ ID REGLA:     [Identificador único]                        │
│ DEFINICIÓN:   [Descripción completa de la regla]           │
│ TIPO:         [Hecho/Restricción/Activador/Inferencia/     │
│                Cálculo]                                    │
│ NATURALEZA:   [Estática/Dinámica]                          │
│ FUENTE:       [Documento, ley o política origen]           │
│ FECHA:        [Fecha de definición/actualización]          │
│ RESPONSABLE:  [Persona o área responsable]                 │
│ ESTADO:       [Activa/Inactiva/En revisión]                │
└─────────────────────────────────────────────────────────────┘
```

### Ejemplo de Reglas Documentadas

#### Recuadro: Ejemplos de Reglas con Plantilla

**REGLA 1**

- **ID:** DISC-1.
- **Definición:** Compras de 1 a 5 productos no reciben descuento por volumen.
- **Tipo:** Cálculo computacional.
- **Naturaleza:** Estática.
- **Fuente:** Política Comercial v2.1.

**REGLA 2**

- **ID:** DISC-2.
- **Definición:** Compras de 6 a 10 productos reciben 10 % de descuento.
- **Tipo:** Cálculo computacional.
- **Naturaleza:** Dinámica.
- **Fuente:** Política Comercial v2.1.

**REGLA 3**

- **ID:** SEC-001.
- **Definición:** Solo gerentes pueden generar reportes de exposición química.
- **Tipo:** Restricción.
- **Naturaleza:** Estática.
- **Fuente:** Manual de Seguridad Industrial.

### Clasificación: Estática vs. Dinámica

#### Reglas Estáticas

- No tienen cambios con respecto al tiempo.
- Son **constantes** y **permanentes**.
- Ejemplo: "Cada empleado debe tener RFC".

#### Reglas Dinámicas

- Cambian con respecto al tiempo.
- Se **actualizan periódicamente**.
- Ejemplo: "Descuentos por volumen" (pueden cambiar según promociones).

> **Nota contextual importante:** La clasificación estática/dinámica ayuda a planificar la frecuencia de revisión y actualización de las reglas en el sistema.

---

## Beneficios de la Especificación Estructurada

### 1. Trazabilidad

- Cada regla tiene un **identificador único**.
- Se puede **rastrear** desde su origen hasta su implementación.
- Facilita las **auditorías** y **revisiones**.

### 2. Mantenimiento

- **Actualizaciones centralizadas** afectan todo el sistema.
- **Cambios controlados** con historial de versiones.
- **Eliminación** o **modificación** sistemática.

### 3. Comunicación

- **Lenguaje común** entre stakeholders.
- **Formato estándar** que facilita la comprensión.
- **Documentación profesional** para auditorías.

### 4. Implementación

- Los desarrolladores tienen **especificaciones claras**.
- **Reducción de errores** de interpretación.
- **Facilita las pruebas** de cumplimiento de reglas.

---

## Resumen Final: Proceso Completo de Gestión de Reglas de Negocio

### Fase 1: Elicitación

1. Formular **preguntas estratégicas** durante la recolección de requerimientos.
2. **Identificar** políticas, relaciones de datos y cálculos.
3. **Clasificar** las reglas por tipo.

### Fase 2: Análisis

1. **Transformar** reglas aplicables en casos de uso.
2. **Derivar** requerimientos funcionales.
3. **Establecer** la lógica del sistema.

### Fase 3: Documentación

1. **Crear** catálogo centralizado de reglas.
2. **Aplicar** plantillas estructuradas.
3. **Mantener** trazabilidad y versionado.

### Fase 4: Gestión

1. **Actualizar** reglas según cambios del negocio.
2. **Revisar** periódicamente reglas dinámicas.
3. **Auditar** cumplimiento en el sistema.

> **Concepto clave:** La gestión efectiva de reglas de negocio es un proceso continuo que requiere disciplina, estructura y herramientas apropiadas para asegurar que los sistemas reflejen con precisión las políticas y regulaciones organizacionales.

---

## Conclusión del Documento Completo

Las reglas de negocio constituyen el fundamento sobre el cual se construyen todos los demás requerimientos del sistema. Su correcta identificación, documentación y gestión es esencial para desarrollar sistemas de información que verdaderamente sirvan a los objetivos organizacionales y cumplan con las regulaciones aplicables.

La comprensión profunda de los cinco tipos de reglas de negocio y la aplicación sistemática de técnicas de elicitación y especificación permitirá a los analistas de requerimientos crear sistemas más robustos, mantenibles y alineados con las necesidades del negocio.
