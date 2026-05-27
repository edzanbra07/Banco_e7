package app.controllers.cliente;

import app.dto.ApiResponse;
import app.dto.cliente.ClienteConsultaPorUsuarioResponseDto;
import app.dto.cliente.ClienteEmpresaCrearRequestDto;
import app.dto.cliente.ClienteEmpresaCrearResponseDto;
import app.dto.cliente.ClientePersonaCrearRequestDto;
import app.dto.cliente.ClientePersonaCrearResponseDto;
import app.exceptions.BusinessRuleException;
import app.security.BancoUserDetails;
import app.services.cliente.ClienteConsultarPorUsuarioService;
import app.services.cliente.ClienteEmpresaCrearService;
import app.services.cliente.ClientePersonaCrearService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/clientes")
@RequiredArgsConstructor
public class ClienteController {

	private final ClientePersonaCrearService clientePersonaCrearService;
	private final ClienteEmpresaCrearService clienteEmpresaCrearService;
	private final ClienteConsultarPorUsuarioService clienteConsultarPorUsuarioService;

	@PostMapping("/personas")
	public ResponseEntity<ApiResponse<ClientePersonaCrearResponseDto>> crearPersona(@Valid @RequestBody ClientePersonaCrearRequestDto requestDto) {
		ClientePersonaCrearResponseDto response = clientePersonaCrearService.create(requestDto);
		return ResponseEntity.status(HttpStatus.CREATED)
			.body(ApiResponse.success("Cliente persona creado correctamente", response, "/api/clientes/personas"));
	}

	@PostMapping("/empresas")
	public ResponseEntity<ApiResponse<ClienteEmpresaCrearResponseDto>> crearEmpresa(@Valid @RequestBody ClienteEmpresaCrearRequestDto requestDto) {
		ClienteEmpresaCrearResponseDto response = clienteEmpresaCrearService.create(requestDto);
		return ResponseEntity.status(HttpStatus.CREATED)
			.body(ApiResponse.success("Cliente empresa creado correctamente", response, "/api/clientes/empresas"));
	}

	@GetMapping("/usuarios/{idUsuario}")
	public ResponseEntity<ApiResponse<ClienteConsultaPorUsuarioResponseDto>> consultarPorUsuario(
		@PathVariable Long idUsuario,
		Authentication authentication
	) {
		BancoUserDetails currentUser = (BancoUserDetails) authentication.getPrincipal();
		boolean isAdmin = currentUser.getAuthorities().stream()
			.anyMatch(authority -> "ROLE_ADMIN_BD".equals(authority.getAuthority()));
		if (!isAdmin && !currentUser.getIdUsuario().equals(idUsuario)) {
			throw new BusinessRuleException("No puede consultar un usuario que no le pertenece");
		}
		ClienteConsultaPorUsuarioResponseDto response = clienteConsultarPorUsuarioService.findByUsuarioId(idUsuario);
		return ResponseEntity.ok(ApiResponse.success("Cliente consultado correctamente", response, "/api/clientes/usuarios/" + idUsuario));
	}
}