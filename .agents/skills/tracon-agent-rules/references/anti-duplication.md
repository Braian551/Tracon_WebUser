# Protocolo contra duplicación

## Antes de agregar

Busca palabras clave, sinónimos y comandos relacionados en:

```text
AGENTS.md
.agents/skills/*/SKILL.md
.agents/skills/*/references/*.md
docs/**/*.md
```

No asumas que una frase distinta representa una regla nueva.

## Al actualizar

1. Identifica la fuente canónica.
2. Edita la regla allí.
3. Elimina copias equivalentes.
4. En archivos consumidores deja, como máximo, una referencia breve a la fuente.
5. Actualiza el enrutamiento solo si cambia cuándo debe cargarse una skill.

## Duplicación aceptable

Solo se permite repetir una frase corta cuando es una barrera crítica de seguridad o autorización y la repetición evita una acción peligrosa inmediata. Incluso entonces, la explicación detallada vive en una sola fuente.

## Señales de duplicación

- La misma lista aparece en `AGENTS.md` y una skill.
- Varias skills explican el mismo procedimiento de bloqueo.
- Una regla visual está en mobile, design y producto.
- Un flujo de despliegue está en infraestructura, quality y `AGENTS.md`.
- Cambiar una regla exige editar tres o más archivos con el mismo texto.

## Reorganización

Cuando una regla creció demasiado:

- Conserva el resumen operativo en `SKILL.md`.
- Mueve el detalle a una referencia temática.
- No mantengas simultáneamente el bloque antiguo y el nuevo.
