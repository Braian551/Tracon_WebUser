# Persistencia: JPA, Flyway, PostgreSQL, Redis y Neo4j

Referencia exhaustiva para ORM controlado, migraciones, transacciones, consultas, caché y proyecciones.

La política transversal de selección tecnológica, coste acotado por petición,
N+1, límites de API y seguridad está en
`../../tracon-agent-rules/references/backend-data-api-scalability-safety.md`.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 9. PERSISTENCIA CON ORM Y BUENAS PRÁCTICAS

## 9.1 Decisión principal

El monolito actual usa ORM como herramienta principal para el trabajo que encaja
en agregados y transacciones; no es una obligación para cada consulta.

La persistencia principal del monolito modular será:

```text
Spring Data JPA
+
Hibernate
+
PostgreSQL
+
Flyway
```

El objetivo no es evitar el ORM ni imponerlo por dogma, sino elegir la herramienta
adecuada y evitar su mal uso.

El ORM debe reducir código repetitivo, acelerar el desarrollo de la beta y mantener consistencia transaccional sin ocultar el comportamiento real de la base de datos.

## 9.2 Estrategia híbrida obligatoria

Usar:

- Spring Data JPA y Hibernate para CRUD, agregados y operaciones transaccionales convencionales.
- Proyecciones JPA para lecturas parciales.
- Specifications solo cuando aporten composición real de filtros.
- JPQL para consultas orientadas al modelo.
- SQL nativo o Spring JDBC para:
  - Feed.
  - Podios.
  - Rankings.
  - Agregaciones.
  - Reportes.
  - Consultas masivas.
  - Procesamiento por lotes.
  - Consultas específicas de PostgreSQL.
  - Operaciones donde JPA genere SQL ineficiente.
- Flyway como única autoridad para crear o modificar el esquema.

No forzar JPA en una consulta que sea más clara, segura y eficiente con SQL explícito.

## 9.3 Configuración obligatoria de Hibernate

Producción debe mantener como mínimo:

```yaml
spring:
  jpa:
    open-in-view: false
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        jdbc:
          time_zone: UTC
          batch_size: 50
        order_inserts: true
        order_updates: true
        generate_statistics: false
```

Reglas:

- `ddl-auto` nunca puede ser `create`, `create-drop` ni `update` fuera de pruebas aisladas.
- En producción debe ser `validate`.
- `open-in-view` debe permanecer desactivado.
- Hibernate no crea ni modifica tablas en producción.
- Flyway controla el esquema.
- La zona JDBC debe ser UTC.
- El tamaño de batch debe ajustarse mediante pruebas, no copiarse sin medición.
- Las estadísticas detalladas de Hibernate no deben quedar activas permanentemente en producción.

## 9.4 Entidades JPA

Las entidades deben ubicarse dentro de la infraestructura del módulo:

```text
modules/{modulo}/infrastructure/persistence/entity/
```

Reglas obligatorias:

- No exponer entidades JPA directamente en controladores.
- No serializar entidades como respuesta JSON.
- No usar entidades como DTO de entrada.
- No compartir entidades entre módulos.
- No colocar lógica de presentación en entidades.
- Mantener constructores controlados.
- Evitar setters públicos indiscriminados.
- Proteger invariantes mediante métodos con intención.
- Implementar `equals()` y `hashCode()` de forma segura.
- No incluir colecciones lazy en `toString()`.
- No incluir secretos ni hashes en `toString()`.
- No usar entidades gigantes que representen varios agregados.
- Cada entidad debe pertenecer a un módulo y agregado definidos.
- Los nombres de tabla y columna deben declararse explícitamente cuando eviten ambigüedad.

## 9.5 Modelo de dominio separado

Las entidades JPA no deben convertirse automáticamente en el modelo de toda la aplicación.

La arquitectura debe distinguir:

```text
Entidad JPA
Modelo de dominio
DTO de API
Proyección de lectura
Evento
Mensaje de worker
```

Los mapeos se ubican en:

```text
modules/{modulo}/infrastructure/persistence/mapper/
```

Para CRUD simple se permite una entidad cercana al modelo de dominio únicamente cuando:

- La frontera del módulo es clara.
- No se expone fuera de infraestructura.
- No acopla la API.
- No contiene relaciones innecesarias.
- La decisión queda documentada.

## 9.6 Relaciones

Regla predeterminada:

```text
LAZY
```

No usar `FetchType.EAGER` por comodidad.

Toda relación debe justificarse.

Evitar:

- Relaciones bidireccionales innecesarias.
- Grafos de objetos gigantes.
- Navegación ilimitada entre entidades.
- Colecciones cargadas accidentalmente.
- Relacionar módulos completos mediante asociaciones JPA.
- Mapear como entidad datos que solo requieren un identificador.

Cuando dos módulos se relacionan, preferir almacenar el identificador:

```java
private UUID userId;
```

en lugar de acoplar directamente entidades internas de otros módulos.

## 9.7 Cascadas y eliminación

Prohibido usar por defecto:

```java
cascade = CascadeType.ALL
```

También está prohibido usar sin análisis:

```java
CascadeType.REMOVE
orphanRemoval = true
```

Antes de aplicar cascada se debe revisar:

- Propiedad real del ciclo de vida.
- Integridad histórica.
- Auditoría.
- Puntos.
- Publicaciones.
- Medios.
- Aceptaciones legales.
- Moderación.
- Efectos de borrado.

Las eliminaciónes sensibles deben ser explícitas y auditables.

## 9.8 Prevención de N+1

Cada consulta que cargue listas o relaciones debe revisarse para evitar N+1.

Herramientas permitidas:

- `JOIN FETCH`.
- `@EntityGraph`.
- Proyecciones.
- Consultas específicas.
- Batch fetching medido.
- SQL nativo.
- Spring JDBC.

No resolver N+1 cambiando todo a `EAGER`.

Las pruebas de repositorio de flujos críticos deben validar el número razonable de consultas cuando sea posible.

## 9.9 Paginación

Toda colección potencialmente grande debe paginarse.

Usar:

- Paginación por cursor para feed, publicaciones y actividad.
- `Pageable` para paneles y listados administrativos donde sea adecuado.
- Proyecciones para devolver solo columnas necesarias.
- Orden estable con criterio de desempate.

Evitar:

- `findAll()` en tablas que crecerán.
- Cargar colecciones completas en memoria.
- Paginar después de haber consultado todos los registros.
- `OFFSET` profundo en feeds de gran tamaño.

## 9.10 Repositorios

Los repositorios Spring Data deben permanecer dentro del módulo:

```text
modules/{modulo}/infrastructure/persistence/repository/
```

Reglas:

- No crear un repositorio global para todo.
- No devolver entidades a la capa API.
- No crear métodos derivados con nombres imposibles de mantener.
- Cuando una consulta derivada se vuelva compleja, usar JPQL, proyección, Specification, QueryDSL si se aprueba, o una consulta explícita.
- Mantener contratos de dominio en `domain/repository/` cuando el desacoplamiento aporte valor.
- Implementar adaptadores en infraestructura.
- Las consultas críticas deben estar documentadas y probadas.

## 9.11 Transacciones

Las transacciones se controlan en la capa de aplicación.

Usar:

```java
@Transactional
```

en servicios de caso de uso, no en controladores.

Reglas:

- Transacciones cortas.
- No llamar servicios externos dentro de una transacción de base de datos.
- No ejecutar FFmpeg dentro de una transacción.
- No enviar correos dentro de la transacción principal.
- No mantener transacciones abiertas mientras se carga un archivo a R2.
- Para efectos externos usar outbox.
- Marcar consultas puras con `readOnly = true` cuando corresponda.
- Definir aislamiento especial solo con evidencia.
- Controlar concurrencia con versionado optimista o locks explícitos según el caso.

## 9.12 Concurrencia y bloqueo

Usar `@Version` para control optimista cuando varias operaciones puedan modificar el mismo agregado.

Casos posibles:

- Preferencias.
- Perfil.
- Configuración de reto.
- Saldos materializados.
- Estados de procesamiento.

Para votos, puntos e idempotencia se deben usar además:

- Restricciones únicas.
- Transacciones.
- Claves de idempotencia.
- Operaciones atómicas.
- Locks pesimistas únicamente en casos medidos.

No confiar exclusivamente en validaciones previas de Java para evitar carreras.

## 9.13 DTOs y proyecciones

La API debe usar DTOs.

Las lecturas optimizadas pueden usar:

- Interface projections.
- Record DTO projections.
- JPQL constructor expressions.
- SQL mapeado.
- `JdbcTemplate`.

No devolver una entidad completa cuando la pantalla solo necesita:

```text
id
username
avatar
score
position
```

## 9.14 Consultas dinámicas

Para filtros combinables se puede usar:

- Spring Data Specifications.
- Criteria API encapsulada.
- QueryDSL si se incorpora y documenta.
- Consultas SQL explícitas.

No construir JPQL o SQL concatenando entradas del usuario.

Los criterios dinámicos deben permanecer en infraestructura y tener pruebas.

## 9.15 Operaciones masivas

No procesar miles de entidades una por una con `save()` dentro de un bucle sin evaluar impacto.

Para operaciones masivas usar según el caso:

- Batch JDBC.
- `saveAll()` con batching verificado.
- JPQL bulk update.
- SQL nativo.
- Workers.
- Procesamiento por páginas.

Después de operaciones bulk JPA, limpiar o sincronizar el contexto de persistencia cuando sea necesario.

## 9.16 Caché de Hibernate

No activar caché de segundo nivel de Hibernate por defecto.

Redis es la implementación de caché de aplicación para lecturas aprobadas; no
se debe cachear todo ni usarlo para ocultar una query ineficiente.

La caché de segundo nivel solo puede habilitarse si:

- Existe métrica.
- Se entiende la invalidación.
- Se documentan entidades cacheadas.
- Se realizan pruebas de consistencia.
- No duplica innecesariamente Redis.

## 9.17 Migraciones con Flyway

Las migraciones se ubican en:

```text
backend/core-api/src/main/resources/db/migration/
```

Formato:

```text
V001__create_users.sql
V002__create_games.sql
V003__create_challenges.sql
```

Reglas:

- No editar una migración aplicada.
- Crear una nueva migración correctiva.
- Hibernate solo valida el resultado.
- La entidad y la migración deben cambiar en el mismo trabajo.
- Las restricciones importantes deben existir en PostgreSQL, no solo en anotaciones.
- Los índices deben definirse mediante migración.
- Los datos semilla controlados deben versionarse.
- Las migraciones deben probarse desde una base vacía y desde la versión anterior.

## 9.18 Migraciones destructivas

No ejecutar automáticamente:

- `DROP TABLE`.
- `DROP COLUMN`.
- `TRUNCATE`.
- Eliminaciones masivas.
- Cambios de tipo con pérdida.
- Actualizaciones masivas sin respaldo.

Requieren:

1. Copia de seguridad.
2. Análisis de consumidores.
3. Migración por fases.
4. Compatibilidad temporal.
5. Aprobación explícita.
6. Plan de rollback.
7. Actualización simultánea de entidades y consultas.

## 9.19 Seguridad del ORM

El ORM no reemplaza la autorización.

Toda consulta debe respetar:

- Usuario autenticado.
- Propiedad.
- Visibilidad.
- Bloqueos.
- Estado de moderación.
- Estado de cuenta.
- Rol.

No aceptar identificadores y ejecutar `findById()` para luego devolver el recurso sin verificar permisos.

Prevenir:

- IDOR.
- Mass assignment.
- Exposición accidental de campos.
- Inyección en consultas nativas.
- Filtros incompletos.
- Borrados por cascada.
- Enumeración de datos.

## 9.20 Rendimiento

Antes de cerrar una funcionalidad con persistencia revisar:

1. SQL generado.
2. Número de consultas.
3. Índices.
4. Paginación.
5. Tamaño de respuesta.
6. Relaciones cargadas.
7. Tiempo de transacción.
8. Uso de memoria.
9. Plan de ejecución en consultas críticas.
10. Estrategia de caché.

El agente debe corregir la causa raíz y no esconder una consulta ineficiente detrás de Redis.

## 9.21 Pruebas obligatorias de persistencia

Usar Testcontainers con PostgreSQL real para:

- Repositorios.
- Migraciones.
- Constraints.
- Relaciones.
- Cascadas autorizadas.
- Concurrencia crítica.
- N+1 en flujos sensibles.
- Consultas nativas.
- Proyecciones.
- Paginación.
- Compatibilidad entre entidades y esquema.

No usar únicamente H2 como sustituto de PostgreSQL para validar persistencia.

## 9.22 Reglas prohibidas

El agente no puede:

- Usar `ddl-auto=update` en producción.
- Activar Open Session in View.
- Devolver entidades JPA desde la API.
- Usar `EAGER` indiscriminadamente.
- Usar `CascadeType.ALL` por defecto.
- Crear relaciones bidireccionales sin necesidad.
- Ejecutar `findAll()` sobre tablas crecientes.
- Ocultar N+1 con caché.
- Modificar esquema desde Hibernate.
- Mezclar entidades de varios módulos.
- Abrir transacciones desde controladores.
- Mantener transacciones durante llamadas externas.
- Concatenar entradas en consultas nativas.
- Suponer que JPA elimina la necesidad de índices.
- Suponer que una anotación reemplaza una restricción real de PostgreSQL.

## 9.23 Regla final de persistencia

```text
ORM SÍ.
ORM SIN CONTROL, NO.
FLYWAY MANDA SOBRE EL ESQUEMA.
JPA PARA CRUD Y TRANSACCIONES.
PROYECCIONES PARA LECTURAS.
SQL EXPLÍCITO PARA CONSULTAS CRÍTICAS.
POSTGRESQL CONSERVA LAS RESTRICCIONES REALES.
REDIS ACELERA, PERO NO OCULTA MALAS CONSULTAS.
```

---

---

# 12. REDIS

## 12.1 Usos autorizados

- Caché.
- Rate limiting.
- Códigos temporales.
- Sesiones efímeras.
- Colas o Redis Streams.
- Locks con expiración.
- Rankings derivados.
- Presencia.
- Pub/Sub para eventos no críticos.
- Idempotencia temporal.

## 12.2 Regla de fuente de verdad

Redis no debe ser la única fuente de verdad de:

- Usuarios.
- Publicaciones.
- Votos.
- Puntos.
- Retos.
- Aceptaciones legales.
- Solicitudes de eliminación.
- Acciones de moderación.

## 12.3 Convención de claves

```text
tracon:{entorno}:{modulo}:{recurso}:{identificador}
```

Ejemplos:

```text
tracon:prod:auth:email_code:{user_id}
tracon:prod:rate_limit:login:{ip_hash}
tracon:prod:leaderboard:weekly:{game_id}
tracon:prod:media:job:{job_id}
```

Toda clave debe tener TTL cuando corresponda.

## 12.4 Prohibiciones

- No usar `KEYS *` en producción.
- No guardar secretos.
- No guardar datos personales sin necesidad.
- No crear claves sin prefijo.
- No depender de Pub/Sub para eventos que no pueden perderse.
- No crear locks sin expiración.

---

---

# 13. NEO4J Y GRAFO SOCIAL

## 13.1 Regla de activación

Neo4j forma parte de la arquitectura futura, pero debe permanecer desactivado en la beta hasta confirmar:

- Memoria disponible.
- Disco disponible.
- Carga real.
- Necesidad de consultas de grafo.
- Estrategia de respaldo.
- Estrategia de sincronización.
- Beneficio frente a PostgreSQL.

## 13.2 Uso inicial

Las relaciones iniciales deben persistirse en PostgreSQL:

```text
user_follows
user_blocks
user_games
```

## 13.3 Uso futuro de Neo4j

Neo4j podrá utilizarse para:

- Recomendación de personas.
- Distancias sociales.
- Comunidades por juego.
- Amigos de amigos.
- Afinidad por retos.
- Detección de grupos coordinados.
- Exploración de relaciones.

## 13.4 Fuente de verdad

PostgreSQL será inicialmente la fuente de verdad.

Neo4j será una proyección reconstruible mediante eventos.

No realizar escrituras dobles directas desde una solicitud.

Usar:

1. Transacción en PostgreSQL.
2. Evento en outbox.
3. Worker.
4. Proyección en Neo4j.
5. Registro de evento procesado.

---
