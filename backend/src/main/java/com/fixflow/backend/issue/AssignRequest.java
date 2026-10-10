package com.fixflow.backend.issue;

import jakarta.validation.constraints.NotNull;

public record AssignRequest(@NotNull Long technicianId) {
}