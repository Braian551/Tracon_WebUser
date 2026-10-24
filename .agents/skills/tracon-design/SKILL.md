---
name: tracon-design
description: Define y aplica el sistema visual y de experiencia de Tracon: identidad gamer de terror/suspenso, tema claro/oscuro, color, tipografía, espaciado, radios, componentes, feed, compositor, estados, responsive, accesibilidad, motion y consistencia. Usar junto con tracon-mobile para implementar UI.
---

# Tracon Design

## Autoridad

Esta es la fuente canónica de reglas visuales y UX. Las skills técnicas no deben duplicar estilos. Los valores ejecutables actuales viven en `mobile/lib/app/theme/`; si documentación y código difieren, inspecciona el código y corrige la fuente que esté desactualizada dentro del alcance autorizado.

## Skills compañeras

Carga solo cuando aplique:

- `tracon-mobile`: obligatorio para implementar o cambiar UI Flutter.
- `tracon-product`: cuando el diseño depende de reglas funcionales, estados, retos, feed, moderación o perfiles.
- `tracon-media`: cuando diseña selector, compositor, carga, progreso, video o reproductor.
- `tracon-agent-rules`: cuando la petición es modificar las reglas del sistema de diseño, no una pantalla.
- `tracon-quality`: para auditoría visual transversal.

## Inicio

1. Inspecciona la pantalla actual, componentes reutilizables y tokens reales.
2. Determina objetivo visual, estados, contenido, anchos, tema y accesibilidad.
3. Lee solo referencias necesarias:
   - `references/design-system.md`
   - `references/ui-patterns.md`
   - `references/design-validation.md`
4. Revisa `mobile/lib/app/theme/`, `mobile/lib/core/widgets/` y componentes del módulo antes de crear otros.

## Reglas

- Los mensajes visibles al usuario no exponen detalles de desarrollo ni infraestructura (API, backend, servicios, túneles, credenciales, excepciones o diagnósticos). Comunican una acción o resultado claro; el detalle técnico se registra solo de forma segura para diagnóstico.
- Mantén identidad propia; las referencias externas son inspiración, no autorización para copiar marca, textos o composición exacta.
- Usa tokens globales; no hardcodees colores, espaciados, radios, sombras o tipografía sin justificación.
- Conserva tema claro y oscuro, contraste, escalado de texto y navegación accesible.
- Prioriza jerarquía limpia, contenido primero y acciones comprensibles.
- La sincronización social no justifica rediseñar la tarjeta: conserva tokens,
  jerarquía y feedback existentes; solo cambia la fuente de los contadores y
  estados para que todas las superficies rendericen la misma proyección.
- En filas de comentarios muestra avatar, `displayName` y contenido como
  jerarquía principal. Username solo aparece en menciones, no como línea
  redundante; el badge `Creador` y los contadores deben sobrevivir nombres
  largos mediante ellipsis y layout flexible.
- Evita tarjetas pesadas, ruido visual y botones sin propósito.
- Diseña estados de carga, vacío, error, éxito, deshabilitado y procesamiento.
- Search debe tener identidad visual propia de Tracon, usar los tokens y
  componentes canónicos, y cubrir discovery, sugerencias, resultados, teclado,
  vacío, error y textos largos; las referencias externas no se copian. El
  invariant del campo canónico está en
  `references/search-field-invariant.md`: no añade filtros automáticamente,
  muestra solo clear con query y no deja espacio, hit target ni semántica
  fantasma.
- En el chat, representa `Enviando`, `Enviado`, `Visto` y fallo/reintento con
  tokens existentes y un único marcador de visto; nunca uses color o icono para
  afirmar lectura sin confirmación server-side. Ver
  `docs/architecture/chat-messaging.md`.
- Cuando muestres disponibilidad de publicación, usa el contrato de límites del
  servidor y copy breve como “2 de 5 publicaciones disponibles hoy”; nunca
  expongas rate limiting, Redis, workers, capacidad interna o códigos técnicos.
- Verifica anchos pequeños, teclado visible, textos largos y contenido dinámico.
- No cambies la identidad visual global por una tarea local sin autorización explícita.

Para el portal operativo conserva una jerarquía densa pero legible, estados de
carga/vacío/error y tablas accesibles; no mezcles navegación privada con la
landing pública. El alcance funcional está en
docs/architecture/web-admin-portal.md.
En la web pública, el estado anónimo debe mostrar entradas visibles de acceso
y registro; el estado autenticado debe mostrar una cuenta operable con avatar,
foco, teclado, Escape y cierre por click fuera. Las entradas de soporte y
administración se descubren desde ese menú solo cuando el permiso server-side
correspondiente está presente.

En onboarding, separa visualmente nombre visible y username, conserva el flujo
de sugerencias y muestra errores accionables. La disponibilidad positiva no
debe convertirse en ruido persistente; el estado disabled/loading y el error
ocupado deben ser suficientes para explicar la acción.

## Cierre

- Compara resultado con tokens y patrones canónicos.
- Revisa responsive, contraste, tema, accesibilidad, estados y consistencia.
- Si se aprobó una nueva regla global, actualiza solo esta skill o su referencia canónica; no la copies a `tracon-mobile` ni `AGENTS.md`.
