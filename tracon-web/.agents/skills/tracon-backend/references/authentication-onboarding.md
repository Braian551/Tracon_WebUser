# Firebase y onboarding de perfil

## Fuente de verdad

Firebase autentica la identidad; `identity.users` conserva la cuenta interna y PostgreSQL decide el estado, username y permisos. La primera resolución de una identidad Firebase verificada crea el usuario activo con `profile.user_profiles.username` y `username_normalized` en `NULL`. En el flujo de correo, una identidad Firebase `password` aún no verificada también puede provisionarse únicamente si existe un challenge de registro ya consumido por el backend. Nunca se genera un username desde el correo, UID o un sufijo aleatorio.

El esquema actual permite esos `NULL`; no se crea una migración para este flujo mientras `V003__profiles_and_preferences.sql` siga siendo la autoridad compatible.

## Bootstrap y contrato

`GET /api/v1/me/account/status` devuelve el estado de cuenta y el bloque explícito:

```json
{"onboarding":{"required":true,"step":"USERNAME","suggestedDisplayName":"...","suggestedAvatarUrl":"..."}}
```

`suggestedDisplayName` y `suggestedAvatarUrl` solo aparecen durante la primera
alta Google cuando el marcador server-side está pendiente. El cliente puede
usarlos para prellenar la pantalla, pero no los convierte en la fuente del
perfil.

Un usuario `active` con `onboarding.required=true` solo puede consultar el estado, obtener sugerencias y completar `/api/v1/onboarding/username`. No puede leer ni publicar contenido, interactuar socialmente, usar chat, medios u otras rutas protegidas hasta completar el paso.

`GET /api/v1/onboarding/username/suggestions` devuelve candidatos disponibles derivados del display name. Es el único endpoint de onboarding permitido sin bearer para que el registro por correo pueda mostrar sugerencias antes de crear Firebase; limita el nombre a 100 caracteres, aplica rate limit por IP y consulta disponibilidad en un lote acotado. `POST /api/v1/onboarding/username` recibe `displayName` y `username` en la misma operación; valida el nombre con las mismas reglas del perfil (`2..100`, no vacío ni controles) y persiste el username normalizado en minúsculas, de 3 a 30 caracteres (`a-z`, números, punto y guion bajo).

En el registro mobile por correo, el orden visible es `correo/OTP -> borrador de
perfil -> contraseña -> consentimiento legal`. La interfaz recoge el
consentimiento antes de crear Firebase, pero no persiste una aceptación local.
Como el estado y la escritura legal exigen bearer, la aplicación crea la
identidad Firebase, ejecuta el bootstrap y confirma allí la versión autoritativa
antes de enviar `POST /api/v1/onboarding/username`. Si los hashes no coinciden,
vuelve a presentar el manifiesto del servidor. Una identidad provisional sin
aceptación no puede publicar, subir medios, enviar mensajes, editar perfil ni
crear contenido de comunidades; el cliente mantiene la sesión en registro y no
monta Home, feed, chats ni WebSocket durante esas operaciones. Google y el
onboarding de usuarios existentes siguen usando la vista canónica de perfil,
sin añadirles un paso de contraseña.

`GET /api/v1/legal/status` es la autoridad de versiones vigentes y
`POST /api/v1/legal/acceptance` valida `consentAttemptId`, version, hash, locale,
plataforma y app desde un manifiesto canonico. El servidor asigna `accepted_at`
en UTC; el cliente nunca envia ni sustituye ese timestamp. La operacion es
transaccional e idempotente y conserva historial inmutable.

La escritura debe confirmar de forma atómica intento, aceptaciones y bootstrap;
un error de persistencia no puede capturarse dentro de la misma transacción para
simular un éxito. Una carrera al registrar una versión debe revalidar hash y
ubicación contra el manifiesto ganador. Los logs solo contienen identificadores
de flujo, HTTP, código seguro, tipo de excepción y claves documentales
sanitizadas; nunca Bearer, UID, correo, hashes completos ni body.

## Unicidad e idempotencia

La disponibilidad es solo una ayuda de UX. La reserva real es un `UPDATE` condicional que exige perfil incompleto y cuenta `active`, protegido por la unicidad de `profile.user_profiles.username_normalized`. Una carrera devuelve `USERNAME_TAKEN`; repetir el mismo username para el mismo usuario es idempotente; otro username después de completar devuelve `USERNAME_ALREADY_SET`.

Un login Firebase posterior resuelve primero por `firebase_uid` y no modifica el perfil existente. Google no sincroniza continuamente `displayName` ni `photoURL`; el marcador one-shot se consume incluso si la importación de foto falla. La foto, si se importa, pasa por el puerto de media, R2, manifiesto y worker existentes, y el perfil solo expone la URL canónica cuando el asset está listo. La vinculación por correo solo aplica a cuentas legacy coherentes y conserva sus identificadores.

## Ciclo de cuenta

Los estados `deactivated`, `deletion_pending` y `deletion_processing` conservan sus reglas de recuperación. El gating de onboarding no debe abrir rutas de recuperación ni sustituir el flujo existente de lifecycle. El cliente debe resolver el paso antes de construir navegación pública y evitar mostrar temporalmente home o contenido a una cuenta incompleta. El marcador Google no reabre onboarding en una cuenta ya completada ni activa un backfill de perfiles legacy.
