# Google Play Billing oficial

La autoridad para esta integración es Android Developers, Google Play Console Help, Google Play Developer API y el paquete oficial Flutter `in_app_purchase`. No usar blogs para decidir políticas o estados.

## Contratos vigentes consultados el 2026-08-08

- Google Play Billing es obligatorio para bienes digitales consumidos dentro de una app distribuida por Play, salvo programas alternativos explícitamente adoptados.
- La compra se envía al backend para verificación antes de conceder el entitlement.
- `PENDING` no concede beneficios.
- `purchases.subscriptionsv2.get` es la lectura vigente para suscripciones; `purchases.subscriptions.acknowledge` sigue siendo el endpoint de acknowledgement.
- Para productos one-time existe `purchases.productsv2.getproductpurchasev2`; el catálogo interno no trata Order ID como identidad universal.
- RTDN llega por Pub/Sub con datos base64 y solo indica que el estado cambió. Siempre se debe consultar la Developer API después de recibirla.
- Durante grace period se conserva el acceso; durante account hold se suspende. Una cancelación conserva acceso hasta el `expiryTime` confirmado.
- `ProductDetails`/precio localizado proviene de la tienda. No hardcodear precios.

## Credenciales

Usar una service account separada y de mínimo privilegio, fuera de Git, releases, imágenes y logs. Si no existe todavía, el adaptador permanece desactivado y el core arranca.

## Enlaces primarios

- Android Developers: integración de Play Billing.
- Google Play Developer API: REST reference.
- RTDN reference guide.
- Flutter `in_app_purchase` en pub.dev.
