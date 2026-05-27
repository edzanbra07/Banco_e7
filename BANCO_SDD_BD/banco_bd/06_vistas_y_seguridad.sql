USE banco_bd;

-- Archivo de compatibilidad historica.
-- El flujo recomendado usa 06_vistas.sql, 07_auditoria.sql y 08_seguridad.sql.

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

CREATE OR REPLACE VIEW vw_bitacora_resumen AS
SELECT b.id_bitacora, b.fecha_hora_operacion, b.id_usuario, b.rol_usuario, b.id_producto_afectado, b.trace_id,
       toper.codigo AS tipo_operacion
  FROM bitacora_operacion b
  JOIN cat_tipo_operacion_bitacora toper ON toper.id_catalogo = b.tipo_operacion_id;

CREATE ROLE IF NOT EXISTS rol_cliente_persona;
CREATE ROLE IF NOT EXISTS rol_cliente_empresa;
CREATE ROLE IF NOT EXISTS rol_empleado_ventanilla;
CREATE ROLE IF NOT EXISTS rol_empleado_comercial;
CREATE ROLE IF NOT EXISTS rol_empleado_empresa;
CREATE ROLE IF NOT EXISTS rol_supervisor_empresa;
CREATE ROLE IF NOT EXISTS rol_analista_interno;
CREATE ROLE IF NOT EXISTS rol_admin_bd;

GRANT EXECUTE ON PROCEDURE banco_bd.sp_transferencia_crear TO rol_cliente_persona;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_prestamo_solicitar TO rol_cliente_persona;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_cliente_consultar_por_usuario TO rol_cliente_persona;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_cuenta_consultar_por_usuario TO rol_cliente_persona;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_prestamo_consultar_por_usuario TO rol_cliente_persona;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_transferencia_consultar_historial_por_usuario TO rol_cliente_persona;

GRANT EXECUTE ON PROCEDURE banco_bd.sp_transferencia_crear TO rol_cliente_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_cliente_consultar_por_usuario TO rol_cliente_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_cuenta_consultar_por_usuario TO rol_cliente_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_prestamo_consultar_por_usuario TO rol_cliente_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_transferencia_consultar_historial_por_usuario TO rol_cliente_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_delegacion_permiso_crear TO rol_cliente_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_delegacion_permiso_cambiar_estado TO rol_cliente_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_delegacion_permiso_consultar_por_empresa TO rol_cliente_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_pago_masivo_crear TO rol_empleado_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_pago_masivo_agregar_detalle TO rol_empleado_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_pago_masivo_consultar_por_empresa TO rol_empleado_empresa;

GRANT SELECT ON banco_bd.vw_cuenta_resumen TO rol_empleado_ventanilla;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_cuenta_abrir TO rol_empleado_ventanilla;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_cuenta_cambiar_estado TO rol_empleado_ventanilla;

GRANT EXECUTE ON PROCEDURE banco_bd.sp_cliente_persona_crear TO rol_empleado_comercial;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_cliente_empresa_crear TO rol_empleado_comercial;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_solicitud_producto_crear TO rol_empleado_comercial;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_solicitud_producto_cambiar_estado TO rol_empleado_comercial;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_solicitud_producto_consultar_por_cliente TO rol_empleado_comercial;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_cliente_asignacion_comercial_crear TO rol_empleado_comercial;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_cliente_asignados_consultar_por_usuario TO rol_empleado_comercial;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_pago_masivo_aprobar TO rol_supervisor_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_pago_masivo_rechazar TO rol_supervisor_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_pago_masivo_ejecutar TO rol_supervisor_empresa;

GRANT EXECUTE ON PROCEDURE banco_bd.sp_transferencia_crear TO rol_empleado_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_transferencia_aprobar TO rol_supervisor_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_transferencia_rechazar TO rol_supervisor_empresa;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_transferencia_ejecutar TO rol_supervisor_empresa;
GRANT SELECT ON banco_bd.vw_transferencia_resumen TO rol_supervisor_empresa;

GRANT EXECUTE ON PROCEDURE banco_bd.sp_prestamo_aprobar TO rol_analista_interno;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_prestamo_rechazar TO rol_analista_interno;
GRANT EXECUTE ON PROCEDURE banco_bd.sp_prestamo_desembolsar TO rol_analista_interno;
GRANT SELECT ON banco_bd.vw_bitacora_resumen TO rol_analista_interno;

GRANT EXECUTE ON PROCEDURE banco_bd.sp_recuperar_saldos_transferencias_cursor TO rol_admin_bd;

GRANT ALL PRIVILEGES ON banco_bd.* TO rol_admin_bd;
