---
name: tracon-quality
description: Audita, revisa o valida cambios de Tracon: diff, arquitectura, errores de edición, pruebas, seguridad, responsive, migraciones, contratos, bloqueos de herramientas y criterios de finalización. Carga únicamente las skills de los archivos afectados.
---

# Tracon Quality

## Objetivo

Encuentra y corrige problemas reales. Una lista de hallazgos no sustituye la implementación cuando el usuario pidió arreglarlos.

## Skills compañeras

Determina por rutas y naturaleza del cambio:

- Arquitectura, dependencias, clases acopladas, responsabilidades o patrones: `tracon-architecture`.
- `mobile/` o UI: `tracon-mobile`; añade `tracon-design` si hay impacto visual.
- `backend/` o migraciones: `tracon-backend`.
- `services/`, R2 o HLS: `tracon-media`.
- Reglas funcionales: `tracon-product`.
- `infra/`, Compose, Nginx o VPS: `tracon-infrastructure`.
- `AGENTS.md` o `.agents/`: `tracon-agent-rules`.

No cargues dominios no afectados.

## Inicio

1. Registra objetivo raíz y archivos cambiados.
2. Identifica tecnologías y consumidores.
3. Carga las skills técnicas correspondientes.
4. Lee solo referencias necesarias:
   - `references/validation-and-testing.md`
   - `references/tool-blockages.md`
   - `references/task-completion-and-reporting.md`
5. Puedes usar `scripts/inspect-changes.ps1` sin modificar archivos.
6. Si el diff toca backend, datos, API, Redis, realtime, webhooks o workers,
   aplica también `../tracon-agent-rules/references/backend-data-api-scalability-safety.md`.

Antes de revisar o editar, aplica la protección del worktree e índice de
`tracon-agent-rules`; trata los cambios concurrentes como trabajo protegido.

## Revisión mínima

- Sintaxis, formato, imports, símbolos, rutas y assets.
- Tipos, nulabilidad, constructores, callbacks y estado.
- Arquitectura, responsabilidades, duplicación y código muerto.
- Seguridad, autorización, secretos y datos personales.
- Migraciones, restricciones, SQL, índices, paginación y N+1 cuando aplique.
- Responsive, texto largo, carga/error/vacío, accesibilidad y tema cuando aplique.
- En auditorías Play/UGC revisa la matriz superficie→reportar/bloquear/moderar,
  seguridad infantil, copyright/audio, Data Safety/SDKs, permisos, eliminación,
  manifiestos legales y respuestas manuales pendientes; no cierres con un
  “ready” si falta una decisión externa.
- Consumidores, contratos, pruebas y documentación.
- En Search revisa además privacidad del historial, filtros de visibilidad y
  bloqueos antes del ranking, cursor ligado a consulta/pestaña, límites y
  rate-limit, uso de renderers/stores canónicos y descarte de respuestas
  obsoletas. La matriz está en `docs/architecture/search.md`.
- Para comentarios verifica por separado `clientCommentId`/UUID servidor,
  retry, doble envío, mismo body con claves distintas, acciones PENDING,
  HTTP/WebSocket en cualquier orden, contadores y ausencia de errores raw en UI.
- Para estado social verifica una sola proyección por `postId`, snapshots
  absolutos sin doble incremento, privacidad de flags viewer, ACK/rollback,
  like-unlike rápido, dedupe por evento, orden por versión, reconexión y
  superficies feed/detalle/Traks/perfil/guardados/compartidos.
- Para notificaciones verifica la matriz foreground activo / foreground otro
  chat / background / terminated: mensaje realtime, read receipt, push/local,
  unread/badge, sonido/vibración, tap, deduplicación y ruta por conversationId.
- Para mensajería verifica doble tap, pérdida después de commit, ACK/eco en
  cualquier orden, reintento con el mismo `clientMessageId`, outbox acotado,
  secuencia de servidor, lectura monotónica y ausencia de duplicados por texto.
  La matriz canónica está en `docs/architecture/chat-messaging.md`.
- Para destinos históricos verifica cada estado `AVAILABLE/DELETED/NOT_FOUND/
  FORBIDDEN/UNAVAILABLE`, fallback por tipo, carrera durante la carga de la
  pantalla, preservación del historial, copy no bloqueante y deduplicación por
  `notificationId`/request.
- Diff completo, archivos accidentales y temporales.
- En releases productivos exige storage preflight/postflight, límites de disco/cache,
  retención de rollback, `DEPLOY_AUTO_PRUNE_VOLUMES=false`, ausencia de prune global
  y evidencia de que PostgreSQL, Redis, Viax, secrets, backups y data volumes fueron
  preservados.
- En releases multi-agente revisa request/overlay/hash, cutoff y conflictos,
  aislamiento del candidato, separación entre estado de request y deployment,
  resumen/diagnostics persistidos y que el retry no recapture, regenere, valide,
  construya ni publique de nuevo el mismo contenido.
- En el bootstrap inicial verifica que un release histórico sin source no se
  infiera, que el preview y la captura aprobada queden fuera del worktree, que
  mobile/web no entren al bootstrap server-side y que solo una nueva release
  completada con validator PASS promueva y retenga el snapshot exacto.
- En incidentes de datos exige primero fase forense read-only, comparación en una
  base temporal aislada, inventario R2 sin borrado y clasificación de relaciones;
  usa `../tracon-infrastructure/scripts/audit-production-safety.ps1` y no bloquea
  las eliminaciones legítimas del producto fuera de las rutas operativas.
- En cambios de límites verifica separación cuota/seguridad, idempotencia bajo
  reintento, ventana UTC, `unlimited` explícito, `Retry-After`, fallo de Redis,
  capacidad de video y que no haya exenciones en filtros de seguridad. Usa
  `docs/architecture/quota-and-rate-limiting.md` como contrato de revisión.
- En cualquier revisión de API/datos comprueba elección de protocolo, query
  amplification/N+1, projection/fetch plan, paginación y page cap, payload,
  timeout, retry owner, idempotencia, BOLA/property auth, SSRF, rate limit,
  concurrencia, backpressure, observabilidad y capacidad. No conviertas una
  heurística ambigua en fallo automático sin evidencia.

En auditorías SEO comprueba conjuntamente status HTTP, redirects, robots,
canonical, sitemap, prerender de rutas públicas y que API/privadas sigan
protegidas; no declares éxito por reducir warnings de Search Console.

## Bloqueos

Un timeout o SDK bloqueado no autoriza éxito. Inspecciona el proceso, intenta soluciones no destructivas, ejecuta validaciones alternativas y reporta exactamente qué no pudo correr.

## Cierre

La tarea termina solo cuando el objetivo está integrado, las validaciones aplicables fueron ejecutadas o justificadamente sustituidas, los errores fueron corregidos y los riesgos residuales están documentados.

Para cambios de reconocimiento y avisos verifica la matriz
`NO_MATCH/MATCHED/REVIEW/MUTE/BLOCK`, cache L0, errores del proveedor,
reintentos idempotentes, persistencia offline, FCM/realtime y deep links;
una notificación duplicada o una alerta por error es un fallo de contrato.

Para lifecycle de datos valida la matriz cuenta/contenido/media/audio:
invisibilidad inmediata, idempotencia, shared references, holds, objetos R2,
ledger de reconocimiento, carrera durante processing/audio scan, Redis acotado,
Firebase por último y recuperación de jobs. Si Testcontainers, R2 o el worker
real no están disponibles, reporta el bloqueo y no lo sustituyas por éxito.

Para el portal valida además que cada pantalla privada corresponda a un
permiso RBAC, que el API no confíe en roles del cliente y que child safety,
copyright y support no filtren evidencia o secretos.

Para onboarding verifica el ciclo completo legal -> perfil -> nombre, la
idempotencia y carrera de username, la separación Firebase/perfil canónico,
el consumo one-shot de sugerencias Google y el fallo seguro de la importación
de avatar (allowlist, tamaño, MIME, media/R2 y purga). Si cambia backend o web,
la validación de producción y el despliegue siguen siendo parte del cierre.
