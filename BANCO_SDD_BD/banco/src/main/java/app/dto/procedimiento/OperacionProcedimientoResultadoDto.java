package app.dto.procedimiento;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OperacionProcedimientoResultadoDto {

	private Integer codigoResultado;
	private String mensajeResultado;
	private Long idEntidad;
	private String traceId;
}