# Pipeline de release reanudable

## Estado de la infraestructura auditada

Tracon corre en un VPS con Docker Compose y Nginx. El release activo se marca
con `/srv/tracon/current` y los releases inmutables viven bajo
`/srv/tracon/releases/`; los bundles se guardan en `/srv/tracon/artifacts/`.
El flujo legacy (`ops/release/remote-release.sh`) recibe source empaquetado,
compila en el VPS, ejecuta tests/build y depende de una sesión SSH larga. Se
conserva como fallback, pero no es la autoridad del flujo nuevo.

No se encontró un registry canónico ni variables de registry configuradas en el
VPS. Por eso la migración usa una fase intermedia segura: el build host produce
un bundle con checksum y `docker save` de las imágenes modificadas. El diseño
de `release-manifest.json` deja el campo `image` listo para sustituir el
transporte por GHCR/digest cuando se configuren owner, permisos y secrets.

## Contrato del manifest

El manifest es JSON, persistente dentro del bundle y del release candidato. Sus
campos principales son:

- `manifestVersion`, `releaseId`, `sourceRevision`, `sourceHash`, `createdAt`;
- `components.<name>.changed`, `image`, `imageId`, `artifact` y
  `artifactSha256`;
- `activation.services`;
- `migrations.required`, `expectedVersion` y `files`;
- `smoke.selected`;
- `validation.status/durationMs` y `build.status/durationMs`;
- `artifacts.bundle` e imágenes.

El VPS verifica el checksum SHA-256 del bundle, evita traversal de paths,
valida el releaseId/sourceHash y rechaza reutilizar un directorio con contenido
distinto. Cada resultado remoto se escribe atómicamente como
`/srv/tracon/deployment-history/<releaseId>.deployment-result.json`; el resumen
humano queda en `<releaseId>.release-summary.txt`.

## Etapas y reanudación

| Etapa | Trabajo | Retry seguro |
| --- | --- | --- |
| `CREATED` | Se registra deployment ID y log | Continúa con el bundle existente |
| `BUILT` | Evidencia del build local | No recompila |
| `VALIDATED` | Suite del release candidate | No repite full suite |
| `PUBLISHED` | Bundle registrado/verificado | No vuelve a subir si el hash coincide |
| `UPLOADED` | Imágenes cargadas y verificadas por image ID | No vuelve a cargar sin necesidad |
| `MIGRATED` | Backup condicional y Flyway comprobado | Reutiliza backup del mismo release |
| `ACTIVATED` | Symlink current/source y Compose `--no-build` | Salta activation si ya está activa |
| `HEALTHY` | Container health + readiness/liveness | Empieza en health |
| `SMOKED` | Smoke autenticado seleccionado | Reintenta smoke sin build |
| `COMPLETED` | Resultado final PASS | Es idempotente |

El proceso remoto se arranca con `nohup setsid` y conserva stdout/stderr en
`/srv/tracon/logs/deployment-<release>-<deployment>.log`. `Start` devuelve un
deployment ID y `Status` lee el JSON; una pérdida de SSH solo requiere volver a
consultar ese JSON. Un lock `flock` en `/srv/tracon/locks/production.lock`
impide activaciones incompatibles. El lock de arranque por release se libera
cuando el hijo ya fue creado y un PID stale no se reutiliza como proceso vivo.

Un `PARTIAL` por configuración faltante de smoke conserva candidato, bundle e
imágenes y puede reanudarse con el mismo tag después de configurar las cuentas.
Un fallo real de health/smoke marca `FAILED`, conserva log/evidencia y ejecuta
rollback de aplicación al release anterior si este ya fue activado.

## Health y seguridad operacional

El runner no consume `docker events`. Para Compose inspecciona estado y
healthcheck de `postgres`, `redis`, `core-api` y `media-worker`; para moderation
worker inspecciona el contenedor con nombre estable. También valida los
endpoints de readiness y liveness de core-api, `systemctl is-active nginx`,
`nginx -t` y que los contenedores Viax sigan activos. El timeout configurable es
120 segundos y el polling 2 segundos; valores no positivos son rechazados.

No hay auto-prune de volúmenes. La migración solo acepta archivos Flyway nuevos
sin `DROP`, `TRUNCATE` o flush destructivo y no ofrece recuperación automática
de datos. `TRACON_DELETION_AUTHORIZATION=NO` y
`TRACON_RECOVERY_AUTHORIZATION=NO` siguen siendo invariantes.

## Smoke y límites de alcance

Baseline usa dos token files de cuentas de sistema para probar un endpoint
autenticado seguro. Social usa el smoke existente solo si está explícitamente
habilitado y existe su helper workdir; debe dejar operaciones reversibles y
controladas. La ausencia de tokens/helper se informa como configuración faltante,
no se inventan credenciales ni se usa una cuenta real.

El manifest elige smoke según el componente/cambio. Un cambio móvil no crea
APK/AAB, no usa ADB y no bloquea un PASS de servidor; `PHYSICAL_RETEST` se
reporta por separado. Una feature flag futura puede separar deploy de release a
usuarios, pero no se agrega una plataforma de flags artificial en esta fase.

## CI/CD y batching

CI valida rápido y construye el candidato; CD publica y dispara Deploy con el
mismo tag. Los workflows permanecen separados. La caché puede acelerar Maven y
BuildKit sin incluir secrets ni estado productivo. No se agrupan cambios
automáticamente con timers en esta fase: un agente puede esperar una candidate
estable y construirla una sola vez; más adelante CI puede aplicar debounce sin
cambiar el contrato del manifest.

## Validación de infraestructura

Los checks INFRA-01..15 cubren manifest, identidad/hash, no rebuild/no re-upload,
recuperación de SSH, health bounded, ausencia de listeners, lock y stale lock,
rollback inmutable, selección de componentes, fallo pre-activation, evidencia,
resultado persistido y smoke failure. El script permanente
`ops/release/test-release-flow.ps1` verifica invariantes estáticas y sintaxis;
la prueba de reanudación real requiere un release candidato controlado y no
debe simular éxito inventando un estado productivo.
