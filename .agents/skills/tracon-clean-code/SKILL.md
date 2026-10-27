---
name: tracon-clean-code
description: Elimina proactivamente código muerto, huérfano y obsoleto en Tracon. Cuando un componente, botón o flujo cambia de acción o se reemplaza, purga de inmediato modales, métodos, reactividad, estilos e imports sin uso.
---

# Tracon Clean Code

## Propósito

Garantizar una base de código limpia, minimalista y sin residuos técnicos en Tracon. Todo código que deje de ser utilizado tras una refactorización, cambio de diseño o cambio de comportamiento de un botón o elemento interactivo debe ser eliminado en la misma iteración.

---

## Directivas Obligatorias de Eliminación de Código Muerto

### 1. Acciones Reemplazadas o Modificadas
- Si un botón o control cambia de comportamiento (por ejemplo, pasaba de abrir un modal a ejecutar una acción directa en un campo de texto):
  - **Eliminar el modal asociado** del `<template>` si ya no tiene otro punto de entrada.
  - **Eliminar las variables reactivas de control** (ej. `isModalOpen`, `searchQuery`, arrays auxiliares).
  - **Eliminar los manejadores y métodos auxiliares** (ej. `openModal`, `insertTag`, etc.).
  - **Eliminar los iconos y dependencias importadas** que solo eran requeridos por esa sección descartada.

### 2. Prohibición de Código Comentado
- Nunca dejes bloques de código comentados *"por si acaso se vuelven a necesitar"*.
- El historial de Git (`git log` / `git diff`) es la única fuente de versiones pasadas. Si un bloque de código ya no se ejecuta, se borra por completo.

### 3. Purga Estricta de Reactividad e Imports
- **Imports**: Ningún archivo debe conservar imports huérfanos de librerías (ej. `lucide-vue-next`, `vue`, etc.).
- **Props y Emits**: Eliminar props y eventos `emit` declarados que hayan dejado de emitirse o escucharse.
- **Computed y Watchers**: Si una propiedad computada o watcher observaba estado eliminado, debe ser removido de inmediato.

### 4. Estilos y Clases CSS Huérfanas
- En bloques `<style scoped>`, eliminar cualquier clase CSS o animación que ya no sea referenciada en el `<template>`.
- Evitar clases Tailwind redundantes en elementos que perdieron su interacción.

### 5. Criterio de Finalización
- Todo cambio que modifique el flujo de un botón debe incluir la limpieza completa de los componentes huérfanos resultantes.
- Ejecutar verificación de tipos y compilación limpia (`vue-tsc -b && vite build`) para confirmar que no existen advertencias de código o tipos no resueltos.

