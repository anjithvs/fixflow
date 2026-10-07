   CREATE TABLE users (
       id            BIGSERIAL PRIMARY KEY,
       email         VARCHAR(255) NOT NULL UNIQUE,
       password_hash VARCHAR(255) NOT NULL,
       full_name     VARCHAR(120) NOT NULL,
       role          VARCHAR(20)  NOT NULL CHECK (role IN ('RESIDENT','TECHNICIAN','ADMIN')),
       created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
       updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
   );