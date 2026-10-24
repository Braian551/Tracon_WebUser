# Simple Deploy version retention

The deployment flow keeps the active app images, the immediately preceding app
images, the active source release, the preceding rollback source and the last
active Web directory. Candidate archives and protected production backups remain
in separate paths.

Never automatically remove release directories, images, archives, Docker
containers, caches or volumes. Retire an item only after an operator identifies
the exact Tracon-owned target and verifies that active and rollback references
do not use it. PostgreSQL, Redis, media temporary storage, unknown volumes,
secrets and backups are never cleanup targets.

Preflight requires at least 15 GB free and less than 85% disk use. A failed
preflight stops before artifact extraction or activation. Do not use global
Docker cleanup or edit Docker's internal storage.

The deploy lock is a Linux kernel flock held by the current command. Status
never guesses that an old lock or PID is stale; it inspects the active process
and deployed services.