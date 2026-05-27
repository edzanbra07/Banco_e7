package app.repositories;

import app.domain.entities.ClientePersonaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClientePersonaRepository extends JpaRepository<ClientePersonaEntity, Long> {
}