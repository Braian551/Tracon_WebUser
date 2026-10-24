---
name: tracon-release
description: Retired legacy release-coordinator name retained as a compatibility redirect to AGENTS.md deployment routing.
---

# Retired release lane

The request ledger, ownership overlays, batch coordinator, recovery states and release coverage flow described in the old revision are retired. Do not invoke ops/release/tracon-release-coordinator.ps1, ops/release/tracon-release.ps1, AutoRelease, or historical requests.

Follow AGENTS.md deployment routing: Core API uses backend/deploy/README.md, Web uses web/deploy/README.md, and workers use tracon-deployment-specialist with ops/deploy/README.md. New development contracts remain governed separately by tracon-change-contract; a contract does not initiate production deployment.

For production-data boundaries, follow `../tracon-agent-rules/references/production-data-safety.md`. This compatibility redirect does not start a release.

For Backend, database or worker changes, follow `../tracon-agent-rules/references/backend-data-api-scalability-safety.md`.

Legacy source and evidence remain available in the cutover archive outside the repository. Existing local changes to application and tests remain intact.
