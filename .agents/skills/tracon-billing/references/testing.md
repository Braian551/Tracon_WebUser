# Pruebas de billing

## Backend

Como mínimo: fallback FREE, compra válida, PENDING sin grant, producto no configurado, package incorrecto, token ligado a otra cuenta, retry idempotente, cancelación hasta expiry, expiry/revoke, grace, hold, restore idempotente, RTDN duplicada y reconciliación por Developer API, acknowledgement y grant administrativo auditado.

Usar fake del puerto para unitarias. La migración debe ejecutarse contra PostgreSQL temporal. No registrar tokens en aserciones/logs salvo hash no reversible.

## Flutter

Probar flags apagadas, Play no disponible, catálogo vacío, carga, pendiente, éxito, cancelación, error de verificación, restore, refresh de entitlements, doble tap, reinicio y usuario FREE/Premium. `BillingStore` debe tener single-flight y un único listener al `purchaseStream`; nunca consulta la tienda desde `build()`.

## Play Console

Usar Internal Testing, license testers y Play Billing Lab. Las cuentas no tester en tracks de prueba pueden generar cargos reales; no activar compras hasta terminar checklist y autorización comercial.
