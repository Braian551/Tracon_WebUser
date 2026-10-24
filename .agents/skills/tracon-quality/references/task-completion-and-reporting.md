# Ejecución, finalización y reporte

## Continuidad

- Una auditoría es el inicio, no la entrega, cuando el usuario pidió implementar o corregir.
- Mantén una lista del objetivo raíz y sus fases: UI, cliente, autenticación, API, persistencia, medios, respuesta, pruebas y despliegue si fue autorizado.
- Un problema reparable de Compose, rutas, puertos o herramienta no es un bloqueo externo.
- Ante bloqueo parcial, registra evidencia, continúa fases independientes y pide solo el dato mínimo realmente necesario.

## Bloqueo real

Existe cuando falta acceso o credencial imprescindible, falta una decisión de negocio, hay incompatibilidades no resolubles de forma segura, la acción sería destructiva no autorizada o una dependencia externa no admite alternativa segura.

## Estados permitidos

- Auditoría completada.
- Implementación en progreso.
- Validación parcial.
- Bloqueo parcial.
- Lista para despliegue.
- Desplegada.
- Terminada.

Usa `Terminada` únicamente cuando el objetivo esté integrado y las validaciones aplicables estén satisfechas o sus límites estén documentados honestamente.

## Prohibiciones absolutas resumidas

- No tocar Viax ni otros proyectos.
- No desplegar ni ejecutar Git en producción sin autorización.
- No limpiar Docker globalmente.
- No exponer bases de datos ni secretos.
- No crear tecnología o servicios prematuros.
- No calcular puntos o autoridad de seguridad en Flutter.
- No usar ORM sin límites o migraciones fuera de Flyway.
- No ocultar fallos ni afirmar pruebas inexistentes.
- No borrar datos por una solicitud ambigua.
- No dejar temporales o backups legacy innecesarios.

## Formato del reporte

Incluye solo apartados aplicables:

```text
RESUMEN
- Objetivo:
- Resultado:

ARCHIVOS MODIFICADOS
- ruta: motivo

VALIDACIONES
- comando: resultado real

ERRORES CORREGIDOS
- error: corrección

DOCUMENTACIÓN
- archivo: cambio

DESPLIEGUE / MIGRACIONES / BACKUP
- solo si ocurrió

RIESGOS O PENDIENTES
- solo si existen
```

No rellenes secciones con “no aplica” en una tarea pequeña; omítelas.
