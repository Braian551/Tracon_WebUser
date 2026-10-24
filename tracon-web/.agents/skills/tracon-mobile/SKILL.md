---
name: tracon-mobile
description: Implementa o revisa la aplicación Flutter de Tracon: pantallas, widgets, navegación, formularios, estado, autenticación cliente, permisos Android/iOS, accesibilidad, rendimiento y pruebas de widgets. Para cualquier cambio visual debe cargar también tracon-design. No usar para cambios exclusivos de Spring, VPS o procesamiento servidor de video.
---

# Tracon Mobile

## Alcance

Trabaja principalmente en `mobile/` y documentación móvil relacionada.

Registra el cambio con `../tracon-change-contract/SKILL.md` y la política
`../tracon-agent-rules/references/change-contract-policy.md`. Mobile conserva
`MOBILE_DEPLOYMENT_REQUEST=NONE`; una publicación en tienda requiere una
solicitud explícita separada.

## Skills compañeras

Carga solo cuando aplique:

- `tracon-design`: obligatorio cuando la tarea crea o modifica apariencia, layout, jerarquía visual, tema, tokens, componentes, responsive visual, animaciones o experiencia de usuario.
- `tracon-architecture`: cuando se modifican límites de capas, gestión de estado estructural, puertos/repositorios, adaptadores de SDK, dependencias o se selecciona un patrón GOF.
- `tracon-backend`: cuando cambia o consume un contrato API, autenticación, autorización, payload, paginación o estado servidor.
- `tracon-media`: cuando selecciona, sube, procesa o reproduce imágenes/video.
- `tracon-product`: cuando cambia comportamiento funcional, estados, permisos de negocio, puntos, feed o moderación.
- `tracon-legal`: cuando cambia copy legal, enlaces de políticas, privacidad, tratamiento de datos, Play o seguridad infantil.
- `tracon-quality`: solo para auditoría amplia o validación transversal solicitada.

No cargues compañeras por simple posibilidad.

Las pantallas legales usan `LegalDocumentPublic`: título y fecha del manifiesto
más body Markdown renderizado. Nunca pasan al widget `releaseStatus`, hashes,
notas de revisión, `LEGAL_TODO`, `LEGAL_REVIEW_REQUIRED` ni estados de
prepublicación; el detalle canónico vive en
`../tracon-legal/references/public-document-presentation.md`.

## Inicio

Cuando se modifiquen la bandeja, FCM, permisos, badges, registros de dispositivos o deep links de notificaciones, carga tambien `tracon-notifications`.

1. Identifica pantallas, widgets, controladores, rutas, datasources, assets, plataformas y pruebas afectadas.
2. Revisa componentes globales existentes antes de crear otro.
3. Conserva arquitectura por módulos y capas.
4. Lee solo referencias necesarias:
   - `references/flutter-architecture.md`
   - `references/ui-permissions-and-accessibility.md`
   - `references/mobile-validation.md`
   - `references/impulse-feedback.md` cuando se modifique la microinteracción de Impulsar en Traks o Posts.
   - `../tracon-backend/references/authentication-onboarding.md` cuando se modifique el onboarding de identidad o username.
5. Consulta documentación aplicable bajo `docs/architecture`, `docs/legal`, `docs/security` y `docs/dependencies/flutter.md`.
6. Cuando la pantalla consuma o modifique un contrato API, paginación,
   realtime, cache u operación async, lee
   `../tracon-agent-rules/references/backend-data-api-scalability-safety.md`.

## Reglas

- No llames HTTP, SDKs o almacenamiento directamente desde widgets salvo prototipo explícito y temporal.
- Reutiliza componentes globales y contratos existentes.
- Usa shimmer para carga de contenido; reserva indicadores circulares para acciones en curso.
- Valida formularios desde la interacción y usa debounce para verificaciones remotas.
- Pagina listas crecientes, usa construcción perezosa y libera controladores, timers y streams.
- Coalescea requests repetidos desde repository/estado canónico, ejecuta en
  paralelo fetches independientes y aplica cancelación/latest-wins cuando una
  navegación vuelve irrelevante la respuesta. La recuperación de red prioriza
  la superficie visible, usa jitter y no crea loops.
- Respeta el contrato server-side de default/max limit, cursor y payload; no
  confíes en Flutter para limitar colecciones ni descargues bytes multimedia
  grandes por JSON/WebSocket/GraphQL cuando exista entrega directa CDN/R2.
- No guardes tokens en almacenamiento inseguro ni imprimas secretos.
- Mantén soporte para anchos pequeños, teclado visible, texto largo y escalado de fuente.
- Para navegación, valida rutas, guards, argumentos, constructores y flujo manual.
- La navegación de notificaciones usa un `AppNavigationCoordinator` enlazado al
  `GoRouter` explícito. No llames `GoRouter.of(context)` desde el `builder` de
  `MaterialApp.router`, donde el contexto puede estar fuera del árbol del router.
- Un widget hijo no puede notificar al padre mutando su estado durante `build`,
  `didUpdateWidget` o una fase de layout. Los `ChatNavigationRequest` se
  consumen después del frame, con ledger por `requestId` y una única apertura.
- Las pantallas abiertas desde una notificación deben tolerar que el objetivo
  cambie entre la preconsulta y la carga: 403/404/410 vuelven al destino estable
  o al shell con copy humano, sin reintentos infinitos ni diagnósticos técnicos.
- En chats, `activeConversationId` solo suprime efectos de notificación mientras
  la app está en foreground; el evento realtime, la inserción del mensaje y el
  read receipt no se suprimen. Background/terminated conserva FCM y el tap.
- En comentarios, el optimista separa `clientCommentId` de `serverCommentId`.
  Las acciones que requieren UUID se deshabilitan o esperan mientras falta el
  UUID; HTTP/WebSocket reemplazan la misma fila por identidad. Los errores raw
  del backend no llegan a UI, y la fila prioriza `displayName` sin repetir
   `@username` fuera del cuerpo de menciones.
- Feed, detalle, Traks, perfil, guardados, compartidos y visor multimedia deben
  observar `CanonicalPostStore` por `postId`. Las acciones optimistas se
  reconcilian con snapshots absolutos, generación y versión; no se mantienen
  contadores sociales paralelos en widgets.
- Search aplica debounce, cancelación y protección contra respuestas obsoletas
  en sugerencias y resultados. Sus posts usan `FeedPostCard`, sus Traks usan
  `TraksPage` y sus personas usan `SocialUserTile`; no duplica renderers ni
  estado social. El buscador visual reutiliza `AppSearchField` y cumple el
  invariant canónico de `tracon-design/references/search-field-invariant.md`:
  sin filtro trailing por defecto, clear únicamente con query y sin espacio o
  semántica fantasma.
- El envío de texto y contenido compartido crea primero un `clientMessageId`,
  pinta optimistic, persiste el payload mínimo en outbox y reutiliza la misma
  identidad al reintentar. ACK HTTP, eco WebSocket e historial se reconcilian
  por ID; solo mensajes visibles avanzan el cursor de lectura. Ver
  `docs/architecture/chat-messaging.md`.
- Firebase obtiene identidad en cliente; el backend sigue siendo autoridad de permisos.
- Traks usa `FeedVideoCoordinator` como autoridad de playback; la pausa de
  usuario es por media y la regla detallada de preload, overlay, poster y
  métricas vive en `tracon-media` y su documento de arquitectura.
- `SessionController` es la única fuente de verdad para Firebase, cuenta, lifecycle y
  onboarding; el listener y la UI deben esperar su misma resolución single-flight.
- Cancelar Google es un resultado normal: no muestra error, no llama al backend ni
  expone excepciones del SDK. Los fallos reales se traducen a mensajes seguros.
- El username obligatorio se resuelve antes de construir o mostrar Home; no se
  asignan usernames definitivos desde correo, UID o sufijos aleatorios.
- Las rutas estáticas de perfil deben preceder a `/profile/:userId`; editar siempre
  usa la identidad autenticada y nunca un identificador recibido por la URL.
- Las decisiones visuales pertenecen a `tracon-design`; no las dupliques aquí.
- Los avisos de revisión musical consumen el centro durable de notificaciones,
  FCM/realtime y deep links validados. La UI muestra canción, artista, estado y
  la separación entre identificación y derechos; solo ofrece acciones que
  tengan endpoint real (ver Trak, silenciar audio o eliminar Trak).
- Las cuotas de producto se leen desde `/api/v1/me/limits`; la UI puede anticipar
  disponibilidad, pero el backend decide. Convierte `429` de cuota, capacidad o
  seguridad a copy humano y no muestra nombres de servicios, almacenamiento o
  identificadores técnicos. El contrato canónico está en
  `docs/architecture/quota-and-rate-limiting.md`.
- Toda superficie UGC nueva o modificada debe exponer reportar/bloquear según
  corresponda, incluido el motivo de seguridad infantil, y enlazar documentos
  legales desde el manifiesto sincronizado; no se acepta un placeholder de
  seguridad en una pantalla de publicación o reproducción.

El flujo legal móvil tiene una única autoridad de estado: `SessionController`
(o un coordinador de sesión equivalente). Su máquina canónica es
`checking -> signedOut | legalRequired | usernameSetup | active | recovery | error`.
El router solo redirige según esa fase; nunca presenta modales desde `redirect`,
`build`, listeners o interceptores HTTP.

`legalRequired` usa un host neutral que presenta una sola `LegalConsentSheet`
después del montaje, con deduplicación single-flight y ciclo de vida seguro. La
hoja conserva checkboxes y draft al abrir un `LegalDocumentPage(documentType)`;
el botón de aceptación queda deshabilitado con spinner hasta la respuesta del
backend. Error conserva la hoja y permite reintentar. Cancelar cierra la hoja,
revoca la sesión Firebase temporal y vuelve a `signedOut`; no reabre el gate.

El backend es la autoridad para aceptar versiones legales. Google/email
resuelven autenticación y estado antes de abrir el gate; una cuenta existente
con estado vigente no muestra UI legal, una cuenta nueva o desactualizada la
muestra una sola vez. Mientras se resuelve legal u onboarding no se construye
Home/feed/media. Un error `LEGAL_ACCEPTANCE_REQUIRED` bloquea publicaciones,
Traks, comentarios, respuestas, mensajes, comunidades, medios y edición de
perfil hasta completar la aceptación. Este detalle vive en
`references/legal-session-flow.md`.

El rail de Traks conserva el silencio como control iconográfico local; la fuente de audio, su página y el Sharesheet usan contratos reutilizables descritos en `docs/architecture/audio-and-sharing.md`.

En el compositor de Trak, `usar audio del video`, la declaración de derechos y `permitir reutilización` son controles distintos. Elegir una Audio Source reemplaza la pista original en el MVP; el juego relacionado permanece opcional.

La microinteracción de Impulsar usa `TraconHaptics` y los componentes `ImpulseActionButton` / `ImpulseCompactToast`. La celebración visual y el haptic de éxito solo se disparan cuando el servidor confirma; undo y failure usan haptics distintos y nunca repiten la celebración. La regla detallada (timeline, tokens de idempotencia, haptics, reduced motion, prohibiciones) vive en `references/impulse-feedback.md`.

Lenguaje user-facing: la UI describe intención, no implementación. Nunca exponer términos internos (`backend`, `API`, `worker`, `selector de Android`, `Photo Picker`, `mediaId`, `asset`, `clip` para usuario). Auditoría y lista viva en `../tracon-design/references/ui-patterns.md` ("Lenguaje user-facing"). Guardrail en `test/user_facing_copy_guardrail_test.dart`.

## Cierre

- Formatea archivos modificados.
- Analiza archivos modificados y consumidores directos.
- Ejecuta pruebas relacionadas.
- Revisa overflow, carga/error/vacío, `mounted`, `dispose`, nulabilidad y assets.
- No declares validado un comando que no terminó correctamente.
- Los cambios exclusivamente móviles no generan AAB/APK ni incrementan
  `versionCode`; tampoco crean `Deployment Request` ni `READY` server-side.
  Un build móvil, cambio de versión, rollout o subida a Play Store solo se hace
  si el usuario lo solicita explícitamente.

El cierre estándar de una tarea mobile es:

```text
STATUS
FILES_CHANGED
DART_FORMAT
FLUTTER_ANALYZE
FLUTTER_TESTS
BACKEND_CHANGED
READY_FOR_MOBILE_RELEASE
MOBILE_RELEASE_EXECUTED=NO
PLAY_STORE_UPLOAD=NO
FINAL_ACTION=STOP
```

En una tarea mixta, `BACKEND_CHANGED` se reporta por separado y solo el
componente server-side puede requerir un Deployment Request. Mobile conserva
`READY_FOR_MOBILE_RELEASE` y `MOBILE_DEPLOYMENT_REQUEST=NONE`.

En el compositor de Trak, el preflight local debe obtener metadata antes de
abrir el editor cuando sea razonablemente posible. Cada fuente conserva un
estado estructurado y la UI muestra un mensaje específico y accionable; nunca
se reduce un fallo conocido a un error genérico de preparación. Una fuente
larga pero válida pasa como `TRIM_REQUIRED`; el proyecto de edición, no la
selección, aplica el límite de duración final. El backend y el worker siguen
siendo autoridad.

`READY` no puede coexistir con un error de lectura de página para la misma
selección. Las operaciones asíncronas de metadata, miniatura y preparación
del editor deben comprobar la identidad estable de la fuente y la generación
de selección antes de publicar resultados; una miniatura fallida conserva la
validación de video y no bloquea por sí sola el editor. El copy y la jerarquía
visual canónicos de estos estados viven en `tracon-design`.

En la cámara de Trak, `rawPreviewSize` no equivale a la geometría de display:
`CameraPreview` y el plugin nativo pueden aplicar aspect ratio y rotación antes
del wrapper de la aplicación. No imponer el tamaño RAW como constraints tight ni
agregar una segunda rotación; la escala debe ser uniforme y la validación de la
textura nativa en un dispositivo físico es obligatoria antes de afirmar que la
cámara está corregida.

Los videos seleccionados deben representarse visualmente en la experiencia de
creador: miniatura cuando sea posible, duración, orden y estado por fuente.
El nombre del archivo es secundario. Reordenar y quitar deben modificar la
misma fuente de verdad que usa el editor; un fallo de miniatura no invalida una
fuente cuyo video y metadata son válidos.

El onboarding de perfil consume las sugerencias del estado de cuenta del
servidor y envía `displayName` + `username` en una única operación. Firebase
puede aportar el prellenado de la primera alta, pero el cliente nunca usa su
nombre o `photoURL` para sobrescribir el perfil canónico después del login.
La disponibilidad es server-authoritative, con debounce y protección contra
respuestas obsoletas; no es necesario mostrar un mensaje positivo persistente.

## Contenido retirado y enlaces antiguos

Feed, perfil, notificaciones y deep links deben tolerar 404/410 de posts,
Traks, audio y media. Mostrar un estado humano como “Este contenido ya no está
disponible.”; no reintentar indefinidamente ni revelar claves, URLs firmadas o
detalles de purga. La cuenta desactivada se presenta como oculta y recuperable;
la eliminación en procesamiento es irreversible.
