# Arquitectura del sitio web

## Estructura canónica

```text
src/
├── assets/         # imágenes, íconos y recursos estáticos
├── components/     # componentes modulares y reutilizables
│   ├── common/     # botones, inputs, modales, cards
│   └── layout/     # navbar, footer, sidebar
├── data/           # datos, modelos o configuración
├── views/          # vistas / páginas principales
├── types/          # interfaces y tipos TypeScript
└── styles/         # configuración y utilidades Tailwind / CSS
```

La web utiliza **Vue.js 3**, **TypeScript** y **Tailwind CSS**, empaquetada con **Vite**. La arquitectura se basa en componentes modulares reutilizables.

## Dispatch de producción

Nginx sirve `web/current/dist` únicamente para `/`, rutas públicas conocidas,
assets y archivos SEO. Las ubicaciones de `/api/`, `/ws/`, `/actuator/` y los
POST de `/account/delete/` se declaran antes del fallback. Las rutas no-web se
mantienen proxyadas a Spring Boot para no convertir una ruta backend en una
respuesta SPA accidental.

## Diseño

La fuente ejecutable del diseño web vive en `web/src/styles/tokens.css` y sus
consumidores. Una tarea exclusivamente web no inspecciona implementaciones de
otros clientes para reconstruir tokens; conserva el lenguaje comprobado en la
web y las referencias compartidas que el usuario haya autorizado.

## Patrones aplicados

- `Adapter` conceptual en el flujo de eliminación: la UI web consume los
  endpoints HTML existentes del backend sin duplicar la lógica de lifecycle.
- Composición por páginas y componentes directos; no se agrega una capa de
  estado global ni un wrapper para cada elemento.

La alternativa directa considerada fue enviar el formulario al backend y
mostrar su template. Se eligió una pequeña adaptación cliente para conservar la
experiencia visual web sin mover la autoridad de eliminación fuera de Spring.
