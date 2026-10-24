---
name: tracon-backend
description: Implementa o revisa el backend Spring Boot de Tracon: módulos, API REST, Firebase Admin, Spring Security, autorización, JPA/Hibernate, Flyway, PostgreSQL, Redis, correo, fechas, concurrencia, contratos y pruebas Java. No usar para cambios exclusivos de UI Flutter o despliegue productivo.
---

# Tracon Backend

## Alcance

Trabaja en `backend/core-api/`, migraciones, contratos y documentación servidor relacionada.

Usa `../tracon-change-contract/SKILL.md` y su política canónica para registrar
el alcance del cambio. Un fix backend pequeño puede usar FAST; cualquier
cambio deployable de server mantiene su Deployment Request independiente.

## Skills compañeras

Carga solo cuando aplique:

- `tracon-architecture`: cuando se modifican límites modulares, capas, puertos/adaptadores, dependencias, eventos, estrategias, estados o patrones GOF.
- `tracon-mobile`: cuando un contrato cambia y Flutter lo consume.
- `tracon-media`: cuando el flujo incluye R2, medios, estados de procesamiento o worker Go.
- `tracon-product`: cuando cambia una regla funcional, estado, permiso, puntuación o moderación.
- `tracon-infrastructure`: cuando cambia Compose, variables productivas, Nginx, despliegue o runtime servidor.
- `tracon-quality`: para auditoría amplia o validación transversal.
- `tracon-billing`: cuando el módulo, contrato, migración o proveedor corresponda a monetización y entitlements.

## Inicio

Cuando una accion genere interaccion para otro usuario, push/email, badges o cambie el outbox de notificaciones, carga tambien `tracon-notifications`.

1. Ubica el módulo propietario y todos sus consumidores.
2. Revisa API, aplicación, dominio, infraestructura, migraciones, pruebas y documentación.
3. Lee solo referencias necesarias:
   - `references/architecture-and-code.md`
   - `references/persistence-postgres-redis.md`
   - `references/security-api-time-and-email.md`
   - `references/backend-validation.md`
   - `references/authentication-onboarding.md` cuando se modifique el flujo Firebase, bootstrap de cuenta o username.
4. Consulta documentos aplicables bajo `docs/architecture`, `docs/database`, `docs/security`, `docs/business`, `docs/decisions` y `docs/dependencies/spring.md`.
5. Para cualquier cambio de API, persistencia, consulta, Redis, realtime,
   webhook, async o contrato, lee antes
   `../tracon-agent-rules/references/backend-data-api-scalability-safety.md`.

## Reglas

- Mantén el monolito modular; extrae servicios solo con evidencia técnica.
- Controladores delgados: formato, identidad, caso de uso y DTO de respuesta.
- No expongas entidades JPA ni modelos internos en API.
- Flyway es la única autoridad del esquema. No edites migraciones aplicadas.
- Las auditorías de datos y recuperaciones siguen
  `../tracon-agent-rules/references/production-data-safety.md`: PostgreSQL se
  compara en una base temporal aislada, no se restaura sobre producción y una
  reparación solo puede ser aditiva, idempotente, transaccional y autorizada.
- Producción usa `ddl-auto=validate` y `open-in-view=false`.
- Usa JPA para CRUD/transacciones, proyecciones para lecturas y SQL/JDBC para consultas críticas cuando sea más claro o eficiente.
- Relaciones `LAZY` por defecto; evita `EAGER`, cascadas indiscriminadas, N+1 y `findAll()` sobre tablas crecientes.
- Cada endpoint de colección impone paginación, orden estable, límite por
  defecto, máximo server-side y payload acotado. Para lecturas hot declara
  projection/fetch plan, round trips HTTP/DB/downstream, query budget, timeout,
  retry owner, idempotencia y evidencia de N+1.
- SQL nativo/JDBC está permitido cuando aporta una ventaja demostrable; exige
  parámetros, allowlist de identificadores dinámicos, plan/índices, razón frente
  a ORM/JPQL y prueba. No concatena input ni expone `SELECT *` en hot reads.
- Todo endpoint/resolver/RPC aplica autenticación, propiedad, visibilidad,
  bloqueos, moderación, rol, estado de cuenta, límites y BOLA. Los request DTO
  usan allowlist de campos; no se bindean entidades JPA.
- Mantén transacciones cortas y fuera de controladores. No llames correo, R2 o FFmpeg dentro de una transacción de BD.
- PostgreSQL conserva restricciones reales, idempotencia y verdad durable. Redis no sustituye persistencia.
- Comentarios usan `UNIQUE(author_user_id, idempotency_key)` como identidad de
  operación y devuelven `clientCommentId` junto al UUID del comentario. No se
  bloquean dos comentarios por el mismo body; una misma clave solo reproduce
  la fila canónica y valida que post, padre y cuerpo coincidan.
- Las mutaciones sociales deben emitir un snapshot absoluto por publicación en
  la misma transacción que incrementa `content.posts.version` y escribe el
  outbox. El hub filtra `viewer` por actor; nunca se publica el guardado de un
  usuario como dato global.
- Los errores de conversión de path UUID y excepciones internas se traducen a
  códigos/copy seguros; nunca se entrega el mensaje técnico crudo a Flutter.
- Para mensajes directos, `conversationId` es la entidad durable y `messageId`
  la entidad secundaria; el hilo de notificación agrega por conversación y usa
  un índice parcial específico. No uses el usuario remitente como destino.
- Cada envío directo exige `clientMessageId`, se deduplica por conversación y
  remitente dentro de una transacción, y recibe `serverSequence` monotónico por
  conversación. Los reintentos devuelven la fila canónica y no repiten la
  notificación; la lectura usa un cursor monotónico independiente. Consulta
  `docs/architecture/chat-messaging.md`.
- La supresión de push de un chat activo usa solo presencia efímera por hash de
  instalación en Redis, con TTL y fail-open; nunca conviertas Redis en la verdad
  de mensajes, unread o read receipts.
- Toda consulta aplica propiedad, visibilidad, bloqueos, moderación, rol y estado de cuenta.
- Search usa PostgreSQL como fuente de verdad con `unaccent`, `pg_trgm` y FTS
  cuando corresponda; filtra visibilidad, moderación, cuenta y bloqueos antes
  de rankear, liga el cursor a consulta/pestaña y mantiene el historial privado
  con lifecycle de cuenta. Ver `docs/architecture/search.md`.
- Audio Source es la referencia canónica reutilizable: el backend revalida estado, visibilidad, permiso de reutilización, licencia vigente, territorio y alcance; reconocimiento, derechos y acción de plataforma son conceptos separados.
- Firebase verifica identidad; PostgreSQL resuelve usuario interno y permisos.
- Usa UTC y `timestamptz`.
- No registres tokens, códigos, contraseñas, cookies, URLs firmadas completas ni datos personales innecesarios.
- Los builds productivos de `core-api` pasan por el storage preflight/postflight de
  `tracon-infrastructure`; no conservan `target` en el runtime release ni limpian
  volúmenes, PostgreSQL, Redis, secretos o backups.
- Cada proveedor o integración externa nueva —incluidos SDKs de anuncios,
  reconocimiento, correo, almacenamiento y autenticación— debe actualizar la
  matriz de privacidad/Data Safety y declarar sus límites de retención. Los
  canales de reclamación UGC/IP deben ser autenticados o rate-limited,
  idempotentes, auditables y separados de decisiones automáticas de derechos.
- Cuotas de producto y rate limiting de seguridad son capacidades distintas: nuevas operaciones deben declarar cuál aplica, usar `QuotaService`/`RateLimitPolicyCatalog` centralizados y conservar PostgreSQL como verdad durable; las exenciones solo pueden omitir cuotas de producto. Consulta `docs/architecture/quota-and-rate-limiting.md`.
- Los eventos `audio.scan.completed` se consumen desde el outbox durable y
  reutilizan `NotificationOrchestrator`: la notificación in-app y su evento de
  entrega deben quedar en la misma transacción. FCM, realtime y offline son
  canales derivados; `MATCHED` no equivale a infracción y `rights_status` no se
  modifica por el reconocimiento.

Las rutas API siguen siendo backend-owned y no deben caer en el fallback HTML
de la web ni entrar al sitemap. robots.txt no reemplaza la protección de
Spring Security; cualquier host público debe coincidir con la configuración
canónica documentada en docs/operations/search-indexing.md.

## Cierre

- Ejecuta pruebas Maven focalizadas o suite necesaria.
- Valida migraciones cuando aplique.
- Revisa entidad/esquema, SQL, índices, paginación, N+1, concurrencia y autorización.
- Verifica consumidores cuando cambie un contrato.

## Eliminación y ledgers

Toda purga debe usar transacción PostgreSQL más job/outbox durable y ser
idempotente. Los objetos R2 salen únicamente de media.object_manifests; los
ledgers de reconocimiento, licencias, compras, reportes y holds no se
eliminan por cascada sin una política explícita. Las FKs de evidencia deben
usar SET NULL cuando el dato operativo deba sobrevivir a la eliminación.

Las APIs del portal deben resolver permisos desde PostgreSQL, extraer el actor
de Authentication, paginar consultas y auditar mutaciones; consultar
docs/architecture/rbac.md para la matriz canónica.

En el onboarding de perfil, el servidor exige `displayName` y `username`;
Firebase/Google aporta identidad verificada y solo prellena la primera alta.
`google_profile_seed_pending` es un marcador one-shot: un login posterior no
sincroniza nombre ni foto. Las fotos externas se aceptan únicamente desde el
proveedor allowlisted, se importan al flujo canónico de media/R2 y no se
persisten como URL externa. La disponibilidad de username es solo una ayuda;
la reserva condicional y la unicidad PostgreSQL deciden el resultado.
