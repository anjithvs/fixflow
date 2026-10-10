package com.fixflow.backend.issue;

import java.time.Instant;

public record IssueEventResponse(
        Long id,
        EventType eventType,
        IssueStatus fromStatus,
        IssueStatus toStatus,
        String detail,
        String actorName,
        Instant createdAt) {

    public static IssueEventResponse from(IssueEvent event) {
        return new IssueEventResponse(
                event.getId(),
                event.getEventType(),
                event.getFromStatus(),
                event.getToStatus(),
                event.getDetail(),
                event.getActor().getFullName(),
                event.getCreatedAt());
    }
}