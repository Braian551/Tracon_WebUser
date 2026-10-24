# Integridad del worktree e índice

Esta es la fuente canónica de la protección del worktree de Tracon. AGENTS.md
conserva solo el hard invariant breve; SKILL.md enruta aquí el procedimiento
detallado. La política aplica igual a Codex, OpenCode, subagentes y wrappers.

## Baseline y propiedad

Al inicio de cada tarea se define conceptualmente:

    BASELINE_WORKTREE = todo estado staged, unstaged y untracked observado antes de editar
    PREEXISTING_WORKTREE_STATE = PROTECTED

El contenido presente al inicio es dato del usuario o de procesos concurrentes.
Descubrir un archivo modificado no otorga propiedad, aunque el cambio parezca
antiguo, incompleto, incorrecto, ajeno, incompatible con HEAD, asociado a otro
módulo o responsable de un fallo. La unidad de comparación es
FINAL_STATE - BASELINE_WORKTREE, nunca FINAL_STATE - HEAD.

Antes de editar se ejecutan solo inspecciones read-only, como mínimo:

    git status --short
    git status --porcelain=v1
    git diff --stat
    git diff
    git diff --cached
    git branch --show-current
    git rev-parse HEAD

Se registra mentalmente qué era staged, unstaged y untracked. Si otro proceso
añade cambios durante la tarea, esos cambios también se conservan y se auditan
antes del cierre.

## Prohibición de mutación temporal

Un agente nunca puede obtener un clean state alterando el worktree principal,
el índice, referencias, commits o archivos untracked. La prohibición se aplica
por efecto, no por spelling, y no cambia porque la operación sea reversible,
temporal o seguida de una restauración.

Sin autorización literal y explícita del usuario para una operación concreta,
están prohibidos:

- git stash, git stash push, git stash pop, git stash apply, git stash drop y git stash clear.
- git reset, git restore, git clean, git checkout destructivo y git switch para escapar del estado actual.
- git rebase, git merge, git cherry-pick y git revert cuando puedan cambiar el estado recibido o el historial.
- Copiar cambios fuera y borrarlos del repositorio, mover o renombrar archivos para probar, sobrescribir archivos con HEAD, cambiar staging temporalmente o usar scripts que hagan cualquiera de lo anterior.

Estas justificaciones no son autorización: “necesito un árbol limpio”, “quiero
confirmar que el fallo era preexistente”, “lo restauraré después”, “solo será
por unos segundos” y “voy a guardar los cambios primero”. Tampoco se usa Git
como mecanismo de arreglo; se inspecciona el diff y se parchean manualmente
solo los hunks propios.

## Índice y untracked

El índice es estado protegido. No se usa git add, git reset HEAD,
git restore --staged, git stash --keep-index ni git stash --staged para
separar una tarea o fabricar un baseline. El agente conserva staging ajeno y no
lo modifica deliberadamente salvo autorización explícita.

Todo untracked presente en el baseline es protegido: no se borra, mueve,
renombra, sobrescribe, incluye en un stash ni se usa como temporal. Untracked no
significa descartable.

## Concurrencia y alcance

Siempre se asume que otros agentes pueden trabajar sobre el mismo repositorio.
En archivos compartidos se inspeccionan primero los hunks existentes y se
aplica un parche mínimo que preserve cada modificación anterior. No se
formatean masivamente archivos ajenos ni se sustituye un archivo completo por
HEAD.

OUT-OF-SCOPE MODIFIED FILE != PERMISSION TO FIX IT. Un archivo ajeno solo se
puede tocar si existe una dependencia técnica demostrable, es necesario para la
entrega, se preservan sus cambios y se documenta la ampliación de alcance. Un
test fallido por sí solo no autoriza corregirlo.

## Fallos globales y atribución

Si una prueba falla fuera del alcance:

1. No se toca el código fallido ni se limpia el worktree.
2. Se inspeccionan baseline, archivo fallido, diff existente y relación con la tarea.
3. Se ejecutan validaciones enfocadas del alcance.
4. Con evidencia suficiente se reporta PRE-EXISTING / OUT-OF-SCOPE FAILURE.
5. Si no puede aislarse sin mutar trabajo protegido, se reporta UNABLE TO ISOLATE WITHOUT MUTATING PROTECTED WORKTREE.

Nunca se fabrica una reproducción limpia mediante stash, reset, restore,
checkout, copia temporal o manipulación del índice. Las pruebas no tienen
prioridad sobre conservar el trabajo recibido.

## Alternativas seguras

Son válidas la lectura de git diff, git show, git log, git blame,
git rev-parse, git ls-tree, análisis estático, revisión del baseline y tests
enfocados. El historial, reflog, stash y objetos dangling solo aportan
evidencia read-only; no se aplican snapshots automáticamente.

Si excepcionalmente se necesita comparar contra un HEAD completo, se puede usar
una copia independiente descartable fuera del worktree activo, únicamente si
no mueve ni modifica archivos ni metadata Git compartida del repositorio
activo. No se crean automáticamente worktrees, ramas o stashes como sustituto.

## Bypass indirecto

La regla aplica por efecto: queda prohibido invocar una operación bloqueada con
PowerShell, cmd, Bash, Python, Node, alias, wrapper, script temporal o proceso
hijo. También queda prohibido ocultar la operación en una cadena o argumento.
La configuración OpenCode usa denegación por defecto de Bash, deniega patrones
de wrappers conocidos y permite solo Git read-only explícito; el auditor
estático comprueba que no exista un override que lo reabra.

## Protección mecánica OpenCode

opencode.json en la raíz es la configuración canónica del repositorio para
OpenCode 1.x. permission.bash usa patrones glob ordenados: la última regla
coincidente gana. La política es * = deny, con allowlist final de comandos Git
read-only conocidos. Por tanto, Git desconocido, comandos encadenados,
git -C <ruta> ..., wrappers y scripts no se convierten en allow por defecto.

No se permite en permission.bash, agent.*.permission.bash, agentes Markdown
ni configuraciones bajo .opencode ningún override allow o ask que cubra stash,
reset, restore, clean, checkout destructivo, switch, rebase, merge,
cherry-pick, revert, index o limpieza de untracked. La auditoría debe fallar si
aparece. La misma política se aplica a todos los agentes, incluidos build,
plan y subagentes.

La configuración de seguridad es protegida por política: un agente normal no
puede debilitarla, cambiar deny a allow, quitar patrones ni añadir overrides
contradictorios. Modificarla solo pertenece a una tarea del usuario que
solicite expresamente reglas de agentes y debe conservar o reforzar la
seguridad. Tras cambiarla, se debe iniciar una sesión/proceso nuevo o recargar
la configuración antes de atribuir efecto a la política.

## Cierre

Antes de finalizar se repiten git status --short, git diff --stat, git diff,
git diff --cached --stat, git diff --cached y git diff --check. Se verifica que
ningún hunk preexistente desapareció, que no hay archivos accidentales,
secretos, temporales ni alteraciones del índice. No se hacen commit, push, ADB,
builds o despliegues salvo autorización independiente.
