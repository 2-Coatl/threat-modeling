# UC-API-006: Generar artefactos PlantUML

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-006
**Versión:** 1.1
**Fecha:** 2025-10-27

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-006|
|**Nombre**|Generar artefactos PlantUML|
|**Actor primario**|SERVICIO DE UI|
|**Actores de soporte**|AUTOR FUNCIONAL|
|**Frecuencia estimada**|Media|
|**Prioridad**|Media — habilita entregables visuales alineados al modelo|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Crear artefactos derivados (imágenes o documentos) a partir del código PlantUML guardado para su distribución.
- **Resultado esperado:** Los artefactos quedan disponibles para compartir con las partes interesadas sin requerir herramientas adicionales.
- **Alcance incluye:**
  - ✅ Seleccionar la versión confirmada del diagrama.
  - ✅ Generar artefactos estándar definidos por la plataforma.
  - ✅ Informar el resultado al AUTOR FUNCIONAL.
- **Fuera de alcance:**
  - ❌ Personalizar estilos o plantillas a medida.
  - ❌ Publicar los artefactos en canales externos (cubierto por procesos operativos).

---

## 3. PRECONDICIONES

- Existe una versión vigente del diagrama apta para generar artefactos.
- Los servicios de conversión están disponibles.
- El actor posee permisos para solicitar los artefactos.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|SERVICIO DE UI|Solicita la generación de artefactos para la versión confirmada del diagrama.
|2|SISTEMA|Valida que la versión existe y puede procesarse.
|3|SISTEMA|Genera los artefactos definidos (por ejemplo, SVG y PDF) y los asocia a la versión.
|4|SISTEMA|Guarda los archivos en el repositorio de salidas.
|5|SISTEMA|Responde indicando que los artefactos están listos y dónde encontrarlos.
|6|SERVICIO DE UI|Muestra la confirmación al AUTOR FUNCIONAL y expone enlaces de descarga.

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El AUTOR FUNCIONAL solicita solo algunos formatos|El SISTEMA genera los formatos requeridos y confirma qué artefactos quedan disponibles.

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|Se detecta corrupción en la versión fuente|El SISTEMA aborta la generación, informa el problema y sugiere revisar el historial.
|FE-02|Los servicios de conversión no responden|El SISTEMA detiene el proceso, mantiene el estado previo y solicita reintento posterior.

---

## 7. POSTCONDICIONES

- **Éxito:** Los artefactos quedan disponibles y vinculados a la versión del diagrama.
- **Fallo:** No se generan archivos nuevos y la plataforma informa la razón del fallo.

---

## 8. REQUISITOS ESPECIALES

- Debe mantenerse consistencia entre los formatos generados (mismo contenido, distintos formatos).
- Las notificaciones al actor deben incluir fecha y hora de generación para control de versiones.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-002, UC-API-005.
- **Artefactos complementarios:** No aplica (repositorio de ejemplos en preparación).
- **Notas adicionales:** Los artefactos generados se consumen en la visualización de resultados (UC-API-009).

