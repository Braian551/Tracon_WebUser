# Mapeo por tecnología

## Flutter y Dart

### Fronteras

- `presentation` conoce casos de uso/controladores, no datasources concretos.
- `domain` no importa Flutter.
- `data` implementa repositorios y adapta Firebase/HTTP/almacenamiento.
- Los modelos del SDK no cruzan hacia dominio o UI sin traducción.

### Patrones idiomáticos

- Strategy: interfaz/clase abstracta, función inyectada o sealed types según complejidad.
- Factory Method: factory constructor o fábrica dedicada cuando hay selección real.
- Builder: normalmente parámetros nombrados y objetos inmutables; Builder solo para construcción compleja.
- Observer: `Stream`, `ValueNotifier`, `ChangeNotifier` o gestor de estado existente; no poner dependencias Flutter en dominio.
- State: sealed classes/enums con transición centralizada; no multiplicar booleanos.
- Adapter: datasources y wrappers de SDK.
- Command: casos de uso o acciones explícitas, sin convertir cada callback en clase.
- Facade: controlador coordinador limitado para un flujo de UI complejo.

### Evitar

- Service locator global oculto.
- Singletons mutables.
- Lógica de negocio en `build()`.
- Repositories que devuelven DTO de red a presentación.
- Herencia de widgets para compartir lógica compleja; preferir composición.

## Spring Boot y Java

### Fronteras

- `api` traduce HTTP y llama aplicación.
- `application` coordina casos de uso y transacciones.
- `domain` conserva reglas sin dependencias de Spring/JPA cuando la complejidad lo justifique.
- `infrastructure` implementa puertos, persistencia y proveedores.

### Patrones idiomáticos

- Strategy: beans que implementan un contrato pequeño; selección explícita por clave/tipo.
- Factory: selecciona estrategias/adaptadores; evita buscar beans dinámicamente desde dominio.
- Adapter: implementación de puerto para JPA, Firebase, R2, Redis o SMTP.
- State: enum con política centralizada, clases de estado cuando existe comportamiento sustancial.
- Observer: eventos de aplicación para efectos locales; outbox para durabilidad.
- Command: objetos inmutables/records para intención y servicios de caso de uso.
- Decorator: composición o AOP solo para preocupaciones realmente transversales y visibles.
- Proxy: reconoce límites de `@Transactional`, seguridad y AOP; evita auto-invocación que salta el proxy.
- Builder: Lombok/manual solo si aporta claridad; records/constructores para objetos simples.

### Evitar

- `ServiceImpl` uno a uno sin contrato necesario.
- Entidades JPA como dominio universal y DTO API.
- Repositorios globales entre módulos.
- `ApplicationContext.getBean()` como selector de negocio.
- Anotaciones de framework en todas las capas por comodidad.
- Herencia profunda de servicios.

## Go

### Fronteras

- Interfaces pequeñas definidas cerca del consumidor.
- Constructores explícitos (`New...`) e inyección por parámetros.
- Dominio y aplicación no importan Gin, SDK S3 ni ejecución de procesos.
- Adaptadores traducen errores y modelos externos.

### Patrones idiomáticos

- Strategy: interfaz pequeña o función de primera clase.
- Factory: función constructora con selección explícita.
- Adapter: struct que implementa interfaz consumidora.
- Chain of Responsibility: middleware o lista de validadores, con orden visible.
- Command: struct de mensaje y handler idempotente.
- State: tipo definido y tabla/método de transiciones; evitar orientación a objetos artificial.
- Decorator: funciones que envuelven interfaces/handlers.
- Observer: canales/eventos locales con ciclo de vida controlado; no para entrega durable.

### Evitar

- Trasladar patrones Java literalmente a Go.
- Interfaces grandes definidas por el proveedor.
- Goroutines globales sin cancelación.
- Singletons mediante variables globales mutables.
- Capas de structs que solo reenvían llamadas.

## PostgreSQL y Redis

Los patrones de objetos no sustituyen capacidades de datos:

- Restricciones, claves únicas y transacciones protegen invariantes concurrentes.
- SQL explícito puede ser más claro que una cadena compleja de objetos.
- Redis no implementa State como fuente única de verdad durable.
- Outbox y processed events resuelven entrega durable mejor que Observer en memoria.

## Integración entre tecnologías

Cuando el mismo concepto existe en Flutter, Spring y Go:

- Comparte contrato semántico, estados y payloads versionados.
- No compartas clases ni detalles internos.
- Cada tecnología implementa el patrón idiomáticamente.
- La autoridad de negocio permanece en backend/PostgreSQL cuando corresponda.
