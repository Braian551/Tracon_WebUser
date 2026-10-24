# Validación focalizada de Flutter

## Orden predeterminado

```powershell
dart format --set-exit-if-changed <archivos_modificados>
flutter analyze <archivos_modificados_y_consumidores>
flutter test <pruebas_relacionadas>
```

Usa análisis completo solamente cuando el cambio sea transversal, cambie dependencias globales, navegación o tema compartido, o no pueda delimitarse con seguridad.

## Revisión manual adicional

- Imports y símbolos reales.
- Parámetros obligatorios, callbacks, tipos y nulabilidad.
- `mounted` después de asincronía y `dispose` de controladores.
- Rutas, guards, argumentos y constructores.
- Assets declarados en `pubspec.yaml`.
- Estados de carga, error, vacío y éxito.
- `Expanded`, `Flexible`, scrollables, teclado, textos largos y overflow.
- Tema claro/oscuro y escalado de texto.

Para el protocolo completo ante herramientas bloqueadas, usa `$tracon-quality` y lee `references/tool-blockages.md`.
