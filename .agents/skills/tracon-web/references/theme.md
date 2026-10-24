# Temas de la web

La preferencia admite `system`, `dark` y `light`. `system` es el valor inicial y
resuelve `prefers-color-scheme`; las selecciones se guardan con la clave
**tracon-theme**.
Mientras la preferencia siga en `system`, los cambios del sistema se reflejan en
tiempo real.

`public/theme-init.js` aplica el tema y `color-scheme` antes de cargar el cliente.
Debe permanecer pequeño, same-origin y compatible con la CSP. No usa cookies.

Dark usa superficies oscuras escalonadas, texto suave y rojo Tracon sin glow
excesivo. Light usa fondo cálido, superficies blancas, texto oscuro suave,
bordes rosados/grises y el mismo rojo de marca. No usa filtros ni inversión.

El selector funciona en todas las rutas, anuncia su estado, usa botón compacto en
desktop y vive dentro del menú móvil.
