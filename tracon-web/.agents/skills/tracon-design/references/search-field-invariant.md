# Tracon Search Field Invariant

La implementación canónica del campo de búsqueda móvil es
`mobile/lib/core/widgets/app_search_field.dart` (`AppSearchField`). Su
contrato visual y de interacción es:

- consulta vacía: icono de búsqueda a la izquierda y ningún trailing;
- consulta no vacía: icono de búsqueda y únicamente la acción `Limpiar búsqueda`;
- `customTrailing` es una extensión opt-in propiedad de la pantalla y solo se
  muestra cuando la consulta está vacía; nunca desplaza ni reemplaza el clear;
- filtros, orden y refinamientos pertenecen explícitamente a la pantalla que
  implementa esa funcionalidad, no al campo genérico;
- el campo no infiere, reserva ni renderiza iconos `filter`, `filter_alt`,
  `filter_list`, `tune`, `sliders`, `adjustments`, `settings` o `sort` por
  defecto;
- al eliminar un trailing también desaparecen su espacio de layout, hit target
  y semántica.

Los callers deben conservar este default al reutilizar `AppSearchField` en
Chats, Comunidades, personas, publicaciones, Traks, retos, perfiles,
selección de destinatarios y búsquedas internas. Un filtro real se declara
fuera del campo y debe tener comportamiento funcional y pruebas propias.
