package com.fixflow.backend.issue;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
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
    private final IssueEventRepository eventRepository;
    private final UserRepository userRepository;

    public IssueController(IssueRepository issueRepository,
                           IssueEventRepository eventRepository,
                           UserRepository userRepository) {
        this.issueRepository = issueRepository;
        this.eventRepository = eventRepository;
        this.userRepository = userRepository;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Transactional
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
        Issue saved = issueRepository.save(issue);

        eventRepository.save(new IssueEvent(
                saved, reporter, EventType.CREATED, null, IssueStatus.OPEN, "Issue reported"));

        return IssueResponse.from(saved);
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
        return IssueResponse.from(findAccessibleIssue(id, user));
    }

    @GetMapping("/{id}/events")
    public List<IssueEventResponse> events(@PathVariable Long id, Authentication authentication) {
        User user = currentUser(authentication);
        Issue issue = findAccessibleIssue(id, user);

        return eventRepository.findByIssueOrderByCreatedAtAscIdAsc(issue).stream()
                .map(IssueEventResponse::from)
                .toList();
    }

    @PatchMapping("/{id}/assign")
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public IssueResponse assign(@PathVariable Long id,
                                @Valid @RequestBody AssignRequest request,
                                Authentication authentication) {
        User admin = currentUser(authentication);

        Issue issue = issueRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Issue not found"));

        if (issue.getStatus() != IssueStatus.OPEN && issue.getStatus() != IssueStatus.ASSIGNED) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Only open or assigned issues can be assigned");
        }

        User technician = userRepository.findById(request.technicianId())
                .filter(u -> u.getRole() == Role.TECHNICIAN)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Technician not found"));

        IssueStatus before = issue.getStatus();
        issue.assignTo(technician);
        Issue saved = issueRepository.save(issue);

        eventRepository.save(new IssueEvent(
                saved, admin, EventType.ASSIGNED, before, IssueStatus.ASSIGNED,
                "Assigned to " + technician.getFullName()));

        return IssueResponse.from(saved);
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('TECHNICIAN')")
    @Transactional
    public IssueResponse updateStatus(@PathVariable Long id,
                                      @Valid @RequestBody StatusUpdateRequest request,
                                      Authentication authentication) {
        User technician = currentUser(authentication);

        Issue issue = issueRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Issue not found"));

        // A technician may only touch issues assigned to them.
        if (issue.getAssignedTo() == null
                || !issue.getAssignedTo().getId().equals(technician.getId())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Issue not found");
        }

        IssueStatus from = issue.getStatus();
        IssueStatus to = request.status();

        boolean allowed = (from == IssueStatus.ASSIGNED && to == IssueStatus.IN_PROGRESS)
                || (from == IssueStatus.IN_PROGRESS && to == IssueStatus.RESOLVED);

        if (!allowed) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Cannot change status from " + from + " to " + to);
        }

        issue.changeStatus(to);
        Issue saved = issueRepository.save(issue);

        eventRepository.save(new IssueEvent(
                saved, technician, EventType.STATUS_CHANGED, from, to, null));

        return IssueResponse.from(saved);
    }

    // Returns the issue only if this user is allowed to see it.
    private Issue findAccessibleIssue(Long id, User user) {
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
        return issue;
    }

    private User currentUser(Authentication authentication) {
        return userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User no longer exists"));
    }
}