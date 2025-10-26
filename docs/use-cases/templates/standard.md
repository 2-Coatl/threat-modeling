# UC-XXX: <TÍTULO DEL CASO DE USO>

**Sistema:** <Nombre del sistema>
**Caso de Uso:** UC-XXX
**Versión:** <versión>
**Fecha:** <AAAA-MM-DD>

---

## 1. INFORMACIÓN GENERAL

|Atributo|Descripción|
|---|---|
|**Código**|UC-XXX|
|**Nombre**|<Nombre del caso de uso>|
|**Prioridad**|<🟢/🟡/🔴 + descripción>|
|**Actores**|<Lista con roles y códigos>|
|**Tipo**|<Tipo de caso (ej. lectura, mantenimiento)>|
|**Frecuencia de Uso**|<Alta/Media/Baja>|
|**Complejidad**|<Baja/Media/Alta>|

---

## 2. DESCRIPCIÓN

### 2.1 Propósito

<Breve explicación del propósito del caso de uso.>

### 2.2 Objetivo

- <Objetivo 1>
- <Objetivo 2>
- <Objetivo n>

### 2.3 Alcance

**Incluye:**

- ✅ <Actividad cubierta>

**NO Incluye:**

- ❌ <Actividad excluida>

### 2.4 Restricciones Especiales

1. <Restricción 1>
2. <Restricción 2>

---

## 3. PRECONDICIONES

### 3.1 Precondiciones del Sistema

```
PRECOND-01: <Descripción>
PRECOND-02: <Descripción>
```

### 3.2 Precondiciones del Usuario

```
PRECOND-XX: <Descripción>
```

### 3.3 Validación de Precondiciones

**Pseudocódigo:**

```
FUNCION validar_precondiciones_ucxxx(usuario_id):
    <Validaciones clave>
FIN FUNCION
```

---

## 4. FLUJO PRINCIPAL

### 4.1 Flujo Paso a Paso

```
<Pasos narrados o diagramados>
```

### 4.2 Pseudocódigo del Flujo Principal

```
FUNCION ejecutar_caso_de_uso(usuario_id):
    <Pasos principales>
FIN FUNCION
```

---

## 5. FLUJOS ALTERNATIVOS

### FA-01: <Nombre del flujo>

**Descripción:** <Contexto>

**Trigger:** <Evento>

**Flujo:**

```
<Pasos del flujo alternativo>
```

**Pseudocódigo:**

```
FUNCION flujo_alternativo(parametros):
    <Pasos>
FIN FUNCION
```

<!-- Repetir secciones FA-0X según sea necesario -->

---

## 6. FLUJOS DE EXCEPCIÓN

### FE-01: <Nombre del flujo>

```
<Pasos del flujo de excepción>
```

<!-- Repetir secciones FE-0X según sea necesario -->

---

## 7. POSTCONDICIONES

### 7.1 Postcondiciones de Éxito

```
POST-01: <Descripción>
```

### 7.2 Postcondiciones de Fallo

```
POST-FAIL-01: <Descripción>
```

---

## 8. REGLAS DE NEGOCIO

### 8.1 Reglas Generales

```
RN-001: <Descripción>
```

<!-- Añadir subsecciones adicionales (permisos, edición, etc.) según corresponda -->

---

## 9. TABLA DE BASE DE DATOS

### 9.1 Tabla: <nombre>

```sql
CREATE TABLE <tabla> (
    <columnas>
);
```

---

## 10. VALIDACIONES

### 10.1 Validaciones de Entrada

```
VAL-01: <Descripción>
```

### 10.2 Validaciones de Negocio

```
VAL-XX: <Descripción>
```

### 10.3 Validaciones de Seguridad

```
VAL-YY: <Descripción>
```

---

## 11. EJEMPLOS DE USO

### 11.1 Ejemplo: <Nombre>

1. <Paso 1>

---

## 12. REQUISITOS NO FUNCIONALES

### 12.1 Rendimiento

```
RNF-01: <Descripción>
```

<!-- Añadir subsecciones adicionales (usabilidad, seguridad, etc.) -->

---

## 13. NOTAS ADICIONALES

### 13.1 <Título>

<Contenido>

---

## 14. MATRIZ DE TRAZABILIDAD

|Requisito|Documento Origen|Sección|
|---|---|---|
|<ID>|<Documento>|<Referencia>|

---

**FIN DEL CASO DE USO UC-XXX**

**Próximo:** <Referencia opcional>
