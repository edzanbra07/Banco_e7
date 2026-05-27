package app.dto.cliente;

import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClienteConsultaPorUsuarioResponseDto {

	private Long idCliente;
	private String idIdentificacion;
	private String nombreCompleto;
	private String correoElectronico;
	private String telefono;
	private String direccion;
	private String tipoClienteCodigo;
	private String estadoClienteCodigo;
	private String nombres;
	private String apellidos;
	private LocalDate fechaNacimiento;
	private String razonSocial;
	private String nit;
	private Long idRepresentanteLegal;
}