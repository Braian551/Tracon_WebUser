# Seguridad de datos productivos y recuperación

Fuente canónica para auditorías de incidente, recuperación selectiva y
operaciones que puedan afectar PostgreSQL, Redis, R2, volúmenes o releases.

## Autorización independiente

- La autorización de deploy permite transportar, construir, activar y revertir
  código o configuración de Tracon dentro del flujo aprobado. No permite borrar
  datos, purgar R2, restaurar un backup sobre producción ni limpiar volúmenes.
- La autorización de borrado debe ser explícita, separada y limitada a un
  objetivo, ambiente, motivo y ventana. `TRACON_DEPLOY_AUTHORIZATION` y
  `TRACON_DELETION_AUTHORIZATION` no son intercambiables.
- La autorización de recuperación debe ser explícita y separada de ambas; una
  recuperación solo puede ser selectiva, reversible o aditiva y con alcance
  registrado.

## Fase forense obligatoria

Antes de reparar, restaurar, publicar o eliminar:

1. Registrar el estado del worktree y preservar cambios concurrentes.
2. Inspeccionar release activo, historial, Compose, redes, volúmenes, backups,
   migraciones, health y separación de Viax en modo read-only.
3. Consultar PostgreSQL sin mutar y comparar como mínimo los backups relevantes
   en una base temporal aislada, nunca sobre la base productiva.
4. Listar R2 con permisos read-only y paginación; no descargar todo, no borrar
   objetos y no imprimir credenciales, URLs firmadas ni claves completas.
5. Correlacionar manifests, assets, relaciones, estados, holds y cuentas antes
   de llamar pérdida a un objeto `R2_ONLY`. R2-only es evidencia de diferencia,
   no prueba de pérdida.

La fase forense no ejecuta `DROP`, `TRUNCATE`, `DELETE`, `pg_restore` sobre
producción, `docker compose down -v`, prune global, `FLUSHALL`/`FLUSHDB`,
eliminación de R2, eliminación de volúmenes o borrado de backups.

## Recuperación selectiva

Solo después del informe y de una autorización de recuperación válida:

- crear y verificar un backup nuevo antes de mutar;
- producir primero un dry-run con conteos, hashes, conflictos y límites;
- aceptar únicamente candidatos de alta confianza con identidad, propietario,
  relación y estado corroborados por PostgreSQL y, cuando corresponda, R2;
- usar transacción corta, lotes acotados, operación idempotente y `INSERT` o
  actualización condicionada que no sobrescriba filas actuales;
- conservar IDs y timestamps históricos solo cuando estén demostrados;
- no recalcular contadores, no reproducir outbox antiguo y no reactivar cuentas,
  contenido, moderación o media eliminados;
- ante conflicto, hold, checksum inconcluso, shared reference o estado de
  eliminación, conservar y reportar; no forzar.

Una restauración completa de backup sobre producción está prohibida. Los
backups son evidencia y fuente para una comparación aislada, no una orden de
reemplazo.

## Guard automatizado

`.agents/skills/tracon-infrastructure/scripts/audit-production-safety.ps1` es
el guard estático canónico para archivos operativos, Compose y migraciones
seleccionadas. Falla cerrado ante SQL destructivo, restore, prune de Docker,
flush de Redis, borrado de R2 o `down -v`. El teardown autenticado sintético
solo se admite con la marca `TRACON_SYNTHETIC_TEARDOWN_OK` y permanece limitado
al script de smoke existente.

El guard no inspecciona controladores, casos de uso ni workers de lifecycle del
producto; por tanto no bloquea `DELETE /account`, purgas idempotentes ni
eliminaciones de media que estén implementadas detrás de sus contratos y
autorizaciones. Esa exclusión no autoriza ejecutar esas acciones en producción
desde un release o una auditoría.

## Evidencia y cierre

Reportar por separado pérdida confirmada, diferencia explicada, candidatos
ambiguos, reparación ejecutada, objetos conservados, integridad referencial,
backup, validaciones y cualquier cambio productivo. Nunca declarar recuperación
por el mero hecho de que un objeto exista en R2.
