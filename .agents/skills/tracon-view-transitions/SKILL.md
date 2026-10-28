---
name: tracon-view-transitions
description: Define e implementa el estándar obligatorio de micro-animaciones y transiciones de pantalla, sub-vistas, pestañas y modales en Tracon. Garantiza que ningún cambio de apartado ocurra de manera estática o instantánea.
---

# Tracon View Transitions

## Propósito

Garantizar la identidad visual fluida, pulida y gamer de Tracon. En la aplicación web de Tracon, **ninguna transición entre pantallas, sub-vistas, apartados o pestañas debe ocurrir de forma estática o instantánea**. Todo cambio de contexto visual debe tener una animación suave con aceleración por GPU.

---

## Directivas Obligatorias de Transición

### 1. Regla de Oro
- Cada vez que un usuario interactúe con un botón, tarjeta o enlace que reemplace la vista actual por una nueva sección, sub-vista o panel (ej. cambiar a *Crear encuesta*, abrir *Información del grupo*, navegar entre *Chats/Comunidades*, cambiar entre *Edición / Sonido / Portada / Portada y datos*, o alternar pestañas como *Publicación / Trak*), se debe envolver el contenido en un componente `<Transition mode="out-in">` con animación fluida.
- **IMPORTANTE (Regla de oro de Vue 3)**: `<Transition>` nunca debe envolver fragmentos `<template v-if>`. Cada vista o sub-vista debe ser un elemento HTML concreto (típicamente `<div v-if="..." :key="...">`) con un atributo `key` único. Sin un elemento con `key`, Vue 3 no ejecuta las transiciones y el cambio ocurre en seco.

---

### 2. Parámetros Canónicos de Movimiento

| Tipo de cambio | Nombre de clase | Duración | Curva Bézier | Transformación |
| :--- | :--- | :--- | :--- | :--- |
| **Pantallas completas y apartados principales** | `view-slide` | `240ms` - `260ms` | `cubic-bezier(0.23, 1, 0.32, 1)` | `translateY(12px) scale(0.995)` → `translateY(-8px)` |
| **Paneles internos y sub-apartados (ej. Sonido, Herramientas)** | `panel-fade` / `tab-fade` | `200ms` - `220ms` | `cubic-bezier(0.23, 1, 0.32, 1)` | `translateY(8px)` → `translateY(-6px)` |
| **Pestañas y sub-tabs internas** | `tab-fade` | `180ms` - `200ms` | `cubic-bezier(0.23, 1, 0.32, 1)` | `translateY(4px)` → `translateY(-4px)` |
| **Modales y popovers flotantes** | `modal-fade` | `200ms` - `220ms` | `cubic-bezier(0.23, 1, 0.32, 1)` | `scale(0.97)` + `opacity` |

---

### 3. Aceleración por GPU y Rendimiento

- **Propiedades animables**: Únicamente `opacity` y `transform`.
- **Nunca animar**: `width`, `height`, `top`, `left`, `margin` o `padding` continuos (provocan recalculaciones costosas de layout/reflow).
- **GPU Hint**: Añadir `will-change: opacity, transform;` en los estados activos.

---

### 4. Estabilidad del Contenedor Raíz

El contenedor padre que envuelve la `<Transition>` debe poseer dimensiones estables para evitar saltos o colapsos de tamaño durante el ciclo `out-in`:
```html
<div class="relative flex-1 overflow-hidden flex flex-col h-full w-full">
  <Transition name="view-slide" mode="out-in">
    ...
  </Transition>
</div>
```

---

### 5. Estilos Canónicos Globales / Scoped

```css
/* Transición entre apartados y pantallas completas */
.view-slide-enter-active,
.view-slide-leave-active {
  transition: opacity 240ms cubic-bezier(0.23, 1, 0.32, 1), transform 240ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.view-slide-enter-from {
  opacity: 0;
  transform: translateY(12px) scale(0.995);
}

.view-slide-leave-to {
  opacity: 0;
  transform: translateY(-8px) scale(0.995);
}

/* Transición entre paneles y sub-vistas internas */
.panel-fade-enter-active,
.panel-fade-leave-active {
  transition: opacity 200ms cubic-bezier(0.23, 1, 0.32, 1), transform 200ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.panel-fade-enter-from {
  opacity: 0;
  transform: translateY(8px);
}

.panel-fade-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

/* Transición para pestañas */
.tab-fade-enter-active,
.tab-fade-leave-active {
  transition: opacity 180ms cubic-bezier(0.23, 1, 0.32, 1), transform 180ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.tab-fade-enter-from {
  opacity: 0;
  transform: translateY(4px);
}

.tab-fade-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

/* Modales y diálogos flotantes */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 200ms cubic-bezier(0.23, 1, 0.32, 1), transform 200ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
  transform: scale(0.97);
}

/* Accesibilidad obligatoria */
@media (prefers-reduced-motion: reduce) {
  .view-slide-enter-active,
  .view-slide-leave-active,
  .panel-fade-enter-active,
  .panel-fade-leave-active,
  .tab-fade-enter-active,
  .tab-fade-leave-active,
  .modal-fade-enter-active,
  .modal-fade-leave-active {
    transition: opacity 120ms ease !important;
    transform: none !important;
  }
}
```

---

### 6. Casos de Uso y Patrones de Implementación

#### Caso A: Navegación entre Apartados Principales
```vue
<div class="relative flex-1 overflow-hidden flex flex-col h-full w-full">
  <Transition name="view-slide" mode="out-in">
    <!-- Apartado 1: Portada -->
    <div v-if="showCoverSelector" key="cover-selector" class="flex-1 flex flex-col h-full overflow-hidden">
      ...
    </div>

    <!-- Apartado 2: Biblioteca de Sonido -->
    <div v-else-if="isPickingMusic" key="music-picker" class="flex-1 flex flex-col h-full overflow-hidden">
      ...
    </div>

    <!-- Apartado 3: Selector de Juego -->
    <div v-else-if="isPickingGame" key="game-picker" class="flex-1 flex flex-col h-full overflow-hidden">
      <GameSelectorView ... />
    </div>

    <!-- Apartado 4: Publicar Trak / Portada y datos -->
    <div v-else-if="showMetadataView" key="metadata-form" class="flex-1 flex flex-col h-full overflow-hidden">
      ...
    </div>

    <!-- Apartado 5: Editor Principal -->
    <div v-else-if="recordedMedia" key="editor-view" class="flex-1 flex flex-col h-full overflow-hidden">
      ...
    </div>

    <!-- Apartado 6: Visor de Grabación -->
    <div v-else key="recorder-view" class="flex-1 flex flex-col h-full overflow-hidden">
      ...
    </div>
  </Transition>
</div>
```

#### Caso B: Sub-apartados y Paneles dentro de un mismo flujo (ej. Editor)
Cuando dentro del editor se cambia de la barra de herramientas al panel de Sonido:
```vue
<Transition name="panel-fade" mode="out-in">
  <div v-if="isEditingSound" key="sound-panel" class="w-full max-w-[420px] ...">
    ...
  </div>
  <div v-else key="timeline-tools-panel" class="w-full max-w-[420px] ...">
    ...
  </div>
</Transition>
```

---

### 7. Checklist de Verificación para Agentes
- [ ] ¿Hay algún cambio de vista usando `<template v-if>` dentro de `<Transition>`? Si lo hay, cámbialo a un `<div v-if="..." :key="...">`.
- [ ] ¿Tienen todos los elementos alternados un `key` único?
- [ ] ¿Está presente el atributo `mode="out-in"` para evitar que ambas vistas coexistan empujando el diseño?
- [ ] ¿Tienen los contenedores `overflow-hidden flex flex-col h-full` para asegurar la estabilidad dimensional?
- [ ] ¿Están definidos los estilos CSS correspondientes con curvas Bézier y GPU acceleration?
