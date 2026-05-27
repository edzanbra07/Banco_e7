package app.dto.cliente;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClienteEmpresaCrearResponseDto {

	private Long idCliente;
	private String idIdentificacion;
	private String nombreCompleto;
	private String correoElectronico;
	private String telefono;
	private String direccion;
	private String razonSocial;
	private String nit;
	private Long idRepresentanteLegal;
	private String tipoClienteCodigo;
	private String estadoClienteCodigo;
	private LocalDateTime createdAt;
	private LocalDateTime updatedAt;
}