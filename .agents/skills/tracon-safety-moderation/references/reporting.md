# Reportes y moderación

Los tipos de destino normalizados son `user`, `post`, `trak`, `comment`, `direct_message` y `community_message`. El catálogo valida motivo y severidad; `child_safety` es crítico. El cliente envía `Idempotency-Key`; PostgreSQL evita duplicados por reportero y clave.

Guardar solo los datos mínimos necesarios: objetivo, motivo, detalle acotado y snapshot/hash protegido cuando exista. El reportero permanece privado frente al usuario reportado. Limitar por usuario/ventana y registrar auditoría sin tokens, PII innecesaria ni contenido sensible en logs.

La cola administrativa ordena críticos primero y solo roles `moderator`, `admin` o `superadmin` pueden consultar o decidir. Toda decisión crea `moderation.actions`, actualiza el estado del reporte y registra `platform.audit_events`. Suspender o restringir usa estado de moderación separado del lifecycle de cuenta.
