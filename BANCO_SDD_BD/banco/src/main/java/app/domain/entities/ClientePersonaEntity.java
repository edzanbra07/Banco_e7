package app.domain.entities;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
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
@Table(name = "cliente_persona")
@EqualsAndHashCode(callSuper = true)
public class ClientePersonaEntity extends BaseEntity {

	@Id
	@Column(name = "id_cliente")
	private Long idCliente;

	@MapsId
	@ToString.Exclude
	@EqualsAndHashCode.Exclude
	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "id_cliente", nullable = false)
	private ClienteEntity cliente;

	@Column(name = "nombres", nullable = false, length = 120)
	private String nombres;

	@Column(name = "apellidos", nullable = false, length = 120)
	private String apellidos;

	@Column(name = "fecha_nacimiento", nullable = false)
	private LocalDate fechaNacimiento;
}