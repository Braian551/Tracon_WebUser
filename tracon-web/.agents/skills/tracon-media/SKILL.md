---
name: tracon-media
description: Implementa o revisa el flujo multimedia de Tracon: Cloudflare R2, URLs prefirmadas, imágenes, videos, FFprobe, FFmpeg, HLS, miniaturas, worker Go/Gin, estados de procesamiento, colas, idempotencia y reproducción Flutter. Carga las capas consumidoras solo cuando el flujo las afecte.
---

# Tracon Media

## Alcance

Aplica a `services/`, módulo media del backend, carga/reproducción Flutter, R2 y documentación multimedia.

## Skills compañeras

Carga solo cuando aplique:

- `tracon-architecture`: cuando se diseña el pipeline, contratos entre procesos, adaptadores, comandos, estados, estrategias, reintentos o patrones GOF.
- `tracon-backend`: autorización de carga, contratos, persistencia, estados o endpoints.
- `tracon-mobile`: selector, subida, progreso, estados o reproducción cliente.
- `tracon-design`: UI visible de selector, compositor, progreso, error o reproductor.
- `tracon-product`: reglas sobre tipos de contenido, moderación, visibilidad o publicación.
- `tracon-infrastructure`: buckets, variables, worker productivo, Compose, CDN/Nginx o despliegue.
- `tracon-quality`: auditoría end-to-end amplia.

## Inicio

1. Modela el flujo completo: autorización, carga, confirmación, trabajo, validación, transcodificación, almacenamiento, estado y reproducción.
2. Verifica propietarios, contratos, idempotencia, límites y eliminación.
3. Lee solo referencias necesarias:
   - `references/media-pipeline.md`
   - `references/go-workers-realtime.md`
   - `references/r2-and-media-security.md`
   - `references/media-validation.md`
4. Consulta documentos de arquitectura, seguridad y pruebas de medios aplicables.
5. Para límites de workers, payloads, caché, async, realtime o contratos,
   lee `../tracon-agent-rules/references/backend-data-api-scalability-safety.md`.

## Reglas

- El cliente sube el original directamente a R2 con autorización temporal; el backend no proxifica archivos pesados.
- Separa metadata de bytes: el backend entrega DTOs y URLs autorizadas; HLS,
  imágenes y audio grandes salen por R2/CDN/direct delivery, no por GraphQL,
  JSON REST o WebSocket como transporte de bytes.
- Valida usuario, cuenta, MIME real, firma, extensión, tamaño, duración, rutas y límites.
- No concatenes entrada del usuario en shell ni aceptes rutas arbitrarias.
- Todo video publicado para reproducción normal produce HLS y miniatura; no uses MP4 completo como flujo principal.
- No generes calidades superiores a la fuente ni 1080p sin necesidad medida.
- Usa trabajos idempotentes, estados explícitos, reintentos limitados, directorio temporal por trabajo y limpieza garantizada.
- Limita CPU, memoria, tiempo y disco temporal de FFmpeg.
- La concurrencia de workers, colas, downloads y proveedores es bounded, con
  backpressure, lease, timeout, lag y DLQ observables. Un nuevo límite reutiliza
  la capacidad canónica y no crea contadores locales paralelos.
- Flutter carga video en viewport, pausa al salir y libera controladores.
- La UI de subida traduce las etapas técnicas a un conjunto pequeño de estados de usuario; no
  expone nombres de HLS, FFmpeg o `audio_scan`.
- El porcentaje solo se muestra cuando proviene de bytes transferidos o progreso de procesamiento
  medible; las demás etapas son indeterminadas y `audio_scan` no bloquea `READY`.
- La preview local se genera una vez por tarea, se reutiliza desde el estado canónico y se limpia
  junto con el archivo temporal al finalizar, cancelar o descartar.
- El indicador persistente y la hoja de subidas observan el mismo coordinador y el indicador es
  no modal: no intercepta toques fuera de sus límites visuales.
- No uses Pub/Sub como única vía para eventos que no pueden perderse.
- Para incidentes, la clasificación DB/R2 es read-only y DB-led según
  `../tracon-agent-rules/references/production-data-safety.md`; un objeto
  `R2_ONLY` se conserva hasta demostrar su estado, y nunca se borra desde un
  release o una auditoría.
- La admisión de nuevo video reutiliza la capacidad central durable: un trabajo
  activo y dos en cola por usuario, 100 nuevos videos por día y concurrencia FFmpeg
  configurable. No cuentes `audio_scan` como nueva transformación; no dupliques
  estos límites en el worker. Consulta `docs/architecture/quota-and-rate-limiting.md`.

## Reproducción de Traks

`FeedVideoCoordinator` es la autoridad única de reproducción del feed inmersivo:
decide el media actual, asigna controllers, coordina autoplay, lifecycle,
preload y liberación. Los widgets observan el estado del slot; no interpretan
`!isPlaying` como pausa de usuario ni llaman `play`, `pause` o `dispose` en
paralelo.

La intención `autoplay` o `pausedByUser` pertenece al media actual. Un swipe
establece el nuevo Trak como autoplay y nunca hereda la pausa del anterior.
Buffering, preparación, lifecycle y navegación son estados técnicos separados.
El overlay central de play solo aparece después de una pausa explícita del
usuario; la miniatura permanece hasta observar el primer frame.

La precarga es acotada y prioriza `current`, `next` y, cuando el pool lo
permite, `previous`; los recursos lejanos se liberan fuera del camino crítico.
Los controllers se reutilizan por media y el límite debe mantenerse medible,
sin crear uno por cada widget o descargar el feed completo.

Las métricas de playback deben anclarse a la activación del media, no a la
creación del controller: `trak_preload_started`, `trak_preload_ready`,
`trak_activation_started`, `trak_play_requested`, `trak_first_frame`,
`trak_swipe_to_first_frame`, `trak_buffering_started`,
`trak_buffering_ended`, `trak_preload_hit`, `trak_preload_miss`,
`trak_controller_acquired`, `trak_controller_reused` y
`trak_controller_released`. Los resultados de profile/release son evidencia;
no se inventan p50/p95 ni validación física.

La política ejecutada y sus límites están documentados en
`docs/architecture/trak-playback-coordination.md`.

La fuente de audio es una identidad durable separada de la preferencia de silencio. FFprobe y el binding `media_id -> audio_asset_id` son la autoridad; `UNKNOWN/NONE` no permite reutilización. La decisión vigente sobre HLS muxado, audio restringido y una futura pista alternativa está en `docs/architecture/audio-and-sharing.md`. Todo proveedor multimedia externo debe aparecer en Privacidad/Data Safety con datos enviados, retención y contrato; ACRCloud identifica una grabación, pero `MATCHED` no es infracción y no habilita `LICENSED` sin evidencia contractual.

Los builds productivos de `media-worker` separan el contexto de build del release
runtime, mantienen BuildKit bajo la retención de infraestructura y nunca auto-prunean
volúmenes ni modifican `/var/lib/containerd` o `/var/lib/docker`.

El reconocimiento musical ocurre en un job durable posterior a la disponibilidad de HLS: reutiliza Audio Source/L0, hash PCM canónico/L1 y lock distribuido antes del proveedor. Un match no es una conclusión de derechos ni bloquea por sí solo; consulta `docs/architecture/audio-recognition.md`.

Cuando un `audio_scan` termina con `MATCHED` o `NO_MATCH`, media-worker persiste
un único evento `audio.scan.completed` en `platform.outbox_events` después del
resultado. El consumidor de notificaciones decide la alerta: `MATCHED/REVIEW`
puede crear un aviso durable; `NO_MATCH`, errores y presupuesto agotado no
alertan. La inserción debe ser idempotente y no incluir audio, firmas ni
secretos.

## Cierre

- Ejecuta pruebas de contrato, R2, worker, estados y end-to-end aplicables.
- Verifica temporales, objetos huérfanos, reintentos, idempotencia y autorización de lectura.
- Documenta cambios de bucket, prefijo, lifecycle, HLS o contrato.

## Validacion de fuentes antes del editor

La validacion de una fuente de video expone una razon estructurada interna y
un mensaje user-facing especifico y accionable. Los fallos conocidos no se
colapsan en un error generico de preparacion.

Source videos longer than the final Trak duration limit are editable
(`TRIM_REQUIRED`) rather than invalid whenever metadata, access, format, size,
resolution and frame-rate checks make that technically safe. Final output
duration constraints belong to the edit project; source duration may exceed
final duration. Backend and worker validation remain authoritative.

## Inventario y carreras de eliminación

Cada raw, variante, poster, manifest HLS, segmento bajo un prefijo exclusivo y
Audio Source debe registrar bucket lógico, clave exacta o prefijo exclusivo en
media.object_manifests. El worker debe comprobar el estado antes de descargar,
antes de publicar outputs y antes de emitir reconocimiento; una eliminación
concurrente no puede revivir el asset ni publicar un aviso huérfano. Los
fallos terminales encolan cleanup de outputs y conservan el raw solo si la
política de retry todavía lo permite.
