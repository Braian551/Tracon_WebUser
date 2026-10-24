# Selección responsable de patrones

## Principio

Un patrón es una herramienta para una presión de diseño repetible. No es un objetivo. La solución correcta puede ser código directo, una función, composición simple, una restricción de base de datos o un contrato pequeño.

## Proceso de decisión

1. Describe el comportamiento actual y el dolor observable.
2. Identifica qué cambia y qué debe permanecer estable.
3. Determina la frontera: UI, aplicación, dominio, persistencia, proveedor o proceso.
4. Evalúa primero la solución directa más simple.
5. Selecciona un patrón solo si reduce acoplamiento, duplicación o riesgo de cambio.
6. Limita el patrón al módulo que lo necesita.
7. Prueba por contrato y comportamiento.
8. Revisa después si el número de abstracciones sigue justificado.

## Mapa de síntomas

| Síntoma | Considerar | Evitar |
|---|---|---|
| Varios algoritmos seleccionables | Strategy | `switch` distribuido o herencia profunda |
| Comportamiento cambia por estado y hay transiciones | State | booleanos combinados y `if` repetidos |
| SDK/proveedor externo contamina el código | Adapter | usar modelos externos en dominio |
| Creación depende de tipo/configuración | Factory Method o fábrica simple | fábrica para una sola construcción trivial |
| Objeto complejo con muchas opciones válidas | Builder | constructor telescópico o setters inválidos |
| Acción debe encolarse, reintentarse o ser idempotente | Command | ejecutar efecto directamente desde transporte |
| Validaciones independientes y ordenables | Chain of Responsibility | método gigante con todos los casos |
| Subsistema complejo necesita una entrada estable | Facade | “God service” que acumula negocio |
| Agregar comportamiento transversal por composición | Decorator | herencia combinatoria |
| Reacción interna a eventos | Observer | usarlo para eventos durables entre procesos |
| Flujo fijo con pasos especializados | Template Method | jerarquía si Strategy/composición es más clara |
| Árbol parte-todo uniforme | Composite | modelar jerarquías que no existen |
| Acceso controlado, lazy o remoto | Proxy | ocultar llamadas costosas sin hacerlo explícito |
| Desacoplar abstracción de implementación variable | Bridge | duplicar jerarquías sin variación real |
| Guardar/restaurar estado de edición | Memento | persistir estados críticos sin auditoría |
| Operaciones sobre estructura estable con muchas operaciones | Visitor | agregar complejidad en modelos que cambian seguido |

## SOLID aplicado

### Responsabilidad única

Una unidad tiene una razón coherente para cambiar. No significa una clase por método. Separa cuando mezcla negocio, transporte, persistencia, UI o proveedor.

### Abierto/cerrado

Permite extensiones donde existe variación real. No diseñes puntos de extensión especulativos.

### Sustitución de Liskov

Una implementación debe cumplir el contrato completo sin excepciones inesperadas, efectos adicionales ni precondiciones más estrictas.

### Segregación de interfaces

Define contratos pequeños desde la necesidad del consumidor. No obligues a implementar métodos no aplicables.

### Inversión de dependencias

El código de alto nivel depende de abstracciones internas; los adaptadores externos implementan esas abstracciones.

## Preguntas antes de crear una abstracción

- ¿Existe más de una implementación actual o una frontera externa real?
- ¿La prueba necesita sustituir esta dependencia?
- ¿El consumidor requiere todo el contrato?
- ¿La abstracción tiene vocabulario del negocio o solo replica el framework?
- ¿La nueva capa elimina conocimiento o solamente reenvía llamadas?
- ¿Podría resolverse con una función o composición simple?

## Antipatrones de sobrearquitectura

- Interfaz y clase `Impl` uno a uno sin frontera ni variación.
- Repository sobre otro repository que solo delega.
- Mapper que copia campos idénticos dentro de la misma frontera sin beneficio.
- Factory que siempre devuelve la misma clase.
- Strategy con una sola opción y sin cambio previsto real.
- Evento para llamadas que requieren respuesta sincrónica inmediata.
- Clases `Manager`, `Helper`, `Utils` o `CommonService` que acumulan responsabilidades.
- Capas vacías creadas para cumplir un diagrama.
- Patrones anidados que dificultan seguir un flujo sencillo.

## Registro mínimo de decisión

Para un patrón local, basta un comentario o documentación cercana cuando la intención no sea obvia. Para una decisión transversal o difícil de revertir, crea o actualiza un ADR con:

- Contexto.
- Fuerzas y restricciones.
- Alternativas.
- Decisión.
- Consecuencias.
- Validación.
