# Flujo Graphify de Tracon

Esta referencia es la fuente canónica para usar Graphify durante el descubrimiento de código del repositorio. Graphify acelera la localización; el código fuente sigue siendo la autoridad.

## Inicio

1. Comprueba que Graphify esté disponible y ejecuta `graphify check-update .`.
2. Si no hay una reextracción semántica pendiente, consulta el grafo existente antes de una búsqueda amplia.
3. Prefiere `graphify explain` o `graphify path` cuando ya conozcas un símbolo. Usa consultas acotadas con un presupuesto habitual de 600–1500 tokens; reserva hasta 2000 para consultas realmente transversales.
4. Abre solo los archivos y símbolos que Graphify identifique y verifica cada inferencia en el código real.

## Actualización

- Ejecuta `graphify update .` una vez al final si hubo cambios estructurales: archivos, clases, funciones, servicios, endpoints, imports, eventos, migraciones o relaciones de llamadas nuevas, renombradas o movidas.
- Los cambios puramente cosméticos o internos —color, padding, tamaño, radio, copy o duración de animación sin cambios de estructura— no requieren actualización.
- No ejecutes `graphify extract .` ni una reconstrucción completa por defecto. Solo se permite si falta `graph.json`, está corrupto, cambió materialmente la versión o configuración del parser, `update` no puede reconciliar el grafo o el usuario lo solicita explícitamente.

## Salud y worktree compartido

- Si una actualización pequeña cambia más del 5% de nodos o aristas, no reconstruyas: ejecuta el diagnóstico soportado por la versión instalada (`graphify diagnose multigraph` en Graphify 0.9.52), revisa el manifiesto y el estado concurrente del worktree, y reporta la causa probable.
- El diagnóstico debe revisar endpoints faltantes, nodos colgantes, self-loops, advertencias de parseo e integridad del grafo. Las advertencias de headers nativos o vendor no relacionados no justifican modificar código de producto.
- El grafo representa el worktree actual compartido. No atribuyas todos sus nodos o deltas al agente actual sin evidencia.
- No modifiques `.agents/skills/graphify/SKILL.md` para reglas específicas de Tracon ni distribuyas copias de este flujo en otras skills; enlaza esta referencia canónica.
