package app.repositories;

import app.domain.entities.CatMonedaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CatMonedaRepository extends JpaRepository<CatMonedaEntity, Long> {
}