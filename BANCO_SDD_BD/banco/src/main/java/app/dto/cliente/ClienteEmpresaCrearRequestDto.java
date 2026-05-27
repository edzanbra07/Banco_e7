package app.dto.cliente;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClienteEmpresaCrearRequestDto {

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
	@Size(max = 200)
	private String razonSocial;

	@NotBlank
	@Size(max = 30)
	private String nit;

	@NotNull
	private Long idRepresentanteLegal;

	@NotNull
	private Long createdBy;
}