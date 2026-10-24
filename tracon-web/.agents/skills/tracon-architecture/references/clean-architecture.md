# Clean Architecture aplicada a Tracon

## Objetivo

Clean Architecture protege las reglas de negocio frente a frameworks, UI, persistencia y proveedores externos. No significa crear carpetas ceremoniales; significa mantener fronteras claras y dependencias dirigidas hacia el núcleo.

## Regla de dependencia

Las dependencias de código deben apuntar hacia capas más internas:

```text
Presentación / API / Workers
            ↓
        Aplicación
            ↓
          Dominio
```

Infraestructura implementa contratos definidos hacia adentro:

```text
Infraestructura ──implementa──> Puerto de aplicación o dominio
```

El dominio no importa:

- Flutter, widgets o `BuildContext`.
- Spring, anotaciones web o seguridad del framework.
- JPA/Hibernate o entidades de persistencia.
- Firebase, R2, SMTP, Redis, FFmpeg o SDKs externos.
- JSON, HTTP, rutas o detalles de serialización.

## Capas y responsabilidades

### Dominio

Contiene comportamiento e invariantes independientes de frameworks:

- Entidades y value objects.
- Políticas y reglas de negocio.
- Estados y transiciones válidas.
- Eventos de dominio cuando aporten valor.
- Contratos estrictamente de dominio cuando sean necesarios.

Evita modelos anémicos cuando una entidad tiene invariantes reales, pero no fuerces métodos en entidades que solo representan datos simples.

### Aplicación

Orquesta intenciones del usuario o del sistema:

- Casos de uso y comandos/consultas.
- Puertos de entrada y salida.
- Transacciones.
- Autorización de negocio coordinada con identidad ya validada.
- Idempotencia y coordinación de efectos.
- Mapeo entre dominio y contratos externos cuando corresponda.

Un caso de uso no debe conocer HTTP, widgets, JPA concreto ni comandos de shell.

### Adaptadores de entrada

Traducen entradas externas a casos de uso:

- Controladores REST.
- Pantallas/controladores de presentación.
- Consumers de colas.
- Jobs programados.
- CLI o scripts autorizados.

Responsabilidades: validar forma, convertir DTO, obtener identidad, invocar aplicación y traducir respuesta/error.

### Adaptadores de salida

Implementan puertos:

- Repositorios PostgreSQL/JPA/JDBC.
- Firebase Admin.
- R2.
- Redis.
- SMTP.
- FFmpeg.
- APIs externas.

No deben decidir reglas de negocio que pertenecen al dominio o aplicación.

## Organización por módulo

Tracon se organiza primero por capacidad funcional, luego por capas.

### Spring Boot

```text
modules/{modulo}/
├── api/
├── application/
│   ├── command/
│   ├── query/
│   ├── service/
│   └── port/
├── domain/
│   ├── model/
│   ├── policy/
│   ├── event/
│   └── repository/
└── infrastructure/
    ├── persistence/
    ├── messaging/
    ├── external/
    └── config/
```

No todos los módulos necesitan todas las carpetas. Créala solo cuando tenga contenido real.

### Flutter

```text
modules/{modulo}/
├── data/
│   ├── datasources/
│   ├── dto/
│   ├── mappers/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── controllers/
    ├── pages/
    └── widgets/
```

Para módulos simples puede omitirse una capa vacía. Cuando exista lógica reutilizable o contratos, debe salir de la UI.

### Go

```text
internal/{capacidad}/
├── application/
├── domain/
├── ports/
├── adapters/
└── transport/
```

También puede conservarse la estructura actual si mantiene la misma dirección de dependencias. En Go, las interfaces deben ubicarse preferentemente cerca del consumidor.

## Fronteras entre módulos

- Un módulo no accede a tablas privadas, repositorios concretos o entidades internas de otro.
- Se comunica mediante casos de uso públicos, contratos pequeños o eventos.
- No uses un paquete global `utils` para ocultar dependencias.
- Los modelos compartidos deben ser realmente estables y transversales; de lo contrario, cada módulo traduce su contrato.
- Evita importaciones bidireccionales y servicios “centrales” que terminan conociendo todo.

## Modelos separados

Distingue cuando cruces una frontera:

```text
DTO de entrada
Modelo de dominio
Entidad de persistencia
Proyección de lectura
DTO de salida
Modelo de presentación
Evento / mensaje
```

Para CRUD muy simple se permite reducir mapeos si no expone infraestructura ni crea acoplamiento. La decisión debe mantenerse local y reversible.

## Dependencias externas

Toda integración externa debe quedar detrás de un adaptador cuando:

- Tiene SDK o contrato ajeno.
- Puede cambiar de proveedor.
- Necesita pruebas sin red.
- Introduce errores, reintentos o políticas propias.
- Su modelo no debe contaminar el dominio.

No crees un adaptador para una función pura o estándar que no introduce frontera real.

## Pruebas por capa

- Dominio: pruebas rápidas de invariantes y políticas.
- Aplicación: casos de uso con puertos fake/mock razonables.
- Adaptadores: integración real o Testcontainers cuando aplique.
- API/presentación: contratos, serialización, navegación y estados.
- End-to-end: solo flujos críticos.

Las pruebas deben verificar comportamiento, no la existencia ceremonial de capas.

## Señales de violación

- Widget que llama Firebase/R2/HTTP directamente.
- Controlador REST que calcula puntos o abre transacciones complejas.
- Entidad JPA devuelta como JSON.
- Dominio importando clases de Spring o Flutter.
- Caso de uso que construye comandos FFmpeg.
- Repositorio que decide permisos de negocio sin contrato explícito.
- Módulo accediendo directamente al repositorio o tabla de otro.
- Objeto externo propagado por toda la aplicación.
- Clase “Manager” o “Service” con múltiples capacidades no relacionadas.
