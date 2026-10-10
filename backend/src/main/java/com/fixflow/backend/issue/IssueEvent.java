package com.fixflow.backend.issue;

import java.time.Instant;

import com.fixflow.backend.user.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "issue_events")
public class IssueEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "issue_id")
    private Issue issue;

    @ManyToOne(optional = false)
    @JoinColumn(name = "actor_id")
    private User actor;

    @Enumerated(EnumType.STRING)
    @Column(name = "event_type", nullable = false, length = 20)
    private EventType eventType;

    @Enumerated(EnumType.STRING)
    @Column(name = "from_status", length = 20)
    private IssueStatus fromStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "to_status", length = 20)
    private IssueStatus toStatus;

    @Column(length = 255)
    private String detail;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    // JPA needs an empty constructor
    protected IssueEvent() {
    }

    public IssueEvent(Issue issue, User actor, EventType eventType,
                      IssueStatus fromStatus, IssueStatus toStatus, String detail) {
        this.issue = issue;
        this.actor = actor;
        this.eventType = eventType;
        this.fromStatus = fromStatus;
        this.toStatus = toStatus;
        this.detail = detail;
        this.createdAt = Instant.now();
    }

    public Long getId() { return id; }
    public Issue getIssue() { return issue; }
    public User getActor() { return actor; }
    public EventType getEventType() { return eventType; }
    public IssueStatus getFromStatus() { return fromStatus; }
    public IssueStatus getToStatus() { return toStatus; }
    public String getDetail() { return detail; }
    public Instant getCreatedAt() { return createdAt; }
}