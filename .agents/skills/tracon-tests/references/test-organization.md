# Tracon test organization guide

## Canonical layout

Flutter mirrors `mobile/lib`:

- `test/modules/<module>/application|data|domain|presentation/...`
- `test/core/<cross-cutting-area>/...`
- `test/app/...` for app composition and smoke coverage.
- `test/architecture/...` for architectural guardrails.
- `test/integration/...` only for cross-boundary flows.

Spring mirrors the package under `backend/core-api/src/main/java`:

- module tests keep `modules/<module>/<layer>`;
- migration safety lives in `db/migration`;
- cross-module infrastructure tests live in `integration`;
- architecture and security guardrails live in `architecture` and `security`.

The package declaration must match the Java path. A move must not be used to
avoid package-private access; keep the package equivalent or change the design
explicitly.

## Before a move

1. Capture paths, file counts, discovered test counts/classes and the runner
   patterns from `mobile/pubspec.yaml` and `backend/core-api/pom.xml`.
2. Group candidates by basename and inspect every pair. Normalize only line
   endings when comparing; additions, imports, package declarations and test
   cases are substantive differences.
3. Select the organized destination as canonical. Merge unique cases there
   before removing a flat duplicate. Preserve any existing user or agent
   changes in the destination.
4. Search for relative imports, resource paths, reflection, package-private
   access and scripts that name the old path.

## After a move

Run the read-only auditor and verify:

- no `*_test.dart` is directly under `mobile/test/`;
- no Java test is directly under `.../tracon/`;
- Java package declarations match their paths;
- no duplicate basename remains unless the subjects genuinely differ and the
  name makes that distinction explicit;
- the Flutter and Maven runners discover at least the baseline cases/classes.

Never solve discovery by changing runner patterns, adding `skip`, `@Disabled`
or deleting a unique test. Do not create a giant shared helper merely to make
the tree appear smaller.
