---
name: tracon-architecture
description: Diseña, refactoriza o revisa la arquitectura de software de Tracon con Clean Architecture, SOLID, límites modulares, puertos y adaptadores y patrones GOF justificados. Usar cuando cambien dependencias, responsabilidades, extensibilidad, proveedores, estados, estrategias, eventos o clases acopladas; no activarla para cambios locales simples que no alteran arquitectura.
---

# Tracon Architecture

## Autoridad

Esta skill es la fuente canónica para arquitectura limpia, SOLID, dependencias entre capas, puertos y adaptadores y selección de patrones de diseño de software. No reemplaza las reglas técnicas de Flutter, Spring, Go, datos, producto o infraestructura: las coordina cuando una decisión atraviesa esas capas.

Los cambios de límites, dependencias, eventos o contratos usan
`../tracon-change-contract/SKILL.md` y la política
`../tracon-agent-rules/references/change-contract-policy.md`.

## Cuándo cargarla

Cárgala cuando la tarea incluya una o más de estas situaciones:

- Definir o modificar límites entre módulos, capas o servicios.
- Refactorizar clases, widgets, controladores, servicios o workers con responsabilidades mezcladas.
- Reducir acoplamiento con Firebase, R2, SMTP, Redis, PostgreSQL, FFmpeg u otros proveedores.
- Elegir o revisar patrones GOF, SOLID, Clean Architecture, puertos/adaptadores o eventos.
- Sustituir condicionales crecientes por estrategias, estados, comandos o cadenas de responsabilidad.
- Crear múltiples implementaciones intercambiables de un contrato.
- Revisar dependencias circulares, acceso directo entre capas o módulos, lógica de negocio en infraestructura o UI.
- Diseñar un flujo transversal que involucre mobile, backend, media y producto.

No la cargues por rutina para renombrar, corregir estilos, ajustar texto, modificar una consulta aislada o implementar un caso directo sin decisión arquitectónica.

## Skills compañeras

Carga solo las capas afectadas:

- `tracon-mobile`: arquitectura Flutter, estado, navegación, SDKs y presentación.
- `tracon-backend`: módulos Spring, casos de uso, puertos, persistencia, seguridad y API.
- `tracon-media`: worker Go, R2, FFmpeg, HLS, colas y procesamiento.
- `tracon-product`: invariantes, estados y reglas funcionales que el diseño debe proteger.
- `tracon-billing`: cuando el flujo incluya catálogo, providers, compras, entitlements o RTDN.
- `tracon-quality`: auditoría arquitectónica amplia o validación transversal.
- `tracon-agent-rules`: únicamente cuando se editen las reglas de arquitectura dentro de `.agents`.

No cargues todas por anticipado. La skill inicial conserva el objetivo raíz y esta skill aporta la decisión arquitectónica.

Cuando el flujo transversal incluya outbox, estrategias de entrega, FCM, preferencias o deep links de notificaciones, carga tambien `tracon-notifications`.

## Inicio obligatorio

1. Define el problema concreto: acoplamiento, duplicación, variación, responsabilidad mezclada, dependencia incorrecta o dificultad de prueba.
2. Localiza productores, consumidores, contratos, pruebas y documentación afectados.
3. Dibuja mentalmente o documenta el flujo actual antes de proponer capas o patrones nuevos.
4. Revisa si el repositorio ya contiene un contrato, patrón o componente equivalente.
5. Lee solo las referencias necesarias:
   - `references/clean-architecture.md`
   - `references/pattern-selection.md`
   - `references/gof-patterns.md`
   - `references/language-mapping.md`
   - `references/architecture-validation.md`
6. Consulta ADR y documentos bajo `docs/architecture/` y `docs/decisions/` relacionados con la tarea.
7. Si el flujo cruza backend, persistencia, API o realtime, lee la referencia
   transversal `../tracon-agent-rules/references/backend-data-api-scalability-safety.md`.

## Reglas esenciales

- La regla de dependencia apunta hacia el negocio: presentación e infraestructura dependen de contratos internos; el dominio no depende de Flutter, Spring, Firebase, R2, Redis, JPA o FFmpeg.
- Organiza por módulo funcional antes que por tipo técnico global. Cada módulo mantiene sus casos de uso, dominio, puertos, adaptadores y API/presentación.
- Usa interfaces o abstracciones solo donde exista una frontera, variación, dependencia externa o necesidad real de prueba; no crees una interfaz por cada clase.
- Un caso de uso representa una intención del negocio y coordina dependencias; no debe convertirse en un contenedor gigante de utilidades.
- La lógica de negocio vive en dominio o aplicación, no en widgets, controladores HTTP, entidades JPA, mappers, repositorios concretos ni scripts de infraestructura.
- DTO, entidad de dominio, entidad de persistencia, proyección, evento y modelo de UI son conceptos distintos. No los unifiques por comodidad cuando cruce fronteras.
- No introduzcas un patrón GOF por moda, nombre académico o anticipación especulativa. Debe resolver un problema observable mejor que código directo.
- Prefiere composición sobre herencia. Usa herencia solo cuando la relación sea estable, verdadera y reduzca complejidad.
- Evita capas vacías, wrappers sin valor, fábricas que crean una sola clase sin variación y abstracciones que solo repiten el framework.
- No conviertas Clean Architecture en una obligación de cuatro carpetas idénticas para todo. La profundidad debe ser proporcional al módulo.
- Mantén contratos pequeños y orientados al consumidor. Evita interfaces generales con métodos que algunos adaptadores no pueden cumplir.
- Los eventos internos desacoplan efectos secundarios; los eventos durables usan outbox cuando no pueden perderse.
- Los eventos de notificación siguen siendo durables en PostgreSQL/outbox; una
  presencia Redis por instalación solo acelera la decisión de entrega push y no
  sustituye el evento realtime, el historial ni el read receipt.
- En mensajería directa, el transporte puede ser al menos una vez: la frontera
  durable es `conversationId` + `clientMessageId`, PostgreSQL asigna
  `serverSequence` e idempotencia, y Flutter reconcilia HTTP/WebSocket/outbox
  por identidad. La decisión completa vive en
  `docs/architecture/chat-messaging.md`.
- En comentarios, `clientCommentId` es la identidad de operación/idempotencia y
  `serverCommentId` es el UUID durable; no se usan de forma intercambiable.
  HTTP, historial y realtime reconcilian por esas identidades, nunca por body.
- El estado social de una publicación usa una proyección canónica por `postId`;
  los contadores globales son snapshots absolutos y los flags del viewer son
  privados. Mutaciones y `socialVersion` se confirman en PostgreSQL/outbox;
  Redis/WebSocket solo distribuyen el evento y el cliente deduplica por
  `eventId` y versión monotónica.
- Search devuelve IDs y DTOs de entidades canónicas desde el módulo backend;
  la presentación móvil reutiliza `CanonicalPostStore` y renderers existentes
  por tipo, sin crear tarjetas o stores paralelos. El contrato, ranking,
  cursor y límites viven en `docs/architecture/search.md`.
- El coordinador de navegación recibe el router explícitamente para que la capa
  de aplicación no dependa de un `BuildContext` accidental del shell.
- La navegación por referencia usa un plan primario/fallback y un resolver de
  disponibilidad en la capa de aplicación; los widgets solo consumen la
  intención después del frame y no mutan estado de sus padres durante su
  actualización. Los ledgers de request son acotados e idempotentes.
- No uses Observer en memoria como sustituto de consistencia durable entre procesos.
- No uses Singleton manual para estado mutable global. Deja el ciclo de vida a la inyección de dependencias y mantén servicios sin estado cuando sea posible.
- Documenta decisiones arquitectónicas transversales o difíciles de revertir mediante ADR. No generes ADR para cambios locales obvios.
- Conserva compatibilidad con la arquitectura actual de Tracon: monolito modular primero, extracción solo con métricas y frontera estable.
- Para release multi-agente, conserva la separación `request -> overlay ->
  baseline -> batch -> candidate -> executor`: el coordinador orquesta el
  flujo, el ejecutor existente mantiene build/deploy y el runner remoto mantiene
  la máquina de deployment reanudable. Cuando falta source histórico, el flujo
  one-time es `approved snapshot -> new release -> validated promotion` y no
  una inferencia desde el worktree. La referencia operativa vive en
  `docs/deployment/multi-agent-release.md`.
- La identidad de un source snapshot usa el puerto/función canónica
  `Get-TraconSourceSnapshotHash` en todos los stages; el snapshot es fuente
  inmutable y el executor recibe un working copy aislado para evitar que
  Maven/tests/codegen muten la evidencia.
- Para flujos transversales de admisión, separa intención de producto, protección de seguridad y capacidad técnica; reutiliza el contrato canónico de `docs/architecture/quota-and-rate-limiting.md` en lugar de crear contadores locales o exenciones por capa.
- La matriz REST/GraphQL/gRPC/WebSocket/webhook/async y la matriz JPA/projection/
  batch/native SQL son canónicas en la referencia transversal de backend/datos.
  Selecciona protocolo y persistencia por patrón de acceso y evidencia, no por
  moda; toda frontera nueva declara coste, seguridad, fallo, observabilidad,
  compatibilidad y cómo se probará.

## Selección de patrones

Antes de aplicar un patrón, registra de forma breve:

1. Problema y evidencia.
2. Variación o cambio esperado.
3. Alternativa directa considerada.
4. Patrón elegido y participantes.
5. Costo añadido.
6. Cómo se probará.
7. Condición para retirarlo si deja de aportar valor.

Patrones prioritarios en Tracon, solo cuando correspondan:

- `Strategy`: algoritmos o políticas intercambiables.
- `State`: comportamiento dependiente de estados válidos y transiciones.
- `Adapter`: SDKs, proveedores y contratos externos.
- `Factory Method` o fábrica simple: selección de implementaciones o creación compleja justificada.
- `Builder`: objetos complejos con muchas opciones válidas, especialmente pruebas/configuración.
- `Command`: intención ejecutable, colas, idempotencia o deshacer/compensar.
- `Observer`: eventos internos no durables; para integración durable usar outbox.
- `Chain of Responsibility`: validaciones o filtros independientes y ordenados.
- `Facade`: entrada simple a un subsistema complejo sin ocultar autorización ni errores.
- `Decorator`: añadir comportamiento transversal por composición.
- `Template Method`: flujo estable con pasos variables; preferir Strategy cuando la herencia no sea natural.

Los demás patrones GOF están permitidos si la referencia demuestra una necesidad concreta.

La separación de audio respecto de video y mute, junto con el contrato de compartir por referencia, es una decisión transversal documentada en `docs/architecture/audio-and-sharing.md`; no se replica en módulos consumidores.

## Cierre

- Verifica dirección de dependencias y ausencia de ciclos.
- Confirma que cada clase o componente tiene una responsabilidad coherente.
- Revisa que el patrón reduzca complejidad neta y no solo aumente archivos.
- Ejecuta pruebas del comportamiento anterior y nuevo.
- Valida consumidores, contratos, serialización, persistencia y eventos afectados.
- Actualiza documentación o ADR solo cuando la decisión sea transversal, persistente o difícil de revertir.
- Reporta el problema corregido, el patrón aplicado o descartado y la razón.

## Lifecycle durable de datos

Las eliminaciones que cruzan PostgreSQL, Redis y R2 deben modelarse como una
operación durable por etapas: estado persistido, outbox/job idempotente,
manifiesto exacto de objetos y comprobación final de referencias y holds.
docs/architecture/data-deletion-lifecycle.md es la fuente canónica; no
introducir borrados directos desde un controlador ni heurísticas de prefijo.

Para superficies administrativas, mantener la frontera Firebase-identidad,
PostgreSQL-autorización y API backend-owned descrita en
docs/architecture/web-admin-portal.md y docs/architecture/rbac.md.

En onboarding, Firebase/Google solo prueba la identidad y puede aportar una
sugerencia de primera alta. `profile.user_profiles` es el perfil social
canónico de Tracon: `displayName` y `username` se completan juntos, y los
logins posteriores nunca sincronizan ni reemplazan esos datos. Un avatar de
Google, si se acepta, debe entrar una sola vez al puerto de media canónico,
con SSRF/allowlist, manifiesto y procesamiento existentes.
