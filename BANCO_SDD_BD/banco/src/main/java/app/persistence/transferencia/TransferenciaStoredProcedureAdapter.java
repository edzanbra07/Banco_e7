package app.persistence.transferencia;

import app.dto.procedimiento.OperacionProcedimientoResultadoDto;
import app.dto.transferencia.TransferenciaCrearRequestDto;
import app.dto.transferencia.TransferenciaDecisionRequestDto;
import jakarta.persistence.EntityManager;
import jakarta.persistence.ParameterMode;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.StoredProcedureQuery;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import org.springframework.stereotype.Repository;

@Repository
public class TransferenciaStoredProcedureAdapter {

	@PersistenceContext
	private EntityManager entityManager;

	public OperacionProcedimientoResultadoDto crear(TransferenciaCrearRequestDto requestDto, Long userId) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_transferencia_crear");
		query.registerStoredProcedureParameter("p_cuenta_origen_id", Long.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_cuenta_destino_id", Long.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_monto", BigDecimal.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_id_usuario_creador", Long.class, ParameterMode.IN);
		registerOutputParameters(query);
		query.setParameter("p_cuenta_origen_id", requestDto.getCuentaOrigenId());
		query.setParameter("p_cuenta_destino_id", requestDto.getCuentaDestinoId());
		query.setParameter("p_monto", requestDto.getMonto());
		query.setParameter("p_id_usuario_creador", userId);
		query.execute();
		return extractResult(query);
	}

	public OperacionProcedimientoResultadoDto aprobar(Long idTransferencia, String observacion, Long userId) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_transferencia_aprobar");
		query.registerStoredProcedureParameter("p_id_transferencia", Long.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_id_usuario_aprobador", Long.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_observacion", String.class, ParameterMode.IN);
		registerOutputParameters(query);
		query.setParameter("p_id_transferencia", idTransferencia);
		query.setParameter("p_id_usuario_aprobador", userId);
		query.setParameter("p_observacion", observacion);
		query.execute();
		return extractResult(query);
	}

	public OperacionProcedimientoResultadoDto rechazar(Long idTransferencia, String observacion, Long userId) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_transferencia_rechazar");
		query.registerStoredProcedureParameter("p_id_transferencia", Long.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_id_usuario_aprobador", Long.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_observacion", String.class, ParameterMode.IN);
		registerOutputParameters(query);
		query.setParameter("p_id_transferencia", idTransferencia);
		query.setParameter("p_id_usuario_aprobador", userId);
		query.setParameter("p_observacion", observacion);
		query.execute();
		return extractResult(query);
	}

	public OperacionProcedimientoResultadoDto ejecutar(Long idTransferencia, Long userId) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_transferencia_ejecutar");
		query.registerStoredProcedureParameter("p_id_transferencia", Long.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_id_usuario_ejecutor", Long.class, ParameterMode.IN);
		registerOutputParameters(query);
		query.setParameter("p_id_transferencia", idTransferencia);
		query.setParameter("p_id_usuario_ejecutor", userId);
		query.execute();
		return extractResult(query);
	}

	@SuppressWarnings("unchecked")
	public ResultSetWithTrace consultarHistorialPorUsuario(Long idUsuario) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_transferencia_consultar_historial_por_usuario");
		query.registerStoredProcedureParameter("p_id_usuario", Long.class, ParameterMode.IN);
		registerOutputParameters(query);
		query.setParameter("p_id_usuario", idUsuario);
		query.execute();
		List<Object[]> rows = query.getResultList();
		List<TransferenciaHistorialRowDto> transferencias = rows.stream().map(TransferenciaStoredProcedureAdapter::toRow).toList();
		return new ResultSetWithTrace(transferencias, (String) query.getOutputParameterValue("o_trace_id"), (Integer) query.getOutputParameterValue("o_codigo_resultado"), (String) query.getOutputParameterValue("o_mensaje_resultado"), asLong(query.getOutputParameterValue("o_id_entidad")));
	}

	private static void registerOutputParameters(StoredProcedureQuery query) {
		query.registerStoredProcedureParameter("o_codigo_resultado", Integer.class, ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_mensaje_resultado", String.class, ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_id_entidad", Long.class, ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_trace_id", String.class, ParameterMode.OUT);
	}

	private static OperacionProcedimientoResultadoDto extractResult(StoredProcedureQuery query) {
		return OperacionProcedimientoResultadoDto.builder()
			.codigoResultado((Integer) query.getOutputParameterValue("o_codigo_resultado"))
			.mensajeResultado((String) query.getOutputParameterValue("o_mensaje_resultado"))
			.idEntidad(asLong(query.getOutputParameterValue("o_id_entidad")))
			.traceId((String) query.getOutputParameterValue("o_trace_id"))
			.build();
	}

	private static TransferenciaHistorialRowDto toRow(Object[] row) {
		return TransferenciaHistorialRowDto.builder()
			.idTransferencia(asLong(row[0]))
			.cuentaOrigenId(asLong(row[1]))
			.cuentaDestinoId(asLong(row[2]))
			.monto(row[3] != null ? new BigDecimal(row[3].toString()) : null)
			.estadoTransferenciaId(asLong(row[4]))
			.fechaCreacion(asTimestamp(row[5]))
			.fechaAprobacion(asTimestamp(row[6]))
			.fechaEjecucion(asTimestamp(row[7]))
			.fechaVencimiento(asTimestamp(row[8]))
			.idUsuarioCreador(asLong(row[9]))
			.idUsuarioAprobador(asLong(row[10]))
			.observacion(asString(row[11]))
			.build();
	}

	private static Long asLong(Object value) {
		if (value == null) {
			return null;
		}
		if (value instanceof Number number) {
			return number.longValue();
		}
		return Long.valueOf(value.toString());
	}

	private static String asString(Object value) {
		return value == null ? null : value.toString();
	}

	private static java.time.LocalDateTime asTimestamp(Object value) {
		if (value == null) {
			return null;
		}
		if (value instanceof Timestamp timestamp) {
			return timestamp.toLocalDateTime();
		}
		return Timestamp.valueOf(value.toString()).toLocalDateTime();
	}

	public record ResultSetWithTrace(List<TransferenciaHistorialRowDto> transferencias, String traceId, Integer codigoResultado, String mensajeResultado, Long idEntidad) {
	}
}