USE banco_bd;

CREATE OR REPLACE VIEW vw_bitacora_resumen AS
SELECT b.id_bitacora, b.fecha_hora_operacion, b.id_usuario, b.rol_usuario, b.id_producto_afectado, b.trace_id,
       toper.codigo AS tipo_operacion
  FROM bitacora_operacion b
  JOIN cat_tipo_operacion_bitacora toper ON toper.id_catalogo = b.tipo_operacion_id;