# Cloudflare R2 y seguridad de almacenamiento

Referencia para buckets, claves, URLs firmadas, CORS, lifecycle, prefijos y separación por entorno.

> Carga este archivo únicamente cuando la tarea toque su ámbito. Estas reglas provienen de la antigua skill maestra y se mantienen fuera de `SKILL.md` para reducir contexto.

# 46. CLOUDFARE R2

- Separar desarrollo y producción.
- Permisos mínimos.
- Tokens distintos.
- No usar credenciales maestras.
- Presigned URLs cortas.
- Validar tamaño antes y después.
- Registrar `object_key`, no URL permanente completa.
- Política de ciclo de vida.
- CORS limitado.
- No permitir listados públicos.
- CDN separado de API.
- Invalidación o versionado de objetos.
- El backend entrega metadatos, no hace proxy de archivos grandes.

---
