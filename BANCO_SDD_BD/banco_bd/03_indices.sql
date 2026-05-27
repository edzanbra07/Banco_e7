USE banco_bd;

-- El modelo ya declara los indices principales dentro de las tablas.

CREATE INDEX idx_bitacora_trace_id ON bitacora_operacion (trace_id);
CREATE INDEX idx_solicitud_producto_gestor ON solicitud_producto (id_usuario_gestor);
CREATE INDEX idx_usuario_rol_estado ON usuario_sistema (rol_sistema_id, estado_usuario_id);
CREATE INDEX idx_transferencia_estado_fecha ON transferencia (estado_transferencia_id, fecha_creacion);
