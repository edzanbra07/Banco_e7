package app.config;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
public class WebCorsConfig {

	@Bean
	public CorsConfigurationSource corsConfigurationSource(
		@Value("${app.web.cors.allowed-origins:http://localhost:3000,http://localhost:5173}") String allowedOrigins,
		@Value("${app.web.cors.allowed-methods:GET,POST,PUT,PATCH,DELETE,OPTIONS}") String allowedMethods,
		@Value("${app.web.cors.allowed-headers:Authorization,Content-Type,Accept,Origin,X-Requested-With}") String allowedHeaders
	) {
		CorsConfiguration configuration = new CorsConfiguration();
		configuration.setAllowedOrigins(splitAndTrim(allowedOrigins));
		configuration.setAllowedMethods(splitAndTrim(allowedMethods));
		configuration.setAllowedHeaders(splitAndTrim(allowedHeaders));
		configuration.setAllowCredentials(true);
		configuration.setMaxAge(3600L);

		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);
		return source;
	}

	private static List<String> splitAndTrim(String value) {
		return List.of(value.split(","))
			.stream()
			.map(String::trim)
			.filter(item -> !item.isBlank())
			.toList();
	}
}