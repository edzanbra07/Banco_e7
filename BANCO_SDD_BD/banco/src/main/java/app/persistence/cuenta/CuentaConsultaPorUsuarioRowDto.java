package app.persistence.cuenta;

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
public class CuentaConsultaPorUsuarioRowDto {

	private Long idCuenta;
	private String numeroCuenta;
	private BigDecimal saldoActual;
	private LocalDate fechaApertura;
	private Long estadoCuentaId;
	private Long tipoCuentaId;
	private Long monedaId;
}