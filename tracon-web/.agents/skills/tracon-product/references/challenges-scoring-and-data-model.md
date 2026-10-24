# Negocio: modelo de datos, retos, evidencias, votos, puntos y podios

Referencia de entidades funcionales, ledger, fraude, rankings y reglas de cambio de puntuación.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 10. MODELO DE DATOS INICIAL

## 10.1 Reglas generales

- Nombres en `snake_case`.
- Fechas en `timestamptz`.
- Tiempos almacenados en UTC.
- Identificadores no predecibles.
- Claves foráneas explícitas.
- Restricciones `UNIQUE`.
- Restricciones `CHECK`.
- Índices documentados.
- Borrado físico solo mediante flujo autorizado.
- No almacenar contadores críticos como única fuente de verdad.
- No duplicar datos sin una razón de lectura medida.

## 10.2 Tablas base sugeridas

### Identidad y seguridad

```text
users
user_credentials
user_email_verifications
user_refresh_sessions
user_roles
roles
account_deletion_requests
login_attempts
security_events
```

### Perfil y juegos

```text
user_profiles
games
user_games
user_preferences
user_blocks
user_reports
```

### Social

```text
user_follows
chat_threads
chat_members
chat_messages
rooms
room_members
```

Chat y salas pueden crearse en fases posteriores, pero los nombres de dominio deben reservarse en documentación, no mediante tablas vacías innecesarias.

### Retos

```text
challenges
challenge_games
daily_challenges
challenge_participants
challenge_submissions
submission_media
submission_votes
```

### Puntos y podios

```text
point_ledger
point_rules
leaderboard_snapshots
```

### Contenido y medios

```text
media_assets
media_variants
media_processing_jobs
```

### Moderación y cumplimiento

```text
content_reports
moderation_actions
audit_events
legal_documents
legal_versions
user_legal_acceptances
```

### Integración asíncrona

```text
outbox_events
processed_events
```

## 10.3 Votos

La tabla de votos debe impedir más de un voto por usuario y publicación:

```text
UNIQUE (submission_id, voter_user_id)
```

El valor debe restringirse:

```text
-1 = desaprobación
 1 = aprobación
```

No confiar en el cliente para sumar o restar puntos.

## 10.4 Libro mayor de puntos

Los puntos deben manejarse como movimientos inmutables:

```text
point_ledger
```

Cada movimiento debe tener:

- Usuario.
- Motivo.
- Referencia.
- Cantidad.
- Fecha.
- Clave de idempotencia.
- Regla aplicada.

No actualizar directamente un campo `total_points` como única fuente de verdad.

Puede existir un total materializado o cacheado, pero debe poder reconstruirse desde el libro mayor.

---

---

# 11. REGLAS DE NEGOCIO DE RETOS Y PODIOS

## 11.1 Retos

Un reto debe incluir:

- Autor.
- Juego o juegos.
- Título.
- Descripción.
- Dificultad.
- Estado.
- Reglas.
- Fecha de creación.
- Alcance.
- Requisitos de evidencia.
- Estado de moderación.

## 11.2 Estados sugeridos

```text
draft
pending_review
published
rejected
archived
```

Los valores exactos deben centralizarse y documentarse.

No usar traducciones diferentes entre Flutter, Java, Go, Redis y PostgreSQL.

## 11.3 Reto diario

La beta debe usar selección determinística:

- Rotación.
- Popularidad limitada.
- Diversidad de juegos.
- Moderación aprobada.
- Evitar repetir el mismo reto durante una ventana definida.

La IA no es necesaria para el primer sistema de sugerencias.

## 11.4 Evidencias

Una evidencia puede contener:

- Texto.
- Imagen.
- Video HLS.
- Estado de moderación.
- Estado de procesamiento.
- Conteo derivado de votos.
- Puntaje calculado en servidor.

## 11.5 Reglas mínimas contra fraude

- No votar la propia evidencia.
- Un voto por usuario.
- Rate limiting.
- Registro de cambios de voto.
- Puntos calculados solo en backend.
- Idempotencia.
- Detección básica de cuentas nuevas coordinadas.
- Posibilidad de congelar puntos durante revisión.
- Reversión mediante movimientos compensatorios, no edición silenciosa del historial.

## 11.6 Podios

Tipos iniciales:

- Diario.
- Semanal.
- Mensual.
- Histórico.
- Por juego.
- Por reto.

No ejecutar una consulta completa costosa por cada apertura de pantalla.

La fuente de verdad estará en PostgreSQL y los resultados frecuentes podrán mantenerse en Redis.

---

---

# 49. REGLAS PARA CAMBIOS DE PUNTOS

Antes de modificar la puntuación verificar:

- Votos.
- Ledger.
- Ranking.
- Caché.
- Workers.
- UI.
- Moderación.
- Reversiones.
- Métricas.
- Migraciones.
- Pruebas.

Toda regla debe vivir en:

```text
docs/business/scoring.md
```

No cambiar fórmulas silenciosamente.

---
