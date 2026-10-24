# Catalogo de eventos conectado

| Evento | IN_APP | PUSH | Agregacion | Ruta |
|---|---:|---:|---:|---|
| DIRECT_MESSAGE | si | si | hilo por `conversationId` | `/chats/<conversationId>` |
| COMMUNITY_MENTION | si | si | no | comunidad/canal |
| COMMUNITY_REPLY | si | si | no | comunidad/canal |
| USER_FOLLOWED | si | si | no | `/profile/<userId>` |
| POST_LIKED / TRAK_LIKED | si | si | si | `/posts/<id>` o `/traks/<id>` |
| POST_COMMENTED / TRAK_COMMENTED | si | si | no | comentarios |
| COMMENT_REPLIED / COMMENT_REACTED | si | si | no | comentarios |
| MENTION_IN_COMMENT | si | si | no | comentarios |
| POST_IMPULSED / TRAK_IMPULSED | si | si | si | `/posts/<id>` o `/traks/<id>` |
| POST_SAVED / TRAK_SAVED | si | si | si | contenido, sin actor |
| IMPULSE_QUOTA_RENEWED | si | si | no | `/profile/impulses` |

Los mensajes generales de una comunidad no generan una notificacion individual; solo menciones y respuestas. Seguridad, OTP, recuperacion y lifecycle conservan sus correos transaccionales propios.
