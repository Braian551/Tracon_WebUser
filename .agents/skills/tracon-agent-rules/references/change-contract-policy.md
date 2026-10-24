# Tracon Change Contract policy

TCC is the specification system for new work. `tracon-change-contract/SKILL.md`
owns the short execution workflow; this file owns policy and version routing.

## Decision and contract

Use one `changeContract` JSON object inside the external run manifest. FAST is
for bounded fixes, UI work, local refactors, and small features. FULL is
required for architecture, permissions, API contracts, migrations, workers,
moderation, and sensitive paths; FULL includes explicit risks. Acceptance and
validation IDs are required at both levels. Let run evidence derive files,
components, ownership, and deployment eligibility.

Graphify is the first architecture discovery tool. Read only the affected
technical skills and their references. The release coordinator runs the
deterministic validator before handoff and again against the pinned candidate.

## Version transition

`ops/change-contract/current-policy.json` defines the effective version and
cutover time. New run manifests and requests after the cutover require
`policyVersion=tcc-v1`, the embedded contract, and its SHA-256.

Records with no policy version, or `openspec-v1`, remain in the legacy lane
when their run began before the effective time. Existing requests, batches,
hashes, ownership evidence, and release manifests remain immutable. The
coordinator processes one policy generation per batch, oldest first; the other
generation stays READY. A legacy release keeps its strict OpenSpec validation
using the active tree or its verified historical archive. Do not convert a
frozen legacy run or request to TCC.

The transition notice is append-only under coordinator `notices/`. Do not use
`Publish-ReleaseNotice` for a specification event: it replaces the latest
production-release notice used by baseline recovery.

## Deployment boundary

Specification and Deployment Request eligibility are independent. Backend,
workers, infrastructure, release tooling, and web retain their required
server-side requests. Mobile has no server Deployment Request; store release
remains separate and requires explicit authorization.
