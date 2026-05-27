package app.mapper;

import app.domain.entities.CatTipoClienteEntity;
import app.dto.CatTipoClienteRequestDto;
import app.dto.CatTipoClienteResponseDto;
import org.springframework.stereotype.Component;

@Component
public class CatTipoClienteMapper {

	public CatTipoClienteResponseDto toResponse(CatTipoClienteEntity entity) {
		return CatTipoClienteResponseDto.builder()
			.idCatalogo(entity.getIdCatalogo())
			.codigo(entity.getCodigo())
			.nombre(entity.getNombre())
			.descripcion(entity.getDescripcion())
			.activo(entity.getActivo())
			.orden(entity.getOrden())
			.createdAt(entity.getCreatedAt())
			.updatedAt(entity.getUpdatedAt())
			.createdBy(entity.getCreatedBy())
			.updatedBy(entity.getUpdatedBy())
			.build();
	}

	public CatTipoClienteEntity toEntity(CatTipoClienteRequestDto requestDto) {
		CatTipoClienteEntity entity = new CatTipoClienteEntity();
		apply(requestDto, entity);
		return entity;
	}

	public void apply(CatTipoClienteRequestDto requestDto, CatTipoClienteEntity entity) {
		entity.setCodigo(requestDto.getCodigo());
		entity.setNombre(requestDto.getNombre());
		entity.setDescripcion(requestDto.getDescripcion());
		entity.setActivo(requestDto.getActivo());
		entity.setOrden(requestDto.getOrden());
	}
}