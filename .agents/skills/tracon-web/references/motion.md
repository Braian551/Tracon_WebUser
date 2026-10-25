# Motion web

- Centraliza duraciones y curvas en tokens `--motion-*` y `--ease-*`.
- Prioriza `transform` y `opacity`; evita animar dimensiones o posición continua.
- Reserva reveal para hero y secciones importantes; el contenido parte visible si
  JavaScript no se ejecuta.
- Los hovers nunca son la única señal de interacción.
- No uses scroll-jacking, parallax agresivo ni movimiento decorativo permanente.
- Con `prefers-reduced-motion: reduce`, desactiva smooth scroll, reveals,
  transforms y retrasos sin ocultar contenido.

## Estándar obligatorio de transiciones de pantalla y modales

Todo componente o flujo con intercambio de vistas, sub-pantallas, modales o selectores
(como notificaciones, creación de comunidad, selector de juegos y cambio de tabs) debe
cumplir la siguiente estructura canónica para garantizar suavidad fluida sin saltos ni
expansiones de altura:

### 1. Parámetros de animación
- **Curva**: `cubic-bezier(0.23, 1, 0.32, 1)` (`--ease-out`).
- **Duración**: `240ms` - `260ms`.
- **Propiedades**: Solo `opacity` y `transform` (GPU accelerated).
- **Entrada (`enter-from`)**: `opacity: 0; transform: translateY(10px–12px) scale(0.995);`
- **Salida (`leave-to`)**: `opacity: 0; transform: translateY(-8px–10px) scale(0.995);`

### 2. Estabilidad de layout y anclaje absoluto
Para evitar que el contenedor colapse a 0px y luego se expanda violentamente:
- El contenedor padre debe tener dimensiones fijas (`h-full` o `h-[calc(...)]`) con `relative overflow-hidden`.
- La clase de salida (`leave-active`) debe anclarse absolutamente:
```css
.view-slide-leave-active {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.view-slide-enter-active {
  z-index: 10;
}
```

### 3. Accesibilidad obligatoria
```css
@media (prefers-reduced-motion: reduce) {
  .view-slide-enter-active,
  .view-slide-leave-active {
    transition: opacity 120ms ease;
    transform: none;
  }
}
```
