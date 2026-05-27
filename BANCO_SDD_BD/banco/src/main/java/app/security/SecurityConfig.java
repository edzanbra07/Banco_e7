package app.security;

import app.dto.ApiResponse;
import app.security.jwt.JwtAuthenticationFilter;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	private static DaoAuthenticationProvider authenticationProvider(UserDetailsService userDetailsService, PasswordEncoder passwordEncoder) {
		DaoAuthenticationProvider provider = new DaoAuthenticationProvider(userDetailsService);
		provider.setPasswordEncoder(passwordEncoder);
		return provider;
	}

	@Bean
	public AuthenticationManager authenticationManager(UserDetailsService userDetailsService, PasswordEncoder passwordEncoder) {
		return new org.springframework.security.authentication.ProviderManager(authenticationProvider(userDetailsService, passwordEncoder));
	}

	@Bean
	public SecurityFilterChain securityFilterChain(HttpSecurity http, JwtAuthenticationFilter jwtAuthenticationFilter) throws Exception {
		http
			.csrf(csrf -> csrf.disable())
			.cors(Customizer.withDefaults())
			.exceptionHandling(exceptionHandling -> exceptionHandling
				.authenticationEntryPoint(authenticationEntryPoint())
				.accessDeniedHandler(accessDeniedHandler())
			)
			.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
			.authorizeHttpRequests(auth -> auth
				.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
				.requestMatchers("/api/auth/**", "/auth/**", "/swagger-ui/**", "/swagger-ui.html", "/v3/api-docs/**").permitAll()
				.requestMatchers("/api/clientes/personas", "/api/clientes/empresas").hasAnyRole("EMPLEADO_COMERCIAL", "ADMIN_BD")
				.requestMatchers("/api/clientes/usuarios/**").authenticated()
				.requestMatchers(HttpMethod.POST, "/api/cuentas").hasAnyRole("EMPLEADO_VENTANILLA", "ADMIN_BD")
				.requestMatchers(HttpMethod.PATCH, "/api/cuentas/*/estado").hasAnyRole("EMPLEADO_VENTANILLA", "ADMIN_BD")
				.requestMatchers(HttpMethod.GET, "/api/cuentas/usuarios/**").authenticated()
				.requestMatchers(HttpMethod.POST, "/api/transferencias").hasAnyRole("CLIENTE_PERSONA", "CLIENTE_EMPRESA", "ADMIN_BD")
				.requestMatchers(HttpMethod.POST, "/api/transferencias/*/aprobar").hasAnyRole("SUPERVISOR_EMPRESA", "ADMIN_BD")
				.requestMatchers(HttpMethod.POST, "/api/transferencias/*/rechazar").hasAnyRole("SUPERVISOR_EMPRESA", "ADMIN_BD")
				.requestMatchers(HttpMethod.POST, "/api/transferencias/*/ejecutar").hasAnyRole("SUPERVISOR_EMPRESA", "ADMIN_BD")
				.requestMatchers(HttpMethod.GET, "/api/transferencias/usuarios/**").authenticated()
				.requestMatchers("/api/catalogos/**").hasRole("ADMIN_BD")
				.anyRequest().authenticated()
			)
			.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
		return http.build();
	}

	@Bean
	public AuthenticationEntryPoint authenticationEntryPoint() {
		return (request, response, authException) -> writeErrorResponse(response, HttpServletResponse.SC_UNAUTHORIZED, "No autenticado", request.getRequestURI());
	}

	@Bean
	public AccessDeniedHandler accessDeniedHandler() {
		return (request, response, accessDeniedException) -> writeErrorResponse(response, HttpServletResponse.SC_FORBIDDEN, "Acceso denegado", request.getRequestURI());
	}

	private static void writeErrorResponse(HttpServletResponse response, int status, String message, String path) throws IOException {
		response.setStatus(status);
		response.setContentType(MediaType.APPLICATION_JSON_VALUE);
		response.setCharacterEncoding("UTF-8");
		new ObjectMapper().writeValue(response.getWriter(), ApiResponse.error(message, path));
	}
}