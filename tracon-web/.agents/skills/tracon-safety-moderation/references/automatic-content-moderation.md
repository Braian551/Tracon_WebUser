# Moderación automática de contenido multimedia

Referencia canónica para imágenes y videos. No duplica reportes ni child
safety. El clasificador solo detecta NSFW genérico; no es detector de CSAM,
edad o delito.

## Invariantes

1. `LOCAL` es el proveedor activo. `EXTERNAL_MODERATION_ENABLED=false` y no
   hay llamadas billables a proveedores externos.
2. Flutter solo conoce `https://tracon.online`; nunca recibe IP, URL o secreto
   del worker remoto.
3. Detección, política y acción son capas separadas: el worker devuelve
   evidencia, core-api decide y la plataforma aplica visibilidad/cuarentena.
4. Estados de media: `PENDING`, `PROCESSING`, `SAFE`, `REVIEW`, `BLOCKED`,
   `FAILED`; `detection_status` es independiente de la decisión.
5. PostgreSQL conserva jobs, leases, intentos, hashes, versiones, scores,
   frames, timestamps y auditoría. Redis no es la única cola.
6. El caché usa hash + proveedor + versión de modelo + versión de política,
   con expiración e invalidación por versión.
7. El video usa muestreo y segunda pasada adaptativa acotados; hay límites de
   frames/bytes/duración y limpieza `finally`/watchdog.
8. La publicación exige `ready` técnico y `SAFE` para todos los assets.
   `REVIEW`, `BLOCKED` y `FAILED` quedan privados/cuarentenados y no se borran
   físicamente por esta decisión.
9. Reportes, copyright y child safety siguen separados. La cola automática
   usa `MODERATION_READ`, `MODERATION_REVIEW`, `MODERATION_DECIDE` y audita
   actor, objetivo, decisión, motivo y UTC.
10. Kill switch, modo, umbrales, límites, leases y retries son server-side;
    el modo inicial es `SHADOW` hasta calibración, legal y calidad.
11. El canal entre hosts usa allowlist de origen, HMAC de método/ruta/cuerpo,
    timestamp, nonce durable, timeout y límite de cuerpo. No se exponen
    PostgreSQL ni Redis.
12. El secundario solo aloja worker/modelo: compose/red propios, non-root,
    read-only, tmpfs, pids, límites CPU/RAM y concurrencia 1; sin privileged,
    Docker socket ni recursos del proyecto ajeno.
13. Notificaciones pasan por outbox/`NotificationOrchestrator`; el worker no
    envía notificaciones.
14. Tests usan fixtures neutros/sintéticos, mocks o modelos ya presentes; no
    pornografía real, CSAM, producción ni APIs externas.
15. Antes de afirmar producción se registran baselines antes/después,
    benchmark real, health, smoke SAFE, fallo/retry, aislamiento y ausencia de
    reinicios/OOM. No reboot ni limpieza global de Docker.
