# Operaciones y activación

Flags de runtime:

- `BILLING_INFRASTRUCTURE_ENABLED=true`: carga el módulo, migración y capabilities.
- `BILLING_PURCHASES_ENABLED=false`: bloquea compras reales y verificación externa hasta configurar Play/IAM/RTDN.

La falta de service account o RTDN no puede impedir health del core mientras compras estén apagadas. El secreto futuro se monta desde `/srv/tracon/secrets/`, nunca desde Compose versionado, Flutter o Dart defines públicos.

Para release: `tracon-release` + `tracon-infrastructure`, backup único solo si la migración supone riesgo real, tag inmutable, recreación exclusiva de `core-api` y health/readiness/smoke. No publicar el AAB en producción Play desde este flujo.
