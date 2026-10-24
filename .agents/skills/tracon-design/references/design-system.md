# Sistema visual de Tracon

## Fuentes ejecutables

Antes de modificar estilos, inspecciona:

- `mobile/lib/app/theme/app_colors.dart`
- `mobile/lib/app/theme/app_theme.dart`
- `mobile/lib/app/theme/app_theme_tokens.dart`
- `mobile/lib/app/theme/app_typography.dart`
- `mobile/lib/app/theme/app_spacing.dart`
- `mobile/lib/app/theme/app_radius.dart`
- `mobile/lib/app/theme/app_shadows.dart`

El código versionado es la fuente ejecutable. Este documento define intención y reglas de uso.

## Identidad

Tracon es una red social gamer orientada a terror, suspenso, misterio, retos y comunidad. La experiencia debe sentirse intensa, moderna y competitiva sin convertirse en una interfaz saturada, caricaturesca o difícil de leer.

## Color

- Color principal claro: rojo vivo `#E21D3A`.
- Color principal oscuro: rojo vivo `#FF405A`.
- Fondos: neutros, negros, carbón y superficies profundas.
- Tonos vino pueden aportar profundidad, pero no reemplazan el rojo principal.
- Evita fondos marrón o vino opaco dominantes.
- Estados de éxito, advertencia, error e información deben provenir del tema.
- No uses color como único indicador de estado.

Cuando los valores reales de los tokens cambien mediante una decisión aprobada, actualiza este documento en la misma tarea.

## Tipografía y jerarquía

- Prioriza legibilidad sobre decoración.
- Usa `TextTheme` y tokens tipográficos.
- Títulos, autor, tiempo, contenido y acciones deben tener jerarquía distinguible.
- Evita exceso de mayúsculas, pesos extremos o tamaños fijos que fallen con escalado.

## Espaciado, radios y sombras

- Usa tokens existentes.
- Mantén ritmo consistente entre pantallas.
- Radios y sombras deben expresar jerarquía, no decorar cada bloque.
- Evita tarjetas dentro de tarjetas.

## Componentes globales

Revisa antes de crear:

- Botones y campos.
- Diálogos y snackbars.
- Shimmer y estados de carga.
- Estados vacío/error.
- Avatar.
- Verificación segmentada.
- Tarjetas o filas de contenido.
- Selectores y reproductores multimedia.

Un componente se vuelve global cuando es reutilizado por varios módulos o representa un patrón estable. No globalices piezas de una sola pantalla prematuramente.
