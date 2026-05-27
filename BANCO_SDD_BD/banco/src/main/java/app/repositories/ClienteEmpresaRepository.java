package app.repositories;

import app.domain.entities.ClienteEmpresaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteEmpresaRepository extends JpaRepository<ClienteEmpresaEntity, Long> {
}