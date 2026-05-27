# 01. Contexto y principios

## Proposito

Este proyecto define una base de datos relacional bancaria orientada por DDD. La base de datos no es un repositorio pasivo: actua como parte activa del dominio, validando invariantes, centralizando reglas criticas y exponiendo servicios de negocio mediante procedimientos almacenados.

## Alcance y premisas

- El sistema cubre clientes, usuarios, cuentas, creditos, transferencias, pagos masivos, solicitudes, delegaciones, seguridad y auditoria.
- El dominio se implementa exclusivamente en MySQL 8+ para conservar consistencia transaccional y trazabilidad.
- La capa de aplicacion no debe sustituir reglas bancarias criticas que pertenecen al motor de datos.
- La bitacora es documental y transaccional; no se modela como dependencia externa.
- Cualquier flujo con impacto financiero debe poder revertirse de forma completa.
- Fuera de alcance: logica clinica, inventarios, facturacion general y cualquier regla ajena al banco.

## Principios rectores

- Las entidades del dominio se representan como tablas.
- Los catalogos y estados se representan como tablas de referencia.
- Las reglas locales de consistencia se validan con triggers.
- Los casos de uso significativos se implementan como procedimientos almacenados.
- La auditoria y trazabilidad forman parte del comportamiento del sistema.
- Toda decision importante debe ser rastreable a un contexto y a una regla del dominio.

## Criterios DDD aplicados

- Entidades con identidad propia: cliente, usuario_sistema, cuenta, prestamo, transferencia, solicitud_producto y delegacion_permiso.
- Agregados con raiz clara: cliente, cuenta, prestamo y transferencia.
- Invariantes protegidas en el mismo limite transaccional donde se modifican los datos.
- Servicios de dominio encapsulados para orquestar cambios que afectan varias tablas.
- Contextos delimitados por funcionalidad: identidad y acceso, clientes, productos, creditos, pagos, auditoria y operacion tecnica.

## Lenguaje ubicuo

- Cliente: sujeto bancario titular o empresarial.
- Cuenta: medio operativo de saldo y movimientos.
- Prestamo: agregado de credito con ciclo de solicitud, decision y desembolso.
- Transferencia: traslado de fondos entre cuentas.
- Pago masivo: lote empresarial con cargo unico y multiples abonos.
- Delegacion: permiso acotado otorgado por empresa a un usuario delegado.
- Bitacora: rastro operativo de eventos significativos con `trace_id`.

## Alcance del sistema

El sistema cubre la gestion de clientes persona y empresa, usuarios del sistema, apertura y consulta de cuentas, solicitudes y manejo de prestamos, transferencias internas y empresariales, pagos masivos, catalogos operativos, delegaciones de permiso, seguridad de acceso y bitacora de operaciones.

La bitacora se entrega como un log documental con payload JSON persistido dentro de MySQL para este paquete, manteniendo semantica de evento y trazabilidad de negocio.

## Regla de lectura del modelo

Cuando una operacion cambia mas de una entidad o valida mas de una regla, no debe depender de SQL suelto en la capa cliente. Debe vivir en un procedimiento almacenado o en un trigger que mantenga la coherencia del dominio.

## Criterio de exito

El diseno se considera consistente cuando cada cambio sensible tiene entidad, catalogo, validacion, transaccion, auditoria y ruta de consulta claramente documentados.

