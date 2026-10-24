---
name: tracon-agent-rules
description: Crea, edita, divide, reorganiza o audita `AGENTS.md`, `.agents/skills`, `SKILL.md`, referencias y reglas de Tracon. Decide la fuente canónica, evita duplicados, mantiene carga progresiva, actualiza enrutamiento y conserva compatibilidad entre agentes como Codex y OpenCode.
---

# Tracon Agent Rules

## Autoridad

Esta skill es la única responsable de modificar la arquitectura de reglas del repositorio. No cambia reglas de producto, diseño o tecnología por sí sola: carga la skill propietaria y edita allí la fuente canónica.

## Skills compañeras

Carga la propietaria de la regla solicitada:

- Visual/UX: `tracon-design`.
- Arquitectura limpia, SOLID y patrones de software: `tracon-architecture`.
- Flutter: `tracon-mobile`.
- Spring/datos/seguridad: `tracon-backend`.
- Medios: `tracon-media`.
- Funcional/negocio: `tracon-product`.
- Privacidad, tratamiento de datos, términos, seguridad infantil y Google Play: `tracon-legal`.
- Monetización, membresías y Google Play Billing: `tracon-billing`.
- VPS/operaciones: `tracon-infrastructure`.
- Validación transversal: `tracon-quality`.

No cargues todas. Para una regla universal que no pertenece a un dominio, esta skill basta.

## Inicio obligatorio

1. Identifica la regla solicitada y su alcance real.
2. Busca conceptos equivalentes en `AGENTS.md`, `.agents/skills/` y documentación relacionada.
3. Clasifica la regla usando `references/rule-placement-map.md`.
4. Elige una sola fuente canónica.
5. Actualiza referencias/enrutamiento sin copiar el contenido completo.
6. Lee:
   - `references/rule-placement-map.md`
   - `references/anti-duplication.md`
   - `references/portable-format.md`
7. Usa `scripts/audit-agent-rules.ps1` para revisar estructura y duplicación aproximada.
8. Para incidentes o reglas que puedan afectar datos productivos, aplica la
   fuente canónica `references/production-data-safety.md` y el guard de
   `tracon-infrastructure/scripts/audit-production-safety.ps1`.
9. Si la regla toca backend, acceso a datos, contratos API, realtime, webhooks,
   GraphQL, gRPC, Redis/caché o workers, lee
   `references/backend-data-api-scalability-safety.md` antes de editar y
   conserva allí la política transversal.
10. La política de especificaciones vive en
    `references/change-contract-policy.md`; para cambios usa la skill
    `../tracon-change-contract/SKILL.md`. No copies esa política en otras skills.

Cuando la regla trate de contenido legal visible, la fuente canónica de la
separación público/interno es
`../tracon-legal/references/public-document-presentation.md`; las skills
consumidoras solo deben enlazarla.

Para descubrimiento no trivial de código, sigue el flujo canónico de
`references/graphify-workflow.md` y evita reconstruir un grafo sano por defecto.

## Reglas de edición

- `AGENTS.md` conserva solo invariantes universales, autorización, fuentes canónicas y enrutamiento.
- Un `SKILL.md` define cuándo usar la skill, alcance, compañeras, flujo y reglas esenciales.
- El detalle extenso va a `references/` de la skill propietaria.
- El estado actual del producto, arquitectura o implementación pertenece a `docs/`, no a las reglas permanentes.
- Scripts repetibles van en `scripts/`.
- No uses frontmatter o carpetas exclusivas de un proveedor en el núcleo portable.
- Mantén `name` y directorio iguales, en minúsculas y con guiones simples.
- Haz descripciones específicas para activación automática.
- No crees una nueva skill si una existente puede asumir la regla sin perder cohesión.
- No hagas una skill depender obligatoriamente de todas las demás.
- Evita ciclos de carga obligatoria.
- Cuando muevas una regla, elimina la versión anterior o sustitúyela por una referencia breve.
- Antes de editar una política existente, localiza su fuente canónica y modifica solo ese lugar; otras skills conservan como máximo una referencia breve.
- Cuando agregues una referencia, actualiza los manifiestos o índices que realmente existan, comprueba enlaces relativos y no crees copias legacy ni backups Markdown.
- La clasificación TCC y la elegibilidad de Deployment Request se mantienen separadas; usa `references/change-contract-policy.md` como fuente única.
- Elimina reglas antiguas contradictorias y mantén `AGENTS.md` pequeño; las políticas operativas detalladas pertenecen a la referencia de la skill propietaria.
- Conserva UTF-8 y corrige texto corrupto.
- La escala se mide, no se declara: las reglas de coste acotado por petición,
  selección de protocolo, N+1, límites y seguridad API tienen una única fuente
  transversal en la referencia de backend/datos; las skills consumidoras solo
  añaden matices de su dominio.

## Protección del worktree e índice — regla crítica

La política canónica está en `references/worktree-integrity.md`. Todo staged,
unstaged y untracked existente al inicio queda protegido; no se altera el
worktree, el índice ni el historial para fabricar un clean state, atribuir un
fallo o facilitar una validación. Lee esa referencia antes de editar y usa el
auditor estático antes del cierre.

## Repository Hygiene / Temporary Artifact Policy

### Regla absoluta

Los agentes no deben usar el repositorio de Tracon como carpeta temporal. Salvo
solicitud explícita de conservar un artefacto dentro del proyecto, no creen en
la raíz ni dentro de los módulos:

- .tmp-*, tmp-*, *.stdout.log, *.stderr.log ni logs de diagnóstico;
- backups improvisados, copias antes de editar, dumps u outputs de comandos;
- ZIP/TAR/TAR.GZ, source bundles, release-source-* o resultados intermedios;
- capturas temporales, qa-screenshots, release-logs o profiling outputs.

En Windows cada ejecución usa un directorio propio bajo
$env:TEMP\tracon-agent\<run-id>\; en Linux usa
/tmp/tracon-agent/<run-id>/. Nunca se comparte un tmp genérico entre agentes ni
se usa C:\Flutter\tracon\tmp como scratch workspace. Los artefactos de release
locales se crean allí, se eliminan después de verificar la operación y solo se
conservan si forman parte deliberada de la entrega. Las rutas temporales del
servidor (/srv/tracon/tmp) son distintas y siguen la política de infraestructura.

Todo agente que cree temporales es responsable de limpiarlos en un finally o
equivalente, tanto si termina correctamente como si falla un test, build,
comando, excepción o estrategia. El cleanup solo puede tocar el directorio
propio de la ejecución actual; nunca borra temporales de otros agentes ni usa
git clean.

Antes de trabajar, registra como baseline git status --short y
git ls-files --others --exclude-standard (junto con el diff protegido según
references/worktree-integrity.md). Al finalizar repite ambos comandos y compara
contra ese baseline. Todo untracked nuevo creado por el agente debe eliminarse
si era temporal o justificarse explícitamente si es implementación deliberada.
Un agente no puede terminar dejando archivos nuevos desconocidos.

Las redirecciones de stdout/stderr, logs de Flutter, Docker o FFmpeg, resultados
JSON, capturas y reportes de tests también van fuera del repositorio:

    flutter test *> "$env:TEMP\tracon-agent\<run-id>\flutter-test.log"

Antes de limpiar históricos, clasifica cada objetivo como fuente, configuración,
documentación/evidencia permanente, cache/build regenerable, log temporal,
archivo temporal de test, artefacto de agente, release temporal o desconocido.
Solo elimina E/F/G/H/I cuando sea inequívocamente generado, no esté trackeado,
no esté referenciado, no sea necesario como evidencia, no pertenezca al trabajo
concurrente de otro agente y ningún proceso lo esté usando. Los desconocidos se
conservan y se reportan.

## Límites de tamaño orientativos

- `AGENTS.md`: objetivo menor de 12 KiB y preferiblemente menos de 200 líneas.
- `SKILL.md`: preferiblemente 80–220 líneas.
- Una referencia: un tema cohesivo; divídela cuando mezcle dominios independientes.

Estos límites son señales de mantenimiento, no excusa para omitir reglas esenciales.

## Cierre

1. Verifica frontmatter, nombres y rutas.
2. Revisa enlaces a skills y referencias inexistentes.
3. Ejecuta auditoría de duplicados.
4. Confirma que la regla quedó en una sola fuente canónica.
5. Reporta archivos creados, modificados, reglas movidas y duplicados eliminados.

Para una actualización transversal de backend/API, ejecuta también
`scripts/audit-data-api-rules.ps1` sobre los archivos afectados y
`scripts/test-data-api-rules.ps1`; sus heurísticas ambiguas son warnings y los
fallos inequívocos se mantienen como hard fail.

El lifecycle de datos y la limpieza R2 tienen fuente canónica en
docs/architecture/data-deletion-lifecycle.md y
docs/operations/r2-orphan-cleanup.md; las skills solo contienen invariantes
breves y no deben duplicar el runbook.

El portal operativo y su matriz RBAC tienen como fuentes canónicas
docs/architecture/web-admin-portal.md y docs/architecture/rbac.md.

La seguridad de datos productivos, la separación de autorizaciones y la
recuperación selectiva tienen como fuente canónica
`references/production-data-safety.md`; no se duplica en otras skills.

## Despliegues multi-agente

Cuando el desarrollo concurrente pueda llegar a producción, aplica
`references/multi-agent-release.md`. Se permite programar en paralelo; los flujos de despliegue se seleccionan en
AGENTS.md. El snapshot y ejecutor de `ops/deploy/` corresponden a workers. Windows mutex y server
`flock` serializan publicación y rollback. No se introducen requests, handoffs,
coordinadores, leases o tareas de AutoRelease.
