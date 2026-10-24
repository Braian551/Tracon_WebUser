# Release coverage and Flyway reconciliation

This is the canonical policy for detecting deployable source changes in the
shared worktree. The request inbox is an immutable transport layer; it is not
the source of truth for whether a change exists.

## Ownership contract

Every source-modifying run starts an external manifest at
`%TEMP%/tracon-agent/<run-id>/run-manifest.json` with `runId`, `startedAt`,
`branch`, `HEAD`, `baselineAtStart`, `policyVersion`, `changeContract`,
`changeContractSha256`, `openspecChange` (legacy only), `componentsTouched`,
`filesObservedAtStart`, `filesModifiedByRun`,
`deployableFilesModifiedByRun`, `migrationFilesModifiedByRun`,
`requestsCreated` and `validationState`. Finalization accepts an explicit list
of files. It never guesses ownership from a dirty shared worktree.

New runs use `tcc-v1`: start with `-ChangeContractPath`, then finalize with
`-ValidationEvidencePath`. The coordinator validates the embedded contract,
hash, exact owned paths and declared PASS evidence before freezing a request.
The immutable request repeats the contract, hash and evidence. Existing records
stay on their recorded `openspec-v1` or implicit legacy lane; strict OpenSpec
validation is retained only for those records until they are reconciled.

The coordinator compares the current source tree to the trusted baseline
manifest, not to HEAD or a Git diff. It classifies changes as server, web,
mobile, generated, release tooling or unowned. Server and web changed-file
coverage must be 100% before a release can be assembled or deployed. A file
with exactly one matching, completed and validated run manifest may be
recovered into a new immutable READY request. Zero owners or multiple owners
produce `UNATTRIBUTED_DEPLOYABLE_CHANGE` and block that component. Mobile is
reported as `READY_FOR_MOBILE_RELEASE`/`NONE` and never creates a Deployment
Request.

## Authorized release scope

`WORKTREE_DIFF` and `RELEASE_SCOPE` are separate concepts. `ReleaseScope` is
metadata containing `runIds`, `openspecChanges`, `requestIds`, `components`,
`explicitPaths` and `dependencyClosure`. The coordinator resolves it from the
requested selectors and related immutable request/run evidence. When no
selector is supplied, `DeployPending` uses the ready deployable requests for
the selected server components; `-DeployAll` includes all completed,
validated, deployable runs and their ready requests, while excluding active,
abandoned, mobile, generated and tooling-only work.

Reports expose both `globalWorktreeCoverage` (diagnostic) and
`authorizedReleaseScopeCoverage` (the deployment gate). Unrelated dirty files,
active runs and unowned changes outside the selected scope are listed as
`globalInformationalCodes`/`excludedActiveRuns`; they do not block an
independent scoped release. An active run inside the scope still blocks it.

Every changed path is recorded in the coordinator-owned
`state/diagnostics/release-ownership-map.json` with run, policy generation,
contract identity or legacy OpenSpec, request, component, lifecycle category
and receipt evidence. Categories include
`ALREADY_DEPLOYED`, `STALE_WORKTREE_COPY`, `PENDING_ATTRIBUTED`,
`PENDING_UNATTRIBUTED`, `ACTIVE_OTHER_RUN`, `ABANDONED_OR_INCOMPLETE`,
`REQUEST_OVERLAP`, `REQUEST_STALE`, `TOOLING_ONLY`, `GENERATED` and
`MOBILE_ONLY`. This map is diagnostic metadata; it never mutates source or
Git state.

## Reconciliation gates

`Coverage` and `ReleaseReconcile` are dry-run by default. `-ApplyRecovery` may
only create local request, ledger and reservation state; it never deploys.
Before every server or web deployment the coordinator re-runs reconciliation,
even when a request id was supplied. It checks READY/BATCHED/APPLIED state,
baseline and candidate hashes, duplicates, overlaps, explicit supersession,
dependencies, unowned files and Flyway collisions. A final report includes
server/web changed and covered files, percentages, mobile exclusion,
unattributed files, recovered request ids, codes and Flyway evidence.

```powershell
pwsh -NoProfile -File .\ops\release\tracon-release-coordinator.ps1 `
  -Mode RunManifestStart -RunId agent-run-001 `
  -ChangeContractPath $contractPath

pwsh -NoProfile -File .\ops\release\tracon-release-coordinator.ps1 `
  -Mode RunManifestFinalize -RunId agent-run-001 `
  -FilesModifiedByRun backend/core-api/src/main/java/example/Changed.java `
  -ValidationEvidencePath $evidencePath

pwsh -NoProfile -File .\ops\release\tracon-release-coordinator.ps1 `
  -Mode ReleaseReconcile -DryRun
```

Scoped examples:

```powershell
pwsh -NoProfile -File .\ops\release\tracon-release-coordinator.ps1 `
  -Mode Coverage -ScopeRunId agent-run-001 -ScopeComponent core-api -DryRun

pwsh -NoProfile -File .\ops\release\tracon-release-coordinator.ps1 `
  -Mode DeployPending -RequestId req-20260913-example -AssembleOnly

pwsh -NoProfile -File .\ops\release\tracon-release-coordinator.ps1 `
  -Mode Coverage -DeployAll -DryRun
```

`-ApplyRecovery` is appropriate only after the run manifest and focused
validation identify the exact files. `DeployPending` refuses to proceed if the
final report is not PASS; no flag bypasses this gate.

## Flyway policy

The guard combines the read-only production safety snapshot with the trusted
baseline migration tree. A version at or below the effective applied version
is allowed only when path, migration identity and content are the exact
trusted historical migration. A different name/content is
`FLYWAY_VERSION_COLLISION` or `FLYWAY_CHECKSUM_CONFLICT`; local duplicate
versions and removal of an applied migration also block. The report always
returns `productionFlywayVersion`, `trustedBaselineFlywayVersion`, effective
version and a derived `nextFreeMigrationVersion`.

```powershell
pwsh -NoProfile -File .\ops\release\tracon-release-coordinator.ps1 `
  -Mode FlywayCollisionCheck -DryRun

pwsh -NoProfile -File .\ops\release\tracon-release-coordinator.ps1 `
  -Mode ReserveMigration -RunId agent-run-001
```

The automated owned handoff and exact context overlay contract is documented in
`docs/deployment/automated-server-release.md`; normal agents use
`tracon-server-release`. Coverage applies to the isolated owned materialization,
with pending/ambiguous ownership blocked and foreign worktree hunks excluded.

Reservations are coordinator-local JSON records under
`state/migration-reservations/` and are allocated under the coordinator lock.
They are unique across concurrent processes. An expired, never-captured
`RESERVED` record may become `STALE`; explicit owner abandonment produces
`ABANDONED`, capture produces `CAPTURED`, and successful promotion produces
`APPLIED`. Every recorded version remains consumed, including abandoned and
stale versions. A bounded repair may rename one attributable, still-pending migration
to the derived free version and update only same-run references. It refuses an
exact applied migration and never edits a production history row or performs a
Flyway repair/clean.

## Release evidence

Each new candidate and server `release-manifest.json` carries a `coverage`
object for server, web, mobile and Flyway plus a frozen `source-receipt.json`
containing the candidate file hashes. After deployment,
`PostDeployReconcile` verifies the receipt, request final states and absence of
related orphan READY requests. A failure is persisted as
`POST_DEPLOY_RECONCILIATION_FAILED` and cannot be reported as PASS.

No coverage operation mutates Git, captures unrelated dirty files, creates a
mobile request, changes an applied migration or deploys production.

## Reconciliación de deuda legacy (one-time)

La política versionada de procedencia está en
`ops/release/legacy-provenance-policy.json`. Su cutoff es el commit
`62ee913d9d77aa670548f46e2c20adec733fe36c`, `2026-09-05T22:18:04Z` UTC:
desde ese instante el run manifest moderno es obligatorio y no existe un
escape hatch legacy. La reconciliación se ejecuta con:

```powershell
pwsh -NoProfile -File .\ops\release\tracon-release-coordinator.ps1 `
  -Mode LegacyReconcile -DryRun
```

Solo con `-ApplyRecovery` se escriben metadata del ledger, registros locales
de ownership, baseline de reconciliación y requests server/web recuperadas;
esa opción nunca despliega. El recovery HIGH exige al menos dos tipos de
evidencia independiente entre ruta explícita de OpenSpec, test dedicado,
diff/hash exacto, historial de request, símbolo exclusivo, overlay inmutable
o receipt histórico. MEDIUM solo se mapea y LOW continúa como
`UNATTRIBUTED`; mtime nunca es evidencia suficiente. Un request móvil legacy
se conserva con su id, fecha y manifiesto, pero se normaliza como
`LEGACY_MOBILE`, `DEPLOYABLE=false`, `RELEASE_COVERAGE_REQUIRED=false` y no
entra en el denominador server/web.

El ledger normalizado usa `APPLIED_HISTORICAL`, `SUPERSEDED_HISTORICAL`,
`READY_ACTUAL`, `READY_STALE`, `ORPHANED`, `LEGACY_MOBILE` y
`UNKNOWN_LEGACY`. Receipts de baselines promovidos, snapshots históricos y
candidates completados prueban `ALREADY_DEPLOYED` por hash exacto; un batch
fallido no cubre cambios. Overlays se reportan como
`IDENTICAL_ALREADY_DEPLOYED`, `IDENTICAL_PENDING`, `SUBSET`, `SUPERSEDED`,
`DEPENDENCY`, `TRUE_CONFLICT` o `LEGACY_UNKNOWN`, sin resolver conflictos por
suposición.

`globalRepositoryStatus` puede permanecer `BLOCKED` por deuda histórica,
mientras `scopedReleaseStatus` puede ser `READY` cuando el scope autorizado
alcanza 100% y no contiene conflicto. La deuda queda en
`outOfScopeLegacyDebt`; el punto de partida de esta única reconciliación se
persiste en `state/diagnostics/legacy-reconciliation-baseline.json` fuera del
repositorio.
