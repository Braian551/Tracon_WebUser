# Ciclo de vida de suscripciones

Mapear estados de Google a estados internos:

| Google | Tracon | Entitlement |
|---|---|---|
| `SUBSCRIPTION_STATE_PENDING` | `PENDING` | no |
| `SUBSCRIPTION_STATE_ACTIVE` | `ACTIVE` | sí |
| `SUBSCRIPTION_STATE_IN_GRACE_PERIOD` | `GRACE_PERIOD` | sí |
| `SUBSCRIPTION_STATE_ON_HOLD` | `ON_HOLD` | no |
| `SUBSCRIPTION_STATE_PAUSED` | `PAUSED` | no |
| `SUBSCRIPTION_STATE_CANCELED` | `CANCELED` | sí hasta expiry confirmado |
| `SUBSCRIPTION_STATE_EXPIRED` | `EXPIRED` | no |
| revocada | `REVOKED` | no |

La concesión se calcula con estado y fechas confirmadas por Developer API. RTDN repetida no altera el resultado. Restore vuelve a verificar compras del usuario y nunca crea una segunda concesión.
