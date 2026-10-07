   package com.fixflow.backend.auth;

   import org.springframework.http.HttpStatus;
   import org.springframework.security.crypto.password.PasswordEncoder;
   import org.springframework.web.bind.annotation.PostMapping;
   import org.springframework.web.bind.annotation.RequestBody;
   import org.springframework.web.bind.annotation.RequestMapping;
   import org.springframework.web.bind.annotation.ResponseStatus;
   import org.springframework.web.bind.annotation.RestController;
   import org.springframework.web.server.ResponseStatusException;

   import com.fixflow.backend.security.JwtService;
   import com.fixflow.backend.user.Role;
   import com.fixflow.backend.user.User;
   import com.fixflow.backend.user.UserRepository;

   import jakarta.validation.Valid;

   @RestController
   @RequestMapping("/api/auth")
   public class AuthController {

       private final UserRepository userRepository;
       private final PasswordEncoder passwordEncoder;
       private final JwtService jwtService;

       public AuthController(UserRepository userRepository,
                             PasswordEncoder passwordEncoder,
                             JwtService jwtService) {
           this.userRepository = userRepository;
           this.passwordEncoder = passwordEncoder;
           this.jwtService = jwtService;
       }

       @PostMapping("/register")
       @ResponseStatus(HttpStatus.CREATED)
       public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
           String email = request.email().trim().toLowerCase();

           if (userRepository.existsByEmail(email)) {
               throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already registered");
           }

           // Public sign-up is ALWAYS a resident
           User user = new User(
                   email,
                   passwordEncoder.encode(request.password()),
                   request.fullName().trim(),
                   Role.RESIDENT);
           userRepository.save(user);

           return toResponse(user);
       }

       @PostMapping("/login")
       public AuthResponse login(@Valid @RequestBody LoginRequest request) {
           String email = request.email().trim().toLowerCase();

           User user = userRepository.findByEmail(email)
                   .orElseThrow(() -> new ResponseStatusException(
                           HttpStatus.UNAUTHORIZED, "Invalid email or password"));

           if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
               throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password");
           }

           return toResponse(user);
       }

       private AuthResponse toResponse(User user) {
           return new AuthResponse(
                   jwtService.generateToken(user),
                   user.getEmail(),
                   user.getFullName(),
                   user.getRole().name());
       }
   }