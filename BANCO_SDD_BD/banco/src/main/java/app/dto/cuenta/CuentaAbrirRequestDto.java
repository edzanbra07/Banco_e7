package app.dto.cuenta;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CuentaAbrirRequestDto {

	@NotNull
	private Long idTitularCliente;

	@NotBlank
	private String numeroCuenta;

	@NotBlank
	private String tipoCuentaCodigo;

	@NotBlank
	private String monedaCodigo;

	@NotNull
	@DecimalMin(value = "0.00")
	private BigDecimal saldoInicial;
}