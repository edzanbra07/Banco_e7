# 02. Modelo de dominio y contextos

## Contextos delimitados

### Identidad y acceso

Gestiona `usuario_sistema`, roles, estados y relacion funcional con cliente o empleado.

### Clientes

Gestiona `cliente`, `cliente_persona` y `cliente_empresa` como representacion directa del sujeto bancario.

### Cuentas y movimientos

Gestiona `cuenta` y `cuenta_movimiento` como agregado financiero de saldo e historial.

### Creditos

Gestiona `prestamo`, `prestamo_aprobacion` y `prestamo_desembolso` como ciclo completo de solicitud, decision y desembolso.

### Transferencias

Gestiona `transferencia` y `transferencia_aprobacion` como flujo de origen, aprobacion, ejecucion y vencimiento.

### Pagos masivos

Gestiona `pago_masivo` y `pago_masivo_detalle` como lote empresarial con origen unico y multiples destinos.

### Productos y solicitudes

Gestiona `producto_bancario` y `solicitud_producto` como oferta y demanda de servicios.

### Delegacion empresarial

Gestiona `delegacion_permiso` como autorizacion acotada a empresa, periodo y tipo de permiso.

### Asignacion comercial

Gestiona `cliente_asignacion_comercial` como el vinculo entre clientes y empleados comerciales responsables de seguimiento.

### Auditoria y bitacora

Gestiona `bitacora_operacion` como trazabilidad de eventos significativos.

## Eventos de dominio relevantes

- Alta de cliente y activacion de identidad operativa.
- Apertura de cuenta con saldo inicial.
- Solicitud, aprobacion, rechazo y desembolso de prestamo.
- Creacion, aprobacion, rechazo, ejecucion y vencimiento de transferencia.
- Creacion, aprobacion, rechazo y ejecucion de pago masivo.
- Creacion, cambio de estado y consulta de solicitud de producto.
- Creacion, revocacion y consulta de delegacion de permiso.
- Creacion, revocacion y consulta de asignacion comercial.
- Registro y consulta de bitacora operativa.

## Agregados y raices

- `cliente` es la raiz para datos de identidad del cliente.
- `usuario_sistema` es la raiz para autenticacion y vinculacion funcional.
- `cuenta` es la raiz para saldo y estado operativo.
- `prestamo` es la raiz para solicitud, aprobacion y desembolso.
- `transferencia` es la raiz para creacion, aprobacion, ejecucion y vencimiento.
- `pago_masivo` es la raiz para lotes empresariales de pagos.
- `solicitud_producto` es la raiz para el ciclo de atencion de productos.
- `delegacion_permiso` es la raiz para permisos empresariales delegados.
- `cliente_asignacion_comercial` es la raiz para la cartera asignada al area comercial.

## Invariantes por agregado

- Un cliente debe tener identificacion unica y datos de contacto validos.
- Una persona natural debe ser mayor de edad.
- Una empresa debe referenciar un representante legal activo de tipo persona.
- Una cuenta no puede operar con saldo negativo ni titular inactivo.
- Un prestamo solo avanza por transiciones permitidas y solo puede desembolsarse cuando esta aprobado.
- Una transferencia no puede ejecutarse sin saldo suficiente ni con cuentas no operables.
- Un pago masivo no puede ejecutarse si la empresa o la cuenta origen no son validas o si no existe saldo suficiente para el total del lote.
- Una delegacion debe tener fechas coherentes y un permiso valido.
- Una asignacion comercial debe vincular un cliente activo con un empleado comercial activo.

## Hechos de dominio relevantes

- El banco distingue entre cliente persona y cliente empresa.
- El acceso de negocio depende del rol y del vinculo funcional.
- Los catalogos controlan estados, tipos y decisiones.
- La bitacora registra hechos, no ediciones manuales.
- Las operaciones financieras deben ser atomicas y trazables.

## Criterios de lectura del dominio

- Si una accion altera saldo, debe existir movimiento asociado.
- Si una accion cambia estado, debe existir validacion previa y registro de auditoria.
- Si una accion se consulta por usuario o empresa, debe estar filtrada por el contexto funcional correcto.

