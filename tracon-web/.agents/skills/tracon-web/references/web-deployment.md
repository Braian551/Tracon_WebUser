# Despliegue del sitio web

La fuente canónica es `web/deploy/README.md`, dentro del repositorio independiente
`Braian551/Tracon_web`. GitHub Actions valida, construye y entrega únicamente
estáticos mediante una identidad SSH exclusiva y restringida.

Simple Deploy conserva Backend y workers. La transición productiva solo retira
su responsabilidad Web después de verificar la nueva entrega y su recuperación.
No reutilizar la identidad del operador, modificar rutas Backend ni desplegar
Web desde paquetes o rollback de Backend. Consultar el estado de transición real
en la guía; código preparado no equivale a una activación productiva completada.
