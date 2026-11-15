-- M19-L01 setup: the demo role reporter
-- It cannot log in and has no password. After the video's REVOKE it holds no grants.
-- Run as postgres. Safe to run again: it creates the role only if it is missing.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'reporter') THEN
    CREATE ROLE reporter;
  END IF;
END
$$;
