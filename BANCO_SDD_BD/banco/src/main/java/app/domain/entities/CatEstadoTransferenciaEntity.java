package app.domain.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@Entity
@Table(name = "cat_estado_transferencia")
@EqualsAndHashCode(callSuper = true)
public class CatEstadoTransferenciaEntity extends CatalogoBaseEntity {
}