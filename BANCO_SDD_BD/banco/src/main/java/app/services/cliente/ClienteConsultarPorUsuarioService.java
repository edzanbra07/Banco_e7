package app.services.cliente;

import app.dto.cliente.ClienteConsultaPorUsuarioResponseDto;
import app.exceptions.ResourceNotFoundException;
import app.mapper.ClienteMapper;
import app.persistence.cliente.ClienteStoredProcedureAdapter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClienteConsultarPorUsuarioService {

	private final ClienteStoredProcedureAdapter procedureAdapter;
	private final ClienteMapper clienteMapper;

	public ClienteConsultaPorUsuarioResponseDto findByUsuarioId(Long idUsuario) {
		ClienteConsultaPorUsuarioResponseDto response = procedureAdapter.consultarPorUsuario(idUsuario);
		if (response == null) {
			throw new ResourceNotFoundException("No existe cliente asociado al usuario: " + idUsuario);
		}
		return clienteMapper.toConsultaPorUsuarioResponse(response);
	}
}