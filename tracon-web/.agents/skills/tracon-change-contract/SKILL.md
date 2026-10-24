---
name: tracon-change-contract
description: Define and validate lightweight contracts for new Tracon changes.
---

# Tracon Change Contract

Use for new Tracon work. For frozen legacy records or policy and queue changes,
read `../tracon-agent-rules/references/change-contract-policy.md` first.

## DISCOVER

1. Check Graphify freshness; run one bounded query, explain, or path. Verify
   relevant source, callers, tests, and ownership. Read only affected skills.

## CONTRACT

2. FAST: bounded bugs, UI, local refactors, small features. FULL: architecture,
   permissions, API contracts, migrations, workers, moderation, sensitive paths;
   FULL requires `risks[]`.
3. Create one external JSON contract with `schemaVersion=1`,
   `policyVersion=tcc-v1`, `id`, `level`, `type`, `summary`, `acceptance[]`, and
   `validation[]`. Add `scope.paths[]` only when it narrows scope and list exact
   paths. TCC specifies the code change; production deployment is a separate
   user authorization and does not require a Deployment Request.

## IMPLEMENT → TEST → RELEASE

4. Preserve pre-existing staged, tracked, untracked and concurrent work. Store
   the contract and evidence outside the source tree unless the user requests a
   checked-in specification.
5. Implement acceptance criteria, run the declared checks and focused tests,
   and record their actual results.
6. Validate with `ops/change-contract/validate.ps1`; include evidence JSON when
   checking completed validation IDs. A failed check remains failed evidence.
7. For an explicitly authorized production release, follow AGENTS.md routing:
   Core API uses `backend/deploy/README.md` and Web uses `web/deploy/README.md`.
   Workers use `tracon-deployment-specialist` and the entry point
   `ops/deploy/tracon-delivery.ps1`. Run `PLAN`, then `VALIDATE` and `PREPARE`;
   PREPARE performs fresh read-only provenance checks without manual signatures.
   DEPLOY_IF_AUTHORIZED requires the responsible user's explicit instruction in
   the agent session and uses the same prepared artifact through restricted SSH.
   Follow `ops/deploy/README.md` for authorization and recovery; do not infer
   production approval from a TCC, repository file or diagnostic request. Mobile/store release stays separate.

TCC `type` describes the specification kind (for example, `feature` or
`migration`); it does not imply that every platform must be built. Deployment
gates are selected by the separate Simple Deploy `changeType` contract. A
server-only contract does not acquire Flutter or APK/AAB gates from TCC. A
mobile-only contract runs Flutter tests and analysis, reports
`SERVER_DEPLOYED=NOT_APPLICABLE`, and remains `MOBILE_RELEASE_PENDING` until a
separately authorized distribution flow exists. Keep TCC validation IDs tied
to checks required by the paths and change type, and record actual results.

New changes use TCC v1. Frozen OpenSpec requests remain in their original
versioned lane and are never rewritten. Validation prints PASS or its first
cause.
