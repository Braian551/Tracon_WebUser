# Responsive web

La implementación es mobile-first y se comprueba en 360, 390, 430, 768, 1024,
1280, 1440 y 1920 px. En cada ancho valida `scrollWidth <= clientWidth`, títulos,
CTA, visuales, navegación, footer, documentos y formularios.

- 360–430: una columna, targets cómodos y padding contenido.
- 768: navegación móvil y composiciones apiladas; no comprimir la cabecera desktop.
- 1024: composiciones dobles solo si el contenido conserva ancho útil.
- 1280–1920: limita la lectura con un contenedor máximo; no escala títulos de
  forma ilimitada ni llena espacio con tarjetas sobredimensionadas.

Define dimensiones de imágenes y evita que un mockup o decoración cree overflow.
No ocultes contenido esencial para resolver un breakpoint.
