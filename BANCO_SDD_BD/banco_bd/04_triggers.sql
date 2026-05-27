USE banco_bd;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_cliente_bi $$
CREATE TRIGGER trg_cliente_bi
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
  IF NEW.id_identificacion IS NULL OR TRIM(NEW.id_identificacion) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Identificacion obligatoria';
  END IF;
  IF NEW.correo_electronico IS NULL OR NEW.correo_electronico NOT LIKE '%@%.%' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Correo electronico invalido';
  END IF;
  IF NEW.telefono IS NULL OR CHAR_LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(NEW.telefono,'0',''),'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9','')) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Telefono invalido';
  END IF;
  IF NEW.direccion IS NULL OR TRIM(NEW.direccion) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Direccion obligatoria';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cliente_bu $$
CREATE TRIGGER trg_cliente_bu
BEFORE UPDATE ON cliente
FOR EACH ROW
BEGIN
  IF NEW.tipo_cliente_id <> OLD.tipo_cliente_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permite cambiar el tipo de cliente sin migracion controlada';
  END IF;
  IF NEW.id_identificacion IS NULL OR TRIM(NEW.id_identificacion) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Identificacion obligatoria';
  END IF;
  IF NEW.correo_electronico IS NULL OR NEW.correo_electronico NOT LIKE '%@%.%' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Correo electronico invalido';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cliente_persona_bi $$
CREATE TRIGGER trg_cliente_persona_bi
BEFORE INSERT ON cliente_persona
FOR EACH ROW
BEGIN
  DECLARE tipo_persona_id BIGINT UNSIGNED;
  IF NEW.nombres IS NULL OR TRIM(NEW.nombres) = '' OR NEW.apellidos IS NULL OR TRIM(NEW.apellidos) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombres y apellidos son obligatorios';
  END IF;
  IF NEW.fecha_nacimiento IS NULL OR TIMESTAMPDIFF(YEAR, NEW.fecha_nacimiento, CURDATE()) < 18 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente persona debe ser mayor de edad';
  END IF;
  SELECT id_catalogo INTO tipo_persona_id FROM cat_tipo_cliente WHERE codigo = 'PERSONA' LIMIT 1;
  IF NOT EXISTS (
    SELECT 1 FROM cliente c WHERE c.id_cliente = NEW.id_cliente AND c.tipo_cliente_id = tipo_persona_id
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente base debe ser de tipo PERSONA';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cliente_persona_bu $$
CREATE TRIGGER trg_cliente_persona_bu
BEFORE UPDATE ON cliente_persona
FOR EACH ROW
BEGIN
  DECLARE tipo_persona_id BIGINT UNSIGNED;
  SELECT id_catalogo INTO tipo_persona_id FROM cat_tipo_cliente WHERE codigo = 'PERSONA' LIMIT 1;
  IF NEW.fecha_nacimiento IS NULL OR TIMESTAMPDIFF(YEAR, NEW.fecha_nacimiento, CURDATE()) < 18 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente persona debe ser mayor de edad';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM cliente c WHERE c.id_cliente = NEW.id_cliente AND c.tipo_cliente_id = tipo_persona_id
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente base debe seguir siendo de tipo PERSONA';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cliente_empresa_bi $$
CREATE TRIGGER trg_cliente_empresa_bi
BEFORE INSERT ON cliente_empresa
FOR EACH ROW
BEGIN
  DECLARE tipo_empresa_id BIGINT UNSIGNED;
  IF NEW.razon_social IS NULL OR TRIM(NEW.razon_social) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Razon social obligatoria';
  END IF;
  IF NEW.nit IS NULL OR TRIM(NEW.nit) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NIT obligatorio';
  END IF;
  SELECT id_catalogo INTO tipo_empresa_id FROM cat_tipo_cliente WHERE codigo = 'EMPRESA' LIMIT 1;
  IF NOT EXISTS (
    SELECT 1 FROM cliente c WHERE c.id_cliente = NEW.id_cliente AND c.tipo_cliente_id = tipo_empresa_id
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente base debe ser de tipo EMPRESA';
  END IF;
  IF NOT EXISTS (
    SELECT 1
      FROM cliente cp
      JOIN cliente_persona pp ON pp.id_cliente = cp.id_cliente
      JOIN cat_estado_cliente ec ON ec.id_catalogo = cp.estado_cliente_id
     WHERE cp.id_cliente = NEW.id_representante_legal
       AND ec.codigo = 'ACTIVO'
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El representante legal debe ser una persona activa';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cliente_empresa_bu $$
CREATE TRIGGER trg_cliente_empresa_bu
BEFORE UPDATE ON cliente_empresa
FOR EACH ROW
BEGIN
  DECLARE tipo_empresa_id BIGINT UNSIGNED;
  SELECT id_catalogo INTO tipo_empresa_id FROM cat_tipo_cliente WHERE codigo = 'EMPRESA' LIMIT 1;
  IF NEW.razon_social IS NULL OR TRIM(NEW.razon_social) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Razon social obligatoria';
  END IF;
  IF NEW.nit IS NULL OR TRIM(NEW.nit) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NIT obligatorio';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM cliente c WHERE c.id_cliente = NEW.id_cliente AND c.tipo_cliente_id = tipo_empresa_id
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente base debe seguir siendo de tipo EMPRESA';
  END IF;
  IF NOT EXISTS (
    SELECT 1
      FROM cliente cp
      JOIN cliente_persona pp ON pp.id_cliente = cp.id_cliente
      JOIN cat_estado_cliente ec ON ec.id_catalogo = cp.estado_cliente_id
     WHERE cp.id_cliente = NEW.id_representante_legal
       AND ec.codigo = 'ACTIVO'
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El representante legal debe ser una persona activa';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_usuario_sistema_bi $$
CREATE TRIGGER trg_usuario_sistema_bi
BEFORE INSERT ON usuario_sistema
FOR EACH ROW
BEGIN
  DECLARE rol_codigo VARCHAR(80);
  DECLARE tiene_cliente INT DEFAULT 0;
  DECLARE tiene_empleado INT DEFAULT 0;
  SELECT codigo INTO rol_codigo FROM cat_rol_sistema WHERE id_catalogo = NEW.rol_sistema_id AND activo = 1 LIMIT 1;
  IF rol_codigo IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rol de sistema invalido o inactivo';
  END IF;
  IF NEW.id_cliente IS NOT NULL THEN
    SET tiene_cliente = 1;
  END IF;
  IF NEW.id_empleado IS NOT NULL THEN
    SET tiene_empleado = 1;
  END IF;
  IF (tiene_cliente + tiene_empleado) <> 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe existir exactamente un vinculo funcional';
  END IF;
  IF rol_codigo LIKE 'CLIENTE_%' AND (tiene_cliente <> 1 OR tiene_empleado <> 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol de cliente requiere un vinculo de cliente';
  END IF;
  IF rol_codigo LIKE 'EMPLEADO_%' OR rol_codigo IN ('SUPERVISOR_EMPRESA', 'ANALISTA_INTERNO') THEN
    IF (tiene_empleado <> 1 OR tiene_cliente <> 0) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol de empleado requiere un vinculo de empleado';
    END IF;
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_usuario_sistema_bu $$
CREATE TRIGGER trg_usuario_sistema_bu
BEFORE UPDATE ON usuario_sistema
FOR EACH ROW
BEGIN
  DECLARE rol_codigo VARCHAR(80);
  DECLARE tiene_cliente INT DEFAULT 0;
  DECLARE tiene_empleado INT DEFAULT 0;
  SELECT codigo INTO rol_codigo FROM cat_rol_sistema WHERE id_catalogo = NEW.rol_sistema_id AND activo = 1 LIMIT 1;
  IF rol_codigo IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rol de sistema invalido o inactivo';
  END IF;
  IF NEW.id_cliente IS NOT NULL THEN
    SET tiene_cliente = 1;
  END IF;
  IF NEW.id_empleado IS NOT NULL THEN
    SET tiene_empleado = 1;
  END IF;
  IF (tiene_cliente + tiene_empleado) <> 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe existir exactamente un vinculo funcional';
  END IF;
  IF rol_codigo LIKE 'CLIENTE_%' AND (tiene_cliente <> 1 OR tiene_empleado <> 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol de cliente requiere un vinculo de cliente';
  END IF;
  IF rol_codigo LIKE 'EMPLEADO_%' OR rol_codigo IN ('SUPERVISOR_EMPRESA', 'ANALISTA_INTERNO') THEN
    IF (tiene_empleado <> 1 OR tiene_cliente <> 0) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol de empleado requiere un vinculo de empleado';
    END IF;
  END IF;
  IF NEW.rol_sistema_id <> OLD.rol_sistema_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cambio de rol requiere control administrativo';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cuenta_bi $$
CREATE TRIGGER trg_cuenta_bi
BEFORE INSERT ON cuenta
FOR EACH ROW
BEGIN
  DECLARE estado_cliente_codigo VARCHAR(80);
  IF NEW.numero_cuenta IS NULL OR TRIM(NEW.numero_cuenta) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero de cuenta obligatorio';
  END IF;
  IF NEW.saldo_actual < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo inicial no puede ser negativo';
  END IF;
  SELECT ec.codigo INTO estado_cliente_codigo
    FROM cliente c
    JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id
   WHERE c.id_cliente = NEW.id_titular_cliente
   LIMIT 1;
  IF estado_cliente_codigo IS NULL OR estado_cliente_codigo NOT IN ('ACTIVO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El titular debe existir y estar activo';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cuenta_bu $$
CREATE TRIGGER trg_cuenta_bu
BEFORE UPDATE ON cuenta
FOR EACH ROW
BEGIN
  IF NEW.saldo_actual < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo no puede quedar negativo';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cuenta_movimiento_bi $$
CREATE TRIGGER trg_cuenta_movimiento_bi
BEFORE INSERT ON cuenta_movimiento
FOR EACH ROW
BEGIN
  IF NEW.monto <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El monto del movimiento debe ser mayor que cero';
  END IF;
  IF NEW.saldo_anterior < 0 OR NEW.saldo_posterior < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los saldos del movimiento deben ser no negativos';
  END IF;
  IF NEW.saldo_posterior <> (NEW.saldo_anterior + NEW.monto) AND NEW.saldo_posterior <> (NEW.saldo_anterior - NEW.monto) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldos del movimiento inconsistentes';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_prestamo_bi $$
CREATE TRIGGER trg_prestamo_bi
BEFORE INSERT ON prestamo
FOR EACH ROW
BEGIN
  DECLARE estado_cliente_codigo VARCHAR(80);
  IF NEW.monto_solicitado <= 0 OR NEW.tasa_interes <= 0 OR NEW.plazo_meses <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Monto, tasa y plazo deben ser positivos';
  END IF;
  SELECT ec.codigo INTO estado_cliente_codigo
    FROM cliente c
    JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id
   WHERE c.id_cliente = NEW.id_cliente_solicitante
   LIMIT 1;
  IF estado_cliente_codigo IS NULL OR estado_cliente_codigo NOT IN ('ACTIVO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente solicitante debe existir y estar activo';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_prestamo_bu $$
CREATE TRIGGER trg_prestamo_bu
BEFORE UPDATE ON prestamo
FOR EACH ROW
BEGIN
  DECLARE estado_anterior VARCHAR(80);
  DECLARE estado_nuevo VARCHAR(80);
  SELECT codigo INTO estado_anterior FROM cat_estado_prestamo WHERE id_catalogo = OLD.estado_prestamo_id LIMIT 1;
  SELECT codigo INTO estado_nuevo FROM cat_estado_prestamo WHERE id_catalogo = NEW.estado_prestamo_id LIMIT 1;
  IF estado_anterior IN ('RECHAZADO', 'DESEMBOLSADO', 'CANCELADO', 'VENCIDO') AND estado_nuevo <> estado_anterior THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El prestamo no puede salir de un estado final';
  END IF;
  IF estado_anterior = 'EN_ESTUDIO' AND estado_nuevo NOT IN ('APROBADO', 'RECHAZADO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de prestamo invalida';
  END IF;
  IF estado_anterior = 'APROBADO' AND estado_nuevo <> 'DESEMBOLSADO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo un prestamo aprobado puede pasar a desembolsado';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_prestamo_aprobacion_bi $$
CREATE TRIGGER trg_prestamo_aprobacion_bi
BEFORE INSERT ON prestamo_aprobacion
FOR EACH ROW
BEGIN
  DECLARE rol_codigo VARCHAR(80);
  DECLARE estado_codigo VARCHAR(80);
  SELECT rs.codigo INTO rol_codigo
    FROM usuario_sistema u
    JOIN cat_rol_sistema rs ON rs.id_catalogo = u.rol_sistema_id
   WHERE u.id_usuario = NEW.id_usuario_aprobador
   LIMIT 1;
  IF rol_codigo <> 'ANALISTA_INTERNO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo Analista Interno puede aprobar prestamos';
  END IF;
  SELECT ep.codigo INTO estado_codigo
    FROM prestamo p
    JOIN cat_estado_prestamo ep ON ep.id_catalogo = p.estado_prestamo_id
   WHERE p.id_prestamo = NEW.id_prestamo
   LIMIT 1;
  IF estado_codigo IS NULL OR estado_codigo NOT IN ('EN_ESTUDIO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El prestamo no esta en estado aprobable';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_transferencia_bi $$
CREATE TRIGGER trg_transferencia_bi
BEFORE INSERT ON transferencia
FOR EACH ROW
BEGIN
  DECLARE estado_origen VARCHAR(80);
  DECLARE estado_destino VARCHAR(80);
  DECLARE estado_usuario_creador VARCHAR(80);
  DECLARE saldo_origen DECIMAL(18,2);
  IF NEW.monto <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El monto debe ser mayor que cero';
  END IF;
  SELECT ec.codigo INTO estado_origen
    FROM cuenta c
    JOIN cat_estado_cuenta ec ON ec.id_catalogo = c.estado_cuenta_id
   WHERE c.id_cuenta = NEW.cuenta_origen_id
   LIMIT 1;
  SELECT ec.codigo INTO estado_destino
    FROM cuenta c
    JOIN cat_estado_cuenta ec ON ec.id_catalogo = c.estado_cuenta_id
   WHERE c.id_cuenta = NEW.cuenta_destino_id
   LIMIT 1;
  IF estado_origen IS NULL OR estado_destino IS NULL OR estado_origen IN ('BLOQUEADA', 'CANCELADA', 'CERRADA') OR estado_destino IN ('BLOQUEADA', 'CANCELADA', 'CERRADA') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Las cuentas deben existir y estar operables';
  END IF;
  IF NEW.cuenta_origen_id = NEW.cuenta_destino_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta origen y destino deben ser diferentes';
  END IF;
  SELECT saldo_actual INTO saldo_origen
    FROM cuenta
   WHERE id_cuenta = NEW.cuenta_origen_id
   LIMIT 1;
  IF saldo_origen < NEW.monto THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente en la cuenta origen';
  END IF;
  SELECT eu.codigo INTO estado_usuario_creador
    FROM usuario_sistema u
    JOIN cat_estado_usuario eu ON eu.id_catalogo = u.estado_usuario_id
   WHERE u.id_usuario = NEW.id_usuario_creador
   LIMIT 1;
  IF estado_usuario_creador IS NULL OR estado_usuario_creador <> 'ACTIVO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario creador debe estar activo';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_transferencia_bu $$
CREATE TRIGGER trg_transferencia_bu
BEFORE UPDATE ON transferencia
FOR EACH ROW
BEGIN
  DECLARE estado_anterior VARCHAR(80);
  DECLARE estado_nuevo VARCHAR(80);
  SELECT codigo INTO estado_anterior FROM cat_estado_transferencia WHERE id_catalogo = OLD.estado_transferencia_id LIMIT 1;
  SELECT codigo INTO estado_nuevo FROM cat_estado_transferencia WHERE id_catalogo = NEW.estado_transferencia_id LIMIT 1;
  IF estado_anterior IN ('RECHAZADA', 'EJECUTADA', 'VENCIDA', 'CANCELADA') AND estado_nuevo <> estado_anterior THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La transferencia no puede salir de un estado final';
  END IF;
  IF estado_anterior = 'CREADA' AND estado_nuevo NOT IN ('EN_ESPERA_APROBACION', 'APROBADA', 'RECHAZADA', 'CANCELADA') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de transferencia invalida';
  END IF;
  IF estado_anterior = 'EN_ESPERA_APROBACION' AND estado_nuevo NOT IN ('APROBADA', 'RECHAZADA', 'VENCIDA', 'CANCELADA') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de transferencia invalida';
  END IF;
  IF estado_anterior = 'APROBADA' AND estado_nuevo <> 'EJECUTADA' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo una transferencia aprobada puede ejecutarse';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_transferencia_aprobacion_bi $$
CREATE TRIGGER trg_transferencia_aprobacion_bi
BEFORE INSERT ON transferencia_aprobacion
FOR EACH ROW
BEGIN
  DECLARE rol_codigo VARCHAR(80);
  DECLARE estado_codigo VARCHAR(80);
  DECLARE creador_id BIGINT UNSIGNED;
  SELECT rs.codigo INTO rol_codigo
    FROM usuario_sistema u
    JOIN cat_rol_sistema rs ON rs.id_catalogo = u.rol_sistema_id
   WHERE u.id_usuario = NEW.id_usuario_aprobador
   LIMIT 1;
  IF rol_codigo NOT IN ('SUPERVISOR_EMPRESA', 'ANALISTA_INTERNO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El aprobador no tiene permiso para decidir transferencias';
  END IF;
  SELECT t.id_usuario_creador, et.codigo INTO creador_id, estado_codigo
    FROM transferencia t
    JOIN cat_estado_transferencia et ON et.id_catalogo = t.estado_transferencia_id
   WHERE t.id_transferencia = NEW.id_transferencia
   LIMIT 1;
  IF estado_codigo IS NULL OR estado_codigo <> 'EN_ESPERA_APROBACION' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La transferencia no esta pendiente de aprobacion';
  END IF;
  IF creador_id = NEW.id_usuario_aprobador THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El creador no puede aprobar su propia transferencia';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_solicitud_producto_bi $$
CREATE TRIGGER trg_solicitud_producto_bi
BEFORE INSERT ON solicitud_producto
FOR EACH ROW
BEGIN
  DECLARE estado_cliente_codigo VARCHAR(80);
  DECLARE estado_solicitud_codigo VARCHAR(80);
  SELECT ec.codigo INTO estado_cliente_codigo
    FROM cliente c
    JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id
   WHERE c.id_cliente = NEW.id_cliente_solicitante
   LIMIT 1;
  IF estado_cliente_codigo IS NULL OR estado_cliente_codigo <> 'ACTIVO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente solicitante debe estar activo';
  END IF;
  SELECT codigo INTO estado_solicitud_codigo FROM cat_estado_solicitud_producto WHERE id_catalogo = NEW.estado_solicitud_id LIMIT 1;
  IF estado_solicitud_codigo IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de solicitud invalido';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_solicitud_producto_bu $$
CREATE TRIGGER trg_solicitud_producto_bu
BEFORE UPDATE ON solicitud_producto
FOR EACH ROW
BEGIN
  DECLARE estado_anterior VARCHAR(80);
  DECLARE estado_nuevo VARCHAR(80);
  SELECT codigo INTO estado_anterior FROM cat_estado_solicitud_producto WHERE id_catalogo = OLD.estado_solicitud_id LIMIT 1;
  SELECT codigo INTO estado_nuevo FROM cat_estado_solicitud_producto WHERE id_catalogo = NEW.estado_solicitud_id LIMIT 1;
  IF estado_anterior IN ('RECHAZADA', 'CERRADA') AND estado_nuevo <> estado_anterior THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no puede salir de un estado final';
  END IF;
  IF estado_anterior = 'RECIBIDA' AND estado_nuevo NOT IN ('EN_REVISION', 'APROBADA', 'RECHAZADA', 'CERRADA') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de solicitud invalida';
  END IF;
  IF estado_anterior = 'EN_REVISION' AND estado_nuevo NOT IN ('APROBADA', 'RECHAZADA', 'CERRADA') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de solicitud invalida';
  END IF;
  IF estado_anterior = 'APROBADA' AND estado_nuevo <> 'CERRADA' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo una solicitud aprobada puede cerrarse';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_delegacion_permiso_bi $$
CREATE TRIGGER trg_delegacion_permiso_bi
BEFORE INSERT ON delegacion_permiso
FOR EACH ROW
BEGIN
  DECLARE estado_empresa VARCHAR(80);
  DECLARE estado_usuario VARCHAR(80);
  IF NEW.fecha_fin IS NOT NULL AND NEW.fecha_fin < NEW.fecha_inicio THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido';
  END IF;
  SELECT ec.codigo INTO estado_empresa
    FROM cliente_empresa ce
    JOIN cliente c ON c.id_cliente = ce.id_cliente
    JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id
   WHERE ce.id_cliente = NEW.id_cliente_empresa
   LIMIT 1;
  IF estado_empresa IS NULL OR estado_empresa <> 'ACTIVO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La empresa debe estar activa';
  END IF;
  SELECT eu.codigo INTO estado_usuario
    FROM usuario_sistema u
    JOIN cat_estado_usuario eu ON eu.id_catalogo = u.estado_usuario_id
   WHERE u.id_usuario = NEW.id_usuario_delegado
   LIMIT 1;
  IF estado_usuario IS NULL OR estado_usuario <> 'ACTIVO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario delegado debe estar activo';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_delegacion_permiso_bu $$
CREATE TRIGGER trg_delegacion_permiso_bu
BEFORE UPDATE ON delegacion_permiso
FOR EACH ROW
BEGIN
  DECLARE estado_anterior VARCHAR(80);
  DECLARE estado_nuevo VARCHAR(80);
  SELECT codigo INTO estado_anterior FROM cat_estado_delegacion WHERE id_catalogo = OLD.estado_delegacion_id LIMIT 1;
  SELECT codigo INTO estado_nuevo FROM cat_estado_delegacion WHERE id_catalogo = NEW.estado_delegacion_id LIMIT 1;
  IF NEW.fecha_fin IS NOT NULL AND NEW.fecha_fin < NEW.fecha_inicio THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido';
  END IF;
  IF estado_anterior IN ('VENCIDA', 'REVOCADA') AND estado_nuevo <> estado_anterior THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La delegacion no puede salir de un estado final';
  END IF;
  IF estado_anterior = 'ACTIVA' AND estado_nuevo NOT IN ('SUSPENDIDA', 'VENCIDA', 'REVOCADA') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de delegacion invalida';
  END IF;
  IF estado_anterior = 'SUSPENDIDA' AND estado_nuevo NOT IN ('ACTIVA', 'REVOCADA', 'VENCIDA') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de delegacion invalida';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cliente_asignacion_comercial_bi $$
CREATE TRIGGER trg_cliente_asignacion_comercial_bi
BEFORE INSERT ON cliente_asignacion_comercial
FOR EACH ROW
BEGIN
  DECLARE estado_cliente VARCHAR(80);
  DECLARE tipo_empleado VARCHAR(80);
  DECLARE estado_empleado VARCHAR(80);
  IF NEW.fecha_fin IS NOT NULL AND NEW.fecha_fin < NEW.fecha_inicio THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido';
  END IF;
  SELECT ec.codigo INTO estado_cliente
    FROM cliente c
    JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id
   WHERE c.id_cliente = NEW.id_cliente
   LIMIT 1;
  IF estado_cliente IS NULL OR estado_cliente <> 'ACTIVO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente debe estar activo';
  END IF;
  SELECT te.codigo, ee.codigo INTO tipo_empleado, estado_empleado
    FROM empleado e
    JOIN cat_tipo_empleado te ON te.id_catalogo = e.tipo_empleado_id
    JOIN cat_estado_empleado ee ON ee.id_catalogo = e.estado_empleado_id
   WHERE e.id_empleado = NEW.id_empleado_comercial
   LIMIT 1;
  IF tipo_empleado IS NULL OR tipo_empleado <> 'COMERCIAL' OR estado_empleado <> 'ACTIVO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado comercial debe existir y estar activo';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cliente_asignacion_comercial_bu $$
CREATE TRIGGER trg_cliente_asignacion_comercial_bu
BEFORE UPDATE ON cliente_asignacion_comercial
FOR EACH ROW
BEGIN
  DECLARE estado_cliente VARCHAR(80);
  DECLARE tipo_empleado VARCHAR(80);
  DECLARE estado_empleado VARCHAR(80);
  IF NEW.fecha_fin IS NOT NULL AND NEW.fecha_fin < NEW.fecha_inicio THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido';
  END IF;
  SELECT ec.codigo INTO estado_cliente
    FROM cliente c
    JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id
   WHERE c.id_cliente = NEW.id_cliente
   LIMIT 1;
  IF estado_cliente IS NULL OR estado_cliente <> 'ACTIVO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente debe estar activo';
  END IF;
  SELECT te.codigo, ee.codigo INTO tipo_empleado, estado_empleado
    FROM empleado e
    JOIN cat_tipo_empleado te ON te.id_catalogo = e.tipo_empleado_id
    JOIN cat_estado_empleado ee ON ee.id_catalogo = e.estado_empleado_id
   WHERE e.id_empleado = NEW.id_empleado_comercial
   LIMIT 1;
  IF tipo_empleado IS NULL OR tipo_empleado <> 'COMERCIAL' OR estado_empleado <> 'ACTIVO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado comercial debe existir y estar activo';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_pago_masivo_bi $$
CREATE TRIGGER trg_pago_masivo_bi
BEFORE INSERT ON pago_masivo
FOR EACH ROW
BEGIN
  DECLARE estado_empresa VARCHAR(80);
  DECLARE estado_cuenta VARCHAR(80);
  IF NEW.total_monto < 0 OR NEW.cantidad_detalles < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Importes invalidos';
  END IF;
  SELECT ec.codigo INTO estado_empresa
    FROM cliente_empresa ce
    JOIN cliente c ON c.id_cliente = ce.id_cliente
    JOIN cat_estado_cliente ec ON ec.id_catalogo = c.estado_cliente_id
   WHERE ce.id_cliente = NEW.id_cliente_empresa
   LIMIT 1;
  IF estado_empresa IS NULL OR estado_empresa <> 'ACTIVO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La empresa debe estar activa';
  END IF;
  SELECT ec.codigo INTO estado_cuenta
    FROM cuenta cu
    JOIN cat_estado_cuenta ec ON ec.id_catalogo = cu.estado_cuenta_id
   WHERE cu.id_cuenta = NEW.id_cuenta_origen
     AND cu.id_titular_cliente = NEW.id_cliente_empresa
   LIMIT 1;
  IF estado_cuenta IS NULL OR estado_cuenta <> 'ACTIVA' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta origen debe ser de la empresa y estar activa';
  END IF;
  IF COALESCE(NEW.total_monto, 0) <> 0 OR COALESCE(NEW.cantidad_detalles, 0) <> 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pago masivo se inicializa en cero y se completa con detalles';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_pago_masivo_bu $$
CREATE TRIGGER trg_pago_masivo_bu
BEFORE UPDATE ON pago_masivo
FOR EACH ROW
BEGIN
  DECLARE estado_anterior VARCHAR(80);
  DECLARE estado_nuevo VARCHAR(80);
  SELECT codigo INTO estado_anterior FROM cat_estado_pago_masivo WHERE id_catalogo = OLD.estado_pago_masivo_id LIMIT 1;
  SELECT codigo INTO estado_nuevo FROM cat_estado_pago_masivo WHERE id_catalogo = NEW.estado_pago_masivo_id LIMIT 1;
  IF estado_anterior IN ('RECHAZADO', 'EJECUTADO', 'VENCIDO', 'CANCELADO') AND estado_nuevo <> estado_anterior THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pago masivo no puede salir de un estado final';
  END IF;
  IF estado_anterior = 'CREADO' AND estado_nuevo NOT IN ('EN_REVISION', 'APROBADO', 'RECHAZADO', 'CANCELADO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de pago masivo invalida';
  END IF;
  IF estado_anterior = 'EN_REVISION' AND estado_nuevo NOT IN ('APROBADO', 'RECHAZADO', 'CANCELADO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de pago masivo invalida';
  END IF;
  IF estado_anterior = 'APROBADO' AND estado_nuevo <> 'EJECUTADO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo un pago masivo aprobado puede ejecutarse';
  END IF;
  IF estado_nuevo IN ('APROBADO', 'EJECUTADO') AND (NEW.cantidad_detalles IS NULL OR NEW.cantidad_detalles <= 0 OR NEW.total_monto <= 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un pago masivo aprobado o ejecutado debe tener detalles y monto positivo';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_pago_masivo_detalle_bi $$
CREATE TRIGGER trg_pago_masivo_detalle_bi
BEFORE INSERT ON pago_masivo_detalle
FOR EACH ROW
BEGIN
  DECLARE estado_pago VARCHAR(80);
  DECLARE estado_cuenta VARCHAR(80);
  IF NEW.monto <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El monto del detalle debe ser mayor que cero';
  END IF;
  SELECT ep.codigo INTO estado_pago
    FROM pago_masivo pm
    JOIN cat_estado_pago_masivo ep ON ep.id_catalogo = pm.estado_pago_masivo_id
   WHERE pm.id_pago_masivo = NEW.id_pago_masivo
   LIMIT 1;
  IF estado_pago IS NULL OR estado_pago IN ('RECHAZADO', 'EJECUTADO', 'VENCIDO', 'CANCELADO') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden agregar detalles a un pago masivo cerrado';
  END IF;
  SELECT ec.codigo INTO estado_cuenta
    FROM cuenta cu
    JOIN cat_estado_cuenta ec ON ec.id_catalogo = cu.estado_cuenta_id
   WHERE cu.id_cuenta = NEW.id_cuenta_destino
   LIMIT 1;
  IF estado_cuenta IS NULL OR estado_cuenta <> 'ACTIVA' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta destino debe estar activa';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_bitacora_operacion_bi $$
CREATE TRIGGER trg_bitacora_operacion_bi
BEFORE INSERT ON bitacora_operacion
FOR EACH ROW
BEGIN
  IF NEW.datos_detalle IS NULL OR JSON_VALID(NEW.datos_detalle) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Datos de bitacora JSON invalidos';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_bitacora_operacion_bu $$
CREATE TRIGGER trg_bitacora_operacion_bu
BEFORE UPDATE ON bitacora_operacion
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La bitacora es inmutable';
END $$

DROP TRIGGER IF EXISTS trg_bitacora_operacion_bd $$
CREATE TRIGGER trg_bitacora_operacion_bd
BEFORE DELETE ON bitacora_operacion
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La bitacora es inmutable';
END $$

DROP TRIGGER IF EXISTS trg_usuario_sistema_bd $$
CREATE TRIGGER trg_usuario_sistema_bd
BEFORE DELETE ON usuario_sistema
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
      FROM prestamo p
      JOIN cat_estado_prestamo ep ON ep.id_catalogo = p.estado_prestamo_id
     WHERE p.id_cliente_solicitante = OLD.id_cliente
       AND ep.codigo IN ('EN_ESTUDIO', 'APROBADO', 'DESEMBOLSADO')
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar un usuario con prestamos activos';
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_cuenta_movimiento_bu $$
CREATE TRIGGER trg_cuenta_movimiento_bu
BEFORE UPDATE ON cuenta_movimiento
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ledger de movimientos es inmutable';
END $$

DROP TRIGGER IF EXISTS trg_cuenta_movimiento_bd $$
CREATE TRIGGER trg_cuenta_movimiento_bd
BEFORE DELETE ON cuenta_movimiento
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ledger de movimientos es inmutable';
END $$

DELIMITER ;