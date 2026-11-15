-- migration 000: a table that remembers which migrations ran
CREATE TABLE schema_migrations (
  version    int PRIMARY KEY,
  name       text NOT NULL,
  applied_at timestamptz NOT NULL DEFAULT now()
);
