package app.dto.cuenta;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CuentaCambioEstadoResponseDto {

	private Long idCuenta;
	private String estadoCuentaCodigo;
	private String traceId;
}