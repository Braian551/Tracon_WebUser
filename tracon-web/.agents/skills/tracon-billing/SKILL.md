---
name: tracon-billing
description: Diseña, implementa o revisa la monetización de Tracon: Google Play Billing, catálogo de productos, membresías, entitlements, verificación server-side, suscripciones, RTDN, restore, seguridad y activación por feature flags.
---

# Tracon Billing

## Alcance y activación

Actívala para cambios en `billing`, `membership`, `premium`, `founder`, `subscription`, `purchase`, `Google Play purchase`, `paid impulses` o `entitlements`, incluyendo backend, Flutter, Play Console y release.

La autoridad de acceso es el backend y PostgreSQL. Flutter solo inicia compras, recupera compras y presenta capabilities; nunca concede Premium por un callback local, almacenamiento o claim del cliente.

## Skills compañeras

- `tracon-architecture`: puertos/adaptadores, límites, idempotencia, estados o eventos.
- `tracon-product`: planes, beneficios, impulsos, privacidad, fraude y decisiones comerciales.
- `tracon-backend`: módulo Spring, Flyway, API, seguridad y persistencia.
- `tracon-mobile` + `tracon-design`: BillingStore, restore y UI de membresías.
- `tracon-notifications`: cambios de entitlement que creen notificaciones u outbox.
- `tracon-release` + `tracon-infrastructure`: build, migración y despliegue autorizado.
- `tracon-quality`: auditoría transversal o validación amplia.

## Flujo obligatorio

1. Audita repositorio, release activo, PostgreSQL, Flyway, Redis, flags y dependencias antes de editar.
2. Lee las referencias necesarias: `architecture.md`, `google-play.md`, `entitlements.md`, `subscription-lifecycle.md`, `testing.md` y `operations.md`.
3. Confirma la última migración real en código, artefacto y base productiva; usa el siguiente número disponible y no edites migraciones aplicadas.
4. Mantén el monolito modular: dominio/aplicación/puertos/adaptadores/API dentro de `core-api`; Google Play queda detrás de un puerto.
5. Verifica compras server-side. `PENDING` no concede beneficios; solo una compra válida y persistida puede crear grants. Acknowledge y RTDN son idempotentes.
6. Conserva `FREE` como fallback y no inventes precios, SKUs ni beneficios aprobados. Los precios localizados vienen de Play ProductDetails.
7. Mantén `BILLING_INFRASTRUCTURE_ENABLED=true` y `BILLING_PURCHASES_ENABLED=false` cuando Play/IAM/RTDN no estén configurados. La ausencia de credenciales no debe impedir arrancar el core.
8. Ejecuta validaciones focalizadas, `git diff --check`, auditoría de secretos y el flujo de release canónico si el despliegue fue solicitado.

## Reglas de seguridad y producto

- No uses Order ID como clave primaria; trata el purchase token como credencial y persiste solo hash/referencia protegida.
- Vincula compras a la cuenta autenticada de Tracon, no al correo de Google ni a un `userId` enviado por el cliente. Rechaza token ya ligado a otra cuenta.
- Separa `FOUNDER` del rol administrativo; soporta `FREE`, `FOUNDER`, `PREMIUM` y consumibles sin activar beneficios no definidos.
- Los impulsos diarios gratuitos existentes no se convierten en pago. Un futuro consumible debe usar ledger/idempotencia y no eliminar rate limits, moderación o anti-spam.
- RTDN es una señal, no autoridad: después de recibirla consulta la Developer API y acepta reintentos/duplicados sin doble grant.
- Para despliegue usa `tracon-release` + `tracon-infrastructure`; no dupliques sus procedimientos aquí.
