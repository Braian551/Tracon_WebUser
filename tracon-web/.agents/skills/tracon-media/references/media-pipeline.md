# Medios: imágenes, video HLS y cliente Flutter

Referencia del flujo de video, estados, calidades, rutas, seguridad y reproducción cliente.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 15. PROCESAMIENTO DE VIDEO HLS

## 15.1 Regla absoluta

No entregar archivos MP4 completos al cliente para reproducción normal.

Todo video publicado debe procesarse a HLS.

## 15.2 Flujo obligatorio

1. Flutter solicita autorización de carga.
2. El backend valida:
   - Usuario.
   - Tipo de contenido.
   - Tamaño.
   - Extensión.
   - MIME.
   - Estado de la cuenta.
   - Límites.
3. El backend genera una URL de carga firmada para R2.
4. Flutter sube el archivo original directamente a R2.
5. Flutter notifica finalización.
6. El backend crea un trabajo idempotente.
7. El worker Go consume el trabajo.
8. Descarga el original a un volumen temporal.
9. Valida el archivo mediante `ffprobe`.
10. Ejecuta FFmpeg.
11. Genera:
    - `master.m3u8`.
    - Playlist por calidad.
    - Segmentos `.ts` o `.m4s`.
    - Miniatura.
    - Metadatos.
12. Sube el resultado a R2.
13. Actualiza el estado.
14. Elimina archivos temporales.
15. Aplica política de eliminación al original cuando corresponda.
16. El cliente recibe metadatos y URL de reproducción.
17. Los segmentos se entregan directamente mediante almacenamiento o CDN.

La publicación que consume el medio permanece fuera de feeds y detalles hasta que todos sus
derivados obligatorios estén `ready`. La transición final del medio y la publicación debe ser
transaccional e idempotente; `published_at` corresponde a ese momento. El flujo ejecutable y
los perfiles se documentan en `docs/architecture/media-processing.md` y se configuran en
`config/media-processing-profiles.json`.

## 15.3 Estados de medios

```text
pending_upload
uploaded
queued
processing
ready
failed
blocked
deleted
```

Los estados de UI pendientes pertenecen al coordinador global de Flutter y no se representan
como tarjetas ni shimmer dentro del feed público.

## 15.4 Calidades

No generar calidades mayores que la fuente.

Ejemplo inicial condicionado por la resolución original:

```text
360p
480p
720p
```

1080p solo cuando exista necesidad, capacidad y política de costos.

## 15.5 Seguridad de medios

- Nombres aleatorios.
- Buckets o prefijos separados por entorno.
- URLs firmadas cuando el contenido no sea público.
- Validación por firma real del archivo.
- Límites de duración.
- Límites de tamaño.
- Timeout de FFmpeg.
- Límites de CPU y memoria.
- Directorio temporal por trabajo.
- Eliminación segura.
- No ejecutar comandos de shell concatenando entrada del usuario.
- No aceptar rutas proporcionadas directamente por el cliente.
- Registrar hash del objeto.
- Evitar path traversal.

## 15.6 Rutas sugeridas en R2

```text
tracon/{env}/users/{user_id}/uploads/raw/{media_id}/source
tracon/{env}/users/{user_id}/media/{media_id}/hls/master.m3u8
tracon/{env}/users/{user_id}/media/{media_id}/hls/720p/index.m3u8
tracon/{env}/users/{user_id}/media/{media_id}/thumb/poster.webp
```

## 15.7 Cliente Flutter

El cliente debe:

- Reproducir HLS.
- Mostrar miniatura.
- Cargar solo al entrar en viewport.
- Pausar al salir de viewport.
- Liberar controladores.
- No reproducir múltiples videos simultáneamente sin política.
- Respetar ahorro de datos.
- Mostrar estado de procesamiento.
- Manejar errores y reintentos limitados.

---

---

# 16. IMÁGENES

- Convertir a formatos eficientes cuando sea compatible.
- Crear miniaturas.
- No mostrar imagen original gigante en el feed.
- Definir límites de resolución.
- Eliminar metadatos sensibles cuando corresponda.
- Validar contenido real.
- Evitar nombres originales públicos.
- Servir mediante R2/CDN.
- Mantener dimensiones en metadatos para evitar saltos de diseño.

---
