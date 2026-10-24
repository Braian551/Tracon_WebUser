---
name: tracon-server-release
description: Retired legacy release-skill name retained as a compatibility redirect to AGENTS.md deployment routing.
---

# Retired release lane

This skill's old request, handoff, coordinator, lease and AutoRelease workflow is retired. Do not invoke ops/release/ deployment commands. Follow AGENTS.md routing: Core API uses backend/deploy/README.md, Web uses web/deploy/README.md, and workers use tracon-deployment-specialist with ops/deploy/README.md.

Backend, configuration and worker changes still require focused tests and database compatibility review. This redirect creates no Deployment Request or handoff. Mobile remains outside server deployments.

The pre-cutover instructions and code snapshot are archived at %LOCALAPPDATA%\Tracon\SimpleDeploy\legacy-archive\20261010\release-system-before-cutover.tar.gz.