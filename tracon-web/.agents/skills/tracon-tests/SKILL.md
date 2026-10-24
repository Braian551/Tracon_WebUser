---
name: tracon-tests
description: Define, organiza, implementa y valida pruebas de Tracon en Flutter y Spring Boot, incluyendo lifecycle, regresiones, Testcontainers, discovery, determinismo y suites por módulo/capa.
---

# Purpose

Esta skill es la autoridad canónica de testing de Tracon. Mantiene una suite
que pueda crecer sin volver a una carpeta plana, protege la discovery real de
Flutter/Maven y convierte bugs de ciclo de vida, sincronización social,
concurrencia, persistencia y seguridad en regresiones ejecutables.

Para pruebas de backend, datos, API, Redis, realtime, webhooks o workers, usa
también la referencia transversal
`../tracon-agent-rules/references/backend-data-api-scalability-safety.md`.

# Scope

Aplica cuando se agregan, corrigen, mueven, eliminan, reorganizan o auditan
tests en `mobile/test/`, `backend/core-api/src/test/` y sus recursos. Coordina
las skills propietarias de mobile/backend/arquitectura, pero no reemplaza sus
reglas de producción.

Para any code change, consult `$tracon-tests` when tests are added, moved,
fixed or reorganized. No infieras que una suite está sana porque un comando
terminó con menos tests descubiertos.

En releases multi-agente, la validación del agente es focalizada y se registra
en la request; la validación completa pertenece al candidato inmutable y se
ejecuta una vez por batch. `ops/release/test-coordinator.ps1` cubre el contrato
operativo COORD-01..35 sin depender de producción ni de Git. El bootstrap
one-time se valida con `ops/release/test-bootstrap.ps1` y BOOT-01..11,
incluyendo preview/aprobación, cutoff, carreras de captura, exclusiones,
aislamiento, promoción y retención del snapshot futuro.
La regresión del incidente de hash se valida con
`ops/release/test-bootstrap-hash.ps1` y HASH-01..10: algoritmo único,
ordenamiento estable, detección de modified/missing/extra y working copy
aislado del snapshot. La recuperación de batches bootstrap incompletos o
incompatibles se valida con `ops/release/test-bootstrap-batch-recovery.ps1` y
BATCH-01..06: diagnóstico campo por campo, supersede del state, preservación
del manifest histórico, nuevo batch desde el mismo snapshot e idempotencia.
El control-plane file-based y el presupuesto de argumentos se validan con
`ops/release/test-process-control-plane.ps1` y ARG-01..12; la regresión del
launcher, streams, UTF-8, exit codes y deadlock se valida con
`ops/release/test-process-launcher.ps1` y PROC-01..14.

# Test directory conventions

La regla principal es: tests mirror the production module/package structure.
Primero módulo funcional y después capa/tipo; no crear una taxonomía global
que vuelva a mezclar módulos.

En Flutter:

- Los nuevos tests de un módulo van bajo `mobile/test/modules/<module>/...`,
  nunca directamente bajo `mobile/test/`.
- Espeja `mobile/lib/modules/<module>/application`, `data`, `domain` y
  `presentation` cuando sea razonable.
- Tests cross-cutting van bajo `mobile/test/core/`, `shared/`, `integration/`,
  `architecture/` o `support/`, según el dueño real.
- `support/fixtures`, `support/builders`, `support/fakes` y `support/matchers`
  solo se crean cuando existe reutilización comprobada; no se crean carpetas
  vacías.
- La raíz de `mobile/test/` contiene principalmente carpetas estructurales y
  un README breve, no decenas de `*_test.dart`.

En Java:

- Java tests mirror the production package under
  `backend/core-api/src/test/java/com/viaxtechnology/tracon/`.
- Un test de `src/main/java/com/viaxtechnology/tracon/modules/posts/...` debe
  vivir en el paquete de test equivalente cuando el subject tenga una capa
  clara (`application`, `domain`, `infrastructure`, `api`).
- `integration/` es para flujos que cruzan módulos o infraestructura; `db/`
  es para seguridad de migraciones; `architecture/` para guardrails; y
  `security/` para autenticación/autorización transversal.
- Mantén el mismo package del subject cuando el test dependa de acceso
  package-private. Mover un archivo no autoriza a hacer públicos miembros.
- `src/test/resources/` conserva los nombres y ubicaciones que Spring/Maven
  descubren; organiza fixtures, SQL y JSON sin esconder `application-test.*`.

# Flutter test conventions

Search debe cubrir normalización compartida, prefijos `@/#`, límite/minimum,
debounce/cancelación/stale-response en cliente y privacidad/ranking/cursor en
backend. La migración de índices e historial requiere un test de Flyway con
PostgreSQL cuando Testcontainers esté disponible; no se sustituye por un mock.
El contrato completo está en `docs/architecture/search.md`.

Nombra cada archivo `<subject>_test.dart`: `canonical_post_store_test.dart`,
`feed_post_card_test.dart`, `comments_controller_test.dart`. No uses
`test1.dart`, `fix_test.dart`, `regression2_test.dart` ni un nombre que no
identifique el subject.

Usa `group('<Subject>', ...)` y descripciones de comportamiento. Los tests
validan comportamiento observable, no detalles privados por reflejo. Conserva
Arrange/Act/Assert de forma legible sin comentarios ceremoniales obligatorios.
No combines varios archivos pequeños en un archivo gigante solo para reducir
el número de archivos.

Un bug fix requiere una regression test que falle antes del fix cuando sea
práctico. Para `setState() or markNeedsBuild() called during build`, la
regresión debe ser un Widget Test real con `FlutterError` capturable; un unit
test aislado del store no basta.

Regla especial de lifecycle Flutter:

> Global observable stores must not be synchronously mutated from widget
> build/didChangeDependencies/didUpdateWidget when the mutation can notify
> ancestors or InheritedNotifier dependents during the current build phase.

La hidratación de servidor debe ocurrir en controller/repository/state
ingestion boundaries rather than leaf widget mounting whenever possible.
Un leaf observa el estado canónico, no hidrata una proyección global mientras
se monta. Para una publicación usa `upsertFromServer`; para una página usa la
API batch productiva `CanonicalPostStore.applyServerSnapshot`. Ambas conservan
merge, `socialVersion`, stale-response protection y la granularidad de los
`ValueNotifier` por post. Una operación batch solo puede documentarse si
existe en producción y tiene consumidores reales; un test no puede inventar
ni exigir un método productivo ausente.

Para `CanonicalPostStore`:

- CanonicalPostStore must preserve newer `socialVersion` state when hydrating
  server snapshots.
- Cubre respuestas stale, eventos realtime, dedupe por `eventId`, estado
  optimista, rollback, ACK absoluto, generación e identidad del viewer.
- Verifica una sola proyección por `postId` entre feed, detail, comments,
  Traks, profile, saved, shared y media viewer.
- Verifica Feed ↔ Detail y Detail ↔ Feed después de like, save, impulse y
  rollback; no mantengas contadores sociales paralelos en widgets.

No uses `Future.delayed` arbitrario para sincronización. Usa `pump`,
`pumpAndSettle`, `fakeAsync` o `Completer` controlados. Un `addPostFrameCallback`
puede ser una frontera de página única cuando no exista una boundary de
ingestion mejor, pero nunca se añade indiscriminadamente a cada PostCard.

# Backend test conventions

Maven soporta por defecto `*Test`, `*Tests` y `Test*` mediante Surefire. Antes
de introducir `*IT` o `*IntegrationTest`, lee el `pom.xml` y confirma que
Failsafe o el patrón correspondiente existe y se ejecuta. No asumas que `*IT`
es discovery automática.

Distingue por infraestructura real:

- unit: sin PostgreSQL/Redis real;
- application: casos de uso con puertos fake/mock controlados;
- repository/infrastructure integration: levanta la dependencia real;
- migration safety: prueba Flyway/esquema y vive bajo `db/migration`;
- end-to-end: flujo crítico que cruza límites y debe nombrarse explícitamente.

No llames unit a una clase que levanta PostgreSQL. Los nombres recomendados
son `FooServiceTest`, `FooControllerTest`, `FooIntegrationTest` o `FooIT`
solo si la configuración real lo reconoce.

# Integration tests

Los tests automáticos no dependen de la red de producción, R2 real, Firebase
real, FCM real, credenciales reales ni servicios externos no controlados. Los
contratos de adaptadores se prueban con fake/double y la integración del
proveedor solo cuando el comportamiento externo importa y existe un entorno
aislado.

Los tests deben poder ejecutarse individualmente y en el orden que el runner
elija. No compartas estado mutable entre clases para ahorrar tiempo; comparte
solo infraestructura de forma segura y aislada.

# Testcontainers

Usa Testcontainers para infraestructura de integración cuando el proyecto ya
lo soporta. PostgreSQL/Redis y propiedades dinámicas deben ser explícitos,
repetibles y limpiables. No introduzcas un singleton global mutable que haga
tests dependientes entre sí; una estrategia estática por clase solo es válida
si el framework garantiza aislamiento y el estado se reinicia.

Si Docker no está disponible, reporta el bloqueo real con tests run, errors y
skipped. No conviertas el test en un pass falso, no agregues `@Disabled` para
ocultarlo y no sustituyas Testcontainers por una afirmación vacía. Mantén
`disabledWithoutDocker` solo cuando ya sea parte del contrato diagnóstico del
test y reporta el skip.

# Regression tests

Una regresión debe reproducir la ruta que falló: mounting, frame, API,
concurrencia, migración o evento realtime. Debe probar el contrato público y
fallar con el código anterior cuando sea viable.

Para el canonical post lifecycle, la ruta mínima es:

`Feed -> ListView/Sliver -> FeedPostCard mounting -> CanonicalPostStoreScope`.

Debe capturar cero lifecycle exceptions. Añade una variante con 10+ cards si
el coste es razonable, verifica el estado canónico y mide que el montaje de
las cards no hidrata ni notifica el store. Si la ingestión procesa una lista,
prueba el contrato real de esa boundary; no supongas una notificación de
colección si el store solo ofrece hidratación por elemento. Rebuild del padre
no debe volver a hidratar indebidamente.

# Fixtures/builders/fakes

Fixtures representan entidades de dominio válidas por defecto. Builders hacen
explícitos los estados excepcionales. Centraliza solo duplicación real:

- `support/fixtures/` para objetos válidos compartidos;
- `support/builders/` para variaciones legibles;
- `support/fakes/` para puertos/repositories controlados;
- `support/matchers/` para aserciones repetidas con semántica propia.

No crees un `test_utils.dart` gigante, no copies el mismo fake en módulos sin
necesidad y no pongas secretos raw en fixtures, snapshots o logs.

# Determinism

Controla clock, UUID, random, zona horaria, orden de iteración y finalización
async cuando influyan en el resultado. No uses `DateTime.now()`, `Random()`,
timezone local, red real, Firebase real, R2 real o FCM real sin una abstracción
inyectable y un double determinista.

# Async testing

Espera futuros y streams explícitamente. Usa `Completer`, `pump`,
`pumpAndSettle`, `fakeAsync` y clocks controlados. No duermas segundos para
esperar una carrera. Prueba retries, cancelación, idempotencia, doble tap y
dispose cuando el contrato lo requiera.

Los widgets con animaciones permanentes, shimmer, reproducción o tareas
progresivas no deben validarse con `pumpAndSettle` como condición de entrada:
un ticker legítimamente activo puede hacer que la prueba agote el timeout.
Controla la async con `Completer`, `pump` de duración acotada, clocks/fakes y
señales observables del contrato; usa `pumpAndSettle` solo cuando el árbol
pueda alcanzar un estado estable verificable. No desactives la animación en
producción ni aumentes arbitrariamente el timeout para ocultar una espera
infinita.

# Database testing

Separa service unit, repository integration y migration safety. Prueba
transacciones, concurrencia, constraints, índices, paginación y rollback en
la capa que los posee. No uses una base productiva ni operaciones destructivas
fuera del container/fixture aislado.

# Migration testing

Los tests Flyway/Postgres son safety gates visibles bajo
`src/test/java/.../db/migration/`. Ejecutan sobre una base aislada, verifican
versiones, esquema, datos de referencia y upgrades relevantes. No los ocultes
dentro de un service test ni muevas `application-test.*` fuera del discovery
de Spring.

El guard de migraciones también tiene la suite focalizada
`.agents/skills/tracon-infrastructure/scripts/test-flyway-safety.ps1` (FLYSAFE-01
a FLYSAFE-10): usa snapshots firmados y fixtures locales para validar historial
aplicado, checksum, migraciones nuevas destructivas, filas fallidas, integridad
del snapshot, ausencia de secretos y ausencia de escrituras productivas.

# Realtime/WebSocket testing

Cuando el protocolo lo permita, prueba duplicados, eventos fuera de orden,
reconexión, replay, dedupe por `eventId`, versión monotónica y ACK/eco en
cualquier orden. No supongas exactly-once si producción entrega al menos una
vez. Verifica que el estado converge sin doble incremento.

# Firebase/FCM testing

Usa puertos y fakes para Firebase identity, auth, token verification y FCM.
No uses sesiones de usuario Firebase reales ni envíes pushes FCM reales en la
suite. Prueba token inválido, actor ausente, permisos y mapping de errores sin
imprimir tokens, cookies, URLs firmadas o credenciales.

# Security testing

Cada test de API/security comprueba actor, propiedad, visibilidad, bloqueos,
moderación, rol, estado de cuenta, límites y respuesta segura. Los tests no
confían en roles enviados por el cliente. Separa cuota de producto de rate
limit de seguridad y prueba que un fallo de Redis no relaje una protección.

En hot paths añade query-budget/payload/pagination regression tests cuando la
infraestructura lo permita. Prueba BOLA con dos usuarios, límites de recursos,
idempotencia y rate limit; si existe el protocolo, añade las matrices
condicionales de GraphQL (depth/cost/batch/field auth), gRPC
(deadline/cancel/retry), webhook (firma/replay/duplicado) y WebSocket
(auth/reconnect/slow consumer/cola bounded). La capacidad se valida en entorno
aislado con load/stress/spike/soak según el riesgo; no se exige load test para
cualquier cambio pequeño ni se confunde un unit test con evidencia de escala.

# Test naming

El nombre del archivo describe el subject y conserva el sufijo que el runner
reconoce. El nombre del caso describe comportamiento y contexto, por ejemplo
`does not notify the canonical store during post card build`; no hace falta
crear un archivo `bug_YYYYMMDD_test.dart` si pertenece claramente al subject.

# Test discovery

Antes de una reorganización guarda el listado completo de `*_test.dart`, las
clases Java y los conteos de casos/clases. Después compara paths, archivos,
clases y tests ejecutados. Un move debe conservar el 100% salvo una deducción
justificada por duplicación real y documentada.

Para Flutter valida que `flutter test` descubre todos los paths bajo `test/`.
Para Maven valida Surefire/Failsafe real y compara `Tests run`, failures,
errors y skipped. Nunca escondas fallos con `skip`, `@Disabled`, `-DskipTests`
ni cambios de patrón; solo se permite una exclusión temporal con autorización
explícita de diagnóstico.

La guía de inventario, reconciliación y movimiento físico está en
`references/test-organization.md`. El auditor read-only
`scripts/audit-test-layout.ps1` comprueba raíces planas, paquetes Java y
duplicados de basename; ejecútalo antes y después de una reorganización.

# Stale test API triage

Cuando un test invoca una API que no compila:

1. Busca la definición productiva, sus consumidores y el contrato documentado.
2. Clasifica el caso como API obsoleta del test, regresión productiva o setup
   inválido; no añadas capacidad a producción solo para satisfacer el test.
3. Si el test es obsoleto, migra su intención a la API pública actual y
   conserva la regresión observable. Si la capacidad falta realmente,
   implementa primero el contrato productivo y luego su test.
4. Repite la búsqueda global y deja cero referencias al nombre obsoleto.

Las copias planas y organizadas no se consideran dos suites: antes de borrar
una copia se comparan contenido, imports, package declarations y casos
añadidos. El destino organizado es canónico; cualquier caso único se fusiona
allí antes de retirar la ruta plana.

# Coverage expectations

La cobertura se interpreta por riesgo y comportamiento, no por un porcentaje
ceremonial: cada bug corregido tiene regresión, cada transición crítica tiene
tests, cada adaptador importante tiene contrato/integración y cada migración
relevante tiene safety gate. La reorganización nunca puede reducir cobertura
por pérdida accidental de discovery.

# Quality gates

Flutter tocado: `dart format`, `flutter analyze` sobre archivos/consumidores y
tests focales; en cambios transversales, `flutter analyze` y `flutter test` de
la suite completa. Backend tocado: `mvn compile` y `mvn test` según la
configuración real. Revisa imports, package declarations, recursos, dispose,
secretos, diff y archivos accidentales.

No declares pass si el runner falló, fue bloqueado o descubrió menos tests.
Reporta bloqueos de Docker/Testcontainers y validaciones pendientes con
precisión.

# Anti-patterns

- Mutar un store observable global desde `build`, `didChangeDependencies`,
  `didUpdateWidget` o layout cuando puede notificar un ancestor.
- Esconder `FlutterError`, ignorar asserts o deshabilitar `notifyListeners`.
- `Future.delayed` arbitrario, sleeps largos o retries infinitos.
- Red/Firebase/FCM/R2/DB productivos en tests.
- Singleton global de Testcontainers con estado mutable compartido.
- Tests de implementación privada sin contrato observable.
- Duplicar fixtures, crear utilidades gigantes o mover a la raíz por comodidad.
- Cambiar producción solo para hacer pasar un test incorrecto.
- `skip`, `@Disabled`, `-DskipTests` o patrones Maven que reduzcan discovery.
- Borrar migraciones, datos o volúmenes para “limpiar” una suite.

# Agent completion checklist

- [ ] Identifiqué subject, consumidores, runner y baseline antes de editar.
- [ ] El test nuevo está en el módulo/capa/package correcto.
- [ ] El bug tiene regresión que cubre la ruta real y falla antes cuando es viable.
- [ ] No hay mutación global durante lifecycle Flutter prohibido.
- [ ] Fixtures, builders y fakes no duplican ni contienen secretos.
- [ ] Async, clock, UUID, random y recursos externos son deterministas.
- [ ] Testcontainers, migraciones, realtime, Firebase y seguridad tienen el
      tipo de prueba correcto y no ocultan bloqueos.
- [ ] Comparé paths y conteos before/after; no perdí discovery.
- [ ] Ejecuté formato/analyze/tests o documenté el bloqueo real.
- [ ] Revisé `git diff --check`, package declarations, imports, temporales y
      archivos accidentales.
- [ ] No generé AAB/APK, no ejecuté ADB, no hice commit/push ni deployment no
      solicitado.

Para onboarding agrega regresiones observables para nombre visible obligatorio,
prefill vacío cuando Google no aporta nombre, primera sugerencia de nombre/foto,
ausencia de sincronización en login posterior, username ocupado, respuestas
obsoletas, doble envío e importación de avatar fallida sin bloquear el alta.
