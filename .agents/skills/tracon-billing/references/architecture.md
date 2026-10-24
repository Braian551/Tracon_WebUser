# Arquitectura de billing

## Módulo

Billing vive dentro del monolito modular `backend/core-api` y se organiza por capacidad:

```text
modules/billing/
├── api/
├── application/
├── domain/
├── ports/
└── infrastructure/googleplay/
```

La aplicación depende de puertos internos. El adaptador de Google traduce Developer API, tokens, estados y errores; los tipos del SDK no cruzan al dominio. La persistencia durable es PostgreSQL mediante Flyway. Redis no es autoridad de entitlement.

## Flujo

```text
Flutter -> Google Play -> purchaseToken -> Core API
        -> adapter Developer API -> transacción PostgreSQL
        -> entitlement grants -> acknowledge -> capabilities
```

El endpoint de verificación obtiene la identidad del JWT/Firebase. La cuenta autenticada no puede ser sustituida por un `userId` del payload. La operación de persistencia es idempotente por proveedor y hash del token; RTDN registra su `messageId` y vuelve a consultar el estado actual.

## Decisiones de diseño

- `Adapter`: aísla Google Play y permite fake/disabled adapter para pruebas y entornos sin IAM.
- `Strategy` se reserva para proveedores futuros; la primera versión solo registra `GOOGLE_PLAY` sin fabricar una jerarquía vacía.
- `State` se representa con estados internos centralizados y transición en aplicación; no se distribuyen enums de Google por el resto del sistema.
- `Outbox` solo se usa para efectos durables que ya existan en la plataforma. No se inventa un segundo outbox.

## Validación

Probar dominio/contratos sin red, aplicación con un fake del puerto y migración contra PostgreSQL. Una compra repetida, RTDN repetida o retry HTTP debe producir una sola transacción/grant.
