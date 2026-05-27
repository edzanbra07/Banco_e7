package app.repositories;

import java.util.Optional;

import app.domain.entities.ClienteEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteRepository extends JpaRepository<ClienteEntity, Long> {

	Optional<ClienteEntity> findByIdIdentificacion(String idIdentificacion);

	boolean existsByIdIdentificacion(String idIdentificacion);
}