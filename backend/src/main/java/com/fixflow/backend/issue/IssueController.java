package com.fixflow.backend.issue;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.fixflow.backend.user.Role;
import com.fixflow.backend.user.User;
import com.fixflow.backend.user.UserRepository;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/issues")
public class IssueController {

    private final IssueRepository issueRepository;
    private final UserRepository userRepository;

    public IssueController(IssueRepository issueRepository, UserRepository userRepository) {
        this.issueRepository = issueRepository;
        this.userRepository = userRepository;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public IssueResponse create(@Valid @RequestBody CreateIssueRequest request,
                                Authentication authentication) {
        User reporter = currentUser(authentication);

        Issue issue = new Issue(
                request.title().trim(),
                request.description().trim(),
                request.category(),
                request.priority(),
                request.location().trim(),
                reporter);

        return IssueResponse.from(issueRepository.save(issue));
    }

    @GetMapping
    public List<IssueResponse> list(Authentication authentication) {
        User user = currentUser(authentication);

        List<Issue> issues = switch (user.getRole()) {
            case ADMIN -> issueRepository.findAllByOrderByCreatedAtDesc();
            case TECHNICIAN -> issueRepository.findByAssignedToOrderByCreatedAtDesc(user);
            case RESIDENT -> issueRepository.findByReporterOrderByCreatedAtDesc(user);
        };

        return issues.stream().map(IssueResponse::from).toList();
    }

    @GetMapping("/{id}")
    public IssueResponse get(@PathVariable Long id, Authentication authentication) {
        User user = currentUser(authentication);

        Issue issue = issueRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Issue not found"));

        boolean allowed = user.getRole() == Role.ADMIN
                || issue.getReporter().getId().equals(user.getId())
                || (issue.getAssignedTo() != null
                    && issue.getAssignedTo().getId().equals(user.getId()));

        if (!allowed) {
            // Same answer as "not found", so outsiders can't discover which IDs exist.
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Issue not found");
        }
        return IssueResponse.from(issue);
    }

    private User currentUser(Authentication authentication) {
        return userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User no longer exists"));
    }
}