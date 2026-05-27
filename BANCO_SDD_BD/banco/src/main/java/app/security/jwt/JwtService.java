package app.security.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.Instant;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.function.Function;
import app.security.BancoUserDetails;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
public class JwtService {

	private final String secret;
	private final long expirationMinutes;

	public JwtService(
		@Value("${app.security.jwt.secret:YmFuY28tc2VjdXJpZGFkLXNlY3JldC1rZXktMzItYnl0ZXM=}") String secret,
		@Value("${app.security.jwt.expiration-minutes:60}") long expirationMinutes) {
		this.secret = secret;
		this.expirationMinutes = expirationMinutes;
	}

	public String generateToken(UserDetails userDetails) {
		Map<String, Object> claims = new LinkedHashMap<>();
		claims.put("roles", userDetails.getAuthorities().stream().map(Object::toString).toList());
		if (userDetails instanceof BancoUserDetails bancoUserDetails) {
			claims.put("userId", bancoUserDetails.getIdUsuario());
		}
		Instant now = Instant.now();
		return Jwts.builder()
			.setClaims(claims)
			.setSubject(userDetails.getUsername())
			.setIssuedAt(Date.from(now))
			.setExpiration(Date.from(now.plusSeconds(expirationMinutes * 60)))
			.signWith(getSigningKey(), SignatureAlgorithm.HS256)
			.compact();
	}

	public String extractUsername(String token) {
		return extractClaim(token, Claims::getSubject);
	}

	public boolean isTokenValid(String token, UserDetails userDetails) {
		return extractUsername(token).equals(userDetails.getUsername()) && !isTokenExpired(token);
	}

	private boolean isTokenExpired(String token) {
		return extractExpiration(token).before(new Date());
	}

	private Date extractExpiration(String token) {
		return extractClaim(token, Claims::getExpiration);
	}

	private <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
		Claims claims = Jwts.parserBuilder().setSigningKey(getSigningKey()).build().parseClaimsJws(token).getBody();
		return claimsResolver.apply(claims);
	}

	private Key getSigningKey() {
		byte[] keyBytes;
		try {
			keyBytes = Decoders.BASE64.decode(secret);
		} catch (IllegalArgumentException ex) {
			keyBytes = secret.getBytes(StandardCharsets.UTF_8);
		}
		return Keys.hmacShaKeyFor(keyBytes);
	}
}