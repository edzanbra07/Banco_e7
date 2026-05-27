package app.domain.entities;

import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@MappedSuperclass
@EqualsAndHashCode(callSuper = true)
public abstract class CatalogoBaseEntity extends BaseEntity {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id_catalogo")
	private Long idCatalogo;

	@Column(name = "codigo", nullable = false, length = 80)
	private String codigo;

	@Column(name = "nombre", nullable = false, length = 150)
	private String nombre;

	@Column(name = "descripcion", length = 255)
	private String descripcion;

	@Column(name = "activo", nullable = false)
	private Boolean activo;

	@Column(name = "orden")
	private Integer orden;
}