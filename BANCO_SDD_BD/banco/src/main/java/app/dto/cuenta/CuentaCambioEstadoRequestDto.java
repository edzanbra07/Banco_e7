package app.dto.cuenta;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CuentaCambioEstadoRequestDto {

	@NotNull
	private Long idCuenta;

	@NotBlank
	private String estadoCuentaCodigo;
}