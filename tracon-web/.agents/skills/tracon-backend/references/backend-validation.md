# Validación focalizada de Spring Boot y persistencia

## Comandos base

Desde `backend/core-api/`:

```powershell
./mvnw test
./mvnw verify
```

En Windows también puede usarse `mvnw.cmd`.

## Selección de alcance

- Ejecuta primero pruebas del módulo o clase afectada.
- Amplía a `verify` completo cuando cambie seguridad global, configuración, módulos compartidos, migraciones o contratos transversales.
- No afirmes que Testcontainers, PostgreSQL, Firebase o servicios externos fueron probados si no se ejecutaron.

## Puertas de persistencia

- Migración nueva, nunca edición de una ya aplicada.
- Compatibilidad entidad/esquema.
- PostgreSQL real mediante Testcontainers cuando aplique.
- Restricciones, índices, paginación y concurrencia.
- SQL generado y ausencia de N+1 crítico.
- `ddl-auto=validate` y `open-in-view=false`.
- Autorización, propiedad y filtros de visibilidad.

## Contratos

Cuando cambie un DTO, estado, endpoint o evento, verifica Flutter, Go, Redis, workers, OpenAPI y documentación consumidores.
