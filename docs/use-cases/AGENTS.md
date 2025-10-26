# Agent Instructions for `docs/use-cases/`

Estas reglas aplican a todo el catálogo de casos de uso (API y UI).

- Usa `templates/standard.md` como base obligatoria. Completa todos los campos;
  cuando una sección no aplique, escribe "No aplica" y explica por qué.
- Mantén los nombres de casos de uso con la convención `Verbo + Objeto` y los
  actores en mayúsculas. Los pasos del flujo deben alternar explícitamente entre
  acción del actor y respuesta observable del sistema.
- Diferencia claramente entre casos de uso y diagramas: las especificaciones son
  narrativas textuales; cualquier diagrama UML debe vivir en artefactos
  complementarios enlazados desde la sección de referencias.
- Cada modificación a un caso de uso activo debe reflejarse en el inventario de
  `README.md` y, si corresponde, en el mapeo de UI↔API.
- Documenta los requisitos especiales desde la perspectiva del actor (mensajes,
  restricciones visibles, atributos de calidad) evitando detalles de
  implementación interna.
