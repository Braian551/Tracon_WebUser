# Escalabilidad y seguridad de datos, APIs y protocolos

Referencia transversal obligatoria para cualquier cambio en backend, acceso a
datos, contratos API, realtime, webhooks, GraphQL, gRPC, Redis/caché o workers
asíncronos. Las reglas de dominio siguen siendo propiedad de cada skill; este
documento fija el método de decisión y los límites técnicos compartidos.

## Principio rector

`SCALE IS MEASURED, NOT CLAIMED.` Ningún test unitario ni una arquitectura
teórica permite certificar “millones de usuarios”. Toda afirmación de capacidad
requiere evidencia aislada de carga, estrés, picos o soak y percentiles de cola.
Lo que sí debe garantizarse desde el diseño es `BOUNDED COST PER REQUEST`:
trabajo, consultas, memoria, payload, concurrencia, reintentos y llamadas a
proveedores tienen límites identificables.

Estas reglas no imponen ORM, REST, GraphQL, gRPC, WebSocket, Redis ni
microservicios por moda. La elección depende del patrón de acceso, semántica,
consistencia, seguridad, latencia, throughput, compatibilidad, mantenimiento y
medición disponible.

## Gate de decisión tecnológica

Antes de introducir o extender GraphQL, gRPC, WebSocket, webhook, una
abstracción de persistencia, un broker o una caché, documenta brevemente:

- `CURRENT`: flujo y stack actual.
- `PROBLEM`: problema observable y evidencia.
- `OPTIONS`: solución directa y alternativas.
- `WHY SELECTED`: por qué la opción elegida encaja.
- `WHY REJECTED`: por qué se descartan las alternativas.
- `OPERATIONAL COST`: conexiones, despliegue, memoria, soporte y observabilidad.
- `FAILURE MODE`: timeouts, duplicados, pérdida, recuperación y degradación.
- `SECURITY`: autenticación, autorización, secretos y límites.
- `PERFORMANCE`: presupuesto de round trips, filas, bytes y latencia.
- `ROLLBACK/COMPATIBILITY`: coexistencia, migración y retirada.
- `LOAD EVIDENCE`: cómo se medirá en un entorno aislado.

Es un registro ligero: un endpoint pequeño no necesita un ADR extenso. Una
decisión transversal o difícil de revertir sí debe quedar en `docs/decisions/`.
La tecnología de protocolo y persistencia se selecciona por patrón de acceso y
requisitos medibles, nunca por tendencia.

## Matriz de protocolos

| Opción | Encaja mejor | Condiciones obligatorias | Evitar cuando |
|---|---|---|---|
| REST | APIs mobile/públicas, CRUD, recursos acotados, mutaciones simples, snapshots y respuestas compatibles con CDN/proxy | DTO/projection, paginación, límites, orden estable, auth por objeto y payload acotado | una pantalla genera cientos de requests pequeños o un endpoint devuelve un agregado sin límite |
| GraphQL | UI con forma de grafo, campos variables, varios clientes/data shapes y over-fetch/under-fetch REST demostrado | DataLoader/batching, límites de profundidad/coste/operaciones, paginación, timeouts, rate limit y auth de nodo/arista/campo | CRUD simple sin problema demostrado o transporte de bytes multimedia |
| gRPC | RPC interno tipado entre servicios y streaming interno de alto throughput | canales reutilizados, deadline, cancelación, flow control, tamaño máximo y retry idempotente acotado | migrar Flutter/core-api solo por “hacer REST más rápido” sin benchmark |
| WebSocket | deltas realtime en foreground, chat, presencia, typing y estados bidireccionales | auth server-side, canales autorizados, `eventId`, secuencia/versión, colas acotadas y reconexión con jitter | historial, snapshots, feed bulk o API primaria de persistencia |
| Webhook | notificación asíncrona server-to-server | HTTPS/TLS, firma sobre raw body, comparación segura, replay protection, dedupe, límites y ACK rápido | realtime de UI, request-response síncrono o cola interna durable |
| Async/outbox | fanout, notificaciones, analytics, transcodificación, indexación y trabajo no crítico para la latencia | evento/job durable, consumidor idempotente, lease, retry finito, DLQ, backpressure y métricas de lag | ocultar un resultado que el request necesita para responder con veracidad |

Una request HTTP o RPC no equivale a una consulta de base de datos: una sola
request GraphQL todavía puede generar 500 SQL queries. Reducir round trips de
red no autoriza una amplificación interna.

### REST: contratos de pantalla y colecciones

REST es una opción normal y preferida cuando describe bien el recurso. Antes de
añadir GraphQL evalúa, en este orden, DTO específico, projection, endpoint
composite o endpoint batch.

Si una pantalla siempre necesita perfil, relación, contadores y un resumen de
posts, evita el waterfall de endpoints obligatorios que solo puede componerse
de forma ineficiente. Eso es `HTTP UNDERFETCH`. El extremo opuesto es un
`OVERFETCH`/god endpoint que devuelve posts completos, comentarios, mensajes,
flags internos y moderación aunque la vista no los use.

Toda colección pública o privada debe declarar `default limit`, `server max
limit`, paginación, orden estable y payload acotado. El cliente nunca fija el
límite real. Para feed, Traks, notificaciones, mensajes, comentarios y listas
sociales grandes se debe evaluar cursor/keyset con un desempate estable; un
`OFFSET` profundo requiere justificación y evidencia.

### GraphQL

GraphQL solo entra cuando el problema de composición y variabilidad está
demostrado. No es válido elegirlo porque “Facebook lo usa”, “es una request”,
“REST es viejo” o “escala mejor”. Si existe, toda colección crítica evita un
resolver que hace `repository.findById(parent)` por elemento. Usa
`DataLoader`, `BatchLoaderRegistry`, `@BatchMapping` u operaciones `IN (:ids)`
set-based. El batching debe preservar autorización por objeto y no mezclar
datos viewer-specific.

En producción se debe definir según aplique: profundidad máxima, coste o
complejidad, número de operaciones por request, tamaño máximo de página,
timeouts, paginación, rate limit, límite de batch e introspection/GraphiQL
explícito. No se deja introspección abierta por accidente. Se autorizan nodo,
arista, campo y mutación; se validan inputs y se prueban BOLA y mass assignment.
Los errores no exponen stack traces, SQL, paths, clases ni secretos.

Para mobile/web first-party, evaluar trusted/persisted operations si GraphQL se
adopta; no es requisito antes de tener GraphQL.

### gRPC

Un canal y sus stubs se reutilizan; crear un canal por request produce conexiones
y handshakes innecesarios. Cada RPC importante tiene deadline deliberado y
propaga cancelación al trabajo downstream cuando sea posible. Retries solo se
aplican a fallos transitorios y operaciones idempotent-safe, con backoff
exponencial, jitter, límite de intentos y throttling cuando exista.

El streaming se reserva para flujos realmente largos. El consumidor debe usar
flow control y límites de mensajes; no se permite que el productor llene memoria
sin límite. Documenta el impacto de streams long-lived en balanceo, despliegue y
redistribución.

## Acceso a datos y ORM

| Estrategia | Uso preferente |
|---|---|
| Entidad JPA/Hibernate | CRUD ordinario, agregado transaccional y relaciones simples |
| Projection/DTO JPA | read model que necesita pocos campos: perfil, actor, feed o notificación |
| `JOIN FETCH`/`@EntityGraph` | asociaciones conocidas requeridas en una unidad de trabajo |
| Batch/`IN (:ids)` | colecciones donde un join de múltiples listas produciría explosión cartesiana |
| JPQL | query relacional custom que sigue encajando naturalmente en entidades |
| Native SQL | CTE, window/ranking, agregación avanzada, bulk o capacidad PostgreSQL probada |
| `JdbcTemplate` | query/batch especializado donde el control de bajo nivel sea más claro |

Ninguna opción es universalmente mejor. JPA puede ser el default para CRUD,
pero ORM no implica rendimiento automático.

- No cargues una entidad completa si una projection/DTO devuelve los campos que
  la lectura necesita. Una entidad no es contrato de API.
- Los controllers devuelven response DTO y reciben request DTO explícitos; evita
  `@RequestBody UserEntity`/`PostEntity` para prevenir over-fetch, mass
  assignment, lazy serialization y acoplamiento.
- `LAZY` no elimina N+1; `EAGER` puede crear graphs enormes. El fetch plan se
  elige por use case y se mide.
- `@OneToMany(fetch = EAGER)` y `@ManyToMany(fetch = EAGER)` en dominios hot
  requieren revisión arquitectónica.
- No conviertas todo a `JOIN FETCH`: varias colecciones pueden multiplicar filas.
  Mide result rows y considera queries batch separadas.
- Una llamada a repository dentro de `for`, `map` o `stream.map` es un smell
  P1 de N+1 que exige revisión; no es bug automático: demuestra la semántica y
  el conteo.
- Para endpoints paginados hot, el número de queries debe permanecer
  aproximadamente acotado al variar de 20 a 50 elementos para la misma shape.
  Añade query-count regression test cuando la infraestructura lo permita.
- Evita `findAll()` sobre tablas crecientes, guardar miles de entidades una por
  una y el patrón `exists()` seguido de `find()` cuando una operación segura
  puede resolverlo. Excepciones por locking/semántica deben quedar explicadas.

### SQL, JPQL y JDBC

SQL nativo no está prohibido. Para una query nativa relevante registra por qué
ORM/JPQL es inadecuado, plan de consulta seguro, soporte de índices,
parametrización y cobertura. Ejecuta `EXPLAIN`/`EXPLAIN ANALYZE` solo en un
entorno seguro con dataset representativo; nunca sobre la base productiva.

Todo valor de usuario usa parámetros preparados, named parameters, binding de
repository o el mecanismo equivalente. Nunca concatena input en `WHERE`, `IN`
u ordenamiento. Identificadores dinámicos como columna/dirección se resuelven
con allowlist, no con value parameter. Evita `SELECT *` en projections/hot
reads. Operaciones masivas evalúan `saveAll`, JDBC batching, bulk update,
procesamiento por páginas o worker.

## WebSocket y realtime

WebSocket entrega deltas, no reemplaza el snapshot durable. El patrón normal es:

`REST/local snapshot + WebSocket delta + reconciliation`.

Al desconectar, el cliente reconecta con backoff exponencial y jitter y recupera
estado perdido mediante cursor, versión o high-watermark. Cada evento usa
`eventId` y, cuando corresponda, `entityId` más `version/sequence`; el cliente
deduplica y descarta eventos atrasados. No se asume exactly-once.

Cada socket/session tiene cola bounded. Presence y typing son droppable o
coalescibles; mensaje, borrado y moderación son recoverable/durables. Un
consumidor lento se coalescea o desconecta según el tipo de evento y nunca
bloquea a otros clientes. Auth, expiración, límite de conexiones y autorización
de cada subscription/canal son server-side; no se confía en `userId` o canal
enviado por el cliente.

## Webhooks

Verifica la firma criptográfica antes de interpretar el payload y, si la firma
depende del cuerpo, usa el raw body sin transformarlo. La comparación debe ser
constant-time cuando aplique. Valida timestamp/ventana, nonce o delivery ID y
dedupe durable para replay. Un webhook firmado también requiere rate limit,
body size, timeout y rechazo barato de firmas inválidas.

El flujo recomendado es `verify -> validate -> dedupe/durable enqueue -> 2xx
rápido -> async`. La entrega puede repetirse: la operación y el consumidor son
idempotentes. El secreto solo vive en el servidor/secret manager: jamás en repo,
Flutter o logs. Un webhook no sustituye el WebSocket de UI ni una cola interna.

## Idempotencia, retries y async

Toda mutación que pueda reintentarse tras una respuesta incierta revisa
idempotencia: publicación, mensaje, confirmación de upload, billing y callback
externo. La clave representa la operación lógica; la misma clave con payload
distinto devuelve conflicto. Para operaciones críticas se prefiere resultado
durable con unique constraint o ledger, no solo dedupe en memoria.

Retry es carga adicional. Debe existir clasificación de error, presupuesto de
intentos, backoff, jitter e idempotencia. No hay retries infinitos ni reintentos
de validación, autorización, policy denial o not-found normal. Audita la
multiplicación Flutter × proxy × core-api × gRPC × worker y asigna un único
owner de retry por frontera.

El request espera solo el estado necesario para responder con verdad. Trabajo
no crítico para la latencia usa outbox/job durable, lease, consumidor
idempotente, concurrencia bounded, prioridad y DLQ. Nunca se usa un thread,
goroutine o `unawaited` sin control como cola. Mide `pending`, oldest age,
processing rate y failure rate; un poison job no puede bloquear la cola.

## Redis, caché y protección de recursos

PostgreSQL conserva la verdad durable. Redis sirve para caché, rate limit,
presencia, locks con TTL, idempotencia temporal o proyecciones reconstruibles
cuando la arquitectura lo permite. No caches todo: primero revisa query plan,
projection, batch e índices. Una caché debe responder quién invalida, cuándo,
qué pasa si falla y cómo se evita mezclar estado del viewer en una key global.

Para hot keys evalúa single-flight/request coalescing, stale-while-revalidate,
TTL jitter y negative cache con TTL corto y sin fuga de autorización. Una caída
de Redis normalmente degrada latencia/caché; no debe corromper datos ni relajar
una protección de seguridad.

Busca primero los primitives canónicos. Hay un owner por rate limiter, caché,
retry coordinator, outbox y WebSocket coordinator; un segundo componente exige
razón arquitectónica explícita, contrato de migración y observabilidad propia.

Toda operación externa considera rate, concurrencia, tiempo, memoria, response
size, upload/array/page size y coste del proveedor. El límite es server-side,
por coste de negocio y con identidad adecuada: principal/usuario autenticado,
IP/device/context para anónimos, evitando castigar carrier-NAT. En varias
réplicas, un límite global no puede vivir solo en memoria de proceso. Responde
429 y `Retry-After` cuando sea útil.

Admission control rechaza o degrada deliberadamente cuando el sistema está
saturado; no deja crecer conexiones, pools o colas sin límite. Protege primero
auth, lecturas críticas, chat y acciones principales frente a analytics, warmers
y agregaciones secundarias. Cuotas de producto y rate limit de seguridad siguen
siendo capacidades distintas y reutilizan los dueños canónicos existentes.

## Seguridad de API y datos

- **BOLA/IDOR:** cada endpoint, resolver o RPC que recibe un object ID verifica
  autorización del principal para ese objeto, no solo autenticación. Si el actor
  sale del token, no se acepta `userId` del cliente como autoridad.
- **Property authorization:** revisa cada campo expuesto. No devuelvas roles,
  flags de moderación, Firebase UID, internals de storage o permisos si el
  contrato no los necesita.
- **Mass assignment:** request DTO explícito y allowlist de campos mutables.
  Nunca bindees una entidad de persistencia completa desde el cliente.
- **SSRF:** cualquier fetch de URL proporcionada por usuario es revisión P0:
  allowlist de protocolo/host, bloqueo de rangos internos, límites de redirects,
  timeout, tamaño, MIME y revalidación de destino.
- **Proveedor externo:** respuesta no confiable; valida esquema/rangos y usa
  timeout. Aplica least privilege a DB, Redis, R2 y proveedores.
- **Errores/logs:** no exponer stack trace, SQL, paths, clases, secretos,
  cookies, tokens, URLs firmadas completas ni PII innecesaria.

## Payload y cliente

En hot endpoints mide bytes sin comprimir y comprimidos, campos utilizados y
latencia. Metadata y bytes son problemas distintos: imágenes, audio y video
grandes se sirven por CDN/R2/direct media delivery, no se tunelizan por GraphQL,
JSON REST, WebSocket o gRPC salvo evidencia excepcional. No comprimas a ciegas
bytes multimedia ya comprimidos.

Flutter debe coalescer requests repetidos mediante repositorio/estado canónico,
ejecutar en paralelo fetches independientes, cancelar o aplicar latest-wins a
requests irrelevantes, paginar y respetar payload mínimo. La restauración de red
no dispara todos los repositorios simultáneamente: prioriza la superficie
visible y aplica jitter a refreshes. El offline-first sigue la reconciliación
canónica existente y no crea loops de requests.

## Observabilidad y capacidad

Cada hot endpoint debe poder medir, cuando la infraestructura lo soporte: RPS,
p50, p95, p99, estado, query count, DB time y response size. Observa Hikari
active/idle/pending/timeouts, locks/deadlocks/slow queries de PostgreSQL,
latencia/hit/miss/memoria/evictions/conexiones de Redis y pending/oldest age/rate
de workers. Los labels son de baja cardinalidad: nunca userId, postId,
messageId, UUID, query raw, signed URL o key Redis raw.

Una decisión de escala identifica primero el cuello de botella: API CPU, DB,
Redis, red, worker o proveedor externo. Antes de añadir réplicas revisa N+1,
índices, projection, payload, caché y async. Scale-out es posterior a la
medición; sharding es último recurso. Los modos load, stress, spike y soak se
ejecutan en entorno aislado para cambios críticos. Nunca se afirma capacidad por
promedios: reporta cola p50/p95/p99.

## Revisión de datos por endpoint

Para cada feature sustancial responde, en el PR/ADR o revisión técnica:

```text
PROTOCOL:
WHY:
DATA STORE:
ORM/SQL STRATEGY:
EXPECTED ROUND TRIPS: HTTP=... DB=... DOWNSTREAM=...
N+1: NO / evidence
PAGE LIMIT: default=... max=...
PAYLOAD:
CACHE: owner / key scope / invalidation / failure
RATE LIMIT:
CONCURRENCY LIMIT:
TIMEOUT:
RETRY OWNER: ... MAX RETRIES: ...
IDEMPOTENCY:
AUTHENTICATION:
OBJECT AUTHORIZATION:
PROPERTY AUTHORIZATION:
BOLA TEST:
RESOURCE CONSUMPTION:
OBSERVABILITY:
CAPACITY IMPACT:
LOAD EVIDENCE:
```

Si query count, downstream calls, memoria o payload crecen con N, no es un bug
automático, pero sí exige revisión explícita. La complejidad O(N) puede ser
correcta; la amplificación multiplicativa de I/O requiere una explicación.
Los presupuestos parten de baseline/medición, no de números mágicos.

## Testing y severidad

Usa la infraestructura existente (PowerShell, tests de arquitectura,
Testcontainers, ArchUnit si ya está disponible) y evita introducir un framework
grande para una heurística. Las pruebas de seguridad cubren según aplique:

- no autenticado, usuario equivocado, owner, roles administrativos, ID inválido,
  object ID ajeno, límite sobredimensionado, sort inválido y rate limit;
- dos usuarios para demostrar BOLA, privacidad de campos y mass assignment;
- GraphQL: depth, complexity, batch size, BOLA, field auth e introspection;
- webhook: firma válida/inválida, body alterado, replay y evento duplicado;
- gRPC: deadline, auth, autorización, mensaje sobredimensionado, retry y cancelación;
- WebSocket: subscription no autorizada, reconnect, evento duplicado, slow
  consumer y cola bounded;
- query budget, paginación, idempotencia, límites de recursos y fallos de Redis.

Los patrones ambiguos (`native SQL`, un repository call, dependencia GraphQL)
son advertencia y revisión, no fallo automático por regex. P0: seguridad,
pérdida de datos o recurso sin límite. P1: N+1, paginación ilimitada, retry
storm o amplificación hot-path. P2: over-fetch/projection/índice subóptimo. P3:
optimización menor sin impacto medido. Prioriza P0/P1.

## Anti-patrones de referencia

```java
// BAD: N+1
for (Post post : posts) {
    mediaRepository.findByPostId(post.getId());
}

// GOOD: una operación set-based y autorización preservada
Map<UUID, Media> media = mediaRepository.findAllForPostIds(postIds);
```

```java
// BAD: entidad como contrato y mass assignment
@RequestBody UserEntity user

// GOOD: contrato explícito
UserProfileResponse response;
UpdateProfileRequest request;
```

```text
BAD: SELECT * para una tarjeta de resumen.
GOOD: projection con los campos de la tarjeta.

BAD: resolver author(post) -> repository.findById() por cada post.
GOOD: DataLoader/@BatchMapping con batch y auth por objeto.

BAD: nuevo channel gRPC por request.
GOOD: channel/stub reutilizado con deadline.

BAD: reconnect inmediato e infinito.
GOOD: backoff exponencial bounded + jitter.

BAD: webhook -> lógica pesada -> 20s -> 200.
GOOD: verify -> dedupe/enqueue durable -> 2xx -> async.

BAD: limit tomado directamente del cliente.
GOOD: default y max limit impuestos por servidor.

BAD: retry en todas las capas.
GOOD: un owner y un presupuesto de retry.
```

## Fuentes técnicas primarias revisadas

Se extrajeron principios, no arquitecturas copiadas:

- [GraphQL en Meta](https://engineering.fb.com/2015/09/14/core-infra/graphql-a-data-query-language/), [Facebook.com/Relay y entrega de datos](https://engineering.fb.com/2020/05/08/web/facebook-redesign/) y [Relay Modern](https://engineering.fb.com/2017/04/18/web/relay-modern-simpler-faster-more-extensible/).
- [Memcache en Meta](https://engineering.fb.com/2013/04/15/core-infra/scaling-memcache-at-facebook/), [computación asíncrona](https://engineering.fb.com/2023/01/31/production-engineering/meta-asynchronous-computing/) y [Async en Facebook](https://engineering.fb.com/2020/08/17/production-engineering/async/), además de [TAO](https://engineering.fb.com/2013/06/25/core-infra/tao-the-power-of-the-graph/).
- [Spring Data JPA projections](https://docs.spring.io/spring-data/jpa/reference/repositories/projections.html), [query methods](https://docs.spring.io/spring-data/jpa/reference/jpa/query-methods.html), [Spring GraphQL execution](https://docs.spring.io/spring-graphql/reference/request-execution.html) y [controllers/batching](https://docs.spring.io/spring-graphql/reference/controllers.html).
- [Hibernate ORM](https://docs.hibernate.org/stable/orm/introduction/html_single/), [gRPC performance](https://grpc.io/docs/guides/performance/), [retries](https://grpc.io/docs/guides/retry/), [flow control](https://grpc.io/docs/guides/flow-control/), [cancellation](https://grpc.io/docs/guides/cancellation/) y [benchmarking](https://grpc.io/docs/guides/benchmarking/).
- [OWASP API Security Top 10](https://owasp.org/API-Security/editions/2023/en/0x11-t10/), [BOLA](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/), [unrestricted resource consumption](https://owasp.org/API-Security/editions/2023/en/0xa4-unrestricted-resource-consumption/) y [GraphQL Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/GraphQL_Cheat_Sheet.html).
- [GitHub: validar deliveries](https://docs.github.com/en/webhooks/using-webhooks/validating-webhook-deliveries), [buenas prácticas de webhooks](https://docs.github.com/en/webhooks/using-webhooks/best-practices-for-using-webhooks), [Stripe webhooks](https://docs.stripe.com/webhooks) y [Stripe idempotency](https://docs.stripe.com/api/idempotent_requests).
