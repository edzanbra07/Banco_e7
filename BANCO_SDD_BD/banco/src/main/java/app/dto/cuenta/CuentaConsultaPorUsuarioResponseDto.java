package app.dto.cuenta;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CuentaConsultaPorUsuarioResponseDto {

	private Long idUsuario;
	private String traceId;
	private List<CuentaConsultaPorUsuarioItemDto> cuentas;
}