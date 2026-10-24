# Medios: servicio Go, workers y tiempo real

Referencia para Gin, workers, colas, reintentos, WebSockets y comunicación con el núcleo.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 14. SERVICIO GO CON GIN

## 14.1 Plantilla

```text
services/media-service/
├── cmd/
│   └── api/
│       └── main.go
├── internal/
│   ├── config/
│   ├── http/
│   │   ├── handlers/
│   │   ├── middleware/
│   │   ├── routes/
│   │   └── response/
│   ├── application/
│   ├── domain/
│   ├── repository/
│   ├── workers/
│   ├── queue/
│   ├── storage/
│   ├── ffmpeg/
│   ├── observability/
│   └── security/
├── migrations/
├── tests/
├── go.mod
├── go.sum
├── Dockerfile
├── .dockerignore
└── README.md
```

## 14.2 Reglas Gin

- Usar `gin.New()` y agregar middleware explícito.
- Definir timeouts.
- No compartir contexto de solicitud entre goroutines.
- Recuperar pánicos.
- Usar logging estructurado.
- Validar contenido.
- Limitar tamaño de cuerpos.
- No confiar en encabezados de proxy sin configuración.
- Propagar `request_id`.
- Exponer health checks.
- Implementar cierre ordenado.
- Usar pools de conexión.
- No crear goroutines sin control, cancelación ni recuperación.
- No usar variables globales mutables.

## 14.3 Comunicación con el núcleo

Preferencias:

1. Eventos asíncronos para procesamiento.
2. API interna autenticada para consultas puntuales.
3. Idempotencia en comandos.
4. Contratos versionados.

No acceder directamente a tablas privadas del núcleo salvo que una decisión arquitectónica documentada lo autorice.

---

---

# 17. WORKERS Y PROCESAMIENTO ASÍNCRONO

## 17.1 Casos obligatorios de worker

- Transcodificación.
- Miniaturas.
- Correos.
- Notificaciones.
- Actualización de rankings.
- Proyecciones a Neo4j.
- Limpieza de cuentas.
- Limpieza de medios.
- Procesamiento de outbox.
- Moderación automatizada futura.

## 17.2 Reglas

Todo trabajo debe tener:

- Identificador.
- Tipo.
- Payload versionado.
- Fecha.
- Número de intento.
- Límite de reintentos.
- Timeout.
- Estado.
- Idempotencia.
- Dead-letter queue.
- Registro de error.
- Métricas.

No hacer transcodificación dentro de una solicitud HTTP.

## 17.3 Reintentos

Usar backoff.

No reintentar indefinidamente.

No reintentar errores permanentes como:

- Archivo inválido.
- Usuario bloqueado.
- Recurso inexistente.
- Formato prohibido.

---

---

# 18. WEBSOCKETS Y TIEMPO REAL

WebSockets se incorporan únicamente cuando sean necesarios para:

- Chat.
- Presencia.
- Salas.
- Eventos en vivo.
- Cambios de estado de procesamiento.
- Notificaciones inmediatas.

No usar WebSockets para:

- Cargar un feed normal.
- Obtener perfiles.
- Consultar retos estáticos.
- Reemplazar todas las APIs REST.

## 18.1 Autorización

Cada conexión debe:

- Autenticar.
- Validar expiración.
- Identificar usuario.
- Verificar bloqueos.
- Autorizar canales.
- Limitar conexiones.
- Registrar cierre.
- Renovar o cerrar ante expiración.

## 18.2 Chat

Solo se permite iniciar chat cuando:

- Existe seguimiento mutuo o regla equivalente aprobada.
- Ningún usuario ha bloqueado al otro.
- Ninguna cuenta está suspendida.
- El usuario conserva permiso para recibir mensajes.

Un bloqueo debe:

- Impedir mensajes nuevos.
- Impedir presencia visible.
- Ocultar descubrimiento cuando aplique.
- Invalidar canales activos.
- Mantener registros necesarios para moderación según política.

---
