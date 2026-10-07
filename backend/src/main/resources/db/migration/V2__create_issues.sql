   CREATE TABLE issues (
       id              BIGSERIAL PRIMARY KEY,
       title           VARCHAR(150)  NOT NULL,
       description     VARCHAR(2000) NOT NULL,
       category        VARCHAR(20)   NOT NULL
                       CHECK (category IN ('PLUMBING','ELECTRICAL','CLEANING','FURNITURE','OTHER')),
       priority        VARCHAR(20)   NOT NULL
                       CHECK (priority IN ('LOW','MEDIUM','HIGH','URGENT')),
       status          VARCHAR(20)   NOT NULL DEFAULT 'OPEN'
                       CHECK (status IN ('OPEN','ASSIGNED','IN_PROGRESS','RESOLVED')),
       location        VARCHAR(150)  NOT NULL,
       reporter_id     BIGINT        NOT NULL REFERENCES users(id),
       assigned_to_id  BIGINT        REFERENCES users(id),
       created_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
       updated_at      TIMESTAMPTZ   NOT NULL DEFAULT now()
   );

   CREATE INDEX idx_issues_reporter ON issues(reporter_id);
   CREATE INDEX idx_issues_assigned ON issues(assigned_to_id);
   CREATE INDEX idx_issues_status   ON issues(status);