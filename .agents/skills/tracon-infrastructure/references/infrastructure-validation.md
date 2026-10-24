# Validación de infraestructura

## Antes de modificar

- Identifica project name, archivos Compose, redes, volúmenes, puertos, rutas y release activo.
- Verifica que toda ruta sea de Tracon.
- Confirma autorización explícita antes de tocar producción.

## Configuración y build

```powershell
docker compose config
docker compose build <servicios_afectados>
```

No hagas builds globales si el cambio está delimitado.

## Después de un despliegue autorizado

1. Verifica contenedores esperados y ausencia de reinicios en bucle.
2. Comprueba liveness y readiness.
3. Ejecuta smoke tests de endpoints y flujo afectado.
4. Revisa logs sin secretos.
5. Verifica migraciones y compatibilidad de versión.
6. Comprueba CPU, RAM y disco.
7. Confirma que rutas, contenedores, redes y volúmenes de Viax no cambiaron.
8. Conserva un rollback realmente utilizable.

No marques despliegue exitoso solo porque los contenedores están `Up`.
