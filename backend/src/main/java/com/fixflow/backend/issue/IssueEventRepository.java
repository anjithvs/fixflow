package com.fixflow.backend.issue;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface IssueEventRepository extends JpaRepository<IssueEvent, Long> {

    List<IssueEvent> findByIssueOrderByCreatedAtAscIdAsc(Issue issue);
}