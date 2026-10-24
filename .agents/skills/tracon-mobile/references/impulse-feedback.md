# Microinteracción de Impulso

Reglas permanentes para la microinteracción de Impulsar en Traks (y reutilizable en Posts sin acoplar a `PageView`).

## Principios

- La celebración del Impulso ocurre **solo cuando el servidor confirma** éxito.
- El haptic es **claro y único**: nada de doble vibración por tap + success.
- La animación es **perceptible pero no invasiva**: nada de overlays fullscreen, confetti, casino UX.
- La microinteracción refuerza **agencia y causalidad**: el usuario sabe que usó un recurso.
- En `reduced motion` se conserva el cambio de estado, el haptic permitido y el feedback compacto.

## Componentes canónicos

- `lib/core/haptics/tracon_haptics_port.dart`: puerto abstracto.
- `lib/core/haptics/tracon_haptics.dart`: implementación Flutter con `mediumImpact` para éxito, `selectionClick` para undo, `lightImpact` para failure.
- `lib/core/haptics/tracon_haptics_port.dart` también expone `NoopTraconHaptics` para tests.
- `lib/modules/posts/presentation/widgets/impulse_reaction_state.dart`: state base abstracto con la lógica de animación (press, success, ring, sparks, haptics, idempotencia). Reutilizado por Traks y Posts.
- `lib/modules/posts/presentation/widgets/impulse_action_button.dart`: botón animado grande (52dp) para Traks, vertical, con ring + sparks + glow + rotation.
- `lib/modules/posts/presentation/widgets/impulse_reaction_feedback.dart`: reacción compacta horizontal (icon + count) para Posts del Feed. Mismo animation pipeline, sin sparks/glow para mantener la fila ligera.
- `lib/modules/posts/presentation/widgets/impulse_energy_ring.dart`: `CustomPainter` para ring y sparks.
- `lib/modules/posts/presentation/widgets/impulse_compact_toast.dart`: feedback compacto con `Deshacer` y barra de progreso sutil. Compartido entre Traks y Posts.

## Haptic

| Evento | Efecto | Cuándo |
|---|---|---|
| Success | `HapticFeedback.mediumImpact` | Cuando `celebrationToken` cambia (servidor confirma). |
| Undo | `HapticFeedback.selectionClick` | Cuando `undoToken` cambia (servidor confirma deshacer). |
| Failure | `HapticFeedback.lightImpact` | Cuando `failureToken` cambia (servidor confirma fallo). |
| Press | Sin haptic | El press solo anima; el haptic fuerte es el de éxito. |

## Idempotencia

- `celebrationToken` / `undoToken` / `failureToken` son `Object?` que cambian cuando un nuevo evento llega.
- El state base (`ImpulseReactionState`) compara contra el último valor: si es igual, no se vuelve a celebrar.
- La reconciliación que confirme un impulso ya celebrado **no** debe generar una segunda celebración.
- `ImpulseActionButton` (Traks) y `ImpulseReactionFeedback` (Posts) comparten **exactamente** la misma semántica de tokens.

## Sincronización visual + haptic

- El haptic de éxito se dispara cuando el `AnimationController` de success cruza ~34% (cerca del pico del punch), no antes.
- En `MediaQuery.disableAnimationsOf` el haptic se sigue disparando pero la animación visual se omite.

## Animación (timeline aproximada)

| ms | Evento |
|---|---|
| 0 | Tap registrado, press inicia scale down |
| ~110 | Press vuelve a scale 1.0 |
| Servidor responde |
| 0 (al success) | Punch 1.00 → 1.18 (easeOutBack) |
| ~50 | Haptic success |
| ~110 | Ring expansión inicia |
| ~50 | Sparks salen |
| ~120 | Punch 1.18 → 0.96 |
| ~220 | Punch 0.96 → 1.0 |
| ~380 | Ring termina de expandirse y se desvanece |

## Feedback compacto

- Reemplaza el `SnackBar` grande. Una sola línea con `⚡ Impulsado · N/M` y `Deshacer` con contraste de marca.
- Barra de progreso MUY sutil sobre la ventana de undo (sin countdown numérico).
- Aparece sobre el bottom nav con `SafeArea(bottom: true)`.
- En 360 px no debe haber overflow.
- Caso `0/limit` se permite añadir texto secundario corto sobre la hora de renovación, pero solo si cabe.

### Hit testing del feedback

- El feedback transitorio no usa una ruta modal ni una barrera fullscreen para
  una acción local. Un `OverlayEntry` propio debe limitar su caja al área
  visible del aviso; las coordenadas fuera de esa caja deben llegar al feed,
  a la navegación y a los controles subyacentes.
- Solo la superficie visual del aviso y `Deshacer` participan en hit testing.
  No se debe resolver el problema con `IgnorePointer` sobre todo el aviso ni
  con un `Positioned.fill` que convierta una decoración en una barrera.
- Un nuevo resultado reemplaza el aviso anterior y elimina su `OverlayEntry`;
  no acumula entradas ni deja callbacks de undo huérfanos.

## Pending / failure / undo

- `pending: true` desactiva el tap, baja opacidad a 0.78 y bloquea interacción.
- Failure revierte el contador y dispara `lightImpact`; no hay segunda celebración.
- Undo revierte el contador y dispara `selectionClick`; no hay segunda celebración.

## Reduced motion

- `MediaQuery.disableAnimationsOf(context) == true` desactiva ring, sparks, scale, rotation, glow, slide y el contador animado. Conserva cambio de estado, haptic permitido y feedback compacto.

## Lo que está prohibido

- Recompensas aleatorias, confetti, sonidos casino, vibraciones largas, haptic spam, colores parpadeantes, countdown numérico de urgencia, rachas artificiales, FOMO, upsell al llegar a 0.
- Reaccionar a `Page swipe`, `count rebuild`, `Snackbar open` o `button repaint` con haptic.
- Recrear `VideoPlayerController`, `TrakSlide` o `PageView` para celebrar.
- Pausar el video para animar.
- Tocar el gesto de tap, vertical swipe, double tap like o comments.

## No inventar

- Si el backend no devuelve `usageId` o `undoAvailable`, no muestres el botón Deshacer.
- Si el servidor no confirma, no muestres el saldo actualizado autoritativamente: usa el `remaining/limit` del resultado confirmado.

## Variantes visuales

| Variante | Widget | Tamaño | Animación | Uso |
|---|---|---|---|---|
| Trak grande | `ImpulseActionButton` | 52dp circular vertical | pulse + ring + sparks + glow + rotation | Rail lateral de Traks |
| Post compacto | `ImpulseReactionFeedback` | 22dp icono + count horizontal | pulse + ring (sin sparks/glow) | Action row de Feed |

Ambas reutilizan `ImpulseReactionState`: misma timeline, misma idempotencia, mismos haptics (`TraconHaptics`), misma snackbar (`ImpulseFeedback.showResult`). El autor del Feed NO debe reimplementar animación ni haptic; debe emitir los tres tokens (`celebrationToken`, `undoToken`, `failureToken`) igual que Traks.
