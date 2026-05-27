# banco_bd

Paquete SQL ejecutable para construir la base de datos bancaria bajo MySQL 8+ con separacion estricta por responsabilidad.

## Arquitectura operativa

El paquete se organiza por capas:

- `00_init.sql` inicializa el esquema.
- `01_catalogos.sql` define estados, tipos, roles y decisiones.
- `02_tablas.sql` materializa entidades maestras, transaccionales y de soporte.
- `03_indices.sql` agrega indices para acceso y trazabilidad.
- `04_triggers.sql` protege invariantes locales y coherencia inmediata.
- `05_procedimientos.sql` concentra la logica de negocio transaccional.
- `06_vistas.sql` expone vistas de consulta y resumen.
- `07_auditoria.sql` centraliza lecturas de bitacora.
- `08_seguridad.sql` declara roles y permisos por perfil.
- `09_datos_semilla.sql` carga una semilla minima para prueba.

```mermaid
flowchart LR
	A[00_init] --> B[01_catalogos]
	B --> C[02_tablas]
	C --> D[03_indices]
	D --> E[04_triggers]
	E --> F[05_procedimientos]
	F --> G[06_vistas]
	G --> H[07_auditoria]
	H --> I[08_seguridad]
	I --> J[09_datos_semilla]
```

## Orden de ejecucion

Ejecutar siempre en este orden:

1. `00_init.sql`
2. `01_catalogos.sql`
3. `02_tablas.sql`
4. `03_indices.sql`
5. `04_triggers.sql`
6. `05_procedimientos.sql`
7. `06_vistas.sql`
8. `07_auditoria.sql`
9. `08_seguridad.sql`
10. `09_datos_semilla.sql` cuando se requiera una instancia de prueba

## Como ejecutar

### Opcion A - MySQL CLI

```bash
mysql -u root -p < 00_init.sql
mysql -u root -p banco_bd < 01_catalogos.sql
mysql -u root -p banco_bd < 02_tablas.sql
mysql -u root -p banco_bd < 03_indices.sql
mysql -u root -p banco_bd < 04_triggers.sql
mysql -u root -p banco_bd < 05_procedimientos.sql
mysql -u root -p banco_bd < 06_vistas.sql
mysql -u root -p banco_bd < 07_auditoria.sql
mysql -u root -p banco_bd < 08_seguridad.sql
mysql -u root -p banco_bd < 09_datos_semilla.sql
```

### Opcion B - MySQL Workbench

Abrir cada script en el orden indicado y ejecutarlo con `Ctrl+Shift+Enter` o con la ejecucion completa del editor.

## Proposito de cada script

| Script | Proposito |
| --- | --- |
| `00_init.sql` | Crea la base y fija el contexto de sesion. |
| `01_catalogos.sql` | Crea catalogos reutilizables para estados, tipos, roles y decisiones. |
| `02_tablas.sql` | Crea el modelo relacional bancario. |
| `03_indices.sql` | Mejora el rendimiento de consultas y reglas de acceso. |
| `04_triggers.sql` | Valida estados, relaciones e invariantes inmediatos. |
| `05_procedimientos.sql` | Ejecuta aperturas, aprobaciones, desembolsos, transferencias, pagos y consultas. |
| `06_vistas.sql` | Publica vistas de lectura y resumen. |
| `07_auditoria.sql` | Publica consultas de auditoria y trazabilidad operativa. |
| `08_seguridad.sql` | Declara roles y permisos por perfil funcional. |
| `09_datos_semilla.sql` | Inserta datos base para pruebas funcionales. |

## Convenciones SQL

- `snake_case` para nombres de objetos.
- Prefijo `sp_` para procedimientos almacenados.
- Prefijo `trg_` para triggers.
- Catalogos como fuente unica de estados, tipos y decisiones.
- Escritura de negocio solo mediante procedimientos.
- Lecturas de negocio y reporte por vistas o SP de consulta.

## Manejo transaccional y rollback

- Los flujos de dinero y estados usan `START TRANSACTION`, `COMMIT` y `ROLLBACK`.
- Los procedimientos criticos incluyen `EXIT HANDLER FOR SQLEXCEPTION`.
- Las operaciones que cambian saldo o estado usan bloqueos `FOR UPDATE` donde corresponde.
- Ningun flujo bancario sensible debe quedar a medio ejecutar.

## Estandar de respuestas

El convenio operativo usado por los procedimientos es:

- `0`: exito.
- `-1`: excepcion no controlada.
- `1001`: validacion o regla de negocio.
- `1002`: integridad o estado inconsistente.
- `1004`: fondos insuficientes.
- `1005`: duplicado.
- `1006`: transicion de estado invalida.
- `1007`: cuenta bloqueada o inactiva.
- `1008`: datos obligatorios faltantes.

## `trace_id`

- Cada operacion genera o preserva un `trace_id`.
- El `trace_id` conecta SPs, bitacora y eventos financieros.
- Este valor facilita auditoria, soporte y analisis forense.

## Auditoria y seguridad

- `bitacora_operacion` conserva el rastro de eventos significativos.
- `07_auditoria.sql` publica lecturas operativas de bitacora.
- `08_seguridad.sql` limita lectura y escritura por rol.
- La capa SQL refuerza el principio de minimo privilegio.
- `usuario_sistema` es la fuente de autenticacion funcional; `id_identificacion` identifica el ingreso y `contrasena_hash` almacena la credencial cifrada.
- Los roles funcionales del banco deben resolverse desde `cat_rol_sistema` y no desde usuarios en memoria.

## Triggers principales

- Clientes y perfiles: `trg_cliente_bi`, `trg_cliente_bu`, `trg_cliente_persona_bi`, `trg_cliente_persona_bu`, `trg_cliente_empresa_bi`, `trg_cliente_empresa_bu`.
- Usuarios: `trg_usuario_sistema_bi`, `trg_usuario_sistema_bu`, `trg_usuario_sistema_bd`.
- Cuentas y movimientos: `trg_cuenta_bi`, `trg_cuenta_bu`, `trg_cuenta_movimiento_bi`, `trg_cuenta_movimiento_bu`, `trg_cuenta_movimiento_bd`.
- Prestamos y transferencias: `trg_prestamo_bi`, `trg_prestamo_bu`, `trg_prestamo_aprobacion_bi`, `trg_transferencia_bi`, `trg_transferencia_bu`, `trg_transferencia_aprobacion_bi`.
- Solicitudes, delegaciones y pagos masivos: `trg_solicitud_producto_bi`, `trg_solicitud_producto_bu`, `trg_delegacion_permiso_bi`, `trg_delegacion_permiso_bu`, `trg_cliente_asignacion_comercial_bi`, `trg_cliente_asignacion_comercial_bu`, `trg_pago_masivo_bi`, `trg_pago_masivo_bu`, `trg_pago_masivo_detalle_bi`.
- Auditoria: `trg_bitacora_operacion_bi`, `trg_bitacora_operacion_bu`, `trg_bitacora_operacion_bd`.

## Validaciones bancarias clave

- El titular de una cuenta debe estar activo.
- Las transferencias requieren estado aprobado y saldo suficiente.
- Los prestamos requieren estados validos y cuenta destino activa para desembolso.
- Los pagos masivos requieren lote completo, cuenta origen activa y fondos suficientes.
- Los usuarios deben tener vinculo coherente con cliente o empleado segun su rol.

## Compatibilidad

- Motor objetivo: MySQL 8+.
- Requiere MySQL 8.0.16+ para que las restricciones `CHECK` se apliquen de forma efectiva.
- Recomendado: InnoDB.
- Codificacion: `utf8mb4`.
- El paquete no debe validarse ni ejecutarse como SQLite.
- El archivo `06_vistas_y_seguridad.sql` se conserva solo por compatibilidad historica y no debe usarse como ruta principal.