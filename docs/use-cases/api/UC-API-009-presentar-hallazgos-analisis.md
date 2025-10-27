# UC-API-009: Facilitar colaboración y exportaciones

**Sistema:** Threat Modeling Platform API
**Caso de Uso:** UC-API-009
**Versión:** 1.0
**Fecha:** 2025-10-28

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-API-009|
|**Nombre**|Facilitar colaboración y exportaciones|
|**Actor primario**|ORQUESTADOR DE MODELOS|
|**Actores de soporte**|BASE DE DATOS, SERVICIO DE NOTIFICACIONES|
|**Frecuencia estimada**|Media|
|**Prioridad**|Media — soporta trabajo en equipo y divulgación|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que los usuarios colaboren sobre modelos (comentarios, compartidos) y obtengan exportaciones formales de amenazas o modelos.
- **Resultado esperado:** La API almacena y expone comentarios, gestiona permisos y entrega archivos exportables en diferentes formatos.
- **Alcance incluye:**
  - ✅ Registrar y consultar comentarios y respuestas (`POST/GET /comments`).
  - ✅ Compartir modelos con usuarios específicos (`POST /share`).
  - ✅ Exportar hallazgos y modelos en formatos JSON o PDF.
- **Fuera de alcance:**
  - ❌ Gestión de roles globales (fuera del alcance de este caso).
  - ❌ Automatización de correos personalizados (pendiente de roadmap).

---

## 3. PRECONDICIONES

- El modelo existe y el usuario posee permisos acorde a la acción solicitada.
- Los servicios de notificaciones (correo) se encuentran disponibles para avisos de compartido.
- El motor de exportación (p. ej. Pandoc) está instalado cuando se requiere PDF.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|ORQUESTADOR DE MODELOS|Envía `POST /api/models/{model_id}/comments` con contenido y elemento asociado.| 
|2|API|Inserta comentario en base de datos, notifica a colaboradores y responde con el objeto creado.| 
|3|ORQUESTADOR DE MODELOS|Solicita `POST /api/models/{model_id}/share` con correo y permiso.| 
|4|API|Valida existencia del usuario, registra en `model_shares`, envía notificación y responde con el registro.| 
|5|ORQUESTADOR DE MODELOS|Ejecuta `GET /api/models/{model_id}/threats/export?format=pdf`.| 
|6|API|Compone reporte en Markdown, invoca Pandoc para generar PDF y devuelve archivo descargable.| 
|7|ORQUESTADOR DE MODELOS|Solicita `GET /api/models/{model_id}/export?format=json`.| 
|8|API|Construye JSON consolidado (modelo, amenazas, metadatos) y responde `200 OK` con archivo.| 

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|El usuario comparte con permiso "ver"|La API marca permiso de solo lectura y lo refleja en consultas posteriores.| 
|FA-02|Se requiere exportar solo hallazgos filtrados|La API acepta parámetros (`severity`, `status`) y aplica filtros antes de generar el archivo.| 

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|El usuario destinatario no existe|La API responde `404 Not Found` y no registra el compartido.| 
|FE-02|Falla la conversión a PDF|La API devuelve `502 Bad Gateway` con detalle del error de Pandoc.| 
|FE-03|El comentario supera longitud permitida|La API responde `400 Bad Request` especificando el límite.| 

---

## 7. POSTCONDICIONES

- **Éxito:** Comentarios, compartidos y archivos exportados quedan disponibles y auditados.
- **Fallo:** No se realizan cambios persistentes; se notifica el motivo y se registra el incidente.

---

## 8. REQUISITOS ESPECIALES

- Adjuntar en notificaciones el nombre del modelo y enlace directo a la vista correspondiente.
- Limitar exportaciones PDF a 50 MB para evitar saturar el servicio.
- Registrar en auditoría cada descarga con usuario, formato y timestamp.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-UI-003, UC-UI-002, UC-API-007, UC-API-011, UC-API-014.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Documentar proceso de revocación de accesos compartidos en la guía de soporte.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-API-009-01|Documentar webhook de notificación cuando se comparta un modelo.|Pendiente|Producto|
|TD-API-009-02|Agregar ejemplos de exportación filtrada por severidad.|Pendiente|Documentación|
