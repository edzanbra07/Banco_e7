package app.security;

import app.dto.ApiResponse;
import app.security.BancoUserDetails;
import app.security.dto.AuthRequestDto;
import app.security.dto.AuthResponseDto;
import app.security.jwt.JwtService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping({"/api/auth", "/auth"})
@RequiredArgsConstructor
public class AuthController {

	private final AuthenticationManager authenticationManager;
	private final JwtService jwtService;

	@PostMapping("/login")
	public ResponseEntity<ApiResponse<AuthResponseDto>> login(@Valid @RequestBody AuthRequestDto requestDto, HttpServletRequest request) {
		Authentication authentication = authenticationManager.authenticate(
			new UsernamePasswordAuthenticationToken(requestDto.getUsername(), requestDto.getPassword())
		);
		BancoUserDetails userDetails = (BancoUserDetails) authentication.getPrincipal();
		String token = jwtService.generateToken(userDetails);
		AuthResponseDto response = AuthResponseDto.builder()
			.token(token)
			.tokenType("Bearer")
			.username(userDetails.getUsername())
			.roles(userDetails.getAuthorities().stream().map(Object::toString).toArray(String[]::new))
			.build();
		return ResponseEntity.ok(ApiResponse.success("Autenticacion exitosa", response, request.getRequestURI()));
	}
}