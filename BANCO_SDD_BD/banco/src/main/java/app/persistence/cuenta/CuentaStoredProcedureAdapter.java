package app.persistence.cuenta;

import app.dto.cuenta.CuentaAbrirRequestDto;
import app.dto.cuenta.CuentaCambioEstadoRequestDto;
import app.dto.procedimiento.OperacionProcedimientoResultadoDto;
import jakarta.persistence.EntityManager;
import jakarta.persistence.ParameterMode;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.StoredProcedureQuery;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import org.springframework.stereotype.Repository;

@Repository
public class CuentaStoredProcedureAdapter {

	@PersistenceContext
	private EntityManager entityManager;

	public OperacionProcedimientoResultadoDto abrirCuenta(CuentaAbrirRequestDto requestDto, Long createdBy) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_cuenta_abrir");
		query.registerStoredProcedureParameter("p_numero_cuenta", String.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_id_titular_cliente", Long.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_tipo_cuenta_codigo", String.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_moneda_codigo", String.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_saldo_inicial", BigDecimal.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_created_by", Long.class, ParameterMode.IN);
		registerOutputParameters(query);
		query.setParameter("p_numero_cuenta", requestDto.getNumeroCuenta());
		query.setParameter("p_id_titular_cliente", requestDto.getIdTitularCliente());
		query.setParameter("p_tipo_cuenta_codigo", requestDto.getTipoCuentaCodigo());
		query.setParameter("p_moneda_codigo", requestDto.getMonedaCodigo());
		query.setParameter("p_saldo_inicial", requestDto.getSaldoInicial());
		query.setParameter("p_created_by", createdBy);
		query.execute();
		return extractResult(query);
	}

	public OperacionProcedimientoResultadoDto cambiarEstado(CuentaCambioEstadoRequestDto requestDto, Long userId) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_cuenta_cambiar_estado");
		query.registerStoredProcedureParameter("p_id_cuenta", Long.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_estado_cuenta_codigo", String.class, ParameterMode.IN);
		query.registerStoredProcedureParameter("p_id_usuario_ejecutor", Long.class, ParameterMode.IN);
		registerOutputParameters(query);
		query.setParameter("p_id_cuenta", requestDto.getIdCuenta());
		query.setParameter("p_estado_cuenta_codigo", requestDto.getEstadoCuentaCodigo());
		query.setParameter("p_id_usuario_ejecutor", userId);
		query.execute();
		return extractResult(query);
	}

	@SuppressWarnings("unchecked")
	public ResultSetWithTrace consultarPorUsuario(Long idUsuario) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_cuenta_consultar_por_usuario");
		query.registerStoredProcedureParameter("p_id_usuario", Long.class, ParameterMode.IN);
		registerOutputParameters(query);
		query.setParameter("p_id_usuario", idUsuario);
		query.execute();
		List<Object[]> rows = query.getResultList();
		List<CuentaConsultaPorUsuarioRowDto> cuentas = rows.stream().map(CuentaStoredProcedureAdapter::toRow).toList();
		return new ResultSetWithTrace(cuentas, (String) query.getOutputParameterValue("o_trace_id"), (Integer) query.getOutputParameterValue("o_codigo_resultado"), (String) query.getOutputParameterValue("o_mensaje_resultado"), asLong(query.getOutputParameterValue("o_id_entidad")));
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

	private static CuentaConsultaPorUsuarioRowDto toRow(Object[] row) {
		return CuentaConsultaPorUsuarioRowDto.builder()
			.idCuenta(asLong(row[0]))
			.numeroCuenta(asString(row[1]))
			.saldoActual(row[2] != null ? new BigDecimal(row[2].toString()) : null)
			.fechaApertura(row[3] != null ? ((Date) row[3]).toLocalDate() : null)
			.estadoCuentaId(asLong(row[4]))
			.tipoCuentaId(asLong(row[5]))
			.monedaId(asLong(row[6]))
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

	public record ResultSetWithTrace(List<CuentaConsultaPorUsuarioRowDto> cuentas, String traceId, Integer codigoResultado, String mensajeResultado, Long idEntidad) {
	}
}