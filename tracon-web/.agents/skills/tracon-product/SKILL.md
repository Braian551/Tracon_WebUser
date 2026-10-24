---
name: tracon-product
description: Define o revisa reglas funcionales de Tracon: visión, alcance beta, retos, evidencias, puntos, podios, feed, descubrimiento, perfiles, social, salas, bloqueos, reportes, moderación, eliminación de cuenta y roadmap. Para redacción legal, privacidad, tratamiento de datos, Play o regiones carga tracon-legal.
---

# Tracon Product

## Alcance

Usa esta skill cuando cambie comportamiento observable, reglas de negocio, estados, puntuación, moderación, decisiones funcionales de privacidad o alcance. La fuente canónica de redacción legal, tratamiento de datos, Google Play y regiones es `tracon-legal`.

Las reglas canónicas de monetización, membresías, Google Play Billing, productos y entitlements viven en `../tracon-billing/`; esta skill conserva únicamente las decisiones de producto que billing deba proteger.

Registra las decisiones funcionales materiales con
`../tracon-change-contract/SKILL.md` y la política
`../tracon-agent-rules/references/change-contract-policy.md`; usa FAST para
ajustes acotados.

## Skills compañeras

Después de definir la regla, carga solo la capa que la implementa:

- `tracon-architecture`: cuando una regla requiere modelar invariantes, estados, estrategias, comandos, eventos o fronteras entre módulos.
- `tracon-mobile`: comportamiento o presentación cliente.
- `tracon-design`: experiencia, jerarquía o patrón visual.
- `tracon-backend`: persistencia, API, autorización o cálculo servidor.
- `tracon-media`: tipos de evidencia y flujo multimedia.
- `tracon-infrastructure`: requisito operativo o despliegue.
- `tracon-quality`: revisión transversal de una regla sensible.

## Inicio

Cuando una regla social, de privacidad o lifecycle pueda producir una notificacion para otro usuario, carga tambien `tracon-notifications`.

1. Identifica actor, regla, permisos, estados, invariantes, efectos y consumidores.
2. Revisa documentación y migraciones antes de inventar estados, tablas o fórmulas.
3. Lee solo referencias necesarias:
   - `references/product-scope-and-roadmap.md`
   - `references/challenges-scoring-and-data-model.md`
   - `references/social-moderation-and-legal.md`
4. Consulta `docs/architecture/project-overview.md`, `docs/business/`, `docs/database/postgresql-schema.md`, `legal/` y ADR aplicables.

## Reglas

- La beta valida consumo, retos y comunidad; no agrega funciones avanzadas por moda.
- Estados y enums deben ser consistentes entre Flutter, Spring, Go, Redis y PostgreSQL.
- Los contadores sociales son globales y absolutos; `liked`, `boosted` y
  `saved` describen exclusivamente al viewer actual. Un ACK o evento repetido
  no puede duplicar una interacción visible.
- El texto repetido en comentarios es contenido válido. La idempotencia usa la
  identidad estable de la operación (`clientCommentId`), y los reintentos
  reutilizan esa misma clave; nunca se deduplica por body o hash.
- Las notificaciones son historial: si Trak, publicación, comentario, perfil,
  comunidad o chat ya no está disponible, el tap conserva el registro y lleva
  a una superficie estable con copy humano y feedback no bloqueante. El estado
  del objetivo no se inventa ni se confunde con autorización.
- En una conversación directa visible y en foreground, el mensaje siempre se
  entrega y se marca leído, pero no genera una alerta adicional (push/local,
  unread, badge, sonido o vibración). Si la conversación no está visible o la
  app está en background/terminated, la alerta sí se conserva.
- “Visible” no significa simplemente ruta abierta: solo los mensajes en la
  ventana visible y cerca del final avanzan el cursor monotónico de lectura.
  `Visto` es un marcador único del último mensaje propio que el interlocutor
  alcanzó; leer la bandeja de notificaciones no sustituye esa acción. Ver
  `docs/architecture/chat-messaging.md`.
- Puntos y votos se calculan en backend con restricciones, idempotencia y ledger inmutable.
- No permitas votar la propia evidencia ni más de un voto por usuario y evidencia.
- Cambios de puntuación revisan ledger, ranking, caché, workers, UI, moderación, reversiones, métricas, migraciones y pruebas.
- Feed y recomendaciones beta usan reglas determinísticas, filtros de seguridad y diversidad.
- Descubrimiento inicial no usa ubicación precisa por defecto.
- Bloqueos y moderación afectan visibilidad, interacción y recomendaciones coherentemente.
- Search solo confirma al historial una consulta enviada explícitamente; las
  teclas y sugerencias no se guardan. La relevancia textual domina popularidad,
  los resultados respetan visibilidad/bloqueos y discovery no fabrica
  tendencias. Ver `docs/architecture/search.md`.
- Cada tipo de UGC define antes de habilitarse su affordance de reporte, bloqueo,
  motivo `child_safety`, cola/decisión de moderación, apelación y comportamiento
  ante evidencia de derechos; no se considera suficiente que exista solo el
  endpoint general.
- Eliminación de cuenta preserva integridad, auditoría y obligaciones legales; no borra en cascada sin análisis.
- No inventes datos corporativos ni presentes como definitiva una política con marcadores pendientes; la prepublicación legal debe seguir el estado y el método de `tracon-legal`.
- Las cuotas de beta son reglas de producto separadas de la protección antiabuso:
  3 Traks, 5 publicaciones, 2 publicaciones con video y 5 videos procesables por
  día, con capacidad técnica independiente. Las exenciones configurables solo
  omiten cuotas de producto y nunca seguridad, moderación o legal. Consulta
  `docs/architecture/quota-and-rate-limiting.md`.

Audio y video son capacidades distintas: silencio es preferencia local, la fuente de audio es durable y `UNKNOWN/NONE` no habilita reutilización. La regla funcional y sus límites viven en `docs/architecture/audio-and-sharing.md`.

Un match de reconocimiento no demuestra titularidad ni licencia. Solo una licencia o política de derechos verificable habilita el catálogo oficial; desactivar reutilización y retirar/bloquear audio son acciones funcionales diferentes.

El aviso al creador solo se genera para un resultado `MATCHED` con acción
`REVIEW` (o una acción explícita `MUTE/BLOCK`); `NO_MATCH` y fallos no generan
alertas. En `shadow` el aviso es informativo: no silencia ni bloquea de forma
automática y conserva `rights_status=UNKNOWN` cuando no existe evidencia.

## Cierre

- Actualiza documentación de negocio cercana.
- Agrega o ajusta pruebas de reglas, permisos, estados, concurrencia y fraude.
- Verifica todos los consumidores de estados, payloads, fórmulas o contratos modificados.

## Validacion funcional de fuentes de video

La duracion de una fuente puede superar la duracion final permitida de un
Trak. Cuando la fuente es tecnicamente segura, su estado funcional es
`TRIM_REQUIRED` y debe continuar al editor; la restriccion de duracion final
pertenece al proyecto de edicion y a la suma de sus recortes.

Toda falla conocida de validacion debe conservar una razon estructurada y una
accion para el usuario. Nunca se colapsa un fallo conocido en un error generico
de preparacion.

## Eliminación, retención y contenido compartido

Desactivar, ocultar, eliminar contenido y purgar una cuenta son estados
distintos. El contenido compartido por referencia, Audio Source, evidencia de
moderación, licencia o hold no se elimina por pertenecer al usuario que inició
la operación. Las reglas completas viven en
docs/architecture/data-deletion-lifecycle.md.

El alcance operativo de administración, soporte, moderación, seguridad
infantil y copyright se documenta en docs/architecture/web-admin-portal.md;
no convertir una etiqueta técnica en una decisión legal o de seguridad.

El perfil inicial requiere nombre visible y username. El nombre y la foto de
Google son sugerencias de primera creación, no una sincronización continua;
una cuenta existente conserva su perfil Tracon. No se hace backfill masivo de
perfiles legacy con nombres genéricos.
