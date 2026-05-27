package app.repositories;

import java.util.Optional;

import app.domain.entities.CatTipoClienteEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CatTipoClienteRepository extends JpaRepository<CatTipoClienteEntity, Long> {

	Optional<CatTipoClienteEntity> findByCodigo(String codigo);

	boolean existsByCodigo(String codigo);
}