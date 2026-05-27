package app.services.cuenta;

import app.domain.entities.CatEstadoCuentaEntity;
import app.domain.entities.CatMonedaEntity;
import app.domain.entities.CatTipoCuentaEntity;
import app.dto.cuenta.CuentaConsultaPorUsuarioItemDto;
import app.dto.cuenta.CuentaConsultaPorUsuarioResponseDto;
import app.exceptions.BusinessRuleException;
import app.exceptions.ResourceNotFoundException;
import app.persistence.cuenta.CuentaStoredProcedureAdapter;
import app.persistence.cuenta.CuentaStoredProcedureAdapter.ResultSetWithTrace;
import app.repositories.CatEstadoCuentaRepository;
import app.repositories.CatMonedaRepository;
import app.repositories.CatTipoCuentaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CuentaConsultaPorUsuarioService {

	private final CuentaStoredProcedureAdapter procedureAdapter;
	private final CatTipoCuentaRepository catTipoCuentaRepository;
	private final CatEstadoCuentaRepository catEstadoCuentaRepository;
	private final CatMonedaRepository catMonedaRepository;

	public CuentaConsultaPorUsuarioResponseDto findByUsuarioId(Long idUsuario) {
		ResultSetWithTrace result = procedureAdapter.consultarPorUsuario(idUsuario);
		if (result.codigoResultado() != null && result.codigoResultado() != 0) {
			if (Integer.valueOf(1002).equals(result.codigoResultado())) {
				throw new ResourceNotFoundException(result.mensajeResultado());
			}
			throw new BusinessRuleException(result.mensajeResultado());
		}

		Map<Long, String> tipoCache = new HashMap<>();
		Map<Long, String> estadoCache = new HashMap<>();
		Map<Long, String> monedaCache = new HashMap<>();

		return CuentaConsultaPorUsuarioResponseDto.builder()
			.idUsuario(idUsuario)
			.traceId(result.traceId())
			.cuentas(result.cuentas().stream()
				.map(row -> CuentaConsultaPorUsuarioItemDto.builder()
					.idCuenta(row.getIdCuenta())
					.numeroCuenta(row.getNumeroCuenta())
					.saldoActual(row.getSaldoActual())
					.fechaApertura(row.getFechaApertura())
					.estadoCuentaCodigo(resolveCodigo(estadoCache, row.getEstadoCuentaId(), catEstadoCuentaRepository))
					.tipoCuentaCodigo(resolveCodigo(tipoCache, row.getTipoCuentaId(), catTipoCuentaRepository))
					.monedaCodigo(resolveCodigo(monedaCache, row.getMonedaId(), catMonedaRepository))
					.build())
				.toList())
			.build();
	}

	private static String resolveCodigo(Map<Long, String> cache, Long idCatalogo, org.springframework.data.jpa.repository.JpaRepository<?, Long> repository) {
		if (idCatalogo == null) {
			return null;
		}
		return cache.computeIfAbsent(idCatalogo, key -> {
			Object entity = repository.findById(key).orElse(null);
			if (entity == null) {
				return null;
			}
			if (entity instanceof CatTipoCuentaEntity catalogo) {
				return catalogo.getCodigo();
			}
			if (entity instanceof CatEstadoCuentaEntity catalogo) {
				return catalogo.getCodigo();
			}
			if (entity instanceof CatMonedaEntity catalogo) {
				return catalogo.getCodigo();
			}
			return null;
		});
	}
}