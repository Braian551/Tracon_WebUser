# Formato portable de agentes

## Núcleo recomendado

```text
AGENTS.md
.agents/
└── skills/
    └── nombre-skill/
        ├── SKILL.md
        ├── references/
        └── scripts/
```

## Frontmatter

Para máxima compatibilidad, usa solamente:

```yaml
---
name: nombre-skill
description: Descripción específica de cuándo debe activarse.
---
```

El nombre debe coincidir con el directorio, usar minúsculas, números y guiones simples.

## Dependencias entre skills

No existe una llamada programática universal entre herramientas. Expresa coordinación mediante una sección `Skills compañeras` que indique condiciones exactas. El agente carga la compañera con el mecanismo disponible en su herramienta.

## Archivos específicos de proveedor

No son parte del núcleo. Si se necesitan, colócalos en `adapters/<proveedor>/` como ejemplos opcionales. Las reglas esenciales nunca deben depender de esos archivos.

## Proyecto frente a configuración global

Las reglas de Tracon son específicas del repositorio y deben vivir en su raíz. La configuración global del usuario debe contener solo preferencias personales válidas para todos sus proyectos.

OpenCode reconoce `AGENTS.md` de proyecto y `.agents/skills`; también admite ubicaciones globales propias. Otras herramientas pueden requerir un adaptador, enlace simbólico o configuración adicional. No existe garantía universal para todas las herramientas.
