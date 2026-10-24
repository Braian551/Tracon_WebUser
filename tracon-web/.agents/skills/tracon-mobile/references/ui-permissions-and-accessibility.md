# Flutter: diseño aprobado, permisos y accesibilidad

Referencia para preservar diseño, responsive, tokens, permisos Android/iOS, accesibilidad visual y UTF-8.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 47. REGLAS DE INTERFAZ

## 47.00 Temas y tokens globales obligatorios

Toda vista nueva o editada debe obtener color, contraste, superficies, bordes y
texto desde `Theme.of(context).colorScheme` y `Theme.of(context).textTheme`.
No introducir `Color(...)`, `Colors.*` ni paletas locales dentro de pantallas
salvo un token global de `AppColors` compatible con ambos temas. Antes de
entregar, verificar tema claro y oscuro: ningún widget puede depender de fondo
oscuro, texto blanco o un color fijo para conservar legibilidad.

## 47.0 Preservación de diseño aprobado

Cuando exista una pantalla, mockup o implementación visual aprobada, un cambio
funcional debe conservar su composición, paleta, jerarquía, navegación,
gradientes, tipografía y comportamiento visual. No se permite sustituirla por
una interfaz Material genérica ni rediseñarla silenciosamente. Antes de editar,
revisar el componente actual y sus referencias visuales; si el cambio requiere
una desviación perceptible, pedir aprobación explícita. Las nuevas vistas deben
reutilizar el mismo lenguaje visual, incluidos los estados mock que producto
quiera mantener mientras la funcionalidad real llega.

La clasificación visual también es obligatoria: las publicaciones usan un feed
de tarjetas o lista desplazable; Traks usa el feed inmersivo vertical de video
corto. No intercambiar ambos patrones por conveniencia técnica.

Los gradientes son excepcionales y sobrios: priorizar superficies sólidas,
contraste, borde y espaciado. No usar gradientes grandes, saturados o múltiples
como sustituto de jerarquía visual, especialmente en perfil y formularios.

- Diseño moderno, oscuro y claro.
- Identidad gamer de Tracon con rojo como color principal y tonos profundos de apoyo.
- Diseño minimalista y moderno como criterio por defecto.
- Respetar `ThemeMode.system` salvo decisión explícita del producto.
- Centralizar colores, espaciados, radios y tipografía en el tema.
- Mantener animaciones fluidas, modernas y sobrias entre vistas, evitando efectos pesados que retrasen el primer frame.
- Comunicar comunidad gamer, retos, juegos, rankings y progreso; no introducir textos o iconografía de transporte por copiar una referencia visual.
- El inicio post-login debe sentirse como una red social gamer, oscura y misteriosa: feed vertical de clips con pestañas superiores simples Para ti/Siguiendo/Radar y metadatos mínimos.
- La navegación inferior del MVP debe priorizar Inicio, Chats, Crear, Traks y Perfil. Traks reserva los videos cortos y puede mostrar un estado de próximamente; Radar vive como pestaña superior del feed para descubrimiento sin duplicar navegación.
- No usar emojis en la interfaz ni en textos de producto; usar iconos de Material, Lucide o assets propios.
- Feed = contenido limpio; Perfil = identidad y reputación; Retos = participación; Logros = recompensa; Impulso = posicionamiento real.
- En el feed principal mostrar solo usuario, título, descripción corta, un tipo de contenido, máximo 2 o 3 hashtags y acciones laterales. No mostrar XP, puntos, insignias, ranking, racha, nivel de miedo constante ni demasiadas categorías.
- En el MVP las pestañas superiores del feed deben ser Para ti, Siguiendo y Radar. Retos y Comunidades pertenecen a vistas dedicadas salvo justificación futura.
- El sistema de reputación visual debe priorizar Impulsos recibidos sobre XP genérico. Evitar barras de XP en perfil principal.
- Impulso es el nombre funcional recomendado para el like especial limitado; se representa con icono de rayo, inicia con 3 usos diarios en el MVP visual y debe mostrarse sin saturar.
- El botón de Impulso en feed debe usar estado normal tipo outline: círculo sin fondo, borde visible e icono de rayo más grande. Al activarse puede usar relleno coral sólido con sombra sobria, evitando fondos translúcidos fuertes o saturación de color.
- El splash animado de Flutter solo debe aparecer en el primer arranque posterior a la instalación.
- Los siguientes ingresos deben priorizar el splash nativo para reducir tiempo perceptible de apertura.
- El onboarding debe mostrarse solo una vez por instalación, salvo que producto pida reactivarlo.
- El welcome debe usar el nombre `Tracon`, no `Tracon Games`.
- Accesibilidad.
- Estados de carga con shimmer.

Los estados de carga de contenido (feed, listas, tarjetas, perfiles, medios y
secciones que ocupan una vista) deben usar siempre un shimmer minimalista que
reproduzca de forma sobria la estructura final y ocupe el área de contenido
completa. El skeleton no puede ser un conjunto genérico de barras: debe copiar
la jerarquía, densidad, espaciado y proporciones del componente real. Por
ejemplo, un post debe reflejar avatar, cabecera, cuerpo, metadatos y acciones;
una tarjeta de media debe reflejar su relación de aspecto; y un perfil sus
bloques principales. En Flutter reutilizar `AppShimmer` o un componente
compartido equivalente, usando colores del tema; no introducir paquetes,
paletas locales, animaciones pesadas ni pantallas de carga genéricas con un
spinner centrado. Los indicadores circulares compactos solo se permiten para
acciones breves y locales, como un botón al enviar o la inicialización de un
reproductor.
- Estados vacíos.
- Errores accionables.
- Confirmación en acciones irreversibles.
- Feed fluido.
- Video sin autoplay agresivo.
- No esconder controles de bloqueo y reporte.
- No usar patrones engañosos.
- No forzar permisos antes de necesitarlos.

---

---

# 48. REGLA DE PERMISOS MÓVILES

Solicitar permiso solo en contexto.

Para fotos y videos en Android moderno, preferir el selector del sistema o permisos granulares actuales (`READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`) solo cuando el flujo realmente lo necesite. No solicitar almacenamiento amplio ni permisos heredados si no son necesarios para Play Store.

Cuando se agregue:

- Cámara.
- Micrófono.
- Galería.
- Notificaciones.
- Ubicación.

se debe revisar:

- AndroidManifest.
- Info.plist.
- Texto mostrado.
- Términos.
- Privacidad.
- Documentación.
- Flujo de denegación.
- Configuración del sistema.

---

---

# 52.1 ACCESIBILIDAD VISUAL Y UTF-8 EN COMPONENTES

Todo componente visual reutilizable debe elegir sus colores de texto, iconos y
estados a partir de `ColorScheme` y sus pares `on*`; no se permite usar texto
gris de bajo contraste sobre fondos de estado. Los `SnackBar`, diálogos,
campos, botones y mensajes de validación deben verificarse en tema claro y
oscuro, con contraste suficiente y sin depender únicamente del color.

Antes de cerrar cambios en Flutter, Java o plantillas de correo se debe revisar
la codificación UTF-8 del contenido visible. Se deben corregir secuencias
mojibake (caracteres corruptos por codificación incorrecta) y no sustituir tildes, eñes o signos de apertura por
equivalentes ASCII en los textos en español. Las validaciones deben mostrar sus
mensajes correctos desde la primera interacción.
