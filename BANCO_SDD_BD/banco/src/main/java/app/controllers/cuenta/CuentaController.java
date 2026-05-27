package app.controllers.cuenta;

import app.dto.ApiResponse;
import app.dto.cuenta.CuentaAbrirRequestDto;
import app.dto.cuenta.CuentaAbrirResponseDto;
import app.dto.cuenta.CuentaCambioEstadoRequestDto;
import app.dto.cuenta.CuentaCambioEstadoResponseDto;
import app.dto.cuenta.CuentaConsultaPorUsuarioResponseDto;
import app.exceptions.BusinessRuleException;
import app.security.BancoUserDetails;
import app.services.cuenta.CuentaAperturaService;
import app.services.cuenta.CuentaConsultaPorUsuarioService;
import app.services.cuenta.CuentaEstadoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/cuentas")
@RequiredArgsConstructor
public class CuentaController {

	private final CuentaAperturaService cuentaAperturaService;
	private final CuentaConsultaPorUsuarioService cuentaConsultaPorUsuarioService;
	private final CuentaEstadoService cuentaEstadoService;

	@PostMapping
	public ResponseEntity<ApiResponse<CuentaAbrirResponseDto>> abrir(@Valid @RequestBody CuentaAbrirRequestDto requestDto, Authentication authentication) {
		BancoUserDetails currentUser = (BancoUserDetails) authentication.getPrincipal();
		CuentaAbrirResponseDto response = cuentaAperturaService.abrir(requestDto, currentUser.getIdUsuario());
		return ResponseEntity.status(HttpStatus.CREATED)
			.body(ApiResponse.success("Cuenta abierta correctamente", response, "/api/cuentas"));
	}

	@GetMapping("/usuarios/{idUsuario}")
	public ResponseEntity<ApiResponse<CuentaConsultaPorUsuarioResponseDto>> consultarPorUsuario(@PathVariable Long idUsuario, Authentication authentication) {
		BancoUserDetails currentUser = (BancoUserDetails) authentication.getPrincipal();
		boolean isAdmin = currentUser.getAuthorities().stream().anyMatch(authority -> "ROLE_ADMIN_BD".equals(authority.getAuthority()));
		if (!isAdmin && !currentUser.getIdUsuario().equals(idUsuario)) {
			throw new BusinessRuleException("No puede consultar cuentas de otro usuario");
		}
		CuentaConsultaPorUsuarioResponseDto response = cuentaConsultaPorUsuarioService.findByUsuarioId(idUsuario);
		return ResponseEntity.ok(ApiResponse.success("Cuentas consultadas correctamente", response, "/api/cuentas/usuarios/" + idUsuario));
	}

	@PatchMapping("/{idCuenta}/estado")
	public ResponseEntity<ApiResponse<CuentaCambioEstadoResponseDto>> cambiarEstado(
		@PathVariable Long idCuenta,
		@Valid @RequestBody CuentaCambioEstadoRequestDto requestDto,
		Authentication authentication
	) {
		BancoUserDetails currentUser = (BancoUserDetails) authentication.getPrincipal();
		CuentaCambioEstadoRequestDto payload = CuentaCambioEstadoRequestDto.builder()
			.idCuenta(idCuenta)
			.estadoCuentaCodigo(requestDto.getEstadoCuentaCodigo())
			.build();
		CuentaCambioEstadoResponseDto response = cuentaEstadoService.cambiarEstado(payload, currentUser.getIdUsuario());
		return ResponseEntity.ok(ApiResponse.success("Estado de cuenta actualizado correctamente", response, "/api/cuentas/" + idCuenta + "/estado"));
	}
}