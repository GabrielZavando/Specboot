# Scenarios: Esquema y validación de `.specboot.json`

## Acceptance Criteria

### Scenario 1: El documento del esquema existe y documenta esquema + validación
- Given el repo de Specboot en estado limpio
- When un dev abre `docs/specboot-json-standard.md`
- Then el archivo existe, documenta el esquema completo (campos requeridos y opcionales, incl. `layers` opcional) y el comportamiento de validación (los 6 casos).

### Scenario 2: validate-specboot.sh pasa sobre el repo Specboot
- Given el repo Specboot con su `.specboot.json` final
- When se ejecuta `bash validate-specboot.sh`
- Then el script reporta éxito (JSON válido, campos requeridos presentes, versión coincide, rutas de `services` existen) y exit 0.

### Scenario 3: .specboot.json ausente → advertencia, no error
- Given un directorio de proyecto sin `.specboot.json`
- When se ejecuta `bash validate-specboot.sh`
- Then imprime "⚠️ .specboot.json no encontrado. Corre 'specboot init' para crearlo." y exit 0 (no bloquea).

### Scenario 4: JSON inválido → error
- Given un `.specboot.json` con sintaxis JSON rota
- When se ejecuta `bash validate-specboot.sh`
- Then reporta error de sintaxis y exit 1.

### Scenario 5: Faltan campos requeridos → error
- Given un `.specboot.json` válido pero sin `frameworkVersion`, `services` o `stack`
- When se ejecuta `bash validate-specboot.sh`
- Then lista el/los campo(s) faltante(s) y exit 1.

### Scenario 6: Incompatibilidad de versión
- Given un `.specboot.json` cuyo `frameworkVersion` es mayor que la versión instalada del framework
- When se ejecuta `bash validate-specboot.sh`
- Then reporta error ("proyecto requiere versión más nueva del framework") y exit 1.
- Given un `frameworkVersion` menor que la instalada
- When se ejecuta `bash validate-specboot.sh`
- Then reporta warning ("framework desactualizado, corre specboot update") y exit 0.

### Scenario 7: services apunta a ruta inexistente → error
- Given un `.specboot.json` cuyo `services` incluye una carpeta que no existe
- When se ejecuta `bash validate-specboot.sh`
- Then reporta error de ruta y exit 1.

### Scenario 8: Enlaces presentes en los doc padres
- Given `docs/specboot-json-standard.md` ya escrito
- When se revisan `docs/framework-contract.md` y `docs/docs-standard.md`
- Then ambos enlazan al nuevo estándar mediante link Markdown válido.

### Scenario 9: Validaciones automáticas del framework no regresan
- Given los artefactos del cambio escritos
- When se ejecutan `bash check-refs.sh` y `bash specboot.sh --ci`
- Then `check-refs.sh` reporta 0 errores y `specboot.sh --ci` no introduce nuevos errores/warnings respecto al baseline de TICKET-0.2.
