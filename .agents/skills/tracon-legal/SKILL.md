---
name: tracon-legal
description: Audita y redacta la privacidad, política de tratamiento, términos, normas UGC, seguridad infantil, eliminación de cuentas, Google Play y alcance regional de Tracon con evidencia verificable y sin declarar cumplimiento no validado.
---

# Tracon Legal

## Autoridad y alcance

Esta skill es la fuente canónica de método para `legal/`, `docs/legal/` y el
contenido legal público de `web/`. No sustituye asesoría jurídica ni convierte
una revisión técnica en una opinión legal. La entidad responsable, los canales
formales, las bases jurídicas, las jurisdicciones y la aprobación de publicación
deben provenir de evidencia confirmada por la empresa o su asesoría.

## Cuándo cargarla

Cárgala cuando cambien o se auditen privacidad, tratamiento de datos, términos,
derechos de usuarios, moderación con impacto legal, seguridad infantil, UGC,
eliminación de cuentas, Data Safety, Google Play, transferencias internacionales
o documentos/regiones legales. Añade la skill técnica de cada capa afectada.

## Skills compañeras

- `tracon-product`: alcance, elegibilidad, reglas funcionales y decisiones de producto.
- `tracon-backend`: datos, proveedores, seguridad, retención y contratos ejecutables.
- `tracon-mobile`: permisos, enlaces y flujos visibles en la app.
- `tracon-notifications`: push, dispositivos, email y preferencias.
- `tracon-safety-moderation`: reportes, bloqueos, UGC y seguridad infantil.
- `tracon-web` + `tracon-ux-copy`: rutas, contenido y copy legal público.
- `tracon-infrastructure`: logs, backups, proveedores operativos y despliegue web.
- `tracon-quality`: auditoría transversal y validación final.

## Flujo obligatorio

1. Inventariar el comportamiento real con rutas, código, migraciones, configuración y pruebas.
2. Separar hechos, inferencias, configuración pendiente y decisiones jurídicas.
3. Marcar datos faltantes como `LEGAL_TODO: [dato requerido]` y riesgos como `LEGAL_REVIEW_REQUIRED`.
4. Consultar fuentes oficiales vigentes, registrar URL, fecha de consulta, alcance y cambio relevante.
5. Redactar por separado términos, aviso de privacidad, política colombiana de tratamiento, normas de comunidad y seguridad infantil cuando corresponda.
6. Versionar cada documento con idioma, fecha, estado, entidad responsable y hash del contenido aprobado o prepublicado.
7. Verificar que la app y la web enlacen las versiones públicas, que la eliminación exista dentro y fuera de la app y que el copy no prometa controles no implementados.
8. Validar primero localmente; desplegar solo el artefacto web autorizado y conservar rollback.

Para la presentación pública, lee `references/public-document-presentation.md`.
La fuente canónica y la separación entre body público, metadata interna y
aceptación versionada deben mantenerse aunque cambie la capa consumidora.
Para la aceptación confirmada por servidor, lee
`references/legal-acceptance-server-confirmation.md`.

## Invariantes

- No inventar NIT, domicilio, representante, correo jurídico, proveedor, país,
  plazo de retención, certificación, consentimiento, edad mínima o cumplimiento.
- `VIAX TECHNOLOGY S.A.S.` es el nombre observado en el repositorio; su
  información corporativa formal sigue requiriendo confirmación documental.
- La aceptación legal solo se afirma como registrada si existe un flujo que la
  capture y la consulta. Un esquema de base de datos sin consumidor no es prueba.
- La eliminación pública e interna debe describir el flujo real: ocultamiento,
  revocación de sesiones, fecha efectiva, recuperación explícita, purga por
  etapas y retenciones mínimas restringidas.
- UGC requiere normas, reportar, bloquear, moderación, proceso de seguridad
  infantil y contacto formal antes de afirmar preparación para Play.
- No afirmar cumplimiento global. La aplicabilidad regional depende de destino,
  audiencia, umbrales, transferencias y decisión jurídica documentada.

Las URLs legales públicas declaradas a Google Play deben conservarse accesibles
y rastreables cuando corresponda; un redirect canónico intencional es válido y
no se elimina solo por aparecer como «Página con redirección». Su validación
técnica se coordina con docs/operations/search-indexing.md.

### Guardrails de publicación social

1. Cada superficie UGC —perfil, post, Trak, comentario, respuesta, mensaje
   directo, comunidad, mensaje de comunidad, audio y adjunto— debe tener una
   ruta visible de reporte, bloqueo cuando aplique, moderación persistida y
   escalamiento infantil antes de marcarla como lista para Play.
2. Todo cambio material de datos o tratamiento exige actualizar Privacidad, la
   política de tratamiento y la matriz Data Safety; cada SDK, proveedor,
   integración externa y flujo de anuncios debe aparecer en la matriz con
   finalidad, datos, compartición, retención y base de confirmación.
3. `Audio original` es atribución técnica, nunca propiedad o licencia.
   `MATCHED`/`NO_MATCH` de reconocimiento no demuestra infracción. `LICENSED`
   solo puede usarse con evidencia contractual de alcance, territorio y
   vigencia; sin ella, `rights_status=UNKNOWN`.
4. Una app social/UGC debe tener una página pública y funcional de seguridad
   infantil, normas contra CSAE/CSAM y grooming, mecanismo in-app, contacto
   operativo y procedimiento verificable. Si falta cualquiera, conservar
   `LEGAL_REVIEW_REQUIRED`.
5. No hardcodear versiones, hashes o URLs legales en consumidores cuando el
   manifiesto canónico pueda suministrarlos. Toda copia debe sincronizarse y
   verificarse por SHA-256; una URL pública no sustituye una aceptación de
   servidor.
6. Una modificación material crea una versión nueva; nunca se sobrescribe el
   documento histórico ni se cambia un hash sin actualizar el manifiesto,
   backend, app, web y pruebas.
7. El copy visible debe hablarle a la persona usuaria: no mostrar `backend`,
   `API`, `worker`, `mediaId`, `MATCHED`, nombres de tablas, secretos ni estados
   internos como si fueran decisiones legales.

## Regla permanente de cambios

Todo UGC nuevo debe comprobar la aceptacion legal vigente en la frontera comun
del backend antes de crear o editar publicaciones, Traks, comentarios,
respuestas, mensajes, contenido de comunidades, medios o perfil. Un cambio
material de datos, proveedores, retencion, UGC, moderacion, edad, pagos,
publicidad o IA exige revisar y versionar Privacidad, Terminos, Data Safety y
el gate de aceptacion antes de habilitarlo.

Para audio generado o aportado por usuarios, `Audio original` es solo una atribución técnica y nunca equivale a licencia. Los estados de derechos, reutilización y retirada deben permanecer bajo `LEGAL_REVIEW_REQUIRED` hasta contar con evidencia y política aprobadas; consulta `docs/legal/audio-rights-review.md`.

El reconocimiento de una grabación y la política interna de plataforma permanecen separados de `rights_status`. Si el proveedor no entrega datos explícitos de derechos, conserva `UNKNOWN`; nunca derives copyright de `MATCHED`.

Las cuotas de producto y las exenciones de beta no son una afirmación de
cumplimiento legal ni alteran el gate de aceptación, moderación, eliminación,
seguridad infantil o derechos. Cualquier cambio material de datos o retención
requiere la revisión legal canónica correspondiente.

El copy de un aviso de audio debe decir que la identificación no determina por
sí sola una infracción y mostrar el estado interno `En revisión`. En `shadow`
el aviso no es una retirada automática; las acciones del creador deben apuntar
solo a endpoints reales y el estado legal del flujo permanece
`LEGAL_REVIEW_REQUIRED`.

## Cierre

Revisar diff, secretos, metadatos, enlaces, hashes, rutas públicas, Data Safety,
retención, backups, aceptación, cuenta infantil, contacto de seguridad infantil
y pendientes. Reportar explícitamente lo no verificado y no cerrar el trabajo con
un documento legal que siga diciendo “definitivo” cuando está en prepublicación.

En eliminación, distinguir borrado de contenido de retención mínima legal,
moderación, copyright, licencias y ledger técnico. Un reclamo recibido por URL
no crea por sí solo un hold automático: hasta existir un target canónico, el
operador debe vincularlo explícitamente en moderation.content_holds.

El portal operativo no se presenta como evidencia de cumplimiento: seguridad
infantil, copyright, soporte y aceptación deben conservar las marcas de
revisión pendientes de docs/operations/.
