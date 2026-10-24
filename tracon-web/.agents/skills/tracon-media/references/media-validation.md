# Validación del flujo multimedia

## Go

```powershell
gofmt -w .
go vet ./...
go test ./...
```

## Docker y configuración

```powershell
docker compose config
docker build <componente_afectado>
```

## Casos obligatorios según alcance

- Autorización y expiración de URL prefirmada.
- MIME, firma, tamaño, duración y extensión.
- Confirmación idempotente de carga.
- Estados `pending_upload`, `uploaded`, `queued`, `processing`, `ready`, `failed`, `blocked` y `deleted`.
- Reintentos, backoff, trabajo duplicado y recuperación del worker.
- FFprobe, timeout FFmpeg, calidades y miniatura.
- Limpieza temporal y objetos huérfanos.
- Lectura privada y autorización HLS.
- Reproducción Flutter dentro/fuera de viewport.

Consulta las pruebas existentes en `docs/testing/` y no uses servicios reales sin configuración segura y autorización.
