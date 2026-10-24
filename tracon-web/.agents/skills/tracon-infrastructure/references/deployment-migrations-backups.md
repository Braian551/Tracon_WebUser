# Simple Deploy, migrations and backups

## App deployment

Core API delivery, migration verification and application recovery follow
`backend/deploy/README.md` through independent GitHub Actions. The worker flow
in ops/deploy/ validates a captured source candidate, builds worker artifacts,
updates selected workers with Compose --no-deps, checks health and smoke routes,
and retains the preceding worker version for rollback. PostgreSQL and Redis are excluded from app updates.

A deployment never restores, recreates or rewinds a database. Application
rollback restores Backend/worker image tags only. Independent Web delivery is
documented in `web/deploy/README.md`. Flyway stays
forward-only.

## Migration gate

Before a new schema migration, validate it against an isolated PostgreSQL
instance and the exact production Flyway history. Applied migration files and
checksums are immutable. New DDL must be backward-compatible with the rollback
application. A migration gap, reused version or unknown applied script stops
Backend activation.

Create a consistent PostgreSQL backup before any migration that can change
production data. Verify its SHA-256 and pg_restore catalog, then restore it to
an isolated, non-networked PostgreSQL instance and check essential tables and
counts. Never restore over production. Keep the verified backup and report its
path.

## Storage and secrets

Keep Tracon releases, backups, Compose state and secrets under /srv/tracon and
outside Viax. Store no credentials in source archives, image layers, build
logs, manifests or public docs. Retain the current and prior application
versions; cleanup is explicit and never targets volumes or unknown resources.