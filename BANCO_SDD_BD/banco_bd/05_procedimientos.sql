USE banco_bd;

DELIMITER $$

-- Convenio de salida estandar:
-- 0 = exito
-- -1 = excepcion no controlada
-- 1001 = validacion o regla de negocio
-- 1002 = integridad o estado inconsistente
-- 1004 = fondos insuficientes
-- 1005 = duplicado
-- 1006 = transicion de estado invalida
-- 1007 = cuenta bloqueada o inactiva
-- 1008 = datos obligatorios faltantes

DROP PROCEDURE IF EXISTS sp_bitacora_registrar $$
CREATE PROCEDURE sp_bitacora_registrar(
  IN p_tipo_operacion_codigo VARCHAR(80),
  IN p_fecha_hora DATETIME,
  IN p_id_usuario BIGINT UNSIGNED,
  IN p_rol_usuario VARCHAR(80),
  IN p_id_producto_afectado VARCHAR(64),
  IN p_datos_detalle JSON,
  IN p_trace_id VARCHAR(64),
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_tipo_id BIGINT UNSIGNED;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = p_trace_id;
  SELECT id_catalogo INTO v_tipo_id FROM cat_tipo_operacion_bitacora WHERE codigo = p_tipo_operacion_codigo LIMIT 1;
  IF v_tipo_id IS NULL THEN
    SET o_codigo_resultado = 1001;
    SET o_mensaje_resultado = 'Tipo de operacion de bitacora invalido';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de operacion de bitacora invalido';
  END IF;
  INSERT INTO bitacora_operacion (tipo_operacion_id, fecha_hora_operacion, id_usuario, rol_usuario, id_producto_afectado, datos_detalle, trace_id)
  VALUES (v_tipo_id, COALESCE(p_fecha_hora, NOW()), p_id_usuario, p_rol_usuario, p_id_producto_afectado, p_datos_detalle, p_trace_id);
  SET o_id_entidad = LAST_INSERT_ID();
END $$

DROP PROCEDURE IF EXISTS sp_cliente_persona_crear $$
CREATE PROCEDURE sp_cliente_persona_crear(
  IN p_id_identificacion VARCHAR(50),
  IN p_nombre_completo VARCHAR(200),
  IN p_correo_electronico VARCHAR(255),
  IN p_telefono VARCHAR(20),
  IN p_direccion VARCHAR(255),
  IN p_nombres VARCHAR(120),
  IN p_apellidos VARCHAR(120),
  IN p_fecha_nacimiento DATE,
  IN p_created_by BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_tipo_cliente BIGINT UNSIGNED;
  DECLARE v_estado_cliente BIGINT UNSIGNED;
  DECLARE v_id_cliente BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_tipo_cliente FROM cat_tipo_cliente WHERE codigo = 'PERSONA' LIMIT 1;
  SELECT id_catalogo INTO v_estado_cliente FROM cat_estado_cliente WHERE codigo = 'ACTIVO' LIMIT 1;
  INSERT INTO cliente (tipo_cliente_id, estado_cliente_id, id_identificacion, nombre_completo, correo_electronico, telefono, direccion, created_by, updated_by)
  VALUES (v_tipo_cliente, v_estado_cliente, p_id_identificacion, p_nombre_completo, p_correo_electronico, p_telefono, p_direccion, p_created_by, p_created_by);
  SET v_id_cliente = LAST_INSERT_ID();
  INSERT INTO cliente_persona (id_cliente, nombres, apellidos, fecha_nacimiento, created_by, updated_by)
  VALUES (v_id_cliente, p_nombres, p_apellidos, p_fecha_nacimiento, p_created_by, p_created_by);
  CALL sp_bitacora_registrar('ALTA_CLIENTE', NOW(), p_created_by, 'CLIENTE_PERSONA', CAST(v_id_cliente AS CHAR), JSON_OBJECT('tipo', 'PERSONA', 'identificacion', p_id_identificacion), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
  SET o_id_entidad = v_id_cliente;
END $$

DROP PROCEDURE IF EXISTS sp_cliente_empresa_crear $$
CREATE PROCEDURE sp_cliente_empresa_crear(
  IN p_id_identificacion VARCHAR(50),
  IN p_nombre_completo VARCHAR(200),
  IN p_correo_electronico VARCHAR(255),
  IN p_telefono VARCHAR(20),
  IN p_direccion VARCHAR(255),
  IN p_razon_social VARCHAR(200),
  IN p_nit VARCHAR(30),
  IN p_id_representante_legal BIGINT UNSIGNED,
  IN p_created_by BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_tipo_cliente BIGINT UNSIGNED;
  DECLARE v_estado_cliente BIGINT UNSIGNED;
  DECLARE v_id_cliente BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET o_codigo_resultado = -1;
    SET o_mensaje_resultado = 'ERROR';
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_tipo_cliente FROM cat_tipo_cliente WHERE codigo = 'EMPRESA' LIMIT 1;
  SELECT id_catalogo INTO v_estado_cliente FROM cat_estado_cliente WHERE codigo = 'ACTIVO' LIMIT 1;
  INSERT INTO cliente (tipo_cliente_id, estado_cliente_id, id_identificacion, nombre_completo, correo_electronico, telefono, direccion, created_by, updated_by)
  VALUES (v_tipo_cliente, v_estado_cliente, p_id_identificacion, p_nombre_completo, p_correo_electronico, p_telefono, p_direccion, p_created_by, p_created_by);
  SET v_id_cliente = LAST_INSERT_ID();
  INSERT INTO cliente_empresa (id_cliente, razon_social, nit, id_representante_legal, created_by, updated_by)
  VALUES (v_id_cliente, p_razon_social, p_nit, p_id_representante_legal, p_created_by, p_created_by);
  CALL sp_bitacora_registrar('ALTA_CLIENTE', NOW(), p_created_by, 'CLIENTE_EMPRESA', CAST(v_id_cliente AS CHAR), JSON_OBJECT('tipo', 'EMPRESA', 'nit', p_nit), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
  SET o_id_entidad = v_id_cliente;
END $$

DROP PROCEDURE IF EXISTS sp_usuario_registrar $$
CREATE PROCEDURE sp_usuario_registrar(
  IN p_id_cliente BIGINT UNSIGNED,
  IN p_id_empleado BIGINT UNSIGNED,
  IN p_rol_sistema_codigo VARCHAR(80),
  IN p_nombre_completo VARCHAR(200),
  IN p_id_identificacion VARCHAR(50),
  IN p_contrasena_hash VARCHAR(255),
  IN p_correo_electronico VARCHAR(255),
  IN p_telefono VARCHAR(20),
  IN p_fecha_nacimiento DATE,
  IN p_direccion VARCHAR(255),
  IN p_created_by BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_rol_id BIGINT UNSIGNED;
  DECLARE v_estado_usuario BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET o_codigo_resultado = -1;
    SET o_mensaje_resultado = 'ERROR';
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  SELECT id_catalogo INTO v_rol_id FROM cat_rol_sistema WHERE codigo = p_rol_sistema_codigo LIMIT 1;
  SELECT id_catalogo INTO v_estado_usuario FROM cat_estado_usuario WHERE codigo = 'ACTIVO' LIMIT 1;
  INSERT INTO usuario_sistema (id_cliente, id_empleado, rol_sistema_id, estado_usuario_id, nombre_completo, id_identificacion, contrasena_hash, correo_electronico, telefono, fecha_nacimiento, direccion, created_by, updated_by)
  VALUES (p_id_cliente, p_id_empleado, v_rol_id, v_estado_usuario, p_nombre_completo, p_id_identificacion, p_contrasena_hash, p_correo_electronico, p_telefono, p_fecha_nacimiento, p_direccion, p_created_by, p_created_by);
  SET o_id_entidad = LAST_INSERT_ID();
END $$

DROP PROCEDURE IF EXISTS sp_cliente_consultar_por_usuario $$
CREATE PROCEDURE sp_cliente_consultar_por_usuario(
  IN p_id_usuario BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_usuario;
  SET o_trace_id = UUID();
  SELECT c.id_cliente,
         c.id_identificacion,
         c.nombre_completo,
         c.correo_electronico,
         c.telefono,
         c.direccion,
         tc.codigo AS tipo_cliente,
         ec.codigo AS estado_cliente,
         cp.nombres,
         cp.apellidos,
         cp.fecha_nacimiento,
         ce.razon_social,
         ce.nit,
         ce.id_representante_legal
    FROM usuario_sistema u
    JOIN cliente c ON c.id_cliente = u.id_cliente
    JOIN cat_tipo_cliente tc ON tc.id_catalogo = c.tipo_cliente_id
    JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id
    LEFT JOIN cliente_persona cp ON cp.id_cliente = c.id_cliente
    LEFT JOIN cliente_empresa ce ON ce.id_cliente = c.id_cliente
   WHERE u.id_usuario = p_id_usuario;
END $$

DROP PROCEDURE IF EXISTS sp_cuenta_abrir $$
CREATE PROCEDURE sp_cuenta_abrir(
  IN p_numero_cuenta VARCHAR(30),
  IN p_id_titular_cliente BIGINT UNSIGNED,
  IN p_tipo_cuenta_codigo VARCHAR(80),
  IN p_moneda_codigo VARCHAR(80),
  IN p_saldo_inicial DECIMAL(18,2),
  IN p_created_by BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_tipo_cuenta BIGINT UNSIGNED;
  DECLARE v_moneda BIGINT UNSIGNED;
  DECLARE v_estado_activa BIGINT UNSIGNED;
  DECLARE v_estado_cliente VARCHAR(80);
  DECLARE v_id_cuenta BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT ec.codigo INTO v_estado_cliente FROM cliente c JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id WHERE c.id_cliente = p_id_titular_cliente LIMIT 1;
  IF v_estado_cliente IS NULL OR v_estado_cliente <> 'ACTIVO' THEN
    SET o_codigo_resultado = 1001;
    SET o_mensaje_resultado = 'El cliente titular debe estar activo';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente titular debe estar activo';
  END IF;
  SELECT id_catalogo INTO v_tipo_cuenta FROM cat_tipo_cuenta WHERE codigo = p_tipo_cuenta_codigo LIMIT 1;
  SELECT id_catalogo INTO v_moneda FROM cat_moneda WHERE codigo = p_moneda_codigo LIMIT 1;
  SELECT id_catalogo INTO v_estado_activa FROM cat_estado_cuenta WHERE codigo = 'ACTIVA' LIMIT 1;
  INSERT INTO cuenta (numero_cuenta, id_titular_cliente, tipo_cuenta_id, moneda_id, estado_cuenta_id, saldo_actual, fecha_apertura, created_by, updated_by)
  VALUES (p_numero_cuenta, p_id_titular_cliente, v_tipo_cuenta, v_moneda, v_estado_activa, COALESCE(p_saldo_inicial, 0.00), CURDATE(), p_created_by, p_created_by);
  SET v_id_cuenta = LAST_INSERT_ID();
  IF COALESCE(p_saldo_inicial, 0.00) > 0 THEN
    INSERT INTO cuenta_movimiento (id_cuenta, tipo_movimiento_id, monto, saldo_anterior, saldo_posterior, referencia_tipo, referencia_id, descripcion, created_by)
    SELECT v_id_cuenta, tm.id_catalogo, p_saldo_inicial, 0.00, p_saldo_inicial, 'APERTURA_CUENTA', CAST(v_id_cuenta AS CHAR), 'Saldo inicial de apertura', p_created_by
      FROM cat_tipo_movimiento_cuenta tm WHERE tm.codigo = 'ABONO' LIMIT 1;
  END IF;
  CALL sp_bitacora_registrar('APERTURA_CUENTA', NOW(), p_created_by, 'SISTEMA', CAST(v_id_cuenta AS CHAR), JSON_OBJECT('numero_cuenta', p_numero_cuenta, 'saldo_inicial', p_saldo_inicial), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
  SET o_id_entidad = v_id_cuenta;
END $$

DROP PROCEDURE IF EXISTS sp_cuenta_cambiar_estado $$
CREATE PROCEDURE sp_cuenta_cambiar_estado(
  IN p_id_cuenta BIGINT UNSIGNED,
  IN p_estado_cuenta_codigo VARCHAR(80),
  IN p_id_usuario_ejecutor BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_nuevo BIGINT UNSIGNED;
  DECLARE v_estado_actual BIGINT UNSIGNED;
  DECLARE v_codigo_actual VARCHAR(80);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_cuenta;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_nuevo FROM cat_estado_cuenta WHERE codigo = p_estado_cuenta_codigo LIMIT 1;
  SELECT estado_cuenta_id INTO v_estado_actual FROM cuenta WHERE id_cuenta = p_id_cuenta FOR UPDATE;
  SELECT codigo INTO v_codigo_actual FROM cat_estado_cuenta WHERE id_catalogo = v_estado_actual LIMIT 1;
  IF v_estado_nuevo IS NULL THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'Estado de cuenta invalido';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de cuenta invalido';
  END IF;
  IF v_codigo_actual IN ('CANCELADA', 'CERRADA') AND p_estado_cuenta_codigo <> v_codigo_actual THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'La cuenta no puede reactivarse desde un estado final';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta no puede reactivarse desde un estado final';
  END IF;
  UPDATE cuenta SET estado_cuenta_id = v_estado_nuevo, updated_by = p_id_usuario_ejecutor WHERE id_cuenta = p_id_cuenta;
  CALL sp_bitacora_registrar('CAMBIO_ESTADO', NOW(), p_id_usuario_ejecutor, 'SISTEMA', CAST(p_id_cuenta AS CHAR), JSON_OBJECT('tabla', 'cuenta', 'estado_nuevo', p_estado_cuenta_codigo), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_prestamo_solicitar $$
CREATE PROCEDURE sp_prestamo_solicitar(
  IN p_tipo_prestamo_codigo VARCHAR(80),
  IN p_id_cliente_solicitante BIGINT UNSIGNED,
  IN p_monto_solicitado DECIMAL(18,2),
  IN p_tasa_interes DECIMAL(9,4),
  IN p_plazo_meses INT,
  IN p_id_cuenta_destino_desembolso BIGINT UNSIGNED,
  IN p_created_by BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_tipo_prestamo BIGINT UNSIGNED;
  DECLARE v_estado_solicitado BIGINT UNSIGNED;
  DECLARE v_id_prestamo BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_tipo_prestamo FROM cat_tipo_prestamo WHERE codigo = p_tipo_prestamo_codigo LIMIT 1;
  SELECT id_catalogo INTO v_estado_solicitado FROM cat_estado_prestamo WHERE codigo = 'EN_ESTUDIO' LIMIT 1;
  IF v_tipo_prestamo IS NULL THEN
    SET o_codigo_resultado = 1001;
    SET o_mensaje_resultado = 'Tipo de prestamo invalido';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de prestamo invalido';
  END IF;
  INSERT INTO prestamo (tipo_prestamo_id, id_cliente_solicitante, monto_solicitado, monto_aprobado, tasa_interes, plazo_meses, estado_prestamo_id, fecha_solicitud, id_cuenta_destino_desembolso, created_by, updated_by)
  VALUES (v_tipo_prestamo, p_id_cliente_solicitante, p_monto_solicitado, NULL, p_tasa_interes, p_plazo_meses, v_estado_solicitado, NOW(), p_id_cuenta_destino_desembolso, p_created_by, p_created_by);
  SET v_id_prestamo = LAST_INSERT_ID();
  CALL sp_bitacora_registrar('SOLICITUD_PRESTAMO', NOW(), p_created_by, 'SISTEMA', CAST(v_id_prestamo AS CHAR), JSON_OBJECT('monto', p_monto_solicitado, 'plazo_meses', p_plazo_meses), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
  SET o_id_entidad = v_id_prestamo;
END $$

DROP PROCEDURE IF EXISTS sp_prestamo_aprobar $$
CREATE PROCEDURE sp_prestamo_aprobar(
  IN p_id_prestamo BIGINT UNSIGNED,
  IN p_id_usuario_aprobador BIGINT UNSIGNED,
  IN p_observacion VARCHAR(255),
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_aprobado BIGINT UNSIGNED;
  DECLARE v_estado_en_estudio BIGINT UNSIGNED;
  DECLARE v_estado_actual BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_prestamo;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_aprobado FROM cat_decision_aprobacion WHERE codigo = 'APROBADO' LIMIT 1;
  SELECT id_catalogo INTO v_estado_en_estudio FROM cat_estado_prestamo WHERE codigo = 'EN_ESTUDIO' LIMIT 1;
  SELECT estado_prestamo_id INTO v_estado_actual FROM prestamo WHERE id_prestamo = p_id_prestamo FOR UPDATE;
  IF v_estado_actual <> v_estado_en_estudio THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'El prestamo no esta en estado aprobable';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El prestamo no esta en estado aprobable';
  END IF;
  INSERT INTO prestamo_aprobacion (id_prestamo, id_usuario_aprobador, decision_id, observacion)
  VALUES (p_id_prestamo, p_id_usuario_aprobador, v_aprobado, p_observacion);
  UPDATE prestamo
     SET estado_prestamo_id = (SELECT id_catalogo FROM cat_estado_prestamo WHERE codigo = 'APROBADO' LIMIT 1),
         fecha_aprobacion = NOW(),
         updated_by = p_id_usuario_aprobador
   WHERE id_prestamo = p_id_prestamo;
  CALL sp_bitacora_registrar('APROBACION_PRESTAMO', NOW(), p_id_usuario_aprobador, 'ANALISTA_INTERNO', CAST(p_id_prestamo AS CHAR), JSON_OBJECT('decision', 'APROBADO', 'observacion', p_observacion), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_prestamo_rechazar $$
CREATE PROCEDURE sp_prestamo_rechazar(
  IN p_id_prestamo BIGINT UNSIGNED,
  IN p_id_usuario_aprobador BIGINT UNSIGNED,
  IN p_observacion VARCHAR(255),
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_rechazado BIGINT UNSIGNED;
  DECLARE v_estado_en_estudio BIGINT UNSIGNED;
  DECLARE v_estado_actual BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_prestamo;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_rechazado FROM cat_decision_aprobacion WHERE codigo = 'RECHAZADO' LIMIT 1;
  SELECT id_catalogo INTO v_estado_en_estudio FROM cat_estado_prestamo WHERE codigo = 'EN_ESTUDIO' LIMIT 1;
  SELECT estado_prestamo_id INTO v_estado_actual FROM prestamo WHERE id_prestamo = p_id_prestamo FOR UPDATE;
  IF v_estado_actual <> v_estado_en_estudio THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'El prestamo no esta en estado rechazable';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El prestamo no esta en estado rechazable';
  END IF;
  INSERT INTO prestamo_aprobacion (id_prestamo, id_usuario_aprobador, decision_id, observacion)
  VALUES (p_id_prestamo, p_id_usuario_aprobador, v_rechazado, p_observacion);
  UPDATE prestamo
     SET estado_prestamo_id = (SELECT id_catalogo FROM cat_estado_prestamo WHERE codigo = 'RECHAZADO' LIMIT 1),
         updated_by = p_id_usuario_aprobador
   WHERE id_prestamo = p_id_prestamo;
  CALL sp_bitacora_registrar('APROBACION_PRESTAMO', NOW(), p_id_usuario_aprobador, 'ANALISTA_INTERNO', CAST(p_id_prestamo AS CHAR), JSON_OBJECT('decision', 'RECHAZADO', 'observacion', p_observacion), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_prestamo_desembolsar $$
CREATE PROCEDURE sp_prestamo_desembolsar(
  IN p_id_prestamo BIGINT UNSIGNED,
  IN p_id_usuario_ejecutor BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_id_cuenta BIGINT UNSIGNED;
  DECLARE v_monto DECIMAL(18,2);
  DECLARE v_estado_aprobado BIGINT UNSIGNED;
  DECLARE v_estado_desembolsado BIGINT UNSIGNED;
  DECLARE v_estado_cuenta VARCHAR(80);
  DECLARE v_saldo_actual DECIMAL(18,2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_prestamo;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_aprobado FROM cat_estado_prestamo WHERE codigo = 'APROBADO' LIMIT 1;
  SELECT id_catalogo INTO v_estado_desembolsado FROM cat_estado_prestamo WHERE codigo = 'DESEMBOLSADO' LIMIT 1;
  SELECT id_cuenta_destino_desembolso, COALESCE(monto_aprobado, monto_solicitado) INTO v_id_cuenta, v_monto
    FROM prestamo WHERE id_prestamo = p_id_prestamo FOR UPDATE;
  IF v_id_cuenta IS NULL THEN
    SET o_codigo_resultado = 1002;
    SET o_mensaje_resultado = 'El prestamo no tiene cuenta destino de desembolso';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El prestamo no tiene cuenta destino de desembolso';
  END IF;
  IF (SELECT estado_prestamo_id FROM prestamo WHERE id_prestamo = p_id_prestamo) <> v_estado_aprobado THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'Solo un prestamo aprobado puede desembolsarse';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo un prestamo aprobado puede desembolsarse';
  END IF;
  SELECT ec.codigo INTO v_estado_cuenta
    FROM cuenta cu
    JOIN cat_estado_cuenta ec ON ec.id_catalogo = cu.estado_cuenta_id
   WHERE cu.id_cuenta = v_id_cuenta
   FOR UPDATE;
  IF v_estado_cuenta IS NULL OR v_estado_cuenta <> 'ACTIVA' THEN
    SET o_codigo_resultado = 1007;
    SET o_mensaje_resultado = 'La cuenta destino debe estar activa para desembolsar el prestamo';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta destino debe estar activa para desembolsar el prestamo';
  END IF;
  SELECT saldo_actual INTO v_saldo_actual FROM cuenta WHERE id_cuenta = v_id_cuenta FOR UPDATE;
  UPDATE cuenta SET saldo_actual = saldo_actual + v_monto, updated_by = p_id_usuario_ejecutor WHERE id_cuenta = v_id_cuenta;
  INSERT INTO cuenta_movimiento (id_cuenta, tipo_movimiento_id, monto, saldo_anterior, saldo_posterior, referencia_tipo, referencia_id, descripcion, created_by)
  SELECT v_id_cuenta, tm.id_catalogo, v_monto, v_saldo_actual, v_saldo_actual + v_monto, 'PRESTAMO', CAST(p_id_prestamo AS CHAR), 'Desembolso de prestamo', p_id_usuario_ejecutor
    FROM cat_tipo_movimiento_cuenta tm WHERE tm.codigo = 'DESEMBOLSO' LIMIT 1;
  UPDATE prestamo
     SET estado_prestamo_id = v_estado_desembolsado,
         fecha_desembolso = NOW(),
         updated_by = p_id_usuario_ejecutor
   WHERE id_prestamo = p_id_prestamo;
  INSERT INTO prestamo_desembolso (id_prestamo, id_cuenta_destino, monto_desembolsado, fecha_desembolso, id_usuario_ejecutor)
  VALUES (p_id_prestamo, v_id_cuenta, v_monto, NOW(), p_id_usuario_ejecutor);
  CALL sp_bitacora_registrar('DESEMBOLSO_PRESTAMO', NOW(), p_id_usuario_ejecutor, 'ANALISTA_INTERNO', CAST(p_id_prestamo AS CHAR), JSON_OBJECT('monto', v_monto, 'cuenta', v_id_cuenta), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_transferencia_crear $$
CREATE PROCEDURE sp_transferencia_crear(
  IN p_cuenta_origen_id BIGINT UNSIGNED,
  IN p_cuenta_destino_id BIGINT UNSIGNED,
  IN p_monto DECIMAL(18,2),
  IN p_id_usuario_creador BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_creada BIGINT UNSIGNED;
  DECLARE v_estado_en_espera BIGINT UNSIGNED;
  DECLARE v_estado_ejecutada BIGINT UNSIGNED;
  DECLARE v_umbral DECIMAL(18,2) DEFAULT 10000.00;
  DECLARE v_id_transferencia BIGINT UNSIGNED;
  DECLARE v_saldo_origen DECIMAL(18,2);
  DECLARE v_saldo_destino DECIMAL(18,2);
  DECLARE v_estado_origen VARCHAR(80);
  DECLARE v_estado_destino VARCHAR(80);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_creada FROM cat_estado_transferencia WHERE codigo = 'CREADA' LIMIT 1;
  SELECT id_catalogo INTO v_estado_en_espera FROM cat_estado_transferencia WHERE codigo = 'EN_ESPERA_APROBACION' LIMIT 1;
  SELECT id_catalogo INTO v_estado_ejecutada FROM cat_estado_transferencia WHERE codigo = 'EJECUTADA' LIMIT 1;
  INSERT INTO transferencia (cuenta_origen_id, cuenta_destino_id, monto, estado_transferencia_id, fecha_creacion, fecha_vencimiento, id_usuario_creador)
  VALUES (
    p_cuenta_origen_id,
    p_cuenta_destino_id,
    p_monto,
    CASE WHEN p_monto > v_umbral THEN v_estado_en_espera ELSE v_estado_ejecutada END,
    NOW(),
    CASE WHEN p_monto > v_umbral THEN DATE_ADD(NOW(), INTERVAL 1 HOUR) ELSE NULL END,
    p_id_usuario_creador
  );
  SET v_id_transferencia = LAST_INSERT_ID();
  IF p_monto <= v_umbral THEN
    SELECT saldo_actual INTO v_saldo_origen FROM cuenta WHERE id_cuenta = p_cuenta_origen_id FOR UPDATE;
    SELECT saldo_actual INTO v_saldo_destino FROM cuenta WHERE id_cuenta = p_cuenta_destino_id FOR UPDATE;

    SELECT ec.codigo INTO v_estado_origen
      FROM cuenta cu
      JOIN cat_estado_cuenta ec ON ec.id_catalogo = cu.estado_cuenta_id
     WHERE cu.id_cuenta = p_cuenta_origen_id
     FOR UPDATE;
    SELECT ec.codigo INTO v_estado_destino
      FROM cuenta cu
      JOIN cat_estado_cuenta ec ON ec.id_catalogo = cu.estado_cuenta_id
     WHERE cu.id_cuenta = p_cuenta_destino_id
     FOR UPDATE;
    IF v_estado_origen <> 'ACTIVA' OR v_estado_destino <> 'ACTIVA' THEN
      SET o_codigo_resultado = 1007;
      SET o_mensaje_resultado = 'Las cuentas deben estar activas para ejecutar la transferencia';
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Las cuentas deben estar activas para ejecutar la transferencia';
    END IF;

    UPDATE cuenta
       SET saldo_actual = saldo_actual - p_monto,
           updated_by = p_id_usuario_creador
     WHERE id_cuenta = p_cuenta_origen_id;

    UPDATE cuenta
       SET saldo_actual = saldo_actual + p_monto,
           updated_by = p_id_usuario_creador
     WHERE id_cuenta = p_cuenta_destino_id;

    INSERT INTO cuenta_movimiento (id_cuenta, tipo_movimiento_id, monto, saldo_anterior, saldo_posterior, referencia_tipo, referencia_id, descripcion, created_by)
    SELECT p_cuenta_origen_id, tm.id_catalogo, p_monto, v_saldo_origen, v_saldo_origen - p_monto, 'TRANSFERENCIA', CAST(v_id_transferencia AS CHAR), 'Transferencia de salida', p_id_usuario_creador
      FROM cat_tipo_movimiento_cuenta tm WHERE tm.codigo = 'TRANSFERENCIA_SALIDA' LIMIT 1;

    INSERT INTO cuenta_movimiento (id_cuenta, tipo_movimiento_id, monto, saldo_anterior, saldo_posterior, referencia_tipo, referencia_id, descripcion, created_by)
    SELECT p_cuenta_destino_id, tm.id_catalogo, p_monto, v_saldo_destino, v_saldo_destino + p_monto, 'TRANSFERENCIA', CAST(v_id_transferencia AS CHAR), 'Transferencia de entrada', p_id_usuario_creador
      FROM cat_tipo_movimiento_cuenta tm WHERE tm.codigo = 'TRANSFERENCIA_ENTRADA' LIMIT 1;

    UPDATE transferencia
       SET fecha_aprobacion = NULL,
           fecha_ejecucion = NOW(),
           updated_by = p_id_usuario_creador
     WHERE id_transferencia = v_id_transferencia;

    CALL sp_bitacora_registrar('EJECUCION_TRANSFERENCIA', NOW(), p_id_usuario_creador, 'SISTEMA', CAST(v_id_transferencia AS CHAR), JSON_OBJECT('monto', p_monto, 'origen', p_cuenta_origen_id, 'destino', p_cuenta_destino_id), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  END IF;
  CALL sp_bitacora_registrar('CREACION_TRANSFERENCIA', NOW(), p_id_usuario_creador, 'SISTEMA', CAST(v_id_transferencia AS CHAR), JSON_OBJECT('monto', p_monto, 'origen', p_cuenta_origen_id, 'destino', p_cuenta_destino_id), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
  SET o_id_entidad = v_id_transferencia;
END $$

DROP PROCEDURE IF EXISTS sp_cuenta_consultar_por_usuario $$
CREATE PROCEDURE sp_cuenta_consultar_por_usuario(
  IN p_id_usuario BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_id_cliente BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_usuario;
  SET o_trace_id = UUID();
  SELECT id_cliente INTO v_id_cliente FROM usuario_sistema WHERE id_usuario = p_id_usuario LIMIT 1;
  IF v_id_cliente IS NULL THEN
    SET o_codigo_resultado = 1002;
    SET o_mensaje_resultado = 'El usuario no esta vinculado a un cliente';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no esta vinculado a un cliente';
  END IF;
  SELECT id_cuenta, numero_cuenta, saldo_actual, fecha_apertura, estado_cuenta_id, tipo_cuenta_id, moneda_id
    FROM cuenta
   WHERE id_titular_cliente = v_id_cliente;
END $$

DROP PROCEDURE IF EXISTS sp_prestamo_consultar_por_usuario $$
CREATE PROCEDURE sp_prestamo_consultar_por_usuario(
  IN p_id_usuario BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_id_cliente BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_usuario;
  SET o_trace_id = UUID();
  SELECT id_cliente INTO v_id_cliente FROM usuario_sistema WHERE id_usuario = p_id_usuario LIMIT 1;
  IF v_id_cliente IS NULL THEN
    SET o_codigo_resultado = 1002;
    SET o_mensaje_resultado = 'El usuario no esta vinculado a un cliente';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no esta vinculado a un cliente';
  END IF;
  SELECT id_prestamo, monto_solicitado, monto_aprobado, tasa_interes, plazo_meses, estado_prestamo_id, fecha_solicitud, fecha_aprobacion, fecha_desembolso
    FROM prestamo
   WHERE id_cliente_solicitante = v_id_cliente;
END $$

DROP PROCEDURE IF EXISTS sp_transferencia_consultar_historial_por_usuario $$
CREATE PROCEDURE sp_transferencia_consultar_historial_por_usuario(
  IN p_id_usuario BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_id_cliente BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_usuario;
  SET o_trace_id = UUID();
  SELECT id_cliente INTO v_id_cliente FROM usuario_sistema WHERE id_usuario = p_id_usuario LIMIT 1;
  IF v_id_cliente IS NULL THEN
    SET o_codigo_resultado = 1002;
    SET o_mensaje_resultado = 'El usuario no esta vinculado a un cliente';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no esta vinculado a un cliente';
  END IF;
  SELECT t.*
    FROM transferencia t
    JOIN cuenta co ON co.id_cuenta = t.cuenta_origen_id
    JOIN cuenta cd ON cd.id_cuenta = t.cuenta_destino_id
   WHERE co.id_titular_cliente = v_id_cliente
      OR cd.id_titular_cliente = v_id_cliente
   ORDER BY t.fecha_creacion DESC;
END $$

DROP PROCEDURE IF EXISTS sp_solicitud_producto_crear $$
CREATE PROCEDURE sp_solicitud_producto_crear(
  IN p_id_cliente_solicitante BIGINT UNSIGNED,
  IN p_id_producto BIGINT UNSIGNED,
  IN p_observacion TEXT,
  IN p_id_usuario_gestor BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_recibida BIGINT UNSIGNED;
  DECLARE v_id_solicitud BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_recibida FROM cat_estado_solicitud_producto WHERE codigo = 'RECIBIDA' LIMIT 1;
  INSERT INTO solicitud_producto (id_cliente_solicitante, id_producto, estado_solicitud_id, id_usuario_gestor, fecha_solicitud, observacion, created_by, updated_by)
  VALUES (p_id_cliente_solicitante, p_id_producto, v_estado_recibida, p_id_usuario_gestor, NOW(), p_observacion, p_id_usuario_gestor, p_id_usuario_gestor);
  SET v_id_solicitud = LAST_INSERT_ID();
  CALL sp_bitacora_registrar('SOLICITUD_PRODUCTO', NOW(), p_id_usuario_gestor, 'EMPLEADO_COMERCIAL', CAST(v_id_solicitud AS CHAR), JSON_OBJECT('cliente', p_id_cliente_solicitante, 'producto', p_id_producto), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
  SET o_id_entidad = v_id_solicitud;
END $$

DROP PROCEDURE IF EXISTS sp_solicitud_producto_cambiar_estado $$
CREATE PROCEDURE sp_solicitud_producto_cambiar_estado(
  IN p_id_solicitud_producto BIGINT UNSIGNED,
  IN p_estado_solicitud_codigo VARCHAR(80),
  IN p_id_usuario_gestor BIGINT UNSIGNED,
  IN p_observacion VARCHAR(255),
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_nuevo BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET o_codigo_resultado = -1;
    SET o_mensaje_resultado = 'ERROR';
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_solicitud_producto;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_nuevo FROM cat_estado_solicitud_producto WHERE codigo = p_estado_solicitud_codigo LIMIT 1;
  IF v_estado_nuevo IS NULL THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'Estado de solicitud invalido';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de solicitud invalido';
  END IF;
  UPDATE solicitud_producto
     SET estado_solicitud_id = v_estado_nuevo,
         id_usuario_gestor = p_id_usuario_gestor,
         observacion = p_observacion,
         updated_by = p_id_usuario_gestor
   WHERE id_solicitud_producto = p_id_solicitud_producto;
  CALL sp_bitacora_registrar('CAMBIO_ESTADO', NOW(), p_id_usuario_gestor, 'EMPLEADO_COMERCIAL', CAST(p_id_solicitud_producto AS CHAR), JSON_OBJECT('estado', p_estado_solicitud_codigo, 'observacion', p_observacion), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_solicitud_producto_consultar_por_cliente $$
CREATE PROCEDURE sp_solicitud_producto_consultar_por_cliente(
  IN p_id_cliente BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_cliente;
  SET o_trace_id = UUID();
  SELECT sp.id_solicitud_producto, sp.id_cliente_solicitante, sp.id_producto, sp.estado_solicitud_id, sp.id_usuario_gestor, sp.fecha_solicitud, sp.observacion
    FROM solicitud_producto sp
   WHERE sp.id_cliente_solicitante = p_id_cliente
   ORDER BY sp.fecha_solicitud DESC;
END $$

DROP PROCEDURE IF EXISTS sp_delegacion_permiso_crear $$
CREATE PROCEDURE sp_delegacion_permiso_crear(
  IN p_id_cliente_empresa BIGINT UNSIGNED,
  IN p_id_usuario_delegado BIGINT UNSIGNED,
  IN p_tipo_permiso_codigo VARCHAR(80),
  IN p_fecha_inicio DATE,
  IN p_fecha_fin DATE,
  IN p_observacion VARCHAR(255),
  IN p_created_by BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_tipo_permiso BIGINT UNSIGNED;
  DECLARE v_estado_activa BIGINT UNSIGNED;
  DECLARE v_id_delegacion BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_tipo_permiso FROM cat_tipo_permiso WHERE codigo = p_tipo_permiso_codigo LIMIT 1;
  SELECT id_catalogo INTO v_estado_activa FROM cat_estado_delegacion WHERE codigo = 'ACTIVA' LIMIT 1;
  IF v_tipo_permiso IS NULL THEN
    SET o_codigo_resultado = 1001;
    SET o_mensaje_resultado = 'Tipo de permiso invalido';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de permiso invalido';
  END IF;
  INSERT INTO delegacion_permiso (id_cliente_empresa, id_usuario_delegado, tipo_permiso_id, estado_delegacion_id, fecha_inicio, fecha_fin, observacion, created_by, updated_by)
  VALUES (p_id_cliente_empresa, p_id_usuario_delegado, v_tipo_permiso, v_estado_activa, p_fecha_inicio, p_fecha_fin, p_observacion, p_created_by, p_created_by);
  SET v_id_delegacion = LAST_INSERT_ID();
  CALL sp_bitacora_registrar('DELEGACION_PERMISO', NOW(), p_created_by, 'CLIENTE_EMPRESA', CAST(v_id_delegacion AS CHAR), JSON_OBJECT('permiso', p_tipo_permiso_codigo, 'delegado', p_id_usuario_delegado), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
  SET o_id_entidad = v_id_delegacion;
END $$

DROP PROCEDURE IF EXISTS sp_delegacion_permiso_cambiar_estado $$
CREATE PROCEDURE sp_delegacion_permiso_cambiar_estado(
  IN p_id_delegacion_permiso BIGINT UNSIGNED,
  IN p_estado_delegacion_codigo VARCHAR(80),
  IN p_id_usuario_ejecutor BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_nuevo BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_delegacion_permiso;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_nuevo FROM cat_estado_delegacion WHERE codigo = p_estado_delegacion_codigo LIMIT 1;
  IF v_estado_nuevo IS NULL THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'Estado de delegacion invalido';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de delegacion invalido';
  END IF;
  UPDATE delegacion_permiso
     SET estado_delegacion_id = v_estado_nuevo,
         updated_by = p_id_usuario_ejecutor
   WHERE id_delegacion_permiso = p_id_delegacion_permiso;
  CALL sp_bitacora_registrar('CAMBIO_ESTADO', NOW(), p_id_usuario_ejecutor, 'CLIENTE_EMPRESA', CAST(p_id_delegacion_permiso AS CHAR), JSON_OBJECT('estado', p_estado_delegacion_codigo), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_cliente_asignacion_comercial_crear $$
CREATE PROCEDURE sp_cliente_asignacion_comercial_crear(
  IN p_id_cliente BIGINT UNSIGNED,
  IN p_id_empleado_comercial BIGINT UNSIGNED,
  IN p_fecha_inicio DATE,
  IN p_fecha_fin DATE,
  IN p_observacion VARCHAR(255),
  IN p_created_by BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_id_asignacion BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  INSERT INTO cliente_asignacion_comercial (id_cliente, id_empleado_comercial, fecha_inicio, fecha_fin, observacion, created_by, updated_by)
  VALUES (p_id_cliente, p_id_empleado_comercial, p_fecha_inicio, p_fecha_fin, p_observacion, p_created_by, p_created_by);
  SET v_id_asignacion = LAST_INSERT_ID();
  CALL sp_bitacora_registrar('ASIGNACION_CLIENTE', NOW(), p_created_by, 'EMPLEADO_COMERCIAL', CAST(v_id_asignacion AS CHAR), JSON_OBJECT('cliente', p_id_cliente, 'empleado', p_id_empleado_comercial), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
  SET o_id_entidad = v_id_asignacion;
END $$

DROP PROCEDURE IF EXISTS sp_cliente_asignacion_comercial_revocar $$
CREATE PROCEDURE sp_cliente_asignacion_comercial_revocar(
  IN p_id_asignacion BIGINT UNSIGNED,
  IN p_fecha_fin DATE,
  IN p_id_usuario_ejecutor BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_asignacion;
  SET o_trace_id = UUID();
  START TRANSACTION;
  UPDATE cliente_asignacion_comercial
     SET fecha_fin = COALESCE(p_fecha_fin, CURDATE()),
         updated_by = p_id_usuario_ejecutor
   WHERE id_asignacion = p_id_asignacion;
  CALL sp_bitacora_registrar('CAMBIO_ESTADO', NOW(), p_id_usuario_ejecutor, 'ADMIN_BD', CAST(p_id_asignacion AS CHAR), JSON_OBJECT('accion', 'revocar_asignacion'), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_cliente_asignados_consultar_por_usuario $$
CREATE PROCEDURE sp_cliente_asignados_consultar_por_usuario(
  IN p_id_usuario BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_id_empleado BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_usuario;
  SET o_trace_id = UUID();
  SELECT id_empleado INTO v_id_empleado FROM usuario_sistema WHERE id_usuario = p_id_usuario LIMIT 1;
  IF v_id_empleado IS NULL THEN
    SET o_codigo_resultado = 1002;
    SET o_mensaje_resultado = 'El usuario no esta vinculado a un empleado';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no esta vinculado a un empleado';
  END IF;
  SELECT c.id_cliente, c.id_identificacion, c.nombre_completo, c.correo_electronico, c.telefono, c.direccion, aca.fecha_inicio, aca.fecha_fin, aca.observacion
    FROM cliente_asignacion_comercial aca
    JOIN cliente c ON c.id_cliente = aca.id_cliente
   WHERE aca.id_empleado_comercial = v_id_empleado
   ORDER BY aca.fecha_inicio DESC;
END $$

DROP PROCEDURE IF EXISTS sp_pago_masivo_crear $$
CREATE PROCEDURE sp_pago_masivo_crear(
  IN p_id_cliente_empresa BIGINT UNSIGNED,
  IN p_id_cuenta_origen BIGINT UNSIGNED,
  IN p_observacion VARCHAR(255),
  IN p_id_usuario_creador BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_creado BIGINT UNSIGNED;
  DECLARE v_id_pago_masivo BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_creado FROM cat_estado_pago_masivo WHERE codigo = 'CREADO' LIMIT 1;
  IF v_estado_creado IS NULL THEN
    SET o_codigo_resultado = 1001;
    SET o_mensaje_resultado = 'Estado inicial de pago masivo invalido';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado inicial de pago masivo invalido';
  END IF;
  INSERT INTO pago_masivo (id_cliente_empresa, id_cuenta_origen, id_usuario_creador, estado_pago_masivo_id, fecha_creacion, observacion, created_by, updated_by)
  VALUES (p_id_cliente_empresa, p_id_cuenta_origen, p_id_usuario_creador, v_estado_creado, NOW(), p_observacion, p_id_usuario_creador, p_id_usuario_creador);
  SET v_id_pago_masivo = LAST_INSERT_ID();
  CALL sp_bitacora_registrar('PAGO_MASIVO', NOW(), p_id_usuario_creador, 'EMPLEADO_EMPRESA', CAST(v_id_pago_masivo AS CHAR), JSON_OBJECT('empresa', p_id_cliente_empresa, 'cuenta_origen', p_id_cuenta_origen), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
  SET o_id_entidad = v_id_pago_masivo;
END $$

DROP PROCEDURE IF EXISTS sp_pago_masivo_agregar_detalle $$
CREATE PROCEDURE sp_pago_masivo_agregar_detalle(
  IN p_id_pago_masivo BIGINT UNSIGNED,
  IN p_id_cuenta_destino BIGINT UNSIGNED,
  IN p_monto DECIMAL(18,2),
  IN p_descripcion VARCHAR(255),
  IN p_id_usuario_creador BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  INSERT INTO pago_masivo_detalle (id_pago_masivo, id_cuenta_destino, monto, descripcion, created_by)
  VALUES (p_id_pago_masivo, p_id_cuenta_destino, p_monto, p_descripcion, p_id_usuario_creador);
  UPDATE pago_masivo
     SET total_monto = total_monto + p_monto,
         cantidad_detalles = cantidad_detalles + 1,
         updated_by = p_id_usuario_creador
   WHERE id_pago_masivo = p_id_pago_masivo;
  CALL sp_bitacora_registrar('PAGO_MASIVO', NOW(), p_id_usuario_creador, 'EMPLEADO_EMPRESA', CAST(p_id_pago_masivo AS CHAR), JSON_OBJECT('detalle_cuenta', p_id_cuenta_destino, 'monto', p_monto), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
  SET o_id_entidad = LAST_INSERT_ID();
END $$

DROP PROCEDURE IF EXISTS sp_pago_masivo_aprobar $$
CREATE PROCEDURE sp_pago_masivo_aprobar(
  IN p_id_pago_masivo BIGINT UNSIGNED,
  IN p_id_usuario_aprobador BIGINT UNSIGNED,
  IN p_observacion VARCHAR(255),
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_aprobado BIGINT UNSIGNED;
  DECLARE v_estado_creado BIGINT UNSIGNED;
  DECLARE v_estado_actual BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_pago_masivo;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_aprobado FROM cat_estado_pago_masivo WHERE codigo = 'APROBADO' LIMIT 1;
  SELECT id_catalogo INTO v_estado_creado FROM cat_estado_pago_masivo WHERE codigo = 'CREADO' LIMIT 1;
  SELECT estado_pago_masivo_id INTO v_estado_actual FROM pago_masivo WHERE id_pago_masivo = p_id_pago_masivo FOR UPDATE;
  IF v_estado_actual <> v_estado_creado THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'El pago masivo no esta en estado aprobable';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pago masivo no esta en estado aprobable';
  END IF;
  IF (SELECT cantidad_detalles FROM pago_masivo WHERE id_pago_masivo = p_id_pago_masivo) <= 0 THEN
    SET o_codigo_resultado = 1008;
    SET o_mensaje_resultado = 'El pago masivo debe tener al menos un detalle';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pago masivo debe tener al menos un detalle';
  END IF;
  UPDATE pago_masivo
     SET estado_pago_masivo_id = v_estado_aprobado,
         fecha_aprobacion = NOW(),
         updated_by = p_id_usuario_aprobador,
         observacion = p_observacion
   WHERE id_pago_masivo = p_id_pago_masivo;
  CALL sp_bitacora_registrar('PAGO_MASIVO', NOW(), p_id_usuario_aprobador, 'SUPERVISOR_EMPRESA', CAST(p_id_pago_masivo AS CHAR), JSON_OBJECT('decision', 'APROBADO'), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_pago_masivo_rechazar $$
CREATE PROCEDURE sp_pago_masivo_rechazar(
  IN p_id_pago_masivo BIGINT UNSIGNED,
  IN p_id_usuario_aprobador BIGINT UNSIGNED,
  IN p_observacion VARCHAR(255),
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_rechazado BIGINT UNSIGNED;
  DECLARE v_estado_creado BIGINT UNSIGNED;
  DECLARE v_estado_actual BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_pago_masivo;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_rechazado FROM cat_estado_pago_masivo WHERE codigo = 'RECHAZADO' LIMIT 1;
  SELECT id_catalogo INTO v_estado_creado FROM cat_estado_pago_masivo WHERE codigo = 'CREADO' LIMIT 1;
  SELECT estado_pago_masivo_id INTO v_estado_actual FROM pago_masivo WHERE id_pago_masivo = p_id_pago_masivo FOR UPDATE;
  IF v_estado_actual <> v_estado_creado THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'El pago masivo no esta en estado rechazable';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pago masivo no esta en estado rechazable';
  END IF;
  UPDATE pago_masivo
     SET estado_pago_masivo_id = v_estado_rechazado,
         fecha_aprobacion = NOW(),
         updated_by = p_id_usuario_aprobador,
         observacion = p_observacion
   WHERE id_pago_masivo = p_id_pago_masivo;
  CALL sp_bitacora_registrar('PAGO_MASIVO', NOW(), p_id_usuario_aprobador, 'SUPERVISOR_EMPRESA', CAST(p_id_pago_masivo AS CHAR), JSON_OBJECT('decision', 'RECHAZADO'), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_pago_masivo_ejecutar $$
CREATE PROCEDURE sp_pago_masivo_ejecutar(
  IN p_id_pago_masivo BIGINT UNSIGNED,
  IN p_id_usuario_ejecutor BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_aprobado BIGINT UNSIGNED;
  DECLARE v_estado_ejecutado BIGINT UNSIGNED;
  DECLARE v_cuenta_origen BIGINT UNSIGNED;
  DECLARE v_total DECIMAL(18,2);
  DECLARE v_saldo_origen DECIMAL(18,2);
  DECLARE v_estado_cuenta_origen VARCHAR(80);
  DECLARE v_estado_cuenta_destino VARCHAR(80);
  DECLARE v_fin BOOLEAN DEFAULT FALSE;
  DECLARE v_id_detalle BIGINT UNSIGNED;
  DECLARE v_cuenta_destino BIGINT UNSIGNED;
  DECLARE v_monto DECIMAL(18,2);
  DECLARE v_descripcion VARCHAR(255);

  DECLARE cur_detalles CURSOR FOR
    SELECT id_pago_masivo_detalle, id_cuenta_destino, monto, descripcion
      FROM pago_masivo_detalle
     WHERE id_pago_masivo = p_id_pago_masivo
     ORDER BY id_pago_masivo_detalle;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fin = TRUE;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;

  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_pago_masivo;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_aprobado FROM cat_estado_pago_masivo WHERE codigo = 'APROBADO' LIMIT 1;
  SELECT id_catalogo INTO v_estado_ejecutado FROM cat_estado_pago_masivo WHERE codigo = 'EJECUTADO' LIMIT 1;
  SELECT id_cuenta_origen, total_monto INTO v_cuenta_origen, v_total
    FROM pago_masivo
   WHERE id_pago_masivo = p_id_pago_masivo
   FOR UPDATE;
  IF (SELECT estado_pago_masivo_id FROM pago_masivo WHERE id_pago_masivo = p_id_pago_masivo) <> v_estado_aprobado THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'Solo un pago masivo aprobado puede ejecutarse';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo un pago masivo aprobado puede ejecutarse';
  END IF;
  IF (SELECT cantidad_detalles FROM pago_masivo WHERE id_pago_masivo = p_id_pago_masivo) <= 0 OR v_total <= 0 THEN
    SET o_codigo_resultado = 1008;
    SET o_mensaje_resultado = 'El pago masivo debe tener detalles y monto positivo';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pago masivo debe tener detalles y monto positivo';
  END IF;
  SELECT saldo_actual INTO v_saldo_origen FROM cuenta WHERE id_cuenta = v_cuenta_origen FOR UPDATE;
  SELECT ec.codigo INTO v_estado_cuenta_origen
    FROM cuenta cu
    JOIN cat_estado_cuenta ec ON ec.id_catalogo = cu.estado_cuenta_id
   WHERE cu.id_cuenta = v_cuenta_origen
   FOR UPDATE;
  IF v_estado_cuenta_origen <> 'ACTIVA' THEN
    SET o_codigo_resultado = 1007;
    SET o_mensaje_resultado = 'La cuenta origen debe estar activa';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta origen debe estar activa';
  END IF;
  IF v_saldo_origen < v_total THEN
    SET o_codigo_resultado = 1004;
    SET o_mensaje_resultado = 'Saldo insuficiente en la cuenta origen';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente en la cuenta origen';
  END IF;
  UPDATE cuenta SET saldo_actual = saldo_actual - v_total, updated_by = p_id_usuario_ejecutor WHERE id_cuenta = v_cuenta_origen;

  INSERT INTO cuenta_movimiento (
    id_cuenta, tipo_movimiento_id, monto, saldo_anterior, saldo_posterior,
    referencia_tipo, referencia_id, descripcion, created_by
  )
  SELECT v_cuenta_origen, tm.id_catalogo, v_total, v_saldo_origen, v_saldo_origen - v_total,
         'PAGO_MASIVO', CAST(p_id_pago_masivo AS CHAR), 'Cargo por ejecucion de pago masivo', p_id_usuario_ejecutor
    FROM cat_tipo_movimiento_cuenta tm
   WHERE tm.codigo = 'CARGO'
   LIMIT 1;

  OPEN cur_detalles;
  read_loop: LOOP
    FETCH cur_detalles INTO v_id_detalle, v_cuenta_destino, v_monto, v_descripcion;
    IF v_fin THEN
      LEAVE read_loop;
    END IF;
    SELECT ec.codigo INTO v_estado_cuenta_destino
      FROM cuenta cu
      JOIN cat_estado_cuenta ec ON ec.id_catalogo = cu.estado_cuenta_id
     WHERE cu.id_cuenta = v_cuenta_destino
     FOR UPDATE;
    IF v_estado_cuenta_destino <> 'ACTIVA' THEN
      SET o_codigo_resultado = 1007;
      SET o_mensaje_resultado = 'La cuenta destino debe estar activa';
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta destino debe estar activa';
    END IF;
    UPDATE cuenta SET saldo_actual = saldo_actual + v_monto, updated_by = p_id_usuario_ejecutor WHERE id_cuenta = v_cuenta_destino;
    INSERT INTO cuenta_movimiento (id_cuenta, tipo_movimiento_id, monto, saldo_anterior, saldo_posterior, referencia_tipo, referencia_id, descripcion, created_by)
    SELECT v_cuenta_destino, tm.id_catalogo, v_monto, (SELECT saldo_actual - v_monto FROM cuenta WHERE id_cuenta = v_cuenta_destino), (SELECT saldo_actual FROM cuenta WHERE id_cuenta = v_cuenta_destino), 'PAGO_MASIVO', CAST(p_id_pago_masivo AS CHAR), v_descripcion, p_id_usuario_ejecutor
      FROM cat_tipo_movimiento_cuenta tm WHERE tm.codigo = 'ABONO' LIMIT 1;
  END LOOP;
  CLOSE cur_detalles;
  UPDATE pago_masivo
     SET estado_pago_masivo_id = v_estado_ejecutado,
         fecha_ejecucion = NOW(),
         updated_by = p_id_usuario_ejecutor
   WHERE id_pago_masivo = p_id_pago_masivo;
  CALL sp_bitacora_registrar('PAGO_MASIVO', NOW(), p_id_usuario_ejecutor, 'EMPLEADO_EMPRESA', CAST(p_id_pago_masivo AS CHAR), JSON_OBJECT('monto_total', v_total), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_pago_masivo_consultar_por_empresa $$
CREATE PROCEDURE sp_pago_masivo_consultar_por_empresa(
  IN p_id_cliente_empresa BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_cliente_empresa;
  SET o_trace_id = UUID();
  SELECT id_pago_masivo, id_cliente_empresa, id_cuenta_origen, id_usuario_creador, estado_pago_masivo_id, fecha_creacion, fecha_aprobacion, fecha_ejecucion, observacion, total_monto, cantidad_detalles
    FROM pago_masivo
   WHERE id_cliente_empresa = p_id_cliente_empresa
   ORDER BY fecha_creacion DESC;
END $$

DROP PROCEDURE IF EXISTS sp_delegacion_permiso_consultar_por_empresa $$
CREATE PROCEDURE sp_delegacion_permiso_consultar_por_empresa(
  IN p_id_cliente_empresa BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_cliente_empresa;
  SET o_trace_id = UUID();
  SELECT id_delegacion_permiso, id_cliente_empresa, id_usuario_delegado, tipo_permiso_id, estado_delegacion_id, fecha_inicio, fecha_fin, observacion
    FROM delegacion_permiso
   WHERE id_cliente_empresa = p_id_cliente_empresa
   ORDER BY fecha_inicio DESC;
END $$

DROP PROCEDURE IF EXISTS sp_transferencia_aprobar $$
CREATE PROCEDURE sp_transferencia_aprobar(
  IN p_id_transferencia BIGINT UNSIGNED,
  IN p_id_usuario_aprobador BIGINT UNSIGNED,
  IN p_observacion VARCHAR(255),
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_aprobada BIGINT UNSIGNED;
  DECLARE v_estado_pendiente BIGINT UNSIGNED;
  DECLARE v_estado_actual BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_transferencia;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_aprobada FROM cat_estado_transferencia WHERE codigo = 'APROBADA' LIMIT 1;
  SELECT id_catalogo INTO v_estado_pendiente FROM cat_estado_transferencia WHERE codigo = 'EN_ESPERA_APROBACION' LIMIT 1;
  SELECT estado_transferencia_id INTO v_estado_actual FROM transferencia WHERE id_transferencia = p_id_transferencia FOR UPDATE;
  IF v_estado_actual <> v_estado_pendiente THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'La transferencia no esta pendiente de aprobacion';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La transferencia no esta pendiente de aprobacion';
  END IF;
  INSERT INTO transferencia_aprobacion (id_transferencia, id_usuario_aprobador, decision_id, observacion)
  VALUES (p_id_transferencia, p_id_usuario_aprobador, (SELECT id_catalogo FROM cat_decision_aprobacion WHERE codigo = 'APROBADO' LIMIT 1), p_observacion);
  UPDATE transferencia
     SET estado_transferencia_id = v_estado_aprobada,
         fecha_aprobacion = NOW(),
         id_usuario_aprobador = p_id_usuario_aprobador,
         updated_by = p_id_usuario_aprobador
   WHERE id_transferencia = p_id_transferencia;
  CALL sp_bitacora_registrar('APROBACION_TRANSFERENCIA', NOW(), p_id_usuario_aprobador, 'SUPERVISOR_EMPRESA', CAST(p_id_transferencia AS CHAR), JSON_OBJECT('decision', 'APROBADO', 'observacion', p_observacion), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_transferencia_rechazar $$
CREATE PROCEDURE sp_transferencia_rechazar(
  IN p_id_transferencia BIGINT UNSIGNED,
  IN p_id_usuario_aprobador BIGINT UNSIGNED,
  IN p_observacion VARCHAR(255),
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_rechazada BIGINT UNSIGNED;
  DECLARE v_estado_pendiente BIGINT UNSIGNED;
  DECLARE v_estado_actual BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_transferencia;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_rechazada FROM cat_estado_transferencia WHERE codigo = 'RECHAZADA' LIMIT 1;
  SELECT id_catalogo INTO v_estado_pendiente FROM cat_estado_transferencia WHERE codigo = 'EN_ESPERA_APROBACION' LIMIT 1;
  SELECT estado_transferencia_id INTO v_estado_actual FROM transferencia WHERE id_transferencia = p_id_transferencia FOR UPDATE;
  IF v_estado_actual <> v_estado_pendiente THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'La transferencia no esta pendiente de aprobacion';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La transferencia no esta pendiente de aprobacion';
  END IF;
  INSERT INTO transferencia_aprobacion (id_transferencia, id_usuario_aprobador, decision_id, observacion)
  VALUES (p_id_transferencia, p_id_usuario_aprobador, (SELECT id_catalogo FROM cat_decision_aprobacion WHERE codigo = 'RECHAZADO' LIMIT 1), p_observacion);
  UPDATE transferencia
     SET estado_transferencia_id = v_estado_rechazada,
         fecha_aprobacion = NOW(),
         id_usuario_aprobador = p_id_usuario_aprobador,
         updated_by = p_id_usuario_aprobador
   WHERE id_transferencia = p_id_transferencia;
  CALL sp_bitacora_registrar('APROBACION_TRANSFERENCIA', NOW(), p_id_usuario_aprobador, 'SUPERVISOR_EMPRESA', CAST(p_id_transferencia AS CHAR), JSON_OBJECT('decision', 'RECHAZADO', 'observacion', p_observacion), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_transferencia_ejecutar $$
CREATE PROCEDURE sp_transferencia_ejecutar(
  IN p_id_transferencia BIGINT UNSIGNED,
  IN p_id_usuario_ejecutor BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_cuenta_origen BIGINT UNSIGNED;
  DECLARE v_cuenta_destino BIGINT UNSIGNED;
  DECLARE v_monto DECIMAL(18,2);
  DECLARE v_saldo_origen DECIMAL(18,2);
  DECLARE v_estado_aprobada BIGINT UNSIGNED;
  DECLARE v_estado_ejecutada BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_transferencia;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_aprobada FROM cat_estado_transferencia WHERE codigo = 'APROBADA' LIMIT 1;
  SELECT id_catalogo INTO v_estado_ejecutada FROM cat_estado_transferencia WHERE codigo = 'EJECUTADA' LIMIT 1;
  SELECT cuenta_origen_id, cuenta_destino_id, monto INTO v_cuenta_origen, v_cuenta_destino, v_monto
    FROM transferencia WHERE id_transferencia = p_id_transferencia FOR UPDATE;
  IF (SELECT estado_transferencia_id FROM transferencia WHERE id_transferencia = p_id_transferencia) <> v_estado_aprobada THEN
    SET o_codigo_resultado = 1006;
    SET o_mensaje_resultado = 'Solo una transferencia aprobada puede ejecutarse';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo una transferencia aprobada puede ejecutarse';
  END IF;
  SELECT saldo_actual INTO v_saldo_origen FROM cuenta WHERE id_cuenta = v_cuenta_origen FOR UPDATE;
  IF v_saldo_origen < v_monto THEN
    SET o_codigo_resultado = 1004;
    SET o_mensaje_resultado = 'Saldo insuficiente';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente';
  END IF;
  UPDATE cuenta SET saldo_actual = saldo_actual - v_monto, updated_by = p_id_usuario_ejecutor WHERE id_cuenta = v_cuenta_origen;
  UPDATE cuenta SET saldo_actual = saldo_actual + v_monto, updated_by = p_id_usuario_ejecutor WHERE id_cuenta = v_cuenta_destino;
  INSERT INTO cuenta_movimiento (id_cuenta, tipo_movimiento_id, monto, saldo_anterior, saldo_posterior, referencia_tipo, referencia_id, descripcion, created_by)
  SELECT v_cuenta_origen, tm.id_catalogo, v_monto, v_saldo_origen, v_saldo_origen - v_monto, 'TRANSFERENCIA', CAST(p_id_transferencia AS CHAR), 'Transferencia de salida', p_id_usuario_ejecutor
    FROM cat_tipo_movimiento_cuenta tm WHERE tm.codigo = 'TRANSFERENCIA_SALIDA' LIMIT 1;
  INSERT INTO cuenta_movimiento (id_cuenta, tipo_movimiento_id, monto, saldo_anterior, saldo_posterior, referencia_tipo, referencia_id, descripcion, created_by)
  SELECT v_cuenta_destino, tm.id_catalogo, v_monto, (SELECT saldo_actual - v_monto FROM cuenta WHERE id_cuenta = v_cuenta_destino), (SELECT saldo_actual FROM cuenta WHERE id_cuenta = v_cuenta_destino), 'TRANSFERENCIA', CAST(p_id_transferencia AS CHAR), 'Transferencia de entrada', p_id_usuario_ejecutor
    FROM cat_tipo_movimiento_cuenta tm WHERE tm.codigo = 'TRANSFERENCIA_ENTRADA' LIMIT 1;
  UPDATE transferencia
     SET estado_transferencia_id = v_estado_ejecutada,
         fecha_ejecucion = NOW(),
         updated_by = p_id_usuario_ejecutor
   WHERE id_transferencia = p_id_transferencia;
  CALL sp_bitacora_registrar('EJECUCION_TRANSFERENCIA', NOW(), p_id_usuario_ejecutor, 'SUPERVISOR_EMPRESA', CAST(p_id_transferencia AS CHAR), JSON_OBJECT('monto', v_monto, 'origen', v_cuenta_origen, 'destino', v_cuenta_destino), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_transferencias_vencidas_marcar $$
CREATE PROCEDURE sp_transferencias_vencidas_marcar(
  IN p_id_usuario_ejecutor BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_estado_pendiente BIGINT UNSIGNED;
  DECLARE v_estado_vencida BIGINT UNSIGNED;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  START TRANSACTION;
  SELECT id_catalogo INTO v_estado_pendiente FROM cat_estado_transferencia WHERE codigo = 'EN_ESPERA_APROBACION' LIMIT 1;
  SELECT id_catalogo INTO v_estado_vencida FROM cat_estado_transferencia WHERE codigo = 'VENCIDA' LIMIT 1;
  UPDATE transferencia
     SET estado_transferencia_id = v_estado_vencida,
         updated_by = p_id_usuario_ejecutor
   WHERE estado_transferencia_id = v_estado_pendiente
     AND fecha_vencimiento IS NOT NULL
     AND fecha_vencimiento <= NOW();
  SET o_id_entidad = ROW_COUNT();
  CALL sp_bitacora_registrar('CAMBIO_ESTADO', NOW(), p_id_usuario_ejecutor, 'SISTEMA', NULL, JSON_OBJECT('accion', 'marcar_vencidas', 'filas_afectadas', o_id_entidad), o_trace_id, @b_cod, @b_msg, @b_id, @b_trace);
  COMMIT;
END $$

DROP PROCEDURE IF EXISTS sp_cuenta_consultar_por_cliente $$
CREATE PROCEDURE sp_cuenta_consultar_por_cliente(
  IN p_id_cliente BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_cliente;
  SET o_trace_id = UUID();
  SELECT id_cuenta, numero_cuenta, saldo_actual, fecha_apertura, estado_cuenta_id, tipo_cuenta_id, moneda_id
    FROM cuenta
   WHERE id_titular_cliente = p_id_cliente;
END $$

DROP PROCEDURE IF EXISTS sp_prestamo_consultar_por_cliente $$
CREATE PROCEDURE sp_prestamo_consultar_por_cliente(
  IN p_id_cliente BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_cliente;
  SET o_trace_id = UUID();
  SELECT id_prestamo, monto_solicitado, monto_aprobado, tasa_interes, plazo_meses, estado_prestamo_id, fecha_solicitud, fecha_aprobacion, fecha_desembolso
    FROM prestamo
   WHERE id_cliente_solicitante = p_id_cliente;
END $$

DROP PROCEDURE IF EXISTS sp_transferencia_consultar_historial $$
CREATE PROCEDURE sp_transferencia_consultar_historial(
  IN p_id_cuenta BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = p_id_cuenta;
  SET o_trace_id = UUID();
  SELECT *
    FROM transferencia
   WHERE cuenta_origen_id = p_id_cuenta OR cuenta_destino_id = p_id_cuenta
   ORDER BY fecha_creacion DESC;
END $$

DROP PROCEDURE IF EXISTS sp_bitacora_consultar_por_rango $$
CREATE PROCEDURE sp_bitacora_consultar_por_rango(
  IN p_desde DATETIME,
  IN p_hasta DATETIME,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;
  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();
  SELECT *
    FROM bitacora_operacion
   WHERE fecha_hora_operacion BETWEEN p_desde AND p_hasta
   ORDER BY fecha_hora_operacion DESC;
END $$

DROP PROCEDURE IF EXISTS sp_recuperar_saldos_transferencias_cursor $$
CREATE PROCEDURE sp_recuperar_saldos_transferencias_cursor(
  IN p_id_usuario_ejecutor BIGINT UNSIGNED,
  OUT o_codigo_resultado INT,
  OUT o_mensaje_resultado VARCHAR(255),
  OUT o_id_entidad BIGINT UNSIGNED,
  OUT o_trace_id VARCHAR(64)
)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_fin BOOLEAN DEFAULT FALSE;
  DECLARE v_fecha_corte DATETIME;
  DECLARE v_id_transferencia BIGINT UNSIGNED;
  DECLARE v_cuenta_origen BIGINT UNSIGNED;
  DECLARE v_cuenta_destino BIGINT UNSIGNED;
  DECLARE v_monto DECIMAL(18,2);
  DECLARE v_saldo_origen DECIMAL(18,2);
  DECLARE v_saldo_destino DECIMAL(18,2);
  DECLARE v_estado_transferencia VARCHAR(80);
  DECLARE v_estado_ejecutada BIGINT UNSIGNED;
  DECLARE v_tipo_salida BIGINT UNSIGNED;
  DECLARE v_tipo_entrada BIGINT UNSIGNED;
  DECLARE v_aplicadas INT DEFAULT 0;
  DECLARE v_omitidas INT DEFAULT 0;

  DECLARE cur_transferencias CURSOR FOR
    SELECT t.id_transferencia, t.cuenta_origen_id, t.cuenta_destino_id, t.monto, et.codigo
      FROM transferencia t
      JOIN cat_estado_transferencia et ON et.id_catalogo = t.estado_transferencia_id
     WHERE t.fecha_creacion > v_fecha_corte
       AND et.codigo = 'EJECUTADA'
     ORDER BY t.fecha_creacion, t.id_transferencia;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fin = TRUE;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF o_codigo_resultado = 0 THEN
      SET o_codigo_resultado = -1;
      SET o_mensaje_resultado = 'ERROR';
    END IF;
    SET o_id_entidad = NULL;
  END;

  SET o_codigo_resultado = 0;
  SET o_mensaje_resultado = 'OK';
  SET o_id_entidad = NULL;
  SET o_trace_id = UUID();

  SELECT COALESCE(MAX(fecha_hora_operacion), '1970-01-01 00:00:00')
    INTO v_fecha_corte
    FROM bitacora_operacion;

  SELECT id_catalogo INTO v_estado_ejecutada FROM cat_estado_transferencia WHERE codigo = 'EJECUTADA' LIMIT 1;
  SELECT id_catalogo INTO v_tipo_salida FROM cat_tipo_movimiento_cuenta WHERE codigo = 'TRANSFERENCIA_SALIDA' LIMIT 1;
  SELECT id_catalogo INTO v_tipo_entrada FROM cat_tipo_movimiento_cuenta WHERE codigo = 'TRANSFERENCIA_ENTRADA' LIMIT 1;

  START TRANSACTION;

  OPEN cur_transferencias;

  read_loop: LOOP
    FETCH cur_transferencias INTO v_id_transferencia, v_cuenta_origen, v_cuenta_destino, v_monto, v_estado_transferencia;
    IF v_fin THEN
      LEAVE read_loop;
    END IF;

    IF EXISTS (
      SELECT 1
        FROM cuenta_movimiento cm
       WHERE cm.referencia_tipo = 'TRANSFERENCIA'
         AND cm.referencia_id = CAST(v_id_transferencia AS CHAR)
    ) THEN
      SET v_omitidas = v_omitidas + 1;
    ELSE
      SELECT saldo_actual INTO v_saldo_origen FROM cuenta WHERE id_cuenta = v_cuenta_origen FOR UPDATE;
      SELECT saldo_actual INTO v_saldo_destino FROM cuenta WHERE id_cuenta = v_cuenta_destino FOR UPDATE;

      UPDATE cuenta
         SET saldo_actual = saldo_actual - v_monto,
             updated_by = p_id_usuario_ejecutor
       WHERE id_cuenta = v_cuenta_origen;

      UPDATE cuenta
         SET saldo_actual = saldo_actual + v_monto,
             updated_by = p_id_usuario_ejecutor
       WHERE id_cuenta = v_cuenta_destino;

      INSERT INTO cuenta_movimiento (
        id_cuenta, tipo_movimiento_id, monto, saldo_anterior, saldo_posterior,
        referencia_tipo, referencia_id, descripcion, created_by
      ) VALUES (
        v_cuenta_origen, v_tipo_salida, v_monto, v_saldo_origen, v_saldo_origen - v_monto,
        'TRANSFERENCIA', CAST(v_id_transferencia AS CHAR), 'Recuperacion de transferencia - salida', p_id_usuario_ejecutor
      );

      INSERT INTO cuenta_movimiento (
        id_cuenta, tipo_movimiento_id, monto, saldo_anterior, saldo_posterior,
        referencia_tipo, referencia_id, descripcion, created_by
      ) VALUES (
        v_cuenta_destino, v_tipo_entrada, v_monto, v_saldo_destino, v_saldo_destino + v_monto,
        'TRANSFERENCIA', CAST(v_id_transferencia AS CHAR), 'Recuperacion de transferencia - entrada', p_id_usuario_ejecutor
      );

      SET v_aplicadas = v_aplicadas + 1;
    END IF;
  END LOOP;

  CLOSE cur_transferencias;

  CALL sp_bitacora_registrar(
    'REVISION_AUDITORIA',
    NOW(),
    p_id_usuario_ejecutor,
    'ADMIN_BD',
    NULL,
    JSON_OBJECT(
      'fecha_corte', v_fecha_corte,
      'transferencias_aplicadas', v_aplicadas,
      'transferencias_omitidas', v_omitidas
    ),
    o_trace_id,
    @b_cod,
    @b_msg,
    @b_id,
    @b_trace
  );

  SET o_id_entidad = v_aplicadas;
  SET o_mensaje_resultado = CONCAT('Recuperacion finalizada. Aplicadas: ', v_aplicadas, ', omitidas: ', v_omitidas);

  COMMIT;
END $$

DELIMITER ;