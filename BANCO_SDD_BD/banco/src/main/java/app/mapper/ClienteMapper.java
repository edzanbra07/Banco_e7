package app.mapper;

import app.domain.entities.ClienteEntity;
import app.dto.cliente.ClienteConsultaPorUsuarioResponseDto;
import app.dto.cliente.ClienteEmpresaCrearResponseDto;
import app.dto.cliente.ClientePersonaCrearResponseDto;
import org.springframework.stereotype.Component;

@Component
public class ClienteMapper {

	public ClientePersonaCrearResponseDto toPersonaResponse(ClienteEntity cliente) {
		return ClientePersonaCrearResponseDto.builder()
			.idCliente(cliente.getIdCliente())
			.idIdentificacion(cliente.getIdIdentificacion())
			.nombreCompleto(cliente.getNombreCompleto())
			.correoElectronico(cliente.getCorreoElectronico())
			.telefono(cliente.getTelefono())
			.direccion(cliente.getDireccion())
			.nombres(cliente.getPersona() != null ? cliente.getPersona().getNombres() : null)
			.apellidos(cliente.getPersona() != null ? cliente.getPersona().getApellidos() : null)
			.fechaNacimiento(cliente.getPersona() != null ? cliente.getPersona().getFechaNacimiento() : null)
			.tipoClienteCodigo(cliente.getTipoCliente() != null ? cliente.getTipoCliente().getCodigo() : null)
			.estadoClienteCodigo(cliente.getEstadoCliente() != null ? cliente.getEstadoCliente().getCodigo() : null)
			.createdAt(cliente.getCreatedAt())
			.updatedAt(cliente.getUpdatedAt())
			.build();
	}

	public ClienteEmpresaCrearResponseDto toEmpresaResponse(ClienteEntity cliente) {
		return ClienteEmpresaCrearResponseDto.builder()
			.idCliente(cliente.getIdCliente())
			.idIdentificacion(cliente.getIdIdentificacion())
			.nombreCompleto(cliente.getNombreCompleto())
			.correoElectronico(cliente.getCorreoElectronico())
			.telefono(cliente.getTelefono())
			.direccion(cliente.getDireccion())
			.razonSocial(cliente.getEmpresa() != null ? cliente.getEmpresa().getRazonSocial() : null)
			.nit(cliente.getEmpresa() != null ? cliente.getEmpresa().getNit() : null)
			.idRepresentanteLegal(cliente.getEmpresa() != null && cliente.getEmpresa().getRepresentanteLegal() != null ? cliente.getEmpresa().getRepresentanteLegal().getIdCliente() : null)
			.tipoClienteCodigo(cliente.getTipoCliente() != null ? cliente.getTipoCliente().getCodigo() : null)
			.estadoClienteCodigo(cliente.getEstadoCliente() != null ? cliente.getEstadoCliente().getCodigo() : null)
			.createdAt(cliente.getCreatedAt())
			.updatedAt(cliente.getUpdatedAt())
			.build();
	}

	public ClienteConsultaPorUsuarioResponseDto toConsultaPorUsuarioResponse(ClienteConsultaPorUsuarioResponseDto dto) {
		return dto;
	}
}