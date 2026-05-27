package app.services.transferencia;

import app.dto.procedimiento.OperacionProcedimientoResultadoDto;
import app.dto.transferencia.TransferenciaCrearRequestDto;
import app.dto.transferencia.TransferenciaDecisionRequestDto;
import app.dto.transferencia.TransferenciaHistorialItemDto;
import app.dto.transferencia.TransferenciaHistorialResponseDto;
import app.dto.transferencia.TransferenciaOperacionResponseDto;
import app.exceptions.BusinessRuleException;
import app.exceptions.ResourceNotFoundException;
import app.persistence.cuenta.CuentaStoredProcedureAdapter;
import app.persistence.transferencia.TransferenciaStoredProcedureAdapter;
import app.persistence.transferencia.TransferenciaStoredProcedureAdapter.ResultSetWithTrace;
import app.repositories.CatEstadoTransferenciaRepository;
import app.security.BancoUserDetails;
import java.util.HashMap;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TransferenciaService {

	private final TransferenciaStoredProcedureAdapter transferAdapter;
	private final CuentaStoredProcedureAdapter cuentaAdapter;
	private final CatEstadoTransferenciaRepository catEstadoTransferenciaRepository;

	@Transactional
	public TransferenciaOperacionResponseDto crear(TransferenciaCrearRequestDto requestDto, BancoUserDetails currentUser) {
		assertCuentaOrigenPerteneceAlUsuario(currentUser, requestDto.getCuentaOrigenId());
		OperacionProcedimientoResultadoDto result = transferAdapter.crear(requestDto, currentUser.getIdUsuario());
		if (result.getCodigoResultado() != null && result.getCodigoResultado() != 0) {
			throw new BusinessRuleException(result.getMensajeResultado());
		}
		return TransferenciaOperacionResponseDto.builder()
			.idTransferencia(result.getIdEntidad())
			.traceId(result.getTraceId())
			.build();
	}

	@Transactional
	public TransferenciaOperacionResponseDto aprobar(Long idTransferencia, TransferenciaDecisionRequestDto requestDto, BancoUserDetails currentUser) {
		OperacionProcedimientoResultadoDto result = transferAdapter.aprobar(idTransferencia, requestDto.getObservacion(), currentUser.getIdUsuario());
		if (result.getCodigoResultado() != null && result.getCodigoResultado() != 0) {
			throw new BusinessRuleException(result.getMensajeResultado());
		}
		return TransferenciaOperacionResponseDto.builder().idTransferencia(result.getIdEntidad()).traceId(result.getTraceId()).build();
	}

	@Transactional
	public TransferenciaOperacionResponseDto rechazar(Long idTransferencia, TransferenciaDecisionRequestDto requestDto, BancoUserDetails currentUser) {
		OperacionProcedimientoResultadoDto result = transferAdapter.rechazar(idTransferencia, requestDto.getObservacion(), currentUser.getIdUsuario());
		if (result.getCodigoResultado() != null && result.getCodigoResultado() != 0) {
			throw new BusinessRuleException(result.getMensajeResultado());
		}
		return TransferenciaOperacionResponseDto.builder().idTransferencia(result.getIdEntidad()).traceId(result.getTraceId()).build();
	}

	@Transactional
	public TransferenciaOperacionResponseDto ejecutar(Long idTransferencia, BancoUserDetails currentUser) {
		OperacionProcedimientoResultadoDto result = transferAdapter.ejecutar(idTransferencia, currentUser.getIdUsuario());
		if (result.getCodigoResultado() != null && result.getCodigoResultado() != 0) {
			throw new BusinessRuleException(result.getMensajeResultado());
		}
		return TransferenciaOperacionResponseDto.builder().idTransferencia(result.getIdEntidad()).traceId(result.getTraceId()).build();
	}

	public TransferenciaHistorialResponseDto consultarHistorialPorUsuario(Long idUsuario) {
		ResultSetWithTrace result = transferAdapter.consultarHistorialPorUsuario(idUsuario);
		if (result.codigoResultado() != null && result.codigoResultado() != 0) {
			if (Integer.valueOf(1002).equals(result.codigoResultado())) {
				throw new ResourceNotFoundException(result.mensajeResultado());
			}
			throw new BusinessRuleException(result.mensajeResultado());
		}
		Map<Long, String> estadoCache = new HashMap<>();
		return TransferenciaHistorialResponseDto.builder()
			.idUsuario(idUsuario)
			.traceId(result.traceId())
			.transferencias(result.transferencias().stream()
				.map(row -> TransferenciaHistorialItemDto.builder()
					.idTransferencia(row.getIdTransferencia())
					.cuentaOrigenId(row.getCuentaOrigenId())
					.cuentaDestinoId(row.getCuentaDestinoId())
					.monto(row.getMonto())
					.estadoTransferenciaCodigo(resolveEstadoCodigo(estadoCache, row.getEstadoTransferenciaId()))
					.fechaCreacion(row.getFechaCreacion())
					.fechaAprobacion(row.getFechaAprobacion())
					.fechaEjecucion(row.getFechaEjecucion())
					.fechaVencimiento(row.getFechaVencimiento())
					.idUsuarioCreador(row.getIdUsuarioCreador())
					.idUsuarioAprobador(row.getIdUsuarioAprobador())
					.observacion(row.getObservacion())
					.build())
				.toList())
			.build();
	}

	private void assertCuentaOrigenPerteneceAlUsuario(BancoUserDetails currentUser, Long cuentaOrigenId) {
		boolean isAdmin = currentUser.getAuthorities().stream().anyMatch(authority -> "ROLE_ADMIN_BD".equals(authority.getAuthority()));
		if (isAdmin) {
			return;
		}
		boolean pertenece = cuentaAdapter.consultarPorUsuario(currentUser.getIdUsuario()).cuentas().stream()
			.anyMatch(cuenta -> cuenta.getIdCuenta().equals(cuentaOrigenId));
		if (!pertenece) {
			throw new BusinessRuleException("La cuenta origen no pertenece al usuario autenticado");
		}
	}

	private String resolveEstadoCodigo(Map<Long, String> cache, Long idEstado) {
		if (idEstado == null) {
			return null;
		}
		return cache.computeIfAbsent(idEstado, key -> catEstadoTransferenciaRepository.findById(key).map(entity -> entity.getCodigo()).orElse(null));
	}
}