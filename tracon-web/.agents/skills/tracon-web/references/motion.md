# Motion web

- Centraliza duraciones y curvas en tokens `--motion-*` y `--ease-*`.
- Prioriza `transform` y `opacity`; evita animar dimensiones o posición continua.
- Reserva reveal para hero y secciones importantes; el contenido parte visible si
  JavaScript no se ejecuta.
- Los hovers nunca son la única señal de interacción.
- No uses scroll-jacking, parallax agresivo ni movimiento decorativo permanente.
- Con `prefers-reduced-motion: reduce`, desactiva smooth scroll, reveals,
  transforms y retrasos sin ocultar contenido.
