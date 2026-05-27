USE banco_bd;

CREATE OR REPLACE VIEW vw_cliente_persona AS
SELECT c.id_cliente, c.id_identificacion, c.nombre_completo, c.correo_electronico, c.telefono, c.direccion,
       cp.nombres, cp.apellidos, cp.fecha_nacimiento, ec.codigo AS estado_cliente
  FROM cliente c
  JOIN cliente_persona cp ON cp.id_cliente = c.id_cliente
  JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id;

CREATE OR REPLACE VIEW vw_cliente_empresa AS
SELECT c.id_cliente, c.id_identificacion, c.nombre_completo, c.correo_electronico, c.telefono, c.direccion,
       ce.razon_social, ce.nit, ce.id_representante_legal, ec.codigo AS estado_cliente
  FROM cliente c
  JOIN cliente_empresa ce ON ce.id_cliente = c.id_cliente
  JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id;

CREATE OR REPLACE VIEW vw_cuenta_resumen AS
SELECT cu.id_cuenta, cu.numero_cuenta, cu.id_titular_cliente, cu.saldo_actual, cu.fecha_apertura,
       tc.codigo AS tipo_cuenta, ec.codigo AS estado_cuenta, m.codigo AS moneda
  FROM cuenta cu
  JOIN cat_tipo_cuenta tc ON tc.id_catalogo = cu.tipo_cuenta_id
  JOIN cat_estado_cuenta ec ON ec.id_catalogo = cu.estado_cuenta_id
  JOIN cat_moneda m ON m.id_catalogo = cu.moneda_id;

CREATE OR REPLACE VIEW vw_prestamo_resumen AS
SELECT p.id_prestamo, p.id_cliente_solicitante, p.monto_solicitado, p.monto_aprobado, p.tasa_interes, p.plazo_meses,
       ep.codigo AS estado_prestamo, tp.codigo AS tipo_prestamo, p.fecha_solicitud, p.fecha_aprobacion, p.fecha_desembolso
  FROM prestamo p
  JOIN cat_estado_prestamo ep ON ep.id_catalogo = p.estado_prestamo_id
  JOIN cat_tipo_prestamo tp ON tp.id_catalogo = p.tipo_prestamo_id;

CREATE OR REPLACE VIEW vw_transferencia_resumen AS
SELECT t.id_transferencia, t.cuenta_origen_id, t.cuenta_destino_id, t.monto,
       et.codigo AS estado_transferencia, t.fecha_creacion, t.fecha_aprobacion, t.fecha_ejecucion, t.fecha_vencimiento,
       t.id_usuario_creador, t.id_usuario_aprobador, t.observacion
  FROM transferencia t
  JOIN cat_estado_transferencia et ON et.id_catalogo = t.estado_transferencia_id;