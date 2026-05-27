package app.security;

import app.domain.entities.UsuarioSistemaEntity;
import app.repositories.UsuarioSistemaRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BancoUserDetailsService implements UserDetailsService {

	private final UsuarioSistemaRepository usuarioSistemaRepository;

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		UsuarioSistemaEntity usuario = usuarioSistemaRepository.findByIdIdentificacion(username)
			.orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado: " + username));

		if (usuario.getEstadoUsuario() == null || usuario.getEstadoUsuario().getCodigo() == null || !"ACTIVO".equals(usuario.getEstadoUsuario().getCodigo())) {
			throw new DisabledException("Usuario inactivo: " + username);
		}
		if (usuario.getRolSistema() == null || usuario.getRolSistema().getCodigo() == null) {
			throw new UsernameNotFoundException("Usuario sin rol asignado: " + username);
		}

		List<GrantedAuthority> authorities = List.of(new SimpleGrantedAuthority("ROLE_" + usuario.getRolSistema().getCodigo()));
		return new BancoUserDetails(usuario.getIdUsuario(), usuario.getIdIdentificacion(), usuario.getContrasenaHash(), authorities);
	}
}