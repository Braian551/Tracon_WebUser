# Política de eliminación de cuenta

La implementación calcula en backend una ventana máxima de recuperación del producto y una fecha legal aplicable por jurisdicción. La fecha efectiva es la más temprana; Flutter solo presenta `recoverableUntil`/`scheduledDeletionAt`.

Durante `DEACTIVATED` se conservan perfil, contenido, relaciones y medios, pero la cuenta queda fuera de visibilidad y creación de interacciones. Durante `DELETION_PENDING` se aplica el mismo ocultamiento y se revocan sesiones. `DELETION_PROCESSING` es irreversible.

La purga elimina PII, credenciales, relaciones, contenido propio, trabajos, cachés y assets exclusivos. Los mensajes ya enviados se minimizan para conservar la integridad conversacional. Comunidades, retos, juegos y auditorías compartidas no se destruyen accidentalmente; solo conservan la referencia mínima necesaria a un tombstone.

Firebase se revoca al ocultar y se elimina después de PostgreSQL, R2 y Redis. Los fallos quedan en la solicitud por etapa y reintento. La política de privacidad debe describir cualquier retención legal con motivo y `retentionUntil`.
