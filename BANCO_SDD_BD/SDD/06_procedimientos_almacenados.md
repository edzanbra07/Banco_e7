# 06. Procedimientos almacenados

## Proposito

Los procedimientos almacenados actuan como servicios de dominio. Encapsulan la logica de negocio, coordinan multiples tablas, respetan transacciones y registran bitacora.

## Contrato operativo

Todo SP de negocio debe documentar:

- entradas;
- salidas estandarizadas con `o_codigo_resultado`, `o_mensaje_resultado`, `o_id_entidad` y `o_trace_id` cuando aplique;
- uso de transaccion y rollback;
- tablas afectadas;
- bitacora asociada;
- reglas de aprobacion, ownership o estado que lo habilitan.

## Servicios definidos

### Identidad y clientes

- `sp_cliente_persona_crear`: crea cliente persona y su subtipo.
- `sp_cliente_empresa_crear`: crea cliente empresa y su subtipo.
- `sp_usuario_registrar`: registra una identidad operativa ligada a cliente o empleado.
- `sp_cliente_consultar_por_usuario`: expone los datos del cliente ligados a la identidad operativa.

### Cuentas

- `sp_cuenta_abrir`: crea una cuenta con saldo inicial opcional.
- `sp_cuenta_cambiar_estado`: cambia el estado de una cuenta con proteccion de estados finales.
- `sp_cuenta_consultar_por_cliente`: expone las cuentas de un cliente.
- `sp_cuenta_consultar_por_usuario`: expone las cuentas desde el contexto de la identidad operativa.

### Creditos

- `sp_prestamo_solicitar`: registra la solicitud de credito en estudio.
- `sp_prestamo_aprobar`: registra decision favorable.
- `sp_prestamo_rechazar`: registra decision desfavorable.
- `sp_prestamo_desembolsar`: ejecuta el desembolso sobre la cuenta destino.
- `sp_prestamo_consultar_por_cliente`: expone los prestamos de un cliente.
- `sp_prestamo_consultar_por_usuario`: expone los prestamos desde la identidad operativa.

### Transferencias

- `sp_transferencia_crear`: registra la transferencia y define si requiere aprobacion.
- `sp_transferencia_aprobar`: registra aprobacion.
- `sp_transferencia_rechazar`: registra rechazo.
- `sp_transferencia_ejecutar`: impacta saldos y movimientos.
- `sp_transferencias_vencidas_marcar`: marca transferencias expiradas.
- `sp_transferencia_consultar_historial`: expone el historial por cuenta.
- `sp_transferencia_consultar_historial_por_usuario`: expone el historial desde la identidad operativa.

### Productos, auditoria y soporte

- `sp_bitacora_registrar`: inserta eventos de auditoria.
- `sp_bitacora_consultar_por_rango`: consulta auditoria por ventana temporal.
- `sp_recuperar_saldos_transferencias_cursor`: rutina tecnica de revision o recuperacion operativa.
- `sp_solicitud_producto_crear`: registra una solicitud comercial.
- `sp_solicitud_producto_cambiar_estado`: actualiza el ciclo de la solicitud.
- `sp_solicitud_producto_consultar_por_cliente`: consulta solicitudes por cliente.
- `sp_delegacion_permiso_crear`: registra una delegacion empresarial.
- `sp_delegacion_permiso_cambiar_estado`: cambia el estado de la delegacion.
- `sp_delegacion_permiso_consultar_por_empresa`: consulta delegaciones por empresa.
- `sp_cliente_asignacion_comercial_crear`: crea una asignacion comercial.
- `sp_cliente_asignacion_comercial_revocar`: revoca una asignacion comercial.
- `sp_cliente_asignados_consultar_por_usuario`: consulta la cartera asignada al comercial.
- `sp_pago_masivo_crear`: crea un lote de pagos.
- `sp_pago_masivo_agregar_detalle`: agrega un destinatario al lote.
- `sp_pago_masivo_aprobar`: aprueba el lote.
- `sp_pago_masivo_rechazar`: rechaza el lote.
- `sp_pago_masivo_ejecutar`: ejecuta el lote aprobado.
- `sp_pago_masivo_consultar_por_empresa`: consulta lotes por empresa.

## Estandar de salida

- `0`: exito.
- `-1`: error no controlado con rollback.
- `1001`: validacion o regla de negocio.
- `1002`: integridad o estado inconsistente.
- `1004`: fondos insuficientes.
- `1006`: transicion de estado invalida.
- `1007`: cuenta bloqueada o inactiva.
- `1008`: datos faltantes o lote incompleto.

Los procedimientos de consulta especializados siguen el mismo criterio de salida para mantener uniformidad de consumo.

## Reglas de implementacion

- Todo SP critico debe abrir transaccion cuando coordine varias tablas.
- Los cambios financieros deben usar bloqueos `FOR UPDATE` donde aplique.
- Los SP deben capturar la semantica del negocio, no solo hacer `INSERT` o `UPDATE` directos.
- Los resultados deben ser trazables por `trace_id` y por registro en bitacora.
- Los SP de aprobacion y ejecucion deben validar rol, estado y ownership.
- Los SP de consulta deben filtrar por contexto de sesion o identidad funcional.

## Criterios de calidad

- Cada SP debe tener nombre descriptivo y proposito unico.
- Cada flujo sensible debe quedar cubierto por prueba positiva y negativa.
- Ningun SP de negocio debe depender de acceso directo a tablas desde el cliente.
- Los procedimientos tecnicos deben quedar documentados como apoyo operacional, no como flujo de usuario final.

