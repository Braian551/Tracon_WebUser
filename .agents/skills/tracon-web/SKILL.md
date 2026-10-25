---
name: tracon-web
description: Diseña e implementa la interfaz visual web de Tracon con Vue.js, TypeScript y Tailwind CSS: arquitectura modular basada en componentes reutilizables, diseño responsive, accesibilidad y temas.
---

# Tracon Web

## Autoridad y alcance

Esta skill coordina la interfaz y experiencia web de Tracon.

**Directivas obligatorias de desarrollo:**
1. **Stack Técnico**: Frontend visual desarrollado con **Vue.js 3** (Composition API con `<script setup>`), **TypeScript** y **Tailwind CSS**.
2. **Modularidad y Reutilización**: Todo el código debe ser modular y dividido en componentes reutilizables (inputs, botones, tarjetas, modales, layouts) para evitar duplicación.
3. **Ámbito Web Estricto**: **Tracon-web tasks MUST NOT inspect, execute, modify or validate Flutter/mobile unless the user explicitly requests mobile work.** No uses Flutter, ADB, emuladores, APK ni archivos de `mobile/`.

## Skills compañeras

- `tracon-ux-copy`: botones, etiquetas, errores, formularios, marketing o ayudas
  legales visibles.
- `tracon-design`: identidad o reglas visuales compartidas documentadas fuera de
  implementaciones no autorizadas.
- `tracon-product`: cambios funcionales o legales que necesiten una decisión de
  producto, no para editar presentación ya aprobada.
- `tracon-infrastructure`: Nginx, VPS, TLS, rutas productivas o releases.
- Entrega Web independiente: `web/deploy/README.md`; usa `tracon-infrastructure`
  para la instalación SSH y transición expresamente autorizadas.
- `tracon-quality`: auditoría transversal o validación final amplia.
- `tracon-agent-rules`: cambios en esta skill o sus referencias.

No cargues `tracon-mobile` para una web que no modifica el producto móvil.

Registra el cambio con `../tracon-change-contract/SKILL.md` y la política
`../tracon-agent-rules/references/change-contract-policy.md`. El contrato no autoriza producción; la entrega Web sigue `web/deploy/README.md`.

## Inicio

1. Inspecciona `web/`, assets web, documentación estrictamente web y, si aplica,
   la configuración dedicada de Nginx y el release publicado.
2. Audita la experiencia real en navegador antes de continuar decisiones previas.
3. Verifica que cada función anunciada exista; no inventes tiendas, redes,
   métricas, socios ni capacidades.
4. Lee solo las referencias necesarias:
   - `references/web-architecture.md`
   - `references/design-system.md`
   - `references/theme.md`
   - `references/motion.md`
   - `references/responsive.md`
   - `references/accessibility.md`
   - `references/seo-performance.md`
   - `references/legal-content.md`
   - `references/web-deployment.md`

## Reglas de experiencia

- Conserva la identidad oscura, roja/rosa y gamer de Tracon; refínala sin volverla
  una plantilla SaaS, un dashboard o una copia de otra marca.
- Centraliza tokens semánticos y estados de botones, tarjetas, campos y foco.
- Mantén temas `system`, `dark` y `light`; `system` es el valor inicial, sigue los
  cambios del sistema y una preferencia manual persiste con la clave
  **tracon-theme**.
- Resuelve el tema antes del primer paint sin cookies ni dependencias pesadas.
- Diseña el tema claro como parte de la misma marca, no como una inversión ciega.
- Usa composición y storytelling; evita grillas genéricas de tarjetas repetidas.
- Usa `clamp()` con jerarquía contenida y valida 360, 390, 430, 768, 1024, 1280,
  1440 y 1920 px sin overflow.
- Anima principalmente `transform` y `opacity`, con tokens y soporte obligatorio
  para `prefers-reduced-motion`.
- **Regla obligatoria de suavidad y transiciones (Motion Standard)**: Todo cambio
  de pantalla, vista, subapartado, modal o selector (ej. notificaciones,
  creación de comunidad, selector de juegos, cambio de tabs/vistas) debe
  implementar la transición suave continua tipo deslizamiento con crossfade:
  - Curva canónica: `cubic-bezier(0.23, 1, 0.32, 1)` (`--ease-out`).
  - Duración estándar: `240ms` a `260ms`.
  - Propiedades animadas: estrictamente `opacity` y `transform` (`translateY(8px–12px)` a `0` con microescala `0.995` a `1`).
  - Estabilidad de altura y layout: el contenedor padre debe tener dimensiones fijas con `relative overflow-hidden`. Durante la salida (`leave-active`), el elemento saliente debe anclarse absolutamente (`position: absolute; inset: 0; width: 100%; height: 100%; pointer-events: none;`) para eliminar cualquier colapso de altura, salto de layout o expansión brusca. Nunca usar cortes secos ni transiciones que colapsen el contenedor a 0px.
- Apunta a WCAG 2.2 AA razonable sin afirmar certificación: teclado, foco, contraste,
  landmarks, headings, labels, targets y menú móvil accesible.
- El usuario nunca necesita comprender arquitectura técnica para entender una
  pantalla. Aplica `tracon-ux-copy` y el checker de copy web.
- Google Play permanece en configuración con valor nulo hasta que exista un enlace
  público comprobado; el estado “Próximamente” no navega.
- Toda capacidad web autenticada debe tener una entrada visible y coherente
  desde la UI cuando la persona tenga el permiso correspondiente. Ocultar una
  ruta no sustituye la autorización server-side.
- El estado de la navbar autenticada proviene de AuthContext y del bootstrap
  canónico de permisos del backend; nunca se deduce por email, query params o
  flags en localStorage.
- Las rutas de administración y soporte deben ser descubribles para quienes
  tienen permiso, y continuar protegidas por el backend aunque desaparezcan
  del menú.

## Reglas técnicas

- **Arquitectura de componentes**: Utiliza Vue 3 Composition API (`<script setup lang="ts">`), TypeScript estricto y Tailwind CSS para diseño y estilos utilitarios consistentes.
- **Reutilización y modularidad**: Divide las vistas en componentes atómicos (`src/components/ui/` y `src/components/common/`) con props y eventos explícitamente tipados.
- Vite genera archivos estáticos para el bundle; no agregues un proceso Node permanente al VPS ni migres de stack sin necesidad medida.
- Las rutas conocidas se sirven desde `web/current/dist`. `/api/`, `/ws/`,
  `/actuator/`, acciones de eliminación y demás rutas no-web conservan su dueño.
- El fallback SPA nunca precede API, WebSocket, health, acciones públicas o SEO.
- Mantén metadata por ruta, canonical, Open Graph, Twitter/X, `robots.txt`,
  `sitemap.xml`, favicon y datos estructurados solo con hechos comprobados.
- Mantén secretos, URLs firmadas, credenciales, datos personales y diagnósticos
  fuera del bundle y del copy.
- Documenta cada dependencia nueva en `docs/dependencies/web.md`; prefiere CSS y
  APIs del navegador para interacciones sencillas.

Las rutas del sitemap deben ser públicas, canónicas, 200 e indexables; las
rutas legales públicas declaradas a Google Play conservan su URL y metadata
prerenderizada cuando corresponda. La política operativa completa vive en
docs/operations/search-indexing.md.
robots.txt solo orienta crawlers y nunca sustituye autenticación, autorización
o protección de Nginx. No introduzcas hosts de producción inexistentes ni
canonicalices hacia un dominio distinto del canónico.

El portal autenticado usa Firebase Web solo para identidad y el mismo origen
para sus APIs; las pantallas privadas requieren noindex y quedan fuera del
sitemap. La arquitectura y el contrato de permisos están en
docs/architecture/web-admin-portal.md y docs/architecture/rbac.md.

## Cierre

1. Ejecuta `npm ci`, `npm run lint`, `npm test`, `npm run build` y el checker de
   copy (directamente o como parte del lint).
2. Revisa HTML, metadata, enlaces, imágenes, bundle, secretos, foco, temas,
   reduced motion y consola del navegador.
3. Valida en navegador los anchos objetivo y capturas web representativas.
4. Si cambia Nginx, ejecuta `nginx -t` antes de recargar y verifica web, API,
   WebSocket, health, TLS y caché.
5. Reporta versión legal, release web, rollback real y pendientes jurídicos o de
   infraestructura sin afirmar resultados no medidos.
