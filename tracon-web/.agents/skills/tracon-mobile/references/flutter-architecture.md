# Flutter: arquitectura, capas, componentes y rendimiento

Referencia detallada para estructura Flutter, separación por capas, tema, shimmer, formularios y rendimiento.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 7. ESTRUCTURA FLUTTER OBLIGATORIA

## 7.1 Enfoque

Flutter debe organizarse por módulos funcionales y capas.

No crear toda la aplicación dentro de:

```text
lib/screens/
lib/pages/
lib/services/
```

sin separación de dominio.

## 7.2 Árbol recomendado

```text
mobile/lib/
├── main.dart
├── bootstrap.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   ├── route_guards.dart
│   │   └── route_names.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   └── app_shadows.dart
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── environment.dart
│   │   └── feature_flags.dart
│   └── lifecycle/
│       └── app_lifecycle_observer.dart
├── core/
│   ├── constants/
│   ├── errors/
│   │   ├── app_exception.dart
│   │   ├── failure.dart
│   │   └── error_mapper.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   ├── auth_interceptor.dart
│   │   ├── retry_policy.dart
│   │   └── network_info.dart
│   ├── storage/
│   │   ├── secure_storage.dart
│   │   ├── local_preferences.dart
│   │   └── cache_store.dart
│   ├── security/
│   │   ├── token_manager.dart
│   │   └── session_manager.dart
│   ├── timezone/
│   │   ├── device_timezone_service.dart
│   │   └── date_time_formatter.dart
│   ├── media/
│   │   ├── media_picker_service.dart
│   │   ├── upload_manager.dart
│   │   └── hls_player_controller.dart
│   ├── utils/
│   ├── extensions/
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── app_dialog.dart
│       ├── app_loader.dart
│       ├── app_error_view.dart
│       ├── app_empty_state.dart
│       ├── app_avatar.dart
│       └── verification/
│           ├── verification_code_input.dart
│           ├── verification_code_timer.dart
│           └── verification_code_section.dart
├── shared/
│   ├── models/
│   ├── widgets/
│   ├── controllers/
│   └── mappers/
└── modules/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── dto/
    │   │   ├── mappers/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── controllers/
    │       ├── pages/
    │       └── widgets/
    ├── profile/
    ├── games/
    ├── challenges/
    ├── submissions/
    ├── votes/
    ├── leaderboard/
    ├── social/
    ├── moderation/
    ├── notifications/
    ├── media/
    ├── legal/
    └── settings/
```

## 7.2.1 Regla para integraciónes externas en Flutter

Cuando se agreguen integraciónes externas como Firebase, Google Sign-In, notificaciones, analítica o proveedores de autenticación:

- Mantener la estructura modular existente.
- Colocar acceso a SDKs y proveedores en `modules/{modulo}/data/datasources/` o en `core/` solo si realmente es transversal.
- Mantener widgets y pantallas en `modules/{modulo}/presentation/`.
- No llamar SDKs externos directamente desde widgets salvo prototipos explícitos y temporales.
- No versionar archivos locales sensibles o de entorno como `google-services.json`, `GoogleService-Info.plist`, `.firebaserc`, `firebase.json` o `firebase_options.dart` si contienen configuración del proyecto real.
- Documentar la dependencia y el motivo en `docs/dependencies/`.

## 7.3 Responsabilidades por capa

### `data`

Contiene:

- DTOs.
- Acceso remoto.
- Acceso local.
- Implementaciones de repositorios.
- Mapeadores.

No contiene reglas visuales.

### `domain`

Contiene:

- Entidades.
- Contratos de repositorio.
- Casos de uso.
- Reglas de negocio independientes de Flutter.

No importa widgets, `BuildContext` ni librerías de interfaz.

### `presentation`

Contiene:

- Páginas.
- Widgets del módulo.
- Estado de presentación.
- Controladores de UI.

No ejecuta SQL ni conoce detalles de almacenamiento del backend.

## 7.4 Regla de componentes globales

Antes de crear un widget nuevo, revisar si existe uno reutilizable.

Componentes globales obligatorios:

- Botones.
- Campos.
- Diálogos.
- Cargadores (shimmer).
- Estado vacío.
- Estado de error.
- Avatar.
- Shimmer (`AppShimmer`, `AppShimmerList`).
- Selector de medios.
- Reproductor HLS.
- Verificación por código de correo.
- Contador para reenvío de código.
- Tarjeta de publicación.
- Tarjeta de reto.
- Tarjeta de usuario.
- Confirmación de acciones sensibles.

## 7.5 Prohibición de widgets gigantes

Una página no debe concentrar:

- Peticiones HTTP.
- Transformaciones de datos.
- Validaciones.
- Navegación.
- Renderizado de listas.
- Manejo de video.
- Estado de formularios.
- Diálogos.
- Lógica de negocio.

Cuando un archivo crezca o mezcle responsabilidades, se debe separar por intención.

Guía de revisión:

- Más de 300 a 400 líneas en un archivo de UI requiere revisión.
- Un método `build()` difícil de leer debe dividirse.
- Un widget reutilizable no debe quedar anidado como método privado si puede vivir en archivo propio.
- La lógica de estado no debe quedar dentro de widgets puramente visuales.

Estas cifras son señales de revisión, no autorización para crear archivos mal diseñados por debajo del límite.

## 7.6 Tema global

Toda interfaz debe usar:

```dart
Theme.of(context)
ColorScheme
TextTheme
```

Los colores de marca deben declararse en:

```text
app/theme/app_colors.dart
```

El color principal de Tracon es rojo vivo (`#E21D3A` en claro y `#FF405A` en oscuro) y debe declararse en tokens globales compatibles con tema claro y oscuro.

No usar colores hardcoded en módulos salvo casos excepcionales documentados.

Debe existir:

- Tema claro.
- Tema oscuro.
- Contraste suficiente.
- Espaciados globales.
- Radios globales.
- Tipografía global.
- Estados de error, éxito, advertencia e información.
- Compatibilidad con texto escalado.
- Responsive móvil.

## 7.8 Colores de marca

El color principal de Tracon es el **rojo**.

- Tema claro: `#E21D3A` como semilla de `ColorScheme.fromSeed`.
- Tema oscuro: `#FF405A` como semilla de `ColorScheme.fromSeed`.
- Los fondos deben permanecer neutros y profundos; evitar contenedores marrón o vino opaco que resten intensidad al rojo principal.
- Se permiten tonos profundos como negro, carbón y rojo vino para dar profundidad visual sin reemplazar el rojo principal.
- Blanco y negro según el tema para fondos y texto base.
- Declarar todos los colores de marca en `app/theme/app_colors.dart`.
- No usar colores hardcoded en módulos salvo casos excepcionales documentados.

## 7.9 Carga con shimmer

Toda carga de contenido asíncrono en la interfaz debe usar **shimmer** como estado de carga visual predeterminado.

- Usar el widget `AppShimmer` ubicado en `core/widgets/app_shimmer.dart`.
- Variantes disponibles: `AppShimmer.circle` para avatares, `AppShimmer.text` para líneas de texto, `AppShimmerList` para listas.
- El `AppLoader` debe usarse con `useShimmer: true` por defecto.
- El CircularProgressIndicator queda reservado exclusivamente para acciones en curso (enviar formulario, procesar), no para carga de contenido estático.
- El shimmer debe adaptarse al tema claro y oscuro automáticamente.

## 7.9.1 Validaciones de formulario en tiempo real

Todo formulario Flutter debe validar en tiempo real desde la primera interacción
del usuario. Los campos deben mostrar formato, obligatoriedad, coincidencia de
contraseñas y reglas locales mediante `AutovalidateMode.onUserInteraction` o
un mecanismo equivalente. Las validaciones que dependen del servidor, como
unicidad de usuario o correo, deben ejecutarse con *debounce*, mostrar estado
de carga/error/disponibilidad y conservar la validación final en backend como
autoridad. No reservar los errores de un formulario para el botón de enviar.

## 7.7 Rendimiento Flutter

Obligatorio:

- Usar `const` cuando sea posible.
- Usar listas perezosas.
- No ejecutar HTTP dentro de `build()`.
- No decodificar videos o imágenes pesadas en el hilo de UI.
- Cancelar timers, streams y controladores.
- No cargar MP4 completo.
- Usar miniaturas.
- Paginar feed y rankings.
- Usar caché con límites.
- Evitar reconstrucciones globales.
- No guardar tokens en preferencias no seguras.
- No imprimir secretos ni tokens en consola.

---

## 7.10 Cámara de Trak — portrait-first obligatorio

La captura interna de Trak (pantalla TrakCameraPage) debe diseñarse **portrait-first**: el preview debe llenar la región vertical disponible del creator viewport, sin grandes bandas negras horizontales y sin distorsión.

Reglas duras:

- Usar `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])` mientras TrakCameraPage esté activa; restaurar `DeviceOrientation.values` al salir del `dispose`. El lock de orientación es necesario pero **no es prueba suficiente**.
- Tras `CameraController.initialize()`, llamar a `controller.lockCaptureOrientation(DeviceOrientation.portraitUp)` para fijar la orientación del archivo grabado.
- Renderizar el preview con `BoxFit.cover` (no `BoxFit.contain`/`BoxFit.fitWidth`), preservando el `aspectRatio` de la preview visible. Nunca estirar la imagen. `rawPreviewSize` y `displayPreviewSize` no son el mismo dato: en la versión instalada, `CameraPreview` ya aplica `1 / controller.value.aspectRatio` en portrait y la rotación correspondiente. El helper `CameraPreviewLayout.buildPortraitPreview` (`lib/modules/posts/presentation/widgets/camera_preview_layout.dart`) debe escalar con COVER usando el ratio display, sin imponer `SizedBox(width: previewSize.width, height: previewSize.height)` sobre la textura RAW.
- No agregar `Transform.rotate` ni `RotatedBox` alrededor del helper solo por `sensorOrientation`: `CameraPreview` y `camera_android_camerax` ya coordinan la rotación de la textura. La transformación de Tracon debe ser únicamente uniforme y de crop; front y back comparten la misma regla geométrica.
- Para el sensor landscape típico (1280×720 o 1920×1080) en dispositivo portrait, registrar por separado `rawPreviewSize`, `sensorOrientation`, `captureOrientation`, `displayPreviewAspectRatio` y `viewportSize`. Los tests matemáticos verifican escala uniforme, pero no sustituyen la validación de la textura nativa.
- El grabador de video debe escribir metadatos de orientación correctos; el editor posterior (`trak_upload_page.dart`) lee el tamaño rotado con `VideoPlayerController.value.size` y eso se mantiene como `width`/`height` del `TrakSourceVideo`. Si la captura es portrait, `width < height`.
- Reescribir el widget de preview sin probar físicamente equivale a no haberlo hecho. La validación final del usuario debe confirmar: pantalla vertical, sin barras negras horizontales grandes, archivo grabado reproducible vertical sin rotación de 90° en players estándar.
- La validación física de la textura queda pendiente hasta probar el dispositivo real; no declarar corregida la cámara solo porque `coverRect` o los tests de layout pasen.

Prohibido:

- Tratar `SystemChrome.setPreferredOrientations` como prueba de verticalidad visual o de archivo.
- Usar `Stretch`, `FittedBox(BoxFit.fill)` o `AspectRatio` que estire.
- Copiar la receta exacta del plugin sin verificar `previewSize` y `sensorOrientation` para la cámara actual.

---
