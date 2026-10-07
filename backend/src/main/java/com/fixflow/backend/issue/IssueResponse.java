package com.fixflow.backend.issue;

import java.time.Instant;

public record IssueResponse(
        Long id,
        String title,
        String description,
        Category category,
        Priority priority,
        IssueStatus status,
        String location,
        String reporterName,
        String assignedToName,
        Instant createdAt) {

    public static IssueResponse from(Issue issue) {
        return new IssueResponse(
                issue.getId(),
                issue.getTitle(),
                issue.getDescription(),
                issue.getCategory(),
                issue.getPriority(),
                issue.getStatus(),
                issue.getLocation(),
                issue.getReporter().getFullName(),
                issue.getAssignedTo() == null ? null : issue.getAssignedTo().getFullName(),
                issue.getCreatedAt());
    }
}