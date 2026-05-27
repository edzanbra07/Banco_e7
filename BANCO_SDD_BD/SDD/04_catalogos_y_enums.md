# 04. Catalogos y enums

## Proposito

Los catalogos representan estados, tipos, roles, decisiones y clasificaciones del dominio. Su uso evita valores magicos, estabiliza el vocabulario y facilita validaciones en triggers y procedimientos.

## Catalogos definidos

- `cat_tipo_cliente`: PERSONA, EMPRESA.
- `cat_estado_cliente`: ACTIVO, INACTIVO, BLOQUEADO, CERRADO.
- `cat_rol_sistema`: CLIENTE_PERSONA, CLIENTE_EMPRESA, EMPLEADO_VENTANILLA, EMPLEADO_COMERCIAL, EMPLEADO_EMPRESA, SUPERVISOR_EMPRESA, ANALISTA_INTERNO, ADMIN_BD.
- `cat_estado_usuario`: ACTIVO, INACTIVO, BLOQUEADO.
- `cat_estado_empleado`: ACTIVO, INACTIVO, SUSPENDIDO.
- `cat_tipo_empleado`: VENTANILLA, COMERCIAL, EMPRESA, SUPERVISOR, ANALISTA.
- `cat_tipo_cuenta`: AHORRO, CORRIENTE, NOMINA, EMPRESARIAL.
- `cat_estado_cuenta`: ACTIVA, BLOQUEADA, CANCELADA, CERRADA.
- `cat_moneda`: BOB, USD, EUR.
- `cat_tipo_prestamo`: PERSONAL, VEHICULAR, HIPOTECARIO, COMERCIAL, CAPITAL_TRABAJO.
- `cat_estado_prestamo`: SOLICITADO, EN_ESTUDIO, APROBADO, RECHAZADO, DESEMBOLSADO, CANCELADO, VENCIDO.
- `cat_estado_transferencia`: CREADA, EN_ESPERA_APROBACION, APROBADA, RECHAZADA, EJECUTADA, VENCIDA, CANCELADA.
- `cat_categoria_producto`: CUENTA, CREDITO, TRANSFERENCIA, PAGO, SERVICIO.
- `cat_estado_producto`: ACTIVO, INACTIVO, SUSPENDIDO, RETIRADO.
- `cat_tipo_movimiento_cuenta`: ABONO, CARGO, DESEMBOLSO, TRANSFERENCIA_SALIDA, TRANSFERENCIA_ENTRADA, AJUSTE, REVERSO.
- `cat_estado_solicitud_producto`: RECIBIDA, EN_REVISION, APROBADA, RECHAZADA, CERRADA.
- `cat_estado_delegacion`: ACTIVA, SUSPENDIDA, VENCIDA, REVOCADA.
- `cat_tipo_permiso`: CONSULTA, OPERACION, APROBACION, ADMINISTRACION.
- `cat_estado_pago_masivo`: CREADO, EN_REVISION, APROBADO, RECHAZADO, EJECUTADO, VENCIDO, CANCELADO.
- `cat_tipo_operacion_bitacora`: ALTA_CLIENTE, APERTURA_CUENTA, SOLICITUD_PRESTAMO, APROBACION_PRESTAMO, DESEMBOLSO_PRESTAMO, CREACION_TRANSFERENCIA, APROBACION_TRANSFERENCIA, EJECUCION_TRANSFERENCIA, SOLICITUD_PRODUCTO, DELEGACION_PERMISO, ASIGNACION_CLIENTE, PAGO_MASIVO, REVISION_AUDITORIA, CAMBIO_ESTADO.
- `cat_decision_aprobacion`: APROBADO, RECHAZADO.

## Criterios de uso

- Ninguna tabla de negocio debe almacenar textos de estado o tipo como fuente principal de verdad.
- Todo trigger o SP debe resolver los codigos a partir de catalogos.
- Los catalogos deben permanecer activos aunque algunos valores queden inactivos por evolucion futura.
- La documentacion y el SQL deben mantener la misma lista canonica sin duplicados ni variantes ambiguas.

## Reglas de coherencia

- Todo catalogo usado por SQL debe existir en esta lista.
- Ningun codigo nuevo debe introducirse sin actualizar documentacion, triggers y SP.
- Los estados finales y transitorios deben quedar separados conceptualmente para evitar transiciones incorrectas.

