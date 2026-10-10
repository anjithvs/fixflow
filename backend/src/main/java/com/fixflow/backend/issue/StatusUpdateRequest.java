package com.fixflow.backend.issue;

import jakarta.validation.constraints.NotNull;

public record StatusUpdateRequest(@NotNull IssueStatus status) {
}