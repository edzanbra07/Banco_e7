package app.services.cuenta;

import app.dto.cuenta.CuentaCambioEstadoRequestDto;
import app.dto.cuenta.CuentaCambioEstadoResponseDto;
import app.dto.procedimiento.OperacionProcedimientoResultadoDto;
import app.exceptions.BusinessRuleException;
import app.persistence.cuenta.CuentaStoredProcedureAdapter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CuentaEstadoService {

	private final CuentaStoredProcedureAdapter procedureAdapter;

	@Transactional
	public CuentaCambioEstadoResponseDto cambiarEstado(CuentaCambioEstadoRequestDto requestDto, Long userId) {
		OperacionProcedimientoResultadoDto result = procedureAdapter.cambiarEstado(requestDto, userId);
		if (result.getCodigoResultado() != null && result.getCodigoResultado() != 0) {
			throw new BusinessRuleException(result.getMensajeResultado());
		}
		return CuentaCambioEstadoResponseDto.builder()
			.idCuenta(result.getIdEntidad())
			.estadoCuentaCodigo(requestDto.getEstadoCuentaCodigo())
			.traceId(result.getTraceId())
			.build();
	}
}