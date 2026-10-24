---
name: tracon-infrastructure
description: Configure or review Tracon Compose, Nginx, VPS paths, certificates, volumes, backups, Flyway compatibility, health, deployment and rollback.
---

# Tracon Infrastructure

## Scope

Applies to Tracon VPS infrastructure, Docker Compose, Nginx, storage, secrets, PostgreSQL, Redis, backup, app releases and operational recovery. It does not authorize production deployment, migration, DNS, TLS or data changes by itself.

For an explicitly authorized Core API deployment, follow `backend/deploy/README.md` (independent GitHub Actions). Workers use ops/deploy/ and tracon-deployment-specialist. Independent Web installation and delivery follow `web/deploy/README.md`. The legacy ops/release/ workflow is retired: do not invoke or re-enable it. Its Task Scheduler runner was removed after a verified Simple Deploy and bidirectional rollback; historical evidence remains archived.

## Read first

- references/docker-server-and-nginx.md
- references/deployment-migrations-backups.md
- references/operations-secrets-observability.md
- references/infrastructure-validation.md
- references/version-retention.md
- ../tracon-agent-rules/references/production-data-safety.md
- ../tracon-agent-rules/references/backend-data-api-scalability-safety.md when Backend, API, queue, worker or database configuration changes

Also read the [verified cutover report](../../../docs/deployment/tracon-simple-deploy-cutover-20261010.md) for production identity and migration evidence.

## Invariants

- Keep Tracon under /srv/tracon/, isolated from Viax container, network, volume, configuration, database, Nginx and secret resources.
- PostgreSQL and Redis are private services. Deploy app services with the Compose project tracon, explicit image tags, and --no-deps. Do not bring PostgreSQL or Redis into an application update.
- Unknown volumes, bind mounts, credentials, certificates, buckets, sessions, queued work and backups remain protected.
- Never run destructive data or Docker volume operations. Never run Git on the VPS. A database rollback never means a Flyway rollback or backup restore over production.
- A new schema migration needs compatibility evidence and a verified PostgreSQL backup restored in an isolated environment. Existing applied migrations and Flyway history remain immutable.
- Use a source snapshot ID separately from the active production baseline. Promote the candidate only after tests, health checks, HTTP smokes, PostgreSQL identity/Flyway checks and read-only R2 access succeed.
- The current production layout and recoverable versions are captured in the dated cutover report and in root-only backups outside the replaced release paths. Do not infer the running version from the current link alone.
- Use the approved service concurrency gate and VPS flock: Core uses Actions concurrency, workers use the deployment helper's Windows mutex. Do not add another scheduler, coordinator or queue.
- Storage preflight fails closed at 85% used or below 15 GB free. Build outputs and temporary work live outside the repository. Retain active and prior application images and the preceding Web version for rollback.
- Do not run global Docker prune, remove data volumes, recreate anonymous volumes, or clean caches to recover space. Do not compile Flutter on the VPS.
- Keep credentials out of package images, output, logs, source archives and public documentation.

## Validation

Run the focused checks from ops/deploy/README.md; validate Compose config and the deployment helper syntax. After a release, check the selected containers, API readiness, public routes, Nginx config, PostgreSQL identity/Flyway, Redis persistence metadata, R2 read access and unchanged persistent volume names. Report rollback as verified only after it has actually been exercised.
