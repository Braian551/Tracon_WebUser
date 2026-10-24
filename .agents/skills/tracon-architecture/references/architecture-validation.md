# Validación arquitectónica

## Revisión de dependencias

- ¿Las dependencias apuntan hacia negocio/aplicación?
- ¿Dominio importa framework, transporte, persistencia o SDK?
- ¿Existe acceso directo entre módulos que debería usar contrato/evento?
- ¿Hay ciclos de importación, inyección o llamadas?
- ¿Una capa conoce modelos internos de otra sin traducción?

## Revisión de responsabilidades

- ¿La unidad mezcla UI, negocio, persistencia, proveedor o infraestructura?
- ¿El nombre describe una intención concreta?
- ¿Los métodos cambian por razones relacionadas?
- ¿Un `Manager`, `Helper`, `Utils`, `Service` o controlador concentra demasiadas capacidades?
- ¿La lógica está en la capa que puede protegerla y probarla mejor?

## Revisión del patrón

- ¿Hay un problema observable que el patrón resuelve?
- ¿La alternativa directa fue considerada?
- ¿Existe variación real o frontera externa?
- ¿El patrón reduce condicionales, acoplamiento o duplicación?
- ¿Añade más archivos/conceptos de los que elimina?
- ¿Los participantes tienen nombres del dominio y no nombres genéricos?
- ¿La selección/configuración está centralizada?
- ¿Se puede probar cada implementación por contrato?

## Revisión de Clean Architecture

- Presentación/API solo traduce y coordina entrada/salida.
- Aplicación representa casos de uso y transacciones.
- Dominio conserva invariantes independientes.
- Infraestructura implementa puertos.
- DTO, dominio, persistencia y UI se separan al cruzar fronteras.
- Las abstracciones se crean por frontera o variación, no por ceremonia.

## Revisión de eventos

- ¿El evento es local o durable?
- ¿Puede perderse?
- ¿Necesita orden, reintento o idempotencia?
- ¿Se usa outbox cuando la entrega debe sobrevivir al proceso?
- ¿El consumidor tolera duplicados?
- ¿El evento evita acoplar módulos o solo oculta una llamada síncrona necesaria?

## Revisión de estados

- ¿Existe una lista central de estados válidos?
- ¿Las transiciones están controladas y probadas?
- ¿Se evitan combinaciones imposibles de booleanos?
- ¿La persistencia impide transiciones concurrentes inválidas?
- ¿Flutter, Spring, Go y base de datos comparten la misma semántica?

## Pruebas mínimas

- Prueba de dominio para invariantes.
- Prueba de aplicación por cada caso de uso modificado.
- Prueba de contrato para cada estrategia/adaptador relevante.
- Integración del adaptador real cuando su comportamiento externo importe.
- Pruebas de transición para State.
- Pruebas de orden/corte para Chain of Responsibility.
- Pruebas de selección para Factory/Strategy.
- Pruebas de idempotencia para Command/eventos durables.

## Criterio de aceptación

La arquitectura mejora cuando:

- El flujo es más fácil de seguir.
- Las reglas se prueban sin levantar frameworks externos.
- Cambiar proveedor o algoritmo afecta menos consumidores.
- Las invariantes tienen una única autoridad.
- Las dependencias y contratos son explícitos.
- La complejidad añadida es proporcional al riesgo y variación reales.

Si el patrón no cumple estos resultados, simplifica o retíralo.
