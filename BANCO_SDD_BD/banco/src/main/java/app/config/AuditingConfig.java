package app.config;

import java.util.Optional;

import app.security.BancoUserDetails;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorAware")
public class AuditingConfig {

	@Bean
	public AuditorAware<Long> auditorAware() {
		return () -> Optional.ofNullable(SecurityContextHolder.getContext().getAuthentication())
			.map(Authentication::getPrincipal)
			.flatMap(AuditingConfig::extractAuditorId);
	}

	private static Optional<Long> extractAuditorId(Object principal) {
		if (principal instanceof BancoUserDetails userDetails) {
			return Optional.ofNullable(userDetails.getIdUsuario());
		}
		if (principal instanceof Long value) {
			return Optional.of(value);
		}
		if (principal instanceof String value) {
			try {
				return Optional.of(Long.parseLong(value));
			} catch (NumberFormatException ignored) {
				return Optional.empty();
			}
		}
		return Optional.empty();
	}
}