package app.services.cliente;

import app.domain.entities.ClienteEntity;
import app.dto.cliente.ClientePersonaCrearRequestDto;
import app.dto.cliente.ClientePersonaCrearResponseDto;
import app.exceptions.BusinessRuleException;
import app.exceptions.ResourceNotFoundException;
import app.mapper.ClienteMapper;
import app.persistence.cliente.ClienteStoredProcedureAdapter;
import app.repositories.ClienteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClientePersonaCrearService {

	private final ClienteStoredProcedureAdapter procedureAdapter;
	private final ClienteRepository clienteRepository;
	private final ClienteMapper clienteMapper;

	@Transactional
	public ClientePersonaCrearResponseDto create(ClientePersonaCrearRequestDto requestDto) {
		if (clienteRepository.existsByIdIdentificacion(requestDto.getIdIdentificacion())) {
			throw new BusinessRuleException("Ya existe un cliente con identificacion: " + requestDto.getIdIdentificacion());
		}
		Long idCliente = procedureAdapter.crearClientePersona(requestDto);
		ClienteEntity cliente = clienteRepository.findById(idCliente)
			.orElseThrow(() -> new ResourceNotFoundException("No se pudo cargar el cliente creado: " + idCliente));
		return clienteMapper.toPersonaResponse(cliente);
	}
}