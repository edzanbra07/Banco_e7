package app.dto.cliente;

import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClientePersonaCrearResponseDto {

	private Long idCliente;
	private String idIdentificacion;
	private String nombreCompleto;
	private String correoElectronico;
	private String telefono;
	private String direccion;
	private String nombres;
	private String apellidos;
	private LocalDate fechaNacimiento;
	private String tipoClienteCodigo;
	private String estadoClienteCodigo;
	private LocalDateTime createdAt;
	private LocalDateTime updatedAt;
}