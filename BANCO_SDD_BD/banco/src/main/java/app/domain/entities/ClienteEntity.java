package app.domain.entities;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "cliente")
@EqualsAndHashCode(callSuper = true)
public class ClienteEntity extends BaseEntity {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id_cliente")
	private Long idCliente;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "tipo_cliente_id", nullable = false)
	private CatTipoClienteEntity tipoCliente;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "estado_cliente_id", nullable = false)
	private CatEstadoClienteEntity estadoCliente;

	@Column(name = "id_identificacion", nullable = false, length = 50, unique = true)
	private String idIdentificacion;

	@Column(name = "nombre_completo", nullable = false, length = 200)
	private String nombreCompleto;

	@Column(name = "correo_electronico", nullable = false, length = 255)
	private String correoElectronico;

	@Column(name = "telefono", nullable = false, length = 20)
	private String telefono;

	@Column(name = "direccion", nullable = false, length = 255)
	private String direccion;

	@ToString.Exclude
	@EqualsAndHashCode.Exclude
	@OneToOne(mappedBy = "cliente", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
	private ClientePersonaEntity persona;

	@ToString.Exclude
	@EqualsAndHashCode.Exclude
	@OneToOne(mappedBy = "cliente", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
	private ClienteEmpresaEntity empresa;
}