# SEO y rendimiento web

## SEO

Cada ruta pública mantiene title, description, canonical, Open Graph y Twitter/X.
El postbuild genera HTML por ruta; `robots.txt`, `sitemap.xml`, manifest y favicon
son archivos reales. Los datos estructurados solo describen hechos comprobados.

## Rendimiento

No agregues dependencias para fades, iconos simples o estado de tema. Define tamaño
de imágenes, carga diferida bajo el fold cuando exista contenido raster pesado y
no retrases el recurso LCP por rutina.

Objetivos de producto: LCP <= 2.5 s, INP <= 200 ms y CLS <= 0.1. Una medición local
no se reporta como dato de campo. Revisa tamaño gzip del build, errores de consola,
saltos de layout, caché larga para assets hasheados y refresco corto para HTML.
