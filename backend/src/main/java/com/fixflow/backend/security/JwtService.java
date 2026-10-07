   package com.fixflow.backend.security;

   import java.nio.charset.StandardCharsets;
   import java.util.Date;

   import javax.crypto.SecretKey;

   import org.springframework.beans.factory.annotation.Value;
   import org.springframework.stereotype.Service;

   import com.fixflow.backend.user.User;

   import io.jsonwebtoken.Claims;
   import io.jsonwebtoken.Jwts;
   import io.jsonwebtoken.security.Keys;

   @Service
   public class JwtService {

       private final SecretKey key;
       private final long expirationMs;

       public JwtService(
               @Value("${app.jwt.secret}") String secret,
               @Value("${app.jwt.expiration-minutes}") long expirationMinutes) {
           this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
           this.expirationMs = expirationMinutes * 60 * 1000;
       }

       public String generateToken(User user) {
           Date now = new Date();
           return Jwts.builder()
                   .subject(user.getEmail())
                   .claim("role", user.getRole().name())
                   .issuedAt(now)
                   .expiration(new Date(now.getTime() + expirationMs))
                   .signWith(key)
                   .compact();
       }

       // Throws an exception if the token is fake, changed, or expired
       public Claims parse(String token) {
           return Jwts.parser()
                   .verifyWith(key)
                   .build()
                   .parseSignedClaims(token)
                   .getPayload();
       }
   }