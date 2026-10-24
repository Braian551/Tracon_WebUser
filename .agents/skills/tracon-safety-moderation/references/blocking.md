# Bloqueos y visibilidad

`social.user_blocks(blocker_user_id, blocked_user_id)` es única por par. Una operación de bloqueo se ejecuta en una transacción y borra los follows en ambas direcciones. Un segundo bloqueo es idempotente; desbloquear no recrea follows.

Para una vista de otro usuario, salvo el propio usuario y un rol moderador autorizado, la existencia de un bloqueo en cualquier dirección debe producir una respuesta indistinguible de usuario no encontrado. Las listas y conteos también deben excluir ambos sentidos.

El bloqueo impide seguir, iniciar o enviar DM, menciones y notificaciones sociales nuevas. No purga mensajes, posts ni auditoría. La lectura de histórico queda sujeta a la política de producto y nunca debe permitir una nueva interacción.

Las consultas de contenido usan `NOT EXISTS` contra ambos sentidos; no confiar en ocultar solo en Flutter. Las comunidades conservan su membresía, pero sus detalles, mensajes, sugerencias y notificaciones son viewer-aware.
