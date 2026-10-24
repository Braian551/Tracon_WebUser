# Producto: eliminación, legal, bloqueos, reportes y moderación

Referencia para retención, términos, privacidad, aceptación, menores, bloqueo y moderación.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 23. ELIMINACIÓN DE CUENTA Y RETENCIÓN

## 23.1 Regla legal importante

El periodo de 15 días para eliminación será una **política de gracia del producto**, no debe presentarse automáticamente como un plazo legal obligatorio de eliminación.

Los plazos legales para responder peticiones o reclamos y las obligaciones de conservación deben revisarse de manera independiente.

## 23.2 Flujo

1. Usuario solicita eliminación.
2. Se exige autenticación reciente.
3. Puede exigirse código de correo.
4. Se crea solicitud.
5. Se revocan sesiones.
6. Se desactiva la cuenta.
7. Se oculta del descubrimiento.
8. Se detienen notificaciones.
9. Se inicia periodo de gracia de 15 días.
10. El usuario puede cancelar durante el periodo.
11. Al finalizar, un worker ejecuta anonimización, supresión o conservación limitada según política.
12. Se registra evidencia de la operación.

## 23.3 No romper integridad

No borrar filas de forma indiscriminada.

Usar estrategias como:

- Autor anónimo.
- Usuario eliminado.
- Tombstone.
- Desvinculación de datos personales.
- Conservación limitada de auditoría.
- Eliminación de medios cuando legal y funcionalmente corresponda.

## 23.4 Publicaciones

No asumir que toda publicación se conserva para siempre.

La política debe definir:

- Qué se elimina.
- Qué se anonimiza.
- Qué se conserva.
- Base jurídica.
- Tiempo.
- Acceso.
- Solicitudes del titular.

La integridad técnica no está por encima de los derechos del titular.

## 23.5 Registros conservables

Pueden requerir conservación restringida:

- Seguridad.
- Prevención de fraude.
- Moderación.
- Evidencia de consentimiento.
- Cumplimiento legal.
- Defensa de reclamaciones.

Estos datos no pueden permanecer accesibles como perfil activo.

---

---

# 24. TÉRMINOS, PRIVACIDAD Y REGLAS DE COMUNIDAD

## 24.1 Estructura

```text
legal/
├── terms/es-CO/
│   ├── v1.0.0.md
│   └── metadata.json
├── privacy/es-CO/
│   ├── v1.0.0.md
│   └── metadata.json
└── community/es-CO/
    ├── v1.0.0.md
    └── metadata.json
```

## 24.2 Versionado

Toda versión debe incluir:

- Tipo.
- Versión.
- Fecha efectiva.
- Fecha de publicación.
- Idioma.
- País.
- Hash.
- Estado.
- Motivo del cambio.

## 24.3 Aceptación

Guardar:

- Usuario.
- Documento.
- Versión.
- Fecha UTC.
- IP minimizada o hash si está justificado.
- User agent reducido si está justificado.
- Método de aceptación.

No sobrescribir la aceptación anterior.

## 24.4 Cambios con impacto legal

Revisar documentos cuando se agregue o cambie:

- Cámara.
- Micrófono.
- Galería.
- Notificaciones.
- Contactos.
- Ubicación.
- Seguimiento.
- Perfil público.
- Mensajería.
- IA.
- Recomendaciones.
- Publicidad.
- Analítica.
- Moderación automatizada.
- Datos compartidos.
- R2 o nuevos proveedores.
- Eliminación de cuenta.
- Retención.
- Menores de edad.
- Pagos futuros.
- Onboarding.
- Welcome.
- Login o registro.
- Autenticación con Google u otros proveedores sociales.
- Copys de consentimiento mostrados antes del acceso.

## 24.5 Menores de edad

Antes de abrir el servicio a menores se debe definir y validar:

- Edad mínima.
- Consentimiento aplicable.
- Moderación.
- Configuración de privacidad.
- Mensajería.
- Reportes.
- Tratamiento de datos.
- Contenido permitido.

No publicar una política improvisada.

---

---

# 25. BLOQUEOS, REPORTES Y MODERACIÓN

## 25.1 Bloqueo

Un bloqueo debe afectar de manera coherente:

- Perfil.
- Seguimiento.
- Descubrimiento.
- Chat.
- Salas.
- Comentarios futuros.
- Notificaciones.
- Recomendaciones.
- Presencia.

## 25.2 Reportes

Un reporte debe incluir:

- Reportante.
- Tipo de objetivo.
- Objetivo.
- Motivo.
- Texto opcional.
- Evidencia.
- Estado.
- Prioridad.
- Fecha.
- Moderador.
- Resolución.

## 25.3 Moderación

Las acciones deben quedar auditadas:

- Ocultar.
- Restaurar.
- Advertir.
- Suspender.
- Bloquear carga.
- Congelar puntos.
- Revertir puntos.
- Eliminar contenido.
- Cerrar cuenta.

No permitir acciones irreversibles sin confirmación y trazabilidad.

---
