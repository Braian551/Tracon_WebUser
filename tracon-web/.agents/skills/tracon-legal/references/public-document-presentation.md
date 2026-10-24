# Presentación pública de documentos legales

## Fuente canónica

`legal/legal-manifest.json` es la autoridad para `title`, `documentType`,
`version`, `effectiveAt`, `locale`, URL, aceptación y hash. `effectiveAt` es la
única fecha que se presenta como “Última actualización”. El cuerpo Markdown
versionado en `legal/` contiene únicamente contenido público; no lleva
front-matter de proceso.

Las copias de mobile y web se generan con
`scripts/sync-legal-artifacts.ps1`. El backend conserva el manifiesto interno
completo para aceptación y release. El manifiesto público excluye
`releaseStatus`, `releaseGate` y notas de revisión.

## Separación de información

La metadata de revisión permanece en `legal/metadata/`, el registro de revisión
y los checks de release. Nunca se envían al widget ni al cuerpo público:

- `LEGAL_TODO` o `LEGAL_REVIEW_REQUIRED`.
- `releaseStatus`, `releaseGate`, estado de borrador o prepublicación.
- responsable observado, contacto técnico provisional, hash, manifest interno,
  rutas de fuente o notas para desarrollo.

No se inventan NIT, domicilio, representante, canales, jurisdicciones, edades,
plazos, licencias ni aprobaciones. Si falta un dato, el tooling conserva el
pendiente y emite `DOCUMENT_NOT_RELEASE_READY`; la UI no lo convierte en una
afirmación legal.

## Contratos y aceptación

`LegalDocumentPublic` contiene solo título, fecha canónica y body para la
presentación. La aceptación usa el `version` y `contentSha256` canónicos del
manifiesto; una versión corta de display nunca reemplaza esos identificadores.

## Renderizado y UX

El body Markdown debe pasar por un parser/renderer real que soporte headings,
énfasis, listas, enlaces, bloques y separadores. No se eliminan caracteres con
`replaceAll` ni se presenta el body como texto plano. La página tiene una única
jerarquía H1 en el header, fecha humana en `es-CO`, lectura de ancho razonable,
scroll completo, enlaces accesibles y estilos de tema claro/oscuro.

La AppBar conserva navegación y no repite títulos largos. La vista ofrece
loading con skeleton, error humano con reintento, contraste, semántica de
headings, texto escalable y enlaces restringidos a destinos seguros.

## Release y pruebas

La validación debe comprobar que las copias y sus hashes coinciden con el
manifiesto, que el manifiesto público no contiene metadata interna, y que la
representación visible no contiene sintaxis Markdown cruda ni marcadores de
workflow. La revisión física de términos, privacidad, normas y tratamiento de
datos sigue siendo necesaria antes de afirmar calidad visual o aprobación
jurídica.
