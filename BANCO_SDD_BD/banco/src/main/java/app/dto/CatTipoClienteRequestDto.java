package app.dto;

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
public class CatTipoClienteRequestDto {

	@NotBlank
	@Size(max = 80)
	private String codigo;

	@NotBlank
	@Size(max = 150)
	private String nombre;

	@Size(max = 255)
	private String descripcion;

	@NotNull
	private Boolean activo;

	private Integer orden;
}