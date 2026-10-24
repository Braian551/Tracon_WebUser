# Arquitectura real de notificaciones

## Flujo

```text
Accion de negocio
  -> NotificationOrchestrator dentro de la transaccion
  -> notification.notifications + platform.outbox_events
  -> NotificationOutboxProcessor
  -> push_deliveries / email_outbox segun preferencias
  -> Firebase Admin FCM o AuthEmailSender
  -> centro Flutter y deep link validado
```

La migracion `V032__notification_center_and_delivery.sql` extiende las tablas existentes de `notification` y crea `notification.push_deliveries`. No existe un segundo outbox paralelo: se reutiliza `platform.outbox_events`.

## Canales y persistencia

- IN_APP: `notification.notifications`, cursor `(created_at,id)`, `seen_at`, `read_at`, `deleted_at`.
- PUSH: `notification.user_devices` y `notification.push_deliveries`; tokens cifrados AES-GCM y hash de `installation_id`.
- EMAIL: `notification.email_outbox` y el `AuthEmailSender` existente; los correos OTP, seguridad y lifecycle siguen separados.
- Preferencias globales actuales: `notification.preferences.push_enabled` y `email_enabled`. Los canales Android son adicionales y permanecen bajo control del sistema operativo.

## Entrega

Los workers reclaman filas con `FOR UPDATE SKIP LOCKED`, actualizan intentos y usan backoff. Un token FCM invalido revoca el dispositivo. El registro de instalacion es idempotente y la rotacion de token no crea otra fila.

## Flutter y Android

`NotificationsController` consume la API, mantiene el unread count y registra `firebase_messaging` sin prompt de arranque. Foreground refresca silenciosamente; background usa el handler top-level; terminated y taps usan `getInitialMessage` y `onMessageOpenedApp`. Android declara `POST_NOTIFICATIONS`, crea canales estables y usa los recursos nativos con densidad `ic_notification` como small icon monocromático, derivados del asset canónico de Tracon. La navegación recibe un `GoRouter` explícito mediante `AppNavigationCoordinator`; nunca llama `GoRouter.of` desde el `builder` de `MaterialApp.router`.

Los mensajes directos usan un hilo durable por conversación: `entity_id=conversationId`, `secondary_entity_id=messageId`, `aggregation_key=direct-message:<conversationId>`, bucket fijo `0` y tag Android `tracon-chat-<conversationId>`. La presencia de la conversación activa es efímera y por instalación en `tracon:<env>:notifications:active-chat:<installationHash>`, con TTL de 75 segundos. El push se suprime solo para esa instalación cuando está en foreground; Redis falla abierto y no reemplaza PostgreSQL.

En foreground activo, el evento realtime y el read receipt siguen funcionando, pero no se muestra notificación local ni se actualizan unread/badges/sonido/vibración para esa conversación. En background o terminated se conserva FCM y el tap vuelve a pasar por la allowlist y la sesión `active`.

## Privacidad y lifecycle

No se notifica al propio actor, se respeta bloqueo y cuenta activa, y los guardados no exponen al usuario que guardo contenido. `AccountPurgeService` elimina dispositivos, notificaciones, preferencias y outbox asociado por cascada.
