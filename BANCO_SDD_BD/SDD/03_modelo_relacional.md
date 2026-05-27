# 03. Modelo relacional

## Correspondencia dominio-tabla

- `cliente` representa la entidad base de cliente.
- `cliente_persona` extiende a `cliente` cuando el tipo es persona natural.
- `cliente_empresa` extiende a `cliente` cuando el tipo es empresa.
- `empleado` representa al personal interno con su clasificacion.
- `usuario_sistema` representa la identidad operativa que interactua con el sistema.
- `producto_bancario` representa el catalogo de productos ofertados.
- `cuenta` representa la cuenta bancaria y su estado operativo.
- `cuenta_movimiento` representa el ledger inmutable de cambios de saldo.
- `prestamo` representa el agregado de credito.
- `prestamo_aprobacion` y `prestamo_desembolso` representan eventos de negocio del credito.
- `transferencia` representa el agregado de transferencia.
- `transferencia_aprobacion` representa la decision sobre la transferencia.
- `pago_masivo` y `pago_masivo_detalle` representan el lote empresarial de pagos.
- `solicitud_producto` representa la solicitud comercial.
- `cliente_asignacion_comercial` representa la cartera asignada al area comercial.
- `delegacion_permiso` representa el otorgamiento de facultades empresariales.
- `bitacora_operacion` representa la auditoria funcional.

## Identificadores y campos comunes

- Las entidades usan claves sustitutas internas numericas para mantener independencia operacional.
- Las columnas naturales relevantes se mantienen como restricciones unicas cuando el dominio lo requiere, por ejemplo identificacion, numero de cuenta o NIT.
- Las tablas de negocio conservan campos de auditoria como `created_by`, `updated_by`, `created_at` o equivalentes cuando aplica.
- Los movimientos financieros se respaldan con saldo anterior, saldo posterior, referencia tipificada y entidad relacionada.

## Relaciones principales

- Un `cliente` puede tener un subtipo exclusivo: persona o empresa.
- Un `usuario_sistema` se vincula a un `cliente` o a un `empleado`, pero no a ambos.
- Una `cuenta` pertenece a un unico `cliente` titular.
- Un `prestamo` pertenece a un unico cliente solicitante y puede desembolsarse a una cuenta valida.
- Una `transferencia` relaciona una cuenta origen y una cuenta destino.
- Un `pago_masivo` relaciona una empresa, una cuenta origen y multiples detalles de pago.
- Una `solicitud_producto` relaciona cliente solicitante y producto solicitado.
- Una `cliente_asignacion_comercial` relaciona cliente y empleado comercial.
- Una `delegacion_permiso` relaciona empresa, usuario delegado, tipo de permiso y estado.

## Normalizacion y consistencia

- Las identidades se separan de sus atributos de subtipo para evitar nulidad masiva.
- Los estados y tipos no se repiten como texto libre; se referencian a catalogos.
- Los movimientos financieros se registran en una tabla separada e inmutable.
- Los datos de auditoria se separan de las entidades de negocio.

## Cardinalidades clave

- Un cliente puede tener cero o una cuenta principal por tipo de producto, segun la regla de negocio.
- Un cliente puede tener varias cuentas, prestamos, solicitudes y asignaciones.
- Una cuenta puede tener muchos movimientos.
- Un prestamo puede tener una aprobacion, un desembolso y una cuenta destino.
- Una transferencia puede tener un unico ciclo de aprobacion y un unico evento de ejecucion.
- Una empresa puede tener multiples delegaciones y multiples pagos masivos.

## Observaciones de diseno

- La representacion actual favorece claves sustitutas internas y claves naturales unicas donde el dominio lo exige.
- El modelo debe preservar el vocabulario del negocio y evitar nombres ambiguos.
- Las operaciones de escritura deben concentrarse en procedimientos para evitar acceso directo inconsistente.

