USE banco_bd;

CREATE TABLE IF NOT EXISTS cat_base (
  id_catalogo BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(80) NOT NULL,
  nombre VARCHAR(150) NOT NULL,
  descripcion VARCHAR(255) NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  orden INT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by BIGINT UNSIGNED NULL,
  updated_by BIGINT UNSIGNED NULL,
  PRIMARY KEY (id_catalogo),
  UNIQUE KEY uk_cat_base_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS cat_tipo_cliente LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_estado_cliente LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_rol_sistema LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_estado_usuario LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_estado_empleado LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_tipo_empleado LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_tipo_cuenta LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_estado_cuenta LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_moneda LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_tipo_prestamo LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_estado_prestamo LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_estado_transferencia LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_categoria_producto LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_estado_producto LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_tipo_movimiento_cuenta LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_estado_solicitud_producto LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_estado_delegacion LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_tipo_permiso LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_estado_pago_masivo LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_tipo_operacion_bitacora LIKE cat_base;
CREATE TABLE IF NOT EXISTS cat_decision_aprobacion LIKE cat_base;

INSERT INTO cat_tipo_cliente (codigo, nombre, descripcion, activo, orden) VALUES
('PERSONA', 'Persona natural', 'Cliente individual del banco', 1, 1),
('EMPRESA', 'Empresa', 'Cliente persona juridica', 1, 2)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_estado_cliente (codigo, nombre, descripcion, activo, orden) VALUES
('ACTIVO', 'Activo', 'Cliente habilitado para operar', 1, 1),
('INACTIVO', 'Inactivo', 'Cliente sin operacion vigente', 1, 2),
('BLOQUEADO', 'Bloqueado', 'Cliente con restriccion operativa', 1, 3),
('CERRADO', 'Cerrado', 'Cliente cerrado definitivamente', 1, 4)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_rol_sistema (codigo, nombre, descripcion, activo, orden) VALUES
('CLIENTE_PERSONA', 'Cliente persona', 'Rol para cliente persona natural', 1, 1),
('CLIENTE_EMPRESA', 'Cliente empresa', 'Rol para cliente juridico', 1, 2),
('EMPLEADO_VENTANILLA', 'Empleado de ventanilla', 'Rol operativo de atencion', 1, 3),
('EMPLEADO_COMERCIAL', 'Empleado comercial', 'Rol comercial', 1, 4),
('EMPLEADO_EMPRESA', 'Empleado de empresa', 'Rol operativo empresarial', 1, 5),
('SUPERVISOR_EMPRESA', 'Supervisor de empresa', 'Rol aprobador empresarial', 1, 6),
('ANALISTA_INTERNO', 'Analista interno', 'Rol de aprobacion y auditoria', 1, 7),
('ADMIN_BD', 'Administrador de base de datos', 'Rol tecnico de administracion', 1, 8)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_estado_usuario (codigo, nombre, descripcion, activo, orden) VALUES
('ACTIVO', 'Activo', 'Usuario habilitado', 1, 1),
('INACTIVO', 'Inactivo', 'Usuario deshabilitado', 1, 2),
('BLOQUEADO', 'Bloqueado', 'Usuario restringido', 1, 3)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_estado_empleado (codigo, nombre, descripcion, activo, orden) VALUES
('ACTIVO', 'Activo', 'Empleado habilitado', 1, 1),
('INACTIVO', 'Inactivo', 'Empleado deshabilitado', 1, 2),
('SUSPENDIDO', 'Suspendido', 'Empleado con restriccion temporal', 1, 3)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_tipo_empleado (codigo, nombre, descripcion, activo, orden) VALUES
('VENTANILLA', 'Ventanilla', 'Personal de caja y atencion', 1, 1),
('COMERCIAL', 'Comercial', 'Personal comercial', 1, 2),
('EMPRESA', 'Empresa', 'Personal operativo empresarial', 1, 3),
('SUPERVISOR', 'Supervisor', 'Personal supervisor', 1, 4),
('ANALISTA', 'Analista', 'Personal de analisis y riesgo', 1, 5)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_tipo_cuenta (codigo, nombre, descripcion, activo, orden) VALUES
('AHORRO', 'Ahorro', 'Cuenta de ahorro', 1, 1),
('CORRIENTE', 'Corriente', 'Cuenta corriente', 1, 2),
('NOMINA', 'Nomina', 'Cuenta de nomina', 1, 3),
('EMPRESARIAL', 'Empresarial', 'Cuenta empresarial', 1, 4)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_estado_cuenta (codigo, nombre, descripcion, activo, orden) VALUES
('ACTIVA', 'Activa', 'Cuenta operativa', 1, 1),
('BLOQUEADA', 'Bloqueada', 'Cuenta con restriccion', 1, 2),
('CANCELADA', 'Cancelada', 'Cuenta cancelada', 1, 3),
('CERRADA', 'Cerrada', 'Cuenta cerrada', 1, 4)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_moneda (codigo, nombre, descripcion, activo, orden) VALUES
('BOB', 'Boliviano', 'Moneda local sugerida', 1, 1),
('USD', 'Dolar estadounidense', 'Moneda dolar', 1, 2),
('EUR', 'Euro', 'Moneda euro', 1, 3)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_tipo_prestamo (codigo, nombre, descripcion, activo, orden) VALUES
('PERSONAL', 'Personal', 'Prestamo personal', 1, 1),
('VEHICULAR', 'Vehicular', 'Prestamo vehicular', 1, 2),
('HIPOTECARIO', 'Hipotecario', 'Prestamo hipotecario', 1, 3),
('COMERCIAL', 'Comercial', 'Prestamo comercial', 1, 4),
('CAPITAL_TRABAJO', 'Capital de trabajo', 'Prestamo para capital de trabajo', 1, 5)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_estado_prestamo (codigo, nombre, descripcion, activo, orden) VALUES
('SOLICITADO', 'Solicitado', 'Prestamo registrado', 1, 1),
('EN_ESTUDIO', 'En estudio', 'Prestamo en analisis', 1, 2),
('APROBADO', 'Aprobado', 'Prestamo aprobado', 1, 3),
('RECHAZADO', 'Rechazado', 'Prestamo rechazado', 1, 4),
('DESEMBOLSADO', 'Desembolsado', 'Prestamo desembolsado', 1, 5),
('CANCELADO', 'Cancelado', 'Prestamo cancelado', 1, 6),
('VENCIDO', 'Vencido', 'Prestamo vencido', 1, 7)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_estado_transferencia (codigo, nombre, descripcion, activo, orden) VALUES
('CREADA', 'Creada', 'Transferencia registrada', 1, 1),
('EN_ESPERA_APROBACION', 'En espera de aprobacion', 'Transferencia pendiente de aprobacion', 1, 2),
('APROBADA', 'Aprobada', 'Transferencia aprobada', 1, 3),
('RECHAZADA', 'Rechazada', 'Transferencia rechazada', 1, 4),
('EJECUTADA', 'Ejecutada', 'Transferencia ejecutada', 1, 5),
('VENCIDA', 'Vencida', 'Transferencia vencida', 1, 6),
('CANCELADA', 'Cancelada', 'Transferencia cancelada', 1, 7)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_categoria_producto (codigo, nombre, descripcion, activo, orden) VALUES
('CUENTA', 'Cuenta', 'Producto tipo cuenta', 1, 1),
('CREDITO', 'Credito', 'Producto de credito', 1, 2),
('TRANSFERENCIA', 'Transferencia', 'Producto de transferencia', 1, 3),
('PAGO', 'Pago', 'Producto de pagos', 1, 4),
('SERVICIO', 'Servicio', 'Servicio bancario', 1, 5)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_estado_producto (codigo, nombre, descripcion, activo, orden) VALUES
('ACTIVO', 'Activo', 'Producto habilitado', 1, 1),
('INACTIVO', 'Inactivo', 'Producto deshabilitado', 1, 2),
('SUSPENDIDO', 'Suspendido', 'Producto suspendido temporalmente', 1, 3),
('RETIRADO', 'Retirado', 'Producto retirado del catalogo operativo', 1, 4)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_tipo_movimiento_cuenta (codigo, nombre, descripcion, activo, orden) VALUES
('ABONO', 'Abono', 'Ingreso a la cuenta', 1, 1),
('CARGO', 'Cargo', 'Salida de la cuenta', 1, 2),
('DESEMBOLSO', 'Desembolso', 'Desembolso de prestamo', 1, 3),
('TRANSFERENCIA_SALIDA', 'Salida por transferencia', 'Debito por transferencia', 1, 4),
('TRANSFERENCIA_ENTRADA', 'Entrada por transferencia', 'Credito por transferencia', 1, 5),
('AJUSTE', 'Ajuste', 'Ajuste manual controlado', 1, 6),
('REVERSO', 'Reverso', 'Reversion de movimiento', 1, 7)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_estado_solicitud_producto (codigo, nombre, descripcion, activo, orden) VALUES
('RECIBIDA', 'Recibida', 'Solicitud creada', 1, 1),
('EN_REVISION', 'En revision', 'Solicitud en analisis', 1, 2),
('APROBADA', 'Aprobada', 'Solicitud aprobada', 1, 3),
('RECHAZADA', 'Rechazada', 'Solicitud rechazada', 1, 4),
('CERRADA', 'Cerrada', 'Solicitud cerrada', 1, 5)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_estado_delegacion (codigo, nombre, descripcion, activo, orden) VALUES
('ACTIVA', 'Activa', 'Delegacion vigente', 1, 1),
('SUSPENDIDA', 'Suspendida', 'Delegacion suspendida', 1, 2),
('VENCIDA', 'Vencida', 'Delegacion vencida', 1, 3),
('REVOCADA', 'Revocada', 'Delegacion revocada', 1, 4)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_estado_pago_masivo (codigo, nombre, descripcion, activo, orden) VALUES
('CREADO', 'Creado', 'Lote de pago creado', 1, 1),
('EN_REVISION', 'En revision', 'Lote en revision', 1, 2),
('APROBADO', 'Aprobado', 'Lote aprobado', 1, 3),
('RECHAZADO', 'Rechazado', 'Lote rechazado', 1, 4),
('EJECUTADO', 'Ejecutado', 'Lote ejecutado', 1, 5),
('VENCIDO', 'Vencido', 'Lote vencido', 1, 6),
('CANCELADO', 'Cancelado', 'Lote cancelado', 1, 7)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_tipo_permiso (codigo, nombre, descripcion, activo, orden) VALUES
('CONSULTA', 'Consulta', 'Permiso solo lectura', 1, 1),
('OPERACION', 'Operacion', 'Permiso operativo', 1, 2),
('APROBACION', 'Aprobacion', 'Permiso de aprobacion', 1, 3),
('ADMINISTRACION', 'Administracion', 'Permiso administrativo', 1, 4)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_tipo_operacion_bitacora (codigo, nombre, descripcion, activo, orden) VALUES
('ALTA_CLIENTE', 'Alta cliente', 'Registro de cliente nuevo', 1, 1),
('APERTURA_CUENTA', 'Apertura de cuenta', 'Registro de apertura de cuenta', 1, 2),
('SOLICITUD_PRESTAMO', 'Solicitud de prestamo', 'Registro de solicitud de prestamo', 1, 3),
('APROBACION_PRESTAMO', 'Aprobacion de prestamo', 'Registro de aprobacion o rechazo', 1, 4),
('DESEMBOLSO_PRESTAMO', 'Desembolso de prestamo', 'Registro de desembolso', 1, 5),
('CREACION_TRANSFERENCIA', 'Creacion de transferencia', 'Registro de creacion', 1, 6),
('APROBACION_TRANSFERENCIA', 'Aprobacion de transferencia', 'Registro de aprobacion o rechazo', 1, 7),
('EJECUCION_TRANSFERENCIA', 'Ejecucion de transferencia', 'Registro de ejecucion', 1, 8),
('SOLICITUD_PRODUCTO', 'Solicitud de producto', 'Registro de solicitud de producto', 1, 9),
('DELEGACION_PERMISO', 'Delegacion de permiso', 'Registro de delegacion de permiso', 1, 10),
('ASIGNACION_CLIENTE', 'Asignacion de cliente', 'Registro de asignacion comercial', 1, 11),
('PAGO_MASIVO', 'Pago masivo', 'Registro de lote de pagos', 1, 12),
('REVISION_AUDITORIA', 'Revision de auditoria', 'Registro de revision', 1, 13),
('CAMBIO_ESTADO', 'Cambio de estado', 'Cambio de estado controlado', 1, 14)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);

INSERT INTO cat_decision_aprobacion (codigo, nombre, descripcion, activo, orden) VALUES
('APROBADO', 'Aprobado', 'Decision favorable', 1, 1),
('RECHAZADO', 'Rechazado', 'Decision desfavorable', 1, 2)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = VALUES(activo), orden = VALUES(orden);