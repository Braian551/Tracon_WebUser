# Validación de diseño

## Revisión focalizada

Para cada pantalla o componente modificado, verificar:

- Tema claro y oscuro.
- Ancho pequeño y tamaño habitual.
- Texto largo y escalado de fuente.
- Teclado visible y scroll.
- Carga, vacío, error, éxito, deshabilitado y procesamiento cuando apliquen.
- Contraste, semántica y target táctil.
- Tokens en lugar de valores hardcodeados.
- Reutilización de componentes existentes.
- Ausencia de overflows y saltos de layout.
- En navegación adaptativa, validar el área realmente ocupada por la barra y
  el `viewPadding.bottom` del sistema en anchos compactos, tablets y escalado
  de texto; no fijar la posición de medios fullscreen con píxeles de un solo
  dispositivo.
- Los overlays transitorios deben declarar límites de hit testing explícitos:
  una superficie de feedback no puede bloquear interacción ajena a ella.

## Evidencia

Usa pruebas de widgets y revisión visual disponible. No declares validación visual si no se ejecutó o inspeccionó realmente.

## Cambios globales

Una modificación de color de marca, tipografía, escala de espaciado, radios, navegación o patrón global requiere:

1. Justificación explícita.
2. Revisión de consumidores.
3. Actualización de tokens.
4. Pruebas o validación visual representativa.
5. Actualización de esta referencia.

No propagues manualmente el mismo valor por múltiples módulos.
