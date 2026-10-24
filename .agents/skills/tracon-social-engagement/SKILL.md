---
name: tracon-social-engagement
description: Implementa o revisa guardados privados, followers/following, estadísticas sociales de perfil, Impulsos y su cartera diaria en Tracon, incluyendo privacidad, idempotencia y concurrencia.
---

# Tracon Social Engagement

## Alcance

Es la fuente canónica de las invariantes de guardados, relaciones de seguimiento,
estadísticas sociales e Impulsos. Trabaja con `tracon-product` y carga únicamente
la capa técnica afectada: `tracon-backend`, `tracon-mobile` o ambas.

## Inicio

1. Inspecciona tablas, endpoints y componentes existentes antes de crear otros.
2. Confirma actor, visibilidad, bloqueo, estado del contenido y operación idempotente.
3. Lee `references/domain-rules.md`.
4. Para feed, listas sociales, fanout o realtime, lee
   `../tracon-agent-rules/references/backend-data-api-scalability-safety.md`.

## Reglas esenciales

- Un Trak es un post; no mantiene subsistemas sociales paralelos.
- Los guardados son privados y solo se consultan desde la identidad autenticada.
- PostgreSQL conserva relaciones, restricciones, cartera y contadores durables.
- Follow, guardado e Impulso protegen idempotencia y concurrencia con constraints y transacciones.
- Impulso separa consumo durable (`impulse_usages`) de efecto (`impulse_effects`): aplicar descuenta una vez, y un Deshacer válido revierte el efecto y reembolsa exactamente ese consumo diario dentro de la misma transacción.
- El saldo diario nunca es el total de Impulsos recibidos.
- Bloqueos, moderación, eliminación y visibilidad se aplican antes de exponer o mutar contenido.
- Flutter puede anticipar la interacción, pero siempre reconcilia con el backend.
- Las lecturas de feed, seguidores, guardados y estadísticas declaran DTO/
  projection, cursor/keyset, límite máximo y coste acotado; las relaciones de
  una colección se resuelven por batch/set-based, no con un repository call por
  elemento. La entrega realtime es delta deduplicable por evento/versión y no
  reemplaza el snapshot HTTP durable.
- Fanout y contadores deben considerar hot keys/viralidad, backpressure y
  coalescing. No se añade un cache, rate limiter o coordinador social paralelo
  sin una razón arquitectónica explícita.

## Cierre

Valida privacidad, cursor estable, deduplicación, concurrencia, saldo, contadores,
rollback optimista y todos los consumidores del contrato modificado.
