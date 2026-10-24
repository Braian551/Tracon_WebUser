# Backend: seguridad, API, correo, fechas, alineación y secretos

Referencia para autenticación, autorización, verificación, correo, UTC, API REST, contratos, logs y configuración sensible.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 19. AUTENTICACIÓN Y SEGURIDAD

## 19.1 Spring Security

Spring Security será la capa principal para:

- Autenticación.
- Autorización.
- Protección de endpoints.
- Roles y permisos.
- Gestión de credenciales.
- Filtros de seguridad.
- Protección ante ataques comunes.

No construir un sistema de autenticación artesanal.

## 19.2 Contraseñas

- Usar `PasswordEncoder`.
- Preferir Argon2id cuando la compatibilidad esté verificada.
- Usar bcrypt con costo apropiado como alternativa.
- Nunca MD5, SHA-1 o SHA-256 directo.
- Nunca cifrado reversible.
- Nunca guardar contraseñas en logs.
- Revisar parámetros con pruebas de rendimiento.

## 19.3 Tokens

Estrategia recomendada:

- Access token de corta duración.
- Refresh token aleatorio.
- Refresh token almacenado de forma hash.
- Rotación.
- Detección de reutilización.
- Revocación por dispositivo.
- Cierre global de sesiones.
- Registro de eventos de seguridad.

No guardar el refresh token en texto plano en PostgreSQL.

## 19.4 Autorización

No basta con que el usuario esté autenticado.

Cada operación debe verificar:

- Propiedad del recurso.
- Rol.
- Estado de cuenta.
- Bloqueos.
- Permiso del módulo.
- Visibilidad.
- Relación social.
- Estado de moderación.

Prevenir IDOR.

## 19.5 Rate limiting

Aplicar límites a:

- Registro.
- Login.
- Reenvío de correo.
- Verificación de código.
- Recuperación de contraseña.
- Votos.
- Comentarios futuros.
- Creación de retos.
- Carga de medios.
- Reportes.
- Búsqueda de usuarios.
- WebSockets.

## 19.6 Entradas

Toda entrada debe validarse en:

1. Cliente para experiencia.
2. Backend para seguridad.

El backend es la autoridad.

## 19.7 Respuestas de error

No devolver:

- Stack traces.
- SQL.
- Claves.
- Tokens.
- Rutas internas.
- Excepciones sin filtrar.
- Datos de otros usuarios.

Usar formato uniforme:

```json
{
  "code": "CHALLENGE_NOT_FOUND",
  "message": "No fue posible encontrar el reto.",
  "requestId": "..."
}
```

---

---

# 20. VERIFICACIÓN DE CORREO Y DOBLE FACTOR

## 20.1 Componente global Flutter

Debe existir un componente global reutilizable para:

- Ingresar código.
- Avanzar entre casillas.
- Pegar código.
- Mostrar tiempo.
- Reenviar.
- Mostrar intentos.
- Mostrar errores.
- Accesibilidad.

El widget no decide reglas de seguridad.

## 20.2 Backend

El código debe:

- Ser aleatorio.
- Tener expiración corta.
- Guardarse hash.
- Ser de un solo uso.
- Tener límite de intentos.
- Tener límite de reenvíos.
- Invalidar códigos anteriores.
- Asociarse a propósito.
- Asociarse a usuario o sesión.
- No aparecer en logs.

Propósitos separados:

```text
email_verification
login_2fa
password_reset
change_email
delete_account
```

No reutilizar un código para varios propósitos.

---

---

# 21. PLANTILLAS GLOBALES DE CORREO

## 21.1 Regla absoluta

No escribir HTML completo dentro de servicios Java o Go.

## 21.2 Estructura

```text
backend/core-api/src/main/resources/templates/email/
├── layouts/
│   └── base.html
├── fragments/
│   ├── header.html
│   ├── footer.html
│   ├── button.html
│   └── security_notice.html
├── auth/
│   ├── verify_email.html
│   ├── login_code.html
│   ├── password_reset.html
│   └── account_deletion.html
├── moderation/
│   └── action_notice.html
└── notifications/
    └── generic_notification.html
```

## 21.3 Reglas

Toda plantilla debe:

- Reutilizar layout.
- Tener versión texto plano.
- Tener asunto centralizado.
- Ser compatible con UTF-8.
- Escapar contenido.
- No revelar datos innecesarios.
- Incluir tiempo de expiración cuando corresponda.
- Incluir aviso si el usuario no solicitó la acción.
- Usar identidad de Tracon y VIAX TECHNOLOGY S.A.S.
- Mantener enlaces configurables.
- No hardcodear dominio.

---

---

# 22. ZONAS HORARIAS Y FECHAS

## 22.1 Regla absoluta

Nunca usar la zona horaria local del servidor como zona del usuario.

## 22.2 Fuente de verdad

- PostgreSQL almacena UTC.
- APIs devuelven ISO 8601.
- Flutter muestra la hora convertida.

## 22.3 Orden de prioridad

1. Zona IANA detectada por el dispositivo.
2. Zona preferida guardada en la cuenta.
3. Zona aproximada por IP como respaldo.
4. UTC como último respaldo.

La IP no debe ser la fuente principal porque puede verse afectada por:

- VPN.
- Proxy.
- Operador móvil.
- Ubicación imprecisa.

## 22.4 Reglas

- El cliente envía una zona como `America/Bogota`.
- El backend valida que sea una zona IANA.
- No guardar únicamente desplazamientos como `-05:00`.
- No aplicar reglas de horario local dentro de SQL sin documentación.
- Las ventanas diarias deben indicar la zona que las define.
- Los podios diarios deben documentar su zona de corte.
- No usar `LocalDateTime.now()` sin un `Clock` inyectable en reglas críticas.
- Las pruebas deben poder fijar el tiempo.

---

---

# 26. API REST

## 26.1 Versionado

```text
/api/v1/
```

## 26.2 Convenciones

- Sustantivos en rutas.
- Métodos HTTP correctos.
- Paginación por cursor para feeds.
- Paginación por página solo para listados administrativos pequeños.
- Respuestas uniformes.
- Idempotency-Key para operaciones sensibles.
- `request_id`.
- UTC.
- OpenAPI actualizado.
- Límites de tamaño.
- Códigos de error estables.

## 26.3 Ejemplos

```text
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/email-verifications
POST   /api/v1/auth/email-verifications/confirm
GET    /api/v1/games
GET    /api/v1/challenges
POST   /api/v1/challenges
POST   /api/v1/challenge-submissions
PUT    /api/v1/challenge-submissions/{id}/vote
GET    /api/v1/leaderboards
POST   /api/v1/media/uploads
POST   /api/v1/accounts/deletion-requests
DELETE /api/v1/accounts/deletion-requests/current
```

## 26.4 No exponer modelos internos

Los DTOs de API son independientes de:

- Filas SQL.
- Entidades de dominio.
- Mensajes de cola.
- Nodos de Neo4j.
- Clases internas.

---

---

# 27. ALINEACIÓN DE DATOS

Cuando se modifique:

- Estado.
- Enum.
- Rol.
- Tipo de voto.
- Tipo de reto.
- Tipo de medio.
- Evento.
- Clave Redis.
- Nombre de campo.
- Contrato.
- Código de error.

Se debe verificar:

```text
FUENTES VERIFICADAS

- Escritura:
- Lectura:
- SQL:
- Flutter:
- Spring:
- Go:
- Redis:
- Workers:
- WebSocket:
- OpenAPI:
- Tests:
- Documentación:
```

No renombrar un valor compartido revisando un solo archivo.

Si existe duda:

```text
NO ELIMINAR
NO RENOMBRAR
NO NORMALIZAR
```

hasta confirmar consumidores.

---

---

# 37. OBSERVABILIDAD

## 37.1 Logs

Todos los servicios deben usar logs estructurados con:

- Timestamp UTC.
- Nivel.
- Servicio.
- Entorno.
- `request_id`.
- Evento.
- Duración.
- Código de error.

No registrar:

- Contraseñas.
- Códigos.
- Tokens.
- Cookies.
- URLs firmadas completas.
- Contenido privado.
- Datos personales innecesarios.

## 37.2 Métricas

Mínimas:

- Solicitudes.
- Latencia.
- Errores.
- Logins fallidos.
- Rate limits.
- Trabajos pendientes.
- Trabajos fallidos.
- Tiempo de transcodificación.
- Uso de disco temporal.
- Caché hit/miss.
- Conexiones DB.
- Conexiones WebSocket futuras.

## 37.3 Health checks

Separar:

- Liveness.
- Readiness.
- Dependencias.

No exponer detalles sensibles públicamente.

---

---

# 45. CONFIGURACIÓN Y SECRETOS

## 45.1 Archivos

```text
.env.example
```

Sí se versiona.

```text
.env
```

No se versiona.

## 45.2 Secretos

- R2.
- JWT.
- SMTP.
- PostgreSQL.
- Redis.
- Neo4j.
- Claves internas.
- APIs externas.

No deben:

- Aparecer en Git.
- Estar en imágenes.
- Estar en logs.
- Enviarse a Flutter.
- Estar en documentación pública.

## 45.3 Rotación

Toda clave debe poder rotarse.

JWT debe soportar identificador de clave cuando se utilice firma asimétrica.

---
