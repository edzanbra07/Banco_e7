package app.domain.entities;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
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
@Table(name = "usuario_sistema")
@EqualsAndHashCode(callSuper = true)
public class UsuarioSistemaEntity extends BaseEntity {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id_usuario")
	private Long idUsuario;

	@Column(name = "id_cliente")
	private Long idCliente;

	@Column(name = "id_empleado")
	private Long idEmpleado;

	@ToString.Exclude
	@EqualsAndHashCode.Exclude
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "rol_sistema_id", nullable = false)
	private CatRolSistemaEntity rolSistema;

	@ToString.Exclude
	@EqualsAndHashCode.Exclude
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "estado_usuario_id", nullable = false)
	private CatEstadoUsuarioEntity estadoUsuario;

	@Column(name = "nombre_completo", nullable = false, length = 200)
	private String nombreCompleto;

	@Column(name = "id_identificacion", nullable = false, length = 50, unique = true)
	private String idIdentificacion;

	@Column(name = "contrasena_hash", nullable = false, length = 255)
	private String contrasenaHash;

	@Column(name = "correo_electronico", nullable = false, length = 255)
	private String correoElectronico;

	@Column(name = "telefono", nullable = false, length = 20)
	private String telefono;

	@Column(name = "fecha_nacimiento")
	private LocalDate fechaNacimiento;

	@Column(name = "direccion", length = 255)
	private String direccion;
}