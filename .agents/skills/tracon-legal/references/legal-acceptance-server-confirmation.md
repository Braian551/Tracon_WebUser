# Aceptación legal confirmada por servidor

## Invariante transversal

El backend es la única autoridad para la versión vigente, el hash, la
localización, `accepted_at` y el estado de aceptación. El cliente puede
renderizar una copia local para comparar y mostrar el contenido, pero no puede
construir la prueba de aceptación desde una copia distinta al
`GET /api/v1/legal/status` de esa sesión.

El flujo válido es:

1. Resolver identidad Firebase y cuenta interna.
2. Consultar el estado legal vigente.
3. Si hace falta, mostrar los documentos y checklist del mismo manifiesto.
4. Enviar `consentAttemptId`, locale, plataforma, versión de app y la prueba
   completa de documentos requeridos.
5. Esperar una respuesta HTTP exitosa con `status.acceptanceRequired == false`.
6. Aplicar ese estado al coordinador de sesión y continuar al siguiente paso
   de onboarding o a la app.

Una excepción, timeout, respuesta no parseable o código HTTP no exitoso deja la
hoja abierta, conserva los checks y permite reintentar. Nunca se marca la
aceptación en caché ni se avanza de fase por un intento de red, por cerrar un
modal o por una respuesta parcial.

## Contrato y persistencia

El servidor valida que el conjunto de documentos, versiones, hashes y locale
coincida con el manifiesto canónico. La escritura debe ser una transacción
atómica que incluya el intento, las aceptaciones, el `accepted_at` generado en
UTC y el bootstrap mínimo de cuenta. La repetición del mismo
`consentAttemptId` y la repetición de los mismos documentos son idempotentes;
una carrera no puede crear una versión incompatible ni convertir un fallo de
restricción en un falso éxito.

Las respuestas de error deben exponer un código seguro y estable para la UI,
sin tokens, cuerpo legal, hashes completos, UID, email ni SQL. El registro
interno puede conservar `flow_id`, estado HTTP, código seguro, tipo de
excepción y claves documentales sanitizadas; nunca la credencial Bearer ni el
cuerpo completo de la solicitud.

## Contrato móvil

La hoja deshabilita el botón durante la solicitud y se cierra únicamente tras
la confirmación del servidor. El evento de éxito se emite después de validar la
respuesta. Los errores técnicos se muestran con copy humano y se registran con
campos sanitizados (`http_status`, `safe_error_code`, `exception_type`,
`document_codes`). Si la copia local y el manifiesto remoto difieren, el cliente
no envía pruebas ambiguas y solicita actualizar o sincronizar la aplicación.

## Validación mínima

Debe existir cobertura para aceptación inicial, replay idempotente, prueba
obsoleta o incompleta, respuesta no autorizada, fallo de persistencia sin
efectos parciales y transición posterior del bootstrap. La prueba PostgreSQL
debe ejecutarse con un motor real antes de declarar validado el comportamiento
transaccional.

## Puertas de completitud productiva

Nunca se declara completo un cambio de documentos legales si el manifiesto
autoritativo y los artefactos realmente desplegados no fueron verificados como
equivalentes en byte, versión y hash en producción. Un healthcheck `200` y un
`401` de un POST anónimo no constituyen un smoke test suficiente para un bug de
aceptación legal: se requiere una aceptación autenticada y controlada, seguida
de la comprobación de `acceptanceRequired == false`, persistencia atómica e
idempotencia.
