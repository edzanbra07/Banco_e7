package app.persistence.transferencia;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransferenciaHistorialRowDto {

	private Long idTransferencia;
	private Long cuentaOrigenId;
	private Long cuentaDestinoId;
	private BigDecimal monto;
	private Long estadoTransferenciaId;
	private LocalDateTime fechaCreacion;
	private LocalDateTime fechaAprobacion;
	private LocalDateTime fechaEjecucion;
	private LocalDateTime fechaVencimiento;
	private Long idUsuarioCreador;
	private Long idUsuarioAprobador;
	private String observacion;
}