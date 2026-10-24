# Simple multi-agent deployments

Core API follows `backend/deploy/README.md` through independent GitHub Actions;
Web follows `web/deploy/README.md`. The Simple Deploy candidate/rollback process
below applies to workers. Their VPS activations share the kernel lock with Core.

Development work is not serialized. Agents keep their changes in the shared worktree, record the affected service in their handoff notes or change contract, and run focused tests. They preserve every other agent's staged, unstaged and untracked work and do not edit deployment helpers for ordinary feature work.

Candidates can be prepared and validated independently. Only one production activation can run at a time: the local activation mutex is acquired after validation/build, and the VPS uses kernel flock on /srv/tracon/simple-deploy.lock across deploy and rollback. The lock releases with the owning process; status reports the lock owner, active release/images, source commit/hash, health, Flyway, database identity and protected volume names. A PID or an old log alone never proves that a deploy is abandoned.

The production agent creates one immutable candidate from the verified active source commit plus manifest-listed overlays, dependencies, tests and authorized migrations. It validates and builds only the declared services, transfers an artifact, and revalidates the live baseline under flock immediately before activation. Compose updates only named app services with --no-deps; PostgreSQL and Redis are excluded. Workers stop gracefully before their replacement consumes the same durable jobs.

The prior app images and Web directory remain available. rollback.ps1 restores them without touching database history, volumes, Redis persistence or R2. A baseline moves forward only after container health, API readiness, HTTP smokes, Flyway, PostgreSQL identity and read-only R2 checks pass.

Flutter-only candidates run analyze/tests and finish with SERVER_DEPLOYED=NOT_APPLICABLE and MOBILE_RELEASE_PENDING. They do not enter server deployment. The workflow creates no requests, ownership map, queue, lease, handoff, coordinator, AutoRelease job, scheduler or release database.
