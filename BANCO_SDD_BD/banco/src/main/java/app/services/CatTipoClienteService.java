package app.services;

import java.util.List;

import app.domain.entities.CatTipoClienteEntity;
import app.dto.CatTipoClienteRequestDto;
import app.dto.CatTipoClienteResponseDto;
import app.exceptions.BusinessRuleException;
import app.exceptions.ResourceNotFoundException;
import app.mapper.CatTipoClienteMapper;
import app.repositories.CatTipoClienteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CatTipoClienteService {

	private final CatTipoClienteRepository repository;
	private final CatTipoClienteMapper mapper;

	public List<CatTipoClienteResponseDto> findAll() {
		return repository.findAll().stream()
			.map(mapper::toResponse)
			.toList();
	}

	public CatTipoClienteResponseDto findById(Long idCatalogo) {
		return repository.findById(idCatalogo)
			.map(mapper::toResponse)
			.orElseThrow(() -> new ResourceNotFoundException("Tipo de cliente no encontrado: " + idCatalogo));
	}

	@Transactional
	public CatTipoClienteResponseDto create(CatTipoClienteRequestDto requestDto) {
		if (repository.existsByCodigo(requestDto.getCodigo())) {
			throw new BusinessRuleException("Ya existe un tipo de cliente con codigo: " + requestDto.getCodigo());
		}
		CatTipoClienteEntity entity = mapper.toEntity(requestDto);
		return mapper.toResponse(repository.save(entity));
	}

	@Transactional
	public CatTipoClienteResponseDto update(Long idCatalogo, CatTipoClienteRequestDto requestDto) {
		CatTipoClienteEntity entity = repository.findById(idCatalogo)
			.orElseThrow(() -> new ResourceNotFoundException("Tipo de cliente no encontrado: " + idCatalogo));

		repository.findByCodigo(requestDto.getCodigo())
			.filter(existing -> !existing.getIdCatalogo().equals(idCatalogo))
			.ifPresent(existing -> {
				throw new BusinessRuleException("Ya existe un tipo de cliente con codigo: " + requestDto.getCodigo());
			});

		mapper.apply(requestDto, entity);
		return mapper.toResponse(repository.save(entity));
	}
}