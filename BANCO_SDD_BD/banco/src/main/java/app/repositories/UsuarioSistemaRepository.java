package app.repositories;

import java.util.Optional;

import app.domain.entities.UsuarioSistemaEntity;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UsuarioSistemaRepository extends JpaRepository<UsuarioSistemaEntity, Long> {

	@EntityGraph(attributePaths = {"rolSistema", "estadoUsuario"})
	Optional<UsuarioSistemaEntity> findByIdIdentificacion(String idIdentificacion);
}