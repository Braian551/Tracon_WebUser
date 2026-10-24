# Protocolo ante bloqueos de herramientas

Un bloqueo de `dart`, `flutter`, Gradle, Java, Maven, Docker, emulador o SDK no autoriza a declarar la tarea terminada.

## Diagnóstico

1. Registra el comando exacto, hora aproximada, timeout y salida disponible.
2. Inspecciona procesos relacionados, PID y línea de comandos.
3. Busca compilaciones paralelas, daemons congelados, locks, procesos huérfanos y recursos insuficientes.
4. Finaliza únicamente un PID confirmado como Tracon o como validación iniciada durante la tarea.
5. Nunca cierres procesos globalmente por nombre, reinicies el equipo, detengas Docker completo, borres cachés globales o dependencias por rutina.
6. Intenta primero soluciones no destructivas y repite la validación focalizada.
7. Cuando conozcas la ruta real del SDK, prueba el binario directo; no inventes rutas.

## Validación alternativa obligatoria

Cuando la herramienta oficial siga bloqueada:

```powershell
git status --short
git diff --check
git diff --stat
git diff --name-only
git diff
```

Después revisa archivo por archivo:

- imports, símbolos, rutas, assets y consumidores;
- tipos, nulabilidad, constructores y callbacks;
- llaves, paréntesis, formato y código muerto;
- seguridad y secretos;
- responsive, scroll, texto y estados visuales;
- migraciones, SQL, contratos y pruebas afectadas;
- documentación y archivos accidentales.

La validación alternativa no equivale a código 0. Reporta exactamente qué validación oficial faltó y el riesgo residual.
