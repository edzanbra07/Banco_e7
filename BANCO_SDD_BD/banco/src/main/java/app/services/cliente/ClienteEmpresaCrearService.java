package app.services.cliente;

import app.domain.entities.ClienteEntity;
import app.dto.cliente.ClienteEmpresaCrearRequestDto;
import app.dto.cliente.ClienteEmpresaCrearResponseDto;
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
public class ClienteEmpresaCrearService {

	private final ClienteStoredProcedureAdapter procedureAdapter;
	private final ClienteRepository clienteRepository;
	private final ClienteMapper clienteMapper;

	@Transactional
	public ClienteEmpresaCrearResponseDto create(ClienteEmpresaCrearRequestDto requestDto) {
		if (clienteRepository.existsByIdIdentificacion(requestDto.getIdIdentificacion())) {
			throw new BusinessRuleException("Ya existe un cliente con identificacion: " + requestDto.getIdIdentificacion());
		}
		Long idCliente = procedureAdapter.crearClienteEmpresa(requestDto);
		ClienteEntity cliente = clienteRepository.findById(idCliente)
			.orElseThrow(() -> new ResourceNotFoundException("No se pudo cargar el cliente creado: " + idCliente));
		return clienteMapper.toEmpresaResponse(cliente);
	}
}