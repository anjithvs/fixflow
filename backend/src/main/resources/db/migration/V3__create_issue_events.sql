   CREATE TABLE issue_events (
       id          BIGSERIAL PRIMARY KEY,
       issue_id    BIGINT       NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
       actor_id    BIGINT       NOT NULL REFERENCES users(id),
       event_type  VARCHAR(20)  NOT NULL
                   CHECK (event_type IN ('CREATED','ASSIGNED','STATUS_CHANGED')),
       from_status VARCHAR(20),
       to_status   VARCHAR(20),
       detail      VARCHAR(255),
       created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
   );

   CREATE INDEX idx_issue_events_issue ON issue_events(issue_id);

   -- Add a "created" history row for the issues you already made while testing
   INSERT INTO issue_events (issue_id, actor_id, event_type, to_status, detail, created_at)
   SELECT id, reporter_id, 'CREATED', 'OPEN', 'Issue reported', created_at
   FROM issues;