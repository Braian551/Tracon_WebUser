# Calidad: documentación, validaciones y pruebas

Referencia para documentación obligatoria, comandos por tecnología y flujos críticos de prueba.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 38. DOCUMENTACIÓN OBLIGATORIA

Todo cambio funcional, visual, técnico, legal u operativo debe actualizar documentación cercana.

## 38.1 Ubicaciones

```text
docs/architecture/
docs/api/
docs/business/
docs/deployment/
docs/security/
docs/database/
docs/legal/
docs/decisions/
docs/dependencies/
```

## 38.2 README por componente

Cada módulo o servicio debe explicar:

- Propósito.
- Responsabilidades.
- Dependencias.
- Cómo ejecutar.
- Variables.
- Endpoints.
- Eventos.
- Persistencia.
- Pruebas.
- Despliegue.
- Problemas conocidos.

## 38.3 ADR

Decisiones importantes:

```text
docs/decisions/ADR-0001-modular-monolith.md
docs/decisions/ADR-0002-orm-controlado-y-persistencia-hibrida.md
docs/decisions/ADR-0003-hls-r2.md
docs/decisions/ADR-0004-postgres-source-of-truth.md
docs/decisions/ADR-0005-neo4j-projection.md
```

## 38.4 Dependencias

Toda dependencia nueva debe documentarse en:

```text
docs/dependencies/{componente}.md
```

Debe incluir:

- Nombre.
- Versión.
- Motivo.
- Alternativas.
- Licencia.
- Riesgo.
- Comando.
- Ruta.
- Uso.

Si no se documenta, la tarea está incompleta.

---

---

# 39. VALIDACIONES POR TECNOLOGÍA

## 39.1 Flutter

Después de modificar Flutter:

```bash
dart format <archivos_o_directorios_modificados>
flutter analyze <vistas_y_archivos_modificados>
flutter test <pruebas_relacionadas>
```

En preflight multimedia, las pruebas deben verificar el estado canónico por
fuente y la ausencia de mensajes contradictorios de página. Cubrir como
mínimo `READY`, `TRIM_REQUIRED`, una fuente inválida removida, pérdida de
acceso, fallo aislado de miniatura y una respuesta asíncrona obsoleta después
de cambiar la selección; la preparación del editor debe probarse como una
fase distinta de la lectura del video.

El análisis focalizado es la regla predeterminada. Debe incluir las vistas modificadas y los archivos que las afectan directamente, por ejemplo widgets compartidos, controladores, rutas, tema o almacenamiento consumido por esas vistas.

Para documentos legales, la revisión debe incluir manifiesto, cuerpo público,
copias mobile/web/backend y aceptación. Debe fallar si la UI contiene
`LEGAL_TODO`, `LEGAL_REVIEW_REQUIRED`, metadata de proceso o Markdown crudo;
los tests deben conservar los pendientes únicamente en el canal interno y
comprobar una fecha canónica, una sola H1, scroll y texto escalable.

Ampliar el análisis a módulos consumidores cuando cambie un contrato compartido. Ejecutar `flutter analyze` completo únicamente cuando el cambio sea realmente transversal o no pueda delimitarse con seguridad, por ejemplo:

- Cambio de dependencias con impacto general.
- Contratos públicos usados por múltiples módulos.
- Configuración o estado global sin consumidores claramente delimitados.
- Refactor transversal de navegación o tema.

No ejecutar análisis completo por rutina cuando solo se modificaron vistas aisladas. Reportar los paths analizados, consumidores incluidos y resultado.

## 39.1.1 Puerta obligatoria contra errores de edición

Antes de dar por terminado un cambio Flutter se debe ejecutar, en este orden:

```bash
dart format --set-exit-if-changed <archivos_modificados>
flutter analyze <archivos_modificados_y_consumidores>
flutter test <pruebas_relacionadas>
```

No basta con que el IDE no muestre problemas. La tarea no puede declararse
validada hasta que los tres comandos terminen con código `0`. Si alguno agota
el tiempo o queda bloqueado, revisar procesos `dart`/`flutter` iniciados por la
tarea, resolver el bloqueo y repetir la validación; reportar el timeout como
bloqueo si no se logra completar. Para cambios de navegación, además se debe
probar el flujo manual completo desde la pantalla de acceso hasta el destino y
verificar que todas las rutas y constructores afectados compilen.

## 39.1.2 Protocolo obligatorio ante bloqueos de herramientas

Un bloqueo de `dart format`, `dart analyze`, `flutter analyze`, `flutter test`,
Gradle, emulador o proceso del SDK no autoriza a declarar una tarea terminada ni
a dejar la revisión pendiente. Antes de cerrar una tarea se deben revisar
sintaxis, imports, símbolos, nulabilidad, tipos, llaves, navegación,
`BuildContext`, estado, responsive, textos, pruebas afectadas, cambios
accidentales, código muerto y arquitectura.

Cuando una herramienta se bloquee, el agente debe:

1. Registrar el comando exacto y conservar su salida.
2. Inspeccionar procesos `dart`, `flutter`, `java`, `gradle`, Android Studio y
   VS Code, incluidos PID y línea de comandos cuando el entorno lo permita.
3. Identificar análisis simultáneos, compilaciones previas, procesos huérfanos,
   bloqueos de `.dart_tool`, Gradle o daemons congelados.
4. Intentar soluciones no destructivas y finalizar solo un PID cuyo origen se
   haya confirmado como Tracon o como validación iniciada en la tarea. Nunca
   cerrar procesos por nombre global ni procesos de otros proyectos.
5. Repetir la validación con tiempos de espera razonables; cuando sea posible,
   probar el ejecutable directo del SDK con su ruta real.

Si el SDK sigue bloqueado, la validación alternativa es obligatoria:

- Ejecutar `git diff --check`, `git status --short`, `git diff --stat`,
  `git diff --name-only` y revisar el diff completo.
- Revisar archivo por archivo los imports, rutas, símbolos, constructores,
  parámetros requeridos, callbacks, nulabilidad, tipos y referencias mediante
  `rg`; confirmar rutas, assets, rutas de navegación y estado afectado.
- Revisar manualmente paréntesis, llaves, restricciones de `Expanded`,
  `Flexible`, `ListView`, `Column` y scrollables; comprobar posibles overflows
  y textos largos en pantallas pequeñas.
- Revisar controladores en `dispose`, uso de `mounted` después de asincronía,
  estados de carga/error/vacío, componentes existentes y consistencia
  arquitectónica.
- Ejecutar primero la prueba específica afectada. Si también se bloquea,
  comparar manualmente sus finders, mocks y textos contra la implementación;
  no declararla aprobada sin esa revisión.
- Revisar formato manualmente contra el estilo del proyecto y, cuando exista
  una ruta real, usar `dart.exe format --output=none --set-exit-if-changed`
  solo sobre archivos modificados.

La tarea puede cerrarse por validación normal (formato, análisis y pruebas con
código 0) o por validación alternativa: bloqueo investigado, acciones seguras
intentadas, revisión manual completa y riesgos residuales documentados. En este
último caso se debe indicar exactamente qué validación oficial no pudo correr;
un apartado de bloqueo nunca sustituye el diagnóstico ni las validaciones
alternativas.

## 39.2 Java

```bash
./mvnw test
./mvnw verify
```

Además:

- Verificación de módulos.
- Pruebas de seguridad relevantes.
- Pruebas de repositorios con PostgreSQL mediante Testcontainers.
- Migraciones en entorno temporal.
- Validación de compatibilidad entre entidades JPA y esquema Flyway.
- Revisión de N+1 en flujos críticos.
- Revisión del SQL generado en consultas sensibles.
- Confirmación de `ddl-auto=validate`.
- Confirmación de `open-in-view=false`.
- Formato y análisis estático configurados.

## 39.3 Go

```bash
gofmt -w .
go vet ./...
go test ./...
```

Ejecutar análisis adicional configurado por el proyecto.

## 39.4 Rust

```bash
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test
```

## 39.5 Python

```bash
ruff check .
ruff format --check .
pytest
```

## 39.6 Docker

```bash
docker compose config
docker build
```

No ejecutar builds globales innecesarios si solo cambió un componente.

---

---

# 40. PRUEBAS

## 40.1 Tipos

- Unitarias.
- Integración.
- Contrato.
- Repositorio.
- Migraciones.
- Seguridad.
- Widget.
- Navegación.
- End-to-end crítico.
- Carga puntual.
- Recuperación de workers.

## 40.2 Flujos críticos

Obligatorio probar:

- Registro.
- Verificación.
- Login.
- Refresh.
- Revocación.
- Recuperación.
- Creación de reto.
- Publicación.
- Voto.
- Idempotencia.
- Puntos.
- Podio.
- Bloqueo.
- Reporte.
- Carga de imagen.
- Carga y procesamiento HLS.
- Eliminación programada.
- Cancelación de eliminación.
- Aceptación legal.

---
