# Flujo legal móvil

## Fuente de autoridad

`SessionController` conserva la fase de sesión y resuelve en una operación
single-flight la identidad Firebase, el estado de cuenta y el estado legal.
`LegalStatus` y la respuesta de `POST /api/v1/legal/acceptance` provienen del
backend; la caché local solo sirve como memoria auxiliar y nunca decide si se
abre el gate.

La fase no puede avanzar a `active` o `usernameSetup` mientras el estado legal
esté pendiente. Si la respuesta exige aceptación, la fase es
`legalRequired`. El router redirige a una ruta host neutral y no contiene
presentación modal.

## Presentación única

El host presenta `showLegalConsentBottomSheet` una vez desde un callback
posterior al montaje. Mantiene la future activa para evitar duplicados ante
rebuilds, refrescos del router, listeners de Firebase o respuestas repetidas.
La hoja es el único checklist de aceptación y abre la página reusable
`LegalDocumentPage(documentType)` sobre la misma ruta modal; volver conserva el
draft y los checks.

La aceptación llama al backend con el draft íntegro. Mientras espera, el botón
queda deshabilitado y muestra un indicador pequeño. La hoja solo se cierra tras
una respuesta exitosa; cualquier fallo conserva checks y permite reintentar.
Después de cerrar, el host aplica el `LegalStatus` recibido de forma atómica al
`SessionController`, guarda la huella como caché auxiliar y deja que el router
seleccione username o app.

La prueba se construye desde el `LegalStatus` remoto. Si el manifiesto local no
coincide con el remoto, no se envía una mezcla de versiones: se registra un
código seguro y se solicita sincronizar la aplicación. La regla transversal de
confirmación, idempotencia y logs seguros vive en
`tracon-legal/references/legal-acceptance-server-confirmation.md`.

Cancelar en una cuenta nueva o en una actualización obligatoria ejecuta el
sign-out canónico de Firebase y deja la fase en `signedOut`. No se conserva una
bandera local de reintento ni se reabre automáticamente.

## Flujos de entrada

- Google existente y vigente: autenticación, estado vigente, app; cero UI legal.
- Google nuevo: autenticación, resolución/provisionamiento mínimo, gate legal,
  username si corresponde, app.
- Google existente desactualizado: autenticación, una hoja, app.
- Email existente: mismo coordinador de sesión que Google.
- Registro email: usa el mismo componente de hoja; el contrato actual crea la
  identidad interna antes de registrar la aceptación y el bootstrap de sesión
  se ejecuta después para evitar una fase legal transitoria.

## Observabilidad segura

Los eventos permitidos son `legal_flow_required`, `legal_sheet_presented`,
`legal_sheet_reused`, `legal_document_opened`, `legal_document_closed`,
`legal_accept_started`, `legal_accept_success`, `legal_accept_failure`,
`legal_sheet_closed`, `legal_flow_completed` y `legal_flow_cancelled`. Solo
incluyen un identificador de flujo aleatorio y tipos/códigos seguros; nunca
email, UID, tokens, contenido legal ni hashes completos.
