# Contenido legal y UGC web

## Fuente

La web consume los documentos estructurados en `web/src/content/legal.js`.
Cada documento tiene tipo, versión, fecha, estado, responsable, contacto y
secciones. La versión pública inicial es `0.1.0-draft` porque `legal/` y la
documentación del producto aún identifican datos corporativos y revisión
jurídica pendientes.

## Reglas de veracidad

- Usar solo proveedores y permisos presentes en el código: Firebase Auth,
  FCM, PostgreSQL, Redis, Cloudflare R2 y procesamiento multimedia.
- Describir la eliminación como el flujo real: ocultamiento, cierre de sesiones,
  fecha definitiva comunicada en el proceso, recuperación explícita y purga por
  etapas con retención mínima restringida. El texto visible no nombra componentes.
- No convertir la ventana del producto en un plazo legal universal ni copiar
  la política de Viax.
- No afirmar NIT, domicilio, certificaciones, licencias musicales, Play Store,
  redes sociales, punto de contacto CSAE o cumplimiento jurídico si no están
  confirmados.
- Publicar normas contra explotación y abuso sexual infantil y una ruta de
  reportes, dejando explícito cualquier punto de contacto formal aún pendiente.

La página puede ser públicamente accesible y útil para revisión, pero no debe
presentarse como versión jurídica definitiva hasta que el responsable la
apruebe y complete los datos faltantes.
