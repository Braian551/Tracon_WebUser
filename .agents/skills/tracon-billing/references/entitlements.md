# Catálogo y entitlements

## Planes

`FREE` es el estado base y no necesita una compra. `FOUNDER` y `PREMIUM` se modelan como planes separados, pero permanecen planificados hasta que producto defina mecanismo y beneficios.

## Modelo

- `billing.plans`: planes internos y su estado.
- `billing.products`: catálogo desacoplado de Play con tipo `SUBSCRIPTION`, `NON_CONSUMABLE` o `CONSUMABLE`.
- `billing.plan_entitlements`: asociación configurable plan/entitlement.
- `billing.entitlement_grants`: concesiones efectivas con fuente, referencia, inicio, fin y estado.
- `billing.purchase_transactions`: auditoría e idempotencia por hash de token.

La ausencia de una fila de grant de entitlement pagado implica `FREE`. Los roles de seguridad no crean grants. Las definiciones iniciales son un vocabulario preparado, no beneficios activos.

## Fuentes de grant

`PLAY_PURCHASE`, `PROMOTION`, `ADMIN`, `FOUNDER` y `MIGRATION`. Las concesiones administrativas requieren autenticación administrativa y `platform.audit_events`.

## Impulsos

El wallet gratuito existente permanece intacto. Un futuro `EXTRA_IMPULSE_PACK` será un consumible separado y deberá acreditar un ledger idempotente; no se implementa saldo directo sin trazabilidad.
