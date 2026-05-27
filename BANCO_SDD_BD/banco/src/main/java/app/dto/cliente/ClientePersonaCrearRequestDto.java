package app.dto.cliente;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClientePersonaCrearRequestDto {

	@NotBlank
	@Size(max = 50)
	private String idIdentificacion;

	@NotBlank
	@Size(max = 200)
	private String nombreCompleto;

	@NotBlank
	@Email
	@Size(max = 255)
	private String correoElectronico;

	@NotBlank
	@Size(max = 20)
	private String telefono;

	@NotBlank
	@Size(max = 255)
	private String direccion;

	@NotBlank
	@Size(max = 120)
	private String nombres;

	@NotBlank
	@Size(max = 120)
	private String apellidos;

	@NotNull
	@Past
	private LocalDate fechaNacimiento;

	@NotNull
	private Long createdBy;
}