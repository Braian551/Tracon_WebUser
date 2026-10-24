---
name: tracon-ux-copy
description: Revisa y escribe copy visible para usuarios de la web de Tracon: marketing, navegación, botones, formularios, errores, ayudas, soporte y explicaciones legales.
---

# Tracon UX Copy

## Alcance

En tareas web, esta skill revisa exclusivamente copy en `web/`. No autoriza
inspeccionar ni modificar otros clientes o capas técnicas.

## Regla principal

El usuario nunca debe necesitar entender la arquitectura técnica para entender
una pantalla.

## Flujo

1. Identifica audiencia, intención, acción principal, estado y límite real.
2. Comprueba el comportamiento existente antes de prometer plazos o resultados.
3. Escribe frases breves, concretas y accionables en español natural.
4. Revisa consistencia entre navegación, CTA, formularios, errores y ayuda.
5. Ejecuta `npm run check:copy` y corrige cada hallazgo accidental.

## Reglas

- Explica qué ocurrió y qué puede hacer la persona; omite diagnósticos internos.
- No muestres protocolos, códigos de transporte, componentes, bases de datos,
  proveedores o despliegues salvo cuando una política los necesite legítimamente.
- No conviertas incertidumbre en una promesa. Usa “Próximamente” sin fecha o enlace
  cuando todavía no exista publicación confirmada.
- Los errores no culpan al usuario y conservan la voz del resto del sitio.
- No pidas contraseñas, códigos ni información innecesaria por soporte.
- El contenido legal mantiene precisión, pero limita terminología obligatoria a su
  sección pertinente.

## Ejemplos

MAL: “Error del backend.”  
BIEN: “No pudimos completar la solicitud.”

MAL: “HTTP 409.”  
BIEN: “Este nombre ya está en uso.”

MAL: “Servidor no disponible.”  
BIEN: “No pudimos conectarnos. Intenta de nuevo.”

MAL: “El backend te muestra la fecha efectiva.”  
BIEN: “Te mostraremos la fecha en que la eliminación será definitiva.”

## Cierre

- Comprueba jerga accidental, textos largos, CTAs ambiguos y estados sin salida.
- Verifica el copy en escritorio y móvil, incluyendo errores y contenido dinámico.
- Reporta excepciones legales permitidas por el checker sin normalizar su uso fuera
  de páginas legales.
