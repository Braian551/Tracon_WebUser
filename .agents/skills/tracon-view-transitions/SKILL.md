---
name: tracon-view-transitions
description: Define e implementa el estándar obligatorio de micro-animaciones y transiciones de pantalla, sub-vistas, pestañas y modales en Tracon. Garantiza que ningún cambio de apartado ocurra de manera estática o instantánea.
---

# Tracon View Transitions

## Propósito

Garantizar la identidad visual fluida, pulida y gamer de Tracon. En la aplicación web de Tracon, **ninguna transición entre pantallas, sub-vistas, apartados o pestañas debe ocurrir de forma estática o instantánea**.

---

## Directivas Obligatorias de Transición

### 1. Regla de Oro
- Cada vez que un usuario interactúe con un botón que reemplace la vista actual por una nueva sección (ej. cambiar a *Crear encuesta*, abrir *Información del grupo*, navegar entre *Chats/Comunidades*, o alternar pestañas como *Publicación / Trak*), se debe envolver el contenido en un componente `<Transition mode="out-in">` con animación fluida.

### 2. Parámetros Canónicos de Movimiento

| Tipo de cambio | Nombre de clase | Duración | Curva Bézier | Transformación |
| :--- | :--- | :--- | :--- | :--- |
| **Pantallas completas y sub-vistas** | `view-slide` / `fade-view` | `240ms` - `260ms` | `cubic-bezier(0.23, 1, 0.32, 1)` | `translateY(10px) scale(0.995)` → `translateY(-8px)` |
| **Pestañas y sub-tabs internas** | `tab-fade` | `180ms` - `200ms` | `cubic-bezier(0.23, 1, 0.32, 1)` | `translateY(4px)` → `translateY(-4px)` |
| **Modales y popovers flotantes** | `modal-fade` | `200ms` - `220ms` | `cubic-bezier(0.23, 1, 0.32, 1)` | `scale(0.98)` + `opacity` |

### 3. Aceleración por GPU y Rendimiento
- **Propiedades animables**: Únicamente `opacity` y `transform`.
- **Nunca animar**: `width`, `height`, `top`, `left`, `margin` o `padding` continuos (provocan layout recalculations costosos).
- **GPU Hint**: Añadir `will-change: opacity, transform;` en estados activos.

### 4. Estabilidad del Contenedor
- El contenedor raíz debe poseer dimensiones estables (`relative overflow-hidden flex flex-col h-full`) para evitar colapsos visuales o saltos bruscos del scrollbar durante el reemplazo `out-in`.

### 5. Accesibilidad Obligatoria
- Toda transición debe respetar la directiva de accesibilidad `prefers-reduced-motion: reduce`:
```css
@media (prefers-reduced-motion: reduce) {
  .view-slide-enter-active,
  .view-slide-leave-active,
  .tab-fade-enter-active,
  .tab-fade-leave-active {
    transition: opacity 120ms ease;
    transform: none;
  }
}
```

---

## Implementación Estándar en Vue 3

```vue
<!-- Template -->
<div class="relative flex-1 overflow-hidden flex flex-col">
  <Transition name="view-slide" mode="out-in">
    <SubViewOne v-if="isSubViewActive" key="sub-view-one" />
    <SubViewTwo v-else key="sub-view-two" />
  </Transition>
</div>

<!-- Scoped Styles -->
<style scoped>
.view-slide-enter-active,
.view-slide-leave-active {
  transition: opacity 240ms cubic-bezier(0.23, 1, 0.32, 1), transform 240ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.view-slide-enter-from {
  opacity: 0;
  transform: translateY(10px) scale(0.995);
}

.view-slide-leave-to {
  opacity: 0;
  transform: translateY(-8px) scale(0.995);
}
</style>
```

