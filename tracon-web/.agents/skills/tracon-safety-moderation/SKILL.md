---
name: tracon-safety-moderation
description: Implementa o revisa bloqueos, reportes, visibilidad, moderacion UGC, seguridad infantil y acciones administrativas de Tracon.
---

# Tracon Safety Moderation

## Propósito

Mantiene la frontera de seguridad y moderación para usuarios, publicaciones, Traks, comentarios, mensajes directos y mensajes de comunidades. Carga `tracon-backend` para enforcement/API, `tracon-mobile` + `tracon-design` para UX y `tracon-product` para reglas funcionales o legales.

Los cambios de autorización, privacidad, seguridad infantil o policy se
registran con `../tracon-change-contract/SKILL.md` y la política
`../tracon-agent-rules/references/change-contract-policy.md`; requieren nivel
FULL.

Lee las referencias de esta skill según el cambio:

- `references/blocking.md` para bloqueo, visibilidad, follows y DM.
- `references/reporting.md` para catálogo, idempotencia, evidencia y cola.
- `references/play-ugc-compliance.md` para UGC y Child Safety Standards.

## Fuente canónica ejecutable

- `social.user_blocks` es la tabla existente de bloqueos; no crear otra tabla paralela.
- `moderation.reports`, `moderation.report_evidence`, `moderation.actions`, `moderation.user_suspensions` y `platform.audit_events` son el modelo de moderación existente.
- V033 solo extiende el modelo para catálogo, idempotencia, evidencia mínima, restricciones diferenciadas y lecturas de chats. Nunca editar V001–V032.
- PostgreSQL es la verdad durable. Redis puede limitar frecuencia, pero no autoriza visibilidad ni reemplaza auditoría.

## Invariantes

- Bloquear es reversible y transaccional: elimina follows mutuos, oculta la existencia para el usuario bloqueado y rechaza nuevas interacciones con `USER_INTERACTION_NOT_AVAILABLE`.
- No borrar historia compartida por bloquear; aplicar consultas viewer-aware a perfil, feed, posts, comentarios, búsqueda, sugerencias, notificaciones, DM y comunidades.
- Reportes no exponen al reportado la identidad del informante. Los detalles administrativos no salen en respuestas de usuario.
- Moderación administrativa usa `moderation.user_restrictions`/acciones; no reutiliza desactivación o eliminación de cuenta.
- Acciones de moderación deben auditar actor, objetivo, acción y momento en UTC. Los reportes críticos de seguridad infantil requieren ruta y contacto de cumplimiento definidos por el producto/legal.

## Validación

Prueba primero reglas de política y SQL con datos de bloqueo bidireccional, luego API y UI. Verifica 404 genérico sin filtración, rollback de bloqueo fallido, rate limit/idempotencia, roles moderator/admin, separación `seen` de notificaciones y `read` de chats. Antes de release revisa las referencias oficiales de Google Play y la documentación legal publicada; no afirmar cumplimiento jurídico no validado.
