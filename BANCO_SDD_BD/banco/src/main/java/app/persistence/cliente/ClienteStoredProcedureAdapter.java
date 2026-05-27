package app.persistence.cliente;

import app.dto.cliente.ClienteConsultaPorUsuarioResponseDto;
import app.dto.cliente.ClienteEmpresaCrearRequestDto;
import app.dto.cliente.ClientePersonaCrearRequestDto;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.StoredProcedureQuery;
import java.util.List;
import org.springframework.stereotype.Repository;

@Repository
public class ClienteStoredProcedureAdapter {

	@PersistenceContext
	private EntityManager entityManager;

	public Long crearClientePersona(ClientePersonaCrearRequestDto requestDto) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_cliente_persona_crear");
		query.registerStoredProcedureParameter("p_id_identificacion", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_nombre_completo", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_correo_electronico", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_telefono", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_direccion", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_nombres", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_apellidos", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_fecha_nacimiento", java.sql.Date.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_created_by", Long.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("o_codigo_resultado", Integer.class, jakarta.persistence.ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_mensaje_resultado", String.class, jakarta.persistence.ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_id_entidad", Long.class, jakarta.persistence.ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_trace_id", String.class, jakarta.persistence.ParameterMode.OUT);
		query.setParameter("p_id_identificacion", requestDto.getIdIdentificacion());
		query.setParameter("p_nombre_completo", requestDto.getNombreCompleto());
		query.setParameter("p_correo_electronico", requestDto.getCorreoElectronico());
		query.setParameter("p_telefono", requestDto.getTelefono());
		query.setParameter("p_direccion", requestDto.getDireccion());
		query.setParameter("p_nombres", requestDto.getNombres());
		query.setParameter("p_apellidos", requestDto.getApellidos());
		query.setParameter("p_fecha_nacimiento", java.sql.Date.valueOf(requestDto.getFechaNacimiento()));
		query.setParameter("p_created_by", requestDto.getCreatedBy());
		query.execute();
		return (Long) query.getOutputParameterValue("o_id_entidad");
	}

	public Long crearClienteEmpresa(ClienteEmpresaCrearRequestDto requestDto) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_cliente_empresa_crear");
		query.registerStoredProcedureParameter("p_id_identificacion", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_nombre_completo", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_correo_electronico", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_telefono", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_direccion", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_razon_social", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_nit", String.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_id_representante_legal", Long.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("p_created_by", Long.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("o_codigo_resultado", Integer.class, jakarta.persistence.ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_mensaje_resultado", String.class, jakarta.persistence.ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_id_entidad", Long.class, jakarta.persistence.ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_trace_id", String.class, jakarta.persistence.ParameterMode.OUT);
		query.setParameter("p_id_identificacion", requestDto.getIdIdentificacion());
		query.setParameter("p_nombre_completo", requestDto.getNombreCompleto());
		query.setParameter("p_correo_electronico", requestDto.getCorreoElectronico());
		query.setParameter("p_telefono", requestDto.getTelefono());
		query.setParameter("p_direccion", requestDto.getDireccion());
		query.setParameter("p_razon_social", requestDto.getRazonSocial());
		query.setParameter("p_nit", requestDto.getNit());
		query.setParameter("p_id_representante_legal", requestDto.getIdRepresentanteLegal());
		query.setParameter("p_created_by", requestDto.getCreatedBy());
		query.execute();
		return (Long) query.getOutputParameterValue("o_id_entidad");
	}

	@SuppressWarnings("unchecked")
	public ClienteConsultaPorUsuarioResponseDto consultarPorUsuario(Long idUsuario) {
		StoredProcedureQuery query = entityManager.createStoredProcedureQuery("sp_cliente_consultar_por_usuario");
		query.registerStoredProcedureParameter("p_id_usuario", Long.class, jakarta.persistence.ParameterMode.IN);
		query.registerStoredProcedureParameter("o_codigo_resultado", Integer.class, jakarta.persistence.ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_mensaje_resultado", String.class, jakarta.persistence.ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_id_entidad", Long.class, jakarta.persistence.ParameterMode.OUT);
		query.registerStoredProcedureParameter("o_trace_id", String.class, jakarta.persistence.ParameterMode.OUT);
		query.setParameter("p_id_usuario", idUsuario);
		query.execute();
		List<Object[]> rows = query.getResultList();
		if (rows.isEmpty()) {
			return null;
		}
		Object[] row = rows.get(0);
		return ClienteConsultaPorUsuarioResponseDto.builder()
			.idCliente(asLong(row[0]))
			.idIdentificacion(asString(row[1]))
			.nombreCompleto(asString(row[2]))
			.correoElectronico(asString(row[3]))
			.telefono(asString(row[4]))
			.direccion(asString(row[5]))
			.tipoClienteCodigo(asString(row[6]))
			.estadoClienteCodigo(asString(row[7]))
			.nombres(asString(row[8]))
			.apellidos(asString(row[9]))
			.fechaNacimiento(row[10] != null ? ((java.sql.Date) row[10]).toLocalDate() : null)
			.razonSocial(asString(row[11]))
			.nit(asString(row[12]))
			.idRepresentanteLegal(asLong(row[13]))
			.build();
	}

	private static Long asLong(Object value) {
		if (value == null) {
			return null;
		}
		if (value instanceof Number number) {
			return number.longValue();
		}
		return Long.valueOf(value.toString());
	}

	private static String asString(Object value) {
		return value == null ? null : value.toString();
	}
}