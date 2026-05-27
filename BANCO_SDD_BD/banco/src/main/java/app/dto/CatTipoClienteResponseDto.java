package app.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CatTipoClienteResponseDto {

	private Long idCatalogo;
	private String codigo;
	private String nombre;
	private String descripcion;
	private Boolean activo;
	private Integer orden;
	private LocalDateTime createdAt;
	private LocalDateTime updatedAt;
	private Long createdBy;
	private Long updatedBy;
}