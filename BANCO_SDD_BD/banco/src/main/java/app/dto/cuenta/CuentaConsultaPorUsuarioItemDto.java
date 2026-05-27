package app.dto.cuenta;

import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CuentaConsultaPorUsuarioItemDto {

	private Long idCuenta;
	private String numeroCuenta;
	private BigDecimal saldoActual;
	private LocalDate fechaApertura;
	private String estadoCuentaCodigo;
	private String tipoCuentaCodigo;
	private String monedaCodigo;
}