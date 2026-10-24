# Patrones GOF para Tracon

## Creacionales

### Factory Method

Usar cuando la creación depende de un tipo, proveedor o contexto y el consumidor no debe conocer la clase concreta.

Ejemplos posibles:

- Elegir procesador de medio según tipo.
- Crear una estrategia de ranking aprobada.
- Construir adaptador de proveedor por configuración validada.

No usar para ocultar un `new` trivial de una única implementación.

### Abstract Factory

Usar cuando se necesita una familia coherente de objetos relacionados y existen varias familias reales.

En Tracon sería excepcional. No crear una fábrica abstracta para un único proveedor o para agrupar objetos sin relación de compatibilidad.

### Builder

Usar para objetos complejos con muchos campos opcionales, combinaciones válidas o configuración de pruebas.

- Mantén invariantes al finalizar `build()`.
- No uses Builder para DTO pequeños o records simples.
- En Dart, parámetros nombrados pueden ser suficientes.

### Prototype

Usar cuando clonar una configuración compleja es más seguro o eficiente que reconstruirla. Evitar clones superficiales de estado mutable y no usarlo para entidades con identidad durable sin reglas claras.

### Singleton

No implementar Singleton manual mutable. Spring y otros contenedores ya administran ciclos de vida. En Dart/Go, preferir inyección explícita. Solo considerar una instancia única para recursos técnicos controlados y sin estado mutable de negocio.

## Estructurales

### Adapter

Patrón principal para aislar:

- Firebase Auth/Admin.
- Cloudflare R2/S3.
- SMTP.
- Redis.
- FFmpeg/ffprobe.
- APIs externas.

El adaptador traduce modelos, errores y operaciones externas a un puerto interno. No filtra tipos del SDK hacia dominio.

### Bridge

Usar cuando una abstracción y su implementación varían independientemente. Es poco frecuente. No confundir con Adapter: Adapter integra un contrato existente; Bridge diseña dos dimensiones de variación desde el inicio.

### Composite

Usar para estructuras jerárquicas parte-todo tratadas uniformemente. Puede servir para reglas o filtros compuestos, pero no modelar árboles artificiales.

### Decorator

Añade comportamiento por composición sin modificar el componente base:

- Métricas.
- Caching seguro.
- Reintentos limitados.
- Auditoría.
- Trazas.

El orden debe ser explícito. No ocultar autorización o transacciones críticas en decoradores difíciles de seguir.

### Facade

Ofrece una interfaz simple a un subsistema complejo, por ejemplo un flujo de publicación multimedia. La fachada coordina, pero no debe convertirse en un servicio gigante ni esconder errores, permisos o estados importantes.

### Flyweight

Comparte datos inmutables repetidos para ahorrar memoria. Solo usar con evidencia de consumo; no complica modelos de negocio por optimización prematura.

### Proxy

Controla acceso, lazy loading, llamadas remotas o seguridad. Spring ya usa proxies para varias capacidades. Evita depender de detalles implícitos de proxy, auto-invocaciones problemáticas o llamadas remotas que parezcan locales y baratas.

## De comportamiento

### Chain of Responsibility

Encadena validadores o filtros independientes:

- Validación de carga multimedia.
- Moderación previa.
- Autorizaciones compuestas.

Cada paso debe tener responsabilidad clara, orden controlado y resultado explícito. No ocultar qué validaciones se ejecutaron.

### Command

Representa una intención ejecutable con datos necesarios:

- Procesar medio.
- Publicar evidencia.
- Aplicar acción de moderación.
- Operación idempotente en cola.

Distingue un comando de aplicación de una carpeta llamada `command`; el patrón aporta ejecución, encapsulación y posible cola/reintento/compensación.

### Interpreter

Rara vez necesario. Solo para un lenguaje o gramática pequeña y estable. No crear DSL propio cuando una configuración declarativa simple o librería segura resuelve el problema.

### Iterator

Usar mecanismos idiomáticos del lenguaje. Implementarlo manualmente solo cuando se requiere recorrido especializado o lazy no cubierto por colecciones estándar.

### Mediator

Centraliza coordinación entre participantes que de otro modo se conocen entre sí. Puede ayudar en UI compleja, pero evita un mediador gigante que termine concentrando toda la lógica.

### Memento

Captura estado para restauración sin exponer internals. Útil para edición local o borradores. Para datos durables sensibles, usar historial/auditoría explícita, no snapshots opacos como única verdad.

### Observer

Reacciona a eventos dentro del mismo proceso:

- Actualización de UI.
- Eventos de aplicación no críticos.

Para eventos que no pueden perderse entre servicios o procesos, usar outbox, consumidor idempotente y persistencia; Observer en memoria no basta.

### State

Encapsula comportamiento por estado y transiciones:

- `pending_upload → uploaded → queued → processing → ready/failed`.
- Estados de publicación o moderación.
- Flujo de reto.

Usarlo cuando cada estado tiene comportamiento o transiciones significativas. Para un enum simple sin comportamiento, conservar enum y validaciones claras.

### Strategy

Encapsula algoritmos intercambiables:

- Ranking.
- Selección de reto diario.
- Moderación o scoring.
- Política de retry.
- Formato de notificación.

La selección debe estar centralizada y probada. Evita registrar estrategias dinámicas sin control o crear una estrategia por cada condición trivial.

### Template Method

Define un flujo estable en una clase base y permite variar pasos. Úsalo solo cuando existe una relación de herencia natural y el esqueleto es realmente estable. En la mayoría de integraciones, Strategy y composición son más flexibles.

### Visitor

Permite agregar operaciones sobre una estructura de tipos estable. Es útil cuando la estructura cambia poco y aparecen muchas operaciones. Evitarlo si los tipos cambian con frecuencia o si pattern matching idiomático es más claro.

## Combinaciones frecuentes

- Adapter + Strategy: varios proveedores detrás de un contrato y política de selección.
- Command + State: trabajos encolados con transiciones explícitas.
- Facade + Ports/Adapters: entrada simple que coordina casos de uso sin acoplar proveedores.
- Decorator + Adapter: métricas, retry o caché alrededor de una integración.
- Chain of Responsibility + Strategy: validaciones ordenadas con políticas intercambiables.
- Observer interno + Outbox durable: reacción local y publicación confiable separadas.

No combines patrones por defecto. Cada uno debe justificar su propia presión de diseño.
