package app.controllers.transferencia;

import app.dto.ApiResponse;
import app.dto.transferencia.TransferenciaCrearRequestDto;
import app.dto.transferencia.TransferenciaDecisionRequestDto;
import app.dto.transferencia.TransferenciaHistorialResponseDto;
import app.dto.transferencia.TransferenciaOperacionResponseDto;
import app.security.BancoUserDetails;
import app.services.transferencia.TransferenciaService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/transferencias")
@RequiredArgsConstructor
public class TransferenciaController {

	private final TransferenciaService transferenciaService;

	@PostMapping
	public ResponseEntity<ApiResponse<TransferenciaOperacionResponseDto>> crear(@Valid @RequestBody TransferenciaCrearRequestDto requestDto, Authentication authentication) {
		BancoUserDetails currentUser = (BancoUserDetails) authentication.getPrincipal();
		TransferenciaOperacionResponseDto response = transferenciaService.crear(requestDto, currentUser);
		return ResponseEntity.status(HttpStatus.CREATED)
			.body(ApiResponse.success("Transferencia creada correctamente", response, "/api/transferencias"));
	}

	@PostMapping("/{idTransferencia}/aprobar")
	public ResponseEntity<ApiResponse<TransferenciaOperacionResponseDto>> aprobar(
		@PathVariable Long idTransferencia,
		@Valid @RequestBody TransferenciaDecisionRequestDto requestDto,
		Authentication authentication
	) {
		BancoUserDetails currentUser = (BancoUserDetails) authentication.getPrincipal();
		TransferenciaOperacionResponseDto response = transferenciaService.aprobar(idTransferencia, requestDto, currentUser);
		return ResponseEntity.ok(ApiResponse.success("Transferencia aprobada correctamente", response, "/api/transferencias/" + idTransferencia + "/aprobar"));
	}

	@PostMapping("/{idTransferencia}/rechazar")
	public ResponseEntity<ApiResponse<TransferenciaOperacionResponseDto>> rechazar(
		@PathVariable Long idTransferencia,
		@Valid @RequestBody TransferenciaDecisionRequestDto requestDto,
		Authentication authentication
	) {
		BancoUserDetails currentUser = (BancoUserDetails) authentication.getPrincipal();
		TransferenciaOperacionResponseDto response = transferenciaService.rechazar(idTransferencia, requestDto, currentUser);
		return ResponseEntity.ok(ApiResponse.success("Transferencia rechazada correctamente", response, "/api/transferencias/" + idTransferencia + "/rechazar"));
	}

	@PostMapping("/{idTransferencia}/ejecutar")
	public ResponseEntity<ApiResponse<TransferenciaOperacionResponseDto>> ejecutar(@PathVariable Long idTransferencia, Authentication authentication) {
		BancoUserDetails currentUser = (BancoUserDetails) authentication.getPrincipal();
		TransferenciaOperacionResponseDto response = transferenciaService.ejecutar(idTransferencia, currentUser);
		return ResponseEntity.ok(ApiResponse.success("Transferencia ejecutada correctamente", response, "/api/transferencias/" + idTransferencia + "/ejecutar"));
	}

	@GetMapping("/usuarios/{idUsuario}")
	public ResponseEntity<ApiResponse<TransferenciaHistorialResponseDto>> consultarHistorial(@PathVariable Long idUsuario, Authentication authentication) {
		BancoUserDetails currentUser = (BancoUserDetails) authentication.getPrincipal();
		boolean isAdmin = currentUser.getAuthorities().stream().anyMatch(authority -> "ROLE_ADMIN_BD".equals(authority.getAuthority()));
		if (!isAdmin && !currentUser.getIdUsuario().equals(idUsuario)) {
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ApiResponse.error("No puede consultar transferencias de otro usuario", "/api/transferencias/usuarios/" + idUsuario));
		}
		TransferenciaHistorialResponseDto response = transferenciaService.consultarHistorialPorUsuario(idUsuario);
		return ResponseEntity.ok(ApiResponse.success("Historial de transferencias consultado correctamente", response, "/api/transferencias/usuarios/" + idUsuario));
	}
}