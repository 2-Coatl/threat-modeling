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

_Continúa en la Parte 2: Tipos de Reglas de Negocio (Hechos y Restricciones)_

> ℹ️ Consulta también el [`Catálogo de Reglas de Negocio`](./business-rules-catalog.md) para la lista completa de reglas identificadas en la plataforma.
