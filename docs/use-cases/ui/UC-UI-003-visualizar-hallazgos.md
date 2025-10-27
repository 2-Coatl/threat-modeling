# UC-UI-003: Compartir hallazgos con el equipo

**Sistema:** Threat Modeling UI
**Caso de Uso:** UC-UI-003
**Versión:** 1.1
**Fecha:** 2025-11-02

---

## 1. INFORMACIÓN GENERAL

|Campo|Detalle|
|---|---|
|**Código**|UC-UI-003|
|**Nombre**|Compartir hallazgos con el equipo|
|**Actor primario**|REVISOR DE SEGURIDAD|
|**Actores de soporte**|AUTOR FUNCIONAL, SERVICIO DE API, SERVICIO DE MENSAJERÍA|
|**Frecuencia estimada**|Semanal|
|**Prioridad**|Alta — habilita la colaboración y seguimiento de mitigaciones|

---

## 2. PROPÓSITO Y ALCANCE

- **Propósito:** Permitir que el REVISOR DE SEGURIDAD inspeccione hallazgos, colabore con el equipo y exporte evidencia para seguimiento.
- **Resultado esperado:** Los hallazgos quedan clasificados, con comentarios y estados actualizados, y el equipo recibe la información relevante.
- **Alcance incluye:**
  - ✅ Visualizar hallazgos por severidad y filtrar resultados.
  - ✅ Actualizar estado y notas de mitigación.
  - ✅ Gestionar comentarios, compartir el modelo y exportar reportes.
  - ✅ Consultar y administrar la bandeja de mensajes, notificaciones y alertas relacionadas con el modelo.
- **Fuera de alcance:**
  - ❌ Definir la taxonomía de amenazas (gestionada en los archivos pytm).
  - ❌ Modificar el modelo visual (cubierto por UC-UI-001).

---

## 3. PRECONDICIONES

- Existen hallazgos generados recientemente (UC-UI-002).
- El REVISOR DE SEGURIDAD cuenta con acceso al modelo y permisos de edición de hallazgos.
- La bandeja de actividad registra eventos del modelo.
- Existen mensajes generados por comentarios, hallazgos críticos o acciones de seguridad.

---

## 4. FLUJO PRINCIPAL (HAPPY PATH)

|Paso|Actor|Interacción|
|---|---|---|
|1|REVISOR DE SEGURIDAD|Ingresa al módulo de hallazgos y selecciona la pestaña "Resumen".| 
|2|SISTEMA|Muestra tarjetas con conteo por severidad, tiempo de generación y estado general.| 
|3|REVISOR DE SEGURIDAD|Aplica filtros por severidad, estado y elemento afectado.| 
|4|SISTEMA|Actualiza la lista de hallazgos respetando los filtros y orden preferido.| 
|5|REVISOR DE SEGURIDAD|Selecciona un hallazgo y marca "Mitigado", agregando notas descriptivas.| 
|6|SISTEMA|Guarda el nuevo estado, muestra confirmación y actualiza el registro en la actividad.| 
|7|REVISOR DE SEGURIDAD|Abre el panel de comentarios sobre un nodo específico y agrega una recomendación.| 
|8|SISTEMA|Publica el comentario, notifica a los colaboradores y mantiene el hilo visible en el lienzo.|
|9|REVISOR DE SEGURIDAD|Utiliza la opción "Compartir" para invitar a otro usuario con permiso de edición.|
|10|SISTEMA|Envía la invitación, refleja el nuevo colaborador y registra el evento en el feed.|
|11|REVISOR DE SEGURIDAD|Abre el centro de notificaciones para revisar alertas no leídas.|
|12|SISTEMA|Agrupa los mensajes por categoría (COMMENT, SHARE, THREAT_ALERT), muestra contadores y destaca los `unread`.|
|13|REVISOR DE SEGURIDAD|Marca como leído un mensaje crítico y filtra por categoría ALERT.|
|14|SISTEMA|Actualiza el badge de no leídos, registra `read_at` y mantiene el historial ordenado por `created_at` descendente.|
|15|REVISOR DE SEGURIDAD|Exporta el reporte de amenazas en PDF para adjuntarlo a la reunión semanal.|
|16|SISTEMA|Genera el archivo, inicia la descarga y confirma que el reporte incluye filtros aplicados.|
|17|REVISOR DE SEGURIDAD|Consulta la pestaña "Actividad" para verificar acciones recientes en el modelo.|
|18|SISTEMA|Muestra el feed cronológico con eventos de generación de diagramas, comentarios, mensajes y cambios de estado.|

---

## 5. FLUJOS ALTERNOS

|ID|Condición|Curso de acción|
|---|---|---|
|FA-01|Se requiere compartir solo lectura|El SISTEMA permite seleccionar permiso "Ver" antes de enviar la invitación y lo refleja en la lista de accesos.| 
|FA-02|El equipo necesita exportar JSON para integrar con otra herramienta|El SISTEMA ofrece el formato JSON y conserva la descarga previa en PDF.|
|FA-03|El REVISOR quiere limpiar notificaciones viejas|El SISTEMA permite aplicar filtros `read/unread` y `deleted`, y enviar acciones de eliminación lógica sobre mensajes propios.|
|FA-04|Se detecta actividad sospechosa en login|El SISTEMA resalta la alerta, enlaza al detalle auditado y recomienda verificar configuraciones de seguridad.|

---

## 6. EXCEPCIONES

|ID|Evento|Respuesta observable|
|---|---|---|
|FE-01|La actualización de estado falla|El SISTEMA muestra alerta, revierte el cambio local y mantiene el hallazgo en su estado previo.|
|FE-02|El correo de colaboración no corresponde a un usuario existente|El SISTEMA informa la situación y sugiere solicitar registro previo (UC-UI-004).|
|FE-03|El comentario no puede guardarse|El SISTEMA indica el error, preserva el texto en borrador y ofrece reintentar.|
|FE-04|El mensaje a revisar no pertenece al usuario|El SISTEMA bloquea la acción, muestra aviso "No tienes permisos" y mantiene el estado sin cambios.|
|FE-05|Falla el servicio de mensajería|El SISTEMA avisa que la notificación será reenviada, registra el evento como `email_sent = FALSE` y conserva el mensaje en la bandeja.|

---

## 7. POSTCONDICIONES

- **Éxito:** Los hallazgos quedan con estados actualizados, comentarios visibles y accesos compartidos según lo solicitado.
- **Fallo:** No se aplican cambios; el sistema conserva el estado anterior y registra el motivo en la actividad.

---

## 8. REQUISITOS ESPECIALES

- Los filtros deben persistir al navegar entre pestañas durante la misma sesión.
- Las notificaciones a colaboradores deben enviarse dentro de los 30 segundos posteriores a la acción.
- El reporte exportado debe incluir metadatos (autor, fecha, filtros aplicados) en la portada.
- La bandeja de mensajes debe ordenar por `created_at` descendente, permitir filtros por `type`, `category` y mostrar contador de no leídos.
- Las acciones de lectura y eliminación lógica deben sincronizarse en tiempo real entre múltiples sesiones del mismo usuario.

---

## 9. REFERENCIAS Y TRAZABILIDAD

- **Casos de uso relacionados:** UC-API-007, UC-API-009, UC-API-011, UC-API-012, UC-API-013, UC-API-014, UC-API-003, UC-API-000, UC-UI-001.
- **Artefactos complementarios:** No aplica.
- **Notas adicionales:** Documentar en la guía de soporte el procedimiento para revocar accesos compartidos.

---

## 10. TAREAS PENDIENTES DE DOCUMENTACIÓN

|ID|Tarea|Estado|Dueño recomendado|
|---|---|---|---|
|TD-UI-003-01|Actualizar capturas del módulo de comentarios con la vista de hilos anidados.|Pendiente|Documentación|
|TD-UI-003-02|Incluir ejemplos de mensajes de correo enviados al compartir modelos.|Pendiente|Producto|
