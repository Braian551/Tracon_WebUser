# Backend: arquitectura principal, evolución y calidad de código

Referencia para monolito modular, selección tecnológica, estructura del repositorio y backend, rendimiento y prevención de código espagueti.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 3. DECISIÓN ARQUITECTÓNICA PRINCIPAL

## 3.1 Regla absoluta: comenzar como monolito modular

El núcleo de Tracon debe comenzar como un **monolito modular con Spring Boot**.

Se usará una estructura por módulos de negocio, contratos internos y eventos de aplicación para facilitar una futura extracción hacia microservicios.

No se debe comenzar con una arquitectura distribuida completa.

## 3.2 Motivo

El proyecto:

- Está en fase inicial.
- Comparte VPS con Viax.
- Tiene presupuesto limitado.
- Necesita reducir consumo de memoria, CPU, disco y complejidad operativa.
- Todavía no tiene métricas reales de uso.
- Necesita evolucionar sin reescritura completa.

## 3.3 Estrategia tecnológica

| Tecnología | Uso autorizado |
|---|---|
| Flutter y Dart | Aplicación móvil |
| Spring Boot | API central, autenticación, autorización, reglas de negocio y módulos principales |
| Spring Modulith | Validación de límites entre módulos y preparación para extracción futura |
| Spring Security | Autenticación, autorización y protecciones comunes |
| Spring Data JPA + Hibernate | ORM principal para persistencia transaccional y CRUD modular, usado con reglas estrictas |
| Spring JDBC / SQL nativo | Consultas críticas, rankings, feed, agregaciones, operaciones masivas y casos donde el ORM no sea la mejor herramienta |
| Flyway | Única autoridad para migraciones y evolución del esquema |
| Go con Gin | Tecnología principal para microservicios extraídos, workers y APIs de alto rendimiento |
| Rust | Procesos específicos con necesidad demostrada de rendimiento, memoria segura o CPU intensiva |
| Python | IA, recomendaciones, clasificación, moderación asistida y análisis futuro |
| Node.js | Solo cuando una integración concreta lo justifique; no es tecnología predeterminada |
| PostgreSQL | Fuente de verdad relacional |
| Redis | Caché, rate limiting, sesiones efímeras, colas, eventos y rankings |
| Neo4j | Grafo social futuro; no activar en beta sin validación de capacidad |
| Cloudflare R2 | Objetos, imágenes, videos y contenido HLS |
| FFmpeg | Transcodificación de video y generación HLS |
| Docker Compose | Contenedores, redes, volúmenes y despliegues aislados |

## 3.4 Regla sobre versiones

No usar etiquetas o dependencias flotantes como:

```text
latest
+
*
SNAPSHOT
```

Toda versión debe quedar fijada en archivos del proyecto y documentada.

Antes de iniciar el proyecto se deben elegir versiones estables y compatibles entre:

- Java LTS.
- Spring Boot.
- Spring Modulith.
- Spring Security.
- Maven.
- Go.
- Gin.
- Flutter.
- Dart.
- PostgreSQL.
- Redis.
- Neo4j.
- FFmpeg.
- Docker Compose.

No actualizar una versión mayor sin:

1. Revisar compatibilidad.
2. Leer notas de migración.
3. Ejecutar pruebas.
4. Actualizar documentación.
5. Preparar rollback.

---

---

# 4. REGLA DE EVOLUCIÓN HACIA MICROSERVICIOS

## 4.1 Tecnología predeterminada para microservicios

Cuando un módulo deba extraerse, la primera opción será:

```text
Go + Gin
```

## 4.2 No extraer por preferencia personal

Un módulo solo se convierte en microservicio si existe por lo menos una de estas razones:

- Escala de forma distinta al núcleo.
- Necesita despliegue independiente frecuente.
- Consume CPU o memoria de manera aislable.
- Presenta un cuello de botella medido.
- Requiere un tiempo de respuesta diferente.
- Tiene una frontera de negocio estable.
- Necesita tolerancia a fallos independiente.
- Usa una tecnología especializada.
- Su extracción reduce riesgo operativo real.

## 4.3 Prohibiciones

No crear un microservicio:

- Por cada tabla.
- Por cada endpoint.
- Por cada pantalla.
- Por cada desarrollador.
- Solo porque “microservicios suena moderno”.
- Sin métricas.
- Sin contrato de API.
- Sin health check.
- Sin observabilidad.
- Sin estrategia de reintento.
- Sin idempotencia.
- Sin documentación.
- Sin plan de rollback.

## 4.4 Orden recomendado de extracción futura

1. `media-service`
2. `realtime-service`
3. `notification-service`
4. `feed-service`
5. `recommendation-service`
6. `social-graph-service`

El orden puede cambiar únicamente con evidencia técnica.

---

---

# 5. USO DE RUST, PYTHON Y NODE.JS

## 5.1 Rust

Rust NO se incorpora en la beta inicial por defecto.

Puede utilizarse cuando pruebas y perfiles demuestren que Go, Java o FFmpeg no satisfacen un requisito concreto.

Casos posibles:

- Procesamiento intensivo de archivos.
- Validación binaria compleja.
- Componentes sensibles a consumo de memoria.
- Algoritmos de moderación local de alto rendimiento.
- Procesamiento masivo donde se justifique un binario especializado.

Antes de agregar Rust se debe documentar:

- Cuello de botella.
- Métrica actual.
- Objetivo esperado.
- Alternativas evaluadas.
- Impacto operativo.
- Plan de mantenimiento.

## 5.2 Python

Python se reserva para fases posteriores:

- Recomendación de retos.
- Recomendación de personas o juegos.
- Clasificación de feed.
- Detección de abuso.
- Moderación asistida.
- Procesamiento de características para modelos.
- Entrenamiento y evaluación.

La beta utilizará reglas determinísticas, no IA.

## 5.3 Node.js

Node.js no se incluye por defecto.

Solo puede incorporarse cuando:

- Una librería o SDK esencial tenga soporte claramente superior en Node.js.
- Se documente por qué Java o Go no son adecuados.
- Se establezca un propietario técnico.
- Se defina ciclo de actualización y seguridad.

No crear un servicio Node.js para duplicar funciones ya cubiertas por Spring Boot o Go.

---

---

# 6. ESTRUCTURA GENERAL DEL REPOSITORIO

```text
tracon-games/
├── mobile/
│   ├── android/
│   ├── ios/
│   ├── assets/
│   ├── lib/
│   ├── test/
│   ├── integration_test/
│   ├── pubspec.yaml
│   ├── pubspec.lock
│   ├── analysis_options.yaml
│   └── README.md
├── backend/
│   ├── core-api/
│   └── README.md
├── services/
│   ├── media-service/
│   ├── realtime-service/
│   ├── notification-service/
│   ├── recommendation-service/
│   └── README.md
├── infra/
│   ├── docker/
│   ├── nginx/
│   ├── monitoring/
│   ├── backups/
│   └── README.md
├── database/
│   ├── migrations/
│   ├── seeds/
│   ├── fixtures/
│   └── README.md
├── legal/
│   ├── terms/
│   ├── privacy/
│   ├── community/
│   └── README.md
├── docs/
│   ├── architecture/
│   ├── api/
│   ├── business/
│   ├── deployment/
│   ├── security/
│   ├── database/
│   ├── legal/
│   ├── decisions/
│   └── dependencies/
├── scripts/
├── tmp/
├── compose.yaml
├── compose.dev.yaml
├── compose.prod.yaml
├── .env.example
├── .gitignore
├── README.md
└── LICENSE
```

## 6.1 Regla de raíz limpia

No dejar en la raíz:

- Logs.
- Dumps.
- Capturas.
- Archivos temporales.
- Resultados de análisis.
- Videos de prueba.
- Copias de bases de datos.
- Claves.
- Credenciales.
- Archivos `.env`.
- Binarios.
- APK generados.
- Segmentos HLS.

Los temporales deben ir en:

```text
tmp/
```

y eliminarse al finalizar la tarea.

---

---

# 8. BACKEND CENTRAL CON SPRING BOOT

## 8.1 Estructura

```text
backend/core-api/
├── src/
│   ├── main/
│   │   ├── java/com/viaxtechnology/tracon/
│   │   │   ├── TraconApplication.java
│   │   │   ├── config/
│   │   │   ├── shared/
│   │   │   │   ├── api/
│   │   │   │   ├── errors/
│   │   │   │   ├── security/
│   │   │   │   ├── events/
│   │   │   │   ├── database/
│   │   │   │   ├── time/
│   │   │   │   ├── validation/
│   │   │   │   └── observability/
│   │   │   └── modules/
│   │   │       ├── auth/
│   │   │       ├── users/
│   │   │       ├── profiles/
│   │   │       ├── games/
│   │   │       ├── challenges/
│   │   │       ├── submissions/
│   │   │       ├── votes/
│   │   │       ├── leaderboard/
│   │   │       ├── social/
│   │   │       ├── moderation/
│   │   │       ├── notifications/
│   │   │       ├── media/
│   │   │       ├── legal/
│   │   │       └── audit/
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-prod.yml
│   │       ├── db/migration/
│   │       └── templates/email/
│   └── test/
├── pom.xml
├── mvnw
├── mvnw.cmd
├── Dockerfile
├── .dockerignore
└── README.md
```

## 8.2 Estructura interna de cada módulo

```text
modules/challenges/
├── api/
│   ├── ChallengeController.java
│   ├── request/
│   └── response/
├── application/
│   ├── command/
│   ├── query/
│   ├── service/
│   └── port/
├── domain/
│   ├── model/
│   ├── event/
│   ├── repository/
│   └── policy/
└── infrastructure/
    ├── persistence/
    │   ├── entity/
    │   ├── repository/
    │   ├── mapper/
    │   ├── projection/
    │   ├── specification/
    │   ├── query/
    │   ├── jdbc/
    │   └── sql/
    ├── messaging/
    └── config/
```

## 8.3 Regla de controladores delgados

Un controlador solo debe:

1. Recibir la solicitud.
2. Validar formato.
3. Obtener identidad autenticada.
4. Llamar un caso de uso.
5. Devolver una respuesta.

No debe:

- Ejecutar SQL.
- Calcular puntos.
- Manejar transacciones complejas.
- Enviar correos directamente.
- Acceder a Redis directamente.
- Subir archivos a R2 directamente.
- Decidir permisos mediante condiciones dispersas.

## 8.4 Regla de límites modulares

Un módulo no puede acceder directamente a tablas privadas de otro módulo.

La comunicación se realiza mediante:

- API pública del módulo.
- Casos de uso expuestos.
- Eventos de aplicación.
- Contratos explícitos.

No crear un paquete `utils` global para ocultar acoplamiento.

---

---

# 28. PREVENCIÓN DE CÓDIGO ESPAGUETI

## 28.1 Prohibiciones

- Controladores con lógica de negocio.
- Widgets con HTTP directo.
- SQL en controladores.
- Repositorios que devuelven objetos de UI.
- Servicios de miles de líneas.
- Archivos `helpers` que contienen de todo.
- Dependencias circulares.
- Acceso entre módulos por clases internas.
- Estados duplicados.
- Excepciones genéricas.
- Nombres ambiguos.
- Métodos que hacen varias tareas.
- Comentarios que contradicen código.
- Código muerto.
- Copiar y pegar validaciones.
- Hardcodear URLs.
- Hardcodear colores.
- Hardcodear plantillas de correo.
- Hardcodear secretos.

## 28.2 Idioma

- Identificadores de código: inglés claro.
- Documentación: español.
- Comentarios: español.
- Mensajes para usuario: español, preparados para internacionalización.
- Códigos de error: inglés estable.

## 28.3 Comentarios

Comentar:

- Intención.
- Restricción.
- Razón de seguridad.
- Regla de negocio no obvia.
- Decisión de rendimiento.
- Compatibilidad temporal.
- Flujo de navegación, autenticación, feed, publicación, retos, puntos y moderación cuando la intención no sea evidente.

No comentar línea por línea ni repetir lo evidente.

En Flutter, los comentarios que expliquen flujos principales deben escribirse obligatoriamente en español. La prioridad es explicar el porqué del flujo y sus límites, no describir widgets obvios.

## 28.4 Funciones

Una función debe tener una responsabilidad.

Cuando una función:

- Valida.
- Consulta.
- Modifica.
- Envía correo.
- Publica evento.
- Formatea respuesta.

todo al mismo tiempo, debe dividirse.

---

---

# 29. UTF-8

## 29.1 Regla absoluta

Todo el proyecto debe usar UTF-8.

## 29.2 Configuración

- Archivos fuente en UTF-8.
- PostgreSQL en UTF-8.
- Respuestas JSON con UTF-8.
- Correos con UTF-8.
- Logs con UTF-8.
- Docker con locale apropiado.
- Nginx con charset UTF-8 cuando aplique.

## 29.3 Prohibiciones

No introducir textos como:

```text
tres ejemplos de palabras con caracteres corruptos
```

Si un archivo presenta corrupción de caracteres:

1. Identificar codificación real.
2. Crear respaldo.
3. Convertir.
4. Revisar diff.
5. Ejecutar pruebas.
6. No reemplazar caracteres masivamente sin validar.

---

---

# 41. RENDIMIENTO Y CAPACIDAD

## 41.1 No optimizar a ciegas

Antes de introducir:

- Rust.
- Neo4j.
- Kafka.
- Kubernetes.
- Más réplicas.
- Más microservicios.
- Nuevas bases de datos.

se deben tener métricas.

## 41.2 VPS compartido

Antes del primer despliegue se debe inventariar:

- CPU.
- RAM.
- Swap.
- Disco.
- IOPS.
- Uso de Viax.
- Puertos.
- Contenedores.
- Volúmenes.
- Redes.
- Nginx.
- Backups.
- Firewall.

No asumir que Viax está inactivo solo porque tenga poco tráfico.

## 41.2.1 Ubicación obligatoria del backend de Tracon

El backend, la base de datos, Redis y el worker de medios de Tracon se ejecutan
exclusivamente en el VPS `168.231.71.225`; el acceso operativo autorizado es
`ssh root@168.231.71.225`. La API pública canónica es
`https://tracon.online`; Nginx termina TLS y el puerto interno de la API no se
debe asumir accesible desde emuladores o equipos de desarrollo.

Antes de diagnosticar un fallo de Flutter, el agente debe inspeccionar el
`API_BASE_URL` efectivo de la configuración de ejecución, los `--dart-define`
y el log de compilación. No debe suponer ni iniciar un backend local, ni usar
`10.0.2.2:18080`, `localhost`, una IP del VPS o subdominios no verificados como
reemplazo de `https://tracon.online`. Para comprobaciones de servidor, usar SSH
solo sobre los recursos identificados como Tracon y no inspeccionar, reiniciar
ni modificar Viax.

## 41.3 Límites

Todos los contenedores Tracon deben tener límites o reservas razonables documentadas.

La transcodificación debe limitar concurrencia.

En un VPS pequeño, comenzar con:

```text
1 trabajo FFmpeg simultáneo
```

y aumentar solo con métricas.

---
