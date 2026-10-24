# Producto: identidad, beta, feed, descubrimiento, salas y roadmap

Referencia para visión, navegación, alcance inicial, recomendaciones, descubrimiento y fases futuras.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 2. IDENTIDAD Y DESCRIPCIÓN DEL PROYECTO

## 2.1 Nombre

```text
Tracon
```

## 2.2 Propietario

```text
VIAX TECHNOLOGY S.A.S.
```

VIAX TECHNOLOGY S.A.S. es la empresa responsable del desarrollo y operación tecnológica de la aplicación.

Antes de publicar la aplicación se deben completar y verificar, como mínimo:

- Razón social exacta.
- NIT.
- Domicilio.
- Correo de contacto.
- Correo de privacidad.
- Canal para peticiones, consultas y reclamos.
- Países donde se prestará el servicio.
- Responsable o área encargada del tratamiento de datos.

No inventar estos datos. Si faltan, deben permanecer como marcadores claramente identificados y su ausencia debe reportarse como bloqueo legal de publicación.

## 2.3 Visión del producto

Tracon será una red social gamer enfocada en videojuegos, retos y comunidad.

La identidad funcional y visual del producto debe comunicar juego, competencia sana, descubrimiento de jugadores, progreso y pertenencia. Las referencias visuales entregadas por el usuario son inspiración de calidad y composición, no una autorización para copiar su dominio de negocio, textos, marca o propósito.

Tracon debe evolucionar como una red social global gamificada para gamers, creadores de contenido, fans del terror, suspenso, misterio, clips, retos y comunidades digitales. No debe limitarse a ser una aplicación exclusiva para un canal de YouTube.

La primera experiencia posterior al inicio de sesión debe priorizar un feed vertical de clips 9:16 enfocado en descubrimiento rápido, sin copiar de forma directa a TikTok, Reels o Shorts. El corazón del producto debe diferenciarse por retos, comunidades, gamificación, contenido gamer, terror, misterio, participación de usuarios y experiencias interactivas.

La pantalla de inicio debe contemplar pestañas superiores simples para el MVP:

- Para ti.
- Siguiendo.
- Radar.

La navegación principal inferior debe contemplar:

1. Inicio.
2. Chats.
3. Crear.
4. Traks (videos cortos; puede mostrar "Próximamente" antes de su entrega).
5. Perfil.

Cada clip o publicación debe modelarse pensando en estos metadatos de producto:

- Usuario creador.
- Descripción.
- Categoría.
- Hashtags.
- Comunidad relacionada.
- Tipo de contenido.
- Nivel de miedo o intensidad.
- Reto asociado, si aplica.
- Likes.
- Comentarios.
- Compartidos.
- Guardados.
- Botón de seguir.
- Reportar contenido.
- Impulsos recibidos por el contenido.

El MVP debe validar primero si los usuarios consumen clips, participan en retos y se unen a comunidades. Evitar pantallas llenas de botones sin propósito o funciones avanzadas que no ayuden a validar ese comportamiento.

La aplicación permitirá progresivamente:

- Crear perfiles.
- Elegir juegos favoritos.
- Encontrar personas que juegan los mismos juegos.
- Crear y participar en retos.
- Publicar evidencia de retos mediante texto, imagen o video.
- Aprobar o desaprobar evidencias.
- Obtener puntos.
- Aparecer en podios y clasificaciones.
- Seguir a otros usuarios.
- Considerar amistad cuando el seguimiento sea mutuo.
- Crear chats entre usuarios autorizados.
- Crear salas relacionadas con juegos.
- Bloquear usuarios.
- Reportar contenido o usuarios.
- Recibir recomendaciones de contenido y retos.
- Incorporar inteligencia artificial en fases futuras.

## 2.4 Objetivo de la beta inicial

La beta NO debe intentar implementar toda la visión de una sola vez.

El alcance inicial obligatorio se limita a:

1. Registro, inicio de sesión y verificación de correo.
2. Perfil básico.
3. Catálogo de juegos.
4. Juegos asociados al perfil.
5. Retos.
6. Retos diarios.
7. Publicaciones o evidencias de retos.
8. Carga de imagen y video.
9. Aprobación y desaprobación.
10. Sistema de puntos.
11. Podios y clasificaciones.
12. Bloqueo y reporte básico.
13. Eliminación programada de cuenta.
14. Términos, privacidad y aceptación versionada.
15. Panel o herramientas mínimas de moderación.

No incluir chat, salas, IA, Neo4j activo ni múltiples microservicios en la primera entrega salvo que exista una necesidad técnica medida y documentada.

---

---

# 42. FEED Y RECOMENDACIONES

## 42.1 Beta

Feed cronológico o por reglas simples:

- Retos recientes.
- Juegos favoritos.
- Contenido moderado.
- Diversidad.
- Popularidad limitada.
- Usuarios seguidos en fase posterior.

## 42.2 Futuro

La IA podrá ordenar contenido mediante un servicio Python.

Debe existir desde el núcleo una interfaz conceptual:

```text
RecommendationProvider
```

La aplicación debe poder volver a un proveedor determinístico si el servicio de IA falla.

## 42.3 Seguridad y ética

No inferir atributos sensibles.

No usar datos no autorizados.

Permitir controles de personalización.

Documentar explicabilidad básica.

---

---

# 43. DESCUBRIMIENTO DE JUGADORES

El descubrimiento inicial se basará en PostgreSQL:

- Juegos en común.
- Idioma.
- Zona horaria amplia.
- Disponibilidad declarada.
- Bloqueos.
- Privacidad.
- Estado de cuenta.

No usar ubicación precisa salvo necesidad futura, consentimiento y actualización legal.

Neo4j podrá mejorar recomendaciones, no reemplazar reglas de seguridad.

---

---

# 44. SALAS

Fase futura.

Una sala debe tener:

- Juego.
- Creador.
- Privacidad.
- Capacidad.
- Estado.
- Expiración.
- Reglas.
- Moderación.
- Miembros.
- Canal en tiempo real.

Datos durables en PostgreSQL.

Presencia y expiración en Redis.

No guardar toda la verdad de una sala únicamente en memoria.

---

---

# 52. PLAN DE IMPLEMENTACIÓN INICIAL

## Etapa 0 — Fundación

- Repositorio.
- README.
- ADR.
- Docker Compose.
- Spring Boot modular.
- PostgreSQL.
- Redis.
- Flutter base.
- Tema claro y oscuro.
- CI.
- Documentación.
- Health checks.
- Seguridad base.

## Etapa 1 — Identidad

- Registro.
- Verificación.
- Login.
- Refresh.
- Logout.
- Recuperación.
- Perfil.
- Juegos del perfil.
- Legal.

## Etapa 2 — Retos

- Juegos.
- Retos.
- Moderación.
- Reto diario.
- Participación.

## Etapa 3 — Evidencias y medios

- Imágenes.
- R2.
- Worker Go.
- FFmpeg.
- HLS.
- Miniaturas.
- Estado de procesamiento.

## Etapa 4 — Votos y puntos

- Aprobación.
- Desaprobación.
- Ledger.
- Reglas.
- Podios.
- Redis.

## Etapa 5 — Seguridad social

- Bloqueos.
- Reportes.
- Suspensiones.
- Eliminación programada.

## Etapa 6 — Social

- Seguimientos.
- Amistad mutua.
- Descubrimiento.
- Chat.
- WebSockets.
- Salas.

## Etapa 7 — Escala

- Neo4j.
- Feed extraído.
- Realtime Go.
- Notificaciones.
- Observabilidad ampliada.

## Etapa 8 — IA

- Recomendaciones.
- Moderación asistida.
- Clasificación.
- Experimentos controlados.

---
