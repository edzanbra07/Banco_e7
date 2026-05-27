package app.dto.transferencia;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransferenciaHistorialResponseDto {

	private Long idUsuario;
	private String traceId;
	private List<TransferenciaHistorialItemDto> transferencias;
}