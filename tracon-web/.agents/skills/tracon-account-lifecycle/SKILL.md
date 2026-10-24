---
name: tracon-account-lifecycle
description: Implementa y revisa el ciclo de vida de cuentas de Tracon: desactivación, reactivación, eliminación pendiente, recuperación, purga, Firebase, visibilidad y cumplimiento de eliminación externa.
---

# Tracon Account Lifecycle

## Autoridad

Esta skill conserva los invariantes del ciclo de vida de cuentas. Las decisiones de API, persistencia, Flutter, producto y release siguen siendo propiedad de sus skills técnicas compañeras.

Registra cualquier cambio de lifecycle con `../tracon-change-contract/SKILL.md`
y la política canónica `../tracon-agent-rules/references/change-contract-policy.md`.

## Skills compañeras

- `tracon-product`: estados, privacidad, retención y derechos del titular.
- `tracon-backend`: API, PostgreSQL, Firebase, Redis, workers y purga.
- `tracon-mobile`: bootstrap, recuperación y acciones de Cuenta.
- `tracon-design`: cuando cambie la experiencia visual.
- `tracon-infrastructure`: configuración, observabilidad y despliegue.
- `tracon-release`: cuando el cambio deba llegar a producción.
- `tracon-quality`: auditoría transversal o validación de datos sensibles.

## Invariantes

- Desactivar no equivale a eliminar: conserva datos y permite reactivar.
- Una solicitud de eliminación oculta inmediatamente la cuenta y no se cancela por un login accidental.
- La fecha legal aplicable prevalece sobre la ventana máxima de recuperación del producto.
- `DELETION_PROCESSING` no puede resucitarse ni restaurarse desde backups.
- Firebase conserva el UID durante recuperación, revoca sesiones al ocultar y se elimina después de la purga durable.
- El `userId` siempre proviene de la identidad autenticada o de un flujo web de verificación; nunca del cliente como autoridad.
- La purga es idempotente, por etapas, reintentable y conserva solo el tombstone mínimo justificado.
- La ruta web externa de Google Play y la ruta interna de la app deben iniciar el mismo caso de uso.

## Cierre

Verifica estados, visibilidad pública, carrera cancelación/worker, PostgreSQL, Redis, R2, Firebase, retención, pruebas y documentación. No declares el ciclo completado si una etapa externa quedó simulada.

La purga usa un manifiesto exacto y conserva assets/media/audio compartidos,
holds y evidencia; nunca borra post_media de contenido de terceros. El
runbook operativo completo está en docs/operations/account-purge-runbook.md.
