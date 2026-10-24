# Operación, secretos y observabilidad

## Capacidad

- No agregues servicios pesados sin revisar RAM, CPU, disco y carga real del VPS compartido.
- Define límites de CPU, memoria, logs y almacenamiento temporal.
- No optimices a ciegas: mide latencia, consultas, colas, transcodificación y uso de recursos.

## Secretos

- Versiona únicamente `.env.example` sin valores reales.
- Mantén secretos en `/srv/tracon/secrets/` o en mecanismos protegidos del entorno.
- Permisos objetivo: secretos `600`, archivos normales `640`, directorios `750` cuando sea compatible.
- No guardes secretos en imágenes, releases, Flutter, logs o documentación pública.
- Diseña rotación de R2, JWT, SMTP, PostgreSQL, Redis y claves internas.

## Logs

Registra de forma estructurada:

- timestamp UTC;
- nivel;
- servicio y entorno;
- `request_id`;
- evento y duración;
- código de error.

No registres contraseñas, códigos, tokens, cookies, URLs firmadas completas, contenido privado ni datos personales innecesarios.

## Métricas mínimas

- solicitudes, latencia y errores;
- logins fallidos y rate limits;
- trabajos pendientes/fallidos y tiempo de transcodificación;
- disco temporal;
- hit/miss de caché;
- conexiones de base de datos;
- recursos de contenedores.

## Health checks

Separa liveness, readiness y dependencias. No expongas detalles sensibles públicamente.
