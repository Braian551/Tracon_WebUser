---
name: tracon-notifications
description: Implementa o revisa las notificaciones de Tracon: centro in-app, FCM, registros multi-dispositivo, permisos Android, canales, badges, deep links, agregacion, privacidad, email transaccional y outbox.
---

# Tracon Notifications

## Proposito

Mantiene la arquitectura real de notificaciones de Tracon en backend y Flutter.
Carga esta skill cuando una funcionalidad produzca una interaccion social para otro usuario, envie mensajes, comentarios, likes, Impulsos, guardados, follows o menciones, o cambie NotificationType, preferencias, badges o deep links.

Lee primero `references/notification-architecture.md` y `references/notification-event-catalog.md`. Carga tambien `tracon-backend`, `tracon-mobile`, `tracon-product` y `tracon-architecture` solo cuando los archivos afectados lo requieran. Para outbox, fanout, provider calls, rate limits o contratos, lee `../tracon-agent-rules/references/backend-data-api-scalability-safety.md`.

## Flujo obligatorio

Para cada evento responde explicitamente:

1. ¿Genera una interaccion para otro usuario?
2. ¿Requiere IN_APP, PUSH y/o EMAIL?
3. ¿Es agregable o idempotente?
4. ¿Expone datos privados o debe evitar self-notifications?
5. ¿Cual es el deep link validado y el canal Android?
6. ¿Como actualiza unread/seen/read y como se prueba?

Los eventos de negocio se persisten en la transaccion de origen y publican en `platform.outbox_events`. `NotificationOrchestrator` crea la fila durable de `notification.notifications`; los workers posteriores encolan email y push. No se envia FCM ni correo sin outbox, y no se registra el token sin cifrado y hash de instalacion.

## Reglas

- PostgreSQL es la verdad durable; Redis no sustituye notificaciones.
- `identity.users` y las reglas de bloqueos, visibilidad y estado activo autorizan al destinatario.
- Los tokens FCM se cifran en reposo; nunca se imprimen ni se incluyen en logs.
- Cada instalacion se identifica por un hash estable y revocable; la rotacion actualiza la misma instalacion.
- Android 13+ solicita `POST_NOTIFICATIONS` solo despues de una accion contextual del usuario.
- Los canales Android son estables y el usuario controla su importancia desde el sistema.
- El centro in-app funciona aunque el permiso push este denegado.
- Los deep links solo aceptan rutas internas permitidas de Tracon.
- Cada tap resuelve de forma lazy el objetivo actual mediante un
  `NotificationDestinationResolver`. Sus estados son `AVAILABLE`, `DELETED`,
  `NOT_FOUND`, `FORBIDDEN` y `UNAVAILABLE`; una referencia histórica nunca se
  elimina por fallar la navegación.
- La resolución separa destino primario y fallback estable: Trak vuelve a Traks,
  publicación a Inicio, perfil/comunidad a Inicio y conversación a Chats. Un
  comentario inaccesible conserva el padre disponible cuando es posible; el
  aviso usa `AppSnackBar` y no bloquea el flujo.
- La preconsulta no sustituye la autorización de la pantalla: la carga final
  debe manejar carreras 403/404/410. Se conservan pending de cold start,
  background y foreground, y se deduplican taps por `notificationId` y aperturas
  de chat por request.
- Los mensajes directos usan `conversationId` como entidad y destino; nunca
  convierten `senderUserId` en `conversationId` ni confían en `route` arbitraria.
- Un mensaje directo mantiene un hilo durable por conversación (`aggregation_key`
  estable y bucket fijo), conserva el mensaje en PostgreSQL y usa un tag Android
  estable para actualizar/cancelar la misma notificación.
- La conversación activa se anuncia por instalación mediante presencia efímera
  Redis con TTL; en foreground se suprimen push/local/unread/badge/sonido solo
  para esa conversación, pero el realtime y el read receipt continúan. Redis
  siempre falla abierto para no perder una entrega.
- `notification.read` y `chat.lastReadSequence` son estados distintos: abrir o
  marcar una notificación no marca todo el chat. El evento `CHAT_READ_UPDATED`
  solo acelera el marcador `Visto`; PostgreSQL y el historial HTTP conservan la
  autoridad. Ver `docs/architecture/chat-messaging.md`.
- El router de notificaciones debe esperar sesión `active`, conservar taps de
  cold start y deduplicar por `notificationId` antes de marcar leído/navegar.
- La eliminacion de cuenta debe purgar dispositivos, entregas y notificaciones segun la politica de lifecycle.
- Las notificaciones de comentario transportan el `serverCommentId` canónico
  en payload/deep link; no se construyen rutas con `clientCommentId`. Si llega
  un evento de comentario por realtime, el consumidor reconcilia por UUID y
  client id, nunca por texto.
- Los snapshots sociales reutilizan `/ws/user`; no se crea un canal paralelo.
  `eventId` deduplica entrega al menos una vez, `socialVersion` descarta
  eventos atrasados y `viewer` se filtra antes de salir del actor.
- El centro in-app es un inbox durable y el fanout FCM/email es async, aislado y
  bounded: reutiliza el outbox canónico, batch cuando el proveedor lo permita,
  respeta cuotas del proveedor y usa retries idempotentes con backoff y DLQ.
  Un webhook de proveedor aplica firma, replay protection, dedupe y ACK rápido;
  nunca ejecuta entrega pesada inline ni crea un segundo outbox.

## Validacion y release

Ejecuta analisis/tests focalizados de backend y mobile, valida V032 sobre una base real y revisa el diff en busca de secretos, tokens, temporales y duplicacion. Para produccion usa la skill de release e infraestructura: un backup unico inmediatamente antes de la migracion, tag inmutable, health checks y rollback estable.
