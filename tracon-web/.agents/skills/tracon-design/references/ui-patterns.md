# Patrones UI de Tracon

## Feed

- Lista continua y ligera; evita tarjetas pesadas para cada publicación.
- Autor y tiempo en una línea cuando el espacio lo permita.
- El contenido es prioritario.
- Acciones compactas, consistentes y con etiquetas accesibles.
- Pestañas principales: `Para ti`, `Siguiendo`, `Radar`.
- Usa paginación, estados vacío/error y shimmer.

En Traks, compartir y guardar son acciones explícitas del rail. El silencio es un icono pequeño sin etiqueta persistente; una fuente disponible usa artwork/avatar o una nota musical de fallback, no aparece en posts sin audio y respeta reducir movimiento.

## Compositor

- Publicación normal: campo de texto principal y adjuntos mediante acciones claras.
- El título se reserva para retos cuando la regla funcional lo requiera.
- Mostrar selección, progreso, error, reintento y estado de procesamiento de medios.
- Evitar formularios extensos antes de que el usuario decida el tipo de contenido.

### Crear Trak (entrada del creator)

- Título: `Crear Trak`. Subtítulo: `¿Cómo quieres empezar?`.
- Una acción primaria grande (filled brand) y una secundaria outlined:
  - **Grabar ahora** — botón grande brand, ícono cámara, descripción `Crea un video con la cámara de Tracon.`
  - **Elegir videos** — outlined surface, ícono galería, descripción `Hasta 10 videos de tu galería.`
- Debajo: `🔒 Solo veremos los videos que elijas.` (un renglón, lock icon).
- Tras seleccionar videos se muestra el contador + un `Siguiente (n)` filled.
- Nunca exponer nombres de APIs, frameworks, bases de datos, `clips`, aspect ratios (`9:16`), `worker`, `selector`, `Photo Picker`, `mediaId`.

## Navegación

La navegación inferior del MVP contempla Inicio, Chats, Crear, Traks y Perfil. Una función aún no entregada puede mostrar un estado `Próximamente` explícito sin simular funcionamiento.

## Formularios

- Validación desde la interacción.
- Mensajes específicos y cercanos al campo.
- Debounce para unicidad u otras comprobaciones remotas.
- Estado de envío separado del estado de carga de contenido.
- Mantener contenido y foco cuando un error recuperable ocurra.

## Carga y estados

- Shimmer para contenido asíncrono.
- Indicador de progreso para acciones como enviar, subir o procesar.
- Vacío: explicar qué falta y ofrecer una acción útil cuando exista.
- Error: explicar el problema sin filtrar detalles internos y permitir reintento cuando sea seguro.
- Procesamiento: distinguir `subiendo`, `procesando`, `listo` y `fallido`.

## Responsive

- Diseñar primero para móvil estrecho.
- Probar textos largos, nombres extensos, teclado, escalado de fuente y barras del sistema.
- Evitar `Row` rígidas con contenido dinámico.
- No ocultar acciones esenciales por overflow.

## Fila de acciones del perfil

La fila de acciones principales del perfil (Seguir/Siguiendo, Mensaje,
Compartir, Editar perfil) prioriza siempre la legibilidad de los labels de
alta prioridad. No se reduce la fuente ni se parten palabras para que
quepan tres botones en móvil compacto.

- **Jerarquía**: Seguir/Siguiendo > Mensaje > Compartir > Editar perfil. La
  acción con menos peso visual (Compartir) es la candidata a compactarse
  cuando el ancho horizontal no admite las tres etiquetas en una sola línea.
- **Adaptativo por ancho real**: cuando el ancho disponible para la fila
  cae por debajo del umbral documentado, Compartir pasa a un botón
  cuadrado de 48×48 solo con icono. Su handler, semántica y tooltip
  (`Compartir perfil`) son idénticos a la versión etiquetada.
- **Sin wrap de labels**: cada `Text` de los botones usa `maxLines: 1`,
  `softWrap: false` y `overflow: TextOverflow.ellipsis`; el layout debe
  garantizar que normalmente no se vea elipsis en `Seguir`, `Siguiendo`,
  `Mensaje` o `Editar perfil` en anchos móviles estándar.
- **Sin duplicación**: una sola composición adaptativa cubre perfil propio
  y ajeno; las decisiones de visibilidad (Mensaje, Editar) son
  condicionales al modelo, no a la pantalla.

## Accesibilidad

- Contraste suficiente.
- Targets táctiles razonables.
- Etiquetas semánticas para iconos.
- Orden de foco coherente.
- No depender solo de color, animación o posición.
- Respetar reducción de movimiento cuando aplique.

## Documentos legales

Las páginas legales priorizan el contenido: una sola H1 en el header, fecha
humana, ancho de lectura cómodo y jerarquía Markdown real para H2/H3, listas,
enlaces, bloques y separadores. No muestran sintaxis Markdown ni metadata de
release, borrador, revisión, contacto técnico o hashes. La separación de
metadata y las reglas de aceptación son canónicas en
`../tracon-legal/references/public-document-presentation.md`.

## Selección visible en pickers y editores

Cualquier selección persistente del usuario que afecte el resultado de un medio (audio, portada, sticker, juego relacionado, etc.) debe responder siempre "¿qué está elegido?" sin obligar a reabrir el selector. Esto vale para editor, publish y cualquier pantalla derivada.

Cada selección debe cumplir simultáneamente:

- **Una sola fuente de verdad**: editor, selector y publish observan el mismo estado canónico. No duplicar `selectedAudioInEditor`, `selectedAudioInSheet`, etc. que puedan desincronizarse.
- **Marcador en el selector**: el item elegido muestra un indicador (badge sobre la portada o trailing) claramente diferenciable del resto de iconos (bookmark, me gusta, guardar).
- **Feedback persistente en el editor**: chip/banner persistente que muestra el nombre legible y, si aplica, una X para quitar sin abrir el selector.
- **Tap para cambiar**: tocar el chip/banner reabre el selector conservando la elección actual marcada.
- **Quitar reversible**: la X quita sin pedir confirmación y sin tocar el origen (no borra el Audio Source ni sus favoritos).
- **Toolbar/acción alineada**: el botón de acción del toolbar refleja el estado activo (color acento + dot/check) cuando hay selección, sin repetir el nombre.
- **Publish alineado**: la pantalla de publicación muestra el mismo nombre/título que el editor. Si editor dice "Alchemist" y publish dice "Audio original", es un bug.
- **Accesibilidad**: el badge expone `Semantics(selected: true, label: 'Seleccionado')` y el chip expone un `Semantics(label: 'Sonido: <título>. Toca para cambiar.')` navegable por TalkBack.
- **Nunca repetir información**: chip + nombre completo en lista + badge gigante + toast permanente saturan. Mantener jerarquía: chip = estado principal, check = confirmación, toolbar = acción.
- **Persistencia**: la selección sobrevive abrir/cerrar el sheet, ir a portada, volver al editor, abrir el selector de juego, navegar a publish y volver, y un background corto.
- **`selectedStartMs`/clamp**: al cambiar de item se clampea el offset seleccionado al rango de la nueva duración; el clamp se cubre con tests.

## Lenguaje user-facing (UX Writing)

La UI habla el idioma del usuario. El código habla el idioma del desarrollador. No mezclar ambos.

### Regla

Toda cadena visible al usuario debe:

- ser simple y natural;
- describir **intención** del usuario, no la implementación;
- evitar nombres de APIs, frameworks, bases de datos o sistemas internos;
- evitar detalles técnicos innecesarios;
- usar vocabulario del producto (`video`, `foto`, `sonido`, `Trak`, `galería`, `cámara`, `subiendo`, `procesando`).

### Prohibido en copy user-facing

- `backend`, `API`, `worker`, `FFmpeg`, `HLS`, `R2`, `PostgreSQL`, `Redis`, `DTO`, `asset`, `mediaId`, `Audio Source ID`, `Photo Picker`, `selector de Android`, `selector privado de Android`, `selector del sistema`, `Embedded Photo Picker`.
- HTTP error codes visibles al usuario (`Error HTTP 500`, `HTTP 409`).
- Mensajes de error que filtren stack, código interno o `backend no respondió`.
- Detalles de permisos (`Permission denied`, `Android 14`, `storage`).

### Excepción

Solo se permite tecnología visible cuando el usuario **realmente** la está gestionando (por ejemplo `Abrir ajustes de Android`). Nunca mostrar nombres de APIs solo porque el código las usa.

### Revisión de copy antes de cerrar

Para cada texto visible:

1. ¿Un usuario normal entiende esto?
2. ¿Necesita saber este detalle?
3. ¿Estoy describiendo implementación en vez de acción?
4. ¿Se puede decir con menos palabras?
5. ¿Es coherente con el resto de Tracon?

### Guardrail

Existe un test (`test/user_facing_copy_guardrail_test.dart`) que detecta automáticamente los términos prohibidos listados arriba en strings user-facing de producción. Cualquier nuevo copy debe pasar este guardrail antes de merge.

## Listas de identidad social (Seguidores, Siguiendo, En común)

Las listas que muestran identidad social (Seguidores, Siguiendo, En común,
seguidos en común, bloqueos) deben priorizar **avatar + identidad + una acción
primaria compacta**, no una composición tipo tarjeta. La fila es continua y se
separa por espaciado, ritmo y jerarquía, no por divisores, fondos ni sombras.

Reglas:

- **Avatar a la izquierda**, identidad al centro y acción al final. La zona de
  identidad ocupa el espacio flexible (`Expanded`); la acción solo el ancho
  mínimo necesario para su etiqueta.
- **Jerarquía de identidad**: `displayName` es la línea principal con peso
  semibold; `@username` y metadata secundaria (`Mutuo`) viven en una línea de
  soporte con contraste bajo.
- **Sin cards**: no envolver cada fila en un `Container` decorado, no usar
  `ListTile` con su padding interno por defecto para estas filas. Evitar
  divisores fuertes entre usuarios.
- **Botón de seguir compacto**: altura fija y moderada (≈32 px), ancho según
  contenido, padding horizontal generoso pero `tapTargetSize: shrinkWrap`.
  Estados visibles: `Seguir`, `Seguir también` (cuando el otro ya te sigue y tú
  no), `Siguiendo`, `Solicitado`. El estado pending se representa con un
  spinner local sin bloquear la fila ni la lista.
- **Sin truncamiento**: el texto del botón nunca debe renderizarse como
  `Sigue…` por falta de espacio. La etiqueta se renderiza con `maxLines: 1`,
  `softWrap: false` y ancho ajustado a contenido.
- **`Siguiendo` discreto**: outline sutil sobre `surfaceContainerHigh`, no un
  rectángulo rosa grueso. El estado primario usa el acento de marca solo cuando
  la acción es positiva.
- **Nombres largos**: `displayName` y `@username` con `maxLines: 1` y
  `TextOverflow.ellipsis`. La fila debe sobrevivir anchos de 360 px sin
  `RenderFlex overflow` ni perdida de la acción.
- **Propio usuario**: nunca mostrar botón de seguir al propio usuario,
  incluso si el endpoint lo devuelve en la página.
- **Mutuo**: se representa como texto secundario al lado del `@username` con
  separador `·`, no como badge independiente.
- **Tap profile**: la zona de identidad abre perfil; el botón de seguir no
  debe disparar navegación accidental.

## Estados de validación de videos antes del editor

La vista de selección muestra miniatura cuando es posible, nombre secundario,
duración y estado por video. `Preparando video…` bloquea continuar; `Listo` y
`Se recortará al editar` permiten abrir el editor. Los fallos muestran una
causa humana y una acción clara como quitar o seleccionar nuevamente. Un video
largo válido nunca se presenta como error: la duración completa queda visible
en la línea de tiempo y la ventana de recorte respeta el límite real del Trak.

La fuente canónica del estado de cada video es independiente de los mensajes
de página. Una fuente en `READY` nunca debe mostrar simultáneamente el error
global de video ilegible; los errores de miniatura se representan como un
estado visual separado y no cambian la validación. Las respuestas asíncronas
de una selección anterior no pueden actualizar la tarjeta ni el error visible
de la selección actual.
