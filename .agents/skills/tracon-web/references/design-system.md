# Sistema de diseño web

## Fuente ejecutable

- `web/src/styles/tokens.css`: color semántico, tipografía, espacio, radios y motion.
- `web/src/styles/theme.css`: base, botones, campos, header, selector y footer.
- `web/src/styles/motion.css`: transiciones, reveals y reducción de movimiento.
- `web/src/styles.css`: composición de páginas y breakpoints.

Los componentes consumen variables semánticas como `--bg`, `--surface`,
`--text-primary`, `--primary`, `--border`, `--danger` y `--success`. No crean una
paleta paralela ni repiten valores arbitrarios.

## Jerarquía

Los títulos usan `clamp()` y un máximo que no domina todo el viewport. Las
secciones alternan narrativa, visuales y bloques compactos; una grilla uniforme
solo se usa cuando el contenido realmente tiene la misma prioridad.

Botones, tarjetas y campos comparten radios, borde, foco y estados. Las variantes
son `primary`, `secondary`, `ghost`, `danger` y `outline`; cada una conserva hover,
active, focus, disabled y loading cuando aplica.
