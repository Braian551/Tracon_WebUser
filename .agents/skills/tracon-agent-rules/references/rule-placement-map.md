# Mapa para ubicar reglas

## `AGENTS.md`

Coloca aquí solo reglas que aplican prácticamente a toda tarea:

- Seguridad y secretos.
- Autorización para producción, Git y acciones destructivas.
- Aislamiento de Viax.
- Objetivo raíz.
- Principio de validación y honestidad.
- Fuente canónica y enrutamiento de skills.

No coloques árboles completos, manuales por framework, roadmap o listas detalladas de pruebas.

## Skill de dominio

Coloca en el `SKILL.md`:

- Cuándo se activa.
- Qué rutas o componentes abarca.
- Qué skills compañeras cargar y bajo qué condición.
- Reglas esenciales que casi toda tarea de ese dominio necesita.
- Cómo iniciar y cerrar.

## Referencia de skill

Coloca en `references/`:

- Arquitectura detallada.
- Matrices de validación.
- Flujos largos.
- Convenciones técnicas específicas.
- Casos excepcionales.
- Listas extensas de seguridad o rendimiento.

## Arquitectura y patrones de software

Coloca en `tracon-architecture` las reglas sobre:

- Clean Architecture y regla de dependencia.
- SOLID.
- Límites entre capas y módulos.
- Puertos y adaptadores.
- Selección y validación de patrones GOF.
- Criterios para evitar sobrearquitectura.

Las skills técnicas solo deben indicar cuándo cargar `tracon-architecture`; no deben copiar el catálogo de patrones. Las decisiones ejecutadas y específicas del proyecto se documentan en `docs/architecture/` o `docs/decisions/`.

## Documentación del proyecto

Coloca en `docs/`:

- Estado actual y decisiones de arquitectura.
- Contratos y esquemas explicados.
- Roadmap y alcance funcional.
- Procedimientos operativos versionados.
- ADR, dependencias y contexto histórico.

Una skill apunta al documento; no copia su contenido completo.

## Código y configuración

Valores ejecutables como tokens visuales, puertos, versiones, enums, migraciones y variables de ejemplo deben tener una fuente versionada en código/configuración. Las reglas explican cómo usarlos, no mantienen una segunda copia innecesaria.

## Instrucción puntual

Una preferencia válida solo para una tarea no debe persistirse como regla. Persistirla requiere que el usuario solicite explícitamente convertirla en estándar o que sea una corrección necesaria de una regla existente.
