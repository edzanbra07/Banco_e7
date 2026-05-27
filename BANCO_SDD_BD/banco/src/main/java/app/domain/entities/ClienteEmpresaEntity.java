package app.domain.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
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
@Table(name = "cliente_empresa")
@EqualsAndHashCode(callSuper = true)
public class ClienteEmpresaEntity extends BaseEntity {

	@Id
	@Column(name = "id_cliente")
	private Long idCliente;

	@MapsId
	@ToString.Exclude
	@EqualsAndHashCode.Exclude
	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "id_cliente", nullable = false)
	private ClienteEntity cliente;

	@Column(name = "razon_social", nullable = false, length = 200)
	private String razonSocial;

	@Column(name = "nit", nullable = false, length = 30, unique = true)
	private String nit;

	@ToString.Exclude
	@EqualsAndHashCode.Exclude
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "id_representante_legal", referencedColumnName = "id_cliente", nullable = false)
	private ClientePersonaEntity representanteLegal;
}