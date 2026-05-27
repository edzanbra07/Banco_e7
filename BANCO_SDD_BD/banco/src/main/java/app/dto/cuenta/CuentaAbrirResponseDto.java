package app.dto.cuenta;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CuentaAbrirResponseDto {

	private Long idCuenta;
	private String numeroCuenta;
	private Long idTitularCliente;
	private String tipoCuentaCodigo;
	private String monedaCodigo;
	private String estadoCuentaCodigo;
	private BigDecimal saldoInicial;
	private String traceId;
}