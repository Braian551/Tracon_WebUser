# Skills portables de Tracon

Esta carpeta contiene skills de proyecto en el formato `SKILL.md` con frontmatter mínimo (`name` y `description`). El núcleo evita configuraciones exclusivas de un proveedor para que pueda ser descubierto por herramientas compatibles con `.agents/skills`.

## Principio de carga

- `AGENTS.md` siempre orienta y enruta.
- El agente ve nombres y descripciones de skills.
- Carga el contenido completo solo cuando la tarea coincide.
- Cada skill puede indicar skills compañeras bajo condiciones concretas.
- Las referencias largas se leen bajo demanda.

## Skills

- `tracon-agent-rules`: edita y reorganiza reglas sin duplicación.
- `tracon-design`: sistema visual y UX.
- `tracon-legal`: auditoría jurídica, privacidad, tratamiento de datos, Play y contenido legal.
- `tracon-architecture`: Clean Architecture, SOLID, límites y patrones GOF.
- `tracon-billing`: monetización, Google Play Billing, catálogo y entitlements.
- `tracon-mobile`: Flutter y plataformas móviles.
- `tracon-web`: Vue.js, TypeScript, Tailwind CSS, componentes modulares, datos estáticos y UI.
- `tracon-backend`: Spring Boot, datos y seguridad servidor.
- `tracon-media`: R2, imágenes, video, HLS y worker Go.
- `tracon-product`: reglas funcionales y alcance.
- `tracon-infrastructure`: Docker, VPS y producción.
- `tracon-quality`: auditoría y validación transversal.

## Portabilidad

El paquete base no depende de `agents/openai.yaml`, comandos exclusivos ni frontmatter propietario. Los adaptadores opcionales para herramientas concretas están en `adapters/` y no son necesarios para el funcionamiento básico.

Las skills son específicas de Tracon y deben permanecer en el repositorio. No se recomienda instalarlas globalmente en el perfil del usuario porque podrían activarse en otros proyectos.
