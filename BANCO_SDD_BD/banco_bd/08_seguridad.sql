USE banco_bd;

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