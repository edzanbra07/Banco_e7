package app.repositories;

import app.domain.entities.CatEstadoCuentaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CatEstadoCuentaRepository extends JpaRepository<CatEstadoCuentaEntity, Long> {
}