package app.services.cuenta;

import app.dto.cuenta.CuentaAbrirRequestDto;
import app.dto.cuenta.CuentaAbrirResponseDto;
import app.dto.procedimiento.OperacionProcedimientoResultadoDto;
import app.exceptions.BusinessRuleException;
import app.persistence.cuenta.CuentaStoredProcedureAdapter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CuentaAperturaService {

	private final CuentaStoredProcedureAdapter procedureAdapter;

	@Transactional
	public CuentaAbrirResponseDto abrir(CuentaAbrirRequestDto requestDto, Long createdBy) {
		OperacionProcedimientoResultadoDto result = procedureAdapter.abrirCuenta(requestDto, createdBy);
		if (result.getCodigoResultado() != null && result.getCodigoResultado() != 0) {
			throw new BusinessRuleException(result.getMensajeResultado());
		}
		return CuentaAbrirResponseDto.builder()
			.idCuenta(result.getIdEntidad())
			.numeroCuenta(requestDto.getNumeroCuenta())
			.idTitularCliente(requestDto.getIdTitularCliente())
			.tipoCuentaCodigo(requestDto.getTipoCuentaCodigo())
			.monedaCodigo(requestDto.getMonedaCodigo())
			.estadoCuentaCodigo("ACTIVA")
			.saldoInicial(requestDto.getSaldoInicial())
			.traceId(result.getTraceId())
			.build();
	}
}