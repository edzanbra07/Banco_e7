package app.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

	private static final String JWT_SCHEME = "bearer-jwt";

	@Bean
	public OpenAPI bancoOpenAPI() {
		return new OpenAPI()
			.addServersItem(new Server().url("http://localhost:8083").description("Banco local"))
			.components(new Components()
				.addSecuritySchemes(JWT_SCHEME, new SecurityScheme()
					.type(SecurityScheme.Type.HTTP)
					.scheme("bearer")
					.bearerFormat("JWT")))
			.addSecurityItem(new SecurityRequirement().addList(JWT_SCHEME))
			.info(new Info()
				.title("Banco API")
				.version("1.0.0")
				.description("API bancaria basada en JPA y procedimientos almacenados")
				.license(new License().name("Internal use only")));
	}
}