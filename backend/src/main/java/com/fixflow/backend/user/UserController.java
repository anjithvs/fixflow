package com.fixflow.backend.user;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
public class UserController {

    public record TechnicianResponse(Long id, String fullName, String email) {
    }

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/technicians")
    @PreAuthorize("hasRole('ADMIN')")
    public List<TechnicianResponse> technicians() {
        return userRepository.findByRoleOrderByFullNameAsc(Role.TECHNICIAN).stream()
                .map(u -> new TechnicianResponse(u.getId(), u.getFullName(), u.getEmail()))
                .toList();
    }
}