# Reglas del dominio de interacción social

## Guardados

- La clave es `(user_id, post_id)` y la colección se ordena por
  `saved_at DESC, post_id DESC`.
- Solo `/me` puede listar guardados. Un perfil público nunca expone la colección.
- Guardar es idempotente; desguardar un elemento inexistente también.
- La miniatura no cuenta como reproducción y una cuadrícula no crea reproductores.

## Seguimiento y estadísticas

- La relación única es `(follower_user_id, followed_user_id)` y no permite auto-follow.
- Los bloqueos excluyen listas y mutaciones en ambas direcciones.
- Seguidores, siguiendo e Impulsos recibidos son cifras reales no negativas.
- Impulsos recibidos cuentan votos sobre posts publicados, aprobados y no eliminados.

## Impulsos

- El límite, el reset de cartera y la duración de `undo` son configuración del backend.
- La ventana usa instantes UTC, reset perezoso y bloqueo transaccional de cartera.
- Cada aplicación crea un consumo durable idempotente en `social.impulse_usages` y un efecto en `social.impulse_effects`.
- Un consumo gratuito exitoso conserva su ledger; un Deshacer válido antes de `undo_until` cambia el efecto a `UNDONE` y reembolsa exactamente una unidad a la misma cartera de la que salió, dentro de la misma transacción.
- El efecto es `ACTIVE` durante la ventana corta, luego `LOCKED`; `LOCKED` sigue contando, pero no admite Deshacer.
- Un usuario solo puede mantener un efecto `ACTIVE` o `LOCKED` por post; después de
  `UNDONE` puede reaplicar y cada reaplicación crea un nuevo consumo durable. No puede
  autoimpulsarse.
- `POST` (con `Idempotency-Key`) aplica; `POST /impulses/{usageId}/undo` identifica la misma aplicación, revierte solo su efecto y reembolsa su consumo diario una sola vez. El `PUT` y `DELETE` heredados son compatibilidad transitoria y no deben borrar historial.
- Las notificaciones usan el `usageId` como deduplicación y el evento `IMPULSED` lo registra el servidor, no el cliente.

## Cliente

- La UI optimista conserva el valor anterior y revierte de forma discreta ante error.
- El saldo se muestra únicamente en perfil propio y la renovación se presenta en la
  zona horaria efectiva sin cambiar el instante del servidor.
- La animación es breve, sin audio, respeta reducción de movimiento y no bloquea scroll.
