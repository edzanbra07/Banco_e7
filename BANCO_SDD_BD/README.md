# BANCO_SDD_BD

Proyecto bancario orientado a MySQL 8+ con enfoque SDD/DDD. La carpeta `SDD/` define el modelo conceptual y las reglas del dominio; la carpeta `banco_bd/` materializa ese diseño en SQL ejecutable, separando catalogos, tablas, indices, triggers, procedimientos, vistas, auditoria, seguridad y semilla.

## Arquitectura del proyecto

La arquitectura sigue una separacion estricta de responsabilidades:

- `SDD/`: contexto de negocio, modelo relacional, reglas, validacion y plan de entrega.
- `banco_bd/`: implementacion SQL del dominio bancario.
- `Enunciado Banco.md`: referencia funcional original.

El banco expone la logica de escritura a traves de procedimientos almacenados y utiliza triggers para proteger invariantes de datos, estados y relaciones criticas. Las lecturas de consulta se resuelven con vistas o procedimientos de apoyo, segun el tipo de consumo.

## Organizacion de carpetas

- `banco_bd/00_init.sql`: crea y selecciona la base `banco_bd`.
- `banco_bd/01_catalogos.sql`: define catalogos, tipos, estados y decisiones.
- `banco_bd/02_tablas.sql`: crea tablas maestras, transaccionales y de soporte.
- `banco_bd/03_indices.sql`: agrega indices para consultas y reglas de acceso.
- `banco_bd/04_triggers.sql`: valida invariantes, estados, trazabilidad e integridad local.
- `banco_bd/05_procedimientos.sql`: concentra la logica transaccional y operativa.
- `banco_bd/06_vistas.sql`: publica vistas de consulta y resumen.
- `banco_bd/07_auditoria.sql`: consolida vistas y consultas de auditoria.
- `banco_bd/08_seguridad.sql`: crea roles y permisos por perfil.
- `banco_bd/09_datos_semilla.sql`: carga minima para pruebas y demostracion.
- `banco_bd/06_vistas_y_seguridad.sql`: archivo legado mantenido solo por compatibilidad historica.

## Orden de ejecucion

Ejecutar en este orden para garantizar dependencias correctas:

1. `banco_bd/00_init.sql`
2. `banco_bd/01_catalogos.sql`
3. `banco_bd/02_tablas.sql`
4. `banco_bd/03_indices.sql`
5. `banco_bd/04_triggers.sql`
6. `banco_bd/05_procedimientos.sql`
7. `banco_bd/06_vistas.sql`
8. `banco_bd/07_auditoria.sql`
9. `banco_bd/08_seguridad.sql`
10. `banco_bd/09_datos_semilla.sql` si se necesita una carga inicial

## Como ejecutar

### Requisitos de ejecucion real

Antes de levantar el backend se debe contar con:

- Java 17 o superior instalado.
- `JAVA_HOME` configurado correctamente.
- MySQL 8+ activo con la base `banco_bd` creada.
- Variables de entorno disponibles para la conexion y seguridad.

Variables recomendadas:

- `DB_URL`.
- `DB_USERNAME`.
- `DB_PASSWORD`.
- `JWT_SECRET`.
- `JWT_EXPIRATION_MINUTES`.
- `SERVER_PORT`.
- `CORS_ALLOWED_ORIGINS`.

Arranque sugerido:

1. Ejecutar los scripts SQL en el orden documentado.
2. Verificar que MySQL responda en el puerto esperado.
3. Confirmar que `JAVA_HOME` apunte al JDK correcto.
4. Correr `mvnw.cmd test` o `mvnw.cmd spring-boot:run` dentro de `banco/`.

### Puertos y rutas base

- Backend: `http://localhost:8083`
- Swagger UI: `http://localhost:8083/swagger-ui.html`
- OpenAPI JSON: `http://localhost:8083/v3/api-docs`
- Login: `POST /api/auth/login` o `POST /auth/login`

Si el frontend se ejecuta separado, usar un origen local como `http://localhost:3000` o `http://localhost:5173` y ajustar `CORS_ALLOWED_ORIGINS` si cambia el puerto.

### Enlace de la aplicacion

Si el proyecto tiene una aplicacion cliente o una interfaz de acceso, documenta aqui su URL de ejecucion o despliegue. Ejemplo:

- Aplicacion local: http://localhost:3000
- API o servicio backend: http://localhost:8083

### Opcion A - MySQL CLI

```bash
mysql -u root -p < banco_bd/00_init.sql
mysql -u root -p banco_bd < banco_bd/01_catalogos.sql
mysql -u root -p banco_bd < banco_bd/02_tablas.sql
mysql -u root -p banco_bd < banco_bd/03_indices.sql
mysql -u root -p banco_bd < banco_bd/04_triggers.sql
mysql -u root -p banco_bd < banco_bd/05_procedimientos.sql
mysql -u root -p banco_bd < banco_bd/06_vistas.sql
mysql -u root -p banco_bd < banco_bd/07_auditoria.sql
mysql -u root -p banco_bd < banco_bd/08_seguridad.sql
mysql -u root -p banco_bd < banco_bd/09_datos_semilla.sql
```

### Opcion B - MySQL Workbench

Abrir cada script en el orden indicado y ejecutarlo con `Ctrl+Shift+Enter` o con la ejecucion completa del editor.

## Estandar operativo

### Convenciones utilizadas

- Nombres en `snake_case`.
- Prefijo `sp_` para procedimientos almacenados.
- Prefijo `trg_` para triggers.
- Catalogos como fuente unica de estados, tipos, roles y decisiones.
- Escritura de negocio centralizada en procedimientos, no en aplicaciones cliente.
- Lecturas de reporte aisladas en vistas o procedimientos de consulta.

### Manejo transaccional

- Las operaciones criticas usan `START TRANSACTION`, `COMMIT` y `ROLLBACK`.
- Los flujos que cambian saldos, estados o aprobaciones bloquean filas relevantes con `FOR UPDATE` cuando aplica.
- Las operaciones compuestas registran primero el cambio de estado y luego los movimientos de ledger, o revierten todo si algo falla.
- Los procedimientos criticos incluyen `EXIT HANDLER FOR SQLEXCEPTION` para asegurar rollback automatico.

### Politica de rollback

- Cualquier excepcion no controlada en una operacion transaccional debe terminar en `ROLLBACK`.
- Ningun cambio parcial debe quedar visible en cuentas, prestamos, transferencias o pagos masivos.
- La bitacora operativa y los movimientos contables deben reflejar solo operaciones efectivamente confirmadas.

### Estandar de codigos de respuesta

El paquete SQL usa un convenio uniforme de salida en procedimientos almacenados:

- `0`: exito.
- `-1`: excepcion no controlada.
- `1001`: validacion o regla de negocio.
- `1002`: integridad o estado inconsistente.
- `1004`: fondos insuficientes.
- `1005`: duplicado.
- `1006`: transicion de estado invalida.
- `1007`: cuenta bloqueada o inactiva.
- `1008`: datos obligatorios faltantes.

Cuando un procedimiento expone `OUT`, el par `o_codigo_resultado` / `o_mensaje_resultado` debe describir el resultado de forma estable y legible para procesos, integraciones y pruebas.

### Uso de `trace_id`

- Cada operacion bancaria genera o preserva un `trace_id` para correlacion.
- El `trace_id` viaja desde procedimientos de negocio hacia la bitacora operativa.
- Esto permite unir una solicitud, sus cambios de estado, sus movimientos y su rastro de auditoria.

### Auditoria

- La tabla `bitacora_operacion` conserva el rastro funcional de eventos relevantes.
- Los procedimientos de negocio invocan `sp_bitacora_registrar` para dejar evidencia de creaciones, aprobaciones, rechazos, desembolsos, ejecuciones y cambios de estado.
- La vista `vw_bitacora_resumen` ofrece una lectura resumida para analisis operativo.

### Seguridad

- Los roles y permisos se definen en la base de datos, no solo en la aplicacion.
- `08_seguridad.sql` concentra los `GRANT` por perfil.
- La separacion de permisos reduce el alcance de cada actor: cliente, empleado, supervisor, analista y administracion tecnica.
- Los triggers y procedimientos refuerzan las restricciones funcionales aunque el cliente externo intente saltarlas.

### Separacion de responsabilidades

- Catalogos: valores canonicos.
- Tablas: persistencia del dominio.
- Indices: rendimiento y acceso.
- Triggers: invariantes y validaciones locales.
- Procedimientos: reglas transaccionales y escritura controlada.
- Vistas: lectura y reporte.
- Auditoria: trazabilidad.
- Seguridad: permisos y roles.

## Proposito de cada script SQL

| Script | Proposito |
| --- | --- |
| `00_init.sql` | Crea la base de datos y establece el contexto de ejecucion. |
| `01_catalogos.sql` | Define catalogos de estados, tipos, roles, decisiones y valores de referencia. |
| `02_tablas.sql` | Crea las entidades maestras, transaccionales y de soporte del dominio bancario. |
| `03_indices.sql` | Agrega indices para consultas frecuentes, llaves logicas y rendimiento operativo. |
| `04_triggers.sql` | Protege reglas de negocio, estados validos, coherencia de relaciones y trazabilidad. |
| `05_procedimientos.sql` | Centraliza la logica transaccional de creacion, aprobacion, ejecucion y consulta. |
| `06_vistas.sql` | Expone vistas de consumo para clientes, cuentas, prestamos, transferencias y resumenes. |
| `07_auditoria.sql` | Publica vistas de auditoria y lectura operativa de bitacora. |
| `08_seguridad.sql` | Crea roles y concede permisos de acuerdo con cada perfil operativo. |
| `09_datos_semilla.sql` | Inserta datos minimos para probar el flujo completo sin dependencia externa. |
| `06_vistas_y_seguridad.sql` | Mantiene compatibilidad historica, pero ya no es la ruta recomendada. |

## Triggers principales

Los triggers se agrupan por area funcional y protegen invariantes criticos:

- Clientes y perfiles: `trg_cliente_bi`, `trg_cliente_bu`, `trg_cliente_persona_bi`, `trg_cliente_persona_bu`, `trg_cliente_empresa_bi`, `trg_cliente_empresa_bu`.
- Usuarios: `trg_usuario_sistema_bi`, `trg_usuario_sistema_bu`, `trg_usuario_sistema_bd`.
- Cuentas y movimientos: `trg_cuenta_bi`, `trg_cuenta_bu`, `trg_cuenta_movimiento_bi`, `trg_cuenta_movimiento_bu`, `trg_cuenta_movimiento_bd`.
- Prestamos: `trg_prestamo_bi`, `trg_prestamo_bu`, `trg_prestamo_aprobacion_bi`.
- Transferencias: `trg_transferencia_bi`, `trg_transferencia_bu`, `trg_transferencia_aprobacion_bi`.
- Solicitudes y delegaciones: `trg_solicitud_producto_bi`, `trg_solicitud_producto_bu`, `trg_delegacion_permiso_bi`, `trg_delegacion_permiso_bu`.
- Asignacion comercial: `trg_cliente_asignacion_comercial_bi`, `trg_cliente_asignacion_comercial_bu`.
- Pagos masivos: `trg_pago_masivo_bi`, `trg_pago_masivo_bu`, `trg_pago_masivo_detalle_bi`.
- Auditoria: `trg_bitacora_operacion_bi`, `trg_bitacora_operacion_bu`, `trg_bitacora_operacion_bd`.

En conjunto, estos triggers ayudan a impedir estados invalidos, relaciones rotas, registros incompletos y manipulacion inconsistente de datos sensibles.

## Validaciones bancarias importantes

- Un cliente titular debe estar activo para abrir cuentas o iniciar operaciones sensibles.
- Una cuenta debe estar activa para desembolsos, transferencias y cargos.
- Un prestamo solo puede aprobarse, rechazarse o desembolsarse desde su estado permitido.
- Una transferencia solo puede ejecutarse cuando fue aprobada y existe saldo suficiente.
- Un pago masivo requiere detalles, monto coherente y cuenta origen activa.
- Las relaciones de usuario deben ser coherentes con su rol: cliente con cliente, empleado con empleado.
- Las transiciones de estado fuera de secuencia se rechazan desde triggers y procedimientos.

## Integridad financiera

La integridad financiera se garantiza combinando varias capas:

- El saldo se modifica solo dentro de procedimientos transaccionales.
- Las filas de cuenta y operacion asociadas se bloquean cuando hay riesgo de concurrencia.
- Cada movimiento relevante queda reflejado en `cuenta_movimiento`.
- El ledger registra origen, destino, montos y saldo antes y despues del cambio.
- Si una aprobacion, ejecucion o desembolso falla, el `ROLLBACK` evita estados intermedios.
- La bitacora conserva el rastro de quien hizo que, cuando y con que `trace_id`.

## Compatibilidad

- Motor objetivo: MySQL 8+.
- Requiere MySQL 8.0.16+ para que las restricciones `CHECK` se apliquen de forma efectiva.
- Recomendado: InnoDB.
- Codificacion: `utf8mb4` con collation uniforme.
- El paquete no debe validarse ni ejecutarse como SQLite.
- El diseno asume soporte para transacciones, `FOR UPDATE`, handlers, roles y vistas de MySQL 8.

## Uso recomendado

1. Revisar `SDD/` para entender el dominio y las reglas.
2. Ejecutar los scripts SQL en el orden indicado.
3. Cargar semilla solo si se necesita una instancia de prueba.
4. Consumir escrituras a traves de procedimientos, no mediante DML directo.
5. Consultar vistas y reportes para lectura operativa.