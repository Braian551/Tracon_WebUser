# Infraestructura: Docker Compose, VPS, aislamiento, Nginx y Git

Referencia de servicios, redes, volúmenes, puertos, rutas de servidor, Nginx y flujo Git.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 30. DOCKER COMPOSE

## 30.1 Aclaración

Se usará **Docker Compose**.

No se usará Composer de PHP porque el backend no es PHP.

## 30.2 Servicios iniciales

```text
tracon-core-api
tracon-postgres
tracon-redis
tracon-media-worker
```

Servicios futuros mediante perfiles:

```text
tracon-neo4j
tracon-realtime
tracon-ai
tracon-monitoring
```

## 30.3 Esqueleto conceptual

```yaml
name: tracon

services:
  core-api:
    build:
      context: ./backend/core-api
    env_file:
      - .env
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - tracon_internal
      - tracon_edge
    restart: unless-stopped

  media-worker:
    build:
      context: ./services/media-service
    env_file:
      - .env
    depends_on:
      redis:
        condition: service_healthy
    networks:
      - tracon_internal
    restart: unless-stopped

  postgres:
    image: postgres:PINNED_VERSION
    env_file:
      - .env
    volumes:
      - tracon_postgres_data:/var/lib/postgresql/data
    networks:
      - tracon_internal
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:PINNED_VERSION
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - tracon_redis_data:/data
      - ./infra/docker/redis/redis.conf:/usr/local/etc/redis/redis.conf:ro
    networks:
      - tracon_internal
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  neo4j:
    image: neo4j:PINNED_VERSION
    profiles: ["graph"]
    volumes:
      - tracon_neo4j_data:/data
    networks:
      - tracon_internal
    restart: unless-stopped

networks:
  tracon_edge:
    name: tracon_edge
  tracon_internal:
    name: tracon_internal
    internal: true

volumes:
  tracon_postgres_data:
    name: tracon_postgres_data
  tracon_redis_data:
    name: tracon_redis_data
  tracon_neo4j_data:
    name: tracon_neo4j_data
```

## 30.4 Reglas de contenedores

- No ejecutar como root cuando sea posible.
- Usar imágenes mínimas.
- Fijar versiones.
- Multi-stage builds.
- Health checks.
- Límites de recursos.
- Logs con rotación.
- `read_only` cuando sea posible.
- `tmpfs` para temporales pequeños.
- Secretos fuera de imagen.
- No montar `/var/run/docker.sock`.
- No usar `network_mode: host`.
- No exponer PostgreSQL, Redis o Neo4j a Internet.
- Publicar la API solo en loopback detrás de Nginx.
- Separar entornos.

---

---

# 31. AISLAMIENTO DEL SERVIDOR COMPARTIDO CON VIAX

## 31.1 Servidor autorizado

```bash
ssh root@168.231.71.225
```

La presencia de esta dirección en la skill NO autoriza al agente a conectarse o desplegar sin una solicitud explícita.

## 31.2 Ruta Tracon

```text
/srv/tracon/
```

## 31.3 Estructura en servidor

```text
/srv/tracon/
├── app/
├── releases/
├── current/
├── config/
├── secrets/
├── logs/
├── backups/
├── tmp/
└── compose/
```

## 31.4 Aislamiento obligatorio

Tracon no puede:

- Escribir en `/var/www/viax/`.
- Reutilizar volúmenes de Viax.
- Reutilizar nombres de contenedor de Viax.
- Reutilizar bases de datos de Viax.
- Reutilizar redes internas de Viax.
- Reutilizar secretos de Viax.
- Reiniciar contenedores de Viax.
- Ejecutar `docker compose down` fuera de `/srv/tracon/`.
- Modificar Nginx de Viax.
- Usar puertos ocupados.
- Borrar imágenes o volúmenes sin identificar propietario.
- Ejecutar limpieza global de Docker.

## 31.5 Prefijos obligatorios

```text
tracon_
tracon-
```

Ejemplos:

```text
tracon-core-api
tracon-postgres
tracon_internal
tracon_postgres_data
```

## 31.6 Docker Compose project name

```text
COMPOSE_PROJECT_NAME=tracon
```

## 31.7 Puertos

Los puertos internos deben documentarse.

Los puertos publicados deben enlazarse a:

```text
127.0.0.1
```

Ejemplo:

```text
127.0.0.1:18080:8080
```

No exponer temporalmente bases de datos al público.

## 31.8 Acceso antes de tener dominio

Opciones autorizadas:

1. Túnel SSH.
2. Dominio o subdominio temporal.
3. Nginx con host dedicado y TLS.
4. Acceso restringido por firewall.

No mezclar Tracon dentro de rutas de Viax sin una decisión explícita.

---

---

# 32. NGINX

Config dedicada:

```text
infra/nginx/tracon-api.conf
```

Producción:

```text
/etc/nginx/sites-available/tracon-api.conf
/etc/nginx/sites-enabled/tracon-api.conf
```

Reglas:

- Archivo separado.
- No editar configuración de Viax.
- TLS.
- Límites de cuerpo.
- Timeouts específicos.
- Encabezados de seguridad.
- Proxy headers controlados.
- Soporte de streaming cuando aplique.
- No servir segmentos HLS desde la API si R2/CDN puede entregarlos.
- Validar con `nginx -t`.
- Recargar, no reiniciar innecesariamente.

---

---

# 33. GITHUB FLOW

## 33.1 Modelo

```text
main
feature/*
fix/*
chore/*
docs/*
```

## 33.2 Flujo

1. Crear rama desde `main`.
2. Implementar cambio.
3. Ejecutar validaciones.
4. Actualizar documentación.
5. Abrir pull request.
6. Revisar.
7. Integrar a `main`.
8. Generar artefacto.
9. Desplegar artefacto aprobado.

## 33.3 Producción

Git está prohibido en producción.

No ejecutar en el VPS:

```text
git clone
git pull
git checkout
git reset
git clean
git merge
git commit
git push
```

El despliegue debe usar:

- Imágenes de contenedor inmutables desde un registro; o
- Paquete de release verificado; o
- Archivos construidos y subidos de forma controlada.

No compilar Flutter en el VPS.

Preferir construir imágenes en CI o entorno de desarrollo para no consumir recursos del servidor compartido.

## 33.4 Regla para agentes

El agente no debe crear commits ni hacer push salvo solicitud explícita.

Siempre debe reportar archivos modificados.

---
