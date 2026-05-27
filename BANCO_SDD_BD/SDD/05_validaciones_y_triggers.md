# 05. Validaciones y triggers

## 1. Objetivo

Definir las validaciones basicas que se ejecutaran automaticamente en MySQL para proteger integridad local, estados y coherencia inmediata de los datos.

## 2. Regla general de uso

- Los triggers solo validan o enriquecen datos locales.
- La logica multi-tabla o de negocio complejo se ejecuta en procedimientos almacenados.
- Los triggers no deben contener loops, consultas costosas ni llamadas externas.

## 3. Matriz de triggers propuestos

### 3.1 `cliente` y subtipos

#### BEFORE INSERT

Validar:

- identificacion obligatoria y no vacia;
- correo con formato basico;
- telefono con longitud permitida;
- direccion obligatoria;
- estado inicial valido;
- tipo cliente correcto.

#### BEFORE UPDATE

Validar:

- no duplicar identificacion;
- no degradar un cliente activo a una combinacion inconsistente;
- no permitir cambio de tipo de cliente sin proceso de migracion controlado.

### 3.2 `cliente_persona`

#### BEFORE INSERT / UPDATE

Validar:

- nombres y apellidos obligatorios;
- fecha_nacimiento no nula;
- edad minima de 18 anos;
- coherencia con `cliente.tipo_cliente = PERSONA`.

### 3.3 `cliente_empresa`

#### BEFORE INSERT / UPDATE

Validar:

- razon social obligatoria;
- NIT obligatorio y unico;
- representante legal obligatorio;
- el representante debe ser persona natural activa;
- coherencia con `cliente.tipo_cliente = EMPRESA`.

### 3.4 `usuario_sistema`

#### BEFORE INSERT

Validar:

- rol existente y activo;
- estado inicial valido;
- al menos un vinculo funcional al cliente o al empleado;
- identificacion unica si se usa como login o identificador humano.

#### BEFORE UPDATE

Validar:

- no permitir estados invalidos;
- no permitir desvinculacion total de la identidad de negocio;
- evitar cambio de rol sin control administrativo.

### 3.5 `cuenta`

#### BEFORE INSERT

Validar:

- numero de cuenta unico;
- titular existente y activo;
- tipo de cuenta valido;
- moneda valida;
- saldo inicial mayor o igual a cero;
- no abrir cuenta a cliente bloqueado o inactivo.

#### BEFORE UPDATE

Validar:

- no permitir saldo negativo;
- no permitir cambio de titular sin SP de reasignacion;
- estados solo por transicion permitida;
- no operar cuentas bloqueadas o canceladas.

### 3.6 `cuenta_movimiento`

#### BEFORE INSERT

Validar:

- monto positivo;
- saldo anterior y posterior coherentes;
- referencia obligatoria;
- tipo de movimiento valido;
- tabla inmutable una vez insertada.

### 3.7 `prestamo`

#### BEFORE INSERT

Validar:

- cliente solicitante activo;
- monto solicitado mayor que cero;
- tasa positiva;
- plazo positivo;
- estado inicial solicitado o en estudio;
- cuenta destino no nula si el flujo ya contempla preasignacion.

#### BEFORE UPDATE

Validar:

- transiciones permitidas solamente:
  - `EN_ESTUDIO` -> `APROBADO` o `RECHAZADO`
  - `APROBADO` -> `DESEMBOLSADO`
- solo roles autorizados pueden cambiar a aprobado o rechazado;
- no desembolsar sin cuenta valida;
- no modificar monto aprobado fuera del flujo de aprobacion.

### 3.8 `prestamo_aprobacion`

#### BEFORE INSERT

Validar:

- el prestamo debe existir;
- el aprobador debe tener rol analista interno;
- la decision debe ser valida;
- el prestamo no puede estar ya desembolsado o cerrado.

### 3.9 `transferencia`

#### BEFORE INSERT

Validar:

- monto mayor que cero;
- cuenta origen y destino existentes;
- cuentas no bloqueadas ni canceladas;
- cuenta origen distinta de destino salvo regla especifica;
- creador valido;
- estado inicial valido;
- fecha de vencimiento calculable si supera umbral.

#### BEFORE UPDATE

Validar:

- transiciones permitidas solo por el flujo definido;
- aprobador distinto al creador;
- no ejecutar si esta vencida;
- no cambiar cuentas una vez creada salvo anulacion controlada.

### 3.10 `transferencia_aprobacion`

#### BEFORE INSERT

Validar:

- la transferencia debe existir;
- el aprobador debe tener rol autorizado;
- la decision debe ser valida;
- no puede aprobar quien creo la transferencia;
- no puede aprobarse una transferencia vencida.

### 3.11 `solicitud_producto`

#### BEFORE INSERT / UPDATE

Validar:

- cliente solicitante existente y activo;
- codigo de producto valido;
- estado de solicitud valido;
- usuario gestor coherente con el flujo.

### 3.12 `delegacion_permiso`

#### BEFORE INSERT / UPDATE

Validar:

- cliente empresa existente;
- usuario delegado valido;
- tipo de permiso valido;
- rango de fechas coherente;
- estado valido.

### 3.13 `pago_masivo` y `pago_masivo_detalle`

#### BEFORE INSERT / UPDATE

Validar:

- empresa activa;
- cuenta origen perteneciente a la empresa y activa;
- total del lote no negativo;
- detalle con monto positivo;
- no agregar detalles a lotes cerrados;
- transiciones validas del lote;
- ejecucion solo con lote aprobado.

### 3.14 `bitacora_operacion`

#### BEFORE INSERT

Validar:

- tipo de operacion no nulo;
- fecha_hora_obligatoria;
- JSON valido;
- no permitir actualizacion o borrado en el ciclo normal.

## 4. Triggers principales implementados

- `trg_cliente_bi` y `trg_cliente_bu`: validan identificacion, estado y coherencia del cliente.
- `trg_cliente_persona_bi` y `trg_cliente_persona_bu`: refuerzan la relacion con el subtipo persona.
- `trg_cliente_empresa_bi` y `trg_cliente_empresa_bu`: refuerzan representante legal y tipo empresa.
- `trg_usuario_sistema_bi` y `trg_usuario_sistema_bu`: validan vinculo funcional rol-cliente-empleado.
- `trg_cuenta_bi` y `trg_cuenta_bu`: protegen apertura, saldo y estados finales.
- `trg_cuenta_movimiento_bi`, `trg_cuenta_movimiento_bu` y `trg_cuenta_movimiento_bd`: mantienen ledger inmutable.
- `trg_prestamo_bi`, `trg_prestamo_bu` y `trg_prestamo_aprobacion_bi`: protegen ciclo del credito.
- `trg_transferencia_bi`, `trg_transferencia_bu` y `trg_transferencia_aprobacion_bi`: protegen ciclo de transferencias.
- `trg_solicitud_producto_bi` y `trg_solicitud_producto_bu`: protegen la solicitud comercial.
- `trg_delegacion_permiso_bi` y `trg_delegacion_permiso_bu`: protegen fechas, tipo y estado de delegacion.
- `trg_cliente_asignacion_comercial_bi` y `trg_cliente_asignacion_comercial_bu`: protegen cartera comercial.
- `trg_pago_masivo_bi`, `trg_pago_masivo_bu` y `trg_pago_masivo_detalle_bi`: protegen lote, totales y detalle.
- `trg_bitacora_operacion_bi`, `trg_bitacora_operacion_bu` y `trg_bitacora_operacion_bd`: preservan inmutabilidad documental.

## 5. Relacion con procedimientos

- Los triggers protegen invariantes locales.
- Los SP ejecutan secuencias completas de negocio.
- Si una regla requiere evaluar varias tablas o varios pasos, debe documentarse y resolverse en SP, no en trigger.

## 6. Triggers de apoyo

### 6.1 Actualizacion automatica de auditoria tecnica

En tablas maestras se pueden usar triggers para actualizar `updated_at` y `updated_by`.

### 6.2 Bloqueo de actualizaciones directas de saldo

Un trigger puede rechazar cualquier update de `saldo_actual` que no venga de un SP autorizado, o bien el disenio puede evitar exponer permisos de escritura directa.

### 6.3 Generacion de bitacora

Los triggers pueden registrar eventos sencillos en `bitacora_operacion`, pero la recomendacion principal es que el SP inserte la bitacora explicitamente para mantener control del contexto de negocio.

## 5. Reglas de implementacion de triggers

- Usar `SIGNAL SQLSTATE '45000'` para invalidar operaciones.
- Mantener mensajes de error estandarizados.
- Evitar consultas recursivas sobre la misma tabla sin necesidad.
- No usar triggers para orquestar procesos largos.
- La logica de expiracion por tiempo debe resolverse con un job o SP programado.

## 6. Casos que no deben ir en triggers

- Ejecucion completa de una transferencia.
- Desembolso completo de un prestamo.
- Aprobaciones que tocan varias tablas.
- Reversos financieros complejos.
- Cierres masivos por vencimiento.

## 7. Resultado esperado

Cada tabla sensible debe tener su conjunto minimo de triggers, pero el motor de negocio real debe quedar en procedimientos almacenados para asegurar claridad y trazabilidad.
